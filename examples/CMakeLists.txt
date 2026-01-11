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

# Environment for master tools (isql, gpre, etc.) - uses output_dir
set(MASTER_ENV ${CMAKE_COMMAND} -E env "FIREBIRD=${output_dir}")
if (UNIX)
    set(MASTER_ENV ${MASTER_ENV} "LD_LIBRARY_PATH=${output_dir}/lib:${output_dir}/bin")
endif()

# Create security5.fdb and firebird.conf in output_dir for embedded ISQL access
# security.fdb is created in boot_dir (includes $<CONFIG> for multi-config generators)
add_custom_command(
    OUTPUT ${output_dir}/security5.fdb
    DEPENDS ${boot_dir}/security.fdb
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${boot_dir}/security.fdb ${output_dir}/security5.fdb
    COMMENT "Copying security5.fdb for embedded access"
)
add_custom_command(
    OUTPUT ${output_dir}/firebird.conf
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_SOURCE_DIR}/builds/install/misc/firebird.conf ${output_dir}/firebird.conf
    COMMENT "Copying firebird.conf for embedded access"
)

add_custom_command(
    OUTPUT empbuild.fdb
    DEPENDS
        $<TARGET_FILE:isql>
        $<TARGET_FILE:engine>
        ${output_dir}/firebird.msg
        ${output_dir}/security5.fdb
        ${output_dir}/firebird.conf
        ${CMAKE_CURRENT_SOURCE_DIR}/empbuild/empbld.sql
    COMMAND ${CMAKE_COMMAND} -E remove empbuild.fdb
    COMMAND ${MASTER_ENV} $<TARGET_FILE:isql> -q -i ${CMAKE_CURRENT_SOURCE_DIR}/empbuild/empbld.sql
    COMMAND ${CMAKE_COMMAND} -E copy_if_different empbuild.fdb empbuild_.fdb
    COMMAND ${CMAKE_COMMAND} -E remove empbuild.fdb
    COMMAND ${CMAKE_COMMAND} -E copy_if_different empbuild_.fdb empbuild.fdb
)
add_custom_command(
    OUTPUT empbuild.cpp
    DEPENDS
        $<TARGET_FILE:gpre>
        $<TARGET_FILE:engine>
        ${CMAKE_CURRENT_SOURCE_DIR}/empbuild/empbuild.epp
        empbuild.fdb
    COMMENT "Calling GPRE for empbuild.epp"
    COMMAND ${MASTER_ENV} $<TARGET_FILE:gpre> -r -m -n ${CMAKE_CURRENT_SOURCE_DIR}/empbuild/empbuild.epp empbuild.cpp
)

add_executable          (empbuild empbuild.cpp empbuild.fdb ${CMAKE_CURRENT_SOURCE_DIR}/empbuild/empbuild.epp)
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

add_custom_command(
    OUTPUT employe2.fdb
    DEPENDS
        $<TARGET_FILE:empbuild>
        $<TARGET_FILE:gfix>
        $<TARGET_FILE:engine>
        ${files}
    COMMAND ${CMAKE_COMMAND} -E remove employe2.fdb
    COMMAND ${CMAKE_COMMAND} -E remove employe2_.fdb
    COMMAND ${MASTER_ENV} $<TARGET_FILE:empbuild> employe2_.fdb
    COMMAND ${CMAKE_COMMAND} -E copy_if_different employe2_.fdb employe2.fdb
)
add_custom_target       (employee_db ALL DEPENDS employe2.fdb SOURCES ${files})
project_group           (employee_db "Examples/Custom build steps")

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
