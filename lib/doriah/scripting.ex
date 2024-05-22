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
  Gets a single script w/variables.

  Raises `Ecto.NoResultsError` if the Script does not exist.

  ## Examples

      iex> get_script_with_variables(123)
      %Script{}

      iex> get_script_with_variables!(456)
      ** (Ecto.NoResultsError)

  """
  def get_script_with_variables!(id) do
    Repo.get!(Script, id)
    |> Repo.preload(script_variables: from(v in ScriptVariable, order_by: v.inserted_at))
    |> Repo.preload(:loadouts)
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
    Repo.transaction(fn ->
      Repo.delete(script_line)
      # we also need to update all the ABOVE ordered ones to match
      Repo.update_all(
        from(line in ScriptLine,
          where: line.script_id == ^script_line.script_id,
          where: line.order > ^script_line.order
        ),
        inc: [order: -1]
      )
    end)
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

  def put_list_to_map(list, map \\ %{}) do
    if length(list) == 0 do
      map
    else
      head = hd(list)

      key_name = Map.keys(head) |> hd()

      mutated_map = Map.put(map, key_name, head[key_name])

      put_list_to_map(tl(list), mutated_map)
    end
  end

  def get_script_as_sh_file(params) do
    script = get_script_with_variables!(params["id"])

    other_param_keys = Map.keys(params) |> Enum.filter(fn param_key -> param_key != "id" end)

    # for customs, we'll do it aggressively, if matches, just override it, doesnt -> create it no problem!
    other_params_as_list =
      other_param_keys
      |> Enum.map(fn param_key ->
        %{param_key => params[param_key]}
      end)

    cooked_variables = put_list_to_map(other_params_as_list)

    fill_content_with_variables(script.whole_script, cooked_variables)
  end

  def standardize_variables(variables) do
    variables
    |> Enum.map(fn variable ->
      %{variable.key => variable.default_value}
    end)
  end

  def import_sh_script(id, raw_body) do
    script = get_script!(id)

    {:ok, updated_script} = update_script(script, %{whole_script: raw_body})

    {:ok, updated_script}
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

  @doc """
  Return the `content` with filled variables

  ## Examples

      iex > fill_content_with_variables(content, variables)
      "filled content"
  """
  def fill_content_with_variables(content, variables) do
    if length(Map.keys(variables)) === 0 do
      content
    else
      all_keys = Map.keys(variables)

      head_key = hd(all_keys)

      {selected_variable_value, remaining_map} = Map.pop(variables, head_key)

      mutated_content =
        String.replace(content, "####{head_key}###", selected_variable_value)

      fill_content_with_variables(mutated_content, remaining_map)
    end
  end
end
