defmodule Doriah.ScriptingTest do
  use Doriah.DataCase

  alias Doriah.Scripting

  describe "scripts" do
    alias Doriah.Scripting.Script

    import Doriah.ScriptingFixtures

    @invalid_attrs %{description: nil, title: nil}

    test "list_scripts/0 returns all scripts" do
      script = script_fixture()
      assert Scripting.list_scripts() == [script]
    end

    test "get_script!/1 returns the script with given id" do
      script = script_fixture()
      assert Scripting.get_script!(script.id) == script
    end

    test "create_script/1 with valid data creates a script" do
      valid_attrs = %{description: "some description", title: "some title"}

      assert {:ok, %Script{} = script} = Scripting.create_script(valid_attrs)
      assert script.description == "some description"
      assert script.title == "some title"
    end

    test "create_script/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scripting.create_script(@invalid_attrs)
    end

    test "update_script/2 with valid data updates the script" do
      script = script_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title"}

      assert {:ok, %Script{} = script} = Scripting.update_script(script, update_attrs)
      assert script.description == "some updated description"
      assert script.title == "some updated title"
    end

    test "update_script/2 with invalid data returns error changeset" do
      script = script_fixture()
      assert {:error, %Ecto.Changeset{}} = Scripting.update_script(script, @invalid_attrs)
      assert script == Scripting.get_script!(script.id)
    end

    test "delete_script/1 deletes the script" do
      script = script_fixture()
      assert {:ok, %Script{}} = Scripting.delete_script(script)
      assert_raise Ecto.NoResultsError, fn -> Scripting.get_script!(script.id) end
    end

    test "change_script/1 returns a script changeset" do
      script = script_fixture()
      assert %Ecto.Changeset{} = Scripting.change_script(script)
    end
  end
end
