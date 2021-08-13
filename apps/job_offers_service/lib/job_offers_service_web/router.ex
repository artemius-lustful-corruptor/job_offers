defmodule JobOffersServiceWeb.Router do
  use JobOffersServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/jobs/offers", JobOffersServiceWeb do
    pipe_through :api

    get "/filter", OffersController, :show
  end
end
