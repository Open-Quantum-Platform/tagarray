# Changelog

All notable changes to tagarray are documented here. This project adheres to
[Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-06-27

First release as a first-class [Open-Quantum-Platform](https://github.com/Open-Quantum-Platform)
project (graduating from `foxtran/libtagarray`'s `0.0.x` line). The C / C++ /
Fortran / Python APIs are now considered stable.

### Added
- **Fortran one-call allocate-and-bind API.** `c%alloc(tag, shape, ptr)` (and the
  free `ta_allocate(c, ...)`) create a container-owned array and bind a typed
  Fortran pointer to it in a single status-checked call, inferring the element
  type from the pointer kind. Fail-fast `alloc_or_die` / `ta_allocate_or_die`
  variants. Element types real64/real32/int32/int64/complex(real64), ranks 1-3.
- **Working CMake packaging.** `find_package(tagarray CONFIG)` now works (a
  `tagarrayConfig.cmake` is generated); in-tree `tagarray::tagarray` /
  `tagarray::tagarray_f` alias targets so find_package and FetchContent use the
  same names.
- **Python packaging.** `pip install` builds a self-contained wheel
  (`pyproject.toml` via scikit-build-core); `import tagarray` works.
- **Examples** (`-DENABLE_EXAMPLES=ON`), including a cross-language demo where
  C++ writes a container to a file and Fortran reads the identical bytes.
- **Tests**: a Fortran `alloc` suite and a Python pytest suite.
- A README and this changelog.

### Fixed
- Truncated `RECORD_NOT_FOUND` / `RECORD_EXISTS` status messages (`+` vs `+=`).
- `RecordInfo%is_associated` (Fortran) always returned `.false.` due to an
  `intent(out)` on the passed object.
- Python binding rejected numpy `int64`/`uint64` arrays ("Type not found")
  because of the `'l'` vs `'q'` buffer-format mismatch on LP64 platforms.

### Changed
- `find_package` version compatibility is `SameMajorVersion` (a future `2.x`
  will not satisfy `find_package(tagarray 1.0.0)`).
- Fortran `.mod` files install via a directory glob (robust to compiler naming)
  rather than a hard-coded list; the generated `defines.hpp` and the
  `Utils.hpp` / `filesystem.hpp` headers are now installed.
- The Python extension is no longer exported into the C/C++ CMake target set.
