Analysis of Szymanski’s mutual exclusion algorithm in Spin
==========================================================

Content
-------
Both of the algorithms described in [1] have been modelled, failure susceptible version can be found under `./model1`,
failure resistant under `./model2`.
Attached you can find a report from the experiment and convenient verifier script.

Running verifier
----------------
In order to run verifier on one of the models, first enter appropriate directory `./model{1,2}` and then run `./verify`
with appropriate arguments as described below.
* `-m <model file>` overrides default model file, by default the only model contained in the directory is selected
* `-l <property number>` verifies given property during simulation, see attached report
* `-e <permutation>` selects epilogue's statements permutation as described in the report
* `-b` enables each process to nondeterministically block in its local section
* `-f` enables weak fairness during simulation
* `-t` shows recorded trail, trace file must be present in the current directory
* `-c` cleans up leftover files (including trace file)

Copyright (c) 2013-2014 Mateusz Machalica

[1]: http://dl.acm.org/citation.cfm?id=55425 "A simple solution to Lamport's concurrent programming problem with linear wait, B. K. Szymanski"
