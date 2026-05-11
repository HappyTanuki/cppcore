cmake_minimum_required(VERSION 3.10)

message(STATUS "CMAKE_ARCHIVE_OUTPUT_DIRECTORY: " ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
message(STATUS "CMAKE_LIBRARY_OUTPUT_DIRECTORY: " ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
message(STATUS "CMAKE_RUNTIME_OUTPUT_DIRECTORY: " ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

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

foreach(SOURCE IN LISTS SOURCES)
	message(STATUS "SOURCE - " ${SOURCE})
endforeach(SOURCE)

##############################################################
## Build setting
##############################################################
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../Inc)
add_library(${TARGET_NAME}A OBJECT ${SOURCES})
add_library(${TARGET_NAME}W OBJECT ${SOURCES})
if(NOT MSVC)
	target_compile_options(${TARGET_NAME}A PUBLIC -std=gnu++14 -O3 -fPIC -Wno-narrowing)
	target_compile_options(${TARGET_NAME}W PUBLIC -std=gnu++14 -O3 -fPIC -Wno-narrowing)
endif()
target_compile_definitions(${TARGET_NAME}W PUBLIC -DUNICODE PUBLIC -D_UNICODE)
add_library(${TARGET_NAME} STATIC $<TARGET_OBJECTS:cppcoreA> $<TARGET_OBJECTS:cppcoreW>)
