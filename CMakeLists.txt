cmake_minimum_required(VERSION 3.14)

# Detect whether this CMakeLists is the top-level project so embedders
# (e.g. FetchContent_MakeAvailable) get sensible defaults.
if(NOT DEFINED CPPCORE_IS_TOP_LEVEL)
	if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
		set(CPPCORE_IS_TOP_LEVEL TRUE)
	else()
		set(CPPCORE_IS_TOP_LEVEL FALSE)
	endif()
endif()

set(TARGET_NAME cppcore)
project(${TARGET_NAME})

option(CPPCORE_BUILD_TESTS "Build cppcore tests" ${CPPCORE_IS_TOP_LEVEL})

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
