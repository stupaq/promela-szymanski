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

#define WantsCS(i)              (P[i]@request_entry)
#define InCS(i)                 (P[i]@critical_section)
#define InAnteroom(i)           (P[i]@in_anteroom)

#define Exclusive(i, j)         (i == j || !InCS(i) || !InCS(j))
#define AloneInCS(i)            FOR_ALL_PROCS_2(i, Exclusive)

#define SkipsAnteroom(i)        (<> (WantsCS(i) U (!InAnteroom(i) U InCS(i))))

#define JLetsIExit(i, j)        (we[i] && !chce[i] -> i != j && <> wy[j])
#define ExitsAnteroom(i)        EXISTS_PROC_2(i, JLetsIExit)

#define IsLively(i)             (WantsCS(i) -> <> InCS(i))

#define EntryLagLimit           (2 * N)
#define LimitedWait(i)          (entry_lag[i] <= EntryLagLimit)

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
#elif LTL == 5
    ltl LinearWait { [] FOR_ALL_PROCS(LimitedWait) } // FIXME not exactly what we wanted here
#elif LTL == 6
    ltl ExitAnteroom2 { [] FOR_ALL_PROCS(ExitsAnteroom2) }
#else
#warning "running verifier without LTL formula makes very little sense"
#endif

