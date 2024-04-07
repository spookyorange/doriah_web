defmodule DoriahWeb.ScriptJSON do
  alias Doriah.Scripting

  @doc """
    Get the script, line by line, ready to be sent to the shell
  """
  def get_script(id) do
    Scripting.get_script_as_sh_file(id)
  end
end
