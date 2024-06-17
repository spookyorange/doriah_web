defmodule Doriah.Repo.Migrations.AddDefaultLoadoutToScripts do
  use Ecto.Migration

  def change do
    alter table(:scripts) do
      add :default_loadout_codename, :string, default: nil
    end
  end
end
