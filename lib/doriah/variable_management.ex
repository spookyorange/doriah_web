defmodule Doriah.VariableManagement do
  @moduledoc """
  The VariableManagement context.
  """

  import Ecto.Query, warn: false
  alias Doriah.Scripting
  alias Doriah.Repo

  alias Doriah.VariableManagement.Loadout

  @doc """
  Returns the list of loadouts.

  ## Examples

      iex> list_loadouts()
      [%Loadout{}, ...]

  """
  def list_loadouts do
    Repo.all(Loadout)
  end

  @doc """
  Gets a single loadout.

  Raises `Ecto.NoResultsError` if the Loadout does not exist.

  ## Examples

      iex> get_loadout!(1, 123)
      %Loadout{}

      iex> get_loadout!(1, 456)
      ** (Ecto.NoResultsError)

  """
  def get_loadout!(script_id, id),
    do: Repo.one(from l in Loadout, where: l.id == ^id and l.script_id == ^script_id)

  @doc """
  Gets a single loadout by it's title & script id.
                                                                                      
  Raises `Ecto.NoResultsError` if the Loadout does not exist.
                                                                                      
  ## Examples
                                                                                      
      iex> get_loadout_by_title!(1, default)
      %Loadout{}
                                                                                      
      iex> get_loadout_by_title!(1, heya)
      ** (Ecto.NoResultsError)
                                                                                      
  """
  def get_loadout_by_title!(script_id, title),
    do: Repo.one(from l in Loadout, where: l.title == ^title and l.script_id == ^script_id)

  @doc """
  Creates a loadout.

  ## Examples

      iex> create_loadout(1, %{field: value})
      {:ok, %Loadout{}}

      iex> create_loadout(1, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_loadout(script_id, attrs \\ %{}) do
    script = Scripting.get_script!(script_id)

    %Loadout{}
    |> Loadout.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:script, script)
    |> Repo.insert()
  end

  @doc """
  Updates a loadout.

  ## Examples

      iex> update_loadout(loadout, %{field: new_value})
      {:ok, %Loadout{}}

      iex> update_loadout(loadout, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_loadout(%Loadout{} = loadout, attrs) do
    loadout
    |> Loadout.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a loadout.

  ## Examples

      iex> delete_loadout(loadout)
      {:ok, %Loadout{}}

      iex> delete_loadout(loadout)
      {:error, %Ecto.Changeset{}}

  """
  def delete_loadout(%Loadout{} = loadout) do
    Repo.delete(loadout)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking loadout changes.

  ## Examples

      iex> change_loadout(loadout)
      %Ecto.Changeset{data: %Loadout{}}

  """
  def change_loadout(%Loadout{} = loadout, attrs \\ %{}) do
    Loadout.changeset(loadout, attrs)
  end
end
