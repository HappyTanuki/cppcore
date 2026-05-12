cmake_minimum_required(VERSION 3.10)
set(TARGET_NAME CommonTest)

message(STATUS "CMAKE_ARCHIVE_OUTPUT_DIRECTORY: " ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
message(STATUS "CMAKE_LIBRARY_OUTPUT_DIRECTORY: " ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
message(STATUS "CMAKE_RUNTIME_OUTPUT_DIRECTORY: " ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

##############################################################
## Utility functions
##############################################################
function(exclude_from_list SOURCES_LIST EXPRESSION)
	file(GLOB EXCLUDE ${EXPRESSION})
	if(EXCLUDE)
		list(REMOVE_ITEM ${SOURCES_LIST} ${EXCLUDE})
	endif()
	set(${SOURCES_LIST} ${${SOURCES_LIST}} PARENT_SCOPE)
endfunction(exclude_from_list)


##############################################################
## Source Filtering
##############################################################
# Glob all source files and filt-out later
file(GLOB_RECURSE SOURCES *.cpp *.c)

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

list(APPEND SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/../../Inc/gtest-all.cc ${CMAKE_CURRENT_SOURCE_DIR}/../../Inc/gtest_main.cc)

foreach(SOURCE IN LISTS SOURCES)
	message(STATUS "SOURCE - " ${SOURCE})
endforeach(SOURCE)

##############################################################
## Build setting
##############################################################
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../Inc)

add_executable(${TARGET_NAME}A ${SOURCES})
add_executable(${TARGET_NAME}W ${SOURCES})
target_compile_definitions(${TARGET_NAME}W PUBLIC -DUNICODE PUBLIC -D_UNICODE)

if(MSVC)
	target_link_libraries(${TARGET_NAME}A cppcore)
	target_link_libraries(${TARGET_NAME}W cppcore)
else()
	target_compile_options(${TARGET_NAME}A PUBLIC -O3 -fPIC)
	target_compile_options(${TARGET_NAME}W PUBLIC -O3 -fPIC)
	target_link_libraries(${TARGET_NAME}A cppcore dl pthread)
	target_link_libraries(${TARGET_NAME}W cppcore dl pthread)
endif()

add_test(NAME ${TARGET_NAME}A COMMAND ${TARGET_NAME}A WORKING_DIRECTORY ${TEST_WORKING_DIRECTORY})
add_test(NAME ${TARGET_NAME}W COMMAND ${TARGET_NAME}W WORKING_DIRECTORY ${TEST_WORKING_DIRECTORY})
