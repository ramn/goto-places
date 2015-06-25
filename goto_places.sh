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

function goto-remove() {
  local name="$1"
  if [ -z "$name" ]; then
    echo "Usage: goto-remove <alias>"
  else
    unset my_goto_places["$name"]
  fi
}

function goto-add-current() {
  name="$1"
  dest="$(pwd)"
  if [ -z "$name" ]; then
    echo "Usage: goto-add-current bookmark_name"
  else
    my_goto_places["$name"]="$dest"
    if [ -f "$GOTO_PLACES_DATA" ]; then
      echo "$name $dest" >> $GOTO_PLACES_DATA
    else
      echo "Could not find GOTO_PLACES_DATA file, can't add bookmark"
    fi
  fi
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
complete -o nospace -F _build_completions_for_goto 'goto-remove'
