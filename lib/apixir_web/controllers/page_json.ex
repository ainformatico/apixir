defmodule ApixirWeb.PageJSON do
  use ApixirWeb, :controller

  def index(%{message: _message}) do
    %{data: [generate_profile()]}
  end

  def show(%{id: _message}) do
    %{data: generate_profile()}
  end

  defp generate_profile do
    %{
      id: 1,
      type: "profile",
      attributes: %{
        email: Faker.Internet.email(),
        phone_number: Faker.Phone.EnGb.number(),
        first_name: Faker.Person.first_name(),
        last_name: Faker.Person.last_name(),
        created_at: Faker.DateTime.between(~N[2016-12-20 00:00:00], ~N[2016-12-25 00:00:00]),
        updated_at: Faker.DateTime.between(~N[2016-12-20 00:00:00], ~N[2016-12-25 00:00:00]),
        properties: %{
          age: Faker.Pizza.pizza()
        }
      }
    }
  end
end
