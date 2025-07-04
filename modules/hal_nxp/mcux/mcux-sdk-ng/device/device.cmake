# Copyright 2025 NXP
#
# SPDX-License-Identifier: Apache-2.0

string(TOUPPER ${CONFIG_SOC} MCUX_DEVICE)

# Find the folder in mcux-sdk/devices that matches the device name
message(STATUS "Looking for device ${MCUX_DEVICE} in ${SdkRootDirPath}/devices/")

file(GLOB_RECURSE device_cmake_files ${SdkRootDirPath}/devices/*/CMakeLists.txt)
foreach(file ${device_cmake_files})
  get_filename_component(folder ${file} DIRECTORY)
  get_filename_component(folder_name ${folder} NAME)
  if(folder_name STREQUAL ${MCUX_DEVICE})
    message(STATUS "Found device folder: ${folder}")
    set(mcux_device_folder ${folder})
    break()
  endif()
endforeach()

if(NOT mcux_device_folder)
  message(FATAL_ERROR "Device ${MCUX_DEVICE} not found in ${SdkRootDirPath}/devices/")
endif()

if(DEFINED CONFIG_MCUX_CORE_SUFFIX)
  string (REGEX REPLACE "^_" "" core_id "${CONFIG_MCUX_CORE_SUFFIX}")
endif()

# Definitions to load device drivers
set(CONFIG_MCUX_HW_DEVICE_CORE "${MCUX_DEVICE}${CONFIG_MCUX_CORE_SUFFIX}")

# Define CPU macro
zephyr_compile_definitions("CPU_${CONFIG_SOC_PART_NUMBER}${CONFIG_MCUX_CORE_SUFFIX}")

if(CONFIG_SOC_SERIES_IMXRT10XX OR CONFIG_SOC_SERIES_IMXRT11XX)
  set(CONFIG_MCUX_COMPONENT_device.boot_header ON)
endif()

if(NOT CONFIG_SOC_MIMX94398_M33)
  set(CONFIG_MCUX_COMPONENT_device.system ON)
endif()
set(CONFIG_MCUX_COMPONENT_device.CMSIS ON)
if(NOT CONFIG_CLOCK_CONTROL_ARM_SCMI)
  set(CONFIG_MCUX_COMPONENT_driver.clock ON)
endif()

# Exclude fsl_power.c for DSP domains
if((CONFIG_ARM) AND (NOT CONFIG_CLOCK_CONTROL_ARM_SCMI))
  set(CONFIG_MCUX_COMPONENT_driver.power ON)
endif()

if(NOT CONFIG_CPU_CORTEX_A)
  set(CONFIG_MCUX_COMPONENT_driver.reset ON)
  set(CONFIG_MCUX_COMPONENT_driver.memory ON)
endif()

# Include fsl_dsp.c for ARM domains (applicable to i.MX RTxxx devices)
if(CONFIG_ARM)
  set(CONFIG_MCUX_COMPONENT_driver.dsp ON)
endif()

# load device variables
include(${mcux_device_folder}/variable.cmake)

# Load device files
mcux_add_cmakelists(${mcux_device_folder})

# Workaround for fsl_flexspi_nor_boot link error, remove the one in SDK, use the Zephyr file.
if(CONFIG_MCUX_COMPONENT_device.boot_header)

  get_target_property(MCUXSDK_SOURCES ${MCUX_SDK_PROJECT_NAME} SOURCES)
  list(FILTER MCUXSDK_SOURCES INCLUDE REGEX ".*fsl_flexspi_nor_boot\.c$")

  if(NOT MCUXSDK_SOURCES STREQUAL "")
    file(RELATIVE_PATH MCUXSDK_SOURCES ${SdkRootDirPath} ${MCUXSDK_SOURCES})
    mcux_project_remove_source(
      BASE_PATH ${SdkRootDirPath}
      SOURCES ${MCUXSDK_SOURCES}
    )
  endif()

endif()
