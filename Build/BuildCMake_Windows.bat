@echo off
setlocal enabledelayedexpansion

REM ==========================================================
REM CMake wrapper for Windows: sets up MSVC environment via
REM vcvarsall.bat, then runs `cmake --preset` / `cmake --build`.
REM
REM Usage:
REM   BuildCMake_Windows.bat                       -> Windows-x64-DLL, Debug + Release
REM   BuildCMake_Windows.bat <ARCH>                -> ARCH = x64 | x86
REM   BuildCMake_Windows.bat <ARCH> <RT>           -> RT   = DLL | Static
REM   BuildCMake_Windows.bat <ARCH> <RT> <CFG>     -> CFG  = Debug | Release | All
REM ==========================================================

set "ARCH=%~1"
if "%ARCH%"=="" set "ARCH=x64"

set "RT=%~2"
if "%RT%"=="" set "RT=DLL"

set "CFG=%~3"
if "%CFG%"=="" set "CFG=All"

REM Configure preset name
set "CONFIGURE_PRESET=Windows-%ARCH%-%RT%"

REM Build preset suffix: DLL -> "", Static -> "-MT"
if /I "%RT%"=="DLL" (
    set "BUILD_SUFFIX="
) else if /I "%RT%"=="Static" (
    set "BUILD_SUFFIX=-MT"
) else (
    echo [ERROR] Unsupported RT: %RT% (use DLL or Static^)
    exit /b 1
)

REM vcvarsall.bat argument
if /I "%ARCH%"=="x64" (
    set "VCVARS_ARCH=x64"
) else if /I "%ARCH%"=="x86" (
    set "VCVARS_ARCH=x86"
) else (
    echo [ERROR] Unsupported ARCH: %ARCH% (use x64 or x86^)
    exit /b 1
)

REM Locate Visual Studio via vswhere
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
    echo [ERROR] vswhere.exe not found at "%VSWHERE%"
    echo Please install Visual Studio 2017 or newer.
    exit /b 1
)

set "VSINSTALL="
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -prerelease -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
    set "VSINSTALL=%%i"
)

if not defined VSINSTALL (
    echo [ERROR] No Visual Studio installation with C++ tools detected.
    exit /b 1
)

set "VCVARSALL=%VSINSTALL%\VC\Auxiliary\Build\vcvarsall.bat"
if not exist "%VCVARSALL%" (
    echo [ERROR] vcvarsall.bat not found at "%VCVARSALL%"
    exit /b 1
)

echo [INFO] Visual Studio: %VSINSTALL%
echo [INFO] Configure preset: %CONFIGURE_PRESET%
echo [INFO] vcvars arch: %VCVARS_ARCH%

call "%VCVARSALL%" %VCVARS_ARCH%
if errorlevel 1 (
    echo [ERROR] vcvarsall.bat failed.
    exit /b 1
)

pushd "%~dp0\.."

cmake --preset %CONFIGURE_PRESET%
if errorlevel 1 (
    popd
    exit /b 1
)

if /I "%CFG%"=="All" (
    cmake --build --preset Windows-%ARCH%-Debug%BUILD_SUFFIX% || (popd & exit /b 1)
    cmake --build --preset Windows-%ARCH%-Release%BUILD_SUFFIX% || (popd & exit /b 1)
) else (
    cmake --build --preset Windows-%ARCH%-%CFG%%BUILD_SUFFIX% || (popd & exit /b 1)
)

popd
exit /b 0
