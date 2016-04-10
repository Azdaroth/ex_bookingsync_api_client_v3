defmodule BookingsyncApiClientV3.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bookingsync_api_client_v3,
      version: "0.0.1",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      elixirc_paths: elixirc_paths(Mix.env),
      preferred_cli_env: [
        vcr: :test, "vcr.delete": :test, "vcr.check": :test, "vcr.show": :test
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpotion]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpotion, "~> 2.2.0"},
      {:json, "~> 0.3.0"},
      {:exvcr, "~> 0.7", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/test_helpers"]
  defp elixirc_paths(_), do: ["lib"]
end


