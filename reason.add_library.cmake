function(reason__add_library__tinclude_dirs TARGET_NAME INC_DIRS)
  reason_verbose("  target_include_directories:")
  foreach(INC_DIR IN LISTS INC_DIRS)
    # Convert include-dir into absolute path if it's not
    if(IS_ABSOLUTE "${INC_DIR}")
      set(build_interface "${INC_DIR}")
    else()
      set(build_interface "${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}")
    endif()

    target_include_directories("${TARGET_NAME}" PUBLIC "$<BUILD_INTERFACE:${build_interface}>")
    reason_verbose("    [public-include=${build_interface}]")
  endforeach()
  target_include_directories("${TARGET_NAME}" PUBLIC "$<INSTALL_INTERFACE:include>")
  reason_verbose("    [public-include=\"$<INSTALL_INTERFACE:include>\"]")
endfunction()

function(reason__add_library__tlink_libs_s TARGET_NAME LINKS)
  foreach(LINK IN LISTS LINKS)
    # Handle Dependencies' include directories
    reason_extract_dependency_properties_to_target("${TARGET_NAME}" "${LINK}")
    # Link it finally
    target_link_libraries("${TARGET_NAME}" INTERFACE "${LINK}")
    reason_verbose("  target_link_libraries:")
    reason_verbose("    [interface-link=${LINK}]")
  endforeach()
endfunction()

function(reason__add_library__tlink_libs_d TARGET_NAME LINKS)
  foreach(LINK IN LISTS LINKS)
    # Handle Dependencies' include dirs
    reason_extract_dependency_properties_to_target("${TARGET_NAME}" "${LINK}")
    # Link it finally
    target_link_libraries("${TARGET_NAME}" PUBLIC "${LINK}")
    reason_verbose("  target_link_libraries: [public-link=${LINK}]")
  endforeach()
endfunction()

function(reason__add_library__compile_define TARGET_NAME DEFINES)
  target_compile_definitions("${TARGET_NAME}" PRIVATE "${DEFINES}")
  foreach(DEFINE IN LISTS DEFINES)
    reason_verbose("  target_compile_definitions: [private-define=${DEFINE}]")
  endforeach()
endfunction()

macro(reason__add_library__use_cotire TARGET_NAME)
  # Use cotire if available
  if (COMMAND cotire AND REASON_USE_COTIRE)
    cotire("${TARGET_NAME}")
    reason_verbose("${TARGET_NAME} cotire applied")
  endif()
endmacro()

macro(reason__add_library__set_shared_lib_version TARGET_NAME)
  # Add shared library version
  if(PROJECT_VERSION)
    set_target_properties("${TARGET_NAME}"
      PROPERTIES VERSION "${PROJECT_VERSION}"
      SOVERSION "${PROJECT_VERSION_MAJOR}")
    reason_verbose("${TARGET_NAME} set shared-lib version: [version=${PROJECT_VERSION}] [soversion=${PROJECT_VERSION_MAJOR}]")
  else()
    reason_verbose("${TARGET_NAME} no shared-lib version")
  endif()
endmacro()

macro(reason__add_library__set_rpath TARGET_NAME)
  # Handle RPATH
  set_target_properties("${TARGET_NAME}" PROPERTIES INSTALL_RPATH "$ORIGIN/../lib")
  set_target_properties("${TARGET_NAME}" PROPERTIES INSTALL_RPATH_USE_LINK_PATH TRUE)
  reason_verbose("${TARGET_NAME} set rpath: [rpath='$ORIGIN/../lib']")
endmacro()

function(reason_add_library)
  set(options HELP STATIC SHARED)
  set(one_value_args TARGET FN)
  set(mlt_value_args INC_DIRS SRCS LINKS DEFINES)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_print_help_file("${REASON_MODULE_DIR}/reason.add_library.help")
  endif()

  reason_set_check(reason_TARGET "You must specify a TARGET when using 'reason_add_library'")
  reason_set_check(reason_SRCS   "You probably forgot to list the source files when using 'reason_add_library'")
  if((NOT reason_STATIC) AND (NOT reason_SHARED))
    reason_message(FATAL_ERROR "You must specify to build either STATIC or SHARED or both")
  endif()

  if(reason_FN)
    set(FN_ADD_LIBRARY "${reason_FN}")
  else()
    set(FN_ADD_LIBRARY "add_library")
  endif()

  reason_util_configure_and_include(
    "reason.add_library.in.cmake"
    "reason.add_library.${FN_ADD_LIBRARY}.out.cmake")
  reason__add_library__impl()
endfunction()
