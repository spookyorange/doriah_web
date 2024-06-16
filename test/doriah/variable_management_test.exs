defmodule Doriah.VariableManagementTest do
  use Doriah.DataCase

  alias Doriah.VariableManagement

  describe "loadouts" do
    alias Doriah.VariableManagement.Loadout

    import Doriah.VariableManagementFixtures

    @invalid_attrs %{title: nil, variables: nil}

    test "list_loadouts/0 returns all loadouts" do
      loadout = loadout_fixture()
      assert VariableManagement.list_loadouts() == [loadout]
    end

    test "get_loadout!/1 returns the loadout with given id" do
      loadout = loadout_fixture()
      assert VariableManagement.get_loadout!(loadout.id) == loadout
    end

    test "create_loadout/1 with valid data creates a loadout" do
      valid_attrs = %{title: "some title", variables: %{}}

      assert {:ok, %Loadout{} = loadout} = VariableManagement.create_loadout(valid_attrs)
      assert loadout.title == "some title"
      assert loadout.variables == %{}
    end

    test "create_loadout/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VariableManagement.create_loadout(@invalid_attrs)
    end

    test "update_loadout/2 with valid data updates the loadout" do
      loadout = loadout_fixture()
      update_attrs = %{title: "some updated title", variables: %{}}

      assert {:ok, %Loadout{} = loadout} =
               VariableManagement.update_loadout(loadout, update_attrs)

      assert loadout.title == "some updated title"
      assert loadout.variables == %{}
    end

    test "update_loadout/2 with invalid data returns error changeset" do
      loadout = loadout_fixture()

      assert {:error, %Ecto.Changeset{}} =
               VariableManagement.update_loadout(loadout, @invalid_attrs)

      assert loadout == VariableManagement.get_loadout!(loadout.id)
    end

    test "delete_loadout/1 deletes the loadout" do
      loadout = loadout_fixture()
      assert {:ok, %Loadout{}} = VariableManagement.delete_loadout(loadout)
      assert_raise Ecto.NoResultsError, fn -> VariableManagement.get_loadout!(loadout.id) end
    end

    test "change_loadout/1 returns a loadout changeset" do
      loadout = loadout_fixture()
      assert %Ecto.Changeset{} = VariableManagement.change_loadout(loadout)
    end
  end
end
