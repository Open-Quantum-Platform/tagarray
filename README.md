# tagarray

**Share the same array data across C, C++, Fortran and Python.**

`tagarray` is a small, dependency-light container that holds named, typed,
multi-dimensional arrays and lets every language bind to the *same* bytes — no
copies, no serialization on the hot path. Store a matrix in C++, read it in
Fortran; allocate in Fortran, inspect it in Python. It is the data-exchange
layer used by [OpenQP](https://github.com/Open-Quantum-Platform/openqp), but it
has no quantum-chemistry dependencies and is useful anywhere mixed-language code
needs to share arrays.

- **Tag-keyed records** — store/retrieve arrays by string name.
- **Typed & N-dimensional** — `real32/64`, `int8..64`, `complex`, `char`; up to 12 dims.
- **Zero-copy views** — every binding sees the container's memory directly.
- **Persisted containers** — `save`/`load` a whole container to a file.
- **One install, four APIs** — C, C++, Fortran, and Python (numpy) from one source.

---

## Quickstart

### Fortran

The high-level `alloc` convenience (v1.0.0) creates a container-owned array
**and** binds a typed pointer to it in one checked call:

```fortran
use tagarray
type(container_t)       :: c
real(c_double), pointer :: mat(:,:)
integer(c_int32_t)      :: status

call c%new()
status = c%alloc("mat", (/ 2, 3 /), mat)   ! allocate + bind in one line
if (status /= TA_OK) error stop get_status_message(status, "mat")
mat = 0.0d0;  mat(2,3) = 42.0d0            ! write straight into the container
call c%delete()
```

`call c%alloc_or_die("mat", (/2,3/), mat)` is the fail-fast variant. Both have a
free-function spelling too: `ta_allocate(c, ...)` / `ta_allocate_or_die(c, ...)`.
Supported element types are `real64/real32/int32/int64/complex(real64)`, ranks 1–3.

### C++

```cpp
#include <tagarray.hpp>
tagarray::Container c("demo");
double v[3] = {1, 2, 3};
c.create("vec", tagarray::defines::TYPE_REAL64, std::vector<int64_t>{3},
         reinterpret_cast<const uint8_t*>(v));
double* d = c["vec"]->raw_data<double*>();   // zero-copy view
```

### C

```c
#include <tagarray.h>
void *c = TA_Container_new("demo");
double v[3] = {1, 2, 3};
int64_t dims[1] = {3};
TA_Container_create(c, "vec", TA_TYPE_REAL64, 1, dims, (const uint8_t*)v, NULL);
RecordInfo ri = TA_Container_get(c, "vec");  /* ri.data is a borrowed view */
TA_Container_delete(c);
```

### Python

```python
import numpy as np, tagarray
c = tagarray.Container("demo")
c["vec"] = np.asfortranarray([1.0, 2.0, 3.0])
print(np.asarray(c["vec"].data))
```

### The point: cross-language sharing

```cpp
// produce.cpp — C++ writes a container to a file
c.create("mat", tagarray::defines::TYPE_REAL64, {2, 3}, ...);
c.save("shared.ta");
```
```fortran
! consume.f90 — Fortran reads the identical bytes back
call c%load("shared.ta")
rec = c%get("mat")
call c_f_pointer(rec%data, mat, rec%dims)   ! same 2x3 matrix, no conversion
```

Runnable versions of all of the above are in [`examples/`](examples/).

---

## Building

```sh
cmake -S . -B build -DENABLE_FORTRAN=ON -DENABLE_TESTING=ON
cmake --build build -j
ctest --test-dir build
```

| Option              | Default | Effect                                            |
|---------------------|---------|---------------------------------------------------|
| `ENABLE_FORTRAN`    | `OFF`   | Build the Fortran bindings (`tagarray_f`)         |
| `ENABLE_PYTHON`     | `OFF`   | Build the Python extension (needs `BUILD_SHARED_LIBS=ON`) |
| `ENABLE_TESTING`    | `OFF`   | Build and register the C/C++/Fortran/Python tests |
| `ENABLE_EXAMPLES`   | `OFF`   | Build the examples                                |
| `BUILD_SHARED_LIBS` | `OFF`   | Build shared instead of static                    |

Requires CMake ≥ 3.25 and a C++17 compiler (plus a Fortran compiler for the
Fortran bindings).

## Using tagarray in your project

**find_package** (after `cmake --install`):

```cmake
find_package(tagarray 1.0.0 CONFIG REQUIRED)
target_link_libraries(myapp PRIVATE tagarray::tagarray)     # C / C++
target_link_libraries(myapp PRIVATE tagarray::tagarray_f)   # Fortran
```

**FetchContent** (no install needed) — links the same `tagarray::` targets:

```cmake
include(FetchContent)
FetchContent_Declare(tagarray
  GIT_REPOSITORY https://github.com/Open-Quantum-Platform/tagarray.git
  GIT_TAG v1.0.0)
set(ENABLE_FORTRAN ON)
FetchContent_MakeAvailable(tagarray)
```

**Python**:

```sh
pip install .          # from a clone, or
pip install git+https://github.com/Open-Quantum-Platform/tagarray.git
```

## Versioning

`tagarray` follows semantic versioning. `find_package(tagarray 1.0.0)` requires
the same major version (a future `2.x` will not silently satisfy it).

## License

MIT — see [LICENSE](LICENSE). Originally created by
[foxtran](https://github.com/foxtran/libtagarray); maintained as a first-class
project under [Open-Quantum-Platform](https://github.com/Open-Quantum-Platform).
