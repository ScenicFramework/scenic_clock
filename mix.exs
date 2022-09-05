defmodule Scenic.Clock.MixProject do
  use Mix.Project

  @version "0.11.0"
  @github "https://github.com/ScenicFramework/scenic_clock"

  def project do
    [
      app: :scenic_clock,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "Scenic.Clock.Components",
        source_ref: "v#{@version}",
        source_url: @github
        # homepage_url: "http://kry10.com",
      ],
      description: description(),
      package: [
        name: :scenic_clock,
        contributors: ["Boyd Multerer"],
        maintainers: ["Boyd Multerer"],
        licenses: ["Apache-2.0"],
        links: %{github: @github}
      ],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.11.0"},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs]},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false}
    ]
  end

  defp description() do
    """
    Scenic.Clock - Analog and Digital clock components for Scenic
    """
  end
end
