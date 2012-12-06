(** Entity/Component Oriented Game/Multimedia Module *)

(** {b Note:} This is an {i experimentation}, not a final work. *)


(** {3 Entities} *)

type id = Ent.id
(** id of an entity, entities have an id only after been added to the world *)

type entity = Comp.entity
(** this is the base type of the [entity / component] concept *)

val new_entity : unit -> entity
(** generic game element *)

val get_id : entity -> id
(** raises an exception if the entity has not been added to the world *)

val get_id_opt : entity -> id option
(** same than [get_id] but returns None instead of raising an exception *)



(** {3 Components} *)

(** A component handles a property / attribute of an entity.

    An entity may have as many components as needed, but only
    one component of each type.
*)

val has_component : entity -> Comp.component_type -> bool

val has_components : entity -> Comp.component_type list -> bool
(** retruns true if the entity contains all the given component types

    (this function does not tell if the entity contains other components
    or not) *)

val has_any_component : entity -> Comp.component_type list -> bool
(** returns true if the entity contains at least one of the given component
    types *)

val iter_components : entity ->
  (Comp.component_type -> Comp.component -> unit) -> unit

val get_components : entity -> Comp.component_type list
val cmp_components : entity -> Comp.component_type list -> int
val components_match : entity -> Comp.component_type list -> bool


(** {3 Constructors / Accessors / Modifiers} *)

(**
  The constructors, accessors and modifiers are in the module [Comp],
  which have been generated (from the type definition of [component])
  with the [gen_comp] command line tool.
*)


(** {3 World} *)

type world = Comp.world
(** for the ['delta] type parameter see the doc of the function [world_step]

  and see [world_step_fold] about the ['fld] type *)

val new_world : unit -> world

val add_entity : world -> entity -> world
val add_entities : world -> entity list -> world

val add_entity_id : world -> entity -> world * id
(** same than [add_entity] but also return the id that was given to this entity
*)

val add_entities_id : world -> entity list ->
  world * id list

val add_entities_init : w:world ->
  n:int -> f:(int -> entity) -> world

(**/**)

val add_entities_ar : world -> entity array -> world

val add_entities_id_ar : world -> entity array ->
  world * id array
(** it is sometimes more convenient to use arrays because we have functions like
    [Array.init] and [Array.make], while there are no equivalent in the [List]
    module *)

(**/**)

val has_entity : world -> id -> bool
(** does an entity exists with the given [id] *)

val replace_entity : world -> id -> entity -> world

val remove_entity : world -> entity -> world
val remove_entity_id : world -> id -> world


(** {3 World Getters} *)

val get_entity : world -> id -> entity
val get_entity_opt : world -> id -> entity option
(** get an entity by its id *)

val get_entities : world -> id list -> entity list
(** ids not found are just skipped *)

val do_get_entities : world -> id list -> entity list
(** raises [Not_found] if an id is not found *)

val get_entities_with_components :
  world -> Comp.component_type list -> entity list


(** {3 World Iterators} *)

val iter_entities : (entity -> unit) -> world -> unit
val fold_entities : (entity -> 'p -> 'p) -> world -> 'p -> 'p
val num_entities : world -> int

val num_entities_with_components : world -> Comp.component_type list -> int


(** {3 Mappers} *)

(** a system will be only applied to the entities that contain
    all the component types of the associated mapper *)

type mapper = Comp.component_type Ent.mapper

val add_mapper :
  world ->
  Comp.component_type list ->
    world * mapper


(** {3 Systems} *)

(** A [system] may update or remove entities, or create new ones, each time
    [world_step] is called. *)

type 'a update = 'a Ent.update

type ('delta) system =
  (Comp.component_type, Comp.component, 'delta) Ent.system
(** the first returned value should be the input entity with eventual changes
    and the second returned value is eventual new entities that should be added
    to the world *)


(** {3 Foldable Systems} *)

type ('delta, 'fld) foldable_system =
  (Comp.component_type, Comp.component, 'delta, 'fld) Ent.foldable_system
(** similar than [system] but a [foldable_system] has an additional folded
    parameter that can be given with [world_step_fold] *)


(** {3 World Step} *)

(** the heart beats here *)

type 'fld born_feedback_func =
  (Comp.component_type, Comp.component, 'fld) Ent.born_feedback_func


val world_step :
  world ->
  'delta system ->
  mapper ->
  'delta ->
  world
(** ['delta] is the input parameter that is given to the systems *)


val world_step_fold :
  world ->
  ('delta, 'fld) foldable_system ->
  mapper ->
  ?fb:'fld born_feedback_func ->
  'delta ->
  'fld ->
  world * 'fld
(** same than [world_step] but with an additional folded parameter ['fld],
    see [foldable_system]s *)

