make \
  -f Makefile.mk \
  WIN_DIR="$HOME/home/ocaml-sdl/ocamlsdl-0.9.1/src/" \
  W_WIN_LIBS="sdl.cma sdlttf.cma sdlgfx.cma" \
  WIN_FLD_DIR="../win_sdl/" \
  VIEW_DIR="./view_sdl/" \
  $*
