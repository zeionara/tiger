#!/bin/bash

apply () {
    find ./lib -type f ! -name *formatter.ex -exec "$@"
}
