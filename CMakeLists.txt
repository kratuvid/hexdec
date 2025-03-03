cmake_minimum_required(VERSION 3.31.6)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()
set(CMAKE_ASM_COMPILER as)

include(CMakePrintHelpers)

project(hexdec LANGUAGES ASM)

# set(common_options -fPIE)
# add_compile_options(${common_options} -Wa,--fatal-warnings,-msyntax=intel,-mnaked-reg)
# add_link_options(${common_options} -nostartfiles -nostdlib)

set(common_options)
add_compile_options(${common_options} -msyntax=intel -mnaked-reg --fatal-warnings)
add_link_options(${common_options} --dynamic-linker /lib64/ld-linux-x86-64.so.2 -nostdlib -pie -z noexecstack)

include_directories(.)

add_executable(hexdec)
target_sources(hexdec PRIVATE hexdec.S syscalls.S utils.S)
