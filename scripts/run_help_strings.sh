#!/usr/bin/env bash

# version 0.0.0

declare -r tag="runscript_help"
if [[ -v _sourced_files["$tag"] ]]; then
  return 0
fi
_sourced_files["$tag"]=""

# TODO Version at all? check versions?
# TODO load_version to source them?

# Help string implementation and help strings for predefined commands.
#
# Combines help strings from the predefined help command with --help parameters
# from set_args to provide help semi-automatically.

# ┌────────────────────────┐
# │ Helper functions       │
# └────────────────────────┘

# TODO Move this to a proper location.
# Show help string in the surrounding context. Use after set_args to display
# help if --help was provided.
# See also: scritps/setargs.sh
#           doc/setargs.txt
#
# This function expects the variable named "help" and a help string to exist, so
# use with care.
#
# Use like so by specifying --help AND providing a help-string:
#
#     myCommand_help_string="Example string";
#     command_myCommand()
#     {
#         set_args "--variables=val --help" "$@";
#         eval "$get_args";                             # Calls provide_help
#     }
provide_help() {
  declare caller_func="${FUNCNAME[1]}"

  # Sanity check. Remove check if this is intended in the future.
  if [[ "$caller_func" != command_* ]]; then
    errchow "Help is meant only for runscript commands at the moment"
    errchou "But we are making an exception now because we want to use it anyway"
  fi

  # Combine help-string from predefined help command with the --help expresion
  # from set_args.
  declare var="${caller_func#command_}_help_string"
  if [[ -v "$var" ]]; then
    declare -n str="$var"
  else
    declare str="${text_dim}(missing help string)${text_normal}"
  fi

  # TODO When help info line is output together with the helpstring variable,
  # we can page them together. Currently that is not possible.
  #  if >/dev/null 2>&1 batcat --version; then
  #    sed -e "$help" <<< "$str" | batcat --plain --paging=auto;
  #  else
  #    sed -e "$help" <<< "$str";
  #  fi

  sed -e "$help" <<<"$str"

  return 0
}

# ┌────────────────────────┐
# │ Help strings           │
# └────────────────────────┘

# TODO Maybe help strings should be read from files? This is starting to appear
# sort of excessive to read every time on script startup. THe colourability is
# nice though.
# FIXME Yeah they should DEFINITELY not fucking hang around here.
declare -g help_help_string link_this_help_string quit_help_string interactive_help_string run_help_string rundir_help_string runscript_help_string function_help_string debug_help_string print_commands_help_string
help_help_string="$(
  cat <<-EOF
	Print help strings from comands.

	Lists commands at the same time, so could be seen as a more porcelain version
	of "print_commands".

	Usage:
	  help [--match=EXPR] [--count=N] [--all] [--help]
	    --count=N
	        Print N lines from each help string. Default 1.
	    --match=EXPR
	        If EXPR is given, the expression is used for
	        print_commands to obtain only matching commands. If no expression is
	        given, all commands are used.
	    --all
	        Consider all commands, including predefined commands which are the
	        same for all instantiations. By default only show additionally
	        specified custom commands.
	    --help
	        Show this help.
	EOF
)"

link_this_help_string="Links a responsible runscript to a selected location

SYNOPSIS

  link_this [--dir=PATH] [--keep]

DESCRIPTION

  Uses the dotfiles deploy command to create symlinks to the run.sh and commands.sh file responsible for exetuting this command. Typical usage would be to naviagate to the target location, and call the desired runscrpt with full path.

EXAMPLE

  /other/project/run.sh link_this [--dir=$$(pwd)]

OPTIONS
  --dir=DIR: Link to DIR instead of working directory.
    Default: this_location=\$this_location (set by commands.sh).
  --keep: Pass --keep to the deploy command. Always keep existing files without
    prompt."

quit_help_string=$'[TODO] Exit runscript
\nThis command is intended for interactive mode (which you cannot leave
otherwise). It is not clear if this is implemented well since the "exit" command
does not go well with error tracing.
\nDefinitely do not use outside of interactive mode at the moment.'

interactive_help_string=$'[TODO] Start script in interactive mode
\nShows available commands and prompts for a selection. Command arguments can be specified separately for each command'

run_help_string=$'Delegate remaining arguments to different runscript
\nProvide path to another (directory containing a) runscript to be executed.'

rundir_help_string=$'Delegate remaining arguments to different runscript (directory only)
\nProvide path to another directory containing a runscript to be executed.'

runscript_help_string=$'Delegate remaining arguments to different runscript (file only)
\nProvide path to another runscript to be executed.'

function_help_string="Run bash function
SYNOPSIS
  function --name=FUNC
  function [--git|--progress|--cache|--system] --name=FUNC
DESCRIPTION
  Call bash function --name, passing remaining argv to the function. If you
  want to pass arguments to the functio that match a parameter, e.g.,
  '--help', force them into positional arguments by prepending '--'. To pass
  '--' to the function.
  This command is used to manually invoke the script functions that are not
  available through the 'command_' interface, e.g., for testing.
  other reasons.
OPTIONS
  --name=NAME: Call function NAME.
  --git:      Source git helpers script.
  --progress: Source progress helpers script.
  --cache:    Source cache helpers script.
  --system:   Source system helpers script."

debug_help_string=$'Run arguments as command + args with set -vx
\nProbably not very helpful now that the runscript is quite busy with code.'

print_commands_help_string=$'Print list of available commands
\nThis command is also used by bash autocompletion to obtain the list of available
commands.
\nUsage:
  print_commands [EXPR]
    If EXPR is given, filter command list with grep -e EXPR.
    Else print all available commands.'
declare -r help_help_string link_this_help_string quit_help_string interactive_help_string run_help_string rundir_help_string runscript_help_string function_help_string debug_help_string print_commands_help_string
