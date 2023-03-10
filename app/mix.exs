defmodule TicketsAlert.MixProject do
  use Mix.Project

  def project do
    [
      app: :tickets_alert,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:ex_unit],
        plt_add_deps: :transitive,
        ignore_warnings: ".dialyzerignore"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      extra_applications: [
        :logger,
        :runtime_tools
      ],
      mod: {TicketsAlert.Application, %{env: Mix.env()}}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:absinthe, "~> 1.6.0"},
      {:absinthe_plug, "~> 1.5"},
      {:amqpx, "~> 5.7"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:cors_plug, "~> 3.0"},
      {:dataloader, "~> 1.0.0"},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.6"},
      {:env, "~> 0.2.0"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:floki, ">= 0.30.0", only: :test},
      {:gettext, "~> 0.18"},
      {:httpoison, "~> 2.0"},
      {:noether, "~> 0.2.1"},
      {:jason, "~> 1.2"},
      {:joken, "~> 2.5"},
      {:phoenix, "~> 1.6.15"},
      {:phoenix_ecto, "~> 4.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:plug_cowboy, "~> 2.5"},
      {:prima_ex_logger, "~> 0.3.0"},
      {:redix, "~> 1.1"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:tz, "~> 0.24.0"},
      {:timex, "~> 3.7"},
      {:uuid, "~> 1.1", app: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      check: [
        "check.compile",
        "check.format",
        "check.deps.unlock",
        "check.credo",
        "check.dialyzer"
      ],
      "format.all": [
        "format mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\" \"priv/**/*.{ex,exs}\" \"config/**/*.{ex,exs}\""
      ],
      "ecto.clear": ["ecto.drop", "ecto.create", "ecto.migrate"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      s: ["local.hex --force", "ecto.clear", "phx.server"],
      test: ["local.hex --force", "ecto.clear", "run priv/repo/seeds.exs", "test"],
      "test.coverage": ["test --cover --export-coverage default", "test.coverage"],
      c: ["check"],
      "check.compile": "compile --all-warnings --ignore-module-conflict --warnings-as-errors --debug-info",
      "check.format": "format --check-formatted mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\" \"priv/**/*.{ex,exs}\" \"config/**/*.{ex,exs}\"",
      "check.deps.unlock": "deps.unlock --check-unused",
      "check.credo": "credo -a --strict",
      "check.dialyzer": "dialyzer --format dialyxir"
    ]
  end
end
