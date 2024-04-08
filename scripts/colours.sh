#!/usr/bin/env bash

# version 0.0.0

# Provide functions to generate a syntax highlighting colour palette from a base
# colour, as decribed in dotfiles/data/syntax.txt.

# Ensuring version even if included already
#load_version "$dotfiles/scripts/version.sh" 0.0.0;
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;
#load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
#load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
#load_version "$dotfiles/scripts/utils.sh" 0.0.0;

saturate_medium()
{
  errchot "Implement";

  # Transform to 75% Saturation
  declare r="${1:?Missing red}";
  declare g="${2:?Missing green}";
  declare b="${3:?Missing blue}";
}

saturate_light()
{
  errchot "Implement";
}

saturate_dark()
{
  errchot "Implement";
}

saturate_colour()
{
  errchot "Implement";
}

#######################################
# Helpers
#######################################

saturate_75()
{
  # Desaturate by 25%
  printf '%d' "$(( (128 + 3 * $1) / 4 ))";
}

saturate_50()
{
  # Desaturate by 25%
  printf '%d' "$(( (128 + $1) / 2 ))";
}

