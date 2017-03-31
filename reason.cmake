if("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" LESS 3.0)
   message(FATAL_ERROR "CMake >= 3.0 required")
endif()

# Reasonable CMake Project
include(reason_color)
include(reason_util)
# Use cotire if possible
# @see https://github.com/sakra/cotire
include(cotire OPTIONAL)

function(reason_add_library)
  set(options HELP NO_STATIC NO_SHARED)
  set(one_value_args TARGET)
  set(mlt_value_args INC_DIRS SRCS LINKS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_message(AUTHOR_WARNING "reason_add_library: reasonable add_library
params:
  - NO_STATIC (BOOL)  : Whether to build static library (the built static lib is named after \"\${TARGET}_s\")
  - NO_SHARED (BOOL)  : Whether to build shared library (the built shared lib is named after \"\${TARGET}_d\")
  - TARGET    (STRING): The target name
  - INC_DIRS  (LIST)  : Extra include directories
  - SRCS      (LIST)  : Source files of the library
  - LINKS     (LIST)  : Extra libraries the library should link against
description:
  'reason_add_library' will build static and shared libraries using '\${TARGET}_s' and '\${TARGET}_d' as their
  corresponding names, unless NO_STATIC or NO_SHARED is defined.
  The shared library is versioned following the project's version
  You do not need to include the 'INC_DIRS' after libraries are built when linking them since cmake
  automatically inferred the include directories for you. @see example 4
example:
  1. Build both static and shared libraries
     project(foo VERSION 1.2.3)
     reason_add_library(TARGET foo INC_DIRS \"include1\" \"include2\" SRCS \"src/foo1.cpp\" \"src/foo2.cpp\"
                        LINKS ncurses pthread)
     - 'libfoo_s.a' and 'libfoo_d.so' are built (shared library is versioned [major.minor]
                                                 following the project version)
       'libfoo_d.so' --> 'libfoo_d.so.1' --> 'libfoo_d.so.1.2'
     - 'include1' and 'include2' directory in \${CMAKE_CURRENT_LIST_DIR} are included
       for target foo (target only include, does not pollute other targets)
     - links 'libncurses.so' and '-pthread'
  2. Build only static library
     reason_add_library(TARGET foo INC_DIRS \"include\" SRCS \"src/foo.cpp\" NO_SHARED)
     - Only 'libfoo_s.a' is built
  3. Build only shared library
     reason_add_library(TARGET foo INC_DIRS \"include\" SRCS \"src/foo.cpp\" NO_STATIC)
     - Only 'libfoo_d.so' is built, and correctly versioned
  4. Build and linked by others
     reason_add_library(TARGET foo INC_DIRS \"my_foo_include\" SRCS \"src/foo.cpp\")
     # ... other cmake code ...
     add_executable(main 'src/main.cpp')  # where you might do `#include <foo.hpp>`
     target_link_libraries(main foo)      # cmake will automatically include 'my_foo_include' directory for you")
    reason_message(FATAL_ERROR)
  endif()

  if(NOT reason_TARGET)
    reason_message(FATAL_ERROR "You must specify a TARGET when using 'reason_add_library'")
  endif()

  if(NOT reason_SRCS)
    reason_message(FATAL_ERROR "You probably forgot to list the source files when using 'reason_add_library'")
  endif()

  # Build static library
  if(NOT reason_NO_STATIC)
    add_library("${reason_TARGET}_s" STATIC "${reason_SRCS}")
    foreach(INC_DIR IN LISTS reason_INC_DIRS)
      target_include_directories("${reason_TARGET}_s"
        PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}>" "$<INSTALL_INTERFACE:include>")
    endforeach()
    foreach(LINK IN LISTS reason_LINKS)
      target_link_libraries("${reason_TARGET}_s" PUBLIC "${LINK}")
    endforeach()
    # Use cotire if available
    if (COMMAND cotire)
      cotire("${reason_TARGET}_s")
    endif()
  endif()

  # Build shared library
  if(NOT reason_NO_SHARED)
    add_library("${reason_TARGET}_d" SHARED "${reason_SRCS}")
    # Handle include directories
    foreach(INC_DIR IN LISTS reason_INC_DIRS)
      target_include_directories("${reason_TARGET}_d"
        PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}>" "$<INSTALL_INTERFACE:include>")
      if(PROJECT_VERSION)
        # Add shared library version
        set_target_properties("${reason_TARGET}_d"
          PROPERTIES VERSION "${PROJECT_VERSION}"
          SOVERSION "${PROJECT_VERSION_MAJOR}")
      endif()
    endforeach()
    # Handle Linking
    foreach(LINK IN LISTS reason_LINKS)
      target_link_libraries("${reason_TARGET}_d" PUBLIC "${LINK}")
    endforeach()
    # Handle RPATH
    set_target_properties("${reason_TARGET}_d" PROPERTIES INSTALL_RPATH "$ORIGIN/../lib")
    set_target_properties("${reason_TARGET}_d" PROPERTIES INSTALL_RPATH_USE_LINK_PATH TRUE)
    # Use cotire if available
    if (COMMAND cotire)
      cotire("${reason_TARGET}_d")
    endif()
  endif()
endfunction()

function(reason_add_executable)
  set(options HELP)
  set(one_value_args TARGET)
  set(mlt_value_args INC_DIRS SRCS LINKS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_message(AUTHOR_WARNING "reason_add_executable: reasonable add_executable
params:
  - TARGET    (STRING): The target name
  - INC_DIRS  (LIST)  : Extra include directories
  - SRCS      (LIST)  : Source files of the library
  - LINKS     (LIST)  : Extra libraries the library should link against
description:
  simply wrap 'add_executable', 'target_include_directories', and 'target_link_libraries'")
    reason_message(FATAL_ERROR)
  endif()

  add_executable("${reason_TARGET}" "${reason_SRCS}")
  # Handle include directories
  foreach(INC_DIR IN LISTS reason_INC_DIRS)
    target_include_directories("${reason_TARGET}"
      PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}>" "$<INSTALL_INTERFACE:include>")
  endforeach()
  # Handle Linking
  foreach(LINK IN LISTS reason_LINKS)
    target_link_libraries("${reason_TARGET}" PUBLIC "${LINK}")
  endforeach()
  # Handle RPATH
  set_target_properties("${reason_TARGET}" PROPERTIES INSTALL_RPATH "$ORIGIN/../lib")
  set_target_properties("${reason_TARGET}" PROPERTIES INSTALL_RPATH_USE_LINK_PATH TRUE)
  # Use cotire if available
  if (COMMAND cotire)
    cotire("${reason_TARGET}")
  endif()
endfunction()

function(reason_install)
  set(options HELP)
  set(one_value_args)
  set(mlt_value_args TARGETS INC_DIRS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_message(AUTHOR_WARNING "reason_install: reasonable install
params:
  - TARGETS  (LIST): The target names, including all executables, libraries both static and shared
  - INC_DIRS (LIST): Include directories to install
description:
  Automatically generates cmake's config file for you. You might use 'find_package' or 'include'
  in CMakeLists.txt of other projects to find this package.")
    reason_message(FATAL_ERROR)
  endif()

  install(TARGETS ${reason_TARGETS}
    EXPORT "${PROJECT_NAME}Config"
    RUNTIME DESTINATION "bin"
    ARCHIVE DESTINATION "lib"
    LIBRARY DESTINATION "lib")

  # Install include directories
  if(reason_INC_DIRS)
    foreach(INC_DIR IN LISTS reason_INC_DIRS)
      install(DIRECTORY "${INC_DIR}" DESTINATION "include")
    endforeach()
  endif()

  # make it an importable project
  install(EXPORT "${PROJECT_NAME}Config" DESTINATION "share/${PROJECT_NAME}/cmake")
endfunction()

function(reason_add_multiple_tests)
  set(options HELP)
  set(one_value_args TEST_NAME)
  set(mlt_value_args SRCS LINKS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_message(AUTHOR_WARNING "reason_add_multiple_tests: reasonable build and add test
params:
  - TEST_NAME (STRING): The test name shown in ctest
  - SRCS      (LIST)  : Sources of your tests
  - LINKS     (LIST)  : Links that all your tests will link against
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

  foreach(SRC IN LISTS reason_SRCS)
    get_filename_component(EXE_NAME "${SRC}" NAME_WE)
    add_executable("${EXE_NAME}" "${SRC}")

    foreach(LINK IN LISTS reason_LINKS)
      target_link_libraries("${EXE_NAME}" PUBLIC "${LINK}")
    endforeach()

    add_test("${reason_TEST_NAME}" "${EXE_NAME}")
  endforeach()
endfunction()

macro(reason_pack_deb)
  set(options HELP)
  set(one_value_args PACKNAME CONTACT DESCSUM DESC DESP_FILE LICENSE_FILE ARCH DEBDEP SECTION PRIORITY)
  set(mlt_value_args)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if (reason_HELP)
    reason_message(AUTHOR_WARNING "reason_pack_deb: reasonable pack deb package for you
params:
  - PACKNAME     (STRING): package name (optional)
  - CONTACT      (STRING): package contact (valid email required)
                           @example: Firstname Lastname <email@example.com>
  - DESCSUM      (STRING): package description summary (optional)
  - DESC         (STRING): package description (long) (optional)
  - DESP_FILE    (STRING): package description file, usually the path to README (optional)
  - LICENSE_FILE (STRING): package licence file path (optional)
  - ARCH         (STRING): package architecture: i386, i686, amd64, armhf, etc.
  - DEBDEP       (STRING): package debian dependencies (use `dpkg -s <package>` to see an example)
                           @example: 'libgstreamer1.0-dev (>= 1.2.4), gstreamer1.0-tools (>= 1.2.3)'
  - SECTION      (STRING): package section (devel is recommended for general use)
                           @see: https://packages.debian.org/en/stable/ for all package sections
  - PRIORITY     (STRING): package priority (mostly 'optional')
                           @see https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics.en.html#s-priority")
    reason_message(FATAL_ERROR)
  endif()

  reason_set_check(reason_CONTACT  "reason_pack_deb: CONTACT is required, i.e. <email@example.com>")
  reason_set_check(reason_ARCH     "reason_pack_deb: ARCH must be defined, i.e. i386, amd64, armhf")
  reason_set_check(PROJECT_VERSION "reason_pack_deb: project's version must be set, i.e. project(foo VERSION 1.0.0), or manually set PROJECT_VERSION variable")

  list(APPEND CPACK_GENERATOR "DEB")

  reason_set_or(CPACK_PACKAGE_NAME "${reason_PACKNAME}" "${PROJECT_NAME}")
  reason_set_if(CPACK_PACKAGE_CONTACT "${reason_CONTACT}")

  reason_set_if(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
  reason_set_if(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
  reason_set_if(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
  reason_set_if(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")

  reason_set_if(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${reason_DESCSUM}")
  reason_set_if(CPACK_PACKAGE_DESCRIPTION "${reason_DESC}")
  reason_set_if(CPACK_PACKAGE_DESCRIPTION_FILE "${reason_DESP_FILE}")
  reason_set_if(CPACK_RESOURCE_FILE_LICENSE "${reason_LICENSE_FILE}")

  reason_set_if(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${reason_ARCH}")
  reason_set_if(CPACK_DEBIAN_PACKAGE_DEPENDS "${reason_DEBDEP}")
  reason_set_if(CPACK_DEBIAN_PACKAGE_SECTION "${reason_SECTION}")
  reason_set_if(CPACK_DEBIAN_PACKAGE_PRIORITY "${reason_PRIORITY}")
endmacro()
