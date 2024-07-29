defmodule ApixirWeb.Router do
  use ApixirWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ApixirWeb do
    resources "/", PageController, only: [:index]
  end

  scope "/api", ApixirWeb do
    pipe_through :api
  end
end
