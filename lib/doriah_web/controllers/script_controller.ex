defmodule DoriahWeb.ScriptController do
  alias Doriah.Scripting
  use DoriahWeb, :controller

  def get_script(conn, params) do
    text(conn, Scripting.get_script_as_sh_file(params))
  end

  def get_script_with_applied_loadout(conn, params) do
    try do
      text(conn, Scripting.get_script_as_sh_file_with_loadout(params))
    rescue
      _ ->
        text(conn, """
        #!/usr/bin/env bash
        echo error: Script id or Loadout title is not valid, please try again with valid values!
        """)
    end
  end

  def export_as_sh(conn, params) do
    send_download(conn, {:binary, Scripting.get_script_as_sh_file(params)}, filename: "script.sh")
  end

  def export_as_doriah(conn, params) do
    send_download(conn, {:binary, Scripting.export_as_doriah(params)},
      filename: "script#{params["id"]}.doriah"
    )
  end
end
