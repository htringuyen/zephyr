include_guard(GLOBAL)

# Save original include command
macro(_original_include)
    _include(${ARGN})
endmacro()

# Override include with timing
macro(include)
    string(TIMESTAMP _start "%s%f" UTC)
    _include(${ARGN})
    string(TIMESTAMP _end "%s%f" UTC)
    math(EXPR _elapsed "${_end} - ${_start}")
    math(EXPR _ms_whole "${_elapsed} / 1000")
    math(EXPR _ms_frac "${_elapsed} % 1000")
    message(STATUS "include(${ARGV0}) took ${_ms_whole}.${_ms_frac} milliseconds")
endmacro()


if (${BOARD} STREQUAL "unit_testing_ext/unit_testing")

    if (NOT DEFINED UT_MODULE_DIR)
        message(FATAL_ERROR "Ztest build extension module is required but not found.")
    endif()

    list(APPEND EXTRA_ZEPHYR_MODULES ${UT_MODULE_DIR})

    message(STATUS "Loading ztest-build-ext")
    include(extensions)
    include(west)
    include(yaml)
    include(root)
    include(zephyr_module)

    add_executable(app "")

    add_subdirectory(${UT_MODULE_DIR} ${CMAKE_BINARY_DIR}/ext)
else()
    zephyr_package_message(NOTICE "Loading Zephyr default modules (${location}).")
    include(zephyr_default NO_POLICY_SCOPE)
endif()