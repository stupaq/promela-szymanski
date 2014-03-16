
#define entry_lag_limit 2*N

#define wants_in(i) (P[i]@wait_entry)
#define is_in(i) (P[i]@critical_section)

ltl mutual_exclusion { [] (in_cs <= 1) }

#define skips_anteroom(i) (<> (wants_in(i) U (!(we[i] && !chce[i]) U is_in(i))))
ltl inevitable_anteroom { ! EXISTS_PROC(skips_anteroom) }

#define i_lets_j_in(i, j) (we[i] && !chce[i] -> i != j && <> wy[j])
#define lets_someone_in(i) (EXISTS_PROC_2(i, i_lets_j_in))
ltl exit_anteroom { [] FOR_ALL_PROCS(lets_someone_in) }

#define process_alive(i) (wants_in(i) -> <> is_in(i))
ltl liveness { [] FOR_ALL_PROCS(process_alive) }

#define limited_lag(i) (entry_lag[i] <= entry_lag_limit)
ltl linear_wait { [] FOR_ALL_PROCS(limited_lag) }

