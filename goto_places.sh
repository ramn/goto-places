#!/bin/bash

# Should be sourced into .bashrc
# Put this in .bashrc:
# export GOTO_PLACES_DATA="/path/to/goto_places.dat"
# . /path/to/goto_places.sh


declare -A my_goto_places

function __load_goto_places() {
  if [[ ! -f "$GOTO_PLACES_DATA" ]]; then
    echo "Can't load goto, no GOTO_PLACES_DATA variable set"
  else
    for key in ${!my_goto_places[@]}
    do
      unset my_goto_places[$key]
    done
    while IFS=' ' read name dest; do
      my_goto_places[$name]="$dest"
    done < "$GOTO_PLACES_DATA"
  fi
}

function goto {
  case $1 in
    show-all-places)
      echo ${!my_goto_places[@]}
      ;;
    help)
      echo "Usage:"
      echo "goto <project> # will cd to that project root dir"
      echo "goto show-all-places # shows all projects goto knows about"
      ;;
    *)
      cd "${my_goto_places[$1]}"
      ;;
  esac
}

function goto-add-current() {
  name="$1"
  dest="$(pwd)"
  if [[ -z "$name" ]]; then
    echo "Usage: goto-add-current bookmark_name"
  else
    my_goto_places["$name"]="$dest"
    if [[ -f "$GOTO_PLACES_DATA" ]]; then
      echo "$name $dest" >> $GOTO_PLACES_DATA
    else
      echo "Could not find GOTO_PLACES_DATA file, can't add bookmark"
    fi
  fi
}

function goto-edit() {
  vim "$GOTO_PLACES_DATA"
  __load_goto_places
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

__load_goto_places
complete -o nospace -F _build_completions_for_goto 'goto'
