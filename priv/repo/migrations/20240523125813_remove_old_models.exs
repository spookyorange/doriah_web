defmodule Doriah.Repo.Migrations.RemoveOldModels do
  use Ecto.Migration

  def change do
    drop table("script_variables")
    drop table("script_lines")
  end
end
