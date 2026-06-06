defmodule Rotinaeco.Repo do
  use Ecto.Repo,
    otp_app: :rotinaeco,
    adapter: Ecto.Adapters.Postgres
end
