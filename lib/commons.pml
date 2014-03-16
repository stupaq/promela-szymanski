/** @author Mateusz Machalica */

inline possibly_block() {
  if
    :: skip
    :: true ->
    end:
        false
  fi;
}

inline wait_forall(k, s, e, p) {
  k = (s);
  do
    :: k >= (e) -> break
    :: k < (e) && (p) -> k++
    :: else -> (p); k = (s);
  od;
}

inline check_exists(k, s, e, p) {
  k = (s);
  do
    :: k >= (e) -> break
    :: k < (e) && (p) -> break
    :: else -> k++
  od;
}

