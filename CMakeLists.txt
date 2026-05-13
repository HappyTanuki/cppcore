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

# MSVC optimization flags for non-Debug configs. Scoped to this directory
# tree so they do not leak into parent projects that consume cppcore via
# add_subdirectory / FetchContent.
if(MSVC)
	# /Oi  : emit intrinsics inline (memcpy, memset, ...) instead of CRT calls.
	# /Gy  : per-function COMDAT sections so the linker can drop unreferenced
	#        functions and fold identical ones (prerequisite for /OPT:REF,ICF).
	add_compile_options(
		$<$<NOT:$<CONFIG:Debug>>:/Oi>
		$<$<NOT:$<CONFIG:Debug>>:/Gy>
	)
	# /OPT:REF : strip functions and data never referenced by the image.
	# /OPT:ICF : fold functions with identical machine code into one symbol.
	add_link_options(
		$<$<NOT:$<CONFIG:Debug>>:/OPT:REF>
		$<$<NOT:$<CONFIG:Debug>>:/OPT:ICF>
	)
	# Whole-program / link-time code generation (/GL + /LTCG): defer codegen
	# to link so the optimizer can inline and propagate across TUs.
	set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
	set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO TRUE)
	set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL TRUE)
endif()

add_subdirectory(Src)

if(CPPCORE_BUILD_TESTS)
	enable_testing()
	add_subdirectory(Test)
endif()
