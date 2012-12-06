OCAMLC := ocamlc -g
OCAMLOPT := ocamlopt -g

.PHONY: all
all: pSet.cma pSet.cmxa pSet.cmxs

.SECONDARY:

%.cmi: %.mli
	$(OCAMLC) -c $<

%.cmo: %.ml %.cmi
	$(OCAMLC) -c $<

%.cmx: %.ml %.cmi
	$(OCAMLOPT) -c $<

%.cma: %.cmo
	$(OCAMLC) -a -o $@ $<

%.cmxa: %.cmx
	$(OCAMLOPT) -a -o $@ $<

%.cmxs: %.cmxa
	$(OCAMLOPT) -shared -linkall -o $@ -ccopt -L. $<

.PHONY: clean
clean:
	$(RM) *.cm[ioxa] *.[oa] *.cmx[as]
