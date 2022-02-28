defmodule Circularly.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Circularly.Repo

  alias Circularly.Accounts.{Organization, User, Permission, UserToken, UserNotifier}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  @spec get_user_by_email(String.t()) :: User.t() | nil
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, [email: email], skip_org_id: true)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  @spec get_user_by_email_and_password(String.t(), String.t()) :: User.t() | nil
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, [email: email], skip_org_id: true)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(String.t()) :: User.t() | Exception.t()
  def get_user!(id), do: Repo.get!(User, id, skip_org_id: true)

  ## User registration

  @doc """
  Registers a user, creates a corresponding organization and creates a permissions record
  that makes the created user admin in created oranization.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec register_user(%{}) ::
          {:error, Ecto.Changeset.t()}
          | {:ok, %{organization: Organization.t(), user: User.t(), permission: Permission.t()}}
  def register_user(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, User.registration_changeset(%User{}, attrs), skip_org_id: true)
    |> Ecto.Multi.insert(:organization, %Organization{}, skip_org_id: true, returning: [:slug])
    |> Ecto.Multi.insert(
      :permission,
      fn %{
           organization: %Organization{org_id: org_id},
           user: %User{id: user_id}
         } ->
        Permission.grant_owner_changeset(%Permission{}, %{user_id: user_id, org_id: org_id})
      end,
      skip_org_id: true
    )
    |> Repo.transaction()
    |> case do
      {:ok, response} ->
        {:ok, response}

      {:error, :user, user_changeset, _} ->
        {:error, user_changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user_registration(User.t(), %{}) :: Ecto.Changeset.t()
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user_email(User.t(), %{}) :: Ecto.Changeset.t()
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec apply_user_email(User.t(), String.t(), %{}) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  @spec update_user_email(User.t(), String.t()) :: :error | :ok
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query, skip_org_id: true),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset, skip_org_id: true)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]),
      skip_org_id: true
    )
  end

  @doc """
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_update_email_instructions(user, current_email, &Routes.user_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  @spec deliver_update_email_instructions(User.t(), String.t(), (any -> any)) ::
          {:error, any} | {:ok, Swoosh.Email.t()}
  def deliver_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token, skip_org_id: true)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user_password(User.t(), %{}) :: Ecto.Changeset.t()
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user_password(User.t(), String.t(), %{}) ::
          {:error, Ecto.Changeset.t()} | {:ok, User.t()}
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset, skip_org_id: true)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all),
      skip_org_id: true
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  @spec generate_user_session_token(User.t()) :: String.t()
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token, skip_org_id: true)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  @spec get_user_by_session_token(String.t()) :: User.t() | nil | Ecto.MultipleResultsError
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query, skip_org_id: true)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  @spec delete_session_token(String.t()) :: :ok
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"), skip_org_id: true)
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &Routes.user_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &Routes.user_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  @spec deliver_user_confirmation_instructions(User.t(), (any -> any)) ::
          {:error, any} | {:ok, Swoosh.Email.t()}
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token, skip_org_id: true)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  @spec confirm_user(String.t()) :: :error | {:ok, User.t()}
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query, skip_org_id: true),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user), skip_org_id: true)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]),
      skip_org_id: true
    )
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &Routes.user_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  @spec deliver_user_reset_password_instructions(User.t(), (any -> any)) ::
          {:error, any} | {:ok, Swoosh.Email.t()}
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token, skip_org_id: true)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  @spec get_user_by_reset_password_token(String.t()) :: nil | User.t()
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query, skip_org_id: true) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  @spec reset_user_password(User.t(), %{}) :: {:error, any} | {:ok, any}
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs), skip_org_id: true)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all),
      skip_org_id: true
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Returns the list of organizations a user is permitted to access.

  ## Examples

      iex> list_organizations_for(current_user)
      [%Organization{}, ...]

  """
  @spec list_organizations_for(User.t()) :: [Organization.t()]
  def list_organizations_for(user) do
    query =
      from o in Circularly.Accounts.Organization,
        join: p in Circularly.Accounts.Permission,
        on: o.org_id == p.org_id,
        where: p.user_id == ^user.id

    Repo.all(query, skip_org_id: true)
  end

  @doc """
  Gets a single organization the given user has permission to access.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization_for!(current_user, "11111111-dead-beef-1111-111111111111")
      %Organization{}

      iex> get_organization_for!(current_user, "11111111-dead-beef-1111-000000000000")
      ** (Ecto.NoResultsError)

  """
  @spec get_organization_for!(User.t(), String.t()) :: Organization.t() | Exception.t()
  def get_organization_for!(user, org_slug) do
    query =
      from o in Circularly.Accounts.Organization,
        join: p in Circularly.Accounts.Permission,
        on: o.org_id == p.org_id,
        where: p.user_id == ^user.id and o.slug == ^org_slug

    Repo.one!(query, skip_org_id: true)
  end

  @doc """
  Gets a single organization the given user has permission to access as well as the user's permissions for this organization.

  ## Examples

      iex> get_organization_and_permission_for(current_user, "valid_org_slug")
      {:ok, organization: %Organization{}, permission: %Permission{}}

      iex> get_organization_and_permission_for(current_user, "invalid_org_slug")
      nil

      iex> get_organization_and_permission_for(current_user, nil)
      nil

  """
  @spec get_organization_and_permission_for(User.t(), String.t()) ::
          {:ok, organization: Organization.t(), permission: Permission.t()} | nil
  def get_organization_and_permission_for(user, org_slug)
      when is_nil(user) or is_nil(org_slug) do
    nil
  end

  def get_organization_and_permission_for(user, org_slug) do
    query =
      from p in Permission,
        join: o in Organization,
        on: p.org_id == o.org_id,
        where: o.slug == ^org_slug and p.user_id == ^user.id,
        select: {:ok, organization: o, permission: p}

    Repo.one(query, skip_org_id: true)
  end

  @doc """
  Creates a organization for a given user and set permission for this user to admin.

  ## Examples

      iex> create_organization_for(current_user, %{field: value})
      {:ok, %Organization{}}

      iex> create_organization_for(current_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_organization_for(User.t(), %{}) ::
          {:error, Ecto.Changeset.t()} | {:ok, Organization.t()}
  def create_organization_for(user, attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:organization, Organization.changeset(%Organization{}, attrs))
    |> Ecto.Multi.insert(
      :permission,
      fn %{organization: %Organization{org_id: org_id}} ->
        Permission.grant_admin_changeset(%Permission{}, %{user_id: user.id, org_id: org_id})
      end,
      skip_org_id: true
    )
    |> Repo.transaction()
    |> case do
      {:ok, response} ->
        {:ok, response.organization}

      {:error, :organization, organization_changeset, _} ->
        {:error, organization_changeset}
    end
  end

  @doc """
  Updates a organization if the given user has admin privileges.

  ## Examples

      iex> update_organization_for(current_user, organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization_for(current_user, other_organization, %{field: new_value})
      {:error, "Not permitted"}

      iex> update_organization_for(current_user, organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_organization_for(User.t(), Organization.t(), %{}) ::
          {:ok, Organization.t()} | {:error, Ecto.Changeset.t()} | {:error, String.t()}
  def update_organization_for(user, %Organization{} = organization, attrs) do
    if is_owner(user, organization) do
      organization
      |> Organization.changeset(attrs)
      |> Repo.update(skip_org_id: true)
    else
      {:error, "Not permitted"}
    end
  end

  @doc """
  Deletes an organization if the given user has admin privileges..

  ## Examples

      iex> delete_organization_for(user, organization)
      {:ok, %Organization{}}

      iex> delete_organization_for(user, organization)
      {:error, %Ecto.Changeset{}}

      iex> delete_organization_for(user, other_organization)
      {:error, "Not permitted"}

  """
  @spec delete_organization_for(User.t(), Organization.t()) ::
          {:ok, Organization.t()} | {:error, Ecto.Changeset.t()} | {:error, String.t()}
  def delete_organization_for(user, %Organization{} = organization) do
    if is_owner(user, organization) do
      Repo.delete(organization)
    else
      {:error, "Not permitted"}
    end
  end

  defp is_owner(user, organization) do
    Repo.get_by(
      Permission,
      [user_id: user.id, org_id: organization.org_id, rights: [:owner]],
      skip_org_id: true
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  @spec change_organization(Organization.t(), %{}) :: Ecto.Changeset.t()
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end
end
