defmodule Doriah.ScriptingExports.Exports do
  def annotate(script_itself, script_as_text, annotations) do
    # annotations are listified already!
    if length(annotations) == 0 do
      script_as_text
    else
      head_of_annotations = hd(annotations)

      case head_of_annotations do
        :under_development_warning ->
          annotate(
            script_itself,
            annotate_script_with_development_warning(script_as_text),
            tl(annotations)
          )

        :loadout_required_warning ->
          annotate(
            script_itself,
            annotate_script_with_loadout_warning(script_itself, script_as_text),
            tl(annotations)
          )

        _ ->
          nil
      end
    end
  end

  defp annotate_script_with_loadout_warning(script_itself, script) do
    """
    echo "Warning, you are running a script that is adviced to be used with a loadout, without a loadout"

    #{do_you_want_to_switch_to_loadout_prompt(script_itself)}

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

  defp do_you_want_to_switch_to_loadout_prompt(script) do
    # loadouts are: %{title} as far as we are concerned
    choices = script.loadouts |> Enum.map(fn loadout -> loadout.title end)

    choices_as_text_looped =
      choices
      |> Enum.map(fn title ->
        """
          echo "#{title}"
        """
      end)

    choices_for_cases =
      choices
      |> Enum.map(fn title ->
        """
          #{title})
            echo "You have selected #{title} loadout"
            read -p "[curl]/wget: " method
            sleep 1
            if [ "$method" = "wget" ]; then
              echo "Continuing with wget"
              sh <(wget -qO- #{DoriahWeb.Endpoint.url()}/api/scripts/as_sh/#{script.id}/with_applied_loadout/#{title})
              exit 0
            fi
            echo "Continuing with curl"
            sh <(curl -s #{DoriahWeb.Endpoint.url()}/api/scripts/as_sh/#{script.id}/with_applied_loadout/#{title})
            exit 0
            ;;
        """
      end)

    """

    echo "You may choose from the choices over here, or just press anything else to continue without one"

    echo

    #{choices_as_text_looped}

    echo

    read -p "To select one, simply write its name(from above, case sensitive) now and press RETURN, or just input anything else(including nothing) to continue without one: " answer

    case $answer in
      #{choices_for_cases}

      *) 
        echo
        echo "Negativity acknowledged, continuing..."
        echo
        ;;

    esac

    """
  end
end
