if("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" LESS 3.3)
   message(FATAL_ERROR "CMake >= 3.3 required")
endif()

# Global Variables @TODO Document it
# 1. REASON_VERBOSE
# 2. REASON_USE_COTIRE

# Reasonable CMake Project
include("reason.color")
include("reason.util")
# Use cotire if possible
# @see https://github.com/sakra/cotire
include(cotire OPTIONAL)

reason_verbose(STATUS "reason verbose: ON")
include("reason.add_library")
include("reason.add_interface_library")
include("reason.add_executable")
include("reason.install")
include("reason.add_multiple_tests")
include("reason.pack_deb")
reason_message(STATUS "reason loaded")
