defmodule Doriah.Scripting.ScriptVariable do
  use Ecto.Schema
  import Ecto.Changeset

  schema "script_variables" do
    field :default_value, :string
    field :key, :string
    field :purpose, :string

    belongs_to :script, Doriah.Scripting.Script

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(script_variable, attrs) do
    script_variable
    |> cast(attrs, [:key, :default_value, :purpose])
    |> validate_required([:key, :default_value, :purpose])
    |> unique_constraint([:script_id, :key])
  end
end
