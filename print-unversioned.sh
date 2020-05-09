#!/usr/bin/env bash

set -eu

# checks for git, subversion, or mercurial directories
dir_is_versioned() {
  
  test -d "$1/.git" || test -d "$1/.svn" || test -d "$1/.hg" 
}

dir_contains_files() {

  test -n "$(find "$1" -maxdepth 1 -type f -not -wholename "$1" -print)"
}

print_subdirs() {

  find "$1" -maxdepth 1 -type d -not -wholename "$1" -print
}

# print dirs not under vcs
# in case dir has children under vcs, recursively check
#
# for given dir:
# - if no children are under vcs print given dir
# - if some children are under vcs, print those not
print_unversioned_descendants() {

  dir_is_versioned "$1" && return 0

  if dir_contains_files "$1"; then
    echo "$1"
    return 0
  fi

  SUBDIRS="$(print_subdirs "$1")"

  [ -z "$SUBDIRS" ] && return 0

  UNVERSIONED=""
  while read -r DIR; do
    SUBUNVERSIONED="$(print_unversioned_descendants "$DIR")"
    if [ -n "$SUBUNVERSIONED" ]; then
      UNVERSIONED="${UNVERSIONED}${SUBUNVERSIONED}"$'\n'
    fi
  done <<< "$SUBDIRS"

  if [ "$UNVERSIONED" = "$SUBDIRS" ]; then
    echo "$1"
  else
    echo -n "$UNVERSIONED"
  fi

  return 0
}

[ -n "$1" ] && ROOT="$1" || ROOT="."
print_unversioned_descendants "$ROOT"

