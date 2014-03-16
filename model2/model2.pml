/** @author Mateusz Machalica */

                #define FOR_ALL_PROCS(p) (p(0) && p(1) && p(2) && p(3))
                #define EXISTS_PROC(p) (p(0) || p(1) || p(2) || p(3))
                #define EXISTS_PROC_2(i, p) (p(i, 0) || p(i, 1) || p(i, 2) || p(i, 3))
/* 01 */        #define N 4                           /* liczba procesow */
/* 02 */        bool chce[N], we[N], wy[N];
/* 03 */        #define i _pid

#include "../lib/state.pml"

                /* Note that to check for all possible scenarios it makes sense to attempt to fail in a given state only
                * once, since after failure all local decisions are forgotten. That being said it is sufficient to try
                * to fail after each assignment to any global variable. */
                inline possibly_fail() {
                    if
                      :: skip
                      :: true -> atomic {
                            chce[i] = false;
                            we[i] = false;
                            wy[i] = false;
                            goto start
                        }
                    fi
                }

/* 04 */        active [N] proctype P()
/* 05 */        {
                    byte k;

/* 06 */        start:
                    /* SEKCJA LOKALNA */

                    if
                      :: skip
                      :: true ->
                        end:
                            false
                    fi;

                    /* PROLOG */

                wait_entry:
                    d_step {
/* 07 */            chce[i] = true;
                        mark_start_waiting(i);
                    }
                    possibly_fail();

                    k = 0;
                    do
                      :: k >= N -> break
                      :: k < N && !(chce[k] && we[k]) -> k++
                    od;

/* 08 */            we[i] = true;
                    possibly_fail();

                    k = 0;
                    do
                      :: k >= N -> break
                      :: k < N && (chce[k] && !we[k]) -> break
                      :: else -> k++
                    od;

                    if
                      :: k < N ->
/* 09 */                {
/* 10 */                    chce[i] = false;
                            possibly_fail();

                            k = 0;
                            do
                              :: wy[k] -> break
                              :: else -> k = (k + 1) % N
                            od;

/* 11 */                    chce[i] = true;
                            possibly_fail();

/* 12 */                }
                      :: else
                    fi;

/* 13 */            wy[i] = true;
                    possibly_fail();

                    k = i + 1;
                    do
                      :: k >= N -> break
                      :: k < N && (!we[k] || wy[k]) -> k++
                    od;

                    k = 0;
                    do
                      :: k >= i -> break
                      :: k < i && !we[k] -> k++
                    od;

                    /* SEKCJA KRYTYCZNA */

                critical_section:
                    mark_cs_entry(i);
                    /* ... */
                    mark_cs_exit(i);

                    /* EPILOG */

/* 14 */            wy[i] = false;
                    possibly_fail();
/* 15 */            we[i] = false;
                    possibly_fail();
/* 16 */            chce[i] = false;
                    //possibly_fail(); /* Completely redundant. */

/* 17 */            goto start
/* 18 */        }

#include "../lib/ltls.pml"

