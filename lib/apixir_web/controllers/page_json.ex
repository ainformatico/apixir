defmodule ApixirWeb.PageJSON do
  use ApixirWeb, :controller

  def index(%{message: message}) do
    %{message: message}
  end
end
