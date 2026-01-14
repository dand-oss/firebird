include(SourceGroups)

###############################################################################
#
# examples
#
###############################################################################

########################################
# EXECUTABLE empbuild
########################################

if (NOT CMAKE_CROSSCOMPILING)

# Skip empbuild for Debug on Windows - DLL loading issues with ASAN
string(TOUPPER "${CMAKE_BUILD_TYPE}" _BUILD_TYPE_UPPER)
if (WIN32 AND _BUILD_TYPE_UPPER STREQUAL "DEBUG")
    message(STATUS "Skipping empbuild for Windows Debug build (CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})")
else()

# Environment for master tools (isql, gpre, etc.)
# Use $<TARGET_FILE_DIR:yvalve> to get actual output location (handles VS directory structure)
if (WIN32)
    # For isql/gpre: Don't set PATH - DLLs are in same dir as EXE, and setting PATH
    # would replace system PATH breaking MSVC runtime DLL loading
    set(MASTER_ENV ${CMAKE_COMMAND} -E env "FIREBIRD=$<TARGET_FILE_DIR:yvalve>" "ASAN_OPTIONS=detect_leaks=0")
    # For empbuild: needs PATH to find gfix/isql via system() calls
    set(EMPBUILD_ENV ${CMAKE_COMMAND} -E env "FIREBIRD=$<TARGET_FILE_DIR:yvalve>" "ASAN_OPTIONS=detect_leaks=0" "PATH=$<TARGET_FILE_DIR:yvalve>")
else()
    set(MASTER_ENV ${CMAKE_COMMAND} -E env "FIREBIRD=${output_dir}" "ASAN_OPTIONS=detect_leaks=0")
    set(MASTER_ENV ${MASTER_ENV} "PATH=${output_dir}/bin:$ENV{PATH}" "LD_LIBRARY_PATH=${output_dir}/lib:${output_dir}")
    set(EMPBUILD_ENV ${MASTER_ENV})
endif()

# Create security5.fdb and firebird.conf where yvalve is (for embedded ISQL access)
# Use generator expressions to handle VS directory structure
# Note: For VS, output_dir doesn't match actual output location, so we use a workaround
add_custom_command(
    OUTPUT ${output_dir}/security5.fdb
    DEPENDS ${boot_dir}/security.fdb $<TARGET_FILE:yvalve>
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${boot_dir}/security.fdb ${output_dir}/security5.fdb
    # Also copy to yvalve's directory for VS builds where paths differ
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${boot_dir}/security.fdb $<TARGET_FILE_DIR:yvalve>/security5.fdb
    COMMENT "Copying security5.fdb for embedded access"
)
add_custom_command(
    OUTPUT ${output_dir}/firebird.conf
    DEPENDS $<TARGET_FILE:yvalve>
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_SOURCE_DIR}/builds/install/misc/firebird.conf ${output_dir}/firebird.conf
    # Also copy to yvalve's directory for VS builds where paths differ
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_SOURCE_DIR}/builds/install/misc/firebird.conf $<TARGET_FILE_DIR:yvalve>/firebird.conf
    COMMENT "Copying firebird.conf for embedded access"
)

# empbuild.fdb is generated in isql's directory (where DLLs are) then copied to examples build dir
# Use $<TARGET_FILE_DIR:isql> to get actual output location (handles multi-config correctly)
# Config files (firebird.msg, security5.fdb, firebird.conf) are copied to yvalve's dir by their source commands
set(empbuild_fdb_path ${CMAKE_CURRENT_BINARY_DIR}/empbuild.fdb)
add_custom_command(
    OUTPUT ${empbuild_fdb_path}
    DEPENDS
        $<TARGET_FILE:isql>
        $<TARGET_FILE:engine>
        $<TARGET_FILE:yvalve>
        ${CMAKE_CURRENT_SOURCE_DIR}/empbuild/empbld.sql
    WORKING_DIRECTORY $<TARGET_FILE_DIR:isql>
    COMMAND ${CMAKE_COMMAND} -E remove -f empbuild.fdb
    COMMAND ${MASTER_ENV} $<TARGET_FILE:isql> -q -i ${CMAKE_CURRENT_SOURCE_DIR}/empbuild/empbld.sql
    COMMAND ${CMAKE_COMMAND} -E copy_if_different empbuild.fdb ${empbuild_fdb_path}
    COMMAND ${CMAKE_COMMAND} -E remove empbuild.fdb
)
# empbuild.cpp is generated in gpre's directory (where DLLs are) then copied to examples build dir
# Use $<TARGET_FILE_DIR:gpre> to get actual output location (handles multi-config correctly)
set(empbuild_cpp_path ${CMAKE_CURRENT_BINARY_DIR}/empbuild.cpp)
add_custom_command(
    OUTPUT ${empbuild_cpp_path}
    DEPENDS
        $<TARGET_FILE:gpre>
        $<TARGET_FILE:engine>
        ${CMAKE_CURRENT_SOURCE_DIR}/empbuild/empbuild.epp
        ${empbuild_fdb_path}
    WORKING_DIRECTORY $<TARGET_FILE_DIR:gpre>
    COMMENT "Calling GPRE for empbuild.epp"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${empbuild_fdb_path} empbuild.fdb
    COMMAND ${MASTER_ENV} $<TARGET_FILE:gpre> -r -m -n ${CMAKE_CURRENT_SOURCE_DIR}/empbuild/empbuild.epp empbuild.cpp
    COMMAND ${CMAKE_COMMAND} -E copy_if_different empbuild.cpp ${empbuild_cpp_path}
    COMMAND ${CMAKE_COMMAND} -E remove empbuild.cpp empbuild.fdb
)

add_executable          (empbuild ${empbuild_cpp_path} ${empbuild_fdb_path} ${CMAKE_CURRENT_SOURCE_DIR}/empbuild/empbuild.epp)
target_link_libraries   (empbuild yvalve)
set_output_directory    (empbuild . CURRENT_DIR)
add_dependencies_cc     (empbuild engine messages)
project_group           (empbuild Examples)

file(GLOB files
    "${CMAKE_CURRENT_SOURCE_DIR}/empbuild/*.sql"
    "${CMAKE_CURRENT_SOURCE_DIR}/empbuild/*.inp"
)
foreach(F ${files})
    get_filename_component(name ${F} NAME)
    add_custom_command(TARGET empbuild POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${F} ${name})
endforeach()


########################################
# BUILD STEP employee_db
########################################

# Windows: copy DLL next to empbuild so it can be found (empbuild is in examples/, DLLs in firebird/)
if (WIN32)
    set(EMPBUILD_COPY_DLL COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:yvalve> $<TARGET_FILE_DIR:empbuild>)
else()
    set(EMPBUILD_COPY_DLL)
endif()

add_custom_command(
    OUTPUT employe2.fdb
    DEPENDS
        $<TARGET_FILE:empbuild>
        $<TARGET_FILE:gfix>
        $<TARGET_FILE:engine>
        ${files}
    COMMAND ${CMAKE_COMMAND} -E remove employe2.fdb
    COMMAND ${CMAKE_COMMAND} -E remove employe2_.fdb
    ${EMPBUILD_COPY_DLL}
    COMMAND ${EMPBUILD_ENV} $<TARGET_FILE:empbuild> employe2_.fdb
    COMMAND ${CMAKE_COMMAND} -E copy_if_different employe2_.fdb employe2.fdb
)
add_custom_target       (employee_db ALL DEPENDS employe2.fdb SOURCES ${files})
project_group           (employee_db "Examples/Custom build steps")

endif() # if (NOT WIN32 Debug)

endif() # if (NOT CMAKE_CROSSCOMPILING)


########################################
# SHARED LIBRARY udrcpp_example
########################################

file(GLOB udrcpp_example_src "udr/*")

add_library             (udrcpp_example SHARED ${udrcpp_example_src})
target_link_libraries   (udrcpp_example yvalve)
set_exported_symbols    (udrcpp_example udr_plugin)
set_output_directory    (udrcpp_example plugins/udr)
project_group           (udrcpp_example Examples)


########################################
# SHARED LIBRARY dbcrypt_example
########################################

add_library             (dbcrypt_example SHARED dbcrypt/DbCrypt.cpp)
set_target_properties   (dbcrypt_example PROPERTIES OUTPUT_NAME DbCrypt_example)
set_output_directory    (dbcrypt_example plugins)
add_dependencies_cc     (dbcrypt_example UpdateCloopInterfaces)
project_group           (dbcrypt_example Examples)


########################################
# SHARED LIBRARY cryptkeyholder_example
########################################

add_library             (cryptkeyholder_example SHARED dbcrypt/CryptKeyHolder.cpp)
set_target_properties   (cryptkeyholder_example PROPERTIES OUTPUT_NAME CryptKeyHolder_example)
set_output_directory    (cryptkeyholder_example plugins)
add_dependencies_cc     (cryptkeyholder_example UpdateCloopInterfaces)
project_group           (cryptkeyholder_example Examples)

###############################################################################
