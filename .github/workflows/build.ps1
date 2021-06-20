param (
    [Parameter(Mandatory)] $vs,
    [Parameter(Mandatory)] $arch
)

$ErrorActionPreference = "Stop"

New-Item "winlib_deps" -ItemType "directory"

$temp = New-TemporaryFile | Rename-Item -NewName {$_.Name + ".zip"} -PassThru
Invoke-WebRequest "https://windows.php.net/downloads/php-sdk/deps/$vs/$arch/libbzip2-1.0.8-$vs-$arch.zip" -OutFile $temp
Expand-Archive $temp -DestinationPath "winlib_deps"

$temp = New-TemporaryFile | Rename-Item -NewName {$_.Name + ".zip"} -PassThru
Invoke-WebRequest "https://windows.php.net/downloads/php-sdk/deps/$vs/$arch/liblzma-5.2.5-1-$vs-$arch.zip" -OutFile $temp
Expand-Archive $temp -DestinationPath "winlib_deps"

$temp = New-TemporaryFile | Rename-Item -NewName {$_.Name + ".zip"} -PassThru
Invoke-WebRequest "https://windows.php.net/downloads/php-sdk/deps/$vs/$arch/zlib-1.2.11-$vs-$arch.zip" -OutFile $temp
Expand-Archive $temp -DestinationPath "winlib_deps"

New-Item "build" -ItemType "directory"
Set-Location "build"
cmake -G "NMake Makefiles" "-DCMAKE_BUILD_TYPE=RelWithDebInfo" "-DZLIB_INCLUDE_DIR=..\winlib_deps\include" "-DZLIB_LIBRARY=..\winlibs_deps\lib\zlib_a.lib" "-DBZIP2_INCLUDE_DIR=..\winlibs_deps\include" "-DBZIP2_LIBRARIES=..\winlibs_deps\lib\libbz2_a.lib" "-DLIBLZMA_INCLUDE_DIR=..\winlibs_deps\include" "-DLIBLZMA_LIBRARY=..\winlibs_deps\lib\liblzma_a.lib" "-DBUILD_TOOLS=OFF" "-DBUILD_REGRESS=OFF" "-DBUILD_EXAMPLES=OFF" "-DBUILD_DOC=OFF" ".."
nmake
