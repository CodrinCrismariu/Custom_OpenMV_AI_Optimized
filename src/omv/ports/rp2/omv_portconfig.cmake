# SPDX-License-Identifier: MIT
#
# Copyright (C) 2021-2024 OpenMV, LLC.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Need to redefine these variables here.
set(TOP_DIR                 $ENV{TOP_DIR})
set(TARGET                  $ENV{TARGET})
set(PORT                    rp2)
set(BUILD                   ${TOP_DIR}/build/rp2)
set(BIN_DIR                 ${TOP_DIR}/build/bin)
set(OMV_DIR                 omv)
set(UVC_DIR                 uvc)
set(CM4_DIR                 cm4)
set(CMSIS_DIR               hal/cmsis)
set(LEPTON_DIR              drivers/lepton)
set(LSM6DS3_DIR             drivers/lsm6ds3)
set(WINC1500_DIR            drivers/winc1500)
set(MLX90621_DIR            drivers/mlx90621)
set(MLX90640_DIR            drivers/mlx90640)
set(MLX90641_DIR            drivers/mlx90641)
set(OPENPDM_DIR             ${TOP_DIR}/lib/openpdm)
set(TENSORFLOW_DIR          ${TOP_DIR}/lib/libtf)
set(OMV_BOARD_CONFIG_DIR    ${TOP_DIR}/${OMV_DIR}/boards/${TARGET}/)
set(OMV_COMMON_DIR          ${TOP_DIR}/${OMV_DIR}/common)
set(PORT_DIR                ${TOP_DIR}/${OMV_DIR}/ports/${PORT})
set(MICROPY_MANIFEST_OMV_LIB_DIR    ${TOP_DIR}/../scripts/libraries)

# Include board cmake fragment
include(${OMV_BOARD_CONFIG_DIR}/omv_boardconfig.cmake)

get_target_property(MICROPY_SOURCES ${MICROPY_TARGET} SOURCES)
list(REMOVE_ITEM MICROPY_SOURCES pendsv.c main.c)
set_property(TARGET ${MICROPY_TARGET} PROPERTY SOURCES ${MICROPY_SOURCES})

target_link_options(${MICROPY_TARGET} PRIVATE
    -Wl,--wrap=tud_cdc_rx_cb
    -Wl,--wrap=mp_hal_stdout_tx_strn
)

target_compile_definitions(${MICROPY_TARGET} PRIVATE
    ARM_MATH_CM0PLUS
    ${OMV_BOARD_MODULES_DEFINITIONS}
    CMSIS_MCU_H="${CMSIS_MCU_H}"
)

target_link_libraries(${MICROPY_TARGET}
    pico_bootsel_via_double_reset
)

# Linker script
add_custom_command(
    OUTPUT ${BUILD}/rp2.ld
    COMMENT "Preprocessing linker script"
    COMMAND "${CMAKE_C_COMPILER}" -P -E -I ${OMV_BOARD_CONFIG_DIR} -DLINKER_SCRIPT ${PORT_DIR}/rp2.ld.S > ${BUILD}/rp2.ld
    DEPENDS ${OMV_BOARD_CONFIG_DIR}/omv_boardconfig.h ${PORT_DIR}/rp2.ld.S
    VERBATIM
)
add_custom_target(
    LinkerScript
    ALL DEPENDS ${BUILD}/rp2.ld
    VERBATIM
)
pico_set_linker_script(${MICROPY_TARGET} ${BUILD}/rp2.ld)

# Add OMV qstr sources
file(GLOB OMV_SRC_QSTR1 ${TOP_DIR}/${OMV_DIR}/modules/*.c)
file(GLOB OMV_SRC_QSTR2 ${TOP_DIR}/${OMV_DIR}/ports/${PORT}/modules/*.c)
list(APPEND MICROPY_SOURCE_QSTR ${OMV_SRC_QSTR1} ${OMV_SRC_QSTR2})

target_include_directories(${MICROPY_TARGET} PRIVATE
    ${TOP_DIR}/${CMSIS_DIR}/include/
    ${TOP_DIR}/${CMSIS_DIR}/include/rpi/

    ${MICROPY_DIR}/py/
    ${MICROPY_DIR}/lib/oofatfs/
    ${MICROPY_DIR}/lib/tinyusb/src/

    ${TOP_DIR}/${OMV_DIR}/
    ${TOP_DIR}/${OMV_DIR}/alloc/
    ${TOP_DIR}/${OMV_DIR}/common/
    ${TOP_DIR}/${OMV_DIR}/imlib/
    ${TOP_DIR}/${OMV_DIR}/modules/
    ${TOP_DIR}/${OMV_DIR}/sensors/
    ${TOP_DIR}/${OMV_DIR}/ports/${PORT}/
    ${TOP_DIR}/${OMV_DIR}/ports/${PORT}/modules/

    ${TOP_DIR}/${LEPTON_DIR}/include/
    ${TOP_DIR}/${LSM6DS3_DIR}/include/
    ${TOP_DIR}/${WINC1500_DIR}/include/
    ${TOP_DIR}/${MLX90621_DIR}/include/
    ${TOP_DIR}/${MLX90640_DIR}/include/
    ${TOP_DIR}/${MLX90641_DIR}/include/
    ${OMV_BOARD_CONFIG_DIR}
    ${TOP_DIR}/${OMV_DIR}/templates/
)

file(GLOB OMV_USER_MODULES ${TOP_DIR}/${OMV_DIR}/modules/*.c)

target_sources(${MICROPY_TARGET} PRIVATE
    ${TOP_DIR}/${OMV_DIR}/alloc/xalloc.c
    ${TOP_DIR}/${OMV_DIR}/alloc/fb_alloc.c
    ${TOP_DIR}/${OMV_DIR}/alloc/umm_malloc.c
    ${TOP_DIR}/${OMV_DIR}/alloc/dma_alloc.c
    ${TOP_DIR}/${OMV_DIR}/alloc/unaligned_memcpy.c

    ${TOP_DIR}/${OMV_DIR}/common/array.c
    ${TOP_DIR}/${OMV_DIR}/common/ringbuf.c
    ${TOP_DIR}/${OMV_DIR}/common/trace.c
    ${TOP_DIR}/${OMV_DIR}/common/mutex.c
    ${TOP_DIR}/${OMV_DIR}/common/pendsv.c
    ${TOP_DIR}/${OMV_DIR}/common/usbdbg.c
    ${TOP_DIR}/${OMV_DIR}/common/tinyusb_debug.c
    ${TOP_DIR}/${OMV_DIR}/common/file_utils.c
    ${TOP_DIR}/${OMV_DIR}/common/mp_utils.c
    ${TOP_DIR}/${OMV_DIR}/common/omv_csi.c

    ${TOP_DIR}/${OMV_DIR}/sensors/ov2640.c
    ${TOP_DIR}/${OMV_DIR}/sensors/ov5640.c
    ${TOP_DIR}/${OMV_DIR}/sensors/ov7670.c
    ${TOP_DIR}/${OMV_DIR}/sensors/ov7690.c
    ${TOP_DIR}/${OMV_DIR}/sensors/ov7725.c
    ${TOP_DIR}/${OMV_DIR}/sensors/ov9650.c
    ${TOP_DIR}/${OMV_DIR}/sensors/mt9v0xx.c
    ${TOP_DIR}/${OMV_DIR}/sensors/mt9m114.c
    ${TOP_DIR}/${OMV_DIR}/sensors/lepton.c
    ${TOP_DIR}/${OMV_DIR}/sensors/hm01b0.c
    ${TOP_DIR}/${OMV_DIR}/sensors/gc2145.c

    ${TOP_DIR}/${OMV_DIR}/imlib/agast.c
    ${TOP_DIR}/${OMV_DIR}/imlib/apriltag.c
    ${TOP_DIR}/${OMV_DIR}/imlib/bayer.c
    ${TOP_DIR}/${OMV_DIR}/imlib/binary.c
    ${TOP_DIR}/${OMV_DIR}/imlib/blob.c
    ${TOP_DIR}/${OMV_DIR}/imlib/bmp.c
    ${TOP_DIR}/${OMV_DIR}/imlib/clahe.c
    ${TOP_DIR}/${OMV_DIR}/imlib/collections.c
    ${TOP_DIR}/${OMV_DIR}/imlib/dmtx.c
    ${TOP_DIR}/${OMV_DIR}/imlib/draw.c
    ${TOP_DIR}/${OMV_DIR}/imlib/edge.c
    ${TOP_DIR}/${OMV_DIR}/imlib/eye.c
    ${TOP_DIR}/${OMV_DIR}/imlib/fast.c
    ${TOP_DIR}/${OMV_DIR}/imlib/fft.c
    ${TOP_DIR}/${OMV_DIR}/imlib/filter.c
    ${TOP_DIR}/${OMV_DIR}/imlib/fmath.c
    ${TOP_DIR}/${OMV_DIR}/imlib/font.c
    ${TOP_DIR}/${OMV_DIR}/imlib/framebuffer.c
    ${TOP_DIR}/${OMV_DIR}/imlib/fsort.c
    ${TOP_DIR}/${OMV_DIR}/imlib/gif.c
    ${TOP_DIR}/${OMV_DIR}/imlib/haar.c
    ${TOP_DIR}/${OMV_DIR}/imlib/hog.c
    ${TOP_DIR}/${OMV_DIR}/imlib/hough.c
    ${TOP_DIR}/${OMV_DIR}/imlib/imlib.c
    ${TOP_DIR}/${OMV_DIR}/imlib/integral.c
    ${TOP_DIR}/${OMV_DIR}/imlib/integral_mw.c
    ${TOP_DIR}/${OMV_DIR}/imlib/isp.c
    ${TOP_DIR}/${OMV_DIR}/imlib/jpegd.c
    ${TOP_DIR}/${OMV_DIR}/imlib/jpege.c
    ${TOP_DIR}/${OMV_DIR}/imlib/lodepng.c
    ${TOP_DIR}/${OMV_DIR}/imlib/png.c
    ${TOP_DIR}/${OMV_DIR}/imlib/kmeans.c
    ${TOP_DIR}/${OMV_DIR}/imlib/lab_tab.c
    ${TOP_DIR}/${OMV_DIR}/imlib/lbp.c
    ${TOP_DIR}/${OMV_DIR}/imlib/line.c
    ${TOP_DIR}/${OMV_DIR}/imlib/lsd.c
    ${TOP_DIR}/${OMV_DIR}/imlib/mathop.c
    ${TOP_DIR}/${OMV_DIR}/imlib/mjpeg.c
    ${TOP_DIR}/${OMV_DIR}/imlib/orb.c
    ${TOP_DIR}/${OMV_DIR}/imlib/phasecorrelation.c
    ${TOP_DIR}/${OMV_DIR}/imlib/point.c
    ${TOP_DIR}/${OMV_DIR}/imlib/ppm.c
    ${TOP_DIR}/${OMV_DIR}/imlib/qrcode.c
    ${TOP_DIR}/${OMV_DIR}/imlib/qsort.c
    ${TOP_DIR}/${OMV_DIR}/imlib/rainbow_tab.c
    ${TOP_DIR}/${OMV_DIR}/imlib/rectangle.c
    ${TOP_DIR}/${OMV_DIR}/imlib/selective_search.c
    ${TOP_DIR}/${OMV_DIR}/imlib/sincos_tab.c
    ${TOP_DIR}/${OMV_DIR}/imlib/stats.c
    ${TOP_DIR}/${OMV_DIR}/imlib/stereo.c
    ${TOP_DIR}/${OMV_DIR}/imlib/template.c
    ${TOP_DIR}/${OMV_DIR}/imlib/xyz_tab.c
    ${TOP_DIR}/${OMV_DIR}/imlib/yuv.c
    ${TOP_DIR}/${OMV_DIR}/imlib/zbar.c

    ${TOP_DIR}/${OMV_DIR}/ports/${PORT}/main.c
    ${TOP_DIR}/${OMV_DIR}/ports/${PORT}/omv_gpio.c
    ${TOP_DIR}/${OMV_DIR}/ports/${PORT}/omv_i2c.c
    ${TOP_DIR}/${OMV_DIR}/ports/${PORT}/omv_csi.c

    ${OMV_USER_MODULES}
)
set_source_files_properties(
    ${TOP_DIR}/${OMV_DIR}/imlib/fmath.c
    PROPERTIES
    COMPILE_OPTIONS "-fno-strict-aliasing"
)

if(MICROPY_PY_CSI)
    target_compile_definitions(${MICROPY_TARGET} PRIVATE
        MICROPY_PY_CSI=1
    )

    # Generate DCMI PIO header
    pico_generate_pio_header(${MICROPY_TARGET}
        ${OMV_BOARD_CONFIG_DIR}/dcmi.pio
    )
endif()

if(MICROPY_PY_AUDIO)
    target_include_directories(${MICROPY_TARGET} PRIVATE
        ${OPENPDM_DIR}/
    )

    set(AUDIO_SOURCES
	    ${OPENPDM_DIR}/OpenPDMFilter.c
        ${TOP_DIR}/${OMV_DIR}/ports/${PORT}/modules/py_audio.c
    )

    target_sources(${MICROPY_TARGET} PRIVATE ${AUDIO_SOURCES})

    target_compile_definitions(${MICROPY_TARGET} PRIVATE
        MICROPY_PY_AUDIO=1
        USE_LUT
    )

    pico_generate_pio_header(${MICROPY_TARGET}
        ${TOP_DIR}/${OMV_DIR}/ports/${PORT}/pdm.pio
    )
endif()

if(MICROPY_PY_ULAB)
    set(MICROPY_ULAB_DIR "${TOP_DIR}/${OMV_DIR}/modules/ulab")

    target_include_directories(${MICROPY_TARGET} PRIVATE
        ${MICROPY_ULAB_DIR}/code/
    )

    set(ULAB_SOURCES
        ${MICROPY_ULAB_DIR}/code/ndarray.c
        ${MICROPY_ULAB_DIR}/code/ndarray_operators.c
        ${MICROPY_ULAB_DIR}/code/ndarray_properties.c
        ${MICROPY_ULAB_DIR}/code/numpy/approx.c
        ${MICROPY_ULAB_DIR}/code/numpy/bitwise.c
        ${MICROPY_ULAB_DIR}/code/numpy/carray/carray.c
        ${MICROPY_ULAB_DIR}/code/numpy/carray/carray_tools.c
        ${MICROPY_ULAB_DIR}/code/numpy/compare.c
        ${MICROPY_ULAB_DIR}/code/numpy/create.c
        ${MICROPY_ULAB_DIR}/code/numpy/fft/fft.c
        ${MICROPY_ULAB_DIR}/code/numpy/fft/fft_tools.c
        ${MICROPY_ULAB_DIR}/code/numpy/filter.c
        ${MICROPY_ULAB_DIR}/code/numpy/io/io.c
        ${MICROPY_ULAB_DIR}/code/numpy/linalg/linalg.c
        ${MICROPY_ULAB_DIR}/code/numpy/linalg/linalg_tools.c
        ${MICROPY_ULAB_DIR}/code/numpy/ndarray/ndarray_iter.c
        ${MICROPY_ULAB_DIR}/code/numpy/numerical.c
        ${MICROPY_ULAB_DIR}/code/numpy/numpy.c
        ${MICROPY_ULAB_DIR}/code/numpy/poly.c
        ${MICROPY_ULAB_DIR}/code/numpy/random/random.c
        ${MICROPY_ULAB_DIR}/code/numpy/stats.c
        ${MICROPY_ULAB_DIR}/code/numpy/transform.c
        ${MICROPY_ULAB_DIR}/code/numpy/vector.c
        ${MICROPY_ULAB_DIR}/code/scipy/integrate/integrate.c
        ${MICROPY_ULAB_DIR}/code/scipy/linalg/linalg.c
        ${MICROPY_ULAB_DIR}/code/scipy/optimize/optimize.c
        ${MICROPY_ULAB_DIR}/code/scipy/scipy.c
        ${MICROPY_ULAB_DIR}/code/scipy/signal/signal.c
        ${MICROPY_ULAB_DIR}/code/scipy/special/special.c
        ${MICROPY_ULAB_DIR}/code/ulab.c
        ${MICROPY_ULAB_DIR}/code/ulab_tools.c
        ${MICROPY_ULAB_DIR}/code/user/user.c
        ${MICROPY_ULAB_DIR}/code/utils/utils.c
    )

    target_sources(${MICROPY_TARGET} PRIVATE ${ULAB_SOURCES})
    list(APPEND MICROPY_SOURCE_QSTR ${ULAB_SOURCES})

    target_compile_definitions(${MICROPY_TARGET} PRIVATE
        MICROPY_PY_ULAB=1
        MODULE_ULAB_ENABLED=1
        ULAB_CONFIG_FILE="${OMV_BOARD_CONFIG_DIR}/ulab_config.h"
    )
endif()

target_compile_definitions(${MICROPY_TARGET} PRIVATE
    MP_CONFIGFILE="${TOP_DIR}/${OMV_DIR}/ports/${PORT}/omv_mpconfigport.h"
)

add_custom_command(TARGET ${MICROPY_TARGET}
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${BIN_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy firmware.elf firmware.bin firmware.uf2 ${BIN_DIR}
    VERBATIM
)
