/** @author Mateusz Machalica */

                /* Whenever you change N, you must also modify LTL metamacros. */
/* 01 */        #define N 4                           /* liczba procesow */
/* 02 */        bool chce[N], we[N], wy[N];
/* 03 */        #define i _pid

#include "../lib/history.pml"
#include "../lib/commons.pml"

                /* We model failures in such a way, that entire local state (local variables & instruction pointer) are
                 * lost, therefore to cover all possible scenarios we can nondeterministically fail after each
                 * modification of the global state only. */
                inline possibly_fail() {
                    if
                      :: skip
                      :: true ->
                        {
                            d_step {
                                chce[i] = false;
                                we[i] = false;
                                wy[i] = false;
                                mark_failure(i);
                            }

                            wait_forall(k, 0, N, (!we[k] || wy[k]));

                            goto start
                        }
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
                              :: else // FIXME
                            fi;

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

                    wait_forall(k, i + 1, N, (!we[k] || wy[k]));

                    wait_forall(k, 0, i, !we[k]);

                    /* SEKCJA KRYTYCZNA */

                critical_section:
                    mark_cs_entry(i);

                    /* EPILOG */

#ifdef EPILOG_321
/* 14 */            wy[i] = false;
                    possibly_fail();
/* 15 */            we[i] = false;
                    possibly_fail();
/* 16 */            chce[i] = false;
#endif
#ifdef EPILOG_312
                    wy[i] = false;
                    possibly_fail();
                    chce[i] = false;
                    possibly_fail();
                    we[i] = false;
#endif
#ifdef EPILOG_231
                    we[i] = false;
                    possibly_fail();
                    wy[i] = false;
                    possibly_fail();
                    chce[i] = false;
#endif
#ifdef EPILOG_213
                    we[i] = false;
                    possibly_fail();
                    chce[i] = false;
                    possibly_fail();
                    wy[i] = false;
#endif
#ifdef EPILOG_132
                    chce[i] = false;
                    possibly_fail();
                    wy[i] = false;
                    possibly_fail();
                    we[i] = false;
#endif
#ifdef EPILOG_123
                    chce[i] = false;
                    possibly_fail();
                    we[i] = false;
                    possibly_fail();
                    wy[i] = false;
#endif
                    /* There is no difference between failing after the epilogue and finishing without interruption with
                    * respect to global state. Therefore we can skip `possibly_fail();` here. */

/* 17 */            goto start
/* 18 */        }

#include "../lib/ltls.pml"

