#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
# shellcheck source=../lib/symlink_utils.sh
source "$SCRIPT_DIR/../lib/symlink_utils.sh"

warnings=()
LogWarning() {
  warnings+=("$1")
}

ShowPathInfo() {
  :
}

ConfirmOverwrite() {
  return 1
}

failures=0

assert_symlink_points_to() {
  local link_path=$1
  local expected_target=$2

  if [ ! -L "$link_path" ]; then
    echo "Expected symlink but got non-symlink: $link_path"
    return 1
  fi

  local actual_target
  actual_target=$(readlink "$link_path")
  if [ "$actual_target" != "$expected_target" ]; then
    echo "Expected $link_path -> $expected_target, got -> $actual_target"
    return 1
  fi
}

assert_warning_contains() {
  local expected=$1
  local warning
  for warning in "${warnings[@]:-}"; do
    if [[ "$warning" == *"$expected"* ]]; then
      return 0
    fi
  done
  echo "Expected warning containing: $expected"
  return 1
}

run_test() {
  local name=$1
  shift

  if "$@"; then
    echo "PASS: $name"
  else
    echo "FAIL: $name"
    failures=$((failures + 1))
  fi
}

test_trailing_slash_creates_inside_directory_and_parents() {
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN

  local target="$tmp/src/config/file.txt"
  mkdir -p "$(dirname "$target")"
  : > "$target"

  local link_pos="$tmp/out/a/b/"
  CreateSymbolicLink 0 "$target" "$link_pos" > /dev/null

  local expected_link="$tmp/out/a/b/file.txt"
  assert_symlink_points_to "$expected_link" "$target"
}

test_force_zero_skips_when_explicit_link_path_is_existing_directory() {
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN

  local target="$tmp/src/target.conf"
  mkdir -p "$(dirname "$target")"
  : > "$target"

  local explicit_link="$tmp/links"
  mkdir -p "$explicit_link"

  warnings=()
  CreateSymbolicLink 0 "$target" "$explicit_link" > /dev/null

  [ -d "$explicit_link" ]
  [ ! -L "$explicit_link" ]
  assert_warning_contains "exists, skip linking"
}

test_explicit_link_path_creates_parent_directories() {
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN

  local target="$tmp/src/payload"
  mkdir -p "$(dirname "$target")"
  : > "$target"

  local explicit_link="$tmp/nested/deep/my_link"
  CreateSymbolicLink 0 "$target" "$explicit_link" > /dev/null

  assert_symlink_points_to "$explicit_link" "$target"
}

test_force_zero_skips_when_explicit_link_path_exists() {
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN

  local target="$tmp/src/new_target"
  mkdir -p "$(dirname "$target")"
  : > "$target"

  local explicit_link="$tmp/existing_link"
  echo "old" > "$explicit_link"

  warnings=()
  CreateSymbolicLink 0 "$target" "$explicit_link" > /dev/null

  [ ! -L "$explicit_link" ]
  grep -q "old" "$explicit_link"
  assert_warning_contains "exists, skip linking"
}

test_force_zero_skips_when_resolved_link_already_exists_in_directory_mode() {
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN

  local old_target="$tmp/src/old_target"
  local new_target="$tmp/src/new_target"
  mkdir -p "$(dirname "$old_target")"
  : > "$old_target"
  : > "$new_target"

  local link_dir="$tmp/link_dir"
  mkdir -p "$link_dir"
  ln -s "$old_target" "$link_dir/new_target"

  warnings=()
  CreateSymbolicLink 0 "$new_target" "$link_dir/" > /dev/null

  assert_symlink_points_to "$link_dir/new_target" "$old_target"
  assert_warning_contains "exists, skip linking"
}

test_force_zero_no_warning_when_existing_symlink_already_points_to_target() {
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN

  local target="$tmp/src/new_target"
  mkdir -p "$(dirname "$target")"
  : > "$target"

  local explicit_link="$tmp/already_correct_link"
  ln -s "$target" "$explicit_link"

  warnings=()
  CreateSymbolicLink 0 "$target" "$explicit_link" > /dev/null

  assert_symlink_points_to "$explicit_link" "$target"
  [ "${#warnings[@]}" -eq 0 ]
}

test_force_zero_overwrites_existing_path_when_confirmed() {
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN

  local target="$tmp/src/replacement"
  mkdir -p "$(dirname "$target")"
  : > "$target"

  local explicit_link="$tmp/my_link"
  echo "legacy" > "$explicit_link"

  ConfirmOverwrite() {
    return 0
  }

  CreateSymbolicLink 0 "$target" "$explicit_link" > /dev/null

  ConfirmOverwrite() {
    return 1
  }

  assert_symlink_points_to "$explicit_link" "$target"
}

test_force_one_replaces_existing_explicit_path() {
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN

  local target="$tmp/src/replacement"
  mkdir -p "$(dirname "$target")"
  : > "$target"

  local explicit_link="$tmp/my_link"
  echo "legacy" > "$explicit_link"

  CreateSymbolicLink 1 "$target" "$explicit_link" > /dev/null

  assert_symlink_points_to "$explicit_link" "$target"
}

test_force_one_handles_directory_mode() {
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN

  local target="$tmp/src/new_file"
  mkdir -p "$(dirname "$target")"
  : > "$target"

  local link_dir="$tmp/force_dir/"
  CreateSymbolicLink 1 "$target" "$link_dir" > /dev/null

  assert_symlink_points_to "$tmp/force_dir/new_file" "$target"
}

test_force_one_replaces_existing_directory_at_explicit_path() {
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN

  local target="$tmp/src/new_file"
  mkdir -p "$(dirname "$target")"
  : > "$target"

  local explicit_link="$tmp/existing_dir"
  mkdir -p "$explicit_link/subdir"
  : > "$explicit_link/subdir/legacy"

  CreateSymbolicLink 1 "$target" "$explicit_link" > /dev/null

  assert_symlink_points_to "$explicit_link" "$target"
}

run_test "trailing slash creates inside directory and parents" test_trailing_slash_creates_inside_directory_and_parents
run_test "force=0 skips existing directory at explicit path" test_force_zero_skips_when_explicit_link_path_is_existing_directory
run_test "explicit link path creates parent directories" test_explicit_link_path_creates_parent_directories
run_test "force=0 skips existing explicit path" test_force_zero_skips_when_explicit_link_path_exists
run_test "force=0 skips existing resolved link in directory mode" test_force_zero_skips_when_resolved_link_already_exists_in_directory_mode
run_test "force=0 no warning for already-correct symlink" test_force_zero_no_warning_when_existing_symlink_already_points_to_target
run_test "force=0 overwrites when user confirms" test_force_zero_overwrites_existing_path_when_confirmed
run_test "force=1 replaces existing explicit path" test_force_one_replaces_existing_explicit_path
run_test "force=1 works in directory mode" test_force_one_handles_directory_mode
run_test "force=1 replaces existing directory at explicit path" test_force_one_replaces_existing_directory_at_explicit_path

if [ "$failures" -gt 0 ]; then
  echo
  echo "Test failures: $failures"
  exit 1
fi

echo
echo "All tests passed"
