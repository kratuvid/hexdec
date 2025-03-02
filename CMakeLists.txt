cmake_minimum_required(VERSION 3.31.6)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()
set(CMAKE_ASM_COMPILER gcc)

include(CMakePrintHelpers)

project(hexdec LANGUAGES ASM)

set(common_options -fPIE)
add_compile_options(${common_options} -Wa,-msyntax=intel,-mnaked-reg)
add_link_options(${common_options} -nostartfiles -nostdlib)
include_directories(.)

add_executable(hexdec)
target_sources(hexdec PRIVATE hexdec.S syscalls.S)
