cmake_minimum_required(VERSION 3.21)
set(TARGET_NAME DummyProcess)

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS *.cpp)

add_executable(${TARGET_NAME} ${SOURCES})
if(MSVC)
	target_link_libraries(${TARGET_NAME} PRIVATE cppcore)
elseif(APPLE)
	target_link_libraries(${TARGET_NAME} PRIVATE cppcore iconv)
else()
	target_link_libraries(${TARGET_NAME} PRIVATE cppcore pthread dl rt)
endif()

# CreateProcessTest_DirectoryTest builds the path as
# `GetCurrentDirectory() + "/DummyProcess"`, so the exe must exist directly
# under TEST_WORKING_DIRECTORY (not just in the per-config output folder).
if(TEST_WORKING_DIRECTORY)
	add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E make_directory ${TEST_WORKING_DIRECTORY}
		COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${TARGET_NAME}> ${TEST_WORKING_DIRECTORY})
endif()
