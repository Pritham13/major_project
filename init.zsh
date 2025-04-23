#!/usr/bin/zsh
export PROJ_DIR="$PWD"
export RTL_DIR="${PROJ_DIR}/rtl"
export PKG_DIR="${PROJ_DIR}/packages"
export TB_DIR="${PROJ_DIR}/tb"
export TEST_DIR="${PROJ_DIR}/tb/tests"

# Alias 
alias rt='function _rt() { make run TESTNAME=$1 > logs.txt && batcat logs.txt; }; _rt'
alias mc="make clean"
alias cmp="make compile && make run"
alias cl="cmp > log.txt && batcat log.txt"
