defmodule Doriah.VariableManagementFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Doriah.VariableManagement` context.
  """

  @doc """
  Generate a unique loadout title.
  """
  def unique_loadout_title, do: "some title#{System.unique_integer([:positive])}"

  @doc """
  Generate a loadout.
  """
  def loadout_fixture(attrs \\ %{}) do
    {:ok, loadout} =
      attrs
      |> Enum.into(%{
        title: unique_loadout_title(),
        variables: %{}
      })
      |> Doriah.VariableManagement.create_loadout()

    loadout
  end
end
