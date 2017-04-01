macro(reason__add_library__tinclude_dirs TARGET_NAME)
  target_include_directories("${TARGET_NAME}" PUBLIC "$<INSTALL_INTERFACE:include>")

  foreach(INC_DIR IN LISTS reason_INC_DIRS)
    if(IS_ABSOLUTE "${INC_DIR}")
      set(build_interface "${INC_DIR}")
    else()
      set(build_interface "${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}")
    endif()

    target_include_directories("${TARGET_NAME}" PUBLIC "$<BUILD_INTERFACE:${build_interface}>")
    reason_verbose(STATUS "${TARGET_NAME} t_include_dirs: [public-include=${build_interface}]")
  endforeach()
endmacro()

macro(reason__add_library__tlink_libs_s TARGET_NAME)
  foreach(LINK IN LISTS reason_LINKS)
    target_link_libraries("${TARGET_NAME}" INTERFACE "${LINK}")
    reason_verbose(STATUS "${TARGET_NAME} t_link_libs: [interface-link=${LINK}]")
  endforeach()
endmacro()

macro(reason__add_library__tlink_libs_d TARGET_NAME)
  foreach(LINK IN LISTS reason_LINKS)
    target_link_libraries("${TARGET_NAME}" PUBLIC "${LINK}")
    reason_verbose(STATUS "${TARGET_NAME} t_link_libs: [public-link=${LINK}]")
  endforeach()
endmacro()

macro(reason__add_library__use_cotire TARGET_NAME)
  # Use cotire if available
  if (COMMAND cotire AND REASON_USE_COTIRE)
    cotire("${TARGET_NAME}")
    reason_verbose(STATUS "${TARGET_NAME} cotire applied")
  endif()
endmacro()

macro(reason__add_library__set_shared_lib_version TARGET_NAME)
  # Add shared library version
  if(PROJECT_VERSION)
    set_target_properties("${TARGET_NAME}"
      PROPERTIES VERSION "${PROJECT_VERSION}"
      SOVERSION "${PROJECT_VERSION_MAJOR}")
    reason_verbose(STATUS "${TARGET_NAME} set shared-lib version: [version=${PROJECT_VERSION}] [soversion=${PROJECT_VERSION_MAJOR}]")
  else()
    reason_verbose(STATUS "${TARGET_NAME} no shared-lib version")
  endif()
endmacro()

macro(reason__add_library__set_rpath TARGET_NAME)
  # Handle RPATH
  set_target_properties("${TARGET_NAME}" PROPERTIES INSTALL_RPATH "$ORIGIN/../lib")
  set_target_properties("${TARGET_NAME}" PROPERTIES INSTALL_RPATH_USE_LINK_PATH TRUE)
  reason_verbose(STATUS "${TARGET_NAME} set rpath: [rpath='$ORIGIN/../lib']")
endmacro()

macro(reason__add_library__print_properties TARGET_NAME)
  get_target_property(t_LINK_LIBS "${TARGET_NAME}" "LINK_LIBRARIES")
  get_target_property(t_INCLUDE_DIRS "${TARGET_NAME}" "INCLUDE_DIRECTORIES")
  reason_verbose(STATUS "${TARGET_NAME} properties:")

  list(REMOVE_DUPLICATES t_INCLUDE_DIRS)
  foreach(v IN LISTS t_INCLUDE_DIRS)
    reason_verbose(STATUS "    [INCLUDE_DIRECTORIES=${v}]")
  endforeach()

  list(REMOVE_DUPLICATES t_LINK_LIBS)
  foreach(v IN LISTS t_LINK_LIBS)
    reason_verbose(STATUS "    [LINK_LIBRARIES=${v}]")
  endforeach()
endmacro()

function(reason_add_library)
  set(options HELP STATIC SHARED)
  set(one_value_args TARGET)
  set(mlt_value_args INC_DIRS SRCS LINKS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_print_help("reason_add_library: reasonable add_library
params:
  - STATIC    (BOOL)  : Whether to build static library (the built static lib is named after \"\${TARGET}_s\")
  - SHARED    (BOOL)  : Whether to build shared library (the built shared lib is named after \"\${TARGET}_d\")
  - TARGET    (STRING): The target name
  - INC_DIRS  (LIST)  : Extra include directories
  - SRCS      (LIST)  : Source files of the library
  - LINKS     (LIST)  : Extra libraries the library should link against
description:
  'reason_add_library' will build static and shared libraries using '\${TARGET}_s' and '\${TARGET}_d' as their
  corresponding names, if STATIC or SHARED is defined.
  The shared library is versioned following the project's version
  You do not need to include the 'INC_DIRS' after libraries are built when linking them since cmake
  automatically inferred the include directories for you. @see example 4
example:
  1. Build both static and shared libraries
     project(foo VERSION 1.2.3)
     reason_add_library(TARGET foo STATIC SHARED
                        INC_DIRS \"include1\" \"include2\" SRCS \"src/foo1.cpp\" \"src/foo2.cpp\"
                        LINKS ncurses pthread)
     - 'libfoo_s.a' and 'libfoo_d.so' are built (shared library is versioned [major.minor]
                                                 following the project version)
       'libfoo_d.so' --> 'libfoo_d.so.1' --> 'libfoo_d.so.1.2'
     - 'include1' and 'include2' directory in \${CMAKE_CURRENT_LIST_DIR} are included
       for target foo (target only include, does not pollute other targets)
     - links 'libncurses.so' and '-pthread'
  2. Build only static library
     reason_add_library(TARGET foo STATIC INC_DIRS \"include\" SRCS \"src/foo.cpp\")
     - Only 'libfoo_s.a' is built
  3. Build only shared library
     reason_add_library(TARGET foo SHARED INC_DIRS \"include\" SRCS \"src/foo.cpp\")
     - Only 'libfoo_d.so' is built, and correctly versioned
  4. Build and linked by others
     reason_add_library(TARGET foo STATIC INC_DIRS \"my_foo_include\" SRCS \"src/foo.cpp\")
     # ... other cmake code ...
     add_executable(main 'src/main.cpp')  # where you might do `#include <foo.hpp>`
     target_link_libraries(main foo_s)      # cmake will automatically include 'my_foo_include' directory for you")
  endif()

  reason_set_check(reason_TARGET "You must specify a TARGET when using 'reason_add_library'")
  reason_set_check(reason_SRCS   "You probably forgot to list the source files when using 'reason_add_library'")
  if((NOT reason_STATIC) AND (NOT reason_SHARED))
    reason_message(FATAL_ERROR "You must specify to build either STATIC or SHARED or both")
  endif()

  # Build static library
  if(reason_STATIC)
    add_library("${reason_TARGET}_s" STATIC "${reason_SRCS}")
    reason_verbose(STATUS "${reason_TARGET}_s add_library: [type=STATIC] [src='${reason_SRCS}']")
    reason__add_library__tinclude_dirs("${reason_TARGET}_s")
    reason__add_library__tlink_libs_s("${reason_TARGET}_s")
    reason__add_library__use_cotire("${reason_TARGET}_s")
    reason__add_library__print_properties("${reason_TARGET}_s")
  endif()

  # Build shared library
  if(reason_SHARED)
    add_library("${reason_TARGET}_d" SHARED "${reason_SRCS}")
    reason_verbose(STATUS "${reason_TARGET}_d add_library: [type=SHARED] [src='${reason_SRCS}']")
    reason__add_library__tinclude_dirs("${reason_TARGET}_d")
    reason__add_library__tlink_libs_d("${reason_TARGET}_d")
    reason__add_library__use_cotire("${reason_TARGET}_d")
    reason__add_library__set_shared_lib_version("${reason_TARGET}_d")
    reason__add_library__set_rpath("${reason_TARGET}_d")
    reason__add_library__print_properties("${reason_TARGET}_d")
  endif()
endfunction()
