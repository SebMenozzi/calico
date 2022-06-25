cmake_minimum_required(VERSION 3.20)

project(calico)

enable_language(Swift)

# Generate xcode schema files
set(CMAKE_XCODE_GENERATE_SCHEME TRUE)

add_subdirectory(App)