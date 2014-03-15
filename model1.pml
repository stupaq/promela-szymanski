/** @author Mateusz Machalica */

                #define FOR_ALL_PROCS(p) (p(0) && p(1) && p(2) && p(3))
                #define EXISTS_PROC_2(i, p) (p(i, 0) || p(i, 1) || p(i, 2) || p(i, 3))
/* 01 */        #define N 4                           /* liczba procesow */
/* 02 */        bool chce[N], we[N], wy[N];
/* 03 */        #define i _pid

                int in_cs;
                bool waits[N];
                int entry_lag[N];
                #define entry_lag_limit 2*N

/* 04 */        active [N] proctype P()
/* 05 */        {
                    int k;

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
                    atomic {
/* 07 */            chce[i] = true;
                        waits[i] = true;
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
                    atomic {
                        in_cs++;
                        waits[i] = false;
                        entry_lag[i] = 0;
                        k = 0;
                        do
                          :: k >= N -> break
                          :: k < N && waits[k] -> entry_lag[k]++; k++
                          :: else -> k++
                        od
                    }

                    /* ... */

                    atomic {
                        in_cs--;
                    }

                    /* EPILOG */

/* 14 */            wy[i] = false;
/* 15 */            we[i] = false;
/* 16 */            chce[i] = false;

/* 17 */            goto start
/* 18 */        }

                #define wants_in(i) (P[i]@wait_entry)
                #define is_in(i) (P[i]@critical_section)

                ltl mutual_exclusion { [] (in_cs <= 1) }

                #define always_enters(i) \
                    (wants_in(i) -> (!is_in(i) U ((!is_in(i) && (we[i] && !chce[i])) U (!is_in(i) U is_in(i)))))
                ltl inevitable_anteroom { [] FOR_ALL_PROCS(always_enters) }

                #define i_lets_j_in(i, j) (we[i] && !chce[i] -> i != j && <> wy[j])
                #define lets_someone_in(i) (EXISTS_PROC_2(i, i_lets_j_in))
                ltl exit_anteroom { [] FOR_ALL_PROCS(lets_someone_in) }

                #define process_alive(i) (wants_in(i) -> <> is_in(i))
                ltl liveness { [] FOR_ALL_PROCS(process_alive) }

                #define limited_lag(i) (entry_lag[i] <= entry_lag_limit)
                ltl linear_wait { [] FOR_ALL_PROCS(limited_lag) }

