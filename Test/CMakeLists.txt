cmake_minimum_required(VERSION 3.10)

# Test sources reference data via the relative path ../../Build/Test/<dir>/file,
# so tests must run with WORKING_DIRECTORY set to <repo>/Build/Test/. This is
# exposed via TEST_WORKING_DIRECTORY so each test target can reuse it.
set(TEST_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../Build/Test CACHE INTERNAL "")

add_subdirectory(StringTest)
#add_subdirectory(EncoderTest)
add_subdirectory(SystemTest)
add_subdirectory(CommonTest)
add_subdirectory(FormatterTest)
add_subdirectory(ServerTest)
add_subdirectory(DummyProcess)
add_subdirectory(DummyDynamicLibrary)
