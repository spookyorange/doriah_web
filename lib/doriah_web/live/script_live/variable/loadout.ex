defmodule DoriahWeb.ScriptLive.Variable.Loadout do
  alias Doriah.VariableManagement
  alias DoriahWeb.BaseUtil.KeyboardSupport

  use DoriahWeb, :live_view
  use DoriahWeb.BaseUtil.Controlful

  alias Doriah.Scripting

  def mount(_, _, socket) do
    {:ok, socket |> assign_controlful()}
  end

  def handle_params(%{"id" => id, "loadout_title" => loadout_title}, _, socket) do
    try do
      script = Scripting.get_script_with_loadouts!(id)

      try do
        loadout = VariableManagement.get_loadout_by_title!(script.id, loadout_title)

        compatible_variables =
          Enum.map(loadout.variables, fn variable ->
            %{key: variable["key"], value: variable["value"], index: variable["index"]}
          end)

        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:script, script)
         |> assign(:loadout, loadout)
         |> assign(:whole_script, script.whole_script)
         |> assign(:currently_applied_loadout_title, loadout.title)
         |> load_all_variables_to_ram(compatible_variables)
         |> assign(:saveable, false)
         |> apply_action(socket.assigns.live_action, script)}
      rescue
        _ ->
          {:noreply,
           socket
           |> push_navigate(to: ~p"/scripts/#{script}/variable_loadout")
           |> put_flash(:error, "Loadout not found")}
      end
    rescue
      _ ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/")
         |> put_flash(:error, "No clue how you got here, but no script nor a loadout is found")}
    end
  end

  def handle_params(%{"id" => id}, _, socket) do
    try do
      script = Scripting.get_script_with_loadouts!(id)

      {:noreply,
       socket
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:script, script)
       |> assign(:loadout, nil)
       |> assign(:whole_script, script.whole_script)
       |> assign(:currently_applied_loadout_title, "None")
       |> assign(
         :current_variables_in_ram,
         []
       )
       |> assign(:currently_applied_variables, [])
       |> assign(:saveable, false)
       |> apply_action(socket.assigns.live_action, script)}
    rescue
      _ ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/")
         |> put_flash(:error, "Script not found")}
    end
  end

  defp apply_action(socket, :variable_loadout, _script) do
    socket
  end

  defp apply_action(socket, :select_default, _script) do
    socket
  end

  defp apply_action(socket, :load_out, _script) do
    socket
  end

  defp apply_action(socket, :delete_loadout, _script) do
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

  defp load_all_variables_to_ram(socket, variables) do
    {variables, _accumulator} =
      Enum.map_reduce(
        variables,
        0,
        fn variable, acc ->
          {%{key: variable.key, value: variable.value, index: acc}, acc + 1}
        end
      )

    socket
    |> assign(:current_variables_in_ram, variables)
    |> assign(:currently_applied_variables, variables)
  end

  defp assign_new_variable_to_ram(socket) do
    if length(socket.assigns.current_variables_in_ram) == 0 do
      desired_index = 0

      socket
      |> assign(
        :current_variables_in_ram,
        socket.assigns.current_variables_in_ram ++
          [%{key: "", value: "", index: desired_index}]
      )
      |> push_event("focus-to-element-with-id", %{id: "key[#{desired_index}]"})
    else
      max_of_variables =
        socket.assigns.current_variables_in_ram
        |> Enum.map(fn var ->
          var.index
        end)
        |> Enum.max()

      desired_index = max_of_variables + 1

      socket
      |> assign(
        :current_variables_in_ram,
        socket.assigns.current_variables_in_ram ++
          [%{key: "", value: "", index: desired_index}]
      )
      |> push_event("focus-to-element-with-id", %{id: "key[#{desired_index}]"})
    end
  end

  defp apply_variables_from_ram_to_current(socket) do
    socket
    |> assign(:currently_applied_variables, socket.assigns.current_variables_in_ram)
    |> assign(:currently_applied_loadout_title, "Custom")
    |> assign(:saveable, true)
    |> clear_flash()
    |> put_flash(:info, "Variables applied to Script")
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
          [
            %{
              key: params[:key][head_key],
              value: params[:value][head_key],
              index: String.to_integer(head_key)
            }
          ]

      # tail of params is going to the next call of this function, kill key and value of head from params and pass!
      head_killed_keys = params[:key] |> Map.delete(head_key)
      head_killed_values = params[:value] |> Map.delete(head_key)

      tail_of_params = %{key: head_killed_keys, value: head_killed_values}

      add_params_from_ram_to_applied(tail_of_params, current_collective_list)
    end
  end

  defp save_loadout_from_applied_to_database(socket, title) do
    applied_variable_map = socket.assigns.currently_applied_variables

    {:ok, loadout} =
      VariableManagement.create_loadout(socket.assigns.script.id, %{
        title: title,
        variables: applied_variable_map
      })

    socket
    |> push_patch(to: ~p"/scripts/#{socket.assigns.script.id}/variable_loadout/#{loadout.id}")
    |> put_flash(:info, "Loadout successfully saved to database")
  end

  defp update_loadout(socket, title) do
    applied_variable_map = socket.assigns.currently_applied_variables

    {:ok, loadout} =
      VariableManagement.update_loadout(socket.assigns.loadout, %{
        title: title,
        variables: applied_variable_map
      })

    socket
    |> push_patch(to: ~p"/scripts/#{socket.assigns.script.id}/variable_loadout/#{loadout.id}")
    |> put_flash(:info, "Loadout successfully updated in the database")
  end

  defp navigate_to_default_loadout_selection(socket) do
    socket
    |> push_navigate(to: ~p"/scripts/#{socket.assigns.script}/variable_loadout/select_default")
  end

  def handle_event("create_new_variable", _, socket) do
    {:noreply,
     socket
     |> assign_new_variable_to_ram()}
  end

  def handle_event("remove_variable_from_ram", %{"variable-index" => variable_index}, socket) do
    new_variable_set_in_ram =
      socket.assigns.current_variables_in_ram
      |> Enum.filter(fn variable ->
        "#{variable.index}" != variable_index
      end)

    {:noreply,
     socket
     |> assign(:current_variables_in_ram, new_variable_set_in_ram)}
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

  def handle_event("locked_loadout", %{"loadout-title" => loadout_title}, socket) do
    if socket.assigns.script.loadouts
       |> Enum.any?(fn x -> x.title == loadout_title end) do
      {:ok, script} =
        Scripting.update_script(
          socket.assigns.script,
          %{
            default_loadout_codename: loadout_title
          }
        )

      {:noreply,
       socket
       |> push_patch(to: ~p"/scripts/#{script}/variable_loadout")
       |> clear_flash()
       |> put_flash(:info, "New default loadout: #{loadout_title}")}
    else
      {:noreply,
       socket
       |> clear_flash()
       |> put_flash(:error, "No such loadout with specified codename found")}
    end
  end

  def handle_event("clear_default_loadout", _, socket) do
    {:ok, script} =
      Scripting.update_script(
        socket.assigns.script,
        %{
          default_loadout_codename: nil
        }
      )

    {:noreply,
     socket
     |> push_patch(to: ~p"/scripts/#{script}/variable_loadout")
     |> clear_flash()
     |> put_flash(:info, "Cleared defualt loadout")}
  end

  def handle_event("save_loadout", %{"new_loadout" => %{"title" => loadout_title}}, socket) do
    {:noreply,
     socket
     |> save_loadout_from_applied_to_database(loadout_title)}
  end

  def handle_event("update_loadout", %{"loadout" => %{"title" => loadout_title}}, socket) do
    {:noreply,
     socket
     |> update_loadout(loadout_title)}
  end

  def handle_event("delete_loadout", %{"loadout-id" => loadout_id}, socket) do
    loadout = VariableManagement.get_loadout!(socket.assigns.script.id, loadout_id)
    {:ok, _} = VariableManagement.delete_loadout(loadout)

    {:noreply,
     socket
     |> push_patch(to: ~p"/scripts/#{socket.assigns.script}/variable_loadout")
     |> put_flash(:info, "Loadout deleted successfully")}
  end

  def handle_event("select_default_modal", _, socket) do
    {:noreply,
     socket
     |> navigate_to_default_loadout_selection()}
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

  def handle_event("keydown", %{"key" => "c"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :variable_loadout do
      {:noreply,
       socket
       |> navigate_to_default_loadout_selection()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "l"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :variable_loadout do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/#{socket.assigns.script}/variable_loadout/load_out")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "u"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :variable_loadout &&
         socket.assigns.saveable do
      {:noreply,
       socket
       |> push_event("focus-to-element-with-id", %{id: "loadout[title]"})}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "s"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :variable_loadout &&
         socket.assigns.saveable do
      {:noreply,
       socket
       |> push_event("focus-to-element-with-id", %{id: "new_loadout[title]"})}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "d"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :variable_loadout do
      {:noreply,
       socket
       |> push_patch(to: ~p"/scripts/#{socket.assigns.script}/variable_loadout/delete_loadout")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "n"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :variable_loadout do
      {:noreply,
       socket
       |> assign_new_variable_to_ram()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "a"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :variable_loadout do
      {:noreply,
       socket
       |> apply_variables_from_ram_to_current()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "e"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :variable_loadout do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/edit_mode")}
    else
      {:noreply, socket}
    end
  end

  use KeyboardSupport

  defp page_title(:variable_loadout), do: "Script - Variable Loadouts"
  defp page_title(:select_default), do: "Script - Select the default Loadout"
  defp page_title(:load_out), do: "Script - Load Loadout"
  defp page_title(:delete_loadout), do: "Script - Delete a Loadout"
end
