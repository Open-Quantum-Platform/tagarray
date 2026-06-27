# Built when -DENABLE_EXAMPLES=ON. Examples link the in-tree alias targets, the
# same names downstream find_package(tagarray) consumers use.

add_executable(example_c   c/quickstart.c)
target_link_libraries(example_c   PRIVATE tagarray::tagarray)

add_executable(example_cpp cpp/quickstart.cpp)
target_link_libraries(example_cpp PRIVATE tagarray::tagarray)

if(ENABLE_FORTRAN)
  add_executable(example_fortran fortran/quickstart.f90)
  target_link_libraries(example_fortran PRIVATE tagarray::tagarray_f)

  # cross-language: C++ writes a file, Fortran reads it
  add_executable(example_xlang_produce cross_language/produce.cpp)
  target_link_libraries(example_xlang_produce PRIVATE tagarray::tagarray)
  add_executable(example_xlang_consume cross_language/consume.f90)
  target_link_libraries(example_xlang_consume PRIVATE tagarray::tagarray_f)
endif()
