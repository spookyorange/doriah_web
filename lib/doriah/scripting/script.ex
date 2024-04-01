defmodule Doriah.Scripting.Script do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scripts" do
    field :description, :string
    field :title, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(script, attrs) do
    script
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end
end
