defmodule JobOffersService.Repo do
  use Ecto.Repo,
    otp_app: :job_offers_service,
    adapter: Ecto.Adapters.Postgres
end
