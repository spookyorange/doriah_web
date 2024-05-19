defmodule DoriahWeb.ScriptLive.Variable.Loadout do
  alias DoriahWeb.BaseUtil.KeyboardSupport

  use DoriahWeb, :live_view
  use DoriahWeb.BaseUtil.Controlful

  import DoriahWeb.ScriptLive.Variable.Index

  alias Doriah.Scripting

  def mount(_, _, socket) do
    {:ok, socket |> assign_controlful()}
  end

  def handle_params(%{"id" => id}, _, socket) do
    script = Scripting.get_script_with_variables!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:script, script)
     |> assign(:whole_script, script.whole_script)
     |> assign(:currently_applied_loadout_title, "None")
     |> assign(
       :current_variables_in_ram,
       []
     )
     |> assign(:currently_applied_variables, [])
     |> apply_action(socket.assigns.live_action, script)}
  end

  defp apply_action(socket, :variable_loadout, _script) do
    socket
  end

  defp change_variables_to_desired_structure(variables) do
    variables
    |> Enum.map(fn variable ->
      %{variable.key => variable.value}
    end)
  end

  def apply_variables_to_script(script, raw_variables) do
    Scripting.fill_content_with_variables(
      script,
      raw_variables
      |> change_variables_to_desired_structure()
      |> Scripting.put_list_to_map()
    )
  end

  defp assign_new_variable_to_ram(socket) do
    current_ram_variables_length = length(socket.assigns.current_variables_in_ram)

    socket
    |> assign(
      :current_variables_in_ram,
      socket.assigns.current_variables_in_ram ++
        [%{key: "", value: "", index: current_ram_variables_length}]
    )
  end

  defp apply_variables_from_ram_to_current(socket) do
    socket
    |> assign(:currently_applied_variables, socket.assigns.current_variables_in_ram)
    |> assign(:currently_applied_loadout_title, "Custom")
  end

  defp add_params_from_ram_to_applied(params, collective_map_list \\ []) do
    # new params will look like 
    # %{"key" => %{"0" => ""}, "value" => %{"0" => ""}} 

    # recursively, apply, remove, apply again!
    # Map.put(collective_map, new_key, new_value)
    # the limit checker:

    if params[:key] == %{} do
      collective_map_list
    else
      # add to collective map, and run it again with less keys, maybe less values for better performance
      # (almost no diff but still (:.)
      all_keys = params[:key] |> Map.keys()
      head_key = hd(all_keys)

      # head key would be "0" in our case, and we'd access it from params["key"][head_key]
      # what i need to do is actually create this thing, key value index, just like the standard
      # construct this got from that place, to make sure that everything is always smooth
      # add this contruct inside: %{key: "", value: "", index: number}
      # head_key is index, key is params["key"][head_key] value is params["value"][head_key]
      current_collective_list =
        collective_map_list ++
          [%{key: params[:key][head_key], value: params[:value][head_key], index: head_key}]

      # tail of params is going to the next call of this function, kill key and value of head from params and pass!
      head_killed_keys = params[:key] |> Map.delete(head_key)
      head_killed_values = params[:value] |> Map.delete(head_key)

      tail_of_params = %{key: head_killed_keys, value: head_killed_values}

      add_params_from_ram_to_applied(tail_of_params, current_collective_list)
    end
  end

  def handle_event("create_new_variable", _, socket) do
    {:noreply,
     socket
     |> assign_new_variable_to_ram()}
  end

  def handle_event("save_variable_changes_to_ram", params, socket) do
    atomic_params = %{key: params["key"], value: params["value"]}
    desired_variables_to_be_applied = add_params_from_ram_to_applied(atomic_params)

    {:noreply,
     socket
     |> assign(:current_variables_in_ram, desired_variables_to_be_applied)}
  end

  def handle_event("apply_variables_from_ram_to_current", _params, socket) do
    {:noreply,
     socket
     |> apply_variables_from_ram_to_current()}
  end

  def handle_event("keydown", %{"key" => "b"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :variable_loadout do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/#{socket.assigns.script}")}
    else
      {:noreply, socket}
    end
  end

  use KeyboardSupport

  defp page_title(:variable_loadout), do: "Script - Variable Loadouts"
end