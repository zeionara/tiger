#!/bin/bash

. tools/debug/main.sh

apply sed -i 's/@debug false/@debug true/g' {} +
