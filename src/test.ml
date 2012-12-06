let comps_t_all = [
  Comp.Alpha_t;
  Comp.Beta_t;
  Comp.Gamma_t;
  Comp.Delta_t;
  Comp.Epsilon_t;
]

let comps_t_a = [
  Comp.Alpha_t;
]

let comps_t_abg = [
  Comp.Alpha_t;
  Comp.Beta_t;
  Comp.Gamma_t;
]

let comps_t_bgd = [
  Comp.Beta_t;
  Comp.Gamma_t;
  Comp.Delta_t;
]

let comps_t_de = [
  Comp.Delta_t;
  Comp.Epsilon_t;
]

let e_all =
  let e = Ent.new_entity () in
  let e = Comp.add_alpha e 46 in
  let e = Comp.add_beta e 3.98 in
  let e = Comp.add_gamma e "Gamma" in
  let e = Comp.add_delta e 'D' in
  let e = Comp.add_epsilon e true in
  (e)

let e_a =
  let e = Ent.new_entity () in
  let e = Comp.add_alpha e 36 in
  (e)

let e_abg =
  let e = Ent.new_entity () in
  let e = Comp.add_alpha e 58 in
  let e = Comp.add_beta e 2.1 in
  let e = Comp.add_gamma e "GAMMA" in
  (e)

let e_bgd =
  let e = Ent.new_entity () in
  let e = Comp.add_beta e 0.1 in
  let e = Comp.add_gamma e "_gamma" in
  let e = Comp.add_delta e 'p' in
  (e)

let b = function true -> "true " | false -> "false"

let test1_legend () =
  print_string "\
# components_match --------------`
# has_any_component -------`     |
# has_components ----`     |     |
#                    |     |     |
"

let test1 label e comps_t =
  Printf.printf "# %14s : " label;
  Printf.printf " %5s" (b (Ent.has_components e comps_t));
  Printf.printf " %5s" (b (Ent.has_any_component e comps_t));
  Printf.printf " %5s" (b (Ent.components_match e comps_t));
  print_newline ()

let () =
  test1_legend ();
  test1 "Test all all" e_all comps_t_all;
  test1 "Test a   abg" e_a   comps_t_abg;
  test1 "Test abg a  " e_abg comps_t_a;
  test1 "Test a   bgd" e_a   comps_t_bgd;
  test1 "Test bgd a  " e_bgd comps_t_a;
;;
