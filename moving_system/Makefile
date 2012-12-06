OCAML := ocaml
OCAMLC := ocamlc
OCAMLOPT := ocamlopt

ENT_DIR := ../src/
ENT_INC := -I $(ENT_DIR)

SFML_DIR := ../../ocaml-sfml-2.0/src/
SFML_INC := -I $(SFML_DIR)

FWIN_DIR := ../win_sfml/
FWIN_INC := -I $(FWIN_DIR)

WIN_INC := $(SFML_INC) $(FWIN_INC)

all: run

.PHONY: comp
comp: comp.cmo

comp.ml: comp.ent \
  comp_before.ml
	cat comp_before.ml > $@
	ocaml $(ENT_DIR)/gen_comp.ml -ml $< >> $@

comp.mli: comp.ent \
  comp_before.mli
	cat comp_before.mli > $@
	ocaml $(ENT_DIR)/gen_comp.ml -mli $< >> $@

comp.cmi: comp.mli
	$(OCAMLC) -c $(ENT_INC) $<
comp.cmo: comp.ml comp.cmi
	$(OCAMLC) -c $(ENT_INC) $<
comp.cmx: comp.ml comp.cmi
	$(OCAMLOPT) -c $(ENT_INC) $<

view.cmi: view.mli state.cmi comp.cmi
	$(OCAMLC) -c $(ENT_INC) $(WIN_INC) $<
view.cmo: view.ml view.cmi comp.cmi
	$(OCAMLC) -c $(ENT_INC) $(WIN_INC) $<
view.cmx: view.ml view.cmi comp.cmi
	$(OCAMLOPT) -c $(ENT_INC) $(WIN_INC) $<

state.cmi: state.mli comp.cmi
	$(OCAMLC) -c $(ENT_INC) $<
state.cmo: state.ml state.cmi comp.cmi
	$(OCAMLC) -c $(ENT_INC) $<
state.cmx: state.ml state.cmi comp.cmi
	$(OCAMLOPT) -c $(ENT_INC) $<

.PHONY: run
run: state.cmo view.cmo comp.cmo
	$(OCAML) \
	  $(ENT_INC) \
	  ent.cma \
	  bigarray.cma \
	  $(SFML_INC) \
	  sfml_system.cma \
	  sfml_window.cma \
	  sfml_graphics.cma \
	  $(FWIN_INC) \
	  windowing.cma \
	  comp.cmo \
	  state.cmo \
	  view.cmo \
	  main.ml $*

.PHONY: stress
stress: stress.opt
	./$<

stress.opt: stress.ml state.cmx comp.cmx
	$(OCAMLOPT) \
	  $(ENT_INC) \
	  unix.cmxa \
	  ent.cmxa \
	  comp.cmx \
	  state.cmx \
	  $< -o $@

.PHONY: clean_comp
clean_comp: clean
	$(RM) comp.ml comp.mli

.PHONY: clean
clean:
	$(RM) *.cm[ioxa] *.[oa] *.cmx[as] *.opt *.exe *.byte

.PHONY: clean_all
clean_all: clean_comp clean
