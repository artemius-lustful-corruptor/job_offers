defmodule JobOffers.Professions do
  @moduledoc """
  Functions to operate with professions
  """

  require Logger
  @priv_dir :code.priv_dir(:job_offers)

  @doc """
  Getting professions
  """
  def set_professions(professions_path) do
    try do
      res =
        Path.join(@priv_dir, professions_path) |> IO.inspect()
        |> File.stream!()
        |> CSV.decode!([{:headers, true}])
        |> Enum.reduce(%{}, fn x, acc ->
          %{"id" => id, "name" => name, "category_name" => category_name} = x
          Map.put(acc, id, %{"name" => name, "category_name" => category_name})
        end)

      {:ok, res}
    rescue
      e ->
        Logger.error("Error through setting professions with reason: #{inspect(e)}")
        {:error, :professions}
    end
  end
end
