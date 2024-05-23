defmodule Doriah.Scripting.Script do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scripts" do
    field :description, :string
    field :title, :string
    field :whole_script, :string, default: ""

    has_many :loadouts, Doriah.VariableManagement.Loadout

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(script, attrs) do
    script
    |> cast(attrs, [:title, :description, :whole_script])
    |> validate_required([:title, :description])
  end
end
