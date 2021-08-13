defmodule JobOffersServiceWeb.PageController do
  use JobOffersServiceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
