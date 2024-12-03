cmake_minimum_required(VERSION 3.27)
project(untitled)

set(CMAKE_CXX_STANDARD 17)

add_executable(
        untitled
        main.cpp
        get_time.o
        get_name.o
        get_state.o
        get_btime.o
        get_cmdline.o
        get_info.o
        suspend_proc.o
        resume_proc.o
        complete_proc.o
)
