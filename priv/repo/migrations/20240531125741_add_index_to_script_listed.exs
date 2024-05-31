defmodule Doriah.Repo.Migrations.AddIndexToScriptListed do
  use Ecto.Migration

  def change do
    create index(:scripts, [:listed])
  end
end
