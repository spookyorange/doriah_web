defmodule Doriah.Repo.Migrations.AddUniqueToKeyInScriptVariables do
  use Ecto.Migration

  def change do
    unique_index(:script_variables, [:key])
  end
end
