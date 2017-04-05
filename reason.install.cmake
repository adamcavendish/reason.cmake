function(reason__install_header_one INC_DIR)
  file(GLOB CHILDREN RELATIVE "${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}" "${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}/*")
  foreach(CHILD IN LISTS CHILDREN)
    if(IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/${INC_DIR}/${CHILD}")
      install(DIRECTORY "${INC_DIR}/${CHILD}" DESTINATION "include")
    else()
      install(FILES "${INC_DIR}/${CHILD}" DESTINATION "include")
    endif()
  endforeach()
endfunction()

function(reason_install)
  set(options HELP)
  set(one_value_args)
  set(mlt_value_args TARGETS INC_DIRS)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if(reason_HELP)
    reason_print_help("reason_install: reasonable install
params:
  - TARGETS  (LIST): The target names, including all executables, libraries both static and shared
  - INC_DIRS (LIST): Include directories to install
description:
  Automatically generates cmake's config file for you. You might use 'find_package' or 'include'
  in CMakeLists.txt of other projects to find this package.
exemple:
1. Project with headers
   reason_install(TARGETS \"demo1\" INC_DIRS \"include\")
2. Project with no headers
   reason_install(TARGETS \"demo2\")
")
  endif()

  install(TARGETS ${reason_TARGETS}
    EXPORT "${PROJECT_NAME}Config"
    RUNTIME DESTINATION "bin"
    ARCHIVE DESTINATION "lib"
    LIBRARY DESTINATION "lib")

  # Install include directories
  if(reason_INC_DIRS)
    foreach(INC_DIR IN LISTS reason_INC_DIRS)
      reason__install_header_one("${INC_DIR}")
    endforeach()
  endif()

  # make it an importable project
  install(EXPORT "${PROJECT_NAME}Config" DESTINATION "share/${PROJECT_NAME}/cmake")
endfunction()
