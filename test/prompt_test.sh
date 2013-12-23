# Navigate to test directory
ORIG_PWD=$PWD
TEST_DIR=$PWD/test

# Move any test .git directories back to dotgit
make move-git-to-dotgit > /dev/null

fixture_dir() {
  TMP_DIR=$(mktemp -d)
  cp -r "$TEST_DIR"/test-files/$1/* $TMP_DIR
  cd $TMP_DIR
  test -d dotgit && mv dotgit .git
}

fixture_git_init() {
  TMP_DIR=$(mktemp -d)
  cd $TMP_DIR
  git init 1> /dev/null
}

# Load in bash_prompt
. .bash_prompt

# is_on_git

  # in a git directory
  fixture_dir 'git'

    # has an exit code of 0
    is_on_git || echo '`is_on_git`; $? != 0 in git directory' 1>&2

  # in a non-git directory
  fixture_dir 'non-git'

    # has a non-zero exit code
    ! is_on_git || echo '`is_on_git`; $? == 0 in non-git directory' 1>&2

  # in a git-init'd directory
  # DEV: This is an edge case test discovered in 0.10.0
  # DEV: Unfortunately, I cannot upgrade to the latest version of Git so I run `git init` to get Travis CI to pass
  # fixture_dir 'git-init'
  fixture_git_init

    # has an exit code of 0
    is_on_git || echo '`is_on_git`; $? != 0 in git-init directory' 1>&2

# get_git_branch

  # on a `master` branch
  fixture_dir 'branch-master'

    # is `master`
    test "$(get_git_branch)" = "master" || echo '`get_git_branch` !== `master` on a `master` branch' 1>&2

  # on `dev/test` branch
  fixture_dir 'branch-dev'

    # is `dev/test`
    test "$(get_git_branch)" = "dev/test" || echo '`get_git_branch` !== `dev/test` on `dev/test` branch' 1>&2

  # off of a branch
  fixture_dir 'branch-non'

    # is 'no branch'
    test "$(get_git_branch)" = "(no branch)" || echo '`get_git_branch` !== `(no branch)` off of a branch' 1>&2

  # in a git-init'd directory
  # DEV: This is an edge case test discovered in 0.10.0
  fixture_git_init

    # is `master`
    test "$(get_git_branch)" = "master" || echo '`get_git_branch` !== `master` in a `git-init` directory' 1>&2

# git_status

  # on a clean and synced branch
  fixture_dir 'clean-synced'

    # is nothing
    test "$(get_git_status)" = "" || echo '`get_git_status` !== "" on a clean and synced branch' 1>&2

  # on a dirty branch
  fixture_dir 'dirty'

    # is an asterisk
    test "$(get_git_status)" = "*" || echo '`get_git_status` !== "*" on a dirty branch' 1>&2

  # on an unpushed branch
  # DEV: This covers new branches (for now)
  fixture_dir 'unpushed'

    # is an empty up triangle
    test "$(get_git_status)" = "△" || echo '`get_git_status` !== "△" on an unpushed branch' 1>&2

  # on a dirty and unpushed branch
  fixture_dir 'dirty-unpushed'

    # is a filled up triangle
    test "$(get_git_status)" = "▲" || echo '`get_git_status` !== "▲" on a dirty and unpushed branch' 1>&2

  # on an unpulled branch
  fixture_dir 'unpulled'

    # is an empty down triangle
    test "$(get_git_status)" = "▽" || echo '`get_git_status` !== "▽" on an unpulled branch' 1>&2

  # on a dirty and unpulled branch
  fixture_dir 'dirty-unpulled'

    # is an filled down triangle
    test "$(get_git_status)" = "▼" || echo '`get_git_status` !== "▼" on a dirty unpulled branch' 1>&2

  # on an unpushed and an unpulled branch
  fixture_dir 'unpushed-unpulled'

    # is an empty hexagon
    test "$(get_git_status)" = "⬡" || echo '`get_git_status` !== "⬡" on an unpushed and unpulled branch' 1>&2

  # on a dirty, unpushed, and unpulled branch
  fixture_dir 'dirty-unpushed-unpulled'

    # is an filled hexagon
    test "$(get_git_status)" = "⬢" || echo '`get_git_status` !== "⬢" on a dirty, unpushed, and unpulled branch' 1>&2

# sexy-bash-prompt
cd $ORIG_PWD

  # when run as a script
  prompt_output="$(bash --norc --noprofile -i -c '. .bash_prompt')"

    # does not have any output
    test ${#prompt_output} -eq 0 || echo '`prompt_output` did not have length 0' 1>&2

# get_prompt_symbol
cd $ORIG_PWD

  # with a normal user
  bash_symbol="$(bash --norc --noprofile -i -c '. .bash_prompt; echo $(get_prompt_symbol)')"

    # is $
    test "$bash_symbol" = "$" || echo '`get_prompt_symbol` !== "$" for a normal user' 1>&2

  # with root
  bash_symbol="$(sudo bash --norc --noprofile -i -c '. .bash_prompt; echo $(get_prompt_symbol)')"

    # is #
    test "$bash_symbol" = "#" || echo '`get_prompt_symbol` !== "#" for root' 1>&2

# prompt colors
esc=$'\033'

  # in a 256 color terminal
  cd $ORIG_PWD
  TERM=xterm-256color . .bash_prompt
  fixture_dir 'branch-master'

    # Deprecated color by color test, not used because requires double maintenance
    # echo "$(TERM=xterm-256color tput bold)$(TERM=xterm-256color tput setaf 27)" | copy
    # test "$prompt_user_color" = "$esc[1m$esc[38;5;27m" || echo '`prompt_user_color` is not bold blue (256)' 1>&2

    # uses 256 color pallete
    expected_prompt='\['$esc'[1m'$esc'[38;5;27m\]\u\['$esc'(B'$esc'[m\] \['$esc'[1m'$esc'[37m\]at\['$esc'(B'$esc'[m\] \['$esc'[1m'$esc'[38;5;39m\]\h\['$esc'(B'$esc'[m\] \['$esc'[1m'$esc'[37m\]in\['$esc'(B'$esc'[m\] \['$esc'[1m'$esc'[38;5;76m\]\w\['$esc'(B'$esc'[m\]$( is_on_git &&   echo -n " \['$esc'[1m'$esc'[37m\]on\['$esc'(B'$esc'[m\] " &&   echo -n "\['$esc'[1m'$esc'[38;5;154m\]$(get_git_info)" &&   echo -n "\['$esc'[1m'$esc'[37m\]")\n\['$esc'(B'$esc'[m\]\['$esc'[1m\]$ \['$esc'(B'$esc'[m\]'

    # DEV: To debug, use a diff tool. Don't stare at the code.
    # http://www.diffchecker.com/diff
    # echo "$PS1"
    # echo "$expected_prompt"
    # make test | copy
    test "$PS1" = "$expected_prompt" || echo '`PS1` is not as expected (256)' 1>&2

  # in an 8 color terminal
  cd $ORIG_PWD
  TERM=xterm . .bash_prompt
  fixture_dir 'branch-master'

    # uses 8 color pallete
    # echo "$(TERM=xterm tput bold)$(TERM=xterm tput setaf 4)" | copy
    expected_prompt='\['$esc'[1m'$esc'[34m\]\u\['$esc'(B'$esc'[m\] \['$esc'[1m'$esc'[37m\]at\['$esc'(B'$esc'[m\] \['$esc'[1m'$esc'[36m\]\h\['$esc'(B'$esc'[m\] \['$esc'[1m'$esc'[37m\]in\['$esc'(B'$esc'[m\] \['$esc'[1m'$esc'[32m\]\w\['$esc'(B'$esc'[m\]$( is_on_git &&   echo -n " \['$esc'[1m'$esc'[37m\]on\['$esc'(B'$esc'[m\] " &&   echo -n "\['$esc'[1m'$esc'[33m\]$(get_git_info)" &&   echo -n "\['$esc'[1m'$esc'[37m\]")\n\['$esc'(B'$esc'[m\]\['$esc'[1m\]$ \['$esc'(B'$esc'[m\]'
    test "$PS1" = "$expected_prompt" || echo '`PS1` is not as expected (8)' 1>&2

  # in an ANSI terminal
  cd $ORIG_PWD
  TERM="" . .bash_prompt
  fixture_dir 'branch-master'

    # uses ANSI colors
    test "$prompt_user_color" = "\033[1;34m" || echo '`prompt_user_color` is not blue (ANSI)' 1>&2
    test "$prompt_preposition_color" = "\033[1;37m" || echo '`prompt_preposition_color` is not white (ANSI)' 1>&2
    test "$prompt_device_color" = "\033[1;36m" || echo '`prompt_device_color` is not cyan (ANSI)' 1>&2
    test "$prompt_dir_color" = "\033[1;32m" || echo '`prompt_dir_color` is not green (ANSI)' 1>&2
    test "$prompt_git_status_color" = "\033[1;33m" || echo '`prompt_git_status_color` is not yellow (ANSI)' 1>&2
    test "$prompt_symbol_color" = "" || echo '`prompt_symbol_color` is not normal (ANSI)' 1>&2

  # when overridden

    # use the new colors