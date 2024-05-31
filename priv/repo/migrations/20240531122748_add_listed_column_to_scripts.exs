defmodule Doriah.Repo.Migrations.AddListedColumnToScripts do
  use Ecto.Migration

  def change do
    alter table(:scripts) do
      add :listed, :boolean, default: false
    end
  end
end
