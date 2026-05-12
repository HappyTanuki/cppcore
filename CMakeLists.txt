cmake_minimum_required(VERSION 3.21)

set(TARGET_NAME cppcore)
project(${TARGET_NAME})

# PROJECT_IS_TOP_LEVEL is set automatically by project() in CMake 3.21+.
# Tests build by default for top-level invocations and are skipped when
# embedded via FetchContent / add_subdirectory.
option(CPPCORE_BUILD_TESTS "Build cppcore tests" ${PROJECT_IS_TOP_LEVEL})

# Fallback output paths for when CMake is invoked without a preset
# (e.g. plain `cmake ../../Src` from a CI script). When a preset is in use,
# CMAKE_*_OUTPUT_DIRECTORY is set via cacheVariables and we keep it.
if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
	if(MSVC)
		set(_DEFAULT_OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Build/WindowsRelease)
	elseif(APPLE)
		set(_DEFAULT_OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Build/MacOSXRelease)
	else()
		set(_DEFAULT_OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Build/LinuxRelease)
	endif()
	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${_DEFAULT_OUTPUT_DIR})
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${_DEFAULT_OUTPUT_DIR})
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${_DEFAULT_OUTPUT_DIR})
endif()

add_subdirectory(Src)

if(CPPCORE_BUILD_TESTS)
	enable_testing()
	add_subdirectory(Test)
endif()
