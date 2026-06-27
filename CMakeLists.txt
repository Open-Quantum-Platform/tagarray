cmake_minimum_required(VERSION 3.25)

project(tagarray
  VERSION 1.0.0
  LANGUAGES C CXX)


option(ENABLE_FORTRAN    "Enable Fortran bindings"        OFF)
option(ENABLE_PYTHON     "Enable Python bindings (requires BUILD_SHARED_LIBS=ON)" OFF)
option(BUILD_SHARED_LIBS "Build as shared library"        OFF)
option(ENABLE_TESTING    "Enable tests"                   OFF)
option(ENABLE_EXAMPLES   "Build the examples"             OFF)
option(ENABLE_LTO        "Enable Link-Time Optimizations" OFF)


if(ENABLE_FORTRAN)
  enable_language(Fortran)
endif()

if(ENABLE_PYTHON)
  # The pybind11 extension links the core library statically (made position-
  # independent below), so the resulting module is self-contained and needs no
  # separate libtagarray at import time. (A shared core also works, but then the
  # dylib must be co-located/rpath'd into the wheel.)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
  find_package(Python3 COMPONENTS Interpreter Development REQUIRED)
  find_package(pybind11 REQUIRED)
endif()


set(PN ${PROJECT_NAME})


include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

if(ENABLE_LTO)
  include(CheckIPOSupported)
  check_ipo_supported(RESULT IPO_AVAILABLE)
else()
  set(IPO_AVAILABLE OFF)
endif()


list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
include(defines)
include(CompilerFlagsSets)
include(TargetCompileCheckAddFlags)


if(NOT DEFINED ${CMAKE_CXX_COMPILER_ID}_CXX_WARNINGS)
  set(${CMAKE_CXX_COMPILER_ID}_CXX_WARNINGS "")
  message(WARNING "${CMAKE_CXX_COMPILER_ID} may not work properly")
endif()
if(ENABLE_FORTRAN)
  if(NOT DEFINED ${CMAKE_Fortran_COMPILER_ID}_Fortran_WARNINGS)
    set(${CMAKE_Fortran_COMPILER_ID}_Fortran_WARNINGS "")
    message(WARNING "${CMAKE_Fortran_COMPILER_ID} may not work properly")
  endif()
endif()


generate_header("C" "${CMAKE_SOURCE_DIR}/defines.csv" "${CMAKE_BINARY_DIR}/include/${PN}/defines.h")
generate_header("CXX" "${CMAKE_SOURCE_DIR}/defines.csv" "${CMAKE_BINARY_DIR}/include/${PN}/defines.hpp")
if(ENABLE_FORTRAN)
  generate_header("Fortran" "${CMAKE_SOURCE_DIR}/defines.csv" "${CMAKE_BINARY_DIR}/defines.f90")
endif()


set(SOURCES)
if(ENABLE_FORTRAN)
  set(SOURCES_Fortran)
endif()
if(ENABLE_PYTHON)
  set(SOURCES_Python)
endif()

add_subdirectory(source)


add_library(${PN} ${SOURCES})
# In-tree namespaced alias so FetchContent consumers link the same target name
# (tagarray::tagarray) that find_package() consumers get from the export below.
add_library(${PN}::${PN} ALIAS ${PN})
add_dependencies(${PN} ${PN}_C_defines)
add_dependencies(${PN} ${PN}_CXX_defines)
target_sources(${PN}
  PUBLIC
    FILE_SET HEADERS BASE_DIRS ${PROJECT_SOURCE_DIR}/include FILES include/${PN}.h
                                                                   include/${PN}.hpp
                                                                   include/${PN}/RecordInfo.h
                                                                   include/${PN}/PyRecordInfo.hpp
                                                                   include/${PN}/Container.hpp
                                                                   include/${PN}/Utils.hpp
                                                                   include/${PN}/filesystem.hpp
                                                                   include/${PN}/hidden/Record.hpp
    FILE_SET HEADERS BASE_DIRS ${CMAKE_BINARY_DIR}/include   FILES ${CMAKE_BINARY_DIR}/include/${PN}/defines.h
                                                                   ${CMAKE_BINARY_DIR}/include/${PN}/defines.hpp
)
target_include_directories(${PN} PRIVATE "${CMAKE_SOURCE_DIR}/include" "${CMAKE_BINARY_DIR}/include")
target_compile_features(${PN} PUBLIC cxx_std_17)
target_compile_check_add_flags(${PN} PRIVATE CXX     ${${CMAKE_CXX_COMPILER_ID}_CXX_WARNINGS})
set_target_properties(${PN} PROPERTIES VERSION ${PROJECT_VERSION}
                                       SOVERSION 1)
if(IPO_AVAILABLE)
  set_target_properties(${PN} PROPERTIES INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()
install(TARGETS ${PN}
        EXPORT ${PN}Targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)


if(ENABLE_FORTRAN)
  add_library(${PN}_f ${SOURCES_Fortran} "${CMAKE_BINARY_DIR}/defines.f90")
  add_library(${PN}::${PN}_f ALIAS ${PN}_f)
  # Export the Fortran module (.mod) directory so downstream `use tagarray`
  # resolves, for both the build tree (FetchContent) and the install tree.
  target_include_directories(${PN}_f INTERFACE
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/include/${PN}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PN}>)
  target_compile_features(${PN}_f PRIVATE cxx_std_17)
  add_dependencies(${PN}_f ${PN}_Fortran_defines)
  target_link_libraries(${PN}_f ${PN})
  target_sources(${PN}_f
    PUBLIC
      FILE_SET HEADERS BASE_DIRS ${PROJECT_SOURCE_DIR}/include FILES include/${PN}.fh
                                                                     include/${PN}/${PN}_v1.fh
                                                                     include/${PN}/${PN}_v2.fh
                                                                     include/${PN}/${PN}_v3.fh
#      FILE_SET HEADERS BASE_DIRS ${CMAKE_BINARY_DIR}/include   FILES ${CMAKE_BINARY_DIR}/include/${PN}/tagarray.mod
#                                                                     ${CMAKE_BINARY_DIR}/include/${PN}/tagarray_defines.mod
#                                                                     ${CMAKE_BINARY_DIR}/include/${PN}/tagarray_capi.mod
#                                                                     ${CMAKE_BINARY_DIR}/include/${PN}/tagarray_utils.mod
#                                                                     ${CMAKE_BINARY_DIR}/include/${PN}/tagarray_container.mod
#                                                                     ${CMAKE_BINARY_DIR}/include/${PN}/tagarray_recordinfo.mod
  )
  set_target_properties(${PN}_f PROPERTIES Fortran_MODULE_DIRECTORY "${CMAKE_BINARY_DIR}/include/${PN}"
                                           VERSION ${PROJECT_VERSION}
                                           SOVERSION 1)
  if(IPO_AVAILABLE AND NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    set_target_properties(${PN}_f PROPERTIES INTERPROCEDURAL_OPTIMIZATION TRUE)
  endif()
  try_compile(assumed_size_polymorphic_objects
    SOURCE_FROM_CONTENT assumed_size_polymorphic_objects.f90 "program test\ncontains\n  subroutine UP(arr)\n    class(*) :: arr(*)\n  end subroutine UP\nend program test")
  if(assumed_size_polymorphic_objects)
    set(MAX_TA_FORTRAN_API_VERSION_AVAILABLE 2)
    target_compile_definitions(${PN}_f PUBLIC TA_FORTRAN_API_VERSION_AVAILABLE=2)
  endif()
  if("${CMAKE_Fortran_COMPILER_ID}" STREQUAL "GNU")
    add_compile_options($<$<COMPILE_LANGUAGE:Fortran>:-std=f2018>)
  elseif("${CMAKE_Fortran_COMPILER_ID}" STREQUAL "Intel")
    add_compile_options($<$<COMPILE_LANGUAGE:Fortran>:-stand f18>)
  elseif("${CMAKE_Fortran_COMPILER_ID}" STREQUAL "IntelLLVM")
    add_compile_options($<$<COMPILE_LANGUAGE:Fortran>:-stand f18>)
  else()
    message(FATAL_ERROR "Unknown Fortran compiler ID: ${CMAKE_Fortran_COMPILER_ID}")
  endif()
  target_compile_check_add_flags(${PN}_f PRIVATE CXX     ${${CMAKE_CXX_COMPILER_ID}_CXX_WARNINGS})
  target_compile_check_add_flags(${PN}_f PRIVATE Fortran ${${CMAKE_Fortran_COMPILER_ID}_Fortran_WARNINGS})
  install(TARGETS ${PN}_f
          EXPORT ${PN}Targets
          LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
          ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
          RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
          INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
          FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  )
  # Install every generated Fortran .mod from the module directory. This is
  # robust to compiler-dependent module names/casing and to new modules
  # (e.g. tagarray_highlevel) without having to enumerate them by hand.
  install(DIRECTORY ${CMAKE_BINARY_DIR}/include/${PN}/
          DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PN}
          FILES_MATCHING PATTERN "*.mod")
endif()


if(ENABLE_PYTHON)
  pybind11_add_module(${PN}_py MODULE ${SOURCES_Python})
  target_compile_features(${PN}_py PRIVATE cxx_std_17)
  target_link_libraries(${PN}_py PRIVATE ${PN})
  target_compile_check_add_flags(${PN}_py PRIVATE CXX ${${CMAKE_CXX_COMPILER_ID}_CXX_WARNINGS})
  # Built as the private extension `_tagarray`; the pure-Python package
  # `tagarray` (python/tagarray) re-exports from it.
  set_target_properties(${PN}_py PROPERTIES OUTPUT_NAME _${PN})
  if(IPO_AVAILABLE)
    set_target_properties(${PN}_py PROPERTIES INTERPROCEDURAL_OPTIMIZATION TRUE)
  endif()
  # NOTE: the Python extension is intentionally NOT part of ${PN}Targets — a
  # C/C++/Fortran find_package(tagarray) consumer must not be forced to resolve
  # pybind11/Python. Proper Python packaging is handled via pyproject.toml.
  # Install into the package directory (COMPONENT python) so scikit-build-core
  # lands it next to __init__.py inside the wheel's `tagarray/` package and the
  # wheel contains ONLY the Python component (no C/C++ headers or cmake config).
  install(TARGETS ${PN}_py
          COMPONENT python
          LIBRARY DESTINATION ${PN}
          RUNTIME DESTINATION ${PN}
  )
endif()


install(EXPORT ${PN}Targets
    FILE ${PN}Targets.cmake
    NAMESPACE ${PN}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PN})

# Generate the package config file so that find_package(tagarray CONFIG) works.
# (Previously only Targets + ConfigVersion were installed, with no Config file,
#  which made find_package(tagarray) fail for every downstream consumer.)
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/${PN}Config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${PN}Config.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PN})

# SameMajorVersion: a firm 1.0.0 must not be silently satisfied by a future
# ABI-breaking 2.x.
write_basic_package_version_file(
    "${PN}ConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PN}Config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PN}ConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PN})


if(ENABLE_TESTING)
  enable_testing()
  add_subdirectory(tests)
endif()

if(ENABLE_EXAMPLES)
  add_subdirectory(examples)
endif()
