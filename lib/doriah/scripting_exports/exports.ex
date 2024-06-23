defmodule Doriah.ScriptingExports.Exports do
  def annotate(script_as_text, annotations) do
    # annotations are listified already!
    if length(annotations) == 0 do
      script_as_text
    else
      head_of_annotations = hd(annotations)

      case head_of_annotations do
        :under_development_warning ->
          annotate(annotate_script_with_development_warning(script_as_text), tl(annotations))

        :loadout_required_warning ->
          annotate(annotate_script_with_loadout_warning(script_as_text), tl(annotations))

        _ ->
          nil
      end
    end
  end

  defp annotate_script_with_loadout_warning(script) do
    """
    echo "Warning, you are running a script that is adviced to be used with a loadout, without a loadout"

    #{are_you_sure_prompt()}

    #{script}
    """
  end

  defp annotate_script_with_development_warning(script) do
    """
    echo "Warning, you are running a script that is flagged as under development"

    #{are_you_sure_prompt()}

    #{script}
    """
  end

  defp are_you_sure_prompt() do
    """

    read -p "Are you sure you want this?(y/[any key to cancel]): " answer

    if [ "$answer" = "y" ]; then
      sleep 1
      echo
      echo "Positivity acknowledged, continuing on..."
    else
      sleep 1
      echo "You did not answer positively, cancelling the process"
      exit 1
    fi

    echo

    """
  end
end
