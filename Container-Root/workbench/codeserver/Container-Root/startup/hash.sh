#!/bin/bash

openssl passwd -6 "$1" | sed 's/\$/\\\$/g'
