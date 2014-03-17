/** @author Mateusz Machalica */

/* These metamacros must be modified whenever you change N. */
#define FOR_ALL_PROCS(p)        (p(0) && p(1) && p(2) && p(3))
#define EXISTS_PROC(p)          (p(0) || p(1) || p(2) || p(3))
#define FOR_ALL_PROCS_2(i, p)   (p(i, 0) && p(i, 1) && p(i, 2) && p(i, 3))
#define EXISTS_PROC_2(i, p)     (p(i, 0) || p(i, 1) || p(i, 2) || p(i, 3))

#define WantsCS(i)              (P[i]@wait_entry)
#define InCS(i)                 (P[i]@critical_section)

#define Exclusive(i, j)         (i == j || !InCS(i) || !InCS(j))
#define AloneInCS(i)            FOR_ALL_PROCS_2(i, Exclusive)
#ifdef LTL_1
    ltl MutualExclusion { [] FOR_ALL_PROCS(AloneInCS) }
#endif

#define InAnteroom(i)           (we[i] && !chce[i])
#define SkipsAnteroom(i)        (<> (WantsCS(i) U (!InAnteroom(i) U InCS(i)))) // FIXME maybe W is more appropriate
#ifdef LTL_2
    ltl InevitableAnteroom { ! EXISTS_PROC(SkipsAnteroom) }
#endif

#define JLetsIExit(i, j)        (InAnteroom(i) -> i != j && <> wy[j])
#define ExitsAnteroom(i)        EXISTS_PROC_2(i, JLetsIExit)
#ifdef LTL_3
    ltl ExitAnteroom { [] FOR_ALL_PROCS(ExitsAnteroom) }
#endif

#define IsLively(i)             (WantsCS(i) -> <> InCS(i))
#ifdef LTL_4
    ltl Liveness { [] FOR_ALL_PROCS(IsLively) }
#endif

#define EntryLagLimit           (2 * N)
#define LimitedWait(i)          (entry_lag[i] <= EntryLagLimit)
#ifdef LTL_5
    ltl LinearWait { [] FOR_ALL_PROCS(LimitedWait) } // FIXME not exactly what we wanted here
#endif

