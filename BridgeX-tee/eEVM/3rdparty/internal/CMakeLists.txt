add_library(intx INTERFACE)
add_library(intx::intx ALIAS intx)

target_sources(intx INTERFACE ${CMAKE_CURRENT_LIST_DIR}/intx/include/intx/intx.hpp)

target_include_directories(intx INTERFACE ${CMAKE_CURRENT_LIST_DIR}/intx/include/)