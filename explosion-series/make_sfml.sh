make \
  -f Makefile.mk \
  WIN_DIR="../../ocaml-sfml/src/" \
  W_WIN_LIBS="sfml_system.cma sfml_window.cma sfml_graphics.cma" \
  WIN_FLD_DIR="../win_sfml/" \
  VIEW_DIR="./view_sfml/" \
  $*
