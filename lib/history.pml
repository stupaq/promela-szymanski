/** @author Mateusz Machalica */

byte entry_lag[N];

inline mark_cs_entry(i) {
#if LTL == 5
    d_step {
        entry_lag[i] = 0;
        k = 0;
        do
          :: k >= N -> break
          :: k < N && k != i && (chce[k] || we[k] || wy[k]) ->
            {
                entry_lag[k]++;
                k++
            }
          :: else -> k++
        od
    }
#else
    skip;
#endif
}

inline mark_failure(i) {
#if LTL == 5
    entry_lag[i] = 0;
#else
    skip;
#endif
}

