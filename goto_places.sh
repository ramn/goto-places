#!/bin/bash

# Should be sourced into .bashrc

declare -A my_goto_places
my_goto_places["a_project"]="/path/to/a_project"

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
