defmodule Doriah.Repo.Migrations.AddWholeScriptLinesToScript do
  use Ecto.Migration

  def change do
    alter table(:scripts) do
      add :whole_script, :text, default: ""
    end
  end
end
