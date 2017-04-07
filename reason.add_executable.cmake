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
    # Handle Dependencies' include dirs
    reason_extract_dependency_properties_to_target("${TARGET_NAME}" "${LINK}")
    # Link it finally
    target_link_libraries("${TARGET_NAME}" PRIVATE "${LINK}")
    reason_verbose("  target_link_libraries:")
    reason_verbose("    [private-link=${LINK}]")
  endforeach()
endfunction()

function(reason__add_executable__compile_define TARGET_NAME DEFINES)
  target_compile_definitions("${TARGET_NAME}" PRIVATE "${DEFINES}")
  foreach(DEFINE IN LISTS DEFINES)
    reason_verbose("  target_compile_definitions: [private-define=${DEFINE}]")
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
  set(mlt_value_args INC_DIRS SRCS LINKS DEFINES)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_print_help_file("${REASON_MODULE_DIR}/reason.add_executable.help")
  endif()
  reason_set_check(reason_TARGET "You must specify a TARGET when using 'reason_add_executable'")
  reason_set_check(reason_SRCS   "You probably forgot to list the sources when using 'reason_add_executable'")

  if(reason_FN)
    set(FN_ADD_EXECUTABLE "${reason_FN}")
  else()
    set(FN_ADD_EXECUTABLE "add_executable")
  endif()

  reason_util_configure_and_include(
    "reason.add_executable.in.cmake"
    "reason.add_executable.${FN_ADD_EXECUTABLE}.out.cmake")
  reason__add_executable__impl()
endfunction()
