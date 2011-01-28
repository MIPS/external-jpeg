LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_ARM_MODE := arm

LOCAL_SRC_FILES := \
	jcapimin.c jcapistd.c jccoefct.c jccolor.c jcdctmgr.c jchuff.c \
	jcinit.c jcmainct.c jcmarker.c jcmaster.c jcomapi.c jcparam.c \
	jcphuff.c jcprepct.c jcsample.c jctrans.c jdapimin.c jdapistd.c \
	jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c jddctmgr.c jdhuff.c \
	jdinput.c jdmainct.c jdmarker.c jdmaster.c jdmerge.c jdphuff.c \
	jdpostct.c jdsample.c jdtrans.c jerror.c jfdctflt.c jfdctfst.c \
	jfdctint.c jidctflt.c jidctred.c jquant1.c \
	jquant2.c jutils.c jmemmgr.c \
	jmem-android.c

# the assembler is only for the ARM version, don't break the Linux sim
ifeq ($(strip $(TARGET_ARCH)),arm)
ANDROID_JPEG_ARM_ASSEMBLER := true
endif

# temp fix until we understand why this broke cnn.com
#ANDROID_JPEG_ARM_ASSEMBLER := false

# use mips assembler IDCT implementation if MIPS DSP-ASE is present
ifeq ($(strip $(TARGET_ARCH)),mips)
  ifeq ($(strip $(ARCH_MIPS_HAS_DSP)),true)
  ANDROID_JPEG_MIPS_ASSEMBLER := true
  endif
endif

ifeq ($(strip $(ANDROID_JPEG_ARM_ASSEMBLER)),true)
LOCAL_SRC_FILES += jidctint.c jidctfst.S
else ifeq ($(strip $(ANDROID_JPEG_MIPS_ASSEMBLER)),true)
LOCAL_CFLAGS += -DANDROID_JPEG_MIPS_ASSEMBLER -fPIC
LOCAL_SRC_FILES += jidctint.c mips_jidctfst.c
  ifneq ($(strip $(TARGET_CPU_ENDIAN)),EB)
  LOCAL_SRC_FILES += mips_idct_le.s
  else
  LOCAL_SRC_FILES += mips_idct_be.s
  endif
else
# no assembler code is used
LOCAL_SRC_FILES += jidctint.c jidctfst.c
endif

LOCAL_CFLAGS += -DAVOID_TABLES 
LOCAL_CFLAGS += -O3 -fstrict-aliasing -fprefetch-loop-arrays
#LOCAL_CFLAGS += -march=armv6j

LOCAL_MODULE:= libjpeg

include $(BUILD_SHARED_LIBRARY)
