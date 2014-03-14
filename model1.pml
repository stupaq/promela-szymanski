
/* 01 */        #define N 4                           /* liczba procesow */
/* 02 */        bool chce[N], we[N], wy[N];
/* 03 */        #define i _pid

                int cs_count;
                bool waits[N];
                #define ENTRY_LAG_LIMIT N
                int entry_lag[N];

/* 04 */        active [N] proctype P()
/* 05 */        {
                    int k;

/* 06 */        start:
                    /* PROLOG */

                    d_step {
/* 07 */            chce[i] = true;
                        waits[i] = true;
                    }

                    k = 0;
                    do
                      :: k >= N -> break
                      :: k < N && !(chce[k] && we[k]) -> k++
                      :: else -> skip
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
                      :: else -> skip
                    fi;

/* 13 */            wy[i] = true;

                    k = i + 1;
                    do
                      :: k >= N -> break
                      :: k < N && (!we[k] || wy[k]) -> k++
                      :: else -> skip
                    od;

                    k = 0;
                    do
                      :: k >= i -> break
                      :: k < i && !we[k] -> k++
                      :: else -> skip
                    od;

                    /* SEKCJA KRYTYCZNA */

                    d_step {
                        cs_count++;
                        assert (cs_count == 1);
                        waits[i] = false;
                        assert(entry_lag[i] <= ENTRY_LAG_LIMIT);
                        entry_lag[i] = 0;
                        k = 0;
                        do
                          :: k >= N -> break
                          :: k < N && waits[k] -> entry_lag[k]++; k++
                          :: else -> k++
                        od
                    }

                    /* ... */

                    d_step {
                        cs_count--;
                    }

                    /* EPILOG */

/* 14 */            wy[i] = false;
/* 15 */            we[i] = false;
/* 16 */            chce[i] = false;

/* 17 */            goto start
/* 18 */        }

