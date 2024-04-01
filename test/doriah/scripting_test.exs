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

  describe "script_lines" do
    alias Doriah.Scripting.ScriptLine

    import Doriah.ScriptingFixtures

    @invalid_attrs %{line_itself: nil, order: nil}

    test "list_script_lines/0 returns all script_lines" do
      script_line = script_line_fixture()
      assert Scripting.list_script_lines() == [script_line]
    end

    test "get_script_line!/1 returns the script_line with given id" do
      script_line = script_line_fixture()
      assert Scripting.get_script_line!(script_line.id) == script_line
    end

    test "create_script_line/1 with valid data creates a script_line" do
      valid_attrs = %{line_itself: "some line_itself", order: 42}

      assert {:ok, %ScriptLine{} = script_line} = Scripting.create_script_line(valid_attrs)
      assert script_line.line_itself == "some line_itself"
      assert script_line.order == 42
    end

    test "create_script_line/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scripting.create_script_line(@invalid_attrs)
    end

    test "update_script_line/2 with valid data updates the script_line" do
      script_line = script_line_fixture()
      update_attrs = %{line_itself: "some updated line_itself", order: 43}

      assert {:ok, %ScriptLine{} = script_line} = Scripting.update_script_line(script_line, update_attrs)
      assert script_line.line_itself == "some updated line_itself"
      assert script_line.order == 43
    end

    test "update_script_line/2 with invalid data returns error changeset" do
      script_line = script_line_fixture()
      assert {:error, %Ecto.Changeset{}} = Scripting.update_script_line(script_line, @invalid_attrs)
      assert script_line == Scripting.get_script_line!(script_line.id)
    end

    test "delete_script_line/1 deletes the script_line" do
      script_line = script_line_fixture()
      assert {:ok, %ScriptLine{}} = Scripting.delete_script_line(script_line)
      assert_raise Ecto.NoResultsError, fn -> Scripting.get_script_line!(script_line.id) end
    end

    test "change_script_line/1 returns a script_line changeset" do
      script_line = script_line_fixture()
      assert %Ecto.Changeset{} = Scripting.change_script_line(script_line)
    end
  end
end
