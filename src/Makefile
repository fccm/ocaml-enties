OCAML := ocaml
OCAMLC := ocamlc -g
OCAMLOPT := ocamlopt -g

.PHONY: all
all: ent.cmi ent.cmo ent.cma ent.cmxa ent.cmxs

.SECONDARY:

ent.cmi: ent.mli ../poly_map/pMap.cmi

ent.cmx: ent.ml ent.cmi ../poly_map/pMap.cmx
	$(OCAMLOPT) -c -I ../poly_map $<
ent.cmo: ent.ml ent.cmi ../poly_map/pMap.cmo
	$(OCAMLC) -c -I ../poly_map $<

ent.cma: ../poly_map/pMap.cmo ent.cmo
	$(OCAMLC) -a -o $@ -I ../poly_map $^

ent.cmxa: ../poly_map/pMap.cmx ent.cmx
	$(OCAMLOPT) -a -o $@ -I ../poly_map $^


../poly_map/pMap.cmi: ../poly_map/pMap.mli
	$(MAKE) -C ../poly_map/ $(shell basename $@)
../poly_map/pMap.cmx: ../poly_map/pMap.ml ../poly_map/pMap.cmi
	$(MAKE) -C ../poly_map/ $(shell basename $@)
../poly_map/pMap.cmo: ../poly_map/pMap.ml ../poly_map/pMap.cmi
	$(MAKE) -C ../poly_map/ $(shell basename $@)


%.ml: %.ent
	$(OCAML) gen_comp.ml -ml $< > $@
%.mli: %.ent
	$(OCAML) gen_comp.ml -mli $< > $@

%.ml: %.unt
	$(OCAML) gen_units.ml comp.ent $< -ml > $@
%.mli: %.unt
	$(OCAML) gen_units.ml comp.ent $< -mli > $@

.PHONY: comp clean_comp
comp: comp.cmo
clean_comp:
	$(RM) comp.ml comp.mli

.PHONY: unit clean_unit
unit: unit.cmo
clean_unit:
	$(RM) unit.ml unit.mli

.PHONY: stress
stress: stress.opt
	./$<
stress.opt: stress.ml ent.cmxa
	$(OCAMLOPT) unix.cmxa ent.cmxa $< -o $@


%.cmi: %.mli
	$(OCAMLC) -c $<

%.cmo: %.ml %.cmi
	$(OCAMLC) -c $<

%.cmx: %.ml
	$(OCAMLOPT) -c $<

%.cmx: %.ml %.cmi
	$(OCAMLOPT) -c $<

%.cma: %.cmo
	$(OCAMLC) -a -o $@ $<

%.cmxa: %.cmx
	$(OCAMLOPT) -a -o $@ $<

%.cmxs: %.cmxa
	$(OCAMLOPT) -shared -linkall -o $@ -ccopt -L. $<

OCAMLDOC := ocamldoc
OCAMLDOC_PRM := -html

.PHONY: doc
doc:
	mkdir -p doc
	$(OCAMLDOC) -d doc $(OCAMLDOC_PRM) ent.mli \
	  cEnt.mli \
	  uEnt.mli \
	  comp.mli unit.mli

.PHONY: clean_doc
clean_doc:
	$(RM) doc/*
	rmdir doc

.PHONY: clean
clean:
	$(RM) *.cm[ioxa] *.[oa] *.cmx[as] *.opt *.exe *.byte

.PHONY: clean_all
clean_all: clean clean_comp clean_unit clean_doc
