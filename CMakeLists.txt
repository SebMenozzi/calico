cmake_minimum_required(VERSION 3.20)

project(calico)

enable_language(Swift)

# Generate xcode schema files
set(CMAKE_XCODE_GENERATE_SCHEME TRUE)
set(CMAKE_Swift_FLAGS "${CMAKE_Swift_FLAGS} -import-objc-header ${PROJECT_SOURCE_DIR}/Shaders/Shader-Header.h" )

# Set path to find cmake files
set(CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/"
    ${CMAKE_MODULE_PATH}
)
# Include cmake/calico.cmake
include(calico)

add_subdirectory(App)
#add_subdirectory(Renderer)
#add_subdirectory(Framework)