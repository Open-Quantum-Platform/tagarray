#include <tagarray.hpp>
#include <cstdio>
int main() {
  tagarray::Container c("consume");
  double v[3] = {1, 2, 3};
  c.create("v", tagarray::defines::TYPE_REAL64, std::vector<int64_t>{3},
           reinterpret_cast<const uint8_t *>(v));
  std::printf("consumer C++ ok: %g\n", c["v"]->raw_data<double *>()[2]);
  return 0;
}
