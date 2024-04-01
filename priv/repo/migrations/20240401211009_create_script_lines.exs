defmodule Doriah.Repo.Migrations.CreateScriptLines do
  use Ecto.Migration

  def change do
    create table(:script_lines) do
      add :line_itself, :string
      add :order, :integer
      add :script_id, references(:scripts, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:script_lines, [:script_id])
  end
end
