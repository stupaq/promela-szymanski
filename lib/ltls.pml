/** @author Mateusz Machalica */

/* These metamacros must be modified whenever you change N. */
#define FOR_ALL_PROCS(p)        (p(0) && p(1) && p(2) && p(3))
#define EXISTS_PROC_2(i, p)     (p(i, 0) || p(i, 1) || p(i, 2) || p(i, 3))

#define wants_cs(i)             (P[i]@wait_entry)
#define is_in_cs(i)             (P[i]@critical_section)

#define are_both_in_cs(i, j)    (i != j && is_in_cs(i) && is_in_cs(j))
#define is_alone_in_cs(i)       (! EXISTS_PROC_2(i, are_both_in_cs)))
ltl mutual_exclusion { [] FOR_ALL_PROCS(is_alone_in_cs) }

#define is_in_anteroom(i)       (we[i] && !chce[i])
#define not_skip_anteroom(i)    ([] !(wants_cs(i) U (!is_in_anteroom(i) U is_in_cs(i))))
/* Note that [] and \forall are commutative, so that all claims have the invariant form. */
ltl inevitable_anteroom { FOR_ALL_PROCS(not_skip_anteroom) }

#define i_lets_j_cs(i, j)       (is_in_anteroom(i) -> i != j && <> wy[j])
#define lets_someone_cs(i)      (EXISTS_PROC_2(i, i_lets_j_cs))
ltl exit_anteroom { [] FOR_ALL_PROCS(lets_someone_cs) }

#define has_liveness(i)         (wants_cs(i) -> <> is_in_cs(i))
ltl liveness { [] FOR_ALL_PROCS(has_liveness) }

#define entry_lag_limit         (2 * N)
#define limited_lag(i)          (entry_lag[i] <= entry_lag_limit)
ltl linear_wait { [] FOR_ALL_PROCS(limited_lag) }

