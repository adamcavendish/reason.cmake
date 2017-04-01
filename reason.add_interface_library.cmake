function(reason_add_interface_library)
  set(options HELP)
  set(one_value_args TARGET)
  set(mlt_value_args INC_DIRS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  # @TODO HELP
  reason_set_check(reason_TARGET   "reason_add_interface_library: TARGET is required")
  reason_set_check(reason_INC_DIRS "reason_add_interface_library: INC_DIRS is required")

  add_library("${reason_TARGET}" INTERFACE)
  # add target_sources
  foreach(INC_DIR IN LISTS reason_INC_DIRS)
    file(GLOB_RECURSE HDRS "${INC_DIR}/*")
    target_sources("${reason_TARGET}" INTERFACE "$<BUILD_INTERFACE:${HDRS}>")
  endforeach()
  # add target include directories
  foreach(INC_DIR IN LISTS reason_INC_DIRS)
    target_include_directories("${reason_TARGET}"
      INTERFACE "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}>" "$<INSTALL_INTERFACE:include>")
  endforeach()

endfunction()
