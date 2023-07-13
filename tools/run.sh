#!/bin/bash

mix run main.exs \
    --board "$TRELLO_BOARD" \
    --list done \
    --members zeionara \
    --commit-title 'fix(ci/cd): pushed one more change' \
    --commit-description 'fix(ci/cd): pushed one more change
    !create something !close $#11 once moRe !make ^&
    Some reaLLy long messaGe here
    which Even SPANS mULTIPLE lines and has spec1al characters such as &!&()$
    ^& ^&
    Some amazing DESCRIPTION hereeeeeeeee
    which Even SPANS mULTIPLE lines and has spec1al characters such as &!&()$
    ^&
    some intermediate text here before the second make command Appers: !make ^&
    that is THE argument for THE second make command
    ^&
    ' \
    --complete 10-07-2023 \
    --tags foo,bar \
    --zoom \
    --done \
    --skip
