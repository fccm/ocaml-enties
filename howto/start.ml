type component_type =
  | Level_t
  | Name_t

type component =
  | Level of int
  | Name of string

let get_level e =
  match Ent.get_component e Level_t with
  | Level level -> level
  | _ -> failwith "get_level"

(* define which components needs bump_system *)
let bump_system_mapper =
  Ent.make_mapper [Level_t]

let bump_system e w bump =
  let level = get_level e in
  let e = Ent.replace_component e Level_t (Level (level + bump)) in
  (Ent.Updated e, [])

let make_entity level name =
  let e = Ent.new_entity () in
  let e = Ent.add_component e (Name_t, Name name) in
  let e = Ent.add_component e (Level_t, Level level) in
  (e)

let name_string e =
  match Ent.get_component_opt e Name_t with
  | Some (Name name) -> Printf.sprintf "name=%s" name
  | _ -> ""

let level_string e =
  match Ent.get_component_opt e Level_t with
  | Some (Level level) -> Printf.sprintf "level=%d" level
  | _ -> ""

let () =
  let e1 = make_entity 1 "dummy-A" in
  let e2 = make_entity 6 "dummy-B" in
  let w = Ent.new_world () in
  let w = Ent.add_entities w [e1; e2] in
  let w =
    Ent.add_system w
      bump_system_mapper
      bump_system
  in
  let w = Ent.world_step w 1 in
  Ent.iter_entities (fun e ->
    let name = name_string e in
    let level = level_string e in
    Printf.printf "# Entity: %s %s\n" name level
  ) w
