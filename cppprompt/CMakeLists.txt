project("CPP Prompt")
cmake_minimum_required(VERSION 2.8)
set(CPP_PROMPT_EXEC "cppprompt")
add_executable(${CPP_PROMPT_EXEC} cppprompt.cpp)
set_target_properties(${CPP_PROMPT_EXEC} PROPERTIES COMPILE_FLAGS "-std=c++11")

