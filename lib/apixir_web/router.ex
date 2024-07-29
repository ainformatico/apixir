defmodule ApixirWeb.Router do
  use ApixirWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApixirWeb do
    pipe_through :api

    resources "/", PageController, only: [:index, :show]
  end
end
