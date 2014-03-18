/** @author Mateusz Machalica */

                /* Whenever you change N, you must also modify LTL metamacros. */
/* 01 */        #define N 4                           /* liczba procesow */
/* 02 */        bool chce[N], we[N], wy[N];
/* 03 */        #define i _pid

#include "../lib/history.pml"
#include "../lib/commons.pml"

/* 04 */        active [N] proctype P()
/* 05 */        {
                    byte k;

/* 06 */        start:
                    /* SEKCJA LOKALNA */

                    local_section();

                    /* PROLOG */

                request_entry:
/* 07 */            chce[i] = true;

                    wait_forall(k, 0, N, !(chce[k] && we[k]));

/* 08 */            we[i] = true;

                anteroom_check:
                    check_exists(k, 0, N, (chce[k] && !we[k]));

                    if
                      :: k < N ->
/* 09 */                {
/* 10 */                    chce[i] = false;

                        in_anteroom:
                            do
                              :: wy[k] -> break
                              :: else -> k = (k + 1) % N
                            od;

/* 11 */                    chce[i] = true;
/* 12 */                }
                      :: else
                    fi;

/* 13 */            wy[i] = true;

                    wait_forall(k, i + 1, N, (!we[k] || wy[k]));

                    wait_forall(k, 0, i, !we[k]);

                    /* SEKCJA KRYTYCZNA */

                critical_section:
                    mark_cs_entry(i);

                    /* EPILOG */

#if EPILOG == 321
/* 14 */            wy[i] = false;
/* 15 */            we[i] = false;
/* 16 */            chce[i] = false;
#elif EPILOG == 312
                    wy[i] = false;
                    chce[i] = false;
                    we[i] = false;
#elif EPILOG == 231
                    we[i] = false;
                    wy[i] = false;
                    chce[i] = false;
#elif EPILOG == 213
                    we[i] = false;
                    chce[i] = false;
                    wy[i] = false;
#elif EPILOG == 132
                    chce[i] = false;
                    wy[i] = false;
                    we[i] = false;
#elif EPILOG == 123
                    chce[i] = false;
                    we[i] = false;
                    wy[i] = false;
#else
#error "protocol epilog must be chosen, any permutation of {1, 2, 3} is acceptable"
#endif

/* 17 */            goto start
/* 18 */        }

#include "../lib/ltls.pml"

