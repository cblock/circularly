defmodule CircularlyWeb.UserAuth do
  @moduledoc false
  import Plug.Conn
  import Phoenix.Controller

  require Logger

  alias Phoenix.LiveView
  alias Circularly.Accounts
  alias CircularlyWeb.Router.Helpers, as: Routes

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_circularly_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Accounts.delete_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      CircularlyWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: "/")
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_current_user(conn, _opts) do
    with {user_token, conn} <- ensure_user_token(conn),
         {:ok, current_user} <- Accounts.get_user_by_session_token(user_token) do
      assign(conn, :current_user, current_user)
    else
      _ ->
        assign(conn, :current_user, nil)
    end
  end

  defp ensure_user_token(conn) do
    if user_token = get_session(conn, :user_token) do
      {user_token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if user_token = conn.cookies[@remember_me_cookie] do
        {user_token, put_session(conn, :user_token, user_token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
   Sets `:current user` and `:current_user_org_membership` on LiveView socket
  """
  def on_mount(
        :assign_current_user,
        _params,
        %{"user_token" => user_token} = _session,
        socket
      ) do
    case Accounts.get_user_by_session_token(user_token) do
      {:ok, current_user} ->
        new_socket = LiveView.assign_new(socket, :current_user, fn -> current_user end)
        {:cont, new_socket}

      _ ->
        {:halt, live_redirect_require_login(socket)}
    end
  end

  def on_mount(
        :assign_current_user_and_org_membership,
        %{"org_slug" => org_slug} = _params,
        %{"user_token" => user_token} = _session,
        socket
      ) do
    with {:ok, current_user} <- Accounts.get_user_by_session_token(user_token),
         {:ok, current_user_org_membership} <-
           Accounts.get_user_org_membership(current_user, org_slug) do
      new_socket =
        socket
        |> LiveView.assign_new(:current_user, fn -> current_user end)
        |> LiveView.assign_new(:current_user_org_membership, fn -> current_user_org_membership end)

      {:cont, new_socket}
    else
      _ ->
        {:halt,
         live_redirect_require_login(socket, "This resource does not exist or cannot be accessed")}
    end
  end

  defp live_redirect_require_login(socket, error_message \\ "Please sign in") do
    socket
    |> LiveView.put_flash(:error, error_message)
    |> LiveView.redirect(to: Routes.user_session_path(socket, :new))
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: Routes.user_session_path(conn, :new))
      |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: "/"
end
