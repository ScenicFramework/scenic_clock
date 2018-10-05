defmodule Scenic.Clock.MixProject do
  use Mix.Project

  @version "0.8.1"
  @github "https://github.com/boydm/scenic_clock"

  def project do
    [
      app: :scenic_clock,
      version: @version,
      elixir: "~> 1.7",
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
      {:scenic, "~> 0.8"},
      {:timex, "~> 3.4"},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs]}
    ]
  end

  defp description() do
    """
    Scenic.Clock - Analog and Digital clock components for Scenic
    """
  end
end
