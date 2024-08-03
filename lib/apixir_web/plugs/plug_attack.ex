defmodule Apixir.Plugs.PlugAttack do
  use PlugAttack
  import Plug.Conn

  @rate_limit_window Application.compile_env!(:apixir, :rate_limit_window)
  @rate_limit_requests Application.compile_env!(:apixir, :rate_limit_requests)

  rule "allow local", conn do
    allow(conn.remote_ip == {127, 0, 0, 1})
  end

  rule "throttle by ip", conn do
    throttle(conn.remote_ip,
      period: @rate_limit_window,
      limit: @rate_limit_requests,
      storage: {PlugAttack.Storage.Ets, Apixir.Plugs.PlugAttack.Storage}
    )
  end

  def allow_action(conn, {:throttle, data}, opts) do
    conn
    |> add_throttling_headers(data)
    |> allow_action(true, opts)
  end

  def allow_action(conn, _data, _opts) do
    conn
  end

  def block_action(conn, {:throttle, data}, opts) do
    conn
    |> add_throttling_headers(data)
    |> block_action(false, opts)
  end

  def block_action(conn, _data, _opts) do
    conn
    # We want to intentionally return 403 and not 429
    |> send_resp(:forbidden, "Forbidden\n")
    # It's important to halt connection once we send a response early
    |> halt
  end

  defp add_throttling_headers(conn, data) do
    conn
    |> put_resp_header("x-ratelimit-limit", to_string(data[:limit]))
    |> put_resp_header("x-ratelimit-remaining", to_string(data[:remaining]))
    |> put_resp_header("x-ratelimit-reset", to_string(seconds_until_reset(data)))
  end

  defp seconds_until_reset(data) do
    # The expires_at value is a unix time in milliseconds
    ((data[:expires_at] - System.system_time(:millisecond)) / 1_000) |> ceil()
  end
end
