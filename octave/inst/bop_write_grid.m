function bop_write_grid(D, n, o, s, fn)
  ## D: structure with data : ex: D.vx(1:n(X), 1:n(Y), 1:n(Z))
  ## n(1:3): size, o(1:3) : origin, s(1:3) : spacing
  ## fn: file name
  global e_c e_m # error code and message
  f = fopen(fn, "w");
  if f == -1
    e_m = sprintf("cannot write to %s", fn);
    e_c = 1;
    return
  endif
  grid(D, n, o, s, f)
  fclose(f);
endfunction

## write gird data to vtk : node centered
function grid(D, n, o, s, f)
  global e_c e_m # error code and message

  if !isstruct(D) ; e_m = "not a structure"; e_c = 1; return; endif
  if numel(n) != 3; e_m = "wrong n"        ; e_c = 1; return; endif
  if numel(o) != 3; e_m = "wrong o"        ; e_c = 1; return; endif
  if numel(s) != 3; e_m = "wrong s"        ; e_c = 1; return; endif

  header(f)
  topology(f, n, o, s);

  l = fieldnames(D);
  nv = numel(l);
  if nv == 0; return; endif

  data_header(f, n)
  for i=1:nv; i = l{i}; scalar(f, D.(i), n, i); endfor
endfunction

function scalar(f, D, n, name)
  X = 1; Y = 2; Z = 3;
  nn = n(X)*n(Y)*n(Z);

  type = "double";
  fprintf(f, "\n");
  fprintf(f, "SCALARS %s %s\n", name, type)
  fprintf(f, "LOOKUP_TABLE default\n")

  skip = 0; arch = "ieee-be";
  fwrite(f, D(:), type, skip, arch);
  # dlmwrite(f, D(:), '\n');
endfunction

function data_header(f, n)
  X = 1; Y = 2; Z = 3;
  nn = n(X)*n(Y)*n(Z);
  fprintf(f, "POINT_DATA %ld", nn);
endfunction

function header(f)
  fprintf(f, "# vtk DataFile Version 2.0\n")
  fprintf(f, "created with bop_write_grid\n")
  # fprintf(f, "ASCII\n")
  fprintf(f, "BINARY\n");
endfunction

function topology(f, n, o, s)
  X = 1; Y = 2; Z = 3;
  fprintf(f, "DATASET STRUCTURED_POINTS\n")
  fprintf(f, "DIMENSIONS %ld %ld %ld\n", n(X), n(Y), n(Z))
  fprintf(f, "ORIGIN  %.9g %.9g %.9g\n", o(X), o(Y), o(Z))
  fprintf(f, "SPACING %.9g %.9g %.9g\n", s(X), s(Y), s(Z))
endfunction
