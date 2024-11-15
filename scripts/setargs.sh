#!/usr/bin/env bash

# version 0.0.0

# Allow && || for debugging:
# shellcheck disable=2015

# Help: doc/setargs.txt

declare -r tag="setargs"
if [[ -v _sourced_files["$tag"] ]]; then
  return 0
fi
_sourced_files["$tag"]=""
declare -rgi __setargs___already________implemented=1

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0
#load_version "$dotfiles/scripts/assert.sh" 0.0.0
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0
#load_version "$dotfiles/scripts/cache.sh" 0.0.0
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0
#load_version "$dotfiles/scripts/setargs.sh" 0.0.0
load_version "$dotfiles/scripts/termcap.sh" 0.0.0
load_version "$dotfiles/scripts/utils.sh" 0.0.0

# Do not modify
declare -g get_args

# Modify to configure set_args
declare -gri _setargs_debug=0
declare -gr _setargs_colour_required="${text_lightred}"
declare -gr _setargs_colour_defaulted="${text_lightorange}"
declare -gr _setargs_colour_optional="${text_lightyellow}"
declare -gr _setargs_colour_argv="${text_lightpurple}"

declare -gr _setargs_optional_true="true"
declare -gr _setargs_optional_false="false"

# • Declare global variable --name-example ➜ __name_example
# • Return eval string declaring local varialbe --name-example ➜ name_example
_generate_new() {
  # TODO ❔Convert - to _ earlier so that name colisions can be found
  declare var_name="${1//-/_}"
  ((_setargs_debug)) && errchod "Declaring variable $var_name = $2" || :
  if [[ -v "$var_name" ]]; then
    abort "setargs: Won't overwrite existing variable $var_name"
  fi
  declare -n _sa_gn_eval_snippet_735="${3:?set_args: Missing eval string snippet for ${FUNCNAME[0]}}"
  printf -v _sa_gn_eval_snippet_735 'declare %s=%s;' "${var_name##*(_)}" "${2@Q}"
}

set_args() {
  ((_setargs_debug)) && errchod "Entering set_args"

  # Sanity checks
  [[ "$(shopt -p extglob)" != "shopt -s extglob" ]] && abort "Requires extglob"
  (($# < 1)) && abort "Setargs usage: dotfiles/doc/setargs.txt"

  # Augment special parameters:
  #   • --autocomplte   For bash completion
  #   • --help          To echo the (augmented) parameter string for usage info
  declare param_string="${1:?set_args: Missing parameter string}"
  ((_setargs_debug)) && errchod "Setargs param_string: [$param_string]"
  declare IFS=" "
  declare args="${*:2}"
  IFS=$'\n\t'
  ((_setargs_debug)) && errchod "IFS=[$IFS]"
  declare -a params
  mapfile -t params <<<"${param_string//+( )/$'\n'}"
  params+=("--autocomplete")
  declare -i allow_leftover_argv=0

  # Categorization for all names (set by param and arg loop)
  declare -A required  # p
  declare -A defaulted # p     param name -> values (udated only from params)
  declare -A optional  # p
  declare -a available # p     Available parameters in order (used for completion)
  declare -A provided  #   a   Provided either by name or positionally
  declare -A by_name   #   a   Provided explicitly by name
  declare -A values    # p+a   any name -> values

  # Variable data (kept for order)
  declare -a positional_data=()  #   a  Excluding split/immediate data)
  declare -a positional_order=() # p    May contain names of provided params
  declare -a leftover_argv=()    #   a  Leftover positional args.

  # Local helper
  declare p a name value
  declare -i i max_i

  #-------------------------------------------------
  # 1. Parsing parameters
  #-------------------------------------------------

  for p in "${params[@]}"; do
    ((_setargs_debug)) && errchod "Parsing parameter [$p]" || :
    # Sanity check: Start with hyphen "-"
    if [[ "${p:0:1}" != "-" ]]; then abort "Params must start with hyphen (--example)"; fi

    name="${p%%=*}"
    value="${p#*=}" # If optional we overwrite # TODO move into else then?

    # Special case: "--" argument enables 'leftover_argv'
    if [[ "$name" == "--" ]]; then
      allow_leftover_argv=1
      ((_setargs_debug)) && errchod "set_args: allow_leftover_argv=$allow_leftover_argv" || :
      continue
    fi

    # Sanity check: Restric characters used for parameter names
    # • 1 or more dashes "-" (to indicate parameter names), then
    # • one letter (to have valid identifier when dashes are removed), then
    # • any amount of word or "-" characters (dashes "-" are changed to
    #   underscpre "_" when generating variables)
    # ❗ The eval name is restricted ot make later used withn "eval".
    if [[ ! "$name" == +([-])[a-zA-Z]*([a-zA-Z0-9_-]) ]]; then
      abort "set_args: Illegal symbol in name $text_user$name$text_normal"
    fi

    # Sanity check: no duplicate parameter names (includes reserved names)
    if [[ -v values["$name"] ]]; then abort "Parameter $name is not unique"; fi

    if [[ ! "$p" =~ "=" ]]; then
      optional["$name"]="" # --flag
      value="${_setargs_optional_false}"
    else

      # Sanity check: reserved parameter name --help must be optional
      if [[ "$name" == "--help" ]]; then
        abort "set_args: Reserved parameter ${text_user}--help${text_normal} must be optionsl"
      fi

      positional_order+=("$name") # Non-optionals may be set by position data
      if ((${#value} == 0)); then
        required["$name"]="" # --required=
      else
        defaulted["$name"]="$value" # --name=default
      fi
    fi
    available+=("$name")
    values["$name"]="$value" # Overwrite this by args
    ((_setargs_debug)) && errchod "Making available: $text_user$name$text_normal" || :
  done

  # shellcheck disable=all
  if ((_setargs_debug)); then
    errchod "Parameters:" || :
    errchod " Available: $text_dim${available[@]}$text_normal" || :
    errchod " Required: $text_dim${!required[@]}$text_normal" || :
    errchod " Optional: $text_dim${!optional[@]}$text_normal" || :
    errchod " Defaulted: $text_dim${!defaulted[@]}$text_normal" || :
  fi

  #-------------------------------------------------
  # 2. Parsing arguments
  #-------------------------------------------------

  unset next_name
  declare positional_only="false"
  if (($# >= 2)); then for a in "${@:2}"; do

    ((_setargs_debug)) && errchod "Parsing argument [$a]" || :

    if [[ "${a:0:1}" != "-" ]] || [[ "$positional_only" == "true" ]]; then
      if [[ -v next_name ]]; then
        # Sanity check
        if [[ "$positional_only" == "true" ]]; then abort "Unreachable: Expecting name $next_name"; fi
        name="$next_name"
        value="$a"
        #        unset next_name;  # Done at end of for loop
      else
        # Data not preceeded by a dashed --name.
        # These are matched with whatever names left afterwards
        #        errchou "Adding positional data [$a]"
        positional_data+=("$a")
        continue
      fi

    else # Starts with -
      if [[ "${a}" == "--" ]]; then
        positional_only="true"
        continue
      fi
      if [[ -v next_name ]]; then abort "Expected data for positional name $next_name, got $a"; fi
      if [[ ! -v values["$name"] ]]; then abort "Unknown argument name $name"; fi

      name="${a%%=*}"
      value="${a#*=}"

      # Sanity check
      # TODO shorten. No output needed
      if [[ -v required["$name"] ]]; then
        : || errchof "Sanity check: $name is required"
      elif [[ -v defaulted["$name"] ]]; then
        : || errchof "Sanity check: $name is defaulted"
      elif [[ -v optional["$name"] ]]; then
        : || errchof "Sanity check: $name is optional"
      else
        ((_setargs_debug)) && errchod "$(print_values available "${available[@]}")" || :
        abort "Argument $text_user${name}$text_normal is unavailable in ${FUNCNAME[1]}"
      fi

      if [[ ! "$a" =~ "=" ]]; then
        if [[ -v optional["$name"] ]]; then
          value="${_setargs_optional_true}"
        else # Implied 'required' or 'defaulted' parameter
          # Wait for data
          declare next_name="$name"
          continue
        fi
      fi

    fi # Data or name?

    by_name["$name"]=""
    provided["$name"]="" # TODO For it to be correct, we would needto check if $value==""
    values["$name"]="$value"

    unset next_name
  done; fi
  if [[ -v next_name ]]; then abort "Expected data for positional name $next_name"; fi

  #-------------------------------------------------
  # 3. Match positional arguments
  #-------------------------------------------------

  # Match positional param names with positional argument data
  if ((${#positional_data[@]} > ${#positional_order[@]})); then
    ((_setargs_debug)) && errchod "$(print_values "positional_data" "${positional_data[@]}")"
    ((_setargs_debug)) && errchod "$(print_values positional_order "${positional_order[@]}")"
    if ! ((allow_leftover_argv)); then abort "Too much positional data"; fi
  fi

  # Match to not-given-by-name required and defaulted parameters
  i=0 # Data index. Increment when used.
  for name in "${positional_order[@]}"; do
    if ((i >= ${#positional_data[@]})); then break; fi
    if [[ -v by_name["$name"] ]]; then continue; fi
    values["$name"]="${positional_data[$i]}"
    ((++i))
    provided["$name"]=""
  done
  ((_setargs_debug)) && errchod "Afterwards: i=$i, $(print_values "positional_data" "${positional_data[@]}")"

  # Match remaining arguments into leftover_argv (if allowed)
  if ((i < ${#positional_data[@]})); then
    if ! ((allow_leftover_argv)); then abort "Too many lone data arguments"; fi
    for (( ; i < ${#positional_data[@]}; ++i)); do
      # TODO Use range instead of loop
      leftover_argv+=("${positional_data[$i]}")
    done
  fi

  ((_setargs_debug)) && errchod "Generated leftover_argv array: $(print_values leftover_argv "${leftover_argv[@]}")" || :
  ((_setargs_debug)) && errchof "leftover_argv actiavted: $allow_leftover_argv" || :
  # TODO (?) Use lone data arguments to create additional positional variables

  #-------------------------------------------------
  # 4. Generate variables
  #-------------------------------------------------

  declare eval_string_end="" # Use for auto-help if --help provided

  # Special cases: --help provided
  if [[ -v provided["--help"] ]]; then
    # Print available parameters colored as basis for usage print. When not in
    # use, mark with 'dim' text. When provided explicitly, mark with 'bold'
    # text.

    declare _setargs_helpstr="${runscript_path_coloured} ${text_blg}${FUNCNAME[1]#command_}${text_normal}"
    declare sed_expression=""
    #    errchof "_setargs_helpstr start: $_setargs_helpstr"
    #    errchof "funanem here: [${FUNCNAME[@]}]"
    # Append all available parameters and their values, colourized
    for p in "${available[@]}"; do
      declare name_format=""
      declare name_colour=""
      declare value_format=""
      declare -a syntax_format=("" "")
      declare syntax_colour="${text_normal}"
      # Colourize name and value
      if [[ -v required["$p"] ]]; then
        name_colour+="${_setargs_colour_required}"
      elif [[ -v defaulted["$p"] ]]; then
        name_colour+="${_setargs_colour_defaulted}"
      elif [[ -v optional["$p"] ]]; then
        name_colour+="${_setargs_colour_optional}"
      else
        abort "set_args: ${BASH_SOURCE[0]}:${LINENO[0]} unreachable"
      fi
      if [[ -v by_name["$p"] ]]; then
        name_colour+="${text_bold}"
      fi
      if [[ ! -v provided["$p"] ]]; then
        name_colour+="${text_dim}"
        value_format+="${text_dim}"
        syntax_colour+="${text_dim}"
      fi
      name_format+="${name_colour}%s${text_normal}"
      if [[ -v optional["$p"] ]]; then
        # When optionals have default value, differentiate them visually from
        # normal values (to the user doesnt feel compelled to provide one).
        syntax_format[0]="${syntax_colour}(=${text_normal}"
        syntax_format[1]="${syntax_colour})${text_normal}"
        value_format+="${text_di}%s${text_normal}"
      else
        value_format+="=${text_italic}%s${text_normal}"
      fi

      # Append to accumulators
      ((_setargs_debug)) && echod "Format string: [${name_format}${syntax_format[0]}${value_format}${syntax_format[1]}]" || :
      # TODO Can we use a constant format str here?
      # shellcheck disable=SC2059
      printf -v a "${name_format}${syntax_format[0]}${value_format}${syntax_format[1]}" "$p" "${values["$p"]}"
      _setargs_helpstr+=" $a"
      # We enforce to only use [a-zA-Z0-9_-] in parameter names
      sed_expression+=";s/$p=\\(\\w*\\)/$p=${text_italic}\\1${text_normal}/g" # Make value after '=' italic
      sed_expression+=";s/$p/${name_colour}${p}${text_normal}/g"              # Make --name coloured
    done                                                                      # Append available parameters colourized

    # Append argv
    if ((allow_leftover_argv)); then
      declare argv_colour="${_setargs_colour_argv}"
      declare argv_elem_colour="${_setargs_colour_argv}${text_italic}"
      declare argv_neutral=""
      if (("${#leftover_argv[@]}" == 0)); then
        argv_colour+="${text_dim}"
        argv_elem_colour+="${text_dim}"
        argv_neutral+="${text_dim}"
      else
        argv_colour+="${text_bold}"
      fi
      _setargs_helpstr+=" ${argv_colour}-- $(print_values_decorate argv "$argv_elem_colour" "$argv_neutral" "${leftover_argv[@]}")"
      sed_expression+=";s/\\bargv\\b/${argv_colour}argv${text_normal}/g" # Colour "argv"
    fi
    # This only works when `command_name` uses no special regex characters. If
    # you have wild command names, maybe xxd and replace in hex space.
    declare -r command_name="${FUNCNAME[1]#command_}"
    sed_expression+=";s/\\([^-]\\)\\(\\b${command_name}\\b\\)/\1${text_blg}\\2${text_normal}/g" # Make command name green

    # Underline SECTION TITLES at start of line
    sed_expression+=";s/^\\(\\s*\\)\\([_A-Z]\\{2,\\}\\)/\\1${text_underline}\\2${text_nounderline}/g"
    # Treat the last # per line as starting comments
    sed_expression+=";s/\\(#[^#]*\\)\$/${text_comment}\\1${text_normal}/g"
    # TODO The help info line is output separately from the help_string
    #      variable, so we cannot page them together. But we want to.
    echoi "$_setargs_helpstr" # TODO is it better to print this on stdout? Currently that would interfere with eval mode
    values["--help"]="$sed_expression"

    # ❕ This integrates provide_help so we dont have to type it. But it also
    # makes the code sort of messy. If this turns out a mistake just remove the
    # line below.
    # See: run_help_strings.sh for definition of provide_help().
    eval_string_end="provide_help;return 0;"
  fi # Special case: --help provided

  # Special cases: --autocomplete provided
  if [[ -v provided["--autocomplete"] ]]; then
    errchoe "set_args: --autocomplete is meant only for autocompletion script use"
    ((_setargs_debug)) && errchod "set_args: Exit to provide --autocomplete: $(print_values available "${available[@]}")" || :
    # show_variable available
    # We inserted --autocomplete as last parameter, so we hide it here
    printf "%s" "${available[*]::${#available[@]}-1}"
    # TODO: Alternatively set get_args to "return 0;" and continue normally.
    exit 0
  fi

  # When --help is provided, print message instead of aborting after some mistakes
  if [[ -v provided["--help"] ]]; then
    declare -r sanitize="echon"
  else
    declare -r sanitize="abort"
  fi

  declare eval_string=""
  for name in "${!values[@]}"; do

    # Sanity check unless --help provided.
    # Could also do
    #     if provided; then generate; fi
    if [[ ! -v provided["$name"] ]]; then
      if [[ -v required["$name"] ]]; then
        "$sanitize" "${text_blr}✖ missing $name$text_normal"
      elif [[ -v optional["$name"] ]]; then
        :
      elif [[ -v defaulted["$name"] ]]; then
        :
      else
        abort "Unreachable: name \"$name\" of unknown kind"
      fi
    else
      :
      ((_setargs_debug)) &&
        if [[ -v by_name["$name"] ]]; then
          errchod "Setting name $name by name"
        else
          errchod "Setting name $name by position"
        fi
    fi

    declare snippet=""
    _generate_new "${name}" "${values["$name"]}" "snippet"
    eval_string+="$snippet"
  done

  # Generate argv (only in eval mode; eventually that should be our only mode)
  if ((allow_leftover_argv)); then
    declare -a argv=("${leftover_argv[@]}") # Encode as eval-able string
    ((_setargs_debug)) && errchof "declaring argv as: ${argv[*]@A}" || :
    eval_string+="${argv[*]@A};"
  fi

  eval_string+="$eval_string_end"

  # Write global eval string that can import variables to local scope. Use as:
  #
  #     set_args "--params" "$@"
  #     eval "$get_args"
  #
  # Evaluating get_args must follow set_args immediately because the "get_args"
  # string would be overwritten by a subcommand's set_args.

  eval_string+='get_args="";' # Prevent accidental re-use
  printf -v get_args '%s' "$eval_string"

  # TODO use this instead:
  #get_args="${eval_string}"

}
