#!/usr/bin/env bash

# This is the entrypoint to the testing system, written for Baystation12 and
# inspired by Rust's configure system
#
# Warn: this is modified version of run-test.sh that Baystation12 uses, so keep that in mind.
#
# The general structure of the test execution is as follows:
# - find_code:              Look for the project root directory and fail fast if
#                           it can't be found. Assumes that it is in . or ..;
#                           custom locations can be specified in CODEPATH
#                           environment variable.
# - run_all_tests:          Run every test group in sequence.
# - run_xxx_tests:          Run the tests for $xxx, doing any necessary setup
#                           first, including calling find_xxx_deps.
# - find_xxx_deps:          Using need_cmd, ensure that programs needed to run
#                           tests that are part of $xxx are available.
# - need_cmd:               Checks availability of command passed as the single
#                           argument. Fails fast if it's not available.
# - err:                    Prints arguments as text, exits indicating failure.
# - warn:                   Prints arguments as text, indicating a warning
#                           condition.
# - msg:                    Used by all printing, formats text nicely.
# - run_test:               Runs a test. The first argument is the friendly name
#                           of the test. The remaining arguments are the shell
#                           command(s) to run. If a test fails, a global counter
#                           is incremented and a warning is emitted.
# - run_test_fail:          Exactly as run_test, but considers failure of the
#                           command to be a successful test.
# - run_test_ci:            Gates run_test to only run test when being run on a
#                           CI platform. This is used to gate tests that are
#                           destructive in some manner.
# - exec_test:              Called by run_test{,fail}, actually executes the
#                           test and returns its resulti.
# - check_fail:             Called at the end of the run, prints final report
# and sets exit status appropriately.
# !!!!!!!! Instructions for adding tests:
# In general, if you want to add a test, it will probably belong to one of the
# groups that already exists. Add it to the relevant run_xxx_tests function, and
# if it introduces any new dependencies, add them to the check_xxx_deps
# function. Some dependencies are guaranteed to be on CI platforms by outside
# means (like .travis.yml), others will need to be installed by this script.
# You'll see plenty of examples of checking for CI and gating tests on that,
# installing instead of checking when running on CI.
#
# If you are *SURE* you need to add a new test group, you'll want to add it
# first to the case at the end of the file, and then add the run_xxx_tests and
# find_xxx_deps for it, adding things to them as appropriate. Importantly, make
# sure to also call run_xxx_tests from run_all_tests. Make sure also to call
# your find_xxx_deps from run_xxx_tests.
#
# Good luck!
# - xales

# Global counter of failed tests
FAILED=0
# List of names of failed tests
FAILED_BYNAME=()
# Global counter of passed tests
PASSED=0

# Version of Node to install for tgui
NODE_VERSION=4

function msg {
    echo -e "\t\e[34mtest\e[0m: $*"
}

function msg_bad {
    echo -e "\e[31m$*\e[0m"
}

function msg_good {
    echo -e "\e[32m$*\e[0m"
}

function msg_meh {
    echo -e "\e[33m$*\e[0m"
}

function warn {
    msg_meh "WARNING: $*"
}

function err {
    msg_bad "error: $*"
    exit 1
}

function fail {
    warn "test \"$1\" failed: $2"
    ((FAILED++))
    FAILED_BYNAME+=("$1")
}

function need_cmd {
    if command -v $1 >/dev/null 2>&1
    then msg "found '$1'"
    else err "program '$1' is missing, please install it"
    fi
}

function run_test {
    msg "running \"$1\""
    name=$1
    shift
    exec_test "$*"
    ret=$?
    if [[ ret -ne 0 ]]
    then fail "$name" $ret
    else ((PASSED++))
    fi
}

function run_test_fail {
    msg "running(fail) \"$1\""
    name=$1
    shift
    exec_test "$*"
    ret=$?
    if [[ ret -eq 0 ]]
    then fail "$name" $ret
    else ((PASSED++))
    fi
}

function check_fail {
    if [[ $FAILED -ne 0 ]]; then
        for t in "${FAILED_BYNAME[@]}"; do
            msg_bad "TEST FAILED: \"$t\""
        done
        err "$FAILED tests failed"
    else msg_good "$PASSED tests passed"
    fi
}

function exec_test {
    eval "$*"
    ret=$?
    return $ret
}

function find_code_deps {
    need_cmd grep
    need_cmd awk
    need_cmd md5sum
    need_cmd python2
    need_cmd python3
    need_cmd pip
}

function find_byond_deps {
    [[ "$CI" != "true" ]] && need_cmd DreamDaemon
}

function find_code {
    if [[ -z ${CODEPATH+x} ]]; then
        if [[ -d ./code ]]
        then CODEPATH=.
        else if [[ -d ../code ]]
            then CODEPATH=..
            fi
        fi
    fi
    cd $CODEPATH
    if [[ ! -d ./code ]]
    then err "invalid CODEPATH: $PWD"
    else msg "found code at $PWD"
    fi
}

function run_byond_tests {
    msg "*** running map tests ***"
    find_byond_deps
    cp config/example/* config/
    if [[ "$CI" == "true" ]]; then
        msg "installing BYOND"
        ./install-byond.sh || exit 1
        source $HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/byondsetup
    fi
    run_test "build map unit tests" "scripts/dm.sh -DUNIT_TEST taucetistation.dme"
    run_test "check no warnings in build" "grep ', 0 warnings' build_log.txt"
    run_test "run unit tests" "DreamDaemon taucetistation.dmb -invisible -trusted -core 2>&1 | tee log.txt"
    run_test "check tests passed" "grep 'All Unit Tests Passed' log.txt"
    run_test "check no runtimes" "grep 'Caught 0 Runtimes' log.txt"
    run_test_fail "check no runtimes 2" "grep 'runtime error:' log.txt"
    run_test_fail "check no warnings" "grep 'WARNING:' log.txt"
    run_test_fail "check no errors" "grep 'ERROR:' log.txt"
}

function run_all_tests {
    run_byond_tests
}

find_code
run_all_tests
check_fail
