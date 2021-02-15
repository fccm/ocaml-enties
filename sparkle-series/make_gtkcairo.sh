make opt \
  -f Makefile.mk \
  WIN_INC="-I +lablgtk2 -I +cairo" \
  W_WIN_LIBS="unix.cmxa lablgtk.cmxa cairo.cmxa cairo_lablgtk.cmxa gtkInit.cmx" \
  WIN_FLD_DIR="./" \
  VIEW_DIR="./view_gtkcairo/"
  PARAMS="$*"
