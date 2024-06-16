defmodule Doriah.Repo.Migrations.AddLoadoutRequiredToScripts do
  use Ecto.Migration

  def change do
    alter table(:scripts) do
      add :loadout_required, :boolean, default: false
    end
  end
end
