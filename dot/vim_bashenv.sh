#!/bin/bash

# version 0.0.0

# Vim bash envronment that we use to have aliases from vim

# I hope this allows us to use bash aliases in vim. Remove if not working.
# I dont know what other effects this will have. If something breaks this line
# might be at fault.
# FIXME Consider using functions instead to not have to use this
shopt -s expand_aliases

# shellcheck source=dot/bash_completion
source "$HOME/.bash_completion"
# shellcheck source=dot/bash_aliases.sh
source "$HOME/.bash_aliases.sh"
