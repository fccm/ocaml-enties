OCAMLC := ocamlc -g
OCAMLOPT := ocamlopt -g
OCAML_SFML_DIR := ../../ocaml-sfml-2.0/src/
OCAML_SFML_INC := -I $(OCAML_SFML_DIR)

.PHONY: all
all: windowing.cma windowing.cmxa windowing.cmxs

windowing.cmi: windowing.mli
	$(OCAMLC) -c $(OCAML_SFML_INC) $<

windowing.cmo: windowing.ml windowing.cmi
	$(OCAMLC) -c $(OCAML_SFML_INC) $<

windowing.cmx: windowing.ml windowing.cmi
	$(OCAMLOPT) -c $(OCAML_SFML_INC) $<

windowing.cma: windowing.cmo
	$(OCAMLC) -a -o $@ $<

windowing.cmxa: windowing.cmx
	$(OCAMLOPT) -a -o $@ $<

windowing.cmxs: windowing.ml
	$(OCAMLOPT) -shared -o $@ $(OCAML_SFML_INC) $<

.PHONY: doc
doc:
	mkdir -p doc
	ocamldoc -d doc -html $(OCAML_SFML_INC) windowing.mli

.PHONY: clean
clean:
	$(RM) *.cm[ioxa] *.[oa] *.cmx[as] *.opt *.exe *.byte
