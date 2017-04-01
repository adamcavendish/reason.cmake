macro(reason__add_executable__tinclude_dirs TARGET_NAME)
  # Handle include directories
  foreach(INC_DIR IN LISTS reason_INC_DIRS)
    target_include_directories("${TARGET_NAME}"
      PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}>" "$<INSTALL_INTERFACE:include>")
  endforeach()
endmacro()

macro(reason__add_executable__tlink_libs TARGET_NAME)
  # Handle Linking
  foreach(LINK IN LISTS reason_LINKS)
    target_link_libraries("${TARGET_NAME}" PUBLIC "${LINK}")
  endforeach()
endmacro()

macro(reason__add_executable__set_rpath TARGET_NAME)
  # Handle RPATH
  set_target_properties("${TARGET_NAME}" PROPERTIES INSTALL_RPATH "$ORIGIN/../lib")
  set_target_properties("${TARGET_NAME}" PROPERTIES INSTALL_RPATH_USE_LINK_PATH TRUE)
  reason_verbose(STATUS "${TARGET_NAME} set rpath: [rpath='$ORIGIN/../lib']")
endmacro()

macro(reason__add_executable__use_cotire TARGET_NAME)
  # Use cotire if available
  if (COMMAND cotire AND REASON_USE_COTIRE)
    cotire("${TARGET_NAME}")
    reason_verbose(STATUS "${TARGET_NAME} cotire applied")
  endif()
endmacro()

function(reason_add_executable)
  set(options HELP)
  set(one_value_args TARGET)
  set(mlt_value_args INC_DIRS SRCS LINKS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_print_help("reason_add_executable: reasonable add_executable
params:
  - TARGET      (STRING): The target name
  - INC_DIRS    (LIST)  : Extra include directories
  - SRCS        (LIST)  : Source files of the library
  - LINKS       (LIST)  : Extra libraries the library should link against
description:
  simply wrap 'add_executable', 'target_include_directories', and 'target_link_libraries'
  setup rpath, and use cotire if possible
example:
  1. Simple, mostly used 
     reason_add_executable(TARGET demo1 SRCS \"src/main.cpp\" INC_DIRS \"include\" LINKS mylib_d)")
  endif()

  add_executable("${reason_TARGET}" "${reason_SRCS}")
  reason__add_executable__tinclude_dirs("${reason_TARGET}")
  reason__add_executable__tlink_libs("${reason_TARGET}")
  reason__add_executable__set_rpath("${reason_TARGET}")
  reason__add_executable__use_cotire("${reason_TARGET}")
endfunction()

function(reason_cuda_add_executable)
  set(options HELP)
  set(one_value_args TARGET)
  set(mlt_value_args INC_DIRS SRCS LINKS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_print_help("reason_cuda_add_executable: reasonable add_executable
params:
  - TARGET      (STRING): The target name
  - INC_DIRS    (LIST)  : Extra include directories
  - SRCS        (LIST)  : Source files of the library
  - LINKS       (LIST)  : Extra libraries the library should link against
description:
  simply wrap 'cuda_add_executable', 'target_include_directories', and 'target_link_libraries'
  setup rpath, and use cotire if possible
example:
  1. Simple, mostly used 
     reason_cuda_add_executable(TARGET demo1 SRCS \"src/main.cu\" INC_DIRS \"include\" LINKS mylib_d)")
  endif()

  cuda_add_executable("${reason_TARGET}" "${reason_SRCS}")
  reason__add_executable__tinclude_dirs("${reason_TARGET}")
  reason__add_executable__tlink_libs("${reason_TARGET}")
  reason__add_executable__set_rpath("${reason_TARGET}")
  reason__add_executable__use_cotire("${reason_TARGET}")
endfunction()
