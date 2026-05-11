cmake_minimum_required(VERSION 3.10)
set(TARGET_NAME DummyProcess)

message(STATUS "CMAKE_ARCHIVE_OUTPUT_DIRECTORY: " ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
message(STATUS "CMAKE_LIBRARY_OUTPUT_DIRECTORY: " ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
message(STATUS "CMAKE_RUNTIME_OUTPUT_DIRECTORY: " ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
message(STATUS "CMAKE_PROJECT_NAME: " ${CMAKE_PROJECT_NAME})
message(STATUS "TARGET_NAME: " ${TARGET_NAME})

##############################################################
## Sources Filtering
##############################################################
file(GLOB_RECURSE SOURCES *.cpp)
message(STATUS "SOURCES: " ${SOURCES})


##############################################################
## Build setting
##############################################################
add_executable(${TARGET_NAME} ${SOURCES})
if(MSVC)
	target_link_libraries(${TARGET_NAME} cppcore)
elseif(APPLE)
	target_link_libraries(${TARGET_NAME} cppcore iconv)
else()
	target_link_libraries(${TARGET_NAME} cppcore pthread dl rt)
endif()

# CreateProcessTest_DirectoryTest builds the path as
# `GetCurrentDirectory() + "/DummyProcess"`, so the exe must exist directly
# under TEST_WORKING_DIRECTORY (not just in the per-config output folder).
if(TEST_WORKING_DIRECTORY)
	add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E make_directory ${TEST_WORKING_DIRECTORY}
		COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${TARGET_NAME}> ${TEST_WORKING_DIRECTORY})
endif()
