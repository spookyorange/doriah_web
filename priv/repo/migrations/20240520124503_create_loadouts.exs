defmodule Doriah.Repo.Migrations.CreateLoadouts do
  use Ecto.Migration

  def change do
    create table(:loadouts) do
      add :title, :string
      add :variables, {:array, :map}
      add :script_id, references(:scripts, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:loadouts, [:script_id])
    create unique_index(:loadouts, [:title, :script_id])
  end
end
