defmodule DoriahWeb.ScriptController do
  alias Doriah.Scripting
  use DoriahWeb, :controller

  def get_script(conn, %{"id" => id}) do
    text(conn, Scripting.get_script_as_sh_file(id))
  end

  def get_script_download(conn, %{"id" => id}) do
    send_download(conn, {:binary, Scripting.get_script_as_sh_file(id)}, filename: "script.sh")
  end
end
