# 导出 COMPILE_COMMANDS.JSON
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# SDK 仓库
set(GIT_AI_M6X_SDK          "https://gitee.com/Ai-Thinker-Open/aithinker_Ai-M6X_SDK")
# UNIX 工具链仓库
set(GIT_TOOLCHAIN_UNIX      "https://gitee.com/bouffalolab/toolchain_gcc_t-head_linux.git")
# WIN 工具链仓库
set(GIT_TOOLCHAIN_WIN       "https://gitee.com/bouffalolab/toolchain_gcc_t-head_windows.git")
# SDK 位置
set(ENV{BL_SDK_BASE}        "$ENV{AI_M6X_SDK}")

# 自动获取 SDK 至项目目录下
message(STATUS "Checking AI-M6X-SDK...")
if("$ENV{BL_SDK_BASE}" STREQUAL "")
    set(ENV{BL_SDK_BASE} ${DEFAULT_SDK_DIR})
    if(NOT EXISTS $ENV{BL_SDK_BASE})
        MESSAGE(WARNING
                "Can't find AI-M6X-SDK, clone to '$ENV{BL_SDK_BASE}' from url '${GIT_AI_M6X_SDK}'")
        execute_process(
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            COMMAND git clone --recursive ${GIT_AI_M6X_SDK} $ENV{BL_SDK_BASE}
            COMMAND_ECHO STDOUT
        )
    endif()
else()
    message(STATUS "Find AI-M6X-SDK: '$ENV{BL_SDK_BASE}'")
endif()

# 配置 SDK 对应的工具链
message(STATUS "Checking toolchain...")
if(MINGW OR CYGWIN OR WIN32)
    # 格式化 Windows 下 SDK 路径
    string(REPLACE "\\" "/" BL_SDK_BASE_REPLACED $ENV{BL_SDK_BASE})
    set(ENV{BL_SDK_BASE} ${BL_SDK_BASE_REPLACED})

    set(ENV{BL_SDK_TOOLCHAIN} "$ENV{BL_SDK_BASE}/toolchain_gcc_t-head_windows")
    set(GIT_TOOLCHAIN ${GIT_TOOLCHAIN_WIN})
    set(GIT_TOOLCHAIN_DIR "toolchain_gcc_t-head_windows")
    list(APPEND CMAKE_PROGRAM_PATH "$ENV{BL_SDK_BASE}/tools/make" "$ENV{BL_SDK_BASE}/tools/ninja")

    # 生成烧录脚本
    file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/flash.bat"
                "SET PATH=$ENV{BL_SDK_BASE}/tools/ninja;%PATH%\nninja -j 2 -C build flash\npause")
    file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/flash_no_pause.bat"
                "SET PATH=$ENV{BL_SDK_BASE}/tools/ninja;%PATH%\nninja -j 2 -C build flash")
else()
    set(ENV{BL_SDK_TOOLCHAIN} "$ENV{BL_SDK_BASE}/toolchain")
    set(GIT_TOOLCHAIN ${GIT_TOOLCHAIN_UNIX})
    set(GIT_TOOLCHAIN_DIR "toolchain")
endif()

if(NOT EXISTS $ENV{BL_SDK_TOOLCHAIN} OR NOT EXISTS "$ENV{BL_SDK_TOOLCHAIN}/bin")
    MESSAGE(WARNING
            "Can't find toolchain: $ENV{BL_SDK_TOOLCHAIN}, clone from url '${GIT_TOOLCHAIN}'")
    execute_process(
        WORKING_DIRECTORY $ENV{BL_SDK_BASE}
        COMMAND git clone ${GIT_TOOLCHAIN} ${GIT_TOOLCHAIN_DIR}
        COMMAND_ECHO STDOUT
    )
endif()

MESSAGE(STATUS "Find toolchain: $ENV{BL_SDK_TOOLCHAIN}")
set(CROSS_COMPILE "$ENV{BL_SDK_TOOLCHAIN}/bin/riscv64-unknown-elf-")
