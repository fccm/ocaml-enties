(** generate functions for component management from a simple description *)

(** Here is an example of input file:

Position  xy
Velocity  xy

Read the ocamldoc of the module Ent for a complete description.
*)

type file = ML | MLI

(** utils *)

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

(** write code *)

let print_component_types cs =
  Printf.printf "type component_type =\n";
  List.iter (fun (comp, comp_data) ->
    Printf.printf "  | %s_t\n" comp
  ) cs;
  print_newline ()


let print_components cs =
  Printf.printf "type component =\n";
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "  | %s of %s\n" comp comp_data
  | (comp, None) ->
      Printf.printf "  | %s\n" comp
  ) cs;
  print_newline ()


let print_entity_alias cs =
  Printf.printf "\
type entity =
  (component_type, component) Ent.entity\n\n"


let print_world_alias cs =
  Printf.printf "\
type world =
  (component_type, component) Ent.world\n\n"


let print_setters_ml cs =
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "\
let add_%s e v =
  Ent.add_component e (%s_t, %s v)\n\n"
        (String.uncapitalize comp)
        comp comp
  | (comp, None) ->
      Printf.printf "\
let add_%s e =
  Ent.add_component e (%s_t, %s)\n\n"
        (String.uncapitalize comp)
        comp comp
  ) cs


let print_setters_mli cs =
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "\
val add_%s : entity -> %s -> entity\n"
        (String.uncapitalize comp)
        comp_data
  | (comp, None) ->
      Printf.printf "\
val add_%s : entity -> entity\n"
        (String.uncapitalize comp)
  ) cs


let print_interrogators_ml cs =
  List.iter (fun (comp, _) ->
    Printf.printf "\
let has_%s e =
  Ent.has_component e %s_t\n\n"
      (String.uncapitalize comp)
      comp
  ) cs


let print_interrogators_mli cs =
  List.iter (fun (comp, _) ->
    Printf.printf "\
val has_%s : entity -> bool\n"
      (String.uncapitalize comp)
  ) cs


let print_removers_ml cs =
  List.iter (fun (comp, _) ->
    Printf.printf "\
let remove_%s e =
  Ent.remove_component e %s_t\n\n"
      (String.uncapitalize comp)
      comp
  ) cs


let print_removers_mli cs =
  List.iter (fun (comp, _) ->
    Printf.printf "\
val remove_%s : entity -> entity\n"
      (String.uncapitalize comp)
  ) cs


let print_getters_ml cs =
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "\
let get_%s e =
  match Ent.get_component e %s_t with
  | %s v -> v
  | _ -> invalid_arg \"get_%s\"\n\n"
        (String.uncapitalize comp)
        comp comp
        (String.uncapitalize comp)
  | (comp, None) -> ()
  ) cs


let print_getters_mli cs =
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "\
val get_%s : entity -> %s\n"
        (String.uncapitalize comp)
        comp_data
  | (comp, None) -> ()
  ) cs


let print_optional_getters_ml cs =
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "\
let get_%s_opt e =
  match Ent.get_component_opt e %s_t with
  | Some (%s v) -> Some v
  | None -> None
  | Some _ -> invalid_arg \"get_%s_opt\"\n\n"
        (String.uncapitalize comp)
        comp comp
        (String.uncapitalize comp)
  | (comp, None) -> ()
  ) cs


let print_optional_getters_mli cs =
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "\
val get_%s_opt : entity -> %s option\n"
        (String.uncapitalize comp)
        comp_data
  | (comp, None) -> ()
  ) cs


let print_getters_default_ml cs =
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "\
let get_%s_default e default =
  match Ent.get_component_opt e %s_t with
  | Some (%s v) -> v
  | None -> default
  | Some _ -> invalid_arg \"get_%s_default\"\n\n"
        (String.uncapitalize comp)
        comp comp
        (String.uncapitalize comp)
  | (comp, None) -> ()
  ) cs


let print_getters_default_mli cs =
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "\
val get_%s_default : entity -> %s -> %s\n"
        (String.uncapitalize comp)
        comp_data
        comp_data
  | (comp, None) -> ()
  ) cs


let print_updaters_ml cs =
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "\
let update_%s e v =
  Ent.replace_component e %s_t (%s v)\n\n"
        (String.uncapitalize comp)
        comp comp
  | (comp, None) -> ()
  ) cs


let print_updaters_mli cs =
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf "\
val update_%s : entity -> %s -> entity\n"
        (String.uncapitalize comp)
        comp_data
  | (comp, None) -> ()
  ) cs


let print_debuger_comp_type_ml cs =
  Printf.printf "let string_of_component_type = function\n";
  List.iter (function
  | (comp, _) ->
      Printf.printf "  | %s_t -> \"%s_t\"\n" comp comp
  ) cs;
  print_newline ()


let print_debuger_comp_type_mli cs =
  Printf.printf "\
val string_of_component_type : component_type -> string\n\n"

let string_of = function
  | "string" -> ""
  | "char" -> "String.make 1 "
  | v -> Printf.sprintf "string_of_%s " v

let print_debuger_comp_ml cs =
  Printf.printf "let string_of_component = function\n";
  List.iter (function
  | (comp, Some comp_data) ->
      Printf.printf
        "  | %s v -> Printf.sprintf \"%s %%s\" (%sv)\n"
        comp comp (string_of comp_data)
  | (comp, None) ->
      Printf.printf
        "  | %s -> Printf.sprintf \"%s\"\n"
        comp comp
  ) cs;
  print_newline ()


let print_debuger_comp_mli cs =
  Printf.printf "\
val string_of_component : component -> string\n\n"

(* print printers *)

let print_printer_mli () =
  print_string "\
val print_entity : entity -> unit
val print_entities : world -> unit
"

let print_printer_ml () =
  print_string "
let _print_entity e =
  Printf.printf \"Entity:\n\";
  Ent.iter_components e (fun comp_t comp ->
    Printf.printf \"  %s  %s\n\"
      (string_of_component_type comp_t)
      (string_of_component comp)
  );
  Printf.printf \"\n\"

let print_entity e =
  _print_entity e;
  Printf.printf \"%!\"

let print_entities w =
  Ent.iter_entities _print_entity w;
  Printf.printf \"====================\n\";
  Printf.printf \"%!\"
"

(** comments *)

let print_warning () =
  Printf.printf "(* Warning: this is GENERATED CODE *)\n\n"

let print_module_title () =
  Printf.printf "(** Component Management *)\n\n"

let print_title f title =
  match f with
  | ML  -> Printf.printf "(* %s *)\n\n" title
  | MLI -> Printf.printf "\n(** {3 %s} *)\n\n" title

let print_component_types f cs =
  print_title f "Type of Components";
  print_component_types cs

let print_setters f cs =
  print_title f "Setters";
  match f with
  | ML  -> print_setters_ml cs
  | MLI -> print_setters_mli cs

let print_interrogators f cs =
  print_title f "Interrogators";
  match f with
  | ML  -> print_interrogators_ml cs
  | MLI -> print_interrogators_mli cs

let print_removers f cs =
  print_title f "Removers";
  match f with
  | ML  -> print_removers_ml cs
  | MLI -> print_removers_mli cs

let print_getters f cs =
  print_title f "Getters";
  match f with
  | ML  -> print_getters_ml cs
  | MLI -> print_getters_mli cs

let print_optional_getters f cs =
  print_title f "Optional Getters";
  match f with
  | ML  -> print_optional_getters_ml cs
  | MLI -> print_optional_getters_mli cs

let print_getters_default f cs =
  print_title f "Getters with Default";
  match f with
  | ML  -> print_getters_default_ml cs
  | MLI -> print_getters_default_mli cs

let print_debugers f cs =
  print_title f "Debuggers";
  match f with
  | ML  ->
      print_debuger_comp_type_ml cs;
      print_debuger_comp_ml cs;
  | MLI ->
      print_debuger_comp_type_mli cs;
      print_debuger_comp_mli cs;
;;

let print_updaters f cs =
  print_title f "Updaters";
  match f with
  | ML  -> print_updaters_ml cs
  | MLI -> print_updaters_mli cs

let print_printer f =
  print_title f "Printers";
  match f with
  | ML  -> print_printer_ml ()
  | MLI -> print_printer_mli ()


(** main *)

let () =
  let args = List.tl (Array.to_list Sys.argv) in
  let in_file, f =
    match args with
    | ["-ml";  file] | [file; "-ml"]  -> (file, ML)
    | ["-mli"; file] | [file; "-mli"] -> (file, MLI)
    | _ -> invalid_arg "( -ml | -mli )"
  in
  let lines = read_lines in_file in
  let cs =
    List.map (fun line ->
      match char_split ' ' line with
      | [comp; comp_data] -> (comp, Some comp_data)
      | [comp] -> (comp, None)
      | _ -> invalid_arg "read component"
    ) lines
  in
  print_warning ();
  print_module_title ();
  print_component_types f cs;
  print_components cs;
  print_entity_alias cs;
  print_world_alias cs;
  print_setters f cs;
  print_getters f cs;
  print_optional_getters f cs;
  print_getters_default f cs;
  print_interrogators f cs;
  print_removers f cs;
  print_updaters f cs;
  print_debugers f cs;
  print_printer f;
;;
