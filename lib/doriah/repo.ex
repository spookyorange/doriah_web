defmodule Doriah.Repo do
  use Ecto.Repo,
    otp_app: :doriah,
    adapter: Ecto.Adapters.Postgres
end
