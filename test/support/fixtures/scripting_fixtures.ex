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

  @doc """
  Generate a script_line.
  """
  def script_line_fixture(attrs \\ %{}) do
    {:ok, script_line} =
      attrs
      |> Enum.into(%{
        line_itself: "some line_itself",
        order: 42
      })
      |> Doriah.Scripting.create_script_line()

    script_line
  end

  @doc """
  Generate a script_variable.
  """
  def script_variable_fixture(attrs \\ %{}) do
    {:ok, script_variable} =
      attrs
      |> Enum.into(%{
        default_value: "some default_value",
        key: "some key",
        purpose: "some purpose"
      })
      |> Doriah.Scripting.create_script_variable()

    script_variable
  end
end
