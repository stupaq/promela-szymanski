/** @author Mateusz Machalica */

inline local_section() {
#ifdef MAY_BLOCK_LS
    atomic {
        if
          :: skip
          :: true ->
            end:
                false
        fi;
    }
#else
#warning "processes will always request critical section reentry"
    skip;
#endif
}

inline check_exists(k, s, e, p) {
    d_step {
        k = (s);
        do
          :: k >= (e) -> break
          :: (k < (e)) && (p) -> break
          :: else -> k++
        od;
    }
}

inline wait_forall(k, s, e, p) {
    atomic {
        k = (s);
        do
          :: k >= (e) -> break
          :: (k < (e)) && (p) -> k++
          :: else -> { (p); k = (s); }
        od;
    }
}

