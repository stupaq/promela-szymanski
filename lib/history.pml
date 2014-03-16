/** @author Mateusz Machalica */

byte in_cs;
byte entry_lag[N];

inline mark_cs_entry(i) {
    d_step {
        in_cs++;
        entry_lag[i] = 0;
        k = 0;
        do
          :: k >= N -> break
          :: k < N && (chce[k] || we[k] || wy[k]) -> entry_lag[k]++; k++
          :: else -> k++
        od
    }
}

inline mark_cs_exit(i) {
    d_step {
        in_cs--;
    }
}

