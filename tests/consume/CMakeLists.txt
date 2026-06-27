# A standalone project that consumes an *installed* tagarray via find_package.
# CI builds and runs this against a fresh install prefix to guarantee the
# package is actually consumable (this would have caught the missing
# tagarrayConfig.cmake).
cmake_minimum_required(VERSION 3.25)
project(tagarray_consume LANGUAGES CXX Fortran)

find_package(tagarray 1.0.0 CONFIG REQUIRED)

add_executable(use_cpp use_cpp.cpp)
target_link_libraries(use_cpp PRIVATE tagarray::tagarray)

add_executable(use_f90 use_f90.f90)
target_link_libraries(use_f90 PRIVATE tagarray::tagarray_f)

enable_testing()
add_test(NAME use_cpp COMMAND use_cpp)
add_test(NAME use_f90 COMMAND use_f90)
