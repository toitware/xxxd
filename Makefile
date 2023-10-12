# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by an MIT-style license that can be
# found in the LICENSE file.

.PHONY: all
all: build

.PHONY: build
build: rebuild-cmake install-pkgs
	(cd build && ninja build)

.PHONY: test
test: rebuild-cmake install-pkgs
	 (cd build && ninja test)

.PHONY: build/CMakeCache.txt
build/CMakeCache.txt:
	$(MAKE) rebuild-cmake

.PHONY: install-pkgs
install-pkgs: rebuild-cmake
	(cd build && ninja download_packages)

# We rebuild the cmake file all the time.
# We use "glob" in the cmakefile, and wouldn't otherwise notice if a new
# file (for example a test) was added or removed.
# It takes <1s on Linux to run cmake, so it doesn't hurt to run it frequently.
.PHONY: rebuild-cmake
rebuild-cmake:
	mkdir -p build
	(cd build && cmake .. -G Ninja)
