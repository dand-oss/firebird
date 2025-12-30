################################################################################
#
# configure
#
################################################################################

########################################
# FUNCTION check_includes
########################################
function(check_includes files)
    foreach(F ${${files}})
        set(name ${F})
        string(REPLACE "." "_" name ${name})
        string(REPLACE "/" "_" name ${name})
        string(TOUPPER ${name} name)
        check_include_files(${F} HAVE_${name})
        #message("/* Define to 1 if you have the <${F}> header file. */")
        #message("#cmakedefine HAVE_${name} 1")
        #message("")
    endforeach()
endfunction(check_includes)

########################################
# FUNCTION check_functions
########################################
function(check_functions functions)
    foreach(F ${${functions}})
        set(name ${F})
        string(TOUPPER ${name} name)
        check_function_exists(${F} HAVE_${name})
        #message("/* Define to 1 if you have the `${F}' function. */")
        #message("#cmakedefine HAVE_${name} 1")
        #message("")
    endforeach()
endfunction(check_functions)

########################################
# FUNCTION check_type_alignment
########################################
function(check_type_alignment type var)
    if (NOT DEFINED ${var})
        check_c_source_runs("#include <stdlib.h>\nint main(){struct s{char a;${type} b;};exit((int)(long)&((struct s*)0)->b);}" ${var})
        #message(STATUS "Performing Test ${var} - It's still OK.")
        message(STATUS "Performing Test ${var} - Success")
        set(${var} ${${var}_EXITCODE} CACHE STRING "${type} alignment" FORCE)
    endif()
endfunction(check_type_alignment)

########################################
# FUNCTION check_symbol
########################################
function(check_symbol symbol var)
    if (NOT ${var}_SYMBOL)
        foreach(f ${ARGN})
            if (NOT ${var})
                unset(${var} CACHE)
                message(STATUS "Looking for ${symbol} - ${f}")
                check_symbol_exists(${symbol} ${f} ${var})
            endif()
        endforeach()
    endif()
    set(${var}_SYMBOL 1 CACHE INTERNAL "Do not check this symbol again")
endfunction(check_symbol)

########################################

include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckCXXSourceCompiles)
include(CheckCXXSourceRuns)
include(CheckFunctionExists)
include(CheckIncludeFiles)
include(CheckLibraryExists)
include(CheckPrototypeDefinition)
include(CheckStructHasMember)
include(CheckSymbolExists)
include(CheckTypeSize)
include(TestBigEndian)

if (ANDROID)
    set(LINUX 1)
endif()

if (IOS)
    set(CMAKE_SYSTEM_PROCESSOR "armv7")
    add_definitions(-D__arm__)
endif()

if (${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
    set(CLANG 1)
endif()

set(ENABLE_BINRELOC 1)

string(TOUPPER ${CMAKE_SYSTEM_NAME} CMAKE_SYSTEM_NAME_UPPER)
set(${CMAKE_SYSTEM_NAME_UPPER} 1)

string(TOUPPER ${CMAKE_SYSTEM_PROCESSOR} CMAKE_SYSTEM_PROCESSOR_UPPER)
string(FIND ${CMAKE_SYSTEM_PROCESSOR} "arm" ARM)
if (NOT ${ARM} EQUAL -1)
    set(ARM 1)
else()
    set(ARM)
endif()
if (${CMAKE_SYSTEM_PROCESSOR_UPPER} STREQUAL "X86_64" OR
    ${CMAKE_SYSTEM_PROCESSOR_UPPER} STREQUAL "AMD64")
    set(AMD64 1)
    set(I386 1)
endif()
set(${CMAKE_SYSTEM_PROCESSOR_UPPER} 1)

set(SHRLIB_EXT ${CMAKE_SHARED_LIBRARY_SUFFIX})
string(REPLACE "." "" SHRLIB_EXT ${SHRLIB_EXT})

set(CASE_SENSITIVITY "true")
set(SUPPORT_RAW_DEVICES 1)

################################################################################
# WINDOWS PRE-SET VALUES
# Set known results BEFORE checks to skip unnecessary compiler invocations
################################################################################

if (WIN32)
    set(ENABLE_BINRELOC 0)
    set(SUPPORT_RAW_DEVICES 0)
    set(WIN_NT 1)
    set(CASE_SENSITIVITY "false")

    # Headers that exist on Windows
    set(HAVE_ASSERT_H 1 CACHE INTERNAL "")
    set(HAVE_CTYPE_H 1 CACHE INTERNAL "")
    set(HAVE_ERRNO_H 1 CACHE INTERNAL "")
    set(HAVE_FCNTL_H 1 CACHE INTERNAL "")
    set(HAVE_FLOAT_H 1 CACHE INTERNAL "")
    set(HAVE_INTTYPES_H 1 CACHE INTERNAL "")
    set(HAVE_IO_H 1 CACHE INTERNAL "")
    set(HAVE_LIMITS_H 1 CACHE INTERNAL "")
    set(HAVE_LOCALE_H 1 CACHE INTERNAL "")
    set(HAVE_MATH_H 1 CACHE INTERNAL "")
    set(HAVE_MEMORY_H 1 CACHE INTERNAL "")
    set(HAVE_SETJMP_H 1 CACHE INTERNAL "")
    set(HAVE_SIGNAL_H 1 CACHE INTERNAL "")
    set(HAVE_STDARG_H 1 CACHE INTERNAL "")
    set(HAVE_STDINT_H 1 CACHE INTERNAL "")
    set(HAVE_STDLIB_H 1 CACHE INTERNAL "")
    set(HAVE_STRING_H 1 CACHE INTERNAL "")
    set(HAVE_SYS_STAT_H 1 CACHE INTERNAL "")
    set(HAVE_SYS_TIMEB_H 1 CACHE INTERNAL "")
    set(HAVE_SYS_TYPES_H 1 CACHE INTERNAL "")
    set(HAVE_WINSOCK2_H 1 CACHE INTERNAL "")

    # Headers that do NOT exist on Windows (POSIX-only)
    set(HAVE_AIO_H 0 CACHE INTERNAL "")
    set(HAVE_ATOMIC_H 0 CACHE INTERNAL "")
    set(HAVE_ATOMIC_OPS_H 0 CACHE INTERNAL "")
    set(HAVE_CRYPT_H 0 CACHE INTERNAL "")
    set(HAVE_DIRENT_H 0 CACHE INTERNAL "")
    set(HAVE_DLFCN_H 0 CACHE INTERNAL "")
    set(HAVE_EDITLINE_H 0 CACHE INTERNAL "")
    set(HAVE_GRP_H 0 CACHE INTERNAL "")
    set(HAVE_ICONV_H 0 CACHE INTERNAL "")
    set(HAVE_LANGINFO_H 0 CACHE INTERNAL "")
    set(HAVE_LIBIO_H 0 CACHE INTERNAL "")
    set(HAVE_LINUX_FALLOC_H 0 CACHE INTERNAL "")
    set(HAVE_MNTENT_H 0 CACHE INTERNAL "")
    set(HAVE_MNTTAB_H 0 CACHE INTERNAL "")
    set(HAVE_NDIR_H 0 CACHE INTERNAL "")
    set(HAVE_NETCONFIG_H 0 CACHE INTERNAL "")
    set(HAVE_NETINET_IN_H 0 CACHE INTERNAL "")
    set(HAVE_POLL_H 0 CACHE INTERNAL "")
    set(HAVE_PTHREAD_H 0 CACHE INTERNAL "")
    set(HAVE_PWD_H 0 CACHE INTERNAL "")
    set(HAVE_RPC_RPC_H 0 CACHE INTERNAL "")
    set(HAVE_RPC_XDR_H 0 CACHE INTERNAL "")
    set(HAVE_SEMAPHORE_H 0 CACHE INTERNAL "")
    set(HAVE_SOCKET_H 0 CACHE INTERNAL "")
    set(HAVE_STRINGS_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_DIR_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_FILE_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_IOCTL_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_IPC_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_MNTENT_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_MNTTAB_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_MOUNT_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_NDIR_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_PARAM_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_RESOURCE_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_SEM_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_SELECT_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_SIGINFO_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_SIGNAL_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_SOCKET_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_SOCKIO_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_SYSCALL_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_TIME_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_UIO_H 0 CACHE INTERNAL "")
    set(HAVE_SYS_WAIT_H 0 CACHE INTERNAL "")
    set(HAVE_TERMIO_H 0 CACHE INTERNAL "")
    set(HAVE_TERMIOS_H 0 CACHE INTERNAL "")
    set(HAVE_UNISTD_H 0 CACHE INTERNAL "")
    set(HAVE_VARARGS_H 0 CACHE INTERNAL "")
    set(HAVE_VFORK_H 0 CACHE INTERNAL "")
    set(HAVE_ZLIB_H 0 CACHE INTERNAL "")

    # Functions that exist on Windows (MSVC CRT)
    set(HAVE_DIRNAME 1 CACHE INTERNAL "")
    set(HAVE_FSYNC 0 CACHE INTERNAL "")  # Windows uses _commit
    set(HAVE_GETCWD 1 CACHE INTERNAL "")
    set(HAVE_GETPAGESIZE 1 CACHE INTERNAL "")
    set(HAVE_SNPRINTF 1 CACHE INTERNAL "")
    set(HAVE_STRDUP 1 CACHE INTERNAL "")
    set(HAVE_STRICMP 1 CACHE INTERNAL "")
    set(HAVE_STRNICMP 1 CACHE INTERNAL "")
    set(HAVE_SWAB 1 CACHE INTERNAL "")
    set(HAVE__SWAB 1 CACHE INTERNAL "")
    set(HAVE_TIME 1 CACHE INTERNAL "")
    set(HAVE_VSNPRINTF 1 CACHE INTERNAL "")

    # Functions that do NOT exist on Windows (POSIX-only)
    set(HAVE_ACCEPT4 0 CACHE INTERNAL "")
    set(HAVE_AO_COMPARE_AND_SWAP_FULL 0 CACHE INTERNAL "")
    set(HAVE_CLOCK_GETTIME 0 CACHE INTERNAL "")
    set(HAVE_CTIME_R 0 CACHE INTERNAL "")
    set(HAVE_FALLOCATE 0 CACHE INTERNAL "")
    set(HAVE_FCHMOD 0 CACHE INTERNAL "")
    set(HAVE_FLOCK 0 CACHE INTERNAL "")
    set(HAVE_FORK 0 CACHE INTERNAL "")
    set(HAVE_GETMNTENT 0 CACHE INTERNAL "")
    set(HAVE_GETRLIMIT 0 CACHE INTERNAL "")
    set(HAVE_GETTIMEOFDAY 0 CACHE INTERNAL "")
    set(HAVE_GETWD 0 CACHE INTERNAL "")
    set(HAVE_GMTIME_R 0 CACHE INTERNAL "")
    set(HAVE_INITGROUPS 0 CACHE INTERNAL "")
    set(HAVE_LOCALTIME_R 0 CACHE INTERNAL "")
    set(HAVE_MKSTEMP 0 CACHE INTERNAL "")
    set(HAVE_MMAP 0 CACHE INTERNAL "")
    set(HAVE_NANOSLEEP 0 CACHE INTERNAL "")
    set(HAVE_POLL 0 CACHE INTERNAL "")
    set(HAVE_POSIX_FADVISE 0 CACHE INTERNAL "")
    set(HAVE_PREAD 0 CACHE INTERNAL "")
    set(HAVE_PTHREAD_CANCEL 0 CACHE INTERNAL "")
    set(HAVE_PTHREAD_KEY_CREATE 0 CACHE INTERNAL "")
    set(HAVE_PTHREAD_KEYCREATE 0 CACHE INTERNAL "")
    set(HAVE_PTHREAD_MUTEXATTR_SETPROTOCOL 0 CACHE INTERNAL "")
    set(HAVE_PTHREAD_MUTEXATTR_SETROBUST_NP 0 CACHE INTERNAL "")
    set(HAVE_PTHREAD_MUTEX_CONSISTENT_NP 0 CACHE INTERNAL "")
    set(HAVE_PTHREAD_RWLOCKATTR_SETKIND_NP 0 CACHE INTERNAL "")
    set(HAVE_PWRITE 0 CACHE INTERNAL "")
    set(HAVE_QSORT_R 0 CACHE INTERNAL "")
    set(HAVE_SEMTIMEDOP 0 CACHE INTERNAL "")
    set(HAVE_SETITIMER 0 CACHE INTERNAL "")
    set(HAVE_SETMNTENT 0 CACHE INTERNAL "")
    set(HAVE_SETPGID 0 CACHE INTERNAL "")
    set(HAVE_SETPGRP 0 CACHE INTERNAL "")
    set(HAVE_SETRLIMIT 0 CACHE INTERNAL "")
    set(HAVE_SIGACTION 0 CACHE INTERNAL "")
    set(HAVE_SIGSET 0 CACHE INTERNAL "")
    set(HAVE_STRCASECMP 0 CACHE INTERNAL "")
    set(HAVE_STRERROR_R 0 CACHE INTERNAL "")
    set(HAVE_STRNCASECMP 0 CACHE INTERNAL "")
    set(HAVE_TCGETATTR 0 CACHE INTERNAL "")
    set(HAVE_TIMES 0 CACHE INTERNAL "")
    set(HAVE_VFORK 0 CACHE INTERNAL "")

    # Windows-specific extras
    set(HAVE_CTIME_S 1 CACHE INTERNAL "")
    set(HAVE_LOCALTIME_S 1 CACHE INTERNAL "")

    # Types that don't exist on Windows (POSIX-only)
    set(HAVE_PID_T "" CACHE INTERNAL "")
    set(HAVE_CADDR_T "" CACHE INTERNAL "")
    set(HAVE_GID_T "" CACHE INTERNAL "")
    set(HAVE_UID_T "" CACHE INTERNAL "")
    set(HAVE_SOCKLEN_T "" CACHE INTERNAL "")

endif(WIN32)

################################################################################
# UNIX/LINUX HEADER AND FUNCTION CHECKS
# Only run these checks on non-Windows platforms
################################################################################

if (NOT WIN32)

set(include_files_list
    aio.h
    assert.h
    atomic.h
    atomic_ops.h
    crypt.h
    ctype.h
    dirent.h
    dlfcn.h
    editline.h
    errno.h
    fcntl.h
    float.h
    grp.h
    iconv.h
    io.h
    inttypes.h
    langinfo.h
    libio.h
    linux/falloc.h
    limits.h
    locale.h
    math.h
    memory.h
    mntent.h
    mnttab.h
    ndir.h
    netconfig.h
    netinet/in.h
    poll.h
    pthread.h
    pwd.h
    rpc/rpc.h
    rpc/xdr.h
    semaphore.h
    setjmp.h
    signal.h
    socket.h
    stdarg.h
    stdint.h
    stdlib.h
    string.h
    strings.h
    sys/dir.h
    sys/file.h
    sys/ioctl.h
    sys/ipc.h
    sys/mntent.h
    sys/mnttab.h
    sys/mount.h
    sys/ndir.h
    sys/param.h
    sys/resource.h
    sys/sem.h
    sys/select.h
    sys/siginfo.h
    sys/signal.h
    sys/socket.h
    sys/sockio.h
    sys/stat.h
    sys/syscall.h
    sys/time.h
    sys/timeb.h
    sys/types.h
    sys/uio.h
    sys/wait.h
    termio.h
    termios.h
    unistd.h
    varargs.h
    vfork.h
    winsock2.h
    zlib.h
)
check_includes(include_files_list)

#if test "$EDITLINE_FLG" = "Y"; then
#  AC_HEADER_DIRENT
#  AC_DEFINE(HAVE_EDITLINE_H, 1, [Define this if editline is in use])
#fi

set(functions_list
    accept4
    AO_compare_and_swap_full
    clock_gettime
    ctime_r
    dirname
    fallocate
    fchmod
    fsync
    flock
    fork
    getpagesize
    getcwd getwd
    gettimeofday
    gmtime_r
    initgroups
    localtime_r
    mkstemp
    mmap
    nanosleep
    poll
    posix_fadvise
    pread pwrite
    pthread_cancel
    pthread_keycreate pthread_key_create
    pthread_mutexattr_setprotocol
    pthread_mutexattr_setrobust_np
    pthread_mutex_consistent_np
    pthread_rwlockattr_setkind_np
    qsort_r
    setitimer
    semtimedop
    setpgid
    setpgrp
    setmntent getmntent
    setrlimit getrlimit
    sigaction
    sigset
    snprintf vsnprintf
    strcasecmp stricmp
    strncasecmp strnicmp
    strdup
    strerror_r
    swab _swab
    tcgetattr
    time times
    vfork
)
check_functions(functions_list)

if (APPLE)
    set(HAVE_QSORT_R 0 CACHE STRING "Disabled on OS X" FORCE)
endif()

endif() # NOT WIN32

################################################################################
# CROSS-PLATFORM CHECKS
# These work on all platforms - let the compiler figure out sizes
################################################################################

# Cross-platform type size checks
check_type_size(long SIZEOF_LONG)
check_type_size(size_t SIZEOF_SIZE_T)
check_type_size("void *" SIZEOF_VOID_P)
check_type_size(size_t HAVE_SIZE_T)

if (NOT WIN32)
    # POSIX types - only check on UNIX
    check_type_size(off_t HAVE_OFF_T)
    check_type_size(pid_t HAVE_PID_T)
    check_type_size(caddr_t HAVE_CADDR_T)

    if (${HAVE_OFF_T} AND ${HAVE_OFF_T} EQUAL 8)
        set(_FILE_OFFSET_BITS 64)
    endif()
endif()

test_big_endian(WORDS_BIGENDIAN)
check_symbol_exists(INFINITY math.h HAVE_INFINITY)
check_symbol_exists(va_copy stdarg.h HAVE_VA_COPY)

# Windows-specific: MAXPATHLEN from MAX_PATH
if (WIN32)
    set(CMAKE_EXTRA_INCLUDE_FILES Windows.h)
    check_type_size("char[MAX_PATH]" MAXPATHLEN)
    set(CMAKE_EXTRA_INCLUDE_FILES)
endif()

# UNIX-only checks (these headers/functions don't exist on Windows)
if (NOT WIN32)
    check_cxx_source_compiles("#include <unistd.h>\nint main(){fdatasync(0);return 0;}" HAVE_FDATASYNC)

    check_library_exists(dl dladdr "${CMAKE_LIBRARY_PREFIX}" HAVE_DLADDR)
    check_library_exists(m fegetenv "${CMAKE_LIBRARY_PREFIX}" HAVE_FEGETENV)
    check_library_exists(m llrint "${CMAKE_LIBRARY_PREFIX}" HAVE_LLRINT)
    check_library_exists(pthread sem_init "${CMAKE_LIBRARY_PREFIX}" HAVE_SEM_INIT)
    check_library_exists(pthread sem_timedwait "${CMAKE_LIBRARY_PREFIX}" HAVE_SEM_TIMEDWAIT)

    check_c_source_compiles("#include <sys/sem.h>\nint main(){union semun s;return 0;}" HAVE_SEMUN)

    set(CMAKE_EXTRA_INCLUDE_FILES sys/socket.h sys/types.h)
    check_type_size(socklen_t HAVE_SOCKLEN_T)
    set(CMAKE_EXTRA_INCLUDE_FILES)

    check_type_size(gid_t HAVE_GID_T)
    check_type_size(uid_t HAVE_UID_T)

    check_symbol(SOCK_CLOEXEC HAVE_DECL_SOCK_CLOEXEC socket.h sys/socket.h)

    # gettimeofday check
    check_c_source_compiles("
        #include <sys/time.h>
        int main() {
            struct timeval tv;
            gettimeofday(&tv, (void*)0);
            return 0;
        }
    " GETTIMEOFDAY_RETURNS_TIMEZONE)

    check_prototype_definition(
        getmntent
        "int getmntent(FILE *file, struct mnttab *mptr)"
        0
        mntent.h
        GETMNTENT_TAKES_TWO_ARGUMENTS
    )

    check_struct_has_member("struct dirent" d_type dirent.h HAVE_STRUCT_DIRENT_D_TYPE)

    check_c_source_compiles("#include <unistd.h>\nint main(){getpgrp();return 0;}" GETPGRP_VOID)
    check_c_source_compiles("#include <unistd.h>\nint main(){setpgrp();return 0;}" SETPGRP_VOID)

    check_c_source_compiles("__thread int a = 42;int main(){a = a + 1;return 0;}" HAVE___THREAD)
    check_c_source_compiles("#include <sys/time.h>\n#include <time.h>\nint main(){return 0;}" TIME_WITH_SYS_TIME)

    set(CMAKE_REQUIRED_LIBRARIES pthread)
    check_c_source_compiles("#include <semaphore.h>\nint main(){sem_t s;sem_init(&s,0,0);return 0;}" WORKING_SEM_INIT)
    set(CMAKE_REQUIRED_LIBRARIES)

    if (EXISTS "/proc/self/exe")
        set(HAVE__PROC_SELF_EXE 1)
    endif()
endif() # NOT WIN32

########################################

if (NOT CMAKE_CROSSCOMPILING)
    check_type_alignment(long FB_ALIGNMENT)
    check_type_alignment(double FB_DOUBLE_ALIGN)
else() # CMAKE_CROSSCOMPILING
    set(FB_ALIGNMENT 8)
    set(FB_DOUBLE_ALIGN 8)
    if (ANDROID)
        set(HAVE__PROC_SELF_EXE 1)
    endif()
endif()

########################################

# WIN32 settings moved to pre-cache block at top of file

if (APPLE)
    set(ENABLE_BINRELOC 0)
    set(CASE_SENSITIVITY "false")
endif()

################################################################################
