#!/bin/bash
# @author Mateusz Machalica

rm -f *.pml.trail
./pan -m10000000 -w26 "$@"

