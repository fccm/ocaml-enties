OCAMLOPT := ocamlopt -g

CLAN_DIR := ../../ocaml-clanlib/src/
INC := -I $(CLAN_DIR)
LIBS := clanlib_core.cmxa clanlib_display.cmxa clanlib_gl.cmxa

windowing.cmxa: windowing.cmx
	$(OCAMLOPT) -a -o $@ $<

windowing.cmi: windowing.mli
	$(OCAMLOPT) -c \
	  $(INC) \
	  $(LIBS) \
	  $<

windowing.cmx: windowing.ml windowing.cmi
	$(OCAMLOPT) -c \
	  $(INC) \
	  $(LIBS) \
	  $<

#	  -ccopt "-lstdc++" \
.PHONY: clean
clean:
	$(RM) *.cm[ioxa] *.[oa] *.cmx[as] *.opt *.exe *.byte
