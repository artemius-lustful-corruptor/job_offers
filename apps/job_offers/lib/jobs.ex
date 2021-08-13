defmodule JobOffers.Jobs do
  @moduledoc """
  Functions to operate with jobs
  """

  alias JobOffers.Continents
  alias JobOffers.Professions
  require Logger
  @priv_dir :code.priv_dir(:job_offers)

  @doc """
  Setting grouped jobs
  """
  @spec set_grouped_jobs() :: {:ok, map()} | {:error, :grouping}
  def set_grouped_jobs do
    with {:ok, professions_path} <- Confex.fetch_env(:job_offers, :professions_csv),
         {:ok, path} <- Confex.fetch_env(:job_offers, :jobs_csv),
         {:ok, res} <- Confex.fetch_env(:job_offers, :result_map),
         {:ok, continents} <- Confex.fetch_env(:job_offers, :continents),
         {:ok, professions} <- Professions.set_professions(professions_path),
         groupped <- set_jobs_assoc_professions(path, res, professions, continents) do
      {:ok, groupped}
    else
      e ->
        Logger.error("Error through data formation with reason: #{inspect(e)}")
        {:error, :grouping}
    end
  end

  @doc """
  Getting groupped jobs by continents
  """
  @spec get_groupped_jobs_by_continents() :: {:ok, map()} | {:error, atom()}
  def get_groupped_jobs_by_continents() do
    with {:ok, continents} <- Confex.fetch_env(:job_offers, :continents),
         {:ok, groupped} <- set_grouped_jobs() do
      {:ok, count_jobs_per_continent(groupped, continents)}
    else
      e ->
        Logger.error("Getting jobs by continent error with reason: #{inspect(e)}")
        {:error, :groupping_by_continents}
    end
  end

  @doc """
  Getting nearest jobs
  """
  @spec find_nearest_jobs(map(), integer(), tuple()) :: {:ok, list()} | {:error, :nearest_jobs}
  def find_nearest_jobs(map, radius, {lat, lon} = point_b) do
    with {:ok, continents} <- Confex.fetch_env(:job_offers, :continents),
         {continent, _} <- Continents.find_continent(continents, lat, lon) do
      res =
        Enum.reduce(map[continent], [], fn x, acc ->
          point_a =
            {String.to_float(x["office_latitude"]), String.to_float(x["office_longitude"])}

          distance = calculate_distance(point_a, point_b)
          build_nearest_jobs_list(x, acc, distance, radius)
        end)

      {:ok, res}
    else
      e ->
        Logger.error("Getting neareset jobs error with reason: #{inspect(e)}")
        {:error, :nearest_jobs}
    end
  end

  defp count_jobs_per_continent(map, continents) do
    Enum.reduce(continents, %{}, fn x, acc ->
      {continent, _} = x

      res =
        Enum.reduce(map[continent], %{}, fn x, acc ->
          %{"category_name" => type} = x
          Map.put(acc, type, update_count(acc, type) + 1)
        end)

      res = Map.put(res, "TOTAL", calculate_total(res))
      Map.put(acc, continent, res)
    end)
  end

  # HELPERS

  defp set_jobs_assoc_professions(jobs_path, res_map, professions, continents) do
    try do
      Path.join(@priv_dir, jobs_path)
      |> File.stream!()
      |> CSV.decode!([{:headers, true}])
      |> Enum.reduce(res_map, fn x, acc ->
        group_by_continent(x, acc, professions, continents)
      end)
    rescue
      e ->
        Logger.error(
          "Error through setting jobs assoc with professions grouping by continents with reason: #{
            inspect(e)
          }"
        )
    end
  end

  defp calculate_distance(a, b) do
    {lat_a, lon_a} = a
    {lat_b, lon_b} = b

    d =
      (ElixirMath.sin(lat_a) * ElixirMath.sin(lat_b) +
         ElixirMath.cos(lat_a) * ElixirMath.cos(lat_b) * ElixirMath.cos(lon_a - lon_b))
      |> ElixirMath.acos()

    r = Confex.get_env(:job_offers, :earth_radius)
    d * r
  end

  defp group_by_continent(row, acc, professions, continents) do
    try do
      %{
        "profession_id" => id,
        "office_latitude" => latitude,
        "office_longitude" => longtitude
      } = row

      lat = String.to_float(latitude)
      lon = String.to_float(longtitude)

      case Continents.find_continent(continents, lat, lon) do
        nil ->
          x = get_from_map(row, professions, id)
          Map.put(acc, "unknown", [x | acc["unknown"]])

        {continent, _} ->
          x = get_from_map(row, professions, id)
          Map.put(acc, continent, [x | acc[continent]])
      end
    rescue
      ArgumentError ->
        acc
    end
  end

  defp calculate_total(map) do
    Enum.reduce(map, 0, fn {_k, v}, acc ->
      acc = acc + v
      acc
    end)
  end

  defp update_count(map, type) do
    case map[type] do
      nil -> 0
      val -> val
    end
  end

  defp get_from_map(x, database, id) do
    case database[id] do
      nil ->
        x |> Map.put("category_name", "unknown")

      %{"name" => name, "category_name" => category_name} ->
        x
        |> Map.put("name", name)
        |> Map.put("category_name", category_name)
    end
  end

  defp build_nearest_jobs_list(element, acc, distance, radius) when distance <= radius do
    [Map.put(element, "distance", Float.floor(distance, 3)) | acc]
  end

  defp build_nearest_jobs_list(_element, acc, _distance, _radius), do: acc
end
