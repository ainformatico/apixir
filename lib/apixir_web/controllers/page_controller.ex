defmodule ApixirWeb.PageController do
  use ApixirWeb, :controller

  def index(conn, _params) do
    render(conn, "index.json", message: "Welcome to Phoenix!")
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.json", id: id)
  end
end
