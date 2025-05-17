#!/bin/bash


function remove_untracked_files() {
    git ls-files --other --exclude-standard | xargs rm -rf
}

function pretty_git_log() {
    local HASH="%C(bold green)%h%C(reset)"
    local DATE="%C(bold black)%aD%C(reset) %C(bold black)(%ar)%C(reset)"
    local REFS="%C(bold blue)%d%C(reset)%n"
    local AUTHOR="%an%C(reset)"
    local SUBJECT="%C(black)%s%C(reset) %C(black)"
    local FIRST_LINE="$HASH - $DATE $REFS"
    local SECOND_LINE="$SUBJECT - $AUTHOR"

    git log --graph --abbrev-commit --decorate --all --pretty="format:$FIRST_LINE$SECOND_LINE%n" $*
}
