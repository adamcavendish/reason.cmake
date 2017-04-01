macro(reason_pack_deb)
  set(options HELP)
  set(one_value_args PACKNAME CONTACT DESCSUM DESC DESP_FILE LICENSE_FILE ARCH DEBDEP SECTION PRIORITY)
  set(mlt_value_args)
  cmake_parse_arguments(reason "${options}" "${one_value_args}" "${mlt_value_args}" "${ARGN}")

  if (reason_HELP)
    reason_message(AUTHOR_WARNING "reason_pack_deb: reasonable pack deb package for you
params:
  - PACKNAME     (STRING): package name (optional)
  - CONTACT      (STRING): package contact (valid email required)
                           @example: Firstname Lastname <email@example.com>
  - DESCSUM      (STRING): package description summary (optional)
  - DESC         (STRING): package description (long) (optional)
  - DESP_FILE    (STRING): package description file, usually the path to README (optional)
  - LICENSE_FILE (STRING): package licence file path (optional)
  - ARCH         (STRING): package architecture: i386, i686, amd64, armhf, etc.
  - DEBDEP       (STRING): package debian dependencies (use `dpkg -s <package>` to see an example)
                           @example: 'libgstreamer1.0-dev (>= 1.2.4), gstreamer1.0-tools (>= 1.2.3)'
  - SECTION      (STRING): package section (devel is recommended for general use)
                           @see: https://packages.debian.org/en/stable/ for all package sections
  - PRIORITY     (STRING): package priority (mostly 'optional')
                           @see https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics.en.html#s-priority")
    reason_message(FATAL_ERROR)
  endif()

  reason_set_check(reason_CONTACT  "reason_pack_deb: CONTACT is required, i.e. <email@example.com>")
  reason_set_check(reason_ARCH     "reason_pack_deb: ARCH must be defined, i.e. i386, amd64, armhf")
  reason_set_check(PROJECT_VERSION "reason_pack_deb: project's version must be set, i.e. project(foo VERSION 1.0.0), or manually set PROJECT_VERSION variable")

  list(APPEND CPACK_GENERATOR "DEB")

  reason_set_or(CPACK_PACKAGE_NAME "${reason_PACKNAME}" "${PROJECT_NAME}")
  reason_set_if(CPACK_PACKAGE_CONTACT "${reason_CONTACT}")

  reason_set_if(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
  reason_set_if(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
  reason_set_if(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
  reason_set_if(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")

  reason_set_if(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${reason_DESCSUM}")
  reason_set_if(CPACK_PACKAGE_DESCRIPTION "${reason_DESC}")
  reason_set_if(CPACK_PACKAGE_DESCRIPTION_FILE "${reason_DESP_FILE}")
  reason_set_if(CPACK_RESOURCE_FILE_LICENSE "${reason_LICENSE_FILE}")

  reason_set_if(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${reason_ARCH}")
  reason_set_if(CPACK_DEBIAN_PACKAGE_DEPENDS "${reason_DEBDEP}")
  reason_set_if(CPACK_DEBIAN_PACKAGE_SECTION "${reason_SECTION}")
  reason_set_if(CPACK_DEBIAN_PACKAGE_PRIORITY "${reason_PRIORITY}")
endmacro()
