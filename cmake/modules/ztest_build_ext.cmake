include_guard(GLOBAL)

if (${BOARD} STREQUAL "unit_testing_ext/unit_testing")

    #set(EXTRA_ZEPHYR_MODULES /home/htring/embc/ztest-build-ext)

    list(APPEND EXTRA_ZEPHYR_MODULES ${UT_MODULE_DIR})

    message(STATUS "Loading ztest-build-ext")
    include(extensions)
    include(west)
    include(yaml)
    include(root)
    include(zephyr_module)

    if (NOT DEFINED ZEPHYR_ZTEST_BUILD_EXT_MODULE_DIR)
        message(FATAL_ERROR "Ztest build extension module is required but not found.")
    endif()

    add_executable(app "")

    add_subdirectory(${ZEPHYR_ZTEST_BUILD_EXT_MODULE_DIR} ${CMAKE_BINARY_DIR}/ext)
else()
    zephyr_package_message(NOTICE "Loading Zephyr default modules (${location}).")
    include(zephyr_default NO_POLICY_SCOPE)
endif()