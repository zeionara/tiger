#!/bin/bash

mix run main.exs \
    --board "$TRELLO_BOARD" \
    --list done \
    --members zeionara \
    --commit-title 'fix(ci/cd): pushed one more change' \
    --commit-description 'fix(ci/cd): pushed one more change \
    !create something !close $#11 once moRe' \
    --complete 10-07-2023 \
    --tags foo,bar \
    --zoom \
    --done \
    --skip