if("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" LESS 3.3)
   message(FATAL_ERROR "CMake >= 3.3 required")
endif()

# Use to specify where the 'reason.cmake' directory is
set(REASON_MODULE_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Global Variables @TODO Document it
# 1. REASON_VERBOSE
# 2. REASON_USE_COTIRE
# 3. REASON_BRIEF_PATH

# Reasonable CMake Project
include("reason.color")
include("reason.util")
# Use cotire if possible
# @see https://github.com/sakra/cotire
include(cotire OPTIONAL)

reason_verbose("reason verbose: ON")
include("reason.add_library")
include("reason.add_interface_library")
include("reason.add_executable")
include("reason.install")
include("reason.add_multiple_tests")
include("reason.pack_deb")
reason_message(STATUS "reason loaded")

function(reason)
  reason_print_help_file("README.md")
endfunction()
