defmodule Doriah.Scripting do
  @moduledoc """
  The Scripting context.
  """

  import Ecto.Query, warn: false
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
    Repo.one!(
      from s in Script,
        join: l in ScriptLine,
        on: s.id == l.script_id,
        where: s.id == ^id,
        select: max(l.order)
    )
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

      iex> create_script_line(%{field: value})
      {:ok, %ScriptLine{}}

      iex> create_script_line(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_associated_blank_script_line(script_id) do
    script = get_script!(script_id)
    script_line_max_number = get_script_lines_max_order!(script_id)

    %ScriptLine{}
    |> ScriptLine.changeset(%{line_itself: "To be filled", order: script_line_max_number + 1})
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
end
