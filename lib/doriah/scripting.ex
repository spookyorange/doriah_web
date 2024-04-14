defmodule Doriah.Scripting do
  @moduledoc """
  The Scripting context.
  """

  import Ecto.Query, warn: false
  alias Doriah.Scripting.ScriptVariable
  alias Doriah.Scripting.ScriptLine
  alias Doriah.Repo

  alias Doriah.Scripting.Script

  @doc """
  Returns the list of scripts.

  ## Examples

      iex> list_scripts()
      [%Script{}, ...]

  """
  def list_scripts do
    Repo.all(Script)
  end

  @doc """
  Gets a single script.

  Raises `Ecto.NoResultsError` if the Script does not exist.

  ## Examples

      iex> get_script!(123)
      %Script{}

      iex> get_script!(456)
      ** (Ecto.NoResultsError)

  """
  def get_script!(id), do: Repo.get!(Script, id)

  @doc """
  Gets a single script w/lines.

  Raises `Ecto.NoResultsError` if the Script does not exist.

  ## Examples

      iex> get_script_with_lines!(123)
      %Script{}

      iex> get_script_with_lines!(456)
      ** (Ecto.NoResultsError)

  """
  def get_script_with_lines!(id) do
    Repo.get!(Script, id)
    |> Repo.preload(script_lines: from(l in ScriptLine, order_by: l.order))
    |> Repo.preload(script_variables: from(v in ScriptVariable, order_by: v.inserted_at))
  end

  @doc """
  Gets a single scripts line count.

  Raises `Ecto.NoResultsError` if the Script does not exist.

  ## Examples

      iex> get_script_lines_max_order!(123)
      number

      iex> get_script_lines_max_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_script_lines_max_order!(id) do
    max_order =
      Repo.one!(
        from s in Script,
          join: l in ScriptLine,
          on: s.id == l.script_id,
          where: s.id == ^id,
          select: max(l.order)
      )

    max_order || 0
  end

  @doc """
  Creates a script.

  ## Examples

      iex> create_script(%{field: value})
      {:ok, %Script{}}

      iex> create_script(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_script(attrs \\ %{}) do
    %Script{}
    |> Script.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a script.

  ## Examples

      iex> update_script(script, %{field: new_value})
      {:ok, %Script{}}

      iex> update_script(script, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_script(%Script{} = script, attrs) do
    script
    |> Script.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a script.

  ## Examples

      iex> delete_script(script)
      {:ok, %Script{}}

      iex> delete_script(script)
      {:error, %Ecto.Changeset{}}

  """
  def delete_script(%Script{} = script) do
    Repo.delete(script)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking script changes.

  ## Examples

      iex> change_script(script)
      %Ecto.Changeset{data: %Script{}}

  """
  def change_script(%Script{} = script, attrs \\ %{}) do
    Script.changeset(script, attrs)
  end

  alias Doriah.Scripting.ScriptLine

  @doc """
  Returns the list of script_lines.

  ## Examples

      iex> list_script_lines()
      [%ScriptLine{}, ...]

  """
  def list_script_lines do
    Repo.all(ScriptLine)
  end

  @doc """
  Gets a single script_line.

  Raises `Ecto.NoResultsError` if the Script line does not exist.

  ## Examples

      iex> get_script_line!(123)
      %ScriptLine{}

      iex> get_script_line!(456)
      ** (Ecto.NoResultsError)

  """
  def get_script_line!(id), do: Repo.get!(ScriptLine, id)

  @doc """
  Creates a script_line.

  ## Examples

      iex> create_associated_blank_script_line(script_id)
      {:ok, %ScriptLine{}}

  """
  def create_associated_blank_script_line(script_id) do
    script = get_script!(script_id)
    script_line_max_number = get_script_lines_max_order!(script_id)

    %ScriptLine{}
    |> ScriptLine.changeset(%{line_itself: "", order: script_line_max_number + 1})
    |> Ecto.Changeset.put_assoc(:script, script)
    |> Repo.insert()
  end

  @doc """
  Updates a script_line.

  ## Examples

      iex> update_script_line(script_line, %{field: new_value})
      {:ok, %ScriptLine{}}

      iex> update_script_line(script_line, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_script_line(%ScriptLine{} = script_line, attrs) do
    script_line
    |> ScriptLine.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a script_line.

  ## Examples

      iex> delete_script_line(script_line)
      {:ok, %ScriptLine{}}

      iex> delete_script_line(script_line)
      {:error, %Ecto.Changeset{}}

  """
  def delete_script_line(%ScriptLine{} = script_line) do
    Repo.delete(script_line)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking script_line changes.

  ## Examples

      iex> change_script_line(script_line)
      %Ecto.Changeset{data: %ScriptLine{}}

  """
  def change_script_line(%ScriptLine{} = script_line, attrs \\ %{}) do
    ScriptLine.changeset(script_line, attrs)
  end

  def get_script_as_sh_file(id) do
    script = get_script_with_lines!(id)
    # we need the lines concatted with \n
    # Enum.join(script.script_lines, "\n")
    script.script_lines
    |> Enum.map(& &1.line_itself)
    |> Enum.map(&to_string/1)
    |> Enum.join("\n")
  end

  def import_multiline_script(id, raw_body) do
    script = get_script!(id)
    latest_order = get_script_lines_max_order!(id)

    cumulative_script_lines =
      raw_body
      |> String.split("\n")
      |> Enum.with_index(latest_order + 1)
      |> Enum.map(fn {text, index} ->
        %{
          line_itself: text,
          order: index,
          script_id: script.id,
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
          updated_at: DateTime.truncate(DateTime.utc_now(), :second)
        }
      end)

    Repo.insert_all(ScriptLine, cumulative_script_lines)

    whole_script_with_lines = get_script_with_lines!(id)

    {:ok, whole_script_with_lines}
  end

  alias Doriah.Scripting.ScriptVariable

  @doc """
  Returns the list of script_variables.

  ## Examples

      iex> list_script_variables()
      [%ScriptVariable{}, ...]

  """
  def list_script_variables do
    Repo.all(ScriptVariable)
  end

  @doc """
  Returns the list of script_variables of a given script(by id).

  ## Examples

      iex> list_script_variables_of_script(script_id)
      [%ScriptVariable{}, ...]

  """
  def list_script_variables_of_script(script_id) do
    Repo.all(from v in ScriptVariable, where: v.script_id == ^script_id)
  end

  @doc """
  Gets a single script_variable.

  Raises `Ecto.NoResultsError` if the Script variable does not exist.

  ## Examples

      iex> get_script_variable!(123)
      %ScriptVariable{}

      iex> get_script_variable!(456)
      ** (Ecto.NoResultsError)

  """
  def get_script_variable!(id), do: Repo.get!(ScriptVariable, id)

  @doc """
  Creates a script_variable.

  ## Examples

      iex> create_script_variable(%{field: value})
      {:ok, %ScriptVariable{}}

      iex> create_script_variable(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_script_variable(%Script{} = script, attrs \\ %{}) do
    %ScriptVariable{}
    |> ScriptVariable.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:script, script)
    |> Repo.insert()
  end

  @doc """
  Updates a script_variable.

  ## Examples

      iex> update_script_variable(script_variable, %{field: new_value})
      {:ok, %ScriptVariable{}}

      iex> update_script_variable(script_variable, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_script_variable(%ScriptVariable{} = script_variable, attrs) do
    script_variable
    |> ScriptVariable.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a script_variable.

  ## Examples

      iex> delete_script_variable(script_variable)
      {:ok, %ScriptVariable{}}

      iex> delete_script_variable(script_variable)
      {:error, %Ecto.Changeset{}}

  """
  def delete_script_variable(%ScriptVariable{} = script_variable) do
    Repo.delete(script_variable)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking script_variable changes.

  ## Examples

      iex> change_script_variable(script_variable)
      %Ecto.Changeset{data: %ScriptVariable{}}

  """
  def change_script_variable(%ScriptVariable{} = script_variable, attrs \\ %{}) do
    ScriptVariable.changeset(script_variable, attrs)
  end
end
