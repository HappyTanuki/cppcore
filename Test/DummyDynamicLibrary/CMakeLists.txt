cmake_minimum_required(VERSION 3.21)
set(TARGET_NAME DummyDynamicLibrary)

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS *.cpp)
if(MSVC)
	list(FILTER SOURCES EXCLUDE REGEX "_Linux\\.cpp$|_Linux_Mac\\.cpp$|_Mac\\.cpp$")
elseif(APPLE)
	list(FILTER SOURCES EXCLUDE REGEX "_Win\\.cpp$|_Linux\\.cpp$")
else()
	list(FILTER SOURCES EXCLUDE REGEX "_Win\\.cpp$|_Mac\\.cpp$")
endif()

add_library(${TARGET_NAME} SHARED ${SOURCES})
if(MSVC)
	target_link_libraries(${TARGET_NAME} PRIVATE cppcore)
elseif(APPLE)
	target_compile_options(${TARGET_NAME} PRIVATE -fPIC)
	target_link_libraries(${TARGET_NAME} PRIVATE cppcore iconv)
else()
	target_compile_options(${TARGET_NAME} PRIVATE -fPIC)
	target_link_libraries(${TARGET_NAME} PRIVATE cppcore pthread dl rt)
endif()

# Tests load this library via LoadLibrary("./DummyDynamicLibrary.dll") with cwd
# set to TEST_WORKING_DIRECTORY, so mirror the build artifact there.
if(TEST_WORKING_DIRECTORY)
	add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E make_directory ${TEST_WORKING_DIRECTORY}
		COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${TARGET_NAME}> ${TEST_WORKING_DIRECTORY})
endif()
