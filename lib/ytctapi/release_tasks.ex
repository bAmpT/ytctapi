defmodule Elixir.Release.Tasks do
  def migrate do
	{:ok, _} = Application.ensure_all_started(:ytctapi)

	path = Application.app_dir(:ytctapi, "priv/repo/migrations")

	Ecto.Migrator.run(Ytctapi.Repo, path, :up, all: true)
  end
end