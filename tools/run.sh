#!/bin/bash

mix run main.exs \
    --board "$TRELLO_BOARD" \
    --list done \
    --members zeionara \
    --commit-title 'fix(ci/cd, foo   , bar ): pushed one more change while pulling data, added another one, and appended the third one' \
    --commit-description 'fix(ci/cd): pushed one more change
    !create ^&pu*@1 add*
    appended^& something !close $#refactor-alignment once moRe !make ^&
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
    --complete 04-08-2023 \
    --tags amar,ui \
    --zoom \
    --done \
    --skip
