/** @author Mateusz Machalica */

byte entry_lag[N];

inline mark_cs_entry(i) {
    d_step {
        entry_lag[i] = 0;
        k = 0;
        do
          :: k >= N -> break
          :: k < N && (chce[k] || we[k] || wy[k]) -> { entry_lag[k]++; k++ }
          :: else -> k++
        od
    }
}

inline mark_failure(i) {
    entry_lag[i] = 0;
}

