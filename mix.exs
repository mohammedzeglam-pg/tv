defmodule Algora.MixProject do
  use Mix.Project

  def project do
    [
      app: :algora,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Algora.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bumblebee, "~> 0.5.3"},
      {:castore, "~> 0.1.13"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:dns_cluster, "~> 0.1.1"},
      {:ecto_network, "~> 1.3.0"},
      {:ecto_sql, "~> 3.6"},
      {:elixir_make, "~> 0.7.0", runtime: false},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:ex_m3u8, "~> 0.9.0"},
      {:ex_marcel, "~> 0.1.0"},
      {:exla, ">= 0.0.0"},
      {:ffmpex, "~> 0.10.0"},
      {:finch, "~> 0.18"},
      {:flame, "~> 0.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:fly_postgres, "~> 0.3.0"},
      {:gettext, "~> 0.18"},
      {:heroicons, "~> 0.5.0"},
      {:hnswlib, "~> 0.1.0"},
      {:icalendar, "~> 1.1.0"},
      {:image, "~> 0.37"},
      {:jason, "~> 1.2"},
      {:libcluster, "~> 3.3.1"},
      {:membrane_core, "~> 1.0"},
      {:membrane_h26x_plugin, "~> 0.10.2"},
      {:membrane_h264_ffmpeg_plugin, "~> 0.32.3"},
      {:membrane_h265_ffmpeg_plugin, "~> 0.4.1"},
      {:membrane_http_adaptive_stream_plugin, "~> 0.18.5"},
      {:membrane_rtmp_plugin, "~> 0.27.3"},
      {:membrane_tee_plugin, "~> 0.12.0"},
      {:membrane_file_plugin, "~> 0.17.2"},
      {:membrane_mp4_plugin, "~> 0.35.2"},
      {:membrane_funnel_plugin, "~> 0.9.1"},
      {:membrane_framerate_converter_plugin, "~> 0.8.2"},
      {:membrane_ffmpeg_swscale_plugin, "~> 0.15.1"},
      {:membrane_raw_video_parser_plugin, "~> 0.12.1"},
      {:membrane_abr_transcoder_plugin, "~> 0.1.1"},
      {:membrane_aac_plugin, "~> 0.19.0", override: true},
      {:mint, "~> 1.0"},
      {:oban, "~> 2.16"},
      {:open_api_spex, "~> 3.16"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_html, "~> 4.0", override: true},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.2"},
      {:phoenix, "~> 1.7.11"},
      {:plug_cowboy, "~> 2.5"},
      {:ratio, "~> 4.0.1", override: true},
      {:replicate, "~> 1.2.0"},
      {:reverse_proxy_plug, "~> 3.0"},
      {:slugify, "~> 1.3"},
      {:swoosh, "~> 1.3"},
      {:syn, "~> 3.3"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:thumbnex, "~> 0.5.0"},
      {:timex, "~> 3.0"},
      {:tzdata, "~> 1.1.2"},
      {:websockex, "~> 0.4.3"},
      # ex_aws
      {:ex_aws_s3, "~> 2.3"},
      {:ex_doc, "~> 0.29.0"},
      {:hackney, ">= 1.20.1"},
      {:sweet_xml, ">= 0.0.0", optional: true},
      # ueberauth
      {:ueberauth, "~> 0.10"},
      {:ueberauth_google, "~> 0.10"},
      {:oauth2, "~> 2.0", override: true},
      {:google_api_you_tube, "~> 0.49"}
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
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind tv", "esbuild tv"],
      "assets.deploy": [
        "tailwind tv --minify",
        "esbuild tv --minify",
        "phx.digest"
      ]
    ]
  end
end
