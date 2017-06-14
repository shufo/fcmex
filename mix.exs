defmodule Fcmex.Mixfile do
  use Mix.Project

  def project do
    [app: :fcmex,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test,
       "coveralls.html": :test,
       vcr: :test,
       "vcr.delete": :test,
       "vcr.check": :test,
       "vcr.show": :test
     ],
     deps: deps()]
  end

  # Configuration for the OTP application
  def application do
    [extra_applications: [:logger, :retry]]
  end

  defp deps do
    [
      {:httpoison, ">= 0.0.0"},
      {:poison, ">= 0.0.0"},
      {:flow, "~> 0.12"},
      {:retry, "~> 0.7"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:exvcr, ">= 0.0.0", only: [:test, :dev]},
      {:excoveralls, ">= 0.0.0", only: :test},
    ]
  end
end
