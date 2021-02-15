OCAML := ocaml
OCAMLC := ocamlc
OCAMLOPT := ocamlopt -g
OCAMLDEP := ocamldep

ENT_DIR := ../src/
ENT_INC := -I $(ENT_DIR)

WIN_DIR :=
WIN_FLD_DIR :=
WIN_INC := -I $(WIN_DIR) -I $(WIN_FLD_DIR)

W_WIN_LIBS :=
WIN_LIBS := $(W_WIN_LIBS) windowing.cma

VIEW_DIR :=

PARAMS :=

WIN_LIBS_X := $(patsubst %.cma, %.cmxa, $(WIN_LIBS))

all: run

.PHONY: dep
dep: depend.mk

-include depend.mk
depend.mk:
	$(OCAMLDEP) *.ml *.mli view_*/*.ml view_*/*.mli > $@

.PHONY: comp
comp: comp.cmo

comp.ml: comp.ent comp_before.ml
	cat comp_before.ml > $@
	$(OCAML) $(ENT_DIR)/gen_comp.ml -ml $< >> $@

comp.mli: comp.ent comp_before.mli
	cat comp_before.mli > $@
	$(OCAML) $(ENT_DIR)/gen_comp.ml -mli $< >> $@

vars.cmi: vars.mli
	$(OCAMLC) -c $<
vars.cmo: vars.ml vars.cmi
	$(OCAMLC) -c $<
vars.cmx: vars.ml vars.cmi
	$(OCAMLOPT) -c $<

comp.cmi: comp.mli
	$(OCAMLC) -c $(ENT_INC) $<
comp.cmo: comp.ml comp.cmi
	$(OCAMLC) -c $(ENT_INC) $<
comp.cmx: comp.ml comp.cmi
	$(OCAMLOPT) -c $(ENT_INC) $<

state.cmi: state.mli vars.cmi
	$(OCAMLC) -c $(ENT_INC) $<
state.cmo: state.ml state.cmi
	$(OCAMLC) -c $(ENT_INC) $<
state.cmx: state.ml state.cmi
	$(OCAMLOPT) -c $(ENT_INC) $<

app.cmi: app.mli state.cmi
	$(OCAMLC) -c $(ENT_INC) $(WIN_INC) $<
app.cmo: app.ml app.cmi
	$(OCAMLC) -c $(ENT_INC) $(WIN_INC) $<
app.cmx: app.ml app.cmi
	$(OCAMLOPT) -c $(ENT_INC) $(WIN_INC) $<

view.cmi: $(VIEW_DIR)/view.mli state.cmi app.cmi
	$(OCAMLC) -c $(ENT_INC) $(WIN_INC) -o $@ $<
view.cmo: $(VIEW_DIR)/view.ml view.cmi
	$(OCAMLC) -c $(ENT_INC) $(WIN_INC) -o $@ $<
view.cmx: $(VIEW_DIR)/view.ml view.cmi
	$(OCAMLOPT) -c $(ENT_INC) $(WIN_INC) -o $@ $<

control.cmi: control.mli state.cmi app.cmi
	$(OCAMLC) -c $(ENT_INC) $(WIN_INC) $<
control.cmo: control.ml control.cmi
	$(OCAMLC) -c $(ENT_INC) $(WIN_INC) $<
control.cmx: control.ml control.cmi
	$(OCAMLOPT) -c $(ENT_INC) $(WIN_INC) $<

.PHONY: run
run: comp.cmo vars.cmo state.cmo app.cmo view.cmo control.cmo
	$(OCAML) bigarray.cma \
	  $(ENT_INC) ent.cma \
	  $(WIN_INC) \
	  $(WIN_LIBS) \
	  \
	  comp.cmo vars.cmo state.cmo app.cmo view.cmo control.cmo \
	  main.ml $(PARAMS)

.PHONY: opt
opt: expser.opt
	./$< $(PARAMS)

expser.opt: comp.cmx vars.cmx state.cmx app.cmx view.cmx control.cmx
	$(OCAMLOPT) bigarray.cmxa \
	  $(ENT_INC) ent.cmxa \
	  $(WIN_INC) \
	  $(WIN_LIBS_X) \
	  \
	  comp.cmx vars.cmx state.cmx app.cmx view.cmx control.cmx \
	  main.ml -o $@

OCAMLDOC := ocamldoc
OCAMLDOC_PRM := -html

.PHONY: doc
doc: comp.mli
	mkdir -p doc
	$(OCAMLDOC) -d doc $(OCAMLDOC_PRM) \
	    $(ENT_INC) \
	    $(WIN_INC) \
	    vars.mli \
	    comp.mli \
	    state.mli \
	    app.mli \
	    $(VIEW_DIR)/view.mli \
	    control.mli

.PHONY: clean_comp
clean_comp: clean
	$(RM) comp.ml comp.mli

.PHONY: clean
clean:
	$(RM) *.cm[ioxa] *.[oa] *.cmx[as] *.opt *.exe *.byte

.PHONY: clean_all
clean_all: clean_comp clean
