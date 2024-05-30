defmodule DoriahWeb.ScriptLive.ImportComponent do
  alias Doriah.Scripting
  alias Doriah.Scripting.Script
  use DoriahWeb, :live_component

  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:doriah_file, accept: ~w(.doriah), max_entries: 1)
     |> assign(:seems_valid, false)
     |> assign(:imported_entity, %Script{})}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Import a Script
        <:subtitle>
          Import your beloved .doriah files here!
        </:subtitle>
      </.header>
      <form phx-target={@myself} phx-change="validate" phx-submit="submit">
        Please import the file from the button here, system will check if it's valid
        <div class="flex flex-col md:flex-row gap-4 justify-between mt-4">
          <.live_file_input upload={@uploads.doriah_file} />
          <.button>
            Upload
          </.button>
        </div>
      </form>

      <form :if={@seems_valid} phx-change="validate" phx-submit="import" phx-target={@myself}>
        <div class="flex flex-col gap-4 items-center mt-4">
          Seems valid, click the button to import it for real!
          <.button type="submit">
            Import It!
          </.button>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("import", _, socket) do
    {:ok, new_script} = Scripting.import_from_file(socket.assigns.imported_entity)

    {:noreply,
     socket
     |> push_navigate(to: ~p"/scripts/#{new_script}")
     |> clear_flash()
     |> put_flash(:info, "Script imported successfully!")}
  end

  def handle_event("submit", _params, socket) do
    file_data_as_binary =
      consume_uploaded_entries(socket, :doriah_file, fn %{path: path}, _entry ->
        File.read(path)
      end)
      |> List.last()

    assign(socket, :seems_valid, false)

    # now that we have the data as binary, we need to make sure that it's valid, by just checking the first row
    if String.starts_with?(file_data_as_binary, "!![script]!!") do
      basic_info_part =
        strip_standardized_part_of_given_string(file_data_as_binary, "basic_info")

      whole_script_part =
        strip_standardized_part_of_given_string(file_data_as_binary, "whole_script")

      loadouts_part =
        strip_standardized_part_of_given_string(file_data_as_binary, "loadouts")

      {:noreply,
       socket
       |> assign(
         :imported_entity,
         socket.assigns.imported_entity
         |> Map.put(
           :title,
           basic_info_part
           |> strip_a_part_of_import("title:", "script_description:")
           |> String.trim()
         )
         |> Map.put(
           :description,
           basic_info_part |> String.split("script_description:") |> List.last() |> String.trim()
         )
         |> Map.put(
           :whole_script,
           whole_script_part |> String.trim_leading("\n") |> String.trim_trailing("\n")
         )
         |> Map.put(:loadouts, make_list_from_loadout_part(loadouts_part))
       )
       |> assign(:seems_valid, true)}
    end
  end

  defp strip_standardized_part_of_given_string(whole_data, tha_string) do
    strip_a_part_of_import(whole_data, "!!![#{tha_string}]!!!", "+++[#{tha_string}]+++")
  end

  defp strip_a_part_of_import(whole_data, start_of_it, end_of_it) do
    whole_data
    |> String.split(start_of_it, parts: 2)
    |> List.last()
    |> String.split(end_of_it, parts: 2)
    |> List.first()
  end

  defp get_cumulative_loadouts(remaining, existing \\ []) do
    if(String.trim(remaining) == "") do
      existing
    else
      remaining_as_2_parts =
        remaining
        |> String.split("!!!![loadout]!!!!", parts: 2)

      part_of_interest = remaining_as_2_parts |> List.last()

      fruitful_plus_remaining =
        part_of_interest
        |> String.split("++++[loadout]++++", parts: 2)

      fruitful = fruitful_plus_remaining |> List.first()

      new_remaining = fruitful_plus_remaining |> List.last()

      get_cumulative_loadouts(new_remaining, [fruitful | existing])
    end
  end

  defp make_list_from_loadout_part(part_as_string) do
    raw_cumulative_loadout_as_list = get_cumulative_loadouts(part_as_string)

    raw_cumulative_loadout_as_list
    |> Enum.reduce([], fn loadout, acc ->
      new_one = %{
        title: strip_a_part_of_import(loadout, "title:", "variables:") |> String.trim(),
        variables:
          loadout
          |> String.split("variables:")
          |> List.last()
          |> String.split(",,,")
          |> List.delete_at(-1)
          |> Enum.map(fn variable ->
            two_part_variable = variable |> String.split("=>")

            %{
              key: two_part_variable |> List.first() |> String.trim(),
              value: two_part_variable |> List.last() |> String.trim()
            }
          end)
      }

      [new_one | acc]
    end)
  end
end
