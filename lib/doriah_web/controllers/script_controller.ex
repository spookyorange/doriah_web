defmodule DoriahWeb.ScriptController do
  alias Doriah.Scripting
  use DoriahWeb, :controller

  def get_script(conn, %{"id" => id}) do
    text(conn, Scripting.get_script_as_sh_file(id))
  end
end
