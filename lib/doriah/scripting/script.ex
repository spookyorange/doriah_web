defmodule Doriah.Scripting.Script do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scripts" do
    field :description, :string
    field :title, :string
    field :whole_script, :string, default: ""
    field :listed, :boolean
    field :loadout_required, :boolean

    field :status, Ecto.Enum,
      values: [
        :under_development,
        :untested_usable,
        :stable,
        :deprecated,
        :discounted,
        :just_imported
      ],
      default: :under_development

    field :deprecated_suggestion_link, :string

    has_many :loadouts, Doriah.VariableManagement.Loadout

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(script, attrs) do
    script
    |> cast(attrs, [
      :title,
      :description,
      :whole_script,
      :status,
      :deprecated_suggestion_link,
      :listed,
      :loadout_required
    ])
    |> validate_required([:title, :description])
  end
end
