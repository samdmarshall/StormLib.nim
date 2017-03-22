## ***************************************************************************
##  StormPort.h                           Copyright (c) Marko Friedemann 2001
## ---------------------------------------------------------------------------
##  Portability module for the StormLib library. Contains a wrapper symbols
##  to make the compilation under Linux work
## 
##  Author: Marko Friedemann <marko.friedemann@bmx-chemnitz.de>
##  Created at: Mon Jan 29 18:26:01 CEST 2001
##  Computer: whiplash.flachland-chemnitz.de
##  System: Linux 2.4.0 on i686
## 
##  Author: Sam Wilkins <swilkins1337@gmail.com>
##  System: Mac OS X and port to big endian processor
## 
## ---------------------------------------------------------------------------
##    Date    Ver   Who  Comment
##  --------  ----  ---  -------
##  29.01.01  1.00  Mar  Created
##  24.03.03  1.01  Lad  Some cosmetic changes
##  12.11.03  1.02  Dan  Macintosh compatibility
##  24.07.04  1.03  Sam  Mac OS X compatibility
##  22.11.06  1.04  Sam  Mac OS X compatibility (for StormLib 6.0)
##  31.12.06  1.05  XPinguin  Full GNU/Linux compatibility
##  17.10.12  1.05  Lad  Moved error codes so they don't overlap with errno.h
## ***************************************************************************

when not (system.cpuEndian == bigEndian):
  const
    PLATFORM_LITTLE_ENDIAN* = true


when defined(powerpc64) or defined(powerpc64el) or defined(amd64) or defined(arm64):
  const
    PLATFORM_64BIT* = true
else:
  const
    PLATFORM_32BIT* = true

## -----------------------------------------------------------------------------
##  Definition of Windows-specific types for non-Windows platforms

when not defined(windows):
  ##  Typedefs for ANSI C
  type
    BYTE* = cuchar
    USHORT* = cushort
    LONG* = cint
    DWORD* = cuint
    DWORD_PTR* = culong
    LONG_PTR* = clong
    INT_PTR* = clong
    LONGLONG* = clonglong
    ULONGLONG* = culonglong
    HANDLE* = pointer
    LPOVERLAPPED* = pointer
  ##  Unsupported on Linux and Mac
  type
    TCHAR* = char
    LCID* = cuint
    PLONG* = ptr LONG
    LPDWORD* = ptr DWORD
    LPBYTE* = ptr BYTE
  ##  Some Windows-specific defines
  const
    MAX_PATH* = 1024

##  64-bit calls are supplied by "normal" calls on Mac

when defined(macosx):
  const
    O_LARGEFILE* = 0
##  Platform-specific error codes for UNIX-based platforms

when defined(macosx) or defined(linux):
  const
    ERROR_SUCCESS* = 0
    ERROR_FILE_NOT_FOUND* = 2 # ENOENT
    ERROR_ACCESS_DENIED* = 1 # EPERM
    ERROR_INVALID_HANDLE* = 9 # EBADF
    ERROR_NOT_ENOUGH_MEMORY* = 12 # ENOMEM
    ERROR_NOT_SUPPORTED* = 45 # ENOTSUP
    ERROR_INVALID_PARAMETER* = 22 # EINVAL
    ERROR_DISK_FULL* = 28 # ENOSPC
    ERROR_ALREADY_EXISTS* = 17 # EEXIST
    ERROR_INSUFFICIENT_BUFFER* = 105 # ENOBUFS
    ERROR_BAD_FORMAT* = 1000
    ERROR_NO_MORE_FILES* = 1001
    ERROR_HANDLE_EOF* = 1002
    ERROR_CAN_NOT_COMPLETE* = 1003
    ERROR_FILE_CORRUPT* = 1004
## -----------------------------------------------------------------------------
##  Swapping functions

when system.cpuEndian == littleEndian:
  template BSWAP_INT16_UNSIGNED*(a: untyped): untyped =
    (a)

  template BSWAP_INT16_SIGNED*(a: untyped): untyped =
    (a)

  template BSWAP_INT32_UNSIGNED*(a: untyped): untyped =
    (a)

  template BSWAP_INT32_SIGNED*(a: untyped): untyped =
    (a)

  template BSWAP_INT64_SIGNED*(a: untyped): untyped =
    (a)

  template BSWAP_INT64_UNSIGNED*(a: untyped): untyped =
    (a)

  template BSWAP_ARRAY16_UNSIGNED*(a, b: untyped): void =
    discard
  
  template BSWAP_ARRAY32_UNSIGNED*(a, b: untyped): void =
    discard
  
  template BSWAP_ARRAY64_UNSIGNED*(a, b: untyped): void =
    discard
  
  template BSWAP_PART_HEADER*(a: untyped): void =
    discard
  
  template BSWAP_TMPQHEADER*(a, b: untyped): void =
    discard
  
  template BSWAP_TMPKHEADER*(a: untyped): void =
    discard
  
else:
  proc SwapInt16*(a2: uint16_t): int16_t
  proc SwapUInt16*(a2: uint16_t): uint16_t
  proc SwapInt32*(a2: uint32_t): int32_t
  proc SwapUInt32*(a2: uint32_t): uint32_t
  proc SwapInt64*(a2: uint64_t): int64_t
  proc SwapUInt64*(a2: uint64_t): uint64_t
  proc ConvertUInt16Buffer*(`ptr`: pointer; length: csize)
  proc ConvertUInt32Buffer*(`ptr`: pointer; length: csize)
  proc ConvertUInt64Buffer*(`ptr`: pointer; length: csize)
  proc ConvertTMPQUserData*(userData: pointer)
  proc ConvertTMPQHeader*(header: pointer; wPart: uint16_t)
  proc ConvertTMPKHeader*(header: pointer)
  template BSWAP_INT16_SIGNED*(a: untyped): untyped =
    SwapInt16((a))

  template BSWAP_INT16_UNSIGNED*(a: untyped): untyped =
    SwapUInt16((a))

  template BSWAP_INT32_SIGNED*(a: untyped): untyped =
    SwapInt32((a))

  template BSWAP_INT32_UNSIGNED*(a: untyped): untyped =
    SwapUInt32((a))

  template BSWAP_INT64_SIGNED*(a: untyped): untyped =
    SwapInt64((a))

  template BSWAP_INT64_UNSIGNED*(a: untyped): untyped =
    SwapUInt64((a))

  template BSWAP_ARRAY16_UNSIGNED*(a, b: untyped): untyped =
    ConvertUInt16Buffer((a), (b))

  template BSWAP_ARRAY32_UNSIGNED*(a, b: untyped): untyped =
    ConvertUInt32Buffer((a), (b))

  template BSWAP_ARRAY64_UNSIGNED*(a, b: untyped): untyped =
    ConvertUInt64Buffer((a), (b))

  template BSWAP_TMPQHEADER*(a, b: untyped): untyped =
    ConvertTMPQHeader((a), (b))

  template BSWAP_TMPKHEADER*(a: untyped): untyped =
    ConvertTMPKHeader((a))

