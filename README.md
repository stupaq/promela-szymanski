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
* `-l <property number>` verifies given property during verification, see attached report
* `-e <permutation>` selects epilogue's statements permutation as described in the report
* `-n` none of the processes can ever block in local section
* `-r` makes processes unreliable (they might restart nondeterministically)
* `-N <number>` overrides number of processes in the model (default number of processes is 4)
* `-f` enables weak fairness during verification
* `-i` in case of error look for minimal counterexample
* `-S` `-M` `-L` small, medium and large verifier resource usage limits
* `-t` shows recorded trail, trace file must be present in the current directory; note that options specified when
  showing recorded trail must match those specified when verificator recorded the trail
* `-c` cleans up leftover files (including trace file)

It is very important to choose appropriate memory limits.
If you are unsure which one to pick, just choose the biggest resources usage you machine can handle.

Usage examples
--------------
Verify mutual exclusion for `model1` with epilogue `312` assuming that no process can ever block in local section (this
actually does not matter for mutual exclusion):

    cd model1/; ./verify -n -e312 -l1

Verify linear wait for `model1` (with constant 2) in weakly fair model and epilogue permutation `123`, show trail (this
particular verification should fail).

    cd model1/; ./verify -f -e123 -l52; ./verify -f -e123 -l52 -t

Verify mutual exclusion for `model2` assuming tha processes might restart nondeterministically and epilogue permutation
is `312`.

    cd model2/; ./verify -r -e312 -l1



Copyright (c) 2013-2014 Mateusz Machalica

[1]: http://dl.acm.org/citation.cfm?id=55425 "A simple solution to Lamport's concurrent programming problem with linear wait, B. K. Szymanski"
