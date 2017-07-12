if("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" LESS 3.3)
   message(FATAL_ERROR "CMake >= 3.3 required")
endif()

if(DEFINED REASON_MODULE_DIR)
  return()
endif()

# Use to specify where the 'reason.cmake' directory is
set(REASON_MODULE_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Use cotire if possible
# @see https://github.com/sakra/cotire
include(cotire OPTIONAL)

# Reasonable CMake Project
include("${REASON_MODULE_DIR}/reason.properties.cmake")
include("${REASON_MODULE_DIR}/reason.color.cmake")
include("${REASON_MODULE_DIR}/reason.util.cmake")

reason_verbose("reason verbose: ON")

include("${REASON_MODULE_DIR}/reason.add_library.cmake")
include("${REASON_MODULE_DIR}/reason.add_interface_library.cmake")
include("${REASON_MODULE_DIR}/reason.add_executable.cmake")
include("${REASON_MODULE_DIR}/reason.install.cmake")
include("${REASON_MODULE_DIR}/reason.add_multiple_tests.cmake")
include("${REASON_MODULE_DIR}/reason.pack_deb.cmake")

reason_message(STATUS "reason loaded")

function(reason)
  reason_print_help_file("${REASON_MODULE_DIR}/reason.help")
endfunction()
