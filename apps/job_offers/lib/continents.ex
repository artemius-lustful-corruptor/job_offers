defmodule JobOffers.Continents do
  @moduledoc """
  Function to operate with continents
  and geographic calculations
  """

  @doc """
  Finding continent
  """
  @spec find_continent(list(), String.t(), String.t()) :: String.t()
  def find_continent(continents, lat, lon) do
    Enum.find(continents, fn {_, cords} ->
      [{a_lng, a_lat}, {b_lng, b_lat}, {c_lng, c_lat}, {d_lng, d_lat}] = cords

      {lat_min, lat_max} = Enum.min_max([a_lat, b_lat, c_lat, d_lat])
      {lon_min, lon_max} = Enum.min_max([a_lng, b_lng, c_lng, d_lng])

      lat_cords = lat_min..lat_max
      lon_cords = lon_min..lon_max

      case {verify_cords(lat, lat_cords), verify_cords(lon, lon_cords)} do
        {true, true} -> true
        _s -> false
      end
    end)
  end

  defp verify_cords(c, cords) do
    ceil(c) in cords
  end
end
