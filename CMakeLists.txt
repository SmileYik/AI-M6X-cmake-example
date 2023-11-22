# *************************************************************#
# 工程源文件配置
# Engineering Source File Configuration
# *************************************************************#

# ############################ 保持默认 #######################
# #########################  Keep default ####################
cmake_minimum_required(VERSION 3.15)

include(proj.conf)
include(proj.cmake)

find_package(bouffalo_sdk REQUIRED HINTS $ENV{BL_SDK_BASE})
# ############################  End  #########################
# #############################################################

# 搜集所有的C文件( Collect source files)
file(GLOB_RECURSE sources "${CMAKE_CURRENT_SOURCE_DIR}/components/*.c")

# 添加头文件的引用路径（Add .h include directories）
sdk_add_include_directories(main config components/wifi)

# 把C文件添加到工程里（Add .c file to the project）
target_sources(app PRIVATE ${sources})

# 设置main.c 的文件（Set the document source for main. c）
# 注意：不能和file(GLOB_RECURSE sources "${CMAKE_CURRENT_SOURCE_DIR}/components/*.c") 冲突（Note: Cannot conflict with “file(GLOB_RECURSE sources "${CMAKE_CURRENT_SOURCE_DIR}/components/*.c")”）
sdk_set_main_file(main/main.c)

# 设置工程名称，这个配置决定了编译出来的文件名。(Set the project name, which determines the compiled file name)
get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${PROJECT_NAME})


# ############################ 保持默认 #######################
# #########################  Keep default ####################
# 复制固件为 firmware.bin
add_custom_target(flash
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${build_dir}/${proj_name}.bin
        ${build_dir}/firmware.bin
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_SOURCE_DIR}/flash_prog_cfg.ini
        ${build_dir}/flash_prog_cfg.ini
    COMMENT "[FLASH] Finished prepare, starting flash to port ${CONFIG_COMX}"
    USES_TERMINAL
)
# 关联依赖，使得 flash 指令能够获得最新的编译产物
add_dependencies(combine ${proj_name}.elf)
add_dependencies(flash combine)

# 设定烧录参数
set(BL_FLASH_PROC ${BL_SDK_BASE}/tools/bflb_tools/bouffalo_flash_cube/BLFlashCommand${TOOL_SUFFIX})
set(BL_FLASH_PROC_CONFIG --chipname=${CHIP})
list(APPEND BL_FLASH_PROC_CONFIG --interface=uart)
list(APPEND BL_FLASH_PROC_CONFIG --baudrate=${BAUDRATE})
list(APPEND BL_FLASH_PROC_CONFIG --port=${CONFIG_COMX})
list(APPEND BL_FLASH_PROC_CONFIG --cpu_id=${CPU_ID})
list(APPEND BL_FLASH_PROC_CONFIG --config=${build_dir}/flash_prog_cfg.ini)
# 附加到flash target之后
add_custom_command(
    TARGET flash
    POST_BUILD
    WORKING_DIRECTORY ${build_dir}
    COMMAND ${BL_FLASH_PROC} ${BL_FLASH_PROC_CONFIG}
    USES_TERMINAL
)
# ############################  End  #########################
# #############################################################
