defmodule Circularly.Repo do
  use Ecto.Repo,
    otp_app: :circularly,
    adapter: Ecto.Adapters.Postgres
end
