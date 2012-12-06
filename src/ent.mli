(** Entity/Component Oriented Game/Multimedia Module *)

(** {b Note:} This is an {i experimentation}, not a final work. *)


(** {3 Entities} *)

type id = int
(** id of an entity, entities have an id only after been added to the world *)

type ('component_type, 'component) entity
(** this is the base type of the [entity / component] concept

    the [component_type] is the key to access to the components *)

val new_entity : unit -> ('comp_t, 'comp) entity
(** generic game element *)

val get_id : ('comp_t, 'comp) entity -> id
(** raises an exception if the entity has not been added to the world *)

val get_id_opt : ('comp_t, 'comp) entity -> id option
(** same than [get_id] but returns None instead of raising an exception *)



(** {3 Components} *)

(** A component handles a property / attribute of an entity.

    An entity may have as many components as needed, but only
    one component of each type.
*)

val add_component :
  ('comp_t, 'comp) entity -> 'comp_t * 'comp -> ('comp_t, 'comp) entity
(** [add_component e (component_type, component_data)] *)

val replace_component :
  ('comp_t, 'comp) entity -> 'comp_t -> 'comp -> ('comp_t, 'comp) entity
(** [replace_component e component_type component_data] *)

val has_component : ('comp_t, 'comp) entity -> 'comp_t -> bool

val has_components : ('comp_t, 'comp) entity -> 'comp_t list -> bool
(** retruns true if the entity contains all the given component types

    (this function does not tell if the entity contains other components
    or not) *)

val has_any_component : ('comp_t, 'comp) entity -> 'comp_t list -> bool
(** returns true if the entity contains at least one of the given component
    types *)

val get_component : ('comp_t, 'comp) entity -> 'comp_t -> 'comp
(** raises [Not_found] if none found *)

val get_component_opt : ('comp_t, 'comp) entity -> 'comp_t -> 'comp option
(** returns [None] if has not the component *)

val remove_component : ('comp_t, 'comp) entity -> 'comp_t ->
  ('comp_t, 'comp) entity

val iter_components : ('comp_t, 'comp) entity ->
  ('comp_t -> 'comp -> unit) -> unit

val get_components : ('comp_t, 'comp) entity -> 'comp_t list
val cmp_components : ('comp_t, 'comp) entity -> 'comp_t list -> int
val components_match : ('comp_t, 'comp) entity -> 'comp_t list -> bool


(** {3 Constructors / Accessors / Modifiers} *)

(**
  Instead of using the previous [*component*] functions
  you may simplify your life, your code and save time by using
  the [gen_comp] command line tool that generates all the constructors,
  accessors and modifiers from the type definition of ['component].

  For example create a file ["comp.ent"] with:
{[
Alpha   int
Beta    float
Gamma   string
Delta   char
Epsilon bool
]}

  then generate the constructors, accessors and modifiers
  (and also printing functions for debuging) with:
{[
ocaml gen_comp.ml -ml comp.ent > comp.ml
ocaml gen_comp.ml -mli comp.ent > comp.mli
]}

  See the [HOWTO] section at the end for further informations.
*)


(** {3 World} *)

type ('comp_t, 'comp) world
(** the first type parameter is the [component_type]

  the second is the [component]

  for the third one see the doc of the function [world_step]

  and see [world_step_fold] about the ['fld] type *)

val new_world : unit -> ('a, 'b) world

val add_entity : ('a, 'b) world -> ('a, 'b) entity -> ('a, 'b) world
val add_entities : ('a, 'b) world -> ('a, 'b) entity list -> ('a, 'b) world

val add_entity_id : ('a, 'b) world -> ('a, 'b) entity -> ('a, 'b) world * id
(** same than [add_entity] but also return the id that was given to this entity
*)

val add_entities_id : ('a, 'b) world -> ('a, 'b) entity list ->
  ('a, 'b) world * id list

val add_entities_init : w:('a, 'b) world ->
  n:int -> f:(int -> ('a, 'b) entity) -> ('a, 'b) world

(**/**)

val add_entities_ar : ('a, 'b) world -> ('a, 'b) entity array -> ('a, 'b) world

val add_entities_id_ar : ('a, 'b) world -> ('a, 'b) entity array ->
  ('a, 'b) world * id array
(** it is sometimes more convenient to use arrays because we have functions like
    [Array.init] and [Array.make], while there are no equivalent in the [List]
    module *)

(**/**)

val has_entity : ('a, 'b) world -> id -> bool
(** does an entity exists with the given [id] *)

val replace_entity : ('a, 'b) world -> id -> ('a, 'b) entity -> ('a, 'b) world

val remove_entity : ('a, 'b) world -> ('a, 'b) entity -> ('a, 'b) world
val remove_entity_id : ('a, 'b) world -> id -> ('a, 'b) world


(** {3 World Getters} *)

val get_entity : ('a, 'b) world -> id -> ('a, 'b) entity
val get_entity_opt : ('a, 'b) world -> id -> ('a, 'b) entity option
(** get an entity by its id *)

val get_entities : ('a, 'b) world -> id list -> ('a, 'b) entity list
(** ids not found are just skipped *)

val do_get_entities : ('a, 'b) world -> id list -> ('a, 'b) entity list
(** raises [Not_found] if an id is not found *)

val get_entities_with_components :
  ('comp_t, 'comp) world -> 'comp_t list -> ('comp_t, 'comp) entity list


(** {3 World Iterators} *)

(** simple iterators not using any [mapper] *)

val iter_entities : (('a, 'b) entity -> unit) -> ('a, 'b) world -> unit
val fold_entities : (('a, 'b) entity -> 'p -> 'p) -> ('a, 'b) world -> 'p -> 'p
val num_entities : ('a, 'b) world -> int

val num_entities_with_components : ('comp_t, 'b) world -> 'comp_t list -> int


(** {3 Mappers} *)

(** a system will be only applied to the entities that contain
    all the component types of the associated mapper *)

type 'component_type mapper

val add_mapper :
  ('comp_t, 'b) world ->
  'comp_t list ->
      ('comp_t, 'b) world *
      'comp_t mapper


(** {3 Systems} *)

(** A [system] may update or remove entities, or create new ones, each time
    [world_step] is called. *)

type 'a update =
  | Identical       (** no components changed *)
  | Updated of 'a   (** the value of some components where updated *)
  | Replace of 'a   (** some components were added and/or removed *)
  | Removed         (** remove this entity *)


type ('comp_t, 'comp, 'delta) system =
  ('comp_t, 'comp) entity ->
  ('comp_t, 'comp) world ->
  'delta ->
      ('comp_t, 'comp) entity update *
      ('comp_t, 'comp) entity list
(** the first returned value should be the input entity with eventual changes
    and the second returned value is eventual new entities that should be added
    to the world *)


type ('a, 'b, 'delta, 'fld) foldable_system =
  ('a, 'b) entity ->
  ('a, 'b) world ->
  'delta ->
  'fld ->
      ('a, 'b) entity update *
      ('a, 'b) entity list *
      'fld
(** similar than [system] but a [foldable_system] has an additional folded
    parameter that can be given with [world_step_fold] *)



(** {3 World Step} *)

(** the heart beats here *)


type ('comp_t, 'comp, 'fld) born_feedback_func =
  ('comp_t, 'comp) world ->
  ('comp_t, 'comp) entity ->
  id list ->
  'fld ->
      ('comp_t, 'comp) world * 'fld
(** this callback is used to make parents aware of the ids of their newly born
    children (see [system] signature) *)


val world_step :
  ('a, 'b) world ->
  ('a, 'b, 'delta) system ->
  'a mapper ->
  'delta ->
  ('a, 'b) world
(** ['delta] is the input parameter that is given to the systems *)


val world_step_fold :
  ('a, 'b) world ->
  ('a, 'b, 'delta, 'fld) foldable_system ->
  'a mapper ->
  ?fb:('a, 'b, 'fld) born_feedback_func ->
  'delta ->
  'fld ->
  ('a, 'b) world * 'fld
(** same than [world_step] but with an additional folded parameter ['fld],
    see [foldable_system]s *)



(* ================================================================ *)


(** {3 Example} *)

(** Here is an example without using the [gen_comp] helper tool: *)

(**
{[
type component_type =
  | Level_t
  | Name_t

type component =
  | Level of int
  | Name of string

let make_entity level name =
  let e = Ent.new_entity () in
  let e = Ent.add_component e (Name_t, Name name) in
  let e = Ent.add_component e (Level_t, Level level) in
  (e)

let get_level e =
  match Ent.get_component e Level_t with
  | Level level -> level
  | _ -> failwith "get_level"

let bump_system_comps = [Level_t]

let bump_system e w bump =
  let level = get_level e in
  let e = Ent.replace_component e Level_t (Level (level + bump)) in
  (Ent.Updated e, [])

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
  let w, bump_system_mapper = Ent.add_mapper w bump_system_comps in
  let w =
    Ent.world_step w
      bump_system
      bump_system_mapper
      1
  in
  Ent.iter_entities (fun e ->
    Printf.printf "Entity: %s %s\n" (name_string e) (level_string e)
  ) w
]}

  Running this example:
{[
$ ocaml -I $ENT_DIR ent.cma example.ml
Entity: name=dummy-A level=2
Entity: name=dummy-B level=7
]}

  This example uses only this module.

  Even with a small example like this one, you can see that the functions
  to set and get the component values are not very elegant.
  This is why there is the [gen_comp] command line tool to generate
  functions to simplify components management.
  Read the following Howto to see how to do this.
*)



(* ================================================================ *)


(** {3 HOWTO} *)

(**
  Here is how to create a [Comp] module to manage the components.

  You can generate the constructors, accessors and modifiers
  from the type definition of the [component]s.

  This type definition is not written in ocaml, but in a simplified way.
  Here is an example with the file ["comp.ent"]:

{[
$ cat comp.ent
Position  xy
Velocity  xy
]}

  You need to define each type of this [*.ent] file,
  and [string_of_*] functions:

{[
$ cat comp_before.mli
type xy = float * float
]}

{[
$ cat comp_before.ml
type xy = float * float

let string_of_xy (x, y) =
  Printf.sprintf "(%g, %g)" x y
]}

  Generate and compile this [Comp] module
  using the provided [gen_comp] command line tool:

{[
cat comp_before.mli > comp.mli
cat comp_before.ml > comp.ml

ocaml gen_comp.ml -mli comp.ent >> comp.mli
ocaml gen_comp.ml -ml comp.ent >> comp.ml

ocamlc -c -I $ENT_DIR comp.mli
ocamlc -c -I $ENT_DIR comp.ml
]}

  Now you can write your main code:

{[
let fps = 30  (* frames per second *)
let dt = 1.0 /. float fps  (* elapsed time between 2 frames *)

(* make n loops *)
let rec loops n f w =
  if n <= 0 then w else
    let w = f w in
    loops (n-1) f w

let move_entity (x, y) (vx, vy) dt =
  (x +. vx *. dt,
   y +. vy *. dt)

(* define which components needs moving_system *)
let moving_system_comps =
  [Comp.Position_t; Comp.Velocity_t]

let moving_system e w dt =
  let pos = Comp.get_position e in
  let vel = Comp.get_velocity e in
  let new_pos = move_entity pos vel dt in
  let e = Comp.update_position e new_pos in
  Ent.Updated e, []

let make_entity pos vel =
  let e = Ent.new_entity () in
  let e = Comp.add_position e pos in
  let e = Comp.add_velocity e vel in
  (e)

let () =
  let e1 = make_entity (2.0, 3.0) (0.1, 0.1) in
  let e2 = make_entity (5.0, 6.0) (0.1, 0.2) in
  let w = Ent.new_world () in
  let w = Ent.add_entities w [e1; e2] in
  let w, moving_system_mapper =
    Ent.add_mapper w moving_system_comps
  in
  let step w =
    Ent.world_step w
      moving_system
      moving_system_mapper
      dt
  in
  let w = loops fps step w in  (* loop for 1 second *)
  Comp.print_entities w
]}

  Run this code:

{[
$ ocaml -I $ENT_DIR ent.cma comp.cmo howto.ml
Entity:
  Position_t  Position (2.1, 3.1)
  Velocity_t  Velocity (0.1, 0.1)

Entity:
  Position_t  Position (5.1, 6.2)
  Velocity_t  Velocity (0.1, 0.2)
]}

*)



(* ================================================================ *)


(** {3 Units Creation} *)

(**
  In order to simplify the creation of different units
  there is the command line tool [gen_units].

  It generates the code of a function to create each unit
  from a simple description file.

  This description file has one unit description by line.
  Each line contains several elements separated by tabulations.
  The first element of the line is the unit name.
  All the following elements define the components of this unit.

  Here is an example:
{[
my_item  Position  Velocity
]}

  Generate the code from this unit description using the
  [gen_units] command line tool:
{[
$ ocaml gen_units.ml units.def > units.ml
]}

  Here is the generated function:
{[
val make_my_item : Comp.xy -> Comp.xy -> Comp.entity
]}

  The generated code of this function is:
{[
let make_my_item position velocity =
  let e = Ent.new_entity () in
  let e = Comp.add_position e position in
  let e = Comp.add_velocity e velocity in
  (e)
]}

  The generated [Comp] module (see the previous section)
  needs to be compiled before this [Units] module.
*)

(** {b More details for units description}

  To create labels for the parameters of the generated functions:
{[
static_item  pos:Position
moving_item  pos:Position  vel:Velocity
]}

  Here the function won't have any parameter for velocity,
  and the function will add a [Velocity] component with the
  given value:
{[
falling_item  pos:Position  Velocity=(0.0, -0.2)
]}

  This given value may be a function call:
{[
random_item  Position=(rand_pos ())  Velocity=(rand_vel ())
]}

  Parameters with a default value:
{[
item_defaults  ?pos:Position=(0.0, 0.0)  ?vel:Velocity=(0.0, 0.0)
]}

  If initialisation functions are used you can put these in
  an other file [units_init_funcs.ml] and compile everything (after
  the [Comp] module) like this:
{[
$ echo "open Units_init_funcs" > units.ml
$ ocaml gen_units.ml units.def >> units.ml
$ ocamlc -c units_init_funcs.ml
$ ocamlc -c -I $ENT_DIR units.ml
]}

*)
