cmake_minimum_required(VERSION 3.21)

# Test sources reference data via the relative path ../../Build/Test/<dir>/file,
# so tests must run with WORKING_DIRECTORY set to <repo>/Build/Test/. Exposed
# as TEST_WORKING_DIRECTORY so DummyProcess / DummyDynamicLibrary can mirror
# their artifacts into the same folder.
set(TEST_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../Build/Test CACHE INTERNAL "")

##############################################################
## Test executable helper (mirrors add_cppcore_module in Src/)
##############################################################
# Builds an A (MultiByte) and W (Unicode) gtest executable pair for the
# named module, links them against cppcore, and registers each with ctest
# under its target name. The bundled gtest amalgamation under Inc/ is
# appended automatically so individual test dirs don't have to list it.
function(add_cppcore_test MODULE)
	set(MODULE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${MODULE})

	file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS ${MODULE_DIR}/*.cpp ${MODULE_DIR}/*.c)
	if(MSVC)
		list(FILTER SOURCES EXCLUDE REGEX "_Linux\\.cpp$|_Linux_Mac\\.cpp$|_Mac\\.cpp$")
	elseif(APPLE)
		list(FILTER SOURCES EXCLUDE REGEX "_Win\\.cpp$|_Linux\\.cpp$")
	else()
		list(FILTER SOURCES EXCLUDE REGEX "_Win\\.cpp$|_Mac\\.cpp$")
	endif()

	list(APPEND SOURCES
		${CMAKE_CURRENT_SOURCE_DIR}/../Inc/gtest-all.cc
		${CMAKE_CURRENT_SOURCE_DIR}/../Inc/gtest_main.cc)

	foreach(VARIANT A W)
		set(TGT ${MODULE}${VARIANT})
		add_executable(${TGT} ${SOURCES})
		target_include_directories(${TGT} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../Inc)
		if(MSVC)
			target_link_libraries(${TGT} PRIVATE cppcore)
		else()
			target_compile_options(${TGT} PRIVATE -O3 -fPIC)
			target_link_libraries(${TGT} PRIVATE cppcore dl pthread)
		endif()
		add_test(NAME ${TGT} COMMAND ${TGT} WORKING_DIRECTORY ${TEST_WORKING_DIRECTORY})
	endforeach()

	target_compile_definitions(${MODULE}W PRIVATE UNICODE _UNICODE)
endfunction()

##############################################################
## Test executables
##############################################################
add_cppcore_test(StringTest)
#add_cppcore_test(EncoderTest)
add_cppcore_test(SystemTest)
add_cppcore_test(CommonTest)
add_cppcore_test(FormatterTest)
add_cppcore_test(ServerTest)

# Support binaries used by the runtime-loader / spawn-process tests above.
# They diverge from the gtest pattern (single target, no A/W split), so they
# stay as their own subdirectories.
add_subdirectory(DummyProcess)
add_subdirectory(DummyDynamicLibrary)
