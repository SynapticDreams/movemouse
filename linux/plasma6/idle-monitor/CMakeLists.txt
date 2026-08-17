cmake_minimum_required(VERSION 3.20)
project(movemouse-idle-monitor LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(ECM 6.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(Qt6 REQUIRED COMPONENTS Core Gui)
find_package(KF6 REQUIRED COMPONENTS IdleTime)

add_executable(movemouse-idle-monitor main.cpp)
target_link_libraries(movemouse-idle-monitor PRIVATE Qt6::Core Qt6::Gui KF6::IdleTime)
