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

  def annotate_script_with_loadout_warning(script) do
    """
    echo "Warning, you are running a script that is adviced to be used with a loadout, without a loadout"
    echo "3 second penalty to think this over"
    sleep 3

    #{script}
    """
  end

  def annotate_script_with_development_warning(script) do
    """
    echo "Warning, you are running a script that is flagged as under development"
    echo "2 second penalty to think this over"
    sleep 2

    #{script}
    """
  end
end
