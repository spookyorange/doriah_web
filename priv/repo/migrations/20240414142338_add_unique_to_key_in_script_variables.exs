defmodule Doriah.Repo.Migrations.AddUniqueToKeyInScriptVariables do
  use Ecto.Migration

  def change do
    create unique_index(:script_variables, [:script_id, :key])
  end
end
