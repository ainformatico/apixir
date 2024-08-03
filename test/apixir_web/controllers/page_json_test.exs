defmodule ApixirWeb.PageJSONTest do
  use ApixirWeb.ConnCase, async: true

  @items_per_page Application.compile_env(:apixir, :default_limit_per_page)
  @max_limit_per_page Application.compile_env(:apixir, :max_limit_per_page)

  describe "index" do
    test "lists all profiles", %{conn: conn} do
      conn = get(conn, ~p"/api/profiles")

      response = json_response(conn, 200)

      data = response["data"]
      links = response["links"]

      assert data |> length() == @items_per_page

      assert data |> Enum.map(&Map.get(&1, "id")) ==
               Enum.to_list(1..@items_per_page)

      assert links == %{
               "self" => "/api/profiles?cursor=MQ==",
               "next" => "/api/profiles?cursor=Mg==",
               "prev" => nil
             }
    end

    test "lists 2 profiles", %{conn: conn} do
      conn = get(conn, ~p"/api/profiles", limit: 2)

      response = json_response(conn, 200)

      data = response["data"]
      links = response["links"]

      assert data |> length() == 2

      assert data |> Enum.map(&Map.get(&1, "id")) == [1, 2]

      assert links == %{
               "self" => "/api/profiles?cursor=MQ==",
               "next" => "/api/profiles?cursor=Mg==",
               "prev" => nil
             }
    end

    test "lists page 2", %{conn: conn} do
      conn = get(conn, ~p"/api/profiles", limit: 2, cursor: "Mg==")

      response = json_response(conn, 200)

      data = response["data"]
      links = response["links"]

      assert data |> length() == 2

      assert data |> Enum.map(&Map.get(&1, "id")) == [3, 4]

      assert links == %{
               "self" => "/api/profiles?cursor=Mg==",
               "next" => "/api/profiles?cursor=Mw==",
               "prev" => "/api/profiles?cursor=MQ=="
             }
    end

    test "lists last page", %{conn: conn} do
      conn = get(conn, ~p"/api/profiles", limit: @max_limit_per_page, cursor: "MjU=")

      response = json_response(conn, 200)

      data = response["data"]
      links = response["links"]

      assert data |> length() == @max_limit_per_page

      assert data |> List.last() |> Map.get("id") == Application.get_env(:apixir, :total_entries)

      assert links == %{
               "self" => "/api/profiles?cursor=MjU=",
               "next" => nil,
               "prev" => "/api/profiles?cursor=MjQ="
             }
    end

    for value <- [nil, "invalid"] do
      test "error when limit is #{value}", %{conn: conn} do
        conn = get(conn, ~p"/api/profiles", limit: unquote(value))

        assert json_response(conn, 400)["errors"] == %{
                 "detail" => "Parameter `limit` must be an integer"
               }
      end
    end

    for value <- [0, @max_limit_per_page + 1] do
      test "error when limit is out of bounds at: #{value}", %{conn: conn} do
        conn = get(conn, ~p"/api/profiles", limit: unquote(value))

        assert json_response(conn, 400)["errors"] == %{
                 "detail" => "Parameter `limit` must be between 1 and #{@max_limit_per_page}"
               }
      end
    end

    for value <- [0, "invalid", "invalid64" |> Base.encode64()] do
      test "error when cursor is invalid with: #{value}", %{conn: conn} do
        conn = get(conn, ~p"/api/profiles", cursor: unquote(value))

        assert json_response(conn, 400)["errors"] == %{
                 "detail" => "Parameter `cursor` is invalid"
               }
      end
    end

    test "error when cursor is out of bounds", %{conn: conn} do
      conn = get(conn, ~p"/api/profiles", cursor: "0" |> Base.encode64())

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Parameter `cursor` is out of range"
             }
    end

    test "error when cursor exceeds pagination", %{conn: conn} do
      conn = get(conn, ~p"/api/profiles", cursor: "10000" |> Base.encode64())

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Pagination limit exceeded"
             }
    end
  end

  describe "show" do
    test "has property `dog` for even numbers", %{conn: conn} do
      conn = get(conn, ~p"/api/profiles/2")

      data = json_response(conn, 200)["data"]

      assert data |> Map.get("id") == 2
      assert data |> Map.get("attributes") |> Map.get("properties") |> Map.has_key?("dog") == true
    end

    test "does not have property `dog` for odd numbers", %{conn: conn} do
      conn = get(conn, ~p"/api/profiles/3")

      data = json_response(conn, 200)["data"]

      assert data |> Map.get("id") == 3

      assert data |> Map.get("attributes") |> Map.get("properties") |> Map.has_key?("dog") ==
               false
    end

    test "show details of `cat` in profile 2000", %{conn: conn} do
      conn = get(conn, ~p"/api/profiles/2000")

      data = json_response(conn, 200)["data"]

      assert data |> Map.get("id") == 2000
      assert data |> Map.get("attributes") |> Map.get("properties") == %{"cat" => "Felix"}
    end

    for value <- [0, 10_000_001] do
      test "returns not found for: #{value}", %{conn: conn} do
        conn = get(conn, ~p"/api/profiles/#{unquote(value)}")

        assert json_response(conn, 404)["errors"] == %{
                 "detail" => "Not found"
               }
      end
    end

    test "returns error for non-integer id", %{conn: conn} do
      conn = get(conn, ~p"/api/profiles/invalid")

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Parameter `id` must be an integer"
             }
    end
  end
end
