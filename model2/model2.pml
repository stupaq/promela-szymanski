/** @author Mateusz Machalica */

                /* LTL metamacros are prepared for 2 <= N <= 4, if you wish to use different value of N, you must modify
                * them acordingly in lib/ltls.pml. In case you forget to do that you will get compile time error. */
/* 01 */        #define N 4                           /* liczba procesow */
#ifdef N_OVERRIDE
#warning "redefined number of processes in the model"
#undef N
#define N N_OVERRIDE
#endif
/* 02 */        bool chce[N], we[N], wy[N];
/* 03 */        #define i _pid

#include "commons.pml"

/* 04 */        active [N] proctype P()
/* 05 */        {
                    byte k;
                    count_init();
                    goto start;

                restart:
                    /* \forall_k (!we[k] || wy[k]) \iff \neg \exists_k (we[k] && !wy[k]) \iff #(we && !wy) = 0 */
                    (count(0,1,0) + count(1,1,0) == 0);

/* 06 */        start:
                    /* SEKCJA LOKALNA */

                    local_section();

                    /* PROLOG */

                    begin_change
/* 07 */            chce[i] = true;
                    end_change
                started_protocol:
                    skip;

                    /* \forall_k !(chce[k] && we[k]) \iff \neq \exists_k (chce[k] && we[k]) \iff #(chce && we) = 0 */
                    (count(1,1,0) + count(1,1,1) == 0);

                    begin_change
/* 08 */            we[i] = true;
                    end_change

                anteroom_check:
                    if
                      /* \exists_k (chce[k] && !we[k]) \iff #(chce && !we) > 0 */
                      :: (count(1,0,0) + count(1,0,1) > 0) ->
/* 09 */                {
                            begin_change
/* 10 */                    chce[i] = false;
                            end_change

                        in_anteroom:
                            (
                            /* \exists_k wy[k] \iff #(wy) > 0 */
                            (count(0,0,1) + count(0,1,1) + count(1,0,1) + count(1,1,1) > 0)
                            ||
                            /* \forall_k (!chce[k] || we[k]) \iff \neg \exists_k (chce[k] && !we[k])
                            * \iff #(chce && !we) = 0 */
                            (count(1,0,0) + count(1,0,1) == 0)
                            );

                            begin_change
/* 11 */                    chce[i] = true;
                            end_change

                            if
                              /* \neg \exists_k wy[k] \iff #(wy) == 0 */
                              :: (count(0,0,1) + count(0,1,1) + count(1,0,1) + count(1,1,1) == 0)
                                    -> goto anteroom_check
                              :: else
                            fi;
/* 12 */                }
                      :: else
                    fi;

                    begin_change
/* 13 */            wy[i] = true;
                    end_change

                    /* \forall_k (k > i \implies (!we || wy)) */
                    wait_forall(k, i + 1, N, (!we[k] || wy[k]));

                    /* \forall_k (k < i \implies !we) */
                    wait_forall(k, 0, i, (!we[k]));

                    /* SEKCJA KRYTYCZNA */

                critical_section:
                    skip;

                    /* EPILOG */

#if EPILOGUE == 321
                    begin_change
/* 14 */            wy[i] = false;
                    interrupt_change
/* 15 */            we[i] = false;
                    interrupt_change
/* 16 */            chce[i] = false;
                    end_change
#elif EPILOGUE == 312
                    begin_change
                    wy[i] = false;
                    interrupt_change
                    chce[i] = false;
                    interrupt_change
                    we[i] = false;
                    end_change
#elif EPILOGUE == 231
                    begin_change
                    we[i] = false;
                    interrupt_change
                    wy[i] = false;
                    interrupt_change
                    chce[i] = false;
                    end_change
#elif EPILOGUE == 213
                    begin_change
                    we[i] = false;
                    interrupt_change
                    chce[i] = false;
                    interrupt_change
                    wy[i] = false;
                    end_change
#elif EPILOGUE == 132
                    begin_change
                    chce[i] = false;
                    interrupt_change
                    wy[i] = false;
                    interrupt_change
                    we[i] = false;
                    end_change
#elif EPILOGUE == 123
                    begin_change
                    chce[i] = false;
                    interrupt_change
                    we[i] = false;
                    interrupt_change
                    wy[i] = false;
                    end_change
#elif EPILOGUE == 6
                    begin_change
                    chce[i] = false;
                    we[i] = false;
                    wy[i] = false;
                    end_change
#else
#error "protocol epilogue must be chosen, any permutation of {1, 2, 3} or 6 (for atomic epilogue) is acceptable"
#endif

/* 17 */            goto start
/* 18 */        }

#include "ltls.pml"

