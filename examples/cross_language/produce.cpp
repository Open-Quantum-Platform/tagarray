// Cross-language demo, step 1: a C++ program writes a tagarray container to a
// file. Run `produce` first, then `consume` (Fortran) on the same file.
#include <tagarray.hpp>
#include <cstdio>
#include <string>

int main(int argc, char **argv) {
  const std::string path = (argc > 1) ? argv[1] : "shared.ta";
  tagarray::Container c("produced-by-cpp");
  double mat[6] = {1, 2, 3, 4, 5, 6};        // 2x3
  c.create("mat", tagarray::defines::TYPE_REAL64, std::vector<int64_t>{2, 3},
           reinterpret_cast<const uint8_t *>(mat), "written by C++");
  c.save(path);
  std::printf("C++  : wrote 2x3 'mat' to %s\n", path.c_str());
  return 0;
}
