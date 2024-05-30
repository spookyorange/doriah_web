defmodule Doriah.Repo.Migrations.StatusColumnsForScripts do
  use Ecto.Migration

  def change do
    alter table(:scripts) do
      add :status, :string, default: "under_development"
      add :deprecated_suggestion_link, :string
    end
  end
end
