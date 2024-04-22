defmodule PersonalYtDlp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PersonalYtDlpWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:personal_yt_dlp, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PersonalYtDlp.PubSub},
      PersonalYtDlp.Downloaders.DownloadServer,
      # Start a worker by calling: PersonalYtDlp.Worker.start_link(arg)
      # {PersonalYtDlp.Worker, arg},
      # Start to serve requests, typically the last entry
      PersonalYtDlpWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PersonalYtDlp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PersonalYtDlpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
