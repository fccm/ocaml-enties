OCAMLC := ocamlc -g
OCAMLOPT := ocamlopt -g
OCAML_SDL_DIR := $(HOME)/home/ocaml-sdl/ocamlsdl-0.9.1/src/
OCAML_SDL_INC := -I $(OCAML_SDL_DIR)

.PHONY: all
all: windowing.cma windowing.cmxa windowing.cmxs

windowing.cmi: windowing.mli
	$(OCAMLC) -c $(OCAML_SDL_INC) $<

windowing.cmo: windowing.ml windowing.cmi
	$(OCAMLC) -c $(OCAML_SDL_INC) $<

windowing.cmx: windowing.ml windowing.cmi
	$(OCAMLOPT) -c $(OCAML_SDL_INC) $<

windowing.cma: windowing.cmo
	$(OCAMLC) -a -o $@ $<

windowing.cmxa: windowing.cmx
	$(OCAMLOPT) -a -o $@ $<

windowing.cmxs: windowing.ml
	$(OCAMLOPT) -shared -o $@ $(OCAML_SDL_INC) $<

.PHONY: doc
doc:
	mkdir -p doc
	ocamldoc -d doc -html $(OCAML_SDL_INC) windowing.mli

.PHONY: clean
clean:
	$(RM) *.cm[ioxa] *.[oa] *.cmx[as] *.opt *.exe *.byte
