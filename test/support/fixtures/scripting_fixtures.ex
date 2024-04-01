defmodule Doriah.ScriptingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Doriah.Scripting` context.
  """

  @doc """
  Generate a script.
  """
  def script_fixture(attrs \\ %{}) do
    {:ok, script} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title"
      })
      |> Doriah.Scripting.create_script()

    script
  end
end
