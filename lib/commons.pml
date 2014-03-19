/** @author Mateusz Machalica */

byte states_count[8];
#define count(chce, we, wy)         states_count[4*chce + 2*we + 1*wy]
#define count_this                  count(chce[_pid], we[_pid], wy[_pid])
#define begin_change                skip; d_step { count_this--;
#define interrupt_change            end_change begin_change
#define end_change                  count_this++; } possibly_fail();

inline count_init() {
    /* Each starting process adds itself to the counter associated with initial state and waits for all
    * processes to join in. */
    atomic {
        count(0,0,0)++;
        (count(0,0,0) == N);
    }
}

inline local_section() {
#ifndef PROCESSES_NEVER_BLOCK
    atomic {
        if
          :: skip
          :: true ->
            end:
                false
        fi;
    }
#else
#warning "processes cannot block in local section and  will always request critical section reentry"
    skip;
#endif
}

/* We model failures in such a way, that entire local state (local variables & instruction pointer) are
 * lost, therefore to cover all possible scenarios we can nondeterministically fail after each
 * modification of the global state only. */
inline possibly_fail() {
#ifdef RESTARTING_PROCESSES
#warning "processes may nondeterministically restart at any moment"
    atomic {
        if
          :: skip
          :: true ->
            {
                count_this--;
                chce[i] = false;
                we[i] = false;
                wy[i] = false;
                count_this++;
                mark_failure(i);

                goto restart
            }
        fi;
    }
#else
    skip;
#endif
}

inline wait_forall(k, s, e, p) {
    atomic {
        k = (s);
        do
          :: k >= (e) -> break
          :: (k < (e)) && (p) -> k++
          :: else -> { (p); k++ }
        od;
    }
}

