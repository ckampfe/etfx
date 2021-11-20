defmodule Etfx.MixProject do
  use Mix.Project

  def project do
    [
      app: :etfx,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod || Mix.env() == :bench,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0", only: [:dev, :bench]},
      {:jason, "~> 1.2", only: [:bench]},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
    ]
  end
end
