defmodule JobOffersServiceWeb.OffersController do
  use JobOffersServiceWeb, :controller
  require Logger

  alias JobOffersService.OffersSrv

  def show(conn, params) do
    %{"lat" => lat_str, "lon" => lon_str, "radius" => radius_str} = params

    try do
      point = {String.to_float(lat_str), String.to_float(lon_str)}
      radius = String.to_integer(radius_str)

      res = OffersSrv.find_nearest_jobs(point, radius)
      conn |> put_status(200) |> json(res)
    rescue
      e ->
        Logger.error("Error through parsing controller parameters with reason: #{inspect(e)}")
        conn |> put_status(400) |> json(%{error: :unexpected_behavior})
    end
  end
end
