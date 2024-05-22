defmodule Doriah.VariableManagement.Loadout do
  use Ecto.Schema
  import Ecto.Changeset

  schema "loadouts" do
    field :title, :string
    field :variables, {:array, :map}

    belongs_to :script, Doriah.Scripting.Script

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(loadout, attrs) do
    loadout
    |> cast(attrs, [:title, :variables])
    |> validate_required([:title])
    |> unique_constraint([:script_id, :title])
  end
end
