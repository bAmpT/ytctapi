defmodule Ytctapi.Mixfile do
  use Mix.Project

  def project do
    [app: :ytctapi,
     version: "0.0.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Ytctapi, []},
     applications: [:phoenix, :phoenix_html, :phoenix_pubsub, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :gen_stage, :mongodb_ecto, :arc_ecto, :comeonin, :guardian, 
                    :briefly, :ecto_lazy_float, :httpoison, :httpotion, :con_cache, :exjieba]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
     {:phoenix, "~> 1.2"},
     {:phoenix_html, "~> 2.8"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0.1"},
     {:gen_stage, "~> 0.11"},
     {:mongodb_ecto, github: "michalmuskala/mongodb_ecto", branch: "ecto-2" },
     {:ecto, "~> 2.0.0", override: true},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:kerosene, "~> 0.7.0"},
     {:guardian, "~> 0.14"},
     {:comeonin, "~> 3.0"},
     {:arc, "~> 0.8.0"},
     {:arc_ecto, "~> 0.7.0"},
     {:exjieba, github: "falood/exjieba"},
     {:pinyin, github: "lidashuang/pinyin"},
     {:ecto_lazy_float, "~> 0.1.2"},
     {:briefly, "~> 0.3"},
     {:con_cache, "~> 0.12.0"},
     {:flow, "~> 0.11"},
     {:httpoison, "~> 0.11"},
     {:httpotion, "~> 3.0.2"},
     {:floki, "~> 0.17.0"},
     {:credo, "~> 0.8", only: [:dev, :test]},
     {:distillery, "~> 1.4"},
     {:mix_docker, "~> 0.4.0"}
     # {:boltun, "~> 1.0.2"},
     # {:chinese_translation, github: "tyrchen/chinese_translation"},
   ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
