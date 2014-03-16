/** @author Mateusz Machalica */

                #define FOR_ALL_PROCS(p) (p(0) && p(1) && p(2) && p(3))
                #define EXISTS_PROC(p) (p(0) || p(1) || p(2) || p(3))
                #define EXISTS_PROC_2(i, p) (p(i, 0) || p(i, 1) || p(i, 2) || p(i, 3))
/* 01 */        #define N 4                           /* liczba procesow */
/* 02 */        bool chce[N], we[N], wy[N];
/* 03 */        #define i _pid

#include "../lib/state.pml"

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

                    k = 0;
                    do
                      :: k >= N -> break
                      :: k < N && !(chce[k] && we[k]) -> k++
                      :: else
                    od;

/* 08 */            we[i] = true;

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

                            k = 0;
                            do
                              :: wy[k] -> break
                              :: else -> k = (k + 1) % N
                            od;

/* 11 */                    chce[i] = true;
/* 12 */                }
                      :: else
                    fi;

/* 13 */            wy[i] = true;

                    k = i + 1;
                    do
                      :: k >= N -> break
                      :: k < N && (!we[k] || wy[k]) -> k++
                      :: else
                    od;

                    k = 0;
                    do
                      :: k >= i -> break
                      :: k < i && !we[k] -> k++
                      :: else
                    od;

                    /* SEKCJA KRYTYCZNA */

                critical_section:
                    mark_cs_entry(i);
                    /* ... */
                    mark_cs_exit(i);

                    /* EPILOG */

/* 14 */            wy[i] = false;
/* 15 */            we[i] = false;
/* 16 */            chce[i] = false;

/* 17 */            goto start
/* 18 */        }

#include "../lib/ltls.pml"

