#!/bin/csh
setenv PROJ_DIR "$cwd"
setenv RTL_DIR "${PROJ_DIR}/rtl"
setenv PKG_DIR "${PROJ_DIR}/packages"
setenv TB_DIR "${PROJ_DIR}/tb"
setenv TEST_DIR "${PROJ_DIR}/tb/tests"
# Aliases
alias rt 'set fn=\!:1; make run TESTNAME=$fn > logs.txt && batcat logs.txt'
alias mc "make clean"
alias cmp "make compile && make run"
alias cl "cmp > log.txt && batcat log.txt"
