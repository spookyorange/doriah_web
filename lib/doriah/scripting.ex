defmodule Doriah.Scripting do
  @moduledoc """
  The Scripting context.
  """

  import Ecto.Query, warn: false
  alias Doriah.Repo

  alias Doriah.Scripting.Script
  alias Doriah.ScriptingExports.Exports

  @doc """
  Returns the list of scripts.

  ## Examples

      iex> list_scripts()
      [%Script{}, ...]

  """
  def list_scripts do
    Repo.all(from s in Script, where: s.listed == true, order_by: [desc: s.inserted_at])
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
  Gets a single script w/variable loadout.

  Raises `Ecto.NoResultsError` if the Script does not exist.

  ## Examples

      iex> get_script_with_loadouts!(123)
      %Script{}

      iex> get_script_with_loadouts!(456)
      ** (Ecto.NoResultsError)

  """
  def get_script_with_loadouts!(id) do
    Repo.get!(Script, id)
    |> Repo.preload(:loadouts)
  end

  @doc """
  Gets a single script w/a variable loadout that we crave.

  Raises `Ecto.NoResultsError` if the Script does not exist.

  ## Examples

      iex> get_script_with_a_specific_loadout!(123, world)
      {script: %Script{}, loadout: %Loadout{}}

      iex> get_script_with_a_specific_loadout!(456, hey)
      ** (Ecto.NoResultsError)

  """

  def get_script_with_a_specific_loadout!(script_id, loadout_title) do
    script_with_all_loadouts =
      Repo.get!(Script, script_id)
      |> Repo.preload(:loadouts)

    loadout_we_want =
      script_with_all_loadouts.loadouts
      |> Enum.filter(fn loadout ->
        loadout.title == loadout_title
      end)
      |> List.first()

    %{script: script_with_all_loadouts, loadout: loadout_we_want}
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

  def create_script_with_loadout_assoc(attrs \\ %{}) do
    %Script{}
    |> Script.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:loadouts)
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
    script = get_script_with_loadouts!(params["id"])

    other_param_keys = Map.keys(params) |> Enum.filter(fn param_key -> param_key != "id" end)

    # for customs, we'll do it aggressively, if matches, just override it, doesnt -> create it no problem!
    other_params_as_list =
      other_param_keys
      |> Enum.map(fn param_key ->
        %{param_key => params[param_key]}
      end)

    cooked_variables = put_list_to_map(other_params_as_list)

    script_as_text = fill_content_with_variables(script.whole_script, cooked_variables)

    if(script.loadout_required) do
      Exports.annotate_script_with_loadout_warning(script_as_text)
    else
      script_as_text
    end
  end

  def get_script_as_sh_file_with_loadout(params) do
    %{script: script, loadout: loadout} =
      get_script_with_a_specific_loadout!(params["id"], params["loadout_title"])

    other_param_keys =
      Map.keys(params)
      |> Enum.filter(fn param_key -> param_key != "id" || param_key != "loadout_title" end)

    half_baked_variables = loadout.variables |> standardize_variables() |> put_list_to_map()

    # for customs, we'll do it aggressively, if matches, just override it, doesnt -> create it no problem!
    other_params_as_list =
      other_param_keys
      |> Enum.map(fn param_key ->
        %{param_key => params[param_key]}
      end)

    cooked_variables = put_list_to_map(other_params_as_list, half_baked_variables)

    fill_content_with_variables(script.whole_script, cooked_variables)
  end

  def standardize_variables(variables) do
    variables
    |> Enum.map(fn variable ->
      %{variable["key"] => variable["value"]}
    end)
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

  def export_as_doriah(params) do
    script = get_script_with_loadouts!(params["id"])

    """
    !![script]!!
    """
    |> add_basic_info_to_doriah_file(script.title, script.description)
    |> add_whole_script_to_doriah_file(script.whole_script)
    |> add_loadouts_to_doriah_file(script.loadouts)
    |> add_end_to_doriah_file()
  end

  defp add_basic_info_to_doriah_file(cumulate_binary, script_title, script_description) do
    """
    #{cumulate_binary}
    !!![basic_info]!!!
    title: #{script_title}
    script_description: #{script_description}
    +++[basic_info]+++
    """
  end

  defp add_whole_script_to_doriah_file(cumulative_binary, whole_script) do
    """
    #{cumulative_binary}
    !!![whole_script]!!!
    #{whole_script}
    +++[whole_script]+++
    """
  end

  defp add_loadouts_to_doriah_file(cumulate_binary, loadouts) do
    doriah_compatible_loadout_list =
      Enum.reduce(Enum.reverse(loadouts), "", fn loadout, acc ->
        """
        #{acc}
        !!!![loadout]!!!!
        title: #{loadout.title}
        variables: #{Enum.reduce(Enum.reverse(loadout.variables), "", fn variable, acc -> "#{acc}#{variable["key"]} => #{variable["value"]},,," end)}
        ++++[loadout]++++
        """
      end)

    """
    #{cumulate_binary}
    !!![loadouts]!!!
    #{doriah_compatible_loadout_list}
    +++[loadouts]+++
    """
  end

  defp add_end_to_doriah_file(cumulative_binary) do
    """
    #{cumulative_binary}
    ++[script]++
    """
  end

  def import_from_file(importable_map) do
    create_script_with_loadout_assoc(%{
      title: importable_map |> Map.get(:title),
      description: importable_map |> Map.get(:description),
      whole_script: importable_map |> Map.get(:whole_script),
      loadouts: importable_map |> Map.get(:loadouts),
      status: :just_imported
    })
  end

  def status_name_to_displayable_name(status) do
    case status do
      :under_development -> "Under Development"
      :untested_usable -> "Untested Stable"
      :stable -> "Stable"
      :deprecated -> "Deprecated"
      :discounted -> "Discounted"
      :just_imported -> "Just Imported"
      _ -> "Unknown"
    end
  end
end
