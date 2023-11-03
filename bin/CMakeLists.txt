# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by an MIT-style license that can be
# found in the LICENSE file.

toit_project(xxxd "${CMAKE_CURRENT_LIST_DIR}")

set(XXXD_SOURCE "${CMAKE_CURRENT_LIST_DIR}/xxxd.toit")
set(XXXD_EXE "${CMAKE_BINARY_DIR}/xxxd${CMAKE_EXECUTABLE_SUFFIX}")
set(XXXD_DEP "${CMAKE_CURRENT_BINARY_DIR}/xxxd.dep")
set(TR_SOURCE "${CMAKE_CURRENT_LIST_DIR}/tr.toit")
set(TR_EXE "${CMAKE_BINARY_DIR}/tr${CMAKE_EXECUTABLE_SUFFIX}")
set(TR_DEP "${CMAKE_CURRENT_BINARY_DIR}/tr.dep")

ADD_TOIT_EXE(
  ${XXXD_SOURCE}
  ${XXXD_EXE}
  ${XXXD_DEP}
  ""
)

ADD_TOIT_EXE(
  ${TR_SOURCE}
  ${TR_EXE}
  ${TR_DEP}
  ""
)

add_custom_target(
  build_binaries
  DEPENDS ${XXXD_EXE} ${TR_EXE}
)

add_dependencies(build build_binaries)
