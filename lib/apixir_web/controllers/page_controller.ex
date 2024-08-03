defmodule ApixirWeb.PageController do
  use ApixirWeb, :controller

  @total_entries Application.compile_env(:apixir, :total_entries)
  @default_limit_per_page Application.compile_env(:apixir, :default_limit_per_page)
  @max_limit_per_page Application.compile_env(:apixir, :max_limit_per_page)

  def index(conn, params) do
    with {:ok, limit} <- extract_limit(params),
         {:ok, page} <- extract_page(params),
         {:ok} <- validate_pagination(limit, page) do
      render(conn, "index.json", limit: limit, page: page)
    else
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", reason: reason)
    end
  end

  def show(conn, %{"id" => number}) do
    with {:ok, id} <- validate_id(number) do
      render(conn, "show.json", id: id)
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: "Not found")

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", reason: reason)
    end
  end

  defp generate_first_cursor() do
    Base.encode64("1")
  end

  defp extract_limit(params) when is_map(params),
    do: extract_limit(Map.get(params, "limit", @default_limit_per_page))

  defp extract_limit(limit) when is_number(limit), do: validate_limit(limit)

  defp extract_limit(param) do
    case validate_number(param) do
      {:error, _} -> {:error, "Parameter `limit` must be an integer"}
      {:ok, value} -> validate_limit(value)
    end
  end

  defp extract_page(params) when is_map(params),
    do: extract_page(Map.get(params, "cursor", generate_first_cursor()))

  defp extract_page(cursor) do
    with {:ok, parsed_cursor} <- Base.decode64(cursor),
         {:ok, page} <- validate_number(parsed_cursor),
         {:ok} <- validate_range(page) do
      {:ok, page}
    else
      {:error, :range} -> {:error, "Parameter `cursor` is out of range"}
      _ -> {:error, "Parameter `cursor` is invalid"}
    end
  end

  defp validate_id(param) do
    with {:ok, id} <- validate_number(param),
         {:ok} <- validate_range(id) do
      {:ok, id}
    else
      {:error, :range} -> {:error, :not_found}
      _ -> {:error, "Parameter `id` must be an integer"}
    end
  end

  defp validate_limit(limit) when limit >= 1 and limit <= @max_limit_per_page, do: {:ok, limit}

  defp validate_limit(_limit),
    do: {:error, "Parameter `limit` must be between 1 and #{@max_limit_per_page}"}

  defp validate_range(number) when number in 1..@total_entries, do: {:ok}

  defp validate_range(_number), do: {:error, :range}

  defp validate_pagination(limit, cursor) when limit * cursor <= @total_entries, do: {:ok}

  defp validate_pagination(_limit, _cursor), do: {:error, "Pagination limit exceeded"}

  defp validate_number(number) do
    case Integer.parse(number) do
      :error -> {:error, "Invalid"}
      {value, _} -> {:ok, value}
    end
  end
end
