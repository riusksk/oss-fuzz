#!/bin/bash -eu
# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

cd /src/libchewing

# build the library.
./autogen.sh
./configure --disable-shared --enable-static --without-sqlite3
make clean all

# build your fuzzer(s)
make -C test CFLAGS="$CFLAGS -Dmain=stress_main -Drand=get_fuzz_input" stress.o

$CC $CFLAGS \
    -o /out/chewing_fuzzer \
    /src/chewing_fuzzer.c \
    test/stress.o test/.libs/libtesthelper.a src/.libs/libchewing.a \
    /work/libfuzzer/*.o $LDFLAGS

# install data files
make -C data pkgdatadir=/out install
