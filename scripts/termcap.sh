#!/usr/bin/env bash

# version 0.0.0

# shellcheck disable=2155

if [[ -v _sourced_files["termcap"] ]]; then
  return 0;
fi
_sourced_files["termcap"]="";

declare -r user_colour=$'\x1b[38;2;255;144;192m';
# declare -r user_colour=$'\x1b[38;2;255;170;102m';
#declare -r user_colour=$'\x1b[38;2;0;128;255m';

# TODO test this:
#   ESC[ ... 38;2;<r>;<g>;<b> ... m   Select RGB foreground color
#   ESC[ ... 48;2;<r>;<g>;<b> ... m   Select RGB background color
#   ESC[ ... 38;5;<i> ... m       Select indexed foreground color
#   ESC[ ... 48;5;<i> ... m       Select indexed background color
# echo -en "\x1b[48;2;255;0;128m"

# Reset everything
readonly text_normal="$(tput sgr0)";

# Modify
readonly text_blink="$(tput blink)";
readonly text_bold="$(tput bold)";
readonly text_dim="$(tput dim)";
readonly text_invert="$(tput rev)";
readonly text_italic="$(tput sitm)";
readonly text_standout="$(tput smso)";  # Invert or bold
readonly text_subscript="$(tput ssubm)";
readonly text_underline="$(tput smul)";

# Undo
readonly text_noitalic="$(tput ritm)";
readonly text_nostandout="$(tput rmso)";
readonly text_nosubscript="$(tput rsubm)";
readonly text_nounderline="$(tput rmul)";

# Foreground Color
#declare text_user=$'\x1b[38;2;240;192;144m';
#declare text_user=$'\x1b[38;2;102;153;255m';
#rgb(240, 192, 144)
readonly text_blue="$(tput setaf 4)";
readonly text_brightblack="$(tput setaf 8)";
readonly text_green="$(tput setaf 2)";
readonly text_lightblue="$(tput setaf 12)";
readonly text_lightgreen="$(tput setaf 10)";
readonly text_lightorange="$(tput setaf 208)";
readonly text_lightred="$(tput setaf 9)";
readonly text_lightyellow="$(tput setaf 11)";
readonly text_orange="$(tput setaf 202)";
readonly text_red="$(tput setaf 1)";
readonly text_white="$(tput setaf 7)";
readonly text_brightwhite="$(tput setaf 15)";
readonly text_yellow="$(tput setaf 3)";
readonly text_cyan="$(tput setaf 6)";
readonly text_lightcyan="$(tput setaf 14)";
readonly text_purple="$(tput setaf 5)";
readonly text_lightpurple="$(tput setaf 13)";
readonly text_pink="$(tput setaf 201)";
readonly text_lightpink="$(tput setaf 213)";

# Background Color
readonly background_black="$(tput setab 0)";
readonly background_brightblack="$(tput setab 8)";
readonly background_red="$(tput setab 1)";

# Combine level 1
# Blink > Invert > bold > dim > italic > light > underline > colour
declare -r text_BI="$text_blink$text_invert";
declare -r text_blpi="$text_bold$text_lightpink";
declare -r text_bpi="$text_bold$text_pink";
readonly text_Ib="$text_invert$text_bold";
readonly text_ib="$text_italic$text_blue";
readonly text_bb="$text_bold$text_blue";
readonly text_bbb="$text_bold$text_brightblack";
readonly text_bc="$text_bold$text_cyan";
readonly text_bd="$text_bold$text_dim";
readonly text_bg="$text_bold$text_green";
readonly text_bi="$text_bold$text_italic";
readonly text_blb="$text_bold$text_lightblue";
readonly text_blc="$text_bold$text_lightcyan";
readonly text_blg="$text_bold$text_lightgreen";
readonly text_blo="$text_bold$text_lightorange";
readonly text_blp="$text_bold$text_lightpurple";
readonly text_blr="$text_bold$text_lightred";
readonly text_bly="$text_bold$text_lightyellow";
readonly text_bo="$text_bold$text_orange";
readonly text_bp="$text_bold$text_purple";
readonly text_br="$text_bold$text_red";
readonly text_bs="$text_bold$text_standout";
readonly text_bw="$text_bold$text_brightwhite";
readonly text_by="$text_bold$text_yellow";
readonly text_di="$text_dim$text_italic";

# Combine level 2
declare -r text_bdilb="$text_lightblue$text_di";
declare -r text_bdiw="$text_bw$text_di";
declare -r text_bdy="$text_bd$text_yellow";
declare -r text_bub="${text_bb}${text_underline}";

# User styles
declare -r text_user="$text_bold$user_colour";
declare -r text_user_soft="$text_dim$user_colour";
declare -r text_user_hard="$text_Ib$user_colour";

# Control
#readonly term_last_line="$(tput ll)"; # Doesnt work Ubuntu 22
readonly term_delete_line="$(tput dl1)";
readonly term_front="$(tput cr)";
# Doesnt work Ubuntu 22 (does it?) TODO might have beed a bug. try again
readonly term_last_line_front="$(tput cup "$(tput lines)" 0)";
readonly term_restore_cursor="$(tput rc)";
readonly term_save_cursor="$(tput sc)";
readonly term_scroll_backward="$(tput ri)";
readonly term_scroll_forward="$(tput ind)";
readonly term_up3="$(tput cuu 3)";
readonly term_up="$(tput cuu1)";
readonly text_left1="$(tput cub1)";
readonly term_erase_forward="$(tput ed)";

readonly text_left2="$text_left1$text_left1";
readonly term_previous="${term_up}$term_front";
