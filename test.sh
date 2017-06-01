#!/usr/bin/env bash

. sibyl.sh sourced

# Prevent linter warnings by declaring variables 
# sourced from main script
declare magenta
declare red
declare green
declare normal

# Testing functions

passes=0
fails=0

function test_ {
  echo
  echo -e "${magenta}TEST${normal} $1"
}

function pass {
  echo -e "${green}PASS${normal} $1"
  passes=$(( passes + 1 ))
}

function fail {
  echo -e "${red}FAIL${normal} $1"
  fails=$(( fails + 1 ))
}

# Assertion functions

function assert_equal {
  if [ "$1" == "$2" ]; then
    pass "$1"
  else
    fail "$1 != $2"
  fi
}

function assert_no_diff {
  diff_output=$(diff "$1" "$2")
  diff_status=$?
  if [ "$diff_status" == 0 ]; then
    pass "$1"
  else
    fail "$1"
    echo "$diff_output" | indent
  fi
}

# Function tests

test_ "name"
assert_equal "$(name "file://folder/subfolder")" "file-folder-subfolder-4329642ba3"
assert_equal "$(name "github://foo/bar/folder/subFOLDER")" "github-foo-bar-folder-subfolder-a022134984"
assert_equal "$(name "file://home/user/Esperança-vôo-avião")" "file-home-user-esperanca-voo-aviao-2169b6d973"

# Iterate over test folders

for dir in tests/*/
do
  test_ "$(basename "$dir")"
  cd "$dir"

  # Compile
  compile

  # Test that files are as expected
  for file in *.expected; do
    assert_no_diff "${file%.*}" "$file"
  done

  cd ../..
done

# Overall stats

info "Passed: ${green}$passes${normal} Failed: ${red}$fails${normal}"

exit $fails
