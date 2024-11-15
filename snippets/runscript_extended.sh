#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 version            │
# ╰──────────────────────╯
# version 0.0.0
# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯
# TODO: This is a template runscript.

# Define commands by prefixing a funciton name with 'command_':
# │   command_name() {}
# Call commands from within the script:
# │   subcommand name [args]
# Allow nonzero exit/return:
#     may_fail [return_value_variable] -- <command>
# NOTE: may_fail runs <command> in a subshell

# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
declare -gr dotfiles="${DOTFILES:-"$HOME/dotfiles"}" # TOKEN_DOTFILES_GLOBAL
# ☯ Every file prevents multi-loads itself using this global dict
declare -gA _sourced_files=(["runscript"]="")
# 🖈 If the runscript requires a specific location, set it here
declare -gr this_location="/tmp"
source "$dotfiles/scripts/boilerplate.sh" "${BASH_SOURCE[0]}" "$@"
# ╭──────────────────────╮
# │ 🛠Configuration      │
# ╰──────────────────────╯
_run_config["versioning"]=0   # {0, 1}
_run_config["log_loads"]=1    # {0, 1}
_run_config["error_frames"]=4 # {1, 2, ...}
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
# ✔ Ensure versions with satisfy_version
satisfy_version "$dotfiles/scripts/boilerplate.sh" 0.0.0
# ✔ Source versioned dependencies with load_version
load_version "$dotfiles/scripts/version.sh" 0.0.0
#load_version "$dotfiles/scripts/assert.sh"
#load_version "$dotfiles/scripts/bash_meta.sh"
#load_version "$dotfiles/scripts/cache.sh"
#load_version "$dotfiles/scripts/error_handling.sh"
#load_version "$dotfiles/scripts/fileinteracts.sh"
#load_version "$dotfiles/scripts/git_utils.sh"
#load_version "$dotfiles/scripts/progress_bar.sh"
load_version "$dotfiles/scripts/setargs.sh"
load_version "$dotfiles/scripts/termcap.sh"
#load_version "$dotfiles/scripts/userinteracts.sh"
load_version "$dotfiles/scripts/utils.sh"
# ╭──────────────────────╮
# │ 🗺 Globals           │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ ⌨  Commands          │
# ╰──────────────────────╯

# Default command (when no arguments are given)
# NOTE: The "default" command should always be present.
command_default() {
  echon "• Usage: $text_bi$0$text_noitalic [COMMAND [args]]$text_normal."
  echon "• Define your own commands in ${text_bi}${BASH_SOURCE[0]}$text_normal"
  echon "• Delegate to subcommands: ${text_bold}subcommand [COMMAND [args]]${text_normal}."
  echon
  echon "Examples (${text_bold}subcommand${text_normal} does not produce [LOG]):"
  set -x
  "$0" print_commands "run" # Print and grep available commands
  set +x
  subcommand print_commands "print"

  echo
  echon "The example command will teach you about set_args."
  echon "(Open ${text_bi}${BASH_SOURCE[0]}${text_normal} to see how the example command itself uses set_args.)"
  set -x
  "$0" example --help
  set +x

  return 0
}

command_example() {
  set_args "--required= --defaulted=nope --optional --help" "$@"
  eval "$get_args" # Generates local variables

  show_ariable required
  show_ariable defaulted
  show_ariable required

  if [[ "$defaulted" == "nope" ]]; then
    echon "${text_bg}✔ Required value --required=$required$text_normal"
    echon "${text_br}✖ Default value --defaulted unchanged.$text_normal"
    echo "${text_bc}${text_invert}TODO${text_normal}${text_cyan} Change ${text_normal}$text_bold--defaulted${text_cyan} in the call to the example command."
  else
    echon "${text_bg}✔ Required value --required=$required$text_normal"
    echon "${text_bg}✔ Default value changed to --defaulted=$defaulted$text_normal"
    echok "${text_bg}☺  You are now ready to create your own commands"
  fi
}

# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 𝑓 Functional         │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 🖹 Help strings       │
# ╰──────────────────────╯

declare example_help_string
example_help_string="$(
  cat <<EOF
Illustrates the use of set_args to specify and ready arguments

COMMAND

  ${text_italic}$0${text_normal} example

  The example command teaches you how to read arguments with set_args.
  For more information, see ${text_blb}${text_italic}~/dotfiles/doc/setargs.txt${text_normal}.

  The example command accepts four parameters that illustrate how set_args works.

PARAMETERS

  --required=         Required parameters are indicated by a trailing =.

  --defaulted=false   Defaulted parameters will always be defined, taking the
                      default value if no value is given explicitly.

  --optional          Optional parameters will only be defined if given
                      explicitly as --optional or --optional=value. Test for
                      existence afterwards with:

                          [[ -v optional ]].

  --help              When parameter --help is provided, variable \$help is set
                      to an expression taken by "sed -e" that colourizes this
                      very help string. Additionally, set_args will print how
                      the command arguments are interpreted for the current
                      invocation. You should see it above (stderr)!

${text_underline}ARGUMENTS${text_normal}

  --required=value    Explicitly sets bash variable required=value.

  --defaulted value:  You can pass name and value separately by placing them
                      immediately after each other. Same as --defaulted=value.

  value1 value2:      Positional arguments are matched to required and defaulted
                      parameters in the order in which the parameter names are
                      specified in the parameter string. Parameters that are
                      matched in other ways are not considered. You can inspect
                      the behaviour by passing --help (see above).
                      ${text_italic}Here:${text_normal} same as --required=value1 --defaulted=value2.

${text_bc}${text_invert}TODO${text_normal}${text_cyan} Remove ${text_normal}--help${text_cyan} when calling $text_normal ${text_bi}"\$0"$text_noitalic example$text_normal ${text_cyan}from the default command in$text_normal $text_bi${BASH_SOURCE[0]}$text_normal ${text_cyan}Fix the error.$text_normal
${text_dim}${text_cyan}Hint: The parameter string of the example command defines expected parameters${text_normal}
EOF
)"

# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
# ⌂ Transition to provided command
subcommand "${@}"
# ╭──────────────────────╮
# │ 🕮  Documentation     │
# ╰──────────────────────╯
