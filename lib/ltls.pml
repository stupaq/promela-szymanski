/** @author Mateusz Machalica */

/* These metamacros must be modified whenever you change N. */
#if N == 4
#define FOR_ALL_PROCS(p)        (p(0) && p(1) && p(2) && p(3))
#define EXISTS_PROC(p)          (p(0) || p(1) || p(2) || p(3))
#define FOR_ALL_PROCS_2(i, p)   (p(i, 0) && p(i, 1) && p(i, 2) && p(i, 3))
#define EXISTS_PROC_2(i, p)     (p(i, 0) || p(i, 1) || p(i, 2) || p(i, 3))
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

#define Exclusive(i, j)         (i == j || !InCS(i) || !InCS(j))
#define AloneInCS(i)            FOR_ALL_PROCS_2(i, Exclusive)

#define InAnteroom(i)           (we[i] && !chce[i])
#define SkipsAnteroom(i)        (<> (WantsCS(i) U (!InAnteroom(i) U InCS(i))))

#define JLetsIExit(i, j)        (InAnteroom(i) -> i != j && <> wy[j])
#define ExitsAnteroom(i)        EXISTS_PROC_2(i, JLetsIExit)

#define IsLively(i)             (WantsCS(i) -> <> InCS(i))

#define EntryLagLimit           (2 * N)
#define LimitedWait(i)          (entry_lag[i] <= EntryLagLimit)

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
#else
#warning "running verifier without LTL formula makes very little sense"
#endif

