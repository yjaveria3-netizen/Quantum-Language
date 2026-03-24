@echo off
setlocal

echo.
echo   Building Quantum Language v2.0.0  ^|  Bytecode VM
echo.
echo   quantum hello.sa  =^>  hello.exe   (compile + bundle)
echo   qrun    hello.sa  =^>  runs directly  (interpret)
echo.

rem ── Detect make tool ──────────────────────────────────────────────────────────
set MAKE_EXE=
where mingw32-make >nul 2>&1
if not errorlevel 1 (
    set MAKE_EXE=mingw32-make
    echo   Using: mingw32-make
    goto :cmake_gen
)
where make >nul 2>&1
if not errorlevel 1 (
    set MAKE_EXE=make
    echo   Using: make
    goto :cmake_gen
)
where ninja >nul 2>&1
if not errorlevel 1 (
    set MAKE_EXE=ninja
    echo   Using: ninja
    goto :cmake_gen
)

echo   [ERROR] No build tool found (tried mingw32-make, make, ninja).
echo   Install MinGW or Ninja and add it to PATH.
pause
exit /b 1

:cmake_gen
rem ── Run CMake in build\ ────────────────────────────────────────────────────────
if not exist build mkdir build
cd build

if "%MAKE_EXE%"=="ninja" (
    cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=Release 2> ..\build_errors.txt
) else (
    cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release 2> ..\build_errors.txt
)

if errorlevel 1 (
    cd ..
    echo.
    echo   [ERROR] CMake configuration failed:
    type build_errors.txt
    pause
    exit /b 1
)

"%MAKE_EXE%" 2>> ..\build_errors.txt
if errorlevel 1 (
    cd ..
    echo.
    echo   [ERROR] Compile failed:
    type build_errors.txt
    pause
    exit /b 1
)

cd ..

rem ── Copy all three binaries to the project root ───────────────────────────────
copy /Y build\quantum.exe      quantum.exe      >nul
copy /Y build\qrun.exe         qrun.exe         >nul
copy /Y build\quantum_stub.exe quantum_stub.exe >nul

echo.
echo   Build successful!
echo.
echo   Binaries copied to project root:
echo     quantum.exe       ^<-- compiler + bundler
echo     qrun.exe          ^<-- direct interpreter
echo     quantum_stub.exe  ^<-- standalone runtime  (used as hello.exe template)
echo.
echo   Usage:
echo     quantum hello.sa        ^<-- compiles hello.sa into hello.exe, then runs it
echo     qrun    hello.sa        ^<-- interprets hello.sa in-place, no .exe created
echo.
echo   Other flags (both tools):
echo     quantum --debug hello.sa    ^<-- dump bytecode then run
echo     quantum --dis   hello.sa    ^<-- dump bytecode only
echo     quantum --check hello.sa    ^<-- parse + type-check only
echo     quantum --test  examples    ^<-- batch test all .sa files
echo.
endlocal