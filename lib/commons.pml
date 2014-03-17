/** @author Mateusz Machalica */

inline possibly_block() {
    if
      :: skip
      :: true ->
        end:
            false
    fi;
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

