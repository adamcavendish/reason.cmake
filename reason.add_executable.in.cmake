function(reason__add_executable__add_executable TARGET_NAME SRCS)
  @FN_ADD_EXECUTABLE@("${TARGET_NAME}" "${SRCS}")
  reason_verbose("  @FN_ADD_EXECUTABLE@():")
  if(REASON_VERBOSE)
    foreach(SRC IN LISTS SRCS)
      reason_verbose("    [src=${SRC}]")
    endforeach()
  endif()
endfunction()

function(reason__add_executable__impl)
  reason_verbose("executable: [target=${reason_TARGET}]")
  reason__add_executable__add_executable("${reason_TARGET}" "${reason_SRCS}")
  reason__add_executable__tinclude_dirs("${reason_TARGET}" "${reason_INC_DIRS}")
  reason__add_executable__tlink_libs("${reason_TARGET}" "${reason_LINKS}")
  reason__add_executable__compile_define("${reason_TARGET}" "${reason_DEFINES}")
  reason__add_executable__set_rpath("${reason_TARGET}")
  reason__add_executable__use_cotire("${reason_TARGET}")
  reason_unique_target_properties("${reason_TARGET}")
  reason_show_target_properties(VERBOSE "${reason_TARGET}")
endfunction()
