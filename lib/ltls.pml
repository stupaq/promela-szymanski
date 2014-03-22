/** @author Mateusz Machalica */

/* These metamacros must be modified whenever you change N. */
#if N == 4
#define FOR_ALL_PROCS(p)        (p(0) && p(1) && p(2) && p(3))
#define EXISTS_PROC(p)          (p(0) || p(1) || p(2) || p(3))
#define FOR_ALL_PROCS_2(i, p)   (p(i, 0) && p(i, 1) && p(i, 2) && p(i, 3))
#define EXISTS_PROC_2(i, p)     (p(i, 0) || p(i, 1) || p(i, 2) || p(i, 3))
#elif N == 3
#define FOR_ALL_PROCS(p)        (p(0) && p(1) && p(2))
#define EXISTS_PROC(p)          (p(0) || p(1) || p(2))
#define FOR_ALL_PROCS_2(i, p)   (p(i, 0) && p(i, 1) && p(i, 2))
#define EXISTS_PROC_2(i, p)     (p(i, 0) || p(i, 1) || p(i, 2))
#elif N == 2
#define FOR_ALL_PROCS(p)        (p(0) && p(1))
#define EXISTS_PROC(p)          (p(0) || p(1))
#define FOR_ALL_PROCS_2(i, p)   (p(i, 0) && p(i, 1))
#define EXISTS_PROC_2(i, p)     (p(i, 0) || p(i, 1))
#else
#error "number of processes set to a value that is not covered by process quantifiers"
#endif

#define Started(i)              (P[i]@started_protocol)
#define InCS(i)                 (P[i]@critical_section)
#define InAnteroom(i)           (P[i]@in_anteroom)

#define Exclusive(i, j)         (i == j || !InCS(i) || !InCS(j))
#define AloneInCS(i)            FOR_ALL_PROCS_2(i, Exclusive)

#define SkipsAnteroom(i)        (<> (Started(i) U (!InAnteroom(i) U InCS(i))))

#define JLetsIExit(i, j)        (we[i] && !chce[i] -> i != j && <> wy[j])
#define ExitsAnteroom(i)        EXISTS_PROC_2(i, JLetsIExit)

#define IsLively(i)             (Started(i) -> <> InCS(i))

#define LimitedOvertake2(i,j)   (i != j && (Started(i) ->   \
                                !InCS(j) U (InCS(j) U (     \
                                !InCS(j) U (InCS(j) U (     \
                                !InCS(j) U InCS(i)))))))
#define LimitedOvertake1(i,j)   (i != j && (Started(i) ->   \
                                !InCS(j) U (InCS(j) U (     \
                                !InCS(j) U InCS(i)))))

#define NoUnlimOvertake(i,j)    (i != j && Started(i) -> !( \
                                ([] (!InCS(i))) && ([] <> (!InCS(j))) && ([] <> InCS(j))))

#define JLetsIExit2(i, j)       (InAnteroom(i) -> i != j && <> wy[j])
#define ExitsAnteroom2(i)       EXISTS_PROC_2(i, JLetsIExit2)

#if LTL == 1
    ltl MutualExclusion { [] FOR_ALL_PROCS(AloneInCS) }
#elif LTL == 2
    ltl InevitableAnteroom { ! EXISTS_PROC(SkipsAnteroom) }
#elif LTL == 3
    ltl ExitAnteroom { [] FOR_ALL_PROCS(ExitsAnteroom) }
#elif LTL == 4
    ltl Liveness { [] FOR_ALL_PROCS(IsLively) }
#elif LTL == 51
    /* We would like to write a quantified formulae, but we can't since there apparently exists a limit for the length
    * of LTL formulae. Therefore we check this property for one pair of processes only. Since our algorithm works in the
    * same way for all pairs of processes i < j and in the same way for all pairs i > j, we can conclude that ,,linear
    * wait'' property holds iff below LTL formulae holds. */
    ltl LinearWait1 { [] (LimitedOvertake1(0,1) && LimitedOvertake1(1,0)) }
#elif LTL == 5
    ltl LinearWait2 { [] (LimitedOvertake2(0,1) && LimitedOvertake2(1,0)) }
#elif LTL == 6
    /* A counterexample to this property tells us that there exists a computation, where one process overtakes the other
    * one unbounded number of times in access to the critical section. */
    ltl NoUnlimitedOvertake { [] (NoUnlimOvertake(0,1) && NoUnlimOvertake(1,0)) }
#elif LTL == 7
    ltl ExitAnteroom2 { [] FOR_ALL_PROCS(ExitsAnteroom2) }
#elif LTL == 999
    active proctype ModelVerificator()
    {
        int k, l;
        /* Wait for all processes to start. */
        count(0,0,0) == N;
        /* Check all assertions periodically. */
    end_start:
        atomic {
            l = 0;
            /* Number of processes in each state cannot be negative. */
            for (k in states_count) {
                assert(states_count[k] >= 0);
                l = l + states_count[k];
            }
            /* Number of processes in any state must be equal to N. */
            assert(l == N);
            /* Check again. */
            goto end_start;
        }
    }
#else
#error "running verifier without LTL formula makes very little sense"
#endif

