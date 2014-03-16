/** @author Mateusz Machalica */

                /* Whenever you change N, you must also modify LTL macros. */
/* 01 */        #define N 4                           /* liczba procesow */
/* 02 */        bool chce[N], we[N], wy[N];
/* 03 */        #define i _pid

#include "../lib/history.pml"
#include "../lib/commons.pml"

                /* Note that to check for all possible scenarios it makes sense to attempt to fail in a given state only
                * once, since after failure all local decisions are forgotten. That being said it is sufficient to try
                * to fail after each assignment to any global variable. */
                inline possibly_fail() {
                    if
                      :: skip
                      :: true ->
                        d_step {
                            chce[i] = false;
                            we[i] = false;
                            wy[i] = false;
                        }

                        wait_forall(k, 0, N, (!we[k] || wy[k]));

                        goto start
                    fi
                }

/* 04 */        active [N] proctype P()
/* 05 */        {
                    byte k;

/* 06 */        start:
                    /* SEKCJA LOKALNA */

                    possibly_block();

                    /* PROLOG */

                wait_entry:
/* 07 */            chce[i] = true;
                    possibly_fail();

                    wait_forall(k, 0, N, !(chce[k] && we[k]));

/* 08 */            we[i] = true;
                    possibly_fail();

                anteroom_check:
                    check_exists(k, 0, N, (chce[k] && !we[k]));

                    if
                      :: k < N ->
/* 09 */                {
/* 10 */                    chce[i] = false;
                            possibly_fail();

                            check_exists(k, 0, N, (wy[k] || !(!chce[k] || we[k])));
                            if
                              :: k == N -> goto anteroom_check
                              :: else
                            fi

/* 11 */                    chce[i] = true;
                            possibly_fail();
/* 12 */                }
                      :: else
                    fi;

/* 13 */            wy[i] = true;
                    possibly_fail();

                    wait_forall(k, i + 1, N, (!we[k] || wy[k]));

                    wait_forall(k, 0, i, !we[k]);

                    /* SEKCJA KRYTYCZNA */

                critical_section:
                    mark_cs_entry(i);
                    skip

                    /* EPILOG */

/* 14 */            wy[i] = false;
                    possibly_fail();
/* 15 */            we[i] = false;
                    possibly_fail();
/* 16 */            chce[i] = false;
                    //possibly_fail(); /* Redundant therefore removed. */

/* 17 */            goto start
/* 18 */        }

#include "../lib/ltls.pml"

