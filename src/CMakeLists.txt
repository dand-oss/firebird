################################################################################
#
# src/CMakeLists.txt - Firebird2 library targets
#
# Builds: libfbclient2, libfbembed2, libib_util, ib_udf, fbudf
#
################################################################################

################################################################################
# SOURCE FILE DEFINITIONS
# Based on builds/posix/make.shared.variables
################################################################################

#---------------------------------------
# JRD CLIENT (jrd/)
#---------------------------------------
set(JRD_CLIENT_SRC
    jrd/alt.cpp
    jrd/db_alias.cpp
    jrd/dsc.cpp
    jrd/enc.cpp
    jrd/gds.cpp
    jrd/isc.cpp
    jrd/isc_file.cpp
    jrd/perf.cpp
    jrd/sdl.cpp
    jrd/status.cpp
    jrd/ThreadData.cpp
    jrd/ThreadStart.cpp
    jrd/utl.cpp
    jrd/why.cpp
    common/cvt.cpp
)

#---------------------------------------
# REMOTE CLIENT (remote/)
#---------------------------------------
set(REMOTE_CLIENT_SRC
    remote/interface.cpp
    remote/inet.cpp
    remote/merge.cpp
    remote/parser.cpp
    remote/protocol.cpp
    remote/remote.cpp
    remote/xdr.cpp
)

# Platform-specific remote files
if (WIN32)
    list(APPEND REMOTE_CLIENT_SRC
        remote/xnet.cpp
        remote/os/win32/wnet.cpp
    )
endif()

#---------------------------------------
# AUTH (Windows trusted authentication)
#---------------------------------------
if (WIN32)
    set(AUTH_SRC
        auth/trusted/AuthSspi.cpp
    )
endif()

#---------------------------------------
# DSQL CLIENT (dsql/)
# NOTE: array.cpp and blob.cpp are pre-generated from .epp files
#---------------------------------------
set(DSQL_CLIENT_SRC
    dsql/array.cpp
    dsql/blob.cpp
    dsql/preparse.cpp
    dsql/user_dsql.cpp
    dsql/utld.cpp
    dsql/keywords.cpp
)

#---------------------------------------
# COMMON CLASSES (common/classes/)
#---------------------------------------
set(FBCLASSES_CLIENT_SRC
    common/classes/alloc.cpp
    common/classes/locks.cpp
    common/classes/semaphore.cpp
    common/classes/fb_string.cpp
    common/classes/timestamp.cpp
    common/classes/PublicHandle.cpp
    common/classes/TempFile.cpp
)

set(FBCLASSES_MSG_SRC
    common/classes/SafeArg.cpp
    common/classes/MsgPrint.cpp
    common/classes/BaseStream.cpp
)

set(CLUMPLETS_SRC
    common/classes/ClumpletReader.cpp
    common/classes/ClumpletWriter.cpp
)

#---------------------------------------
# COMMON CONFIG (common/config/)
#---------------------------------------
set(FBCONFIG_SRC
    common/config/config.cpp
    common/config/config_file.cpp
    common/config/dir_list.cpp
)

#---------------------------------------
# CONFIG (config/)
#---------------------------------------
set(CONFIG_SRC
    config/AdminException.cpp
    config/Args.cpp
    config/ArgsException.cpp
    config/ConfObj.cpp
    config/ConfObject.cpp
    config/ConfigFile.cpp
    config/Configuration.cpp
    config/Element.cpp
    config/FileName.cpp
    config/InputFile.cpp
    config/InputStream.cpp
    config/Lex.cpp
    config/ScanDir.cpp
    config/Stream.cpp
    config/StreamSegment.cpp
)

#---------------------------------------
# VULCAN (vulcan/)
#---------------------------------------
set(VULCAN_SRC
    vulcan/PathName.cpp
    vulcan/RefObject.cpp
)

#---------------------------------------
# COMMON (common/)
#---------------------------------------
set(FBCOMMON_SRC
    common/fb_exception.cpp
    common/thd.cpp
    common/utils.cpp
    common/classes/MetaName.cpp
    common/StatusHolder.cpp
    common/classes/init.cpp
    common/StatusArg.cpp
)

if (UNIX AND NOT APPLE)
    list(APPEND FBCOMMON_SRC jrd/os/posix/fbsyslog.cpp)
elseif (WIN32)
    list(APPEND FBCOMMON_SRC jrd/os/win32/fbsyslog.cpp)
endif()

#---------------------------------------
# GPRE CLIENT (gpre/)
#---------------------------------------
set(GPRELIB_CLIENT_SRC
    gpre/pretty.cpp
)

#---------------------------------------
# SECURITY CLIENT (utilities/gsec/)
#---------------------------------------
set(SECURITY_CLIENT_SRC
    utilities/gsec/call_service.cpp
)

#---------------------------------------
# OS SPECIFIC
#---------------------------------------
if (UNIX AND NOT APPLE)
    set(OS_SPECIFIC_SRC
        jrd/os/posix/config_root.cpp
        jrd/os/posix/path_utils.cpp
        jrd/os/posix/mod_loader.cpp
        jrd/os/posix/guid.cpp
        jrd/os/posix/os_utils.cpp
        jrd/os/posix/isc_ipc.cpp
        common/dllinst.cpp
    )
    # Binreloc for binary relocation support
    if (ENABLE_BINRELOC)
        list(APPEND OS_SPECIFIC_SRC
            ${CMAKE_SOURCE_DIR}/extern/binreloc/binreloc.c
        )
    endif()
elseif (APPLE)
    set(OS_SPECIFIC_SRC
        jrd/os/darwin/config_root.cpp
        jrd/os/posix/path_utils.cpp
        jrd/os/darwin/mod_loader.cpp
        jrd/os/posix/guid.cpp
        jrd/os/posix/os_utils.cpp
        jrd/os/posix/isc_ipc.cpp
        common/dllinst.cpp
    )
elseif (WIN32)
    set(OS_SPECIFIC_SRC
        jrd/os/win32/config_root.cpp
        jrd/os/win32/path_utils.cpp
        jrd/os/win32/mod_loader.cpp
        jrd/os/win32/guid.cpp
        jrd/os/win32/os_utils.cpp
        jrd/os/win32/isc_ipc.cpp
        common/dllinst.cpp
    )
endif()

#---------------------------------------
# SERVER MAIN DUMMY (for client library)
#---------------------------------------
# Server main dummy - only needed on Unix for symbol versioning
if (UNIX)
    set(SMD_SRC remote/os/sun/server_main_dummy.cpp)
endif()

################################################################################
# LIBRARY: libib_util.so
################################################################################

add_library(ib_util SHARED extlib/ib_util.cpp)

set_target_properties(ib_util PROPERTIES
    OUTPUT_NAME ib_util
)

set_output_directory_unix(ib_util lib)
set_exported_symbols(ib_util ib_util)
project_group(ib_util "Libraries")

################################################################################
# LIBRARY: ib_udf.so (UDF)
################################################################################

add_library(ib_udf MODULE extlib/ib_udf.cpp)

target_link_libraries(ib_udf ib_util)

set_target_properties(ib_udf PROPERTIES
    OUTPUT_NAME ib_udf
    PREFIX ""
)

set_output_directory_unix(ib_udf UDF)
project_group(ib_udf "Libraries/UDF")

################################################################################
# LIBRARY: fbudf.so (UDF)
################################################################################

add_library(fbudf MODULE
    extlib/fbudf/fbudf.cpp
    extlib/fbudf/stdafx.cpp
    common/classes/timestamp.cpp
)

target_compile_definitions(fbudf PRIVATE SUPERCLIENT)
target_link_libraries(fbudf ib_util)

set_target_properties(fbudf PROPERTIES
    OUTPUT_NAME fbudf
    PREFIX ""
)

set_output_directory_unix(fbudf UDF)
project_group(fbudf "Libraries/UDF")

################################################################################
# LIBRARY: libfbclient2.so
################################################################################

if (FIREBIRD_BUILD_FBCLIENT)

set(FBCLIENT_SRC
    ${JRD_CLIENT_SRC}
    ${REMOTE_CLIENT_SRC}
    ${DSQL_CLIENT_SRC}
    ${FBCLASSES_CLIENT_SRC}
    ${FBCLASSES_MSG_SRC}
    ${CLUMPLETS_SRC}
    ${FBCONFIG_SRC}
    ${CONFIG_SRC}
    ${VULCAN_SRC}
    ${FBCOMMON_SRC}
    ${GPRELIB_CLIENT_SRC}
    ${SECURITY_CLIENT_SRC}
    ${OS_SPECIFIC_SRC}
    ${SMD_SRC}
    ${AUTH_SRC}
)

add_library(fbclient2 SHARED ${FBCLIENT_SRC})

# Client library uses SUPERCLIENT define (server functionality disabled)
target_compile_definitions(fbclient2 PRIVATE SUPERCLIENT)

target_link_libraries(fbclient2
    PUBLIC ${LIB_dl}
    PUBLIC ${LIB_pthread}
    PUBLIC ${LIB_m}
    PUBLIC ${LIB_Ws2_32}
    PUBLIC ${LIB_mpr}
)

set_target_properties(fbclient2 PROPERTIES
    OUTPUT_NAME fbclient2
    VERSION ${FIREBIRD_VERSION}
    SOVERSION ${FIREBIRD_VERSION_MAJOR}
)

set_output_directory_unix(fbclient2 lib)
# Windows: .def file for DLL exports (symbols private by default)
# Linux: .vers file for symbol versioning (symbols public by default, adds ABI version tags)
# Different mechanisms with different naming conventions - no need to match
if(WIN32)
    set_exported_symbols(fbclient2 fbclient)
else()
    set_exported_symbols(fbclient2 firebird)
endif()
project_group(fbclient2 "Libraries")

# Export as Firebird2::fbclient for find_package consumers
set_target_properties(fbclient2 PROPERTIES EXPORT_NAME fbclient)

# Add interface include directories for downstream consumers
target_include_directories(fbclient2 PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src/include>
    $<INSTALL_INTERFACE:include/firebird>
)

########################################
# INSTALL RULES
########################################

# Install the fbclient library
install(TARGETS fbclient2
    EXPORT Firebird2Targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install public headers from src/include (except gen/)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/src/include/
    DESTINATION include/firebird
    FILES_MATCHING PATTERN "*.h"
    PATTERN "gen" EXCLUDE
)

# Install additional public headers not in src/include/
install(FILES
    ${CMAKE_SOURCE_DIR}/src/extlib/ib_util.h
    ${CMAKE_SOURCE_DIR}/src/jrd/perf.h
    ${CMAKE_SOURCE_DIR}/src/include/gen/iberror.h
    DESTINATION include/firebird
)

########################################
# Generate merged ibase.h
# The public ibase.h is a concatenation of multiple headers with #include directives stripped
# Matches builds/posix/Makefile.in.firebird IBASE_ExtraFiles
########################################

set(IBASE_OUTPUT_DIR ${CMAKE_BINARY_DIR}/include)
set(IBASE_OUTPUT ${IBASE_OUTPUT_DIR}/ibase.h)

# Source files to merge (order matters - matches builds/posix/Makefile.in.firebird)
set(IBASE_SOURCES
    ${CMAKE_SOURCE_DIR}/src/misc/ibase_header.txt
    ${CMAKE_SOURCE_DIR}/src/include/types_pub.h
    ${CMAKE_SOURCE_DIR}/src/include/consts_pub.h
    ${CMAKE_SOURCE_DIR}/src/dsql/sqlda_pub.h
    ${CMAKE_SOURCE_DIR}/src/jrd/dsc_pub.h
    ${CMAKE_SOURCE_DIR}/src/jrd/ibase.h
    ${CMAKE_SOURCE_DIR}/src/jrd/inf_pub.h
    ${CMAKE_SOURCE_DIR}/src/jrd/blr.h
    ${CMAKE_SOURCE_DIR}/src/include/gen/iberror.h
)

# Generate merged ibase.h at configure time
file(MAKE_DIRECTORY ${IBASE_OUTPUT_DIR})
set(IBASE_CONTENT "")
foreach(src ${IBASE_SOURCES})
    file(READ ${src} src_content)
    # Strip #include "..." lines (local includes that are now inlined)
    # Handle both Unix (\n) and Windows (\r\n) line endings
    string(REGEX REPLACE "#include[ \t]+\"[^\"]+\"[^\r\n]*[\r\n]+" "" src_content "${src_content}")
    string(APPEND IBASE_CONTENT "${src_content}\n")
endforeach()
file(WRITE ${IBASE_OUTPUT} "${IBASE_CONTENT}")

# Install generated ibase.h
install(FILES ${IBASE_OUTPUT}
    DESTINATION include/firebird
)

# Install export targets file
install(EXPORT Firebird2Targets
    FILE Firebird2Targets.cmake
    NAMESPACE Firebird2::
    DESTINATION lib/cmake/Firebird2
)

# Package configuration
include(CMakePackageConfigHelpers)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/Firebird2ConfigVersion.cmake"
    VERSION ${FIREBIRD_VERSION}
    COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
    "${CMAKE_SOURCE_DIR}/Firebird2Config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/Firebird2Config.cmake"
    INSTALL_DESTINATION lib/cmake/Firebird2
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/Firebird2Config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/Firebird2ConfigVersion.cmake"
    DESTINATION lib/cmake/Firebird2
)

endif() # FIREBIRD_BUILD_FBCLIENT

################################################################################
# LIBRARY: libfbembed2.so
################################################################################

if (FIREBIRD_BUILD_FBEMBED)

#---------------------------------------
# JRD SERVER (jrd/) - pre-generated from .epp
#---------------------------------------
set(JRD_SERVER_SRC
    jrd/blob_filter.cpp
    jrd/dpm.cpp
    jrd/dfw.cpp
    jrd/dyn.cpp
    jrd/dyn_def.cpp
    jrd/dyn_del.cpp
    jrd/dyn_mod.cpp
    jrd/dyn_util.cpp
    jrd/fun.cpp
    jrd/grant.cpp
    jrd/ini.cpp
    jrd/met.cpp
    jrd/pcmet.cpp
    jrd/scl.cpp
    jrd/CharSet.cpp
    jrd/Collation.cpp
    jrd/DatabaseSnapshot.cpp
    jrd/VirtualTable.cpp
    jrd/RecordBuffer.cpp
    jrd/blb.cpp
    jrd/btn.cpp
    jrd/btr.cpp
    jrd/builtin.cpp
    jrd/GlobalRWLock.cpp
    jrd/cch.cpp
    jrd/cmp.cpp
    jrd/cvt.cpp
    jrd/cvt2.cpp
    jrd/DataTypeUtil.cpp
    jrd/UserManagement.cpp
    jrd/divorce.cpp
    jrd/err.cpp
    jrd/event.cpp
    jrd/evl.cpp
    jrd/exe.cpp
    jrd/ext.cpp
    jrd/execute_statement.cpp
    jrd/filters.cpp
    jrd/flu.cpp
    jrd/functions.cpp
    jrd/idx.cpp
    jrd/inf.cpp
    jrd/intl.cpp
    jrd/intl_builtin.cpp
    jrd/IntlManager.cpp
    jrd/IntlUtil.cpp
    jrd/isc_sync.cpp
    jrd/jrd.cpp
    jrd/Database.cpp
    jrd/lck.cpp
    jrd/mov.cpp
    jrd/nav.cpp
    jrd/opt.cpp
    jrd/Optimizer.cpp
    jrd/pag.cpp
    jrd/par.cpp
    jrd/ods.cpp
    jrd/pwd.cpp
    jrd/PreparedStatement.cpp
    jrd/RandomGenerator.cpp
    jrd/Relation.cpp
    jrd/ResultSet.cpp
    jrd/rlck.cpp
    jrd/rpb_chain.cpp
    jrd/rse.cpp
    jrd/sdw.cpp
    jrd/shut.cpp
    jrd/sort.cpp
    jrd/sqz.cpp
    jrd/svc.cpp
    jrd/SysFunction.cpp
    jrd/TempSpace.cpp
    jrd/tpc.cpp
    jrd/tra.cpp
    jrd/validation.cpp
    jrd/vio.cpp
    jrd/nodebug.cpp
    jrd/nbak.cpp
    jrd/sha.cpp
    jrd/TextType.cpp
    jrd/unicode_util.cpp
    jrd/RuntimeStatistics.cpp
    jrd/DebugInterface.cpp
    jrd/extds/ExtDS.cpp
    jrd/extds/InternalDS.cpp
    jrd/extds/IscDS.cpp
    jrd/trace/TraceConfigStorage.cpp
    jrd/trace/TraceLog.cpp
    jrd/trace/TraceManager.cpp
    jrd/trace/TraceObjects.cpp
)

# Platform-specific physical I/O
if (UNIX)
    list(APPEND JRD_SERVER_SRC jrd/os/posix/unix.cpp)
elseif (WIN32)
    list(APPEND JRD_SERVER_SRC jrd/os/win32/winnt.cpp)
endif()

#---------------------------------------
# DSQL SERVER (dsql/) - pre-generated from .epp
#---------------------------------------
set(DSQL_SERVER_SRC
    dsql/metd.cpp
    dsql/DdlNodes.cpp
    dsql/ddl.cpp
    dsql/dsql.cpp
    dsql/errd.cpp
    dsql/gen.cpp
    dsql/hsh.cpp
    dsql/make.cpp
    dsql/movd.cpp
    dsql/parse.cpp
    dsql/Parser.cpp
    dsql/pass1.cpp
    dsql/misc_func.cpp
    dsql/StmtNodes.cpp
)

#---------------------------------------
# ALICE (alice/) - pre-generated from .epp
#---------------------------------------
set(ALICE_SRC
    alice/alice.cpp
    alice/exe.cpp
    alice/alice_meta.cpp
    alice/tdr.cpp
)

#---------------------------------------
# BURP (burp/) - pre-generated from .epp
#---------------------------------------
set(BURP_SRC
    burp/burp.cpp
    burp/backup.cpp
    burp/restore.cpp
    burp/mvol.cpp
    burp/misc.cpp
    burp/canonical.cpp
)

#---------------------------------------
# LOCK (lock/)
#---------------------------------------
set(LOCK_SRC
    lock/lock.cpp
)

#---------------------------------------
# SECURITY SERVER - pre-generated from .epp
#---------------------------------------
set(SECURITY_SERVER_SRC
    utilities/gstat/dba.cpp
    utilities/gstat/ppg.cpp
)

#---------------------------------------
# NBACKUP/NTRACE
#---------------------------------------
set(NBACKUP_SRC
    utilities/nbackup.cpp
)

set(NTRACE_SRC
    jrd/trace/TraceCmdLine.cpp
    jrd/trace/TraceService.cpp
)

#---------------------------------------
# COMMON SERVER CLASSES
#---------------------------------------
set(FBCLASSES_SERVER_SRC
    common/classes/UserBlob.cpp
)

#---------------------------------------
# Combine all sources for embedded library
#---------------------------------------
set(FBEMBED_SRC
    ${JRD_CLIENT_SRC}
    ${JRD_SERVER_SRC}
    ${DSQL_CLIENT_SRC}
    ${DSQL_SERVER_SRC}
    ${REMOTE_CLIENT_SRC}
    ${LOCK_SRC}
    ${ALICE_SRC}
    ${BURP_SRC}
    ${SECURITY_SERVER_SRC}
    ${NBACKUP_SRC}
    ${NTRACE_SRC}
    ${FBCLASSES_CLIENT_SRC}
    ${FBCLASSES_MSG_SRC}
    ${FBCLASSES_SERVER_SRC}
    ${CLUMPLETS_SRC}
    ${FBCONFIG_SRC}
    ${CONFIG_SRC}
    ${VULCAN_SRC}
    ${FBCOMMON_SRC}
    ${GPRELIB_CLIENT_SRC}
    ${SECURITY_CLIENT_SRC}
    ${OS_SPECIFIC_SRC}
    ${AUTH_SRC}
)

add_library(fbembed2 SHARED ${FBEMBED_SRC})

# Define EMBEDDED to disable features requiring security database
target_compile_definitions(fbembed2 PRIVATE EMBEDDED)

# Link bundled ICU (static) for character set support
target_link_libraries(fbembed2
    PRIVATE icu_uc
    PRIVATE icu_i18n
    PRIVATE icu_data
    PUBLIC ${LIB_dl}
    PUBLIC ${LIB_pthread}
    PUBLIC ${LIB_m}
    PUBLIC ${LIB_Ws2_32}
    PUBLIC ${LIB_mpr}
)

set_target_properties(fbembed2 PROPERTIES
    OUTPUT_NAME fbembed2
    VERSION ${FIREBIRD_VERSION}
    SOVERSION ${FIREBIRD_VERSION_MAJOR}
)

set_output_directory_unix(fbembed2 lib)
# Windows: .def for exports, Linux: .vers for symbol versioning (different mechanisms)
if(WIN32)
    set_exported_symbols(fbembed2 fbclient)
else()
    set_exported_symbols(fbembed2 firebird)
endif()
project_group(fbembed2 "Libraries")

# Install embedded library
install(TARGETS fbembed2
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

endif() # FIREBIRD_BUILD_FBEMBED

################################################################################
# INSTALL: Utility and UDF libraries
################################################################################

# Install ib_util library
install(TARGETS ib_util
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install UDF libraries to UDF/ directory
install(TARGETS ib_udf fbudf
    LIBRARY DESTINATION UDF
    RUNTIME DESTINATION UDF
)
