defmodule Scenic.Clock.MixProject do
  use Mix.Project

  @scenic_version "0.7.0"
  @github "https://github.com/boydm/scenic_clock"

  def project do
    [
      app: :scenic_clock,
      version: @scenic_version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "Scenic.Clock.Components"
        # source_ref: "v#{@version}",
        # source_url:≈ "https://github.com/boydm/scenic_clock",
        # homepage_url: "http://kry10.com",
      ],
      description: description(),
      package: [
        name: :scenic_math,
        contributors: ["Boyd Multerer"],
        maintainers: ["Boyd Multerer"],
        licenses: ["Apache 2"],
        links: %{github: @github}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> #{@scenic_version}"},

      {:timex, "~> 3.3"},

      {:ex_doc, ">= 0.0.0", only: [:dev, :docs]},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    """
    Scenic.Clock - Analog and Digital clock components for Scenic
    """
  end
end
