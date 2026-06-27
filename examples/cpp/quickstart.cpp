// tagarray C++ quickstart.
#include <tagarray.hpp>
#include <cstdio>

int main() {
  tagarray::Container c("cpp-quickstart");

  double vec[3] = {1.0, 2.0, 3.0};
  c.create("vec", tagarray::defines::TYPE_REAL64, std::vector<int64_t>{3},
           reinterpret_cast<const uint8_t *>(vec));

  auto rec = c["vec"];                       // std::shared_ptr<Record>
  double *d = rec->raw_data<double *>();      // zero-copy view
  std::printf("C++ : vec = [%g, %g, %g]\n", d[0], d[1], d[2]);
  return 0;
}
