function(reason_add_multiple_tests)
  set(options HELP)
  set(one_value_args TEST_NAME)
  set(mlt_value_args INC_DIRS SRCS LINKS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_message(AUTHOR_WARNING "reason_add_multiple_tests: reasonable build and add test
params:
  - TEST_NAME (STRING): The test name shown in ctest
  - FN        (STRING): The custom `add_executable` function to use (optional)
  - INC_DIRS  (LIST)  : Extra include directories (optional)
  - SRCS      (LIST)  : Sources of your tests
  - LINKS     (LIST)  : Links that all your tests will link against (optional)
description:
  Mostly tests are in single files and they all links in the same way,
  and therefore, you can use 'reason_add_multiple_tests' to add them altogether.
example:
  reason_add_multiple_tests(TEST_NAME test_case SRCS 'test/test_foo1.cpp' 'test/test_foo2.cpp' LINKS gtest foo)
  - executable 'test_foo1' and 'test_foo2' will be built for testing
  - Add 'enable_testing()' in 'CMakeLists.txt' to enable testing
  - Use 'make test' or 'ctest' to run the test")
    reason_message(FATAL_ERROR)
  endif()

  reason_set_check(reason_TEST_NAME "You must specify a TEST_NAME when using 'reason_add_multiple_tests'")
  reason_set_check(reason_SRCS      "You probably forgot to specify the source files when using 'reason_add_multiple_tests'")

  reason_verbose("tests: [test-name: ${reason_TEST_NAME}]")
  foreach(SRC IN LISTS reason_SRCS)
    # Use "${SRC}" without extension name as exe's name
    get_filename_component(EXE_NAME "${SRC}" NAME_WE)
    reason_add_executable(TARGET "${EXE_NAME}" INC_DIRS "${reason_INC_DIRS}" SRCS "${SRC}" LINKS "${reason_LINKS}" FN "${reason_FN}")
    add_test("${reason_TEST_NAME}" "${EXE_NAME}")
  endforeach()
endfunction()
