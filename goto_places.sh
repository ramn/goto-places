#!/bin/bash

# Should be sourced into .bashrc
# Put this in .bashrc:
# export GOTO_PLACES_DATA="/path/to/goto_places.dat"
# . /path/to/goto_places.sh


declare -A my_goto_places

if [ ! -f "$GOTO_PLACES_DATA" ]; then
  echo "Can't load goto, no GOTO_PLACES_DATA variable set"
else
  while IFS=' ' read name dest; do
    my_goto_places[$name]="$dest"
  done < "$GOTO_PLACES_DATA"
fi

function goto {
  case $1 in
    show-all-places)
      echo ${!my_goto_places[@]}
      ;;
    help)
      echo "Usage: $0 <project> # will cd to that project root dir"
      echo "$0 show-all-places # shows all projects goto knows about"
      ;;
    *)
      cd "${my_goto_places[$1]}"
      ;;
  esac
}

function _build_completions {
  local current_word
  COMPREPLY=()
  current_word=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($(compgen -W "$($1)" -- $current_word))
}

function _build_completions_for_goto {
  _build_completions 'goto show-all-places'
}

complete -o nospace -F _build_completions_for_goto 'goto'
