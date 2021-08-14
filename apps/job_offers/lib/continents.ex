defmodule JobOffers.Continents do
  @moduledoc """
  Function to operate with continents
  and geographic calculations
  """

  require Logger

  @doc """
  Finding continent
  """
  @spec find(list(), float(), float()) :: any()
  def find(continents, lat, lon) do
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

  @doc """
  Group professions and jobs to continents
  """
  @spec group(map(), map(), list(), list()) :: map()
  def group(job, acc, professions, continents) do
    try do
      %{
        "profession_id" => id,
        "office_latitude" => latitude,
        "office_longitude" => longtitude
      } = job

      lat = String.to_float(latitude)
      lon = String.to_float(longtitude)
      prof_job = recognize(job, professions, id)

      case find(continents, lat, lon) do
        nil ->
          Map.put(acc, "unknown", [prof_job | acc["unknown"]])

        {continent, _} ->
          Map.put(acc, continent, [prof_job | acc[continent]])
      end
    rescue
      ArgumentError ->
        acc
    end
  end

  @doc """
  Calculate distance between two points
  """
  @spec distance(tuple(), tuple()) :: float() | 0
  def distance(a, b) do
    with {lat_a, lon_a} <- a,
         {lat_b, lon_b} <- b,
         {:ok, r} <- Confex.fetch_env(:job_offers, :earth_radius) do
      d =
        (ElixirMath.sin(lat_a) * ElixirMath.sin(lat_b) +
           ElixirMath.cos(lat_a) * ElixirMath.cos(lat_b) * ElixirMath.cos(lon_a - lon_b))
        |> ElixirMath.acos()

      d * r
    else
      e ->
        Logger.warn("Unexpected distance calculation with reason: #{inspect(e)}")
        0
    end
  end

  defp verify_cords(c, cords) do
    ceil(c) in cords
  end

  defp recognize(x, professions, id) do
    case professions[id] do
      nil ->
        x |> Map.put("category_name", "unknown")

      %{"name" => name, "category_name" => category_name} ->
        x
        |> Map.put("name", name)
        |> Map.put("category_name", category_name)
    end
  end
end
