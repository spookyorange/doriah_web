defmodule Doriah.Scripting.Script do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scripts" do
    field :description, :string
    field :title, :string

    has_many :script_lines, Doriah.Scripting.ScriptLine
    has_many :script_variables, Doriah.Scripting.ScriptVariable

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(script, attrs) do
    script
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end
end
