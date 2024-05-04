defmodule Doriah.Repo.Migrations.AddWholeScriptLinesToScript do
  use Ecto.Migration

  def change do
    alter table(:scripts) do
      add :whole_script, :text
    end
  end
end
