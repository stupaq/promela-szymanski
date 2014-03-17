/** @author Mateusz Machalica */

#ifndef EPILOG_321
#ifndef EPILOG_312
#ifndef EPILOG_231
#ifndef EPILOG_213
#ifndef EPILOG_132
#ifndef EPILOG_123
/* Default epilog. */
#define EPILOG_321
#endif
#endif
#endif
#endif
#endif
#endif

inline possibly_block() {
#ifndef NEVER_BLOCKS
    if
      :: skip
      :: true ->
        end:
            false
    fi;
#else
    skip
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

