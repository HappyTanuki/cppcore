cmake_minimum_required(VERSION 3.21)

set(CPPCORE_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../Inc)

##############################################################
## Module helper
##############################################################
# Mirrors the per-folder vcxproj layout: each module becomes a pair of
# OBJECT libraries (A: MultiByte, W: Unicode) compiled with the folder's
# own stdafx.h as a precompiled header. The unified cppcore static lib
# downstream pulls the object files from every module.
function(add_cppcore_module MODULE)
	set(MODULE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${MODULE})

	file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS ${MODULE_DIR}/*.cpp ${MODULE_DIR}/*.c)

	# Drop sources that belong to other platforms based on the *_Win /
	# *_Linux / *_Mac / *_Linux_Mac filename suffix.
	if(MSVC)
		list(FILTER SOURCES EXCLUDE REGEX "_Linux\\.cpp$|_Linux_Mac\\.cpp$|_Mac\\.cpp$")
	elseif(APPLE)
		list(FILTER SOURCES EXCLUDE REGEX "_Win\\.cpp$|_Linux\\.cpp$")
	else()
		list(FILTER SOURCES EXCLUDE REGEX "_Win\\.cpp$|_Mac\\.cpp$")
	endif()

	set(PCH_HEADER ${MODULE_DIR}/stdafx.h)

	foreach(VARIANT A W)
		set(TGT ${MODULE}${VARIANT})
		add_library(${TGT} OBJECT ${SOURCES})
		target_include_directories(${TGT} PRIVATE $<BUILD_INTERFACE:${CPPCORE_INCLUDE_DIR}>)
		target_compile_features(${TGT} PRIVATE cxx_std_23)
		if(NOT MSVC)
			target_compile_options(${TGT} PRIVATE -fPIC -Wno-narrowing)
		endif()
		if(EXISTS ${PCH_HEADER})
			target_precompile_headers(${TGT} PRIVATE ${PCH_HEADER})
		endif()
	endforeach()

	# Wide-character variant compiles with the Win32 Unicode API selected.
	target_compile_definitions(${MODULE}W PRIVATE UNICODE _UNICODE)

	# CMake auto-injects the PCH into every TU; .c sources cannot consume
	# a C++ PCH, so opt them out per source.
	foreach(SRC ${SOURCES})
		if(SRC MATCHES "\\.c$")
			set_source_files_properties(${SRC}
				TARGET_DIRECTORY ${MODULE}A ${MODULE}W
				PROPERTIES SKIP_PRECOMPILE_HEADERS ON)
		endif()
	endforeach()
endfunction()

##############################################################
## Modules
##############################################################
set(CPPCORE_MODULES
	000_String
	001_Encoder
	100_System
	200_Common
	300_Formatter
	400_Server)

foreach(M ${CPPCORE_MODULES})
	add_cppcore_module(${M})
endforeach()

##############################################################
## Unified static library
##############################################################
set(_CPPCORE_OBJECTS)
foreach(M ${CPPCORE_MODULES})
	list(APPEND _CPPCORE_OBJECTS $<TARGET_OBJECTS:${M}A> $<TARGET_OBJECTS:${M}W>)
endforeach()

add_library(${TARGET_NAME} STATIC ${_CPPCORE_OBJECTS})
# $<TARGET_OBJECTS:...> carries .obj files only; usage requirements from the
# per-module OBJECT libraries are not inherited, so declare the consumer-
# facing include path and language standard on the unified target.
# UNICODE / _UNICODE are not declared here on purpose: the W-variant TUs
# are already compiled with them (PRIVATE on each ${MODULE}W), and the
# resulting cppcore.lib contains both A and W symbols. Consumers pick A
# or W by setting (or not setting) UNICODE in their own build.
target_include_directories(${TARGET_NAME} PUBLIC $<BUILD_INTERFACE:${CPPCORE_INCLUDE_DIR}>)
target_compile_features(${TARGET_NAME} PUBLIC cxx_std_23)

# Namespaced alias so external projects can link via `cppcore::cppcore`
# without colliding on the plain `cppcore` name.
add_library(cppcore::cppcore ALIAS ${TARGET_NAME})
