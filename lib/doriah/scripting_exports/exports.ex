defmodule Doriah.ScriptingExports.Exports do
  def annotate_script_with_loadout_warning(script) do
    """
    echo "Warning, you are running a script that is adviced to be used with a loadout, without a loadout"

    sleep 2

    echo "Starting in 3"
    sleep 1
    echo "2"
    sleep 1
    echo "1"
    sleep 1

    #{script}
    """
  end
end
