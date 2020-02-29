defmodule Example2.Application do
  @moduledoc false
  import Telemetry.Metrics

  use Application

  def start(_type, _args) do
    attach_manual_metrics!()

    children = [
      Example2.Repo,
      Example2Web.Endpoint,
      {TelemetryMetricsStatsd,
       port: 8126,
       metrics: [
         counter("example.foo.count"),
         sum("example.foo.data_val_1"),
         sum("example.foo.data_val_2", tags: [:metadata_key])
       ]}
    ]

    opts = [strategy: :one_for_one, name: Example2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Example2Web.Endpoint.config_change(changed, removed)
    :ok
  end

  defp attach_manual_metrics! do
    alias Example2.Metrics.ExampleMetricsHandler

    :ok =
      :telemetry.attach(
        "simple-event",
        [:example, :simple],
        &ExampleMetricsHandler.handle_simple/4,
        %{my_config: :baz}
      )
  end
end
