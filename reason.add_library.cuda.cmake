function(reason__add_library__add_library TARGET_NAME TYPE SRCS)
  if("${TYPE}" STREQUAL "STATIC")
    cuda_add_library("${TARGET_NAME}" STATIC "${SRCS}")
  elseif("${TYPE}" STREQUAL "SHARED")
    cuda_add_library("${TARGET_NAME}" SHARED "${SRCS}")
  else()
    reason_message(FATAL_ERROR "reason_add_library has only 2 types: STATIC or SHARED")
  endif()

  reason_verbose("  cuda_add_library:")
  if(REASON_VERBOSE)
    foreach(SRC IN LISTS SRCS)
      reason_verbose("    [src=${SRC}]")
    endforeach()
  endif()
endfunction()

macro(reason__extract_INCLUDE_DIRECTORIES_to_CUDA_INCLUDE TARGET_NAME)
  # Use 'cuda_include_directories' to add include directories
  get_target_property(props "${TARGET_NAME}" "INCLUDE_DIRECTORIES")
  if((NOT "${props}" STREQUAL "props-NOTFOUND") AND (NOT "${props}" STREQUAL ""))
    reason_verbose("  cuda_include_directories:")
    foreach(prop IN LISTS props)
      # Removes cmake-generator-expression to raw PATH
      string(REGEX REPLACE "\\$<.*:" "" prop "${prop}")
      string(REGEX REPLACE ">" "" prop "${prop}")
      cuda_include_directories("${prop}")
      reason_verbose("    ${prop}")
    endforeach()
  endif()
endmacro()

macro(reason__extract_COMPILE_DEFINITIONS_to_NVCC_FLAGS TARGET_NAME)
  # Use CUDA_NVCC_FLAGS to define compile options
  get_target_property(props "${TARGET_NAME}" "COMPILE_OPTIONS")
  if((NOT "${props}" STREQUAL "props-NOTFOUND") AND (NOT "${props}" STREQUAL ""))
    set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};${props}")
    string(REGEX REPLACE ";+" ";" CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS}")
    string(REGEX REPLACE ";$" ""  CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS}")
    reason_verbose("  set CUDA_NVCC_FLAGS to: ${CUDA_NVCC_FALGS}")
  endif()
endmacro()

function(reason__add_library_s__impl)
  function(create_cuda_dummy_s DUMMY_NAME)
    set(REASON_VERBOSE FALSE)
    add_library("${DUMMY_NAME}" STATIC EXCLUDE_FROM_ALL "${REASON_MODULE_DIR}/reason.add_library.cuda.dummy_main.cpp")
    reason__add_library__tinclude_dirs("${DUMMY_NAME}" "${reason_INC_DIRS}")
    reason__add_library__tlink_libs_s("${DUMMY_NAME}" "${reason_LINKS}")
    reason__add_library__compile_define("${DUMMY_NAME}" "${reason_DEFINES}")
    reason_unique_target_properties("${DUMMY_NAME}")
  endfunction()

  reason_verbose("cuda-library: [target=${reason_TARGET}_s] [type=STATIC]")

  # Backup CUDA_NVCC_FLAGS, and CUDA_NVCC_INCLUDE_DIRS_USER
  set(CUDA_NVCC_INCLUDE_DIRS_USER_BACKUP "${CUDA_NVCC_INCLUDE_DIRS_USER}")
  set(CUDA_NVCC_FLAGS_BACKUP "${CUDA_NVCC_FLAGS}")

  # Create a dummy cuda target to extract include-dir dependencies and compile-options
  set(DUMMY_NAME "${reason_TARGET}_s__cuda_dummy")
  create_cuda_dummy_s("${DUMMY_NAME}")

  reason__extract_INCLUDE_DIRECTORIES_to_CUDA_INCLUDE("${DUMMY_NAME}")
  reason__extract_COMPILE_DEFINITIONS_to_NVCC_FLAGS("${DUMMY_NAME}")

  reason__add_library__add_library("${reason_TARGET}_s" STATIC "${reason_SRCS}")
  reason__add_library__tinclude_dirs("${reason_TARGET}_s" "${reason_INC_DIRS}")
  reason__add_library__tlink_libs_s("${reason_TARGET}_s" "${reason_LINKS}")
  reason__add_library__compile_define("${reason_TARGET}_s" "${reason_DEFINES}")
  reason__add_library__use_cotire("${reason_TARGET}_s")
  reason_unique_target_properties("${reason_TARGET}_s")
  reason_show_target_properties(VERBOSE "${reason_TARGET}_s")

  # Restore CUDA_NVCC_FLAGS, and CUDA_NVCC_INCLUDE_DIRS_USER
  set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS_BACKUP}")
  set(CUDA_NVCC_INCLUDE_DIRS_USER "${CUDA_NVCC_INCLUDE_DIRS_USER_BACKUP}")
endfunction()

function(reason__add_library_d__impl)
  function(create_cuda_dummy_d DUMMY_NAME)
    set(REASON_VERBOSE FALSE)
    add_library("${DUMMY_NAME}" SHARED EXCLUDE_FROM_ALL "${REASON_MODULE_DIR}/reason.add_library.cuda.dummy_main.cpp")
    reason__add_library__tinclude_dirs("${DUMMY_NAME}" "${reason_INC_DIRS}")
    reason__add_library__tlink_libs_d("${DUMMY_NAME}" "${reason_LINKS}")
    reason__add_library__compile_define("${DUMMY_NAME}" "${reason_DEFINES}")
    reason_unique_target_properties("${DUMMY_NAME}")
  endfunction()

  reason_verbose("cuda-library: [target=${reason_TARGET}_d] [type=SHARED]")

  # Backup CUDA_NVCC_FLAGS, and CUDA_NVCC_INCLUDE_DIRS_USER
  set(CUDA_NVCC_INCLUDE_DIRS_USER_BACKUP "${CUDA_NVCC_INCLUDE_DIRS_USER}")
  set(CUDA_NVCC_FLAGS_BACKUP "${CUDA_NVCC_FLAGS}")

  # Create a dummy cuda target to extract include-dir dependencies and compile-options
  set(DUMMY_NAME "${reason_TARGET}_d__cuda_dummy")
  create_cuda_dummy_d("${DUMMY_NAME}")

  reason__extract_INCLUDE_DIRECTORIES_to_CUDA_INCLUDE("${DUMMY_NAME}")
  reason__extract_COMPILE_DEFINITIONS_to_NVCC_FLAGS("${DUMMY_NAME}")

  reason__add_library__add_library("${reason_TARGET}_d" SHARED "${reason_SRCS}")
  reason__add_library__tinclude_dirs("${reason_TARGET}_d" "${reason_INC_DIRS}")
  reason__add_library__tlink_libs_d("${reason_TARGET}_d" "${reason_LINKS}")
  reason__add_library__compile_define("${reason_TARGET}_d" "${reason_DEFINES}")
  reason__add_library__use_cotire("${reason_TARGET}_d")
  reason__add_library__set_shared_lib_version("${reason_TARGET}_d")
  reason__add_library__set_rpath("${reason_TARGET}_d")
  reason_unique_target_properties("${reason_TARGET}_d")
  reason_show_target_properties(VERBOSE "${reason_TARGET}_d")

  # Restore CUDA_NVCC_FLAGS, and CUDA_NVCC_INCLUDE_DIRS_USER
  set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS_BACKUP}")
  set(CUDA_NVCC_INCLUDE_DIRS_USER "${CUDA_NVCC_INCLUDE_DIRS_USER_BACKUP}")
endfunction()

function(reason__add_library__impl)
  # Build static library
  if(reason_STATIC)
    reason__add_library_s__impl()
  endif()

  # Build shared library
  if(reason_SHARED)
    reason__add_library_d__impl()
  endif()
endfunction()
