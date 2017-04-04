function(reason__add_executable__tinclude_dirs TARGET_NAME INC_DIRS)
  reason_verbose("  target_include_directories():")
  # Handle include directories
  foreach(INC_DIR IN LISTS INC_DIRS)
    set(build_interface "${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}")
    target_include_directories("${TARGET_NAME}" PRIVATE "$<BUILD_INTERFACE:${build_interface}>")
    reason_verbose("    [private-include=${build_interface}]")
  endforeach()
  target_include_directories("${TARGET_NAME}" PRIVATE "$<INSTALL_INTERFACE:include>")
  reason_verbose("    [private-include=\"$<INSTALL_INTERFACE:include>\"]")
endfunction()

function(reason__add_executable__tlink_libs TARGET_NAME LINKS)
  foreach(LINK IN LISTS LINKS)
    # Handle Dependencies' compile definitions @TODO
    # Handle Dependencies' include dirs
    reason_extract_dep_inc_dirs_to_target("${TARGET_NAME}" "${LINK}")
    # Link it finally
    target_link_libraries("${TARGET_NAME}" PRIVATE "${LINK}")
    reason_verbose("  target_link_libraries:")
    reason_verbose("    [private-link=${LINK}]")
  endforeach()
endfunction()

function(reason__add_executable__set_rpath TARGET_NAME)
  # Handle RPATH
  set_target_properties("${TARGET_NAME}" PROPERTIES INSTALL_RPATH "$ORIGIN/../lib")
  set_target_properties("${TARGET_NAME}" PROPERTIES INSTALL_RPATH_USE_LINK_PATH TRUE)
  reason_verbose("${TARGET_NAME} set rpath: [rpath='$ORIGIN/../lib']")
endfunction()

function(reason__add_executable__use_cotire TARGET_NAME)
  # Use cotire if available
  if(COMMAND cotire AND REASON_USE_COTIRE)
    cotire("${TARGET_NAME}")
    reason_verbose("${TARGET_NAME} cotire applied")
  endif()
endfunction()

function(reason_add_executable)
  set(options HELP)
  set(one_value_args TARGET FN)
  set(mlt_value_args INC_DIRS SRCS LINKS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_print_help("reason_add_executable: reasonable add_executable
params:
  - TARGET      (STRING): The target name
  - FN          (STRING): The custom `add_executable` function to use (optional)
  - INC_DIRS    (LIST)  : Extra include directories (optional)
  - SRCS        (LIST)  : Source files of the library
  - LINKS       (LIST)  : Extra libraries the library should link against (optional)
description:
  simply wrap 'add_executable', 'target_include_directories', and 'target_link_libraries'
  setup rpath, and use cotire if possible
example:
  1. Simple, mostly used 
     reason_add_executable(TARGET demo1 SRCS \"src/main.cpp\" INC_DIRS \"include\" LINKS mylib_d)
  2. Customized 'add_executable' function, i.e. `cuda_add_executable`
     reason_add_executable(TARGET demo1 SRCS \"src/main.cu\" INC_DIRS \"include\" LINKS mylib_d FN cuda_add_executable)")
  endif()
  reason_set_check(reason_TARGET "You must specify a TARGET when using 'reason_add_executable'")
  reason_set_check(reason_SRCS   "You probably forgot to list the sources when using 'reason_add_executable'")

  if(reason_FN)
    set(FN_ADD_EXECUTABLE "${reason_FN}")
  else()
    set(FN_ADD_EXECUTABLE "add_executable")
  endif()

  reason_verbose("executable: [target=${reason_TARGET}]")
  reason_util_configure_and_include("reason.add_executable.in.cmake" "reason.add_executable.out.cmake")
  reason__add_executable__impl()
endfunction()
