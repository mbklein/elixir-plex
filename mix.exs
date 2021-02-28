defmodule Plex.MixProject do
  use Mix.Project

  def project do
    [
      app: :plex,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
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
      {:codepagex, "~> 0.1.6"},
      {:httpoison, "~> 1.8.0"},
      {:inflex, "~> 2.1.0"},
      {:jason, "~> 1.2.2"},
      {:sweet_xml, "~> 0.6.6"}
    ]
  end
end
