#!/bin/bash

. tools/debug/main.sh

apply sed -i 's/@debug true/@debug false/g' {} +
