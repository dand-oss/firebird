################################################################################
#
# CMakeLists.txt - Firebird2 CMake build system
#
# Builds: libfbclient2.so, libfbembed2.so, libib_util.so, ib_udf.so, fbudf.so
#
################################################################################

################################################################################
# CMAKE SETTINGS
################################################################################

cmake_minimum_required(VERSION 3.16)

# Prevent in-source builds
if (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds not allowed. Please use a separate build directory.")
endif()

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/builds/cmake)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

################################################################################
# PROJECT SETTINGS
################################################################################

project(firebird2 C CXX)

###############
# ASI default settings
list(APPEND CMAKE_MODULE_PATH "$ENV{ASV_CMAKE}")
include(asv_cmake_defaults)
asv_cmake_defaults( )
###############

# Debug-specific defines (matches autotools DEV_BUILD)
add_compile_definitions($<$<CONFIG:Debug>:DEV_BUILD>)

# Build options
option(FIREBIRD_BUILD_FBCLIENT "Build remote client library (libfbclient2)" ON)
option(FIREBIRD_BUILD_FBEMBED "Build embedded library (libfbembed2)" ON)
option(FIREBIRD_BUILD_ICU "Build bundled ICU libraries" ON)  # Always ON - bundled ICU 63.1

# Version
set(FIREBIRD_VERSION_MAJOR 2)
set(FIREBIRD_VERSION_MINOR 5)
set(FIREBIRD_VERSION_PATCH 9)
set(FIREBIRD_VERSION "${FIREBIRD_VERSION_MAJOR}.${FIREBIRD_VERSION_MINOR}.${FIREBIRD_VERSION_PATCH}")

# C++ standard (firebird2 uses older C++)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)

################################################################################
# OUTPUT DIRECTORIES
################################################################################

set(output_dir ${CMAKE_BINARY_DIR}/${PROJECT_NAME})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${output_dir}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${output_dir}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${output_dir}/lib)

################################################################################
# CONFIGURE - Platform detection and feature checks
################################################################################

include(Configure)

# Firebird configuration variables
set(FB_PREFIX "${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}")
set(FB_IPC_NAME "FirebirdIPI")
set(FB_LOGFILENAME "firebird.log")
set(FB_SERVICE_NAME "gds_db")
set(FB_SERVICE_PORT 3050)
set(FB_BINDIR "${FB_PREFIX}/bin")
set(FB_SBINDIR "${FB_PREFIX}/bin")
set(FB_CONFDIR "${FB_PREFIX}")
set(FB_LIBDIR "${FB_PREFIX}/lib")
set(FB_INCDIR "${FB_PREFIX}/include")
set(FB_DOCDIR "${FB_PREFIX}/doc")
set(FB_UDFDIR "${FB_PREFIX}/UDF")
set(FB_SAMPLEDIR "${FB_PREFIX}/examples")
set(FB_SAMPLEDBDIR "${FB_PREFIX}/examples/empbuild")
set(FB_HELPDIR "${FB_PREFIX}/help")
set(FB_INTLDIR "${FB_PREFIX}/intl")
set(FB_MISCDIR "${FB_PREFIX}/misc")
set(FB_SECDBDIR "${FB_PREFIX}")
set(FB_MSGDIR "${FB_PREFIX}")
set(FB_LOGDIR "${FB_PREFIX}")
set(FB_GUARDDIR "${FB_PREFIX}")
set(FB_PLUGDIR "${FB_PREFIX}/plugins")

# Generate autoconfig.h
set(AUTOCONFIG_SRC ${CMAKE_SOURCE_DIR}/src/include/gen/autoconfig.h.in)
set(AUTOCONFIG ${CMAKE_BINARY_DIR}/src/include/gen/autoconfig.h)
configure_file(${AUTOCONFIG_SRC} ${AUTOCONFIG} @ONLY)

################################################################################
# COMPILER AND LINKER SETTINGS
################################################################################

if (WIN32)
    set(OS_DIR win32)
    add_definitions(-DWIN_NT -DSUPERCLIENT)
elseif (APPLE)
    set(OS_DIR darwin)
    add_definitions(-DDARWIN -DSUPERCLIENT)
elseif (UNIX)
    set(OS_DIR posix)
    add_definitions(-DLINUX -DSUPERCLIENT)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
endif()

# Platform libraries
if (WIN32)
    set(LIB_Ws2_32 Ws2_32)
    set(LIB_mpr mpr)
else()
    set(LIB_dl dl)
    set(LIB_pthread pthread)
    set(LIB_m m)
endif()

################################################################################
# PRE-BUILD: SYMBOL VERSIONING
################################################################################

if (UNIX)
    # Copy .vers files to build directory for symbol versioning
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/builds/posix)
    file(GLOB vers_files "${CMAKE_SOURCE_DIR}/builds/posix/*.vers")
    foreach(f ${vers_files})
        get_filename_component(name ${f} NAME)
        configure_file(${f} ${CMAKE_BINARY_DIR}/builds/posix/${name} COPYONLY)
    endforeach()
endif()

################################################################################
# BUILD FUNCTIONS
################################################################################

include(BuildFunctions)

################################################################################
# INCLUDE DIRECTORIES
################################################################################

include_directories(
    ${CMAKE_BINARY_DIR}/src/include/gen
    ${CMAKE_BINARY_DIR}/src/include
    ${CMAKE_SOURCE_DIR}/src/include
    ${CMAKE_SOURCE_DIR}/src/include/gen
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/src/vulcan
)

################################################################################
# EXTERNAL LIBRARIES
################################################################################

# Bundled ICU
if (FIREBIRD_BUILD_ICU)
    add_subdirectory(extern/icu)
endif()

################################################################################
# SOURCE BUILD
################################################################################

add_subdirectory(src)

################################################################################
# INSTALL
################################################################################

# Install headers
install(DIRECTORY ${CMAKE_SOURCE_DIR}/src/include/
    DESTINATION include/firebird
    FILES_MATCHING PATTERN "*.h"
    PATTERN "gen" EXCLUDE
)

# Install generated headers
install(FILES ${AUTOCONFIG}
    DESTINATION include/firebird/gen
)

################################################################################
# SUMMARY
################################################################################

message(STATUS "")
message(STATUS "Firebird2 ${FIREBIRD_VERSION} CMake Configuration Summary")
message(STATUS "================================================")
message(STATUS "  Build type:      ${CMAKE_BUILD_TYPE}")
message(STATUS "  Install prefix:  ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  Build fbclient:  ${FIREBIRD_BUILD_FBCLIENT}")
message(STATUS "  Build fbembed:   ${FIREBIRD_BUILD_FBEMBED}")
message(STATUS "  Build ICU:       ${FIREBIRD_BUILD_ICU}")
message(STATUS "")
