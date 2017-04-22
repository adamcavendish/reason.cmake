function(reason__add_executable__add_executable TARGET_NAME SRCS)
  cuda_add_executable("${TARGET_NAME}" "${SRCS}")
  reason_verbose("  cuda_add_executable:")
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

function(reason__add_executable__impl)
  function(create_cuda_dummy DUMMY_NAME)
    set(REASON_VERBOSE FALSE)
    add_executable("${DUMMY_NAME}" EXCLUDE_FROM_ALL "${REASON_MODULE_DIR}/reason.add_executable.cuda.dummy_main.cpp")
    reason__add_executable__tinclude_dirs("${DUMMY_NAME}" "${reason_INC_DIRS}")
    reason__add_executable__tlink_libs("${DUMMY_NAME}" "${reason_LINKS}")
    reason__add_executable__compile_define("${DUMMY_NAME}" "${reason_DEFINES}")
    reason_unique_target_properties("${DUMMY_NAME}")
  endfunction()

  reason_verbose("cuda-executable: [target=${reason_TARGET}]")

  # Backup CUDA_NVCC_FLAGS, and CUDA_NVCC_INCLUDE_DIRS_USER
  set(CUDA_NVCC_INCLUDE_DIRS_USER_BACKUP "${CUDA_NVCC_INCLUDE_DIRS_USER}")
  set(CUDA_NVCC_FLAGS_BACKUP "${CUDA_NVCC_FLAGS}")

  # Create a dummy cuda target to extract include-dir dependencies and compile-options
  set(DUMMY_NAME "${reason_TARGET}__cuda_dummy")
  create_cuda_dummy("${DUMMY_NAME}")

  reason__extract_INCLUDE_DIRECTORIES_to_CUDA_INCLUDE("${DUMMY_NAME}")
  reason__extract_COMPILE_DEFINITIONS_to_NVCC_FLAGS("${DUMMY_NAME}")

  reason__add_executable__add_executable("${reason_TARGET}" "${reason_SRCS}")
  reason__add_executable__tinclude_dirs("${reason_TARGET}" "${reason_INC_DIRS}")
  reason__add_executable__tlink_libs("${reason_TARGET}" "${reason_LINKS}")
  reason__add_executable__compile_define("${reason_TARGET}" "${reason_DEFINES}")
  reason__add_executable__set_rpath("${reason_TARGET}")
  reason_unique_target_properties("${reason_TARGET}")
  reason_show_target_properties(VERBOSE "${reason_TARGET}")

  # Restore CUDA_NVCC_FLAGS, and CUDA_NVCC_INCLUDE_DIRS_USER
  set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS_BACKUP}")
  set(CUDA_NVCC_INCLUDE_DIRS_USER "${CUDA_NVCC_INCLUDE_DIRS_USER_BACKUP}")
endfunction()
