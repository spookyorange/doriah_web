defmodule Doriah.Scripting.ScriptLine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "script_lines" do
    field :line_itself, :string
    field :order, :integer

    belongs_to :script, Doriah.Scripting.Script

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(script_line, attrs) do
    script_line
    |> cast(attrs, [:line_itself, :order])
    |> validate_required([:line_itself, :order])
  end
end
