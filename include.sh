#!/bin/bash

RESUME_URL=$(yq -crM '.links | map(select(.name=="Resume")) | .[].url' data.yaml)
export RESUME_URL
PDF=${RESUME_URL}joehillen-resume.pdf
export PDF

function loop() {
  while read -r line; do
    "$@" "$line"
  done
}

function trim() {
  local s
  local arg
  local left
  local right

  # TODO getopt
  while [[ $1 ]]; do
    case "$1" in
    -l | --left)
      left=true
      ;;
    -r | --right)
      right=true
      ;;
    --)
      shift
      arg="$*"
      break
      ;;
    *)
      arg="$*"
      break
      ;;
    esac
    shift
  done

  if [[ $left != true && $right != true ]]; then
    left=true
    right=true
  fi

  # if no arguments, read from STDIN
  while [[ $arg ]] || IFS=$'\n' read -r s; do
    # XXX: $arg is to avoid defining a function for this block
    [[ $arg ]] && s="$arg"

    # remove leading whitespace characters
    if [[ $left = true ]]; then
      s="${s#"${s%%[![:space:]]*}"}"
    fi

    # remove trailing whitespace characters
    if [[ $right = true ]]; then
      s="${s%"${s##*[![:space:]]}"}"
    fi

    printf '%s\n' "$s"

    [[ $arg ]] && break
  done
}

function get() {
  yq -cMr "try .$1 // empty" data.yaml
}

function edu() {
  get "education.$*"
}

function check() {
  local path="$1"
  ! grep -q null "$path" || {
    echo "$path contains null values"
    exit 1
  }
}
