
byte in_cs;
bool waits[N];
byte entry_lag[N];
#define entry_lag_limit 2*N

inline mark_start_waiting(i) {
    waits[i] = true;
}

inline mark_cs_entry(i) {
    d_step {
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
}

inline mark_cs_exit(i) {
    d_step {
        in_cs--;
    }
}

