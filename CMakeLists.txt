cmake_minimum_required(VERSION 3.10)

if(POLICY CMP0091)
    cmake_policy(SET CMP0091 NEW)
endif()

project(cppcore)

add_subdirectory(Src)
#add_subdirectory(Test)