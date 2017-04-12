function(reason__add_library__add_library TARGET_NAME TYPE SRCS)
  if("${TYPE}" STREQUAL "STATIC")
    @FN_ADD_LIBRARY@("${TARGET_NAME}" STATIC "${SRCS}")
  elseif("${TYPE}" STREQUAL "SHARED")
    @FN_ADD_LIBRARY@("${TARGET_NAME}" SHARED "${SRCS}")
  else()
    reason_message(FATAL_ERROR "reason_add_library has only 2 types: STATIC or SHARED")
  endif()

  reason_verbose("  @FN_ADD_LIBRARY@:")
  if(REASON_VERBOSE)
    foreach(SRC IN LISTS SRCS)
      reason_verbose("    [src=${SRC}]")
    endforeach()
  endif()
endfunction()

function(reason__add_library__impl)
  # Build static library
  if(reason_STATIC)
    reason_verbose("library: [target=${reason_TARGET}_s] [type=STATIC]")
    reason__add_library__add_library("${reason_TARGET}_s" STATIC "${reason_SRCS}")
    reason__add_library__tinclude_dirs("${reason_TARGET}_s" "${reason_INC_DIRS}")
    reason__add_library__tlink_libs_s("${reason_TARGET}_s" "${reason_LINKS}")
    reason__add_library__compile_define("${reason_TARGET}_s" "${reason_DEFINES}")
    reason__add_library__use_cotire("${reason_TARGET}_s")
    reason_unique_target_properties("${reason_TARGET}_s")
    reason_show_target_properties(VERBOSE "${reason_TARGET}_s")
  endif()

  # Build shared library
  if(reason_SHARED)
    reason_verbose("library: [target=${reason_TARGET}_d] [type=SHARED]")
    reason__add_library__add_library("${reason_TARGET}_d" SHARED "${reason_SRCS}")
    reason__add_library__tinclude_dirs("${reason_TARGET}_d" "${reason_INC_DIRS}")
    reason__add_library__tlink_libs_d("${reason_TARGET}_d" "${reason_LINKS}")
    reason__add_library__compile_define("${reason_TARGET}_d" "${reason_DEFINES}")
    reason__add_library__use_cotire("${reason_TARGET}_d")
    reason__add_library__set_shared_lib_version("${reason_TARGET}_d")
    reason__add_library__set_rpath("${reason_TARGET}_d")
    reason_unique_target_properties("${reason_TARGET}_d")
    reason_show_target_properties(VERBOSE "${reason_TARGET}_d")
  endif()
endfunction()