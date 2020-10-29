!IFNDEF VERSION
VERSION=unknown
!ENDIF

!IF "$(PHP_SDK_ARCH)" == "x64"
PLATFORM=x64
!ELSE
PLATFORM=Win32
!ENDIF

!IF $(PHP_SDK_VS_NUM) >= 16
LZMA_OPTS=-DLIBLZMA_INCLUDE_DIR=$(MAKEDIR)\deps\include -DLIBLZMA_LIBRARY=$(MAKEDIR)\deps\lib\liblzma_a.lib
LZMA_DEBUG_OPTS=-DLIBLZMA_INCLUDE_DIR=$(MAKEDIR)\deps\include -DLIBLZMA_LIBRARY=$(MAKEDIR)\deps\lib\liblzma_a_debug.lib
!ELSE
LZMA_OPTS=
LZMA_DEBUG_OPTS=
!ENDIF

DEPS_DIR=$(MAKEDIR)\..\deps

OUTPUT=$(MAKEDIR)\..\libzip-$(VERSION)-$(PHP_SDK_VS)-$(PHP_SDK_ARCH)
ARCHIVE=$(OUTPUT).zip

all:
	git checkout .
	git clean -fdx

	-rmdir /s /q build
	mkdir build
	cd build
	cmake .. -DCMAKE_GENERATOR_PLATFORM=$(PLATFORM) -DZLIB_INCLUDE_DIR=$(DEPS_DIR)\include -DZLIB_LIBRARY=$(DEPS_DIR)\lib\zlib_a.lib -DBZIP2_INCLUDE_DIR=$(DEPS_DIR)\include -DBZIP2_LIBRARIES=$(DEPS_DIR)\lib\libbz2_a.lib $(LZMA_OPTS) -DBUILD_REGRESS=OFF
	cd $(MAKEDIR)\build
	msbuild /t:libzip_a /p:configuration=RelWithDebInfo /p:platform=$(PLATFORM) libzip.sln

	cmake .. -DCMAKE_GENERATOR_PLATFORM=$(PLATFORM) -DZLIB_INCLUDE_DIR=$(DEPS_DIR)\include -DZLIB_LIBRARY=$(DEPS_DIR)\lib\zlib_a.lib -DBZIP2_INCLUDE_DIR=$(DEPS_DIR)\include -DBZIP2_LIBRARIES=$(DEPS_DIR)\lib\libbz2_a_debug.lib $(LZMA_DEBUG_OPTS) -DBUILD_REGRESS=OFF
	cd $(MAKEDIR)\build
	msbuild /t:libzip_a /p:configuration=Debug /p:platform=$(PLATFORM) libzip.sln

	-rmdir /s /q $(OUTPUT)
	xcopy ..\lib\zip.h $(OUTPUT)\include\*
	xcopy zipconf.h $(OUTPUT)\include\*
	xcopy lib\RelWithDebInfo\libzip_a.lib $(OUTPUT)\lib\*
	xcopy lib\libzip_a.dir\RelWithDebInfo\libzip_a.pdb $(OUTPUT)\lib\*
	xcopy lib\Debug\libzip_a_debug.* $(OUTPUT)\lib\*

	del $(ARCHIVE)
	7za a $(ARCHIVE) $(OUTPUT)\*
