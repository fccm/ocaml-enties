(** Entity/Component oriented module
    for game and multimedia programming *)

type id = int

(** Entities *)

external c2i : 'a -> int = "%identity"

let cmp_comp a b = (c2i a) - (c2i b)

let cmp_e a b = (a - b)

let not_int p =
  Obj.is_block (Obj.repr p)


type ('component_type, 'component) entity =
  {
    id : id;
    components : ('component_type, 'component) PMap.t;
  }

let new_entity () =
  {
    id = -1;
    components = PMap.empty;
  }


let get_id_opt e =
  if e.id < 0 then None
  else Some e.id

let get_id e =
  if e.id < 0 then invalid_arg "get_id"
  else e.id


(** Components *)

let has_component e comp_type =
  PMap.mem comp_type cmp_comp e.components

let has_components e comp_types =
  List.for_all (has_component e) comp_types

let has_any_component e comp_types =
  List.exists (has_component e) comp_types

let put_component e (comp_type, comp_data) =
  { e with
    components = PMap.add comp_type comp_data cmp_comp e.components;
  }

let add_component e (comp_type, comp_data) =
  if not_int comp_type then invalid_arg "add_component: component_type";
  if has_component e comp_type then
    invalid_arg "add_component: already has component_type";
  put_component e (comp_type, comp_data)

let replace_component e comp_type new_val =
  if not_int comp_type then invalid_arg "replace_component: component_type";
  put_component e (comp_type, new_val)

let get_component e comp_type =
  PMap.find comp_type cmp_comp e.components

let get_component_opt e comp_type =
  PMap.find_opt comp_type cmp_comp e.components

let remove_component e comp_type =
  { e with
    components = PMap.remove comp_type cmp_comp e.components;
  }

let iter_components e f =
  PMap.iterk f e.components

let get_components e =
  PMap.keys e.components

let cmp_components e comp_types =
  let comp_types_in = List.sort cmp_comp comp_types in
  let comp_types_e = PMap.keys e.components in
  Pervasives.compare comp_types_in comp_types_e

let components_match e comp_types =
  (cmp_components e comp_types) = 0


(** Mappers *)

(** mappers discriminate entities based on their component set *)

type 'comp_t mapper = {
  comp_t : 'comp_t list;
}


let mapper_match e mapper =
  has_components e mapper.comp_t


(** World *)

type ('a, 'b) world = {
  id_counter : int;
  entities : (id, ('a, 'b) entity) PMap.t;
  mappers : 'a mapper list;
}


let new_world () =
  {
    id_counter = 0;
    entities = PMap.empty;
    mappers = [];
  }


let add_entity w e =
  if e.id <> -1 then invalid_arg "add_entity";
  let id = w.id_counter in
  let e = { e with id } in
  { w with
    id_counter = w.id_counter + 1;
    entities = PMap.add id e cmp_e w.entities;
  }


let add_entity_id w e =
  if e.id <> -1 then invalid_arg "add_entity_id";
  let id = w.id_counter in
  let e = { e with id } in
  { w with
    id_counter = w.id_counter + 1;
    entities = PMap.add id e cmp_e w.entities;
  }, id


let remove_entity w e =
  { w with
    entities = PMap.remove e.id cmp_e w.entities;
  }

let remove_entity_id w id =
  { w with
    entities = PMap.remove id cmp_e w.entities;
  }


let add_mapper w comp_t =  (* TODO *)
  let mapper = { comp_t } in
  let w = { w with mappers = mapper :: w.mappers } in
  (w, mapper)


let get_entity w id =
  PMap.find id cmp_e w.entities

let get_entity_opt w id =
  PMap.find_opt id cmp_e w.entities

let num_entities w =
  PMap.cardinal w.entities

let has_entity w id =
  PMap.mem id cmp_e w.entities

let iter_entities f w =
  PMap.iter f w.entities

let fold_entities f w acc =
  PMap.fold f w.entities acc

let add_entities w es =
  List.fold_left add_entity w es

let add_entities_ar w er =
  Array.fold_left add_entity w er

let add_entities_init ~w ~n ~f =
  let er = Array.init n f in
  add_entities_ar w er

let _add_entities_id w es =
  List.fold_left (fun (w, acc) e ->
    let w, id = add_entity_id w e in
    (w, id::acc)
  ) (w, []) es

let add_entities_id w es =
  let w, ids = _add_entities_id w es in
  (w, List.rev ids)

let add_entities_id_ar w er =
  let n = Array.length er in
  let ids = Array.make n (-1) in
  let wr = ref w in
  for i = 0 to n - 1 do
    let e = Array.unsafe_get er i in
    let w, id = add_entity_id !wr e in
    wr := w;
    Array.unsafe_set ids i id;
  done;
  (!wr, ids)


let put_entity w id e =
  { w with
    entities = PMap.add id e cmp_e w.entities;
  }

let replace_entity w id e =
  if not (has_entity w id) then invalid_arg "replace_entity";
  if e.id <> id then invalid_arg "replace_entity";
  put_entity w id e


let num_entities_with_components w comp_types =
  fold_entities (fun e n ->
    if has_components e comp_types then n + 1 else n
  ) w 0

let get_entities_with_components w comp_types =
  fold_entities (fun e acc ->
    if has_components e comp_types then e::acc else acc
  ) w []

let get_entities w ids =
  List.fold_left (fun acc id ->
    match get_entity_opt w id with
    | Some e -> e :: acc
    | None -> acc
  ) [] (List.rev ids)

let do_get_entities w ids =
  List.fold_left (fun acc id ->
    let e = get_entity w id in
    (e :: acc)
  ) [] (List.rev ids)


(** System types *)

type 'a update =
  | Identical       (* no components changed *)
  | Updated of 'a   (* the value of some components where updated *)
  | Replace of 'a   (* some components were added and/or removed *)
  | Removed         (* remove this entity *)


type ('a, 'b, 'delta) system =
  ('a, 'b) entity ->
  ('a, 'b) world ->
  'delta ->
      ('a, 'b) entity update *
      ('a, 'b) entity list


type ('a, 'b, 'delta, 'fld) foldable_system =
  ('a, 'b) entity ->
  ('a, 'b) world ->
  'delta ->
  'fld ->
      ('a, 'b) entity update *
      ('a, 'b) entity list *
      'fld


(* the heart beat is here *)

type ('comp_t, 'comp, 'fld) born_feedback_func =
  ('comp_t, 'comp) world ->
  ('comp_t, 'comp) entity ->
  id list ->
  'fld ->
  ('comp_t, 'comp) world * 'fld



let world_step w system mapper delta =
  PMap.foldk
    (fun id e w ->
      if not (mapper_match e mapper) then w else
      let this_e, born = system e w delta in
      let w = add_entities w born in
      match this_e with
      | Identical -> (w)
      | Updated e -> (put_entity w id e)
      | Replace e -> (put_entity w id e)
      | Removed -> (remove_entity w e)
    )
    w.entities
    w


let world_step_fold w system mapper ?fb delta acc =
  PMap.foldk
    (fun id e ((w, acc) as wacc) ->
      if not (mapper_match e mapper) then wacc else
      let this_e, born, acc = system e w delta acc in
      let w, acc =
        if born = [] then (w, acc) else
        match fb with
        | None ->
            (add_entities w born, acc)
        | Some feedback ->
            let w, ids = add_entities_id w born in
            feedback w e ids acc
      in
      match this_e with
      | Identical -> (w, acc)
      | Updated e -> (put_entity w id e, acc)
      | Replace e -> (put_entity w id e, acc)
      | Removed -> (remove_entity w e, acc)
    )
    w.entities
    (w, acc)
