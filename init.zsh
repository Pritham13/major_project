#!/usr/bin/zsh
export PROJ_DIR="$PWD"
export RTL_DIR="${PROJ_DIR}/rtl"
export PKG_DIR="${PROJ_DIR}/packages"

# Alias 
alias rt='function _rt() { make run TESTNAME=$1 > logs.txt && bat logs.txt; }; _rt'
alias mc="make clean"
alias cmp="make compile && make run"
alias cl="cmp > log.txt && bat log.txt"
