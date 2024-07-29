defmodule Apixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ApixirWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:apixir, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Apixir.PubSub},
      # Start a worker by calling: Apixir.Worker.start_link(arg)
      # {Apixir.Worker, arg},
      # Start to serve requests, typically the last entry
      ApixirWeb.Endpoint,
      {PlugAttack.Storage.Ets,
       name: Apixir.Plugs.PlugAttack.Storage,
       clean_period: Application.get_env(:apixir, :rate_limit_window)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Apixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ApixirWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
