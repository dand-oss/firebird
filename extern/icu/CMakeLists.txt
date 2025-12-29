################################################################################
#
# CMakeLists.txt - ICU configuration for Firebird2
#
# Uses system ICU on Linux/Unix, bundled ICU on Windows
#
################################################################################

if (UNIX)
    ############################################################################
    # SYSTEM ICU (Linux/Unix)
    ############################################################################

    # Find system ICU headers
    find_path(ICU_INCLUDE_DIR unicode/ucnv.h
        PATHS
            /usr/include
            /usr/local/include
            /usr/include/x86_64-linux-gnu
    )

    if ("${ICU_INCLUDE_DIR}" STREQUAL "ICU_INCLUDE_DIR-NOTFOUND")
        message(FATAL_ERROR "ICU headers not found! Install libicu-dev")
    endif()

    # Find system ICU libraries
    find_library(ICU_UC_LIB icuuc REQUIRED)
    find_library(ICU_DATA_LIB icudata REQUIRED)
    find_library(ICU_I18N_LIB icui18n REQUIRED)

    message(STATUS "Using system ICU:")
    message(STATUS "  Include: ${ICU_INCLUDE_DIR}")
    message(STATUS "  Libraries: ${ICU_UC_LIB} ${ICU_DATA_LIB} ${ICU_I18N_LIB}")

    # Create interface libraries that link to system ICU
    # Disable C++ API features (use C++17/20 features not available in C++11)
    add_library(icu_uc INTERFACE)
    target_include_directories(icu_uc INTERFACE ${ICU_INCLUDE_DIR})
    target_compile_definitions(icu_uc INTERFACE
        U_SHOW_CPLUSPLUS_API=0
        U_SHOW_CPLUSPLUS_HEADER_API=0
    )
    target_link_libraries(icu_uc INTERFACE ${ICU_UC_LIB})

    add_library(icu_i18n INTERFACE)
    target_include_directories(icu_i18n INTERFACE ${ICU_INCLUDE_DIR})
    target_compile_definitions(icu_i18n INTERFACE
        U_SHOW_CPLUSPLUS_API=0
        U_SHOW_CPLUSPLUS_HEADER_API=0
    )
    target_link_libraries(icu_i18n INTERFACE ${ICU_I18N_LIB})

    add_library(icu_data INTERFACE)
    target_link_libraries(icu_data INTERFACE ${ICU_DATA_LIB})

    # Export include directories
    set(ICU_INCLUDE_DIRS ${ICU_INCLUDE_DIR} PARENT_SCOPE)
    set(ICU_LIBRARIES ${ICU_UC_LIB} ${ICU_I18N_LIB} ${ICU_DATA_LIB} PARENT_SCOPE)

else()
    ############################################################################
    # BUNDLED ICU 3.0 (Windows) - build from source
    ############################################################################

    set(ICU_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/source)

    # Collect source files for each ICU component
    file(GLOB ICU_COMMON_SOURCES
        ${ICU_SOURCE_DIR}/common/*.c
        ${ICU_SOURCE_DIR}/common/*.cpp
    )

    file(GLOB ICU_I18N_SOURCES
        ${ICU_SOURCE_DIR}/i18n/*.c
        ${ICU_SOURCE_DIR}/i18n/*.cpp
    )

    set(ICU_STUBDATA_SOURCES ${ICU_SOURCE_DIR}/stubdata/stubdata.c)

    # Common compile definitions for all ICU components
    set(ICU_COMMON_DEFINITIONS
        _CRT_SECURE_NO_WARNINGS
        U_SHOW_CPLUSPLUS_API=0
        U_STATIC_IMPLEMENTATION
    )

    # ICU stubdata (data) library
    add_library(icu_data STATIC ${ICU_STUBDATA_SOURCES})
    target_include_directories(icu_data
        PUBLIC ${ICU_SOURCE_DIR}/common
    )
    target_compile_definitions(icu_data PRIVATE
        ${ICU_COMMON_DEFINITIONS}
        STUBDATA_EXPORTS
    )

    # ICU common (uc) library
    add_library(icu_uc STATIC ${ICU_COMMON_SOURCES})
    target_include_directories(icu_uc
        PUBLIC ${ICU_SOURCE_DIR}/common
        PRIVATE ${ICU_SOURCE_DIR}/i18n
    )
    target_compile_definitions(icu_uc
        PUBLIC
            U_SHOW_CPLUSPLUS_API=0
            U_STATIC_IMPLEMENTATION
        PRIVATE
            ${ICU_COMMON_DEFINITIONS}
            U_COMMON_IMPLEMENTATION
    )
    target_link_libraries(icu_uc PUBLIC icu_data)

    # ICU i18n library
    add_library(icu_i18n STATIC ${ICU_I18N_SOURCES})
    target_include_directories(icu_i18n
        PUBLIC ${ICU_SOURCE_DIR}/common
        PUBLIC ${ICU_SOURCE_DIR}/i18n  # For unicode/utrans.h etc.
    )
    target_compile_definitions(icu_i18n
        PUBLIC
            U_SHOW_CPLUSPLUS_API=0
            U_STATIC_IMPLEMENTATION
        PRIVATE
            ${ICU_COMMON_DEFINITIONS}
            U_I18N_IMPLEMENTATION
    )
    target_link_libraries(icu_i18n PUBLIC icu_uc)

    # Suppress MSVC warnings for ICU code (third-party, not our code)
    if(MSVC)
        target_compile_options(icu_data PRIVATE /W0)
        target_compile_options(icu_uc PRIVATE /W0)
        target_compile_options(icu_i18n PRIVATE /W0)
    endif()

    # Export include directories
    set(ICU_INCLUDE_DIRS ${ICU_SOURCE_DIR}/common PARENT_SCOPE)
    set(ICU_LIBRARIES icu_i18n icu_uc icu_data PARENT_SCOPE)

    message(STATUS "Building bundled ICU 3.0 from source:")
    message(STATUS "  Include: ${ICU_SOURCE_DIR}/common")

endif()
