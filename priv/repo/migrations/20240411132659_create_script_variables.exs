defmodule Doriah.Repo.Migrations.CreateScriptVariables do
  use Ecto.Migration

  def change do
    create table(:script_variables) do
      add :key, :string
      add :default_value, :string
      add :purpose, :string
      add :script_id, references(:scripts, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    alter table(:script_lines) do
      modify :script_id, references(:scripts, on_delete: :delete_all),
        from: references(:scripts, on_delete: :nothing)
    end

    create index(:script_variables, [:script_id])
  end
end
