/* tagarray C quickstart: store arrays under string tags, read them back. */
#include <stdio.h>
#include <tagarray.h>

int main(void) {
  void *c = TA_Container_new("c-quickstart");

  double vec[3] = {1.0, 2.0, 3.0};
  int64_t dims[1] = {3};
  TA_Container_create(c, "vec", TA_TYPE_REAL64, 1, dims,
                      (const uint8_t *)vec, "a 1-D vector");

  /* RecordInfo holds borrowed views into container-owned memory. */
  RecordInfo ri = TA_Container_get(c, "vec");
  const double *d = (const double *)ri.data;
  printf("C   : vec = [%g, %g, %g]\n", d[0], d[1], d[2]);

  TA_Container_delete(c);     /* frees all record storage */
  return 0;
}
