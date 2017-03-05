defmodule JsonApiAssert.Mixfile do
  use Mix.Project

  def project do
    [app: :json_api_assert,
     version: "0.0.2",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     description: "assertions for JSON API payload",
     deps: deps(),
     docs: [
      main: "JsonApiAssert",
      logo: "jsonapi-assert.png"
     ]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  def package do
    [maintainers: ["Brian Cardarella"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/DockYard/json_api_assert"}]
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
    [{:ecto, "~> 1.1.8", only: :test},
     {:earmark, "~> 0.2.1", only: :dev},
     {:ex_doc, "~> 0.11.5", only: :dev}]
  end
end
