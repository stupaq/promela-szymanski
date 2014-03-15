#!/bin/bash
# @author Mateusz Machalica

[[ $# -ne 1 ]] && exit 1

rm -f *.pml.trail
./pan -a -m10000000 -w26 -N$1

