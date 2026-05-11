cmake_minimum_required(VERSION 3.10)
set(TARGET_NAME DummyDynamicLibrary)

message(STATUS "CMAKE_ARCHIVE_OUTPUT_DIRECTORY: " ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
message(STATUS "CMAKE_LIBRARY_OUTPUT_DIRECTORY: " ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
message(STATUS "CMAKE_RUNTIME_OUTPUT_DIRECTORY: " ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
message(STATUS "CMAKE_PROJECT_NAME: " ${CMAKE_PROJECT_NAME})
message(STATUS "TARGET_NAME: " ${TARGET_NAME})

##############################################################
## Utility functions
##############################################################
function(exclude_from_list SOURCES_LIST EXPRESSION)
	file(GLOB_RECURSE EXCLUDE ${EXPRESSION})
	if(EXCLUDE)
		list(REMOVE_ITEM ${SOURCES_LIST} ${EXCLUDE})
	endif()
	set(${SOURCES_LIST} ${${SOURCES_LIST}} PARENT_SCOPE)
endfunction(exclude_from_list)


##############################################################
## Sources Filtering
##############################################################
file(GLOB_RECURSE SOURCES *.cpp)

if(MSVC)
	exclude_from_list(SOURCES *_Linux.cpp)
	exclude_from_list(SOURCES *_Linux_Mac.cpp)
	exclude_from_list(SOURCES *_Mac.cpp)
elseif(APPLE)
	exclude_from_list(SOURCES *_Win.cpp)
	exclude_from_list(SOURCES *_Linux.cpp)
else()
	exclude_from_list(SOURCES *_Win.cpp)
	exclude_from_list(SOURCES *_Mac.cpp)
endif()
message(STATUS "SOURCES: " ${SOURCES})


##############################################################
## Build setting
##############################################################
add_library(${TARGET_NAME} SHARED ${SOURCES})
if(MSVC)
	target_link_libraries(${TARGET_NAME} cppcore)
elseif(APPLE)
	target_compile_options(${TARGET_NAME} PUBLIC -fPIC)
	target_link_libraries(${TARGET_NAME} cppcore iconv)
else()
	target_compile_options(${TARGET_NAME} PUBLIC -fPIC)
	target_link_libraries(${TARGET_NAME} cppcore pthread dl rt)
endif()

# Tests load this library via LoadLibrary("./DummyDynamicLibrary.dll") with cwd
# set to TEST_WORKING_DIRECTORY, so mirror the build artifact there.
if(TEST_WORKING_DIRECTORY)
	add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E make_directory ${TEST_WORKING_DIRECTORY}
		COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${TARGET_NAME}> ${TEST_WORKING_DIRECTORY})
endif()
