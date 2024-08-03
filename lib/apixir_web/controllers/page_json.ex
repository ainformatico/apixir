defmodule ApixirWeb.PageJSON do
  use ApixirWeb, :controller

  @total_entries Application.compile_env(:apixir, :total_entries)

  def index(%{limit: limit, page: page}) do
    %{data: generate_profiles(limit, page), links: generate_links(page, limit)}
  end

  def show(%{id: id}) do
    %{data: generate_profile(id)}
  end

  def render("error.json", %{reason: reason}) do
    %{errors: %{detail: reason}}
  end

  defp generate_profiles(amount, current_page) do
    Enum.map(1..amount, fn id ->
      generate_profile((current_page - 1) * amount + id)
    end)
  end

  defp generate_profile(id) do
    %{
      id: id,
      type: "profile",
      attributes: %{
        email: Faker.Internet.email(),
        phone_number: Faker.Phone.EnGb.number(),
        first_name: Faker.Person.first_name(),
        last_name: Faker.Person.last_name(),
        created_at: Faker.DateTime.backward(365),
        updated_at: Faker.DateTime.forward(90),
        properties: generate_properties(id)
      }
    }
  end

  defp generate_properties(2000), do: %{cat: "Felix"}

  defp generate_properties(id) do
    properties = %{
      pizza: Faker.Pizza.pizza()
    }

    if rem(id, 2) == 0 do
      Map.put(properties, :dog, Faker.Dog.PtBr.breed())
    else
      properties
    end
  end

  defp generate_links(current_page, limit) do
    current_page_cursor = convert_to_cursor(current_page)
    total_pages = @total_entries / limit

    %{
      self: generate_link_with_cursor(current_page_cursor),
      next: generate_next_page_link(current_page, total_pages),
      prev: generate_prev_page_link(current_page)
    }
  end

  defp generate_next_page_link(current_page, total_pages) when current_page < total_pages,
    do: (current_page + 1) |> convert_to_cursor() |> generate_link_with_cursor()

  defp generate_next_page_link(_current_page, _total_pages), do: nil

  defp generate_prev_page_link(current_page) when current_page > 1,
    do: (current_page - 1) |> convert_to_cursor() |> generate_link_with_cursor()

  defp generate_prev_page_link(_current_page), do: nil

  defp generate_link_with_cursor(cursor) do
    "/api/profiles?cursor=#{cursor}"
  end

  defp convert_to_cursor(page) do
    to_string(page) |> Base.encode64()
  end
end
