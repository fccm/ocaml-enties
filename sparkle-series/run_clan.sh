make opt \
  -f Makefile.mk \
  WIN_DIR="../../ocaml-clanlib/src/" \
  W_WIN_LIBS="clanlib_core.cmxa clanlib_display.cmxa clanlib_gl.cmxa" \
  WIN_FLD_DIR="../win_clan/" \
  VIEW_DIR="./view_clan/"
  PARAMS="$*"
