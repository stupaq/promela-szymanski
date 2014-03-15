/** @author Mateusz Machalica */

                #define ForallProcs(p) (p(0) && p(1) && p(2) && p(3))
/* 01 */        #define N 4                           /* liczba procesow */
/* 02 */        bool chce[N], we[N], wy[N];
/* 03 */        #define i _pid

                int in_cs;
                bool waits[N];
                int entry_lag[N];
                #define entry_lag_limit 3*N

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

                #define Safe (in_cs <= 1)
                ltl mutual_exclusion { [] Safe }

                #define Inevitablei(i) (true)
                ltl inevitable_anteroom { [] ForallProcs(Inevitablei) }

                #define Exitij(i, j) (we[i] && !chce[i] -> i != j && <> wy[j])
                #define Exiti(i) (Exitij(i, 0) || Exitij(i, 1) || Exitij(i, 2) || Exitij(i, 3))
                ltl exit_anteroom { [] ForallProcs(Exiti) }

                #define Alivei(i) ((P[i]@wait_entry) -> <> (P[i]@critical_section))
                ltl liveness { [] ForallProcs(Alivei) }

                #define LagLimiti(i) (entry_lag[i] <= entry_lag_limit)
                ltl linear_wait { [] ForallProcs(LagLimiti) }

