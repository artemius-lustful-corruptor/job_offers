defmodule JobOffersService.OffersSrv do
  use GenServer

  alias JobOffers.Jobs

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def find_nearest_jobs(point, radius) do
    GenServer.call(__MODULE__, {:nearest_jobs, point, radius})
  end

  def init(_state) do
    # TODO adding more concurrency
    Jobs.group()
  end

  def handle_call({:nearest_jobs, point, radius}, _from, state) do
    jobs =
      case Jobs.get_nearest(state, radius, point) do
        {:ok, res} -> res
        {:error, _} -> []
      end

    {:reply, jobs, state}
  end
end
