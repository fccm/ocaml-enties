type id = Ent.id

type entity = Comp.entity

type world = Comp.world

type mapper = Comp.component_type Ent.mapper

type 'a update = 'a Ent.update

type ('a) system =
  (Comp.component_type, Comp.component, 'a) Ent.system

type ('delta, 'fld) foldable_system =
  (Comp.component_type, Comp.component, 'delta, 'fld) Ent.foldable_system

type 'fld born_feedback_func =
  (Comp.component_type, Comp.component, 'fld) Ent.born_feedback_func


let new_entity          = Ent.new_entity
let get_id              = Ent.get_id
let get_id_opt          = Ent.get_id_opt

let has_component       = Ent.has_component
let has_components      = Ent.has_components
let has_any_component   = Ent.has_any_component
let iter_components     = Ent.iter_components
let get_components      = Ent.get_components
let cmp_components      = Ent.cmp_components
let components_match    = Ent.components_match

let new_world           = Ent.new_world

let add_entity          = Ent.add_entity
let add_entities        = Ent.add_entities
let add_entity_id       = Ent.add_entity_id
let add_entities_id     = Ent.add_entities_id
let add_entities_init   = Ent.add_entities_init
let add_entities_ar     = Ent.add_entities_ar
let add_entities_id_ar  = Ent.add_entities_id_ar

let has_entity          = Ent.has_entity
let replace_entity      = Ent.replace_entity
let remove_entity       = Ent.remove_entity
let remove_entity_id    = Ent.remove_entity_id
let get_entity          = Ent.get_entity
let get_entity_opt      = Ent.get_entity_opt
let get_entities        = Ent.get_entities
let do_get_entities     = Ent.do_get_entities
let get_entities_with_components = Ent.get_entities_with_components

let iter_entities       = Ent.iter_entities
let fold_entities       = Ent.fold_entities
let num_entities        = Ent.num_entities
let num_entities_with_components = Ent.num_entities_with_components

let add_mapper = Ent.add_mapper

let world_step = Ent.world_step
let world_step_fold = Ent.world_step_fold
