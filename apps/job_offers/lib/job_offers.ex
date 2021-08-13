defmodule JobOffers do
  @moduledoc """
  Client functions
  """

  alias JobOffers.Jobs
  alias JobOffers.Professions
  require Logger

  @doc """
  Getting offers
  """
  @spec getting_offers() :: {:ok, map()} | {:error, atom()}
  def getting_offers() do
    with {:ok, continents} = Confex.fetch_env(:jobs_offers, :continents),
         {:ok, groupped} <- Jobs.set_grouped_jobs() do
      {:ok, Jobs.count_jobs_per_continent(groupped, continents)}
    else
      e ->
        Logger.error("Error through data formation with reason: #{inspect(e)}")
        {:error, :offers}
    end
  end
end
