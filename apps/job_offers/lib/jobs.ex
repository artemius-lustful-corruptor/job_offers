defmodule JobOffers.Jobs do
  @moduledoc """
  Functions to operate with jobs
  """

  alias JobOffers.Continents
  alias JobOffers.Professions
  require Logger
  @priv_dir :code.priv_dir(:job_offers)

  @doc """
  Getting groupped jobs by continents
  """
  @spec distribute_by_continent() :: {:ok, map()} | {:error, atom()}
  def distribute_by_continent do
    with {:ok, continents} <- Confex.fetch_env(:job_offers, :continents),
         {:ok, groupped} <- group() do
      {:ok, count(groupped, continents)}
    else
      e ->
        Logger.error("Getting jobs by continent error with reason: #{inspect(e)}")
        {:error, :groupping_by_continents}
    end
  end

  @doc """
  Getting nearest jobs
  """
  @spec get_nearest(map(), integer(), tuple()) :: {:ok, list()} | {:error, :nearest_jobs}
  def get_nearest(map, radius, {lat, lon} = point_b) do
    with {:ok, continents} <- Confex.fetch_env(:job_offers, :continents),
         {continent, _} <- Continents.find(continents, lat, lon) do
      res =
        Enum.reduce(map[continent], [], fn x, acc ->
          point_a = {
            String.to_float(x["office_latitude"]),
            String.to_float(x["office_longitude"])
          }

          distance = Continents.distance(point_a, point_b)
          build_nearest_list(x, acc, distance, radius)
        end)

      {:ok, res}
    else
      e ->
        Logger.error("Getting neareset jobs error with reason: #{inspect(e)}")
        {:error, :nearest_jobs}
    end
  end

  @doc """
  Getting grouped jobs that associate with professions
  """
  @spec group() :: {:ok, map()} | {:error, :grouping}
  def group do
    with {:ok, professions_path} <- Confex.fetch_env(:job_offers, :professions_csv),
         {:ok, jobs} <- Confex.fetch_env(:job_offers, :jobs_csv),
         {:ok, res} <- Confex.fetch_env(:job_offers, :result_map),
         {:ok, continents} <- Confex.fetch_env(:job_offers, :continents),
         {:ok, professions} <- Professions.set_professions(professions_path),
         groupped <- assoc_professions(jobs, res, professions, continents) do
      {:ok, groupped}
    else
      e ->
        Logger.error("Error through data formation with reason: #{inspect(e)}")
        {:error, :grouping}
    end
  end

  # HELPERS

  defp total(map) do
    Enum.reduce(map, 0, fn {_k, v}, acc ->
      acc + v
    end)
  end

  defp count(map, continents) do
    Enum.reduce(continents, %{}, fn x, acc ->
      {continent, _} = x

      res =
        Enum.reduce(map[continent], %{}, fn x, acc ->
          %{"category_name" => type} = x
          counter = Map.get(acc, type, 0) + 1
          Map.put(acc, type, counter)
        end)

      res = Map.put(res, "TOTAL", total(res))
      Map.put(acc, continent, res)
    end)
  end

  defp assoc_professions(jobs_path, res_map, professions, continents) do
    try do
      Path.join(@priv_dir, jobs_path)
      |> File.stream!()
      |> CSV.decode!([{:headers, true}])
      |> Enum.reduce(res_map, fn job, acc ->
        Continents.group(job, acc, professions, continents)
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

  defp build_nearest_list(element, acc, distance, radius) when distance <= radius do
    [Map.put(element, "distance", Float.floor(distance, 3)) | acc]
  end

  defp build_nearest_list(_element, acc, _distance, _radius), do: acc
end
