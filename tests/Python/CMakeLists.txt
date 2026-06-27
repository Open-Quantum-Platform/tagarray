# Run the Python test suite against the freshly built extension. Only meaningful
# when ENABLE_PYTHON=ON; skips gracefully if pytest is unavailable.
find_program(PYTEST_EXECUTABLE NAMES pytest)
if(PYTEST_EXECUTABLE AND TARGET ${PROJECT_NAME}_py)
  add_test(NAME PythonAPI::pytest
           COMMAND ${PYTEST_EXECUTABLE} -q ${CMAKE_CURRENT_SOURCE_DIR})
  # Make both the compiled extension and the pure-python package importable.
  set_tests_properties(PythonAPI::pytest PROPERTIES
    ENVIRONMENT "PYTHONPATH=$<TARGET_FILE_DIR:${PROJECT_NAME}_py>:${CMAKE_SOURCE_DIR}/python")
endif()
