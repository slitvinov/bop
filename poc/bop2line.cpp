/* Usage:
  bop2line <n> <o> <s>  <in1.bop> <in2.bop>
  bop2line 64 0.0 0.5 solvent-00302.bop > profile.dat
*/

#include <cstdlib>
#include <cstdio>
#include "reader.h"

enum {X, Y, Z};
#define MAX_LINE 1000

int n;    /* number of steps */
double o; /* origin */
double s; /* spacing */

double   nnd[MAX_LINE]; /* number density and velocity histogram */
double    vv[MAX_LINE];
ReadData d;

void process();
void write();

int main(int argc, char **argv) {
  int iarg = 1;
  /* fprintf(stderr, "usage: %s <n> <o> <s>  <in1.bop> <in2.bop> ...\n", argv[iarg++]); */
  n = atoi(argv[iarg++]);
  o = atof(argv[iarg++]);
  s = atof(argv[iarg++]);

  const int nd = argc - iarg;

  for (int i = 0; i < nd; i++, iarg++) {
    init(&d);
    read(argv[iarg], &d);
    process();
  }
  write();
}

void write() {
  int ih;
  double x, v, nd;
  for (ih = 0; ih < n; ih++) {
    nd = nnd[ih], v = vv[ih];
    x = ih * s + o + s/2;
    printf("%g %g\n", x, v/nd);
  }
}

void process() {
  long i;
  int ih;
  float *p; /* particle */
  float *r, *v;
  double y, vx;
  for (i = 0, p = d.fdata; i < d.n; i++, p += d.nvars) {
    r = p; v = p + 3;
    y = r[Y]; vx = v[X];

    y -= o; y /= s; ih = int(y);
    if (ih  < 0) continue;
    if (ih >= n) continue;

    nnd[ih]++;
    vv [ih] += vx;
  }
}
