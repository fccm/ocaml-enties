(** generate functions for units from a simple description *)

(** Here is an example of input file:

{[
item		Position
ball		pos:Position
moving_ball	pos:Position	vel:Velocity
falling_ball	pos:Position	Velocity=(0.0, -0.2)
random_ball	Position=(rand_xy ())	Velocity=(rand_xy)
ball_defaults	?pos:Position=(0.0, 0.0)	?vel:Velocity=(0.0, 0.0)
]}

Read the ocamldoc of the module Ent for a complete description.
*)

type file = ML | MLI

(** utils *)

let rec index_from n s i c =
  if i >= n then -1 else
  if String.unsafe_get s i = c
  then i
  else index_from n s (i + 1) c

let index_from s i c =
  let n = String.length s in
  index_from n s i c

let index s c =
  index_from s 0 c

let rec rindex_from s i c =
  if i < 0 then -1 else
  if String.unsafe_get s i = c
  then i
  else rindex_from s (i - 1) c

let rec char_split_rec ((c, s) as cs) i acc =
  match rindex_from s i c with
  | -1 ->
      if (i+1) = 0 then acc
      else String.sub s 0 (i+1) :: acc
  | j ->
      char_split_rec cs (j-1) (
        if (i-j) = 0
        then acc
        else (String.sub s (j+1) (i-j) :: acc)
      )

let char_split c s =
  if s = "" then [] else
  char_split_rec (c, s) (String.length s - 1) []

let input_line_opt ic =
  try Some (input_line ic)
  with End_of_file -> close_in ic; None

let read_lines fn =
  let ic = open_in fn in
  let rec aux acc =
    match input_line_opt ic with
    | Some s -> aux (s::acc)
    | None -> List.rev acc
  in
  aux []

let rem_chars s n =
  let len = String.length s in
  String.sub s n (len - n)

let concat_wrap ?(max = 80) j1 j2 lst =
  let b = Buffer.create 100 in
  let jn = String.length j1 in
  let rec aux n = function
  | x::xs ->
      let len_x = String.length x in
      let len = n + len_x + jn in
      if len > max
      then (Buffer.add_string b j2;
            Buffer.add_string b x; aux len_x xs)
      else (Buffer.add_string b j1;
            Buffer.add_string b x; aux len xs)
  | [] ->
      Buffer.contents b
  in
  match lst with
  | [] -> ""
  | x::xs ->
      Buffer.add_string b x;
      let len = String.length x in
      aux len xs

let cut s i =
  let n = String.length s in
  (String.sub s 0 (i),
   String.sub s (i+1) (n-i-1))


(** components *)

let read_comp line =
  match char_split ' ' line with
  | [comp; comp_data] -> (comp, Some comp_data)
  | [comp] -> (comp, None)
  | _ -> invalid_arg "read component"


let comp_has_val cs comp =
  let v = List.assoc comp cs in
  match v with Some _ -> true | None -> false

let comp_get_type cs comp =
  let v = List.assoc comp cs in
  match v with Some v -> v | None -> assert false


(** read the parameters *)

type param =
  | Std_param of string
    (** "Position" *)

  | Label_param of string * string
    (** "pos:Position" *)

  | Fix_param of string * string
    (** "Position=(0.0, 0.0)" *)

  | Default_param of string * string * string
    (** "?pos:Position=(0.0, 0.0)" *)


(** create the correct parameter *)

let param_std p =
  Std_param p

let param_label p c =
  let lbl, comp = cut p c in
  Label_param (lbl, comp)

let param_fix p c =
  let comp, value = cut p c in
  Fix_param (comp, value)

let param_default p c1 c2 =
  if c1 > c2 then failwith "default parameter";
  let tmp, value = cut p c2 in
  let lbl, comp = cut tmp c1 in
  let _, lbl = cut lbl 0 in
  Default_param (lbl, comp, value)


(** check which parameter should be created *)
let read_param p =
  match index p '?', index p ':', index p '=' with
  | -1, -1, -1 -> param_std p
  | -1, c, -1 -> param_label p c
  | -1, -1, c -> param_fix p c
  | 0, c1, c2 -> param_default p c1 c2
  | _ -> failwith "parameter"


(** arguments for the function call (the implementation) *)
let arg_param = function
  | Std_param comp ->  (* "Position" *)
      String.uncapitalize comp
  | Label_param (lbl, comp) ->  (* "pos:Position" *)
      Printf.sprintf "~%s" lbl
  | Fix_param (comp, value) ->  (* "Position=(0.0, 0.0)" *)
      ""
  | Default_param (lbl, comp, value) ->  (* "?pos:Position=(0.0, 0.0)" *)
      Printf.sprintf "?(%s=%s)" lbl value


(** arguments for the signature *)
let sig_param cs = function
  | Std_param comp -> comp_get_type cs comp
  | Label_param (lbl, comp) ->
      Printf.sprintf "%s:%s" lbl (comp_get_type cs comp)
  | Fix_param (comp, value) -> ""
  | Default_param (lbl, comp, value) ->
      Printf.sprintf "?%s:%s" lbl (comp_get_type cs comp)


(** implementation: add the components of the unit *)
let add_param = function
  | Std_param p ->
      Printf.sprintf "  let _e = Comp.add_%s _e %s in\n"
        (String.uncapitalize p)
        (String.uncapitalize p)
  | Label_param (lbl, comp) ->
      Printf.sprintf "  let _e = Comp.add_%s _e %s in\n"
        (String.uncapitalize comp) lbl
  | Fix_param (comp, value) ->
      Printf.sprintf "  let _e = Comp.add_%s _e %s in\n"
        (String.uncapitalize comp) value
  | Default_param (lbl, comp, value) ->
      Printf.sprintf "  let _e = Comp.add_%s _e %s in\n"
        (String.uncapitalize comp) lbl


(** [Comp.component_type] *)
let comp_type = function
  | Std_param comp ->
      Printf.sprintf "Comp.%s_t" comp
  | Label_param (lbl, comp) -> 
      Printf.sprintf "Comp.%s_t" comp
  | Fix_param (comp, value) ->
      Printf.sprintf "Comp.%s_t" comp
  | Default_param (lbl, comp, value) ->
      Printf.sprintf "Comp.%s_t" comp


(** components with a predefined value
  should not be a argument of the function call *)
let call_param = function
  | Std_param _ -> true
  | Label_param (_, _) -> true
  | Fix_param (_, _) -> false
  | Default_param (_, _, _) -> true


(** if the function needs an additional unit argument
  due to optional arguments *)
let def_param d = function
  | Std_param _ -> false
  | Label_param (_, _) -> d
  | Fix_param (_, _) -> d
  | Default_param (_, _, _) -> true


let call_params params =
  concat_wrap ~max:50 " " "\n    "
    (List.map arg_param params)

let add_params params =
  String.concat ""
    (List.map add_param params)

let comp_types_list params =
  concat_wrap ~max:78 "; " ";\n  "
    (List.map comp_type params)

let sig_params cs params =
  concat_wrap ~max:60 " -> " " ->\n  "
    (List.map (sig_param cs) params)


(** arguments for calling the make_* functions (implementation) *)
let arg_params params =
  let params = List.filter call_param params in
  if params = [] then "()" else
    let ps = call_params params in
    if List.fold_left def_param false params
    then ps ^ " ()"
    else ps

(** arguments for calling the make_* functions (signature) *)
let sig_params cs params =
  let params = List.filter call_param params in
  if params = [] then "unit" else
    let ps = sig_params cs params in
    if List.fold_left def_param false params
    then ps ^ " -> unit"
    else ps


(** {3 Printing function} *)

let print_unit_ml cs name params =
  Printf.printf "
let make_%s %s =
  let _e = Ent.new_entity () in
%s  (_e)
"   name
    (arg_params params)
    (add_params params)


let print_unit_mli cs name params =
  Printf.printf "
val make_%s : %s -> Comp.entity"
    name
    (sig_params cs params)


let print_unit = function
  | ML -> print_unit_ml
  | MLI -> print_unit_mli


let print_comps_ml name params =
  Printf.printf "
let %s_comps = [
  %s
]
"   name
    (comp_types_list params)

let print_comps_mli name params =
  Printf.printf "
val %s_comps : Comp.component_type list" name

let print_comps = function
  | ML -> print_comps_ml
  | MLI -> print_comps_mli


let print_matcher_ml name =
  Printf.printf "
let is_%s e =
  Ent.has_components e %s_comps
"   name name

let print_matcher_strict_ml name =
  Printf.printf "
let is_%s_strict e =
  Ent.components_match e %s_comps
"   name name

let print_matcher_mli name =
  Printf.printf "
val is_%s : Comp.entity -> bool" name

let print_matcher_strict_mli name =
  Printf.printf "
val is_%s_strict : Comp.entity -> bool" name

let print_matcher = function
  | ML -> print_matcher_ml
  | MLI -> print_matcher_mli

let print_matcher_strict = function
  | ML -> print_matcher_strict_ml
  | MLI -> print_matcher_strict_mli

let print_unit_comment name =
  Printf.printf "\n\n(** {6 Unit %s} *)\n" name

let print_comment star com =
  let s = String.concat " " com in
  let s = rem_chars s (1 + String.length star) in
  Printf.printf "\n\n(*%s %s *)\n" star (String.trim s)

let print_tl_comment com =
  let s = String.concat " " com in
  let s = rem_chars s (1 + 3) in
  Printf.printf "\n\n(** {2 %s} *)\n" (String.trim s)

let is_comment = function
  | [] -> false
  | s :: _ ->
      String.length s > 1 &&
      s.[0] = '#'

let is_doc_comment = function
  | [] -> false
  | s :: _ ->
      String.length s > 2 &&
      s.[0] = '#' && s.[1] = '#'

let is_title_comment = function
  | [] -> false
  | s :: _ ->
      String.length s > 3 &&
      s.[0] = '#' && s.[1] = '#' && s.[2] = '#'

let no_val_comps cs = function
  | Std_param comp ->
      if comp_has_val cs comp
      then Std_param comp
      else Fix_param (comp, "")
  | p -> p

let gen_unit_code f cs = function
  | [] -> ()
  | com when is_title_comment com -> print_tl_comment com
  | com when is_doc_comment com -> print_comment "*" com
  | com when is_comment com -> print_comment "" com
  | name :: [] -> Printf.kprintf failwith "empty unit: %s" name
  | name :: params ->
      print_unit_comment name;
      let params = List.map read_param params in
      let params = List.map (no_val_comps cs) params in
      print_unit f cs name params;
      print_comps f name params;
      print_matcher f name;
      print_matcher_strict f name;
  ;;


(** main *)

let usage () =
  Printf.eprintf
    "usage: %s <comp-def> <units-def> ( -ml | -mli )\n"
    Sys.argv.(0);
  exit 0

let () =
  let args = List.tl (Array.to_list Sys.argv) in
  let unit_file, comp_file, f =
    match args with
    | [comp_file; unit_file; "-ml"; ] -> (unit_file, comp_file, ML)
    | [comp_file; unit_file; "-mli" ] -> (unit_file, comp_file, MLI)
    | _ -> usage ()
  in
  let u_lines = read_lines unit_file in
  let c_lines = read_lines comp_file in
  let cs = List.map (read_comp) c_lines in
  let us = List.map (char_split '\t') u_lines in
  List.iter (gen_unit_code f cs) us
