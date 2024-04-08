#!/usr/bin/env bash

# version 0.0.0

# shellcheck disable=all

declare -gr dotfiles="${DOTFILES:-"$HOME/dotfiles"}"; # TOKEN_DOTFILES_GLOBAL
declare -gA _sourced_files=( ["runscript"]="" );
declare -gr this_location="/tmp"; # Set this to auto-symlink when in wrong place
source "$dotfiles/scripts/boilerplate.sh" "${BASH_SOURCE[0]}" "$@";
satisfy_version "$dotfiles/scripts/boilerplate.sh";

# ┌────────────────────────┐
# │ Info ❔                │
# └────────────────────────┘

# ❗This is a template file. Remove this notice after copying.

# Define commands:
# │   command_name() {}
# Call commands:
# │   "$0" name [args]  # With logging
# │   subcommand name [args]     # Without logging
# Deactivate automatic exit on error:
# │   set +e;
# │   ...
# │   set -e;

# ┌────────────────────────┐
# │ Config ⚙               │
# └────────────────────────┘

# Show loaded files on console
#_run_config["log_loads"]=1;

# Reduce error printing:
_run_config[error_frames]=2;

# ┌────────────────────────┐
# │ Includes               │
# └────────────────────────┘

#source ~/dotfiles/scripts/git_utils.sh;

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0;
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;
load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;
load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
load_version "$dotfiles/scripts/utils.sh" 0.0.0;

# ┌────────────────────────┐
# │ Constants              │
# └────────────────────────┘

# Constants which are shared between commands

declare -r this_location=""; # Intended location, default input for link_this

# ┌────────────────────────┐
# │ Commands               │
# └────────────────────────┘

# ❕Prefix commands with "command_" so that they are recognized by runscript.
# ❕The default command should always be given.

# Default command (when no arguments are given)
command_default()
{
  echon "• Usage: $text_bi$0$text_noitalic [COMMAND [args]]$text_normal.";
  echon "• Define your own commands in ${text_bi}$BASH_SOURCE$text_normal";
  echon "• Delegate to subcommands: ${text_bold}subcommand [COMMAND [args]]${text_normal}.";
  echon
  echon "Examples (${text_bold}subcommand${text_normal} does not produce [LOG]):"
  set -x;
  "$0" print_commands "run";  # Print and grep available commands
  set +x;
  subcommand print_commands "print";

  echo
  echon "The example command will teach you about set_args.";
  echon "(Open ${text_bi}$BASH_SOURCE${text_normal} to see how the example command itself uses set_args.)";
  set -x;
  "$0" example --help;
  set +x;

  return 0;
}

command_example()
{
  set_args "--required= --defaulted=false --optional --help" "$@";
  eval "$get_args"; # Generates the local variables

  if [[ "$defaulted" == "false" ]]; then
    echoi "${text_bg}✔ Required value --required=$required$text_normal";
    echoi "${text_br}✖ Default value --defaulted unchanged.$text_normal";
    echo "${text_bc}${text_invert}TODO${text_normal}${text_cyan} Change ${text_normal}$text_bold--defaulted${text_cyan} in the call to the example command.";
  else
    echoi "${text_bg}✔ Required value --required=$required$text_normal";
    echoi "${text_bg}✔ Default value changed to --defaulted=$defaulted$text_normal";
    echok "${text_bg}☺  You are now ready to create your own commands";
  fi
}

# ┌────────────────────────┐
# │ Helpers                │
# └────────────────────────┘

# ┌────────────────────────┐
# │ Stateless              │
# └────────────────────────┘

# ┌────────────────────────┐
# │ Help strings           │
# └────────────────────────┘

# ❗
# Only provide a help string when set_args is used: Bash completion will call
# the command with --completion. set_args catches this and calls exit before
# anything else is executed.

  declare -r example_help_string="$(cat << EOF
Illustrates the use of set_args to specify and ready arguments

${text_underline}COMMAND${text_normal} ${text_italic}$0${text_normal} ${text_bold}example${text_normal}

  The example command teaches you how to read arguments with set_args/get_args.
  For more information, see ${text_blb}${text_italic}~/dotfiles/doc/setargs.txt${text_normal}.

  The example command accepts four parameters that illustrate how set_args works.

${text_underline}PARAMETERS${text_normal}

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

${text_bc}${text_invert}TODO${text_normal}${text_cyan} Remove ${text_normal}--help${text_cyan} when calling $text_normal ${text_bi}"\$0"$text_noitalic example$text_normal ${text_cyan}from the default command in$text_normal $text_bi$BASH_SOURCE$text_normal ${text_cyan}Fix the error.$text_normal
${text_dim}${text_cyan}Hint: The parameter string of the example command defines expected parameters${text_normal}
EOF
  )";

# ┌────────────────────────┐
# │ Boilerplate            │
# └────────────────────────┘

# Transition to provided command
subcommand "${@}";
