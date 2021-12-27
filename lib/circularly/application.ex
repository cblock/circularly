defmodule Circularly.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Circularly.Repo,
      # Start the Telemetry supervisor
      CircularlyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Circularly.PubSub},
      # Start the Endpoint (http/https)
      CircularlyWeb.Endpoint
      # Start a worker by calling: Circularly.Worker.start_link(arg)
      # {Circularly.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Circularly.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CircularlyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
