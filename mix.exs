defmodule MixProtobuffs.MixProject do
  use Mix.Project

  def project do
    [
      app: :mix_protobuffs,
      version: "0.1.0",
      elixir: "~> 1.9",
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:protobuffs, git: "https://github.com/basho/erlang_protobuffs", tag: "0.9.1"},
      {:meck, "~> 0.8.13", override: true, runtime: false}
    ]
  end
end
