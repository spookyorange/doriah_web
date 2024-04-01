defmodule Doriah.Repo.Migrations.CreateScripts do
  use Ecto.Migration

  def change do
    create table(:scripts) do
      add :title, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
