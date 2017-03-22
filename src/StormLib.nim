## ***************************************************************************
##  StormLib.h                        Copyright (c) Ladislav Zezula 1999-2010
## ---------------------------------------------------------------------------
##  StormLib library v 7.02
## 
##  Author : Ladislav Zezula
##  E-mail : ladik@zezula.net
##  WWW    : http://www.zezula.net
## ---------------------------------------------------------------------------
##    Date    Ver   Who  Comment
##  --------  ----  ---  -------
##  xx.xx.99  1.00  Lad  Created
##  24.03.03  2.50  Lad  Version 2.50
##  02.04.03  3.00  Lad  Version 3.00 with compression
##  11.04.03  3.01  Lad  Renamed to StormLib.h for compatibility with
##                       original headers for Storm.dll
##  10.05.03  3.02  Lad  Added Pkware DCL compression
##  26.05.03  4.00  Lad  Completed all compressions
##  18.06.03  4.01  Lad  Added SFileSetFileLocale
##                       Added SFileExtractFile
##  26.07.03  4.02  Lad  Implemented nameless rename and delete
##  26.07.03  4.03  Lad  Added support for protected MPQs
##  28.08.03  4.10  Lad  Fixed bugs that caused StormLib incorrectly work
##                       with Diablo I savegames and with files having full
##                       hash table
##  08.12.03  4.11  DCH  Fixed bug in reading file sector larger than 0x1000
##                       on certain files.
##                       Fixed bug in AddFile with MPQ_FILE_REPLACE_EXISTING
##                       (Thanx Daniel Chiamarello, dchiamarello@madvawes.com)
##  21.12.03  4.50  Lad  Completed port for Mac
##                       Fixed bug in compacting (if fsize is mul of 0x1000)
##                       Fixed bug in SCompCompress
##  27.05.04  4.51  Lad  Changed memory management from new/delete to our
##                       own macros
##  22.06.04  4.60  Lad  Optimized search. Support for multiple listfiles.
##  30.09.04  4.61  Lad  Fixed some bugs (Aaargh !!!)
##                       Correctly works if HashTableSize > BlockTableSize
##  29.12.04  4.70  Lad  Fixed compatibility problem with MPQs from WoW
##  14.07.05  5.00  Lad  Added the BZLIB compression support
##                       Added suport of files stored as single unit
##  17.04.06  5.01  Lad  Converted to MS Visual Studio 8.0
##                       Fixed issue with protected Warcraft 3 protected maps
##  15.05.06  5.02  Lad  Fixed issue with WoW 1.10+
##  07.09.06  5.10  Lad  Fixed processing files longer than 2GB
##  22.11.06  6.00  Lad  Support for MPQ archives V2
##  12.06.07  6.10  Lad  Support for (attributes) file
##  10.09.07  6.12  Lad  Support for MPQs protected by corrupting hash table
##  03.12.07  6.13  Lad  Support for MPQs with hash tbl size > block tbl size
##  07.04.08  6.20  Lad  Added SFileFlushArchive
##  09.04.08        Lad  Removed FilePointer variable from MPQ handle
##                       structure, as it caused more problems than benefits
##  12.05.08  6.22  Lad  Support for w3xMaster map protector
##  05.10.08  6.23  Lad  Support for protectors who set negative values in
##                       the table of file blocks
##  26.05.09  6.24  Lad  Fixed search for multiple lang files with deleted
##                       entries
##  03.09.09  6.25  Lad  Fixed decompression bug in huffmann decompression
##  22.03.10  6.50  Lad  New compressions in Starcraft II (LZMA, sparse)
##                       Fixed compacting MPQs that contain single unit files
##  26.04.10  7.00  Lad  Major rewrite
##  08.06.10  7.10  Lad  Support for partial MPQs
##  08.07.10  7.11  Lad  Support for MPQs v 3.0
##  20.08.10  7.20  Lad  Support for opening multiple MPQs in patch mode
##  20.09.10  8.00  Lad  MPQs v 4, HET and BET tables
##  07.01.11  8.01  Lad  Write support for MPQs v 3 and 4
##  15.09.11  8.04  Lad  Bug fixes, testing for Diablo III MPQs
##  26.04.12  8.10  Lad  Support for data map, added SFileGetArchiveBitmap
##  29.05.12  8.20  Lad  C-only interface
##  14.01.13  8.21  Lad  ADPCM and Huffmann (de)compression refactored
##  04.12.13  9.00  Lad  Unit tests, bug fixes
##  27.08.14  9.10  Lad  Signing archives with weak digital signature
##  25.11.14  9.11  Lad  Fixed bug reading & creating HET table
##  18.09.15  9.20  Lad  Release 9.20
##  12.12.16  9.20  Lad  Release 9.21
## ***************************************************************************

import "StormPort.nim"

## -----------------------------------------------------------------------------
##  Defines

const
  MD5_DIGEST_SIZE = 0x10

const
  STORMLIB_VERSION* = 0x00000915
  STORMLIB_VERSION_STRING* = "9.21"
  ID_MPQ* = 0x1A51504D
  ID_MPQ_USERDATA* = 0x1B51504D
  ID_MPK* = 0x1A4B504D
  ERROR_AVI_FILE* = 10000
  ERROR_UNKNOWN_FILE_KEY* = 10001
  ERROR_CHECKSUM_ERROR* = 10002
  ERROR_INTERNAL_FILE* = 10003
  ERROR_BASE_FILE_MISSING* = 10004
  ERROR_MARKED_FOR_DELETE* = 10005
  ERROR_FILE_INCOMPLETE* = 10006
  ERROR_UNKNOWN_FILE_NAMES* = 10007
  ERROR_CANT_FIND_PATCH_PREFIX* = 10008

##  Values for SFileCreateArchive

const
  HASH_TABLE_SIZE_MIN* = 0x00000004
  HASH_TABLE_SIZE_DEFAULT* = 0x00001000
  HASH_TABLE_SIZE_MAX* = 0x00080000
  HASH_ENTRY_DELETED* = 0xFFFFFFFE
  HASH_ENTRY_FREE* = 0xFFFFFFFF
  HET_ENTRY_DELETED* = 0x00000080
  HET_ENTRY_FREE* = 0x00000000
  HASH_STATE_SIZE* = 0x00000060

##  Values for SFileOpenArchive

const
  SFILE_OPEN_HARD_DISK_FILE* = 2
  SFILE_OPEN_CDROM_FILE* = 3

##  Values for SFileOpenFile

const
  SFILE_OPEN_FROM_MPQ* = 0x00000000
  SFILE_OPEN_CHECK_EXISTS* = 0xFFFFFFFC
  SFILE_OPEN_BASE_FILE* = 0xFFFFFFFD
  SFILE_OPEN_ANY_LOCALE* = 0xFFFFFFFE
  SFILE_OPEN_LOCAL_FILE* = 0xFFFFFFFF

##  Flags for TMPQArchive::dwFlags

const
  MPQ_FLAG_READ_ONLY* = 0x00000001
  MPQ_FLAG_CHANGED* = 0x00000002
  MPQ_FLAG_MALFORMED* = 0x00000004
  MPQ_FLAG_HASH_TABLE_CUT* = 0x00000008
  MPQ_FLAG_BLOCK_TABLE_CUT* = 0x00000010
  MPQ_FLAG_CHECK_SECTOR_CRC* = 0x00000020
  MPQ_FLAG_SAVING_TABLES* = 0x00000040
  MPQ_FLAG_PATCH* = 0x00000080
  MPQ_FLAG_WAR3_MAP* = 0x00000100
  MPQ_FLAG_LISTFILE_NONE* = 0x00000200
  MPQ_FLAG_LISTFILE_NEW* = 0x00000400
  MPQ_FLAG_ATTRIBUTES_NONE* = 0x00000800
  MPQ_FLAG_ATTRIBUTES_NEW* = 0x00001000
  MPQ_FLAG_SIGNATURE_NONE* = 0x00002000
  MPQ_FLAG_SIGNATURE_NEW* = 0x00004000

##  Values for TMPQArchive::dwSubType

const
  MPQ_SUBTYPE_MPQ* = 0x00000000
  MPQ_SUBTYPE_SQP* = 0x00000001
  MPQ_SUBTYPE_MPK* = 0x00000002

##  Return value for SFileGetFileSize and SFileSetFilePointer

const
  SFILE_INVALID_SIZE* = 0xFFFFFFFF
  SFILE_INVALID_POS* = 0xFFFFFFFF
  SFILE_INVALID_ATTRIBUTES* = 0xFFFFFFFF

##  Flags for SFileAddFile

const
  MPQ_FILE_IMPLODE* = 0x00000100
  MPQ_FILE_COMPRESS* = 0x00000200
  MPQ_FILE_ENCRYPTED* = 0x00010000
  MPQ_FILE_FIX_KEY* = 0x00020000
  MPQ_FILE_PATCH_FILE* = 0x00100000
  MPQ_FILE_SINGLE_UNIT* = 0x01000000
  MPQ_FILE_DELETE_MARKER* = 0x02000000
  MPQ_FILE_SECTOR_CRC* = 0x04000000
  MPQ_FILE_SIGNATURE* = 0x10000000
  MPQ_FILE_EXISTS* = 0x80000000
  MPQ_FILE_REPLACEEXISTING* = 0x80000000
  MPQ_FILE_COMPRESS_MASK* = 0x0000FF00
  MPQ_FILE_VALID_FLAGS* = (MPQ_FILE_IMPLODE or MPQ_FILE_COMPRESS or
      MPQ_FILE_ENCRYPTED or MPQ_FILE_FIX_KEY or MPQ_FILE_PATCH_FILE or
      MPQ_FILE_SINGLE_UNIT or MPQ_FILE_DELETE_MARKER or MPQ_FILE_SECTOR_CRC or
      MPQ_FILE_SIGNATURE or MPQ_FILE_EXISTS)

##  We need to mask out the upper 4 bits of the block table index.
##  This is because it gets shifted out when calculating block table offset
##  BlockTableOffset = pHash->dwBlockIndex << 0x04
##  Malformed MPQ maps may contain block indexes like 0x40000001 or 0xF0000023

const
  BLOCK_INDEX_MASK* = 0x0FFFFFFF

template MPQ_BLOCK_INDEX*(pHash: untyped): untyped =
  (pHash.dwBlockIndex and BLOCK_INDEX_MASK)

##  Compression types for multiple compressions

const
  MPQ_COMPRESSION_HUFFMANN* = 0x00000001
  MPQ_COMPRESSION_ZLIB* = 0x00000002
  MPQ_COMPRESSION_PKWARE* = 0x00000008
  MPQ_COMPRESSION_BZIP2* = 0x00000010
  MPQ_COMPRESSION_SPARSE* = 0x00000020
  MPQ_COMPRESSION_ADPCM_MONO* = 0x00000040
  MPQ_COMPRESSION_ADPCM_STEREO* = 0x00000080
  MPQ_COMPRESSION_LZMA* = 0x00000012
  MPQ_COMPRESSION_NEXT_SAME* = 0xFFFFFFFF

##  Constants for SFileAddWave

const
  MPQ_WAVE_QUALITY_HIGH* = 0
  MPQ_WAVE_QUALITY_MEDIUM* = 1
  MPQ_WAVE_QUALITY_LOW* = 2

##  Signatures for HET and BET table

const
  HET_TABLE_SIGNATURE* = 0x1A544548
  BET_TABLE_SIGNATURE* = 0x1A544542

##  Decryption keys for MPQ tables

const
  MPQ_KEY_HASH_TABLE* = 0xC3AF3770
  MPQ_KEY_BLOCK_TABLE* = 0xEC83B3A3
  LISTFILE_NAME* = "(listfile)"
  SIGNATURE_NAME* = "(signature)"
  ATTRIBUTES_NAME* = "(attributes)"
  PATCH_METADATA_NAME* = "(patch_metadata)"
  MPQ_FORMAT_VERSION_1* = 0
  MPQ_FORMAT_VERSION_2* = 1
  MPQ_FORMAT_VERSION_3* = 2
  MPQ_FORMAT_VERSION_4* = 3

##  Flags for MPQ attributes

const
  MPQ_ATTRIBUTE_CRC32* = 0x00000001
  MPQ_ATTRIBUTE_FILETIME* = 0x00000002
  MPQ_ATTRIBUTE_MD5* = 0x00000004
  MPQ_ATTRIBUTE_PATCH_BIT* = 0x00000008
  MPQ_ATTRIBUTE_ALL* = 0x0000000F
  MPQ_ATTRIBUTES_V1* = 100

##  Flags for SFileOpenArchive

const
  BASE_PROVIDER_FILE* = 0x00000000
  BASE_PROVIDER_MAP* = 0x00000001
  BASE_PROVIDER_HTTP* = 0x00000002
  BASE_PROVIDER_MASK* = 0x0000000F
  STREAM_PROVIDER_FLAT* = 0x00000000
  STREAM_PROVIDER_PARTIAL* = 0x00000010
  STREAM_PROVIDER_MPQE* = 0x00000020
  STREAM_PROVIDER_BLOCK4* = 0x00000030
  STREAM_PROVIDER_MASK* = 0x000000F0
  STREAM_FLAG_READ_ONLY* = 0x00000100
  STREAM_FLAG_WRITE_SHARE* = 0x00000200
  STREAM_FLAG_USE_BITMAP* = 0x00000400
  STREAM_OPTIONS_MASK* = 0x0000FF00
  STREAM_PROVIDERS_MASK* = 0x000000FF
  STREAM_FLAGS_MASK* = 0x0000FFFF
  MPQ_OPEN_NO_LISTFILE* = 0x00010000
  MPQ_OPEN_NO_ATTRIBUTES* = 0x00020000
  MPQ_OPEN_NO_HEADER_SEARCH* = 0x00040000
  MPQ_OPEN_FORCE_MPQ_V1* = 0x00080000
  MPQ_OPEN_CHECK_SECTOR_CRC* = 0x00100000
  MPQ_OPEN_PATCH* = 0x00200000
  MPQ_OPEN_READ_ONLY* = STREAM_FLAG_READ_ONLY

##  Flags for SFileCreateArchive

const
  MPQ_CREATE_LISTFILE* = 0x00100000
  MPQ_CREATE_ATTRIBUTES* = 0x00200000
  MPQ_CREATE_SIGNATURE* = 0x00400000
  MPQ_CREATE_ARCHIVE_V1* = 0x00000000
  MPQ_CREATE_ARCHIVE_V2* = 0x01000000
  MPQ_CREATE_ARCHIVE_V3* = 0x02000000
  MPQ_CREATE_ARCHIVE_V4* = 0x03000000
  MPQ_CREATE_ARCHIVE_VMASK* = 0x0F000000
  FLAGS_TO_FORMAT_SHIFT* = 24

##  Flags for SFileVerifyFile

const
  SFILE_VERIFY_SECTOR_CRC* = 0x00000001
  SFILE_VERIFY_FILE_CRC* = 0x00000002
  SFILE_VERIFY_FILE_MD5* = 0x00000004
  SFILE_VERIFY_RAW_MD5* = 0x00000008
  SFILE_VERIFY_ALL* = 0x0000000F

##  Return values for SFileVerifyFile

const
  VERIFY_OPEN_ERROR* = 0x00000001
  VERIFY_READ_ERROR* = 0x00000002
  VERIFY_FILE_HAS_SECTOR_CRC* = 0x00000004
  VERIFY_FILE_SECTOR_CRC_ERROR* = 0x00000008
  VERIFY_FILE_HAS_CHECKSUM* = 0x00000010
  VERIFY_FILE_CHECKSUM_ERROR* = 0x00000020
  VERIFY_FILE_HAS_MD5* = 0x00000040
  VERIFY_FILE_MD5_ERROR* = 0x00000080
  VERIFY_FILE_HAS_RAW_MD5* = 0x00000100
  VERIFY_FILE_RAW_MD5_ERROR* = 0x00000200
  VERIFY_FILE_ERROR_MASK* = (VERIFY_OPEN_ERROR or VERIFY_READ_ERROR or
      VERIFY_FILE_SECTOR_CRC_ERROR or VERIFY_FILE_CHECKSUM_ERROR or
      VERIFY_FILE_MD5_ERROR or VERIFY_FILE_RAW_MD5_ERROR)

##  Flags for SFileVerifyRawData (for MPQs version 4.0 or higher)

const
  SFILE_VERIFY_MPQ_HEADER* = 0x00000001
  SFILE_VERIFY_HET_TABLE* = 0x00000002
  SFILE_VERIFY_BET_TABLE* = 0x00000003
  SFILE_VERIFY_HASH_TABLE* = 0x00000004
  SFILE_VERIFY_BLOCK_TABLE* = 0x00000005
  SFILE_VERIFY_HIBLOCK_TABLE* = 0x00000006
  SFILE_VERIFY_FILE_FLAG* {.importc: "SFILE_VERIFY_FILE", header: "StormLib.h".} = 0x00000007

##  Signature types

const
  SIGNATURE_TYPE_NONE* = 0x00000000
  SIGNATURE_TYPE_WEAK* = 0x00000001
  SIGNATURE_TYPE_STRONG* = 0x00000002

##  Return values for SFileVerifyArchive

const
  ERROR_NO_SIGNATURE* = 0
  ERROR_VERIFY_FAILED* = 1
  ERROR_WEAK_SIGNATURE_OK* = 2
  ERROR_WEAK_SIGNATURE_ERROR* = 3
  ERROR_STRONG_SIGNATURE_OK* = 4
  ERROR_STRONG_SIGNATURE_ERROR* = 5

##  Pointer to hashing function

type
  TFileStream* = distinct object

type
  HASH_STRING* = proc (szFileName: cstring; dwHashType: DWORD): DWORD

## -----------------------------------------------------------------------------
##  File information classes for SFileGetFileInfo and SFileFreeFileInfo

type                          ##  Info classes for archives
  SFileInfoClass* {.size: sizeof(cint), importcpp: "SFileInfoClass",
                   header: "StormLib.h".} = enum
    SFileMpqFileName,         ##  Name of the archive file (TCHAR [])
    SFileMpqStreamBitmap,     ##  Array of bits, each bit means availability of one block (BYTE [])
    SFileMpqUserDataOffset,   ##  Offset of the user data header (ULONGLONG)
    SFileMpqUserDataHeader,   ##  Raw (unfixed) user data header (TMPQUserData)
    SFileMpqUserData,         ##  MPQ USer data, without the header (BYTE [])
    SFileMpqHeaderOffset,     ##  Offset of the MPQ header (ULONGLONG)
    SFileMpqHeaderSize,       ##  Fixed size of the MPQ header
    SFileMpqHeader,           ##  Raw (unfixed) archive header (TMPQHeader)
    SFileMpqHetTableOffset,   ##  Offset of the HET table, relative to MPQ header (ULONGLONG)
    SFileMpqHetTableSize,     ##  Compressed size of the HET table (ULONGLONG)
    SFileMpqHetHeader,        ##  HET table header (TMPQHetHeader)
    SFileMpqHetTable,         ##  HET table as pointer. Must be freed using SFileFreeFileInfo
    SFileMpqBetTableOffset,   ##  Offset of the BET table, relative to MPQ header (ULONGLONG)
    SFileMpqBetTableSize,     ##  Compressed size of the BET table (ULONGLONG)
    SFileMpqBetHeader,        ##  BET table header, followed by the flags (TMPQBetHeader + DWORD[])
    SFileMpqBetTable,         ##  BET table as pointer. Must be freed using SFileFreeFileInfo
    SFileMpqHashTableOffset,  ##  Hash table offset, relative to MPQ header (ULONGLONG)
    SFileMpqHashTableSize64,  ##  Compressed size of the hash table (ULONGLONG)
    SFileMpqHashTableSize,    ##  Size of the hash table, in entries (DWORD)
    SFileMpqHashTable,        ##  Raw (unfixed) hash table (TMPQBlock [])
    SFileMpqBlockTableOffset, ##  Block table offset, relative to MPQ header (ULONGLONG)
    SFileMpqBlockTableSize64, ##  Compressed size of the block table (ULONGLONG)
    SFileMpqBlockTableSize,   ##  Size of the block table, in entries (DWORD)
    SFileMpqBlockTable,       ##  Raw (unfixed) block table (TMPQBlock [])
    SFileMpqHiBlockTableOffset, ##  Hi-block table offset, relative to MPQ header (ULONGLONG)
    SFileMpqHiBlockTableSize64, ##  Compressed size of the hi-block table (ULONGLONG)
    SFileMpqHiBlockTable,     ##  The hi-block table (USHORT [])
    SFileMpqSignatures,       ##  Signatures present in the MPQ (DWORD)
    SFileMpqStrongSignatureOffset, ##  Byte offset of the strong signature, relative to begin of the file (ULONGLONG)
    SFileMpqStrongSignatureSize, ##  Size of the strong signature (DWORD)
    SFileMpqStrongSignature,  ##  The strong signature (BYTE [])
    SFileMpqArchiveSize64,    ##  Archive size from the header (ULONGLONG)
    SFileMpqArchiveSize,      ##  Archive size from the header (DWORD)
    SFileMpqMaxFileCount,     ##  Max number of files in the archive (DWORD)
    SFileMpqFileTableSize,    ##  Number of entries in the file table (DWORD)
    SFileMpqSectorSize,       ##  Sector size (DWORD)
    SFileMpqNumberOfFiles,    ##  Number of files (DWORD)
    SFileMpqRawChunkSize,     ##  Size of the raw data chunk for MD5
    SFileMpqStreamFlags,      ##  Stream flags (DWORD)
    SFileMpqFlags,            ##  Nonzero if the MPQ is read only (DWORD)
                  ##  Info classes for files
    SFileInfoPatchChain,      ##  Chain of patches where the file is (TCHAR [])
    SFileInfoFileEntry,       ##  The file entry for the file (TFileEntry)
    SFileInfoHashEntry,       ##  Hash table entry for the file (TMPQHash)
    SFileInfoHashIndex,       ##  Index of the hash table entry (DWORD)
    SFileInfoNameHash1,       ##  The first name hash in the hash table (DWORD)
    SFileInfoNameHash2,       ##  The second name hash in the hash table (DWORD)
    SFileInfoNameHash3,       ##  64-bit file name hash for the HET/BET tables (ULONGLONG)
    SFileInfoLocale,          ##  File locale (DWORD)
    SFileInfoFileIndex,       ##  Block index (DWORD)
    SFileInfoByteOffset,      ##  File position in the archive (ULONGLONG)
    SFileInfoFileTime,        ##  File time (ULONGLONG)
    SFileInfoFileSize,        ##  Size of the file (DWORD)
    SFileInfoCompressedSize,  ##  Compressed file size (DWORD)
    SFileInfoFlags,           ##  File flags from (DWORD)
    SFileInfoEncryptionKey,   ##  File encryption key
    SFileInfoEncryptionKeyRaw, ##  Unfixed value of the file key
    SFileInfoCRC32            ##  CRC32 of the file


## -----------------------------------------------------------------------------
##  Callback functions
##  Values for compact callback

const
  CCB_CHECKING_FILES* = 1
  CCB_CHECKING_HASH_TABLE* = 2
  CCB_COPYING_NON_MPQ_DATA* = 3
  CCB_COMPACTING_FILES* = 4
  CCB_CLOSING_ARCHIVE* = 5

type
  SFILE_DOWNLOAD_CALLBACK* = proc (pvUserData: pointer; ByteOffset: ULONGLONG;
                                dwTotalBytes: DWORD)
  SFILE_ADDFILE_CALLBACK* = proc (pvUserData: pointer; dwBytesWritten: DWORD;
                               dwTotalBytes: DWORD; bFinalCall: bool)
  SFILE_COMPACT_CALLBACK* = proc (pvUserData: pointer; dwWorkType: DWORD;
                               BytesProcessed: ULONGLONG; TotalBytes: ULONGLONG)

## -----------------------------------------------------------------------------
##  Structure for bit arrays used for HET and BET tables

type
  TBitArray* {.importcpp: "TBitArray", header: "StormLib.h".} = object
    NumberOfBytes* {.importc: "NumberOfBytes".}: DWORD ##  Total number of bytes in "Elements"
    NumberOfBits* {.importc: "NumberOfBits".}: DWORD ##  Total number of bits that are available
    Elements* {.importc: "Elements".}: array[1, BYTE] ##  Array of elements (variable length)
  

proc GetBits*(array: ptr TBitArray; nBitPosition: cuint; nBitLength: cuint;
             pvBuffer: pointer; nResultSize: cint) {.importcpp: "GetBits(@)",
    header: "StormLib.h".}
proc SetBits*(array: ptr TBitArray; nBitPosition: cuint; nBitLength: cuint;
             pvBuffer: pointer; nResultSize: cint) {.importcpp: "SetBits(@)",
    header: "StormLib.h".}
## -----------------------------------------------------------------------------
##  Structures related to MPQ format
## 
##  Note: All structures in this header file are supposed to remain private
##  to StormLib. The structures may (and will) change over time, as the MPQ
##  file format evolves. Programmers directly using these structures need to
##  be aware of this. And the last, but not least, NEVER do any modifications
##  to those structures directly, always use SFile* functions.
## 

const
  MPQ_HEADER_SIZE_V1* = 0x00000020
  MPQ_HEADER_SIZE_V2* = 0x0000002C
  MPQ_HEADER_SIZE_V3* = 0x00000044
  MPQ_HEADER_SIZE_V4* = 0x000000D0
  MPQ_HEADER_DWORDS* = (MPQ_HEADER_SIZE_V4 div 0x00000004)

type
  TMPQUserData* {.importcpp: "TMPQUserData", header: "StormLib.h".} = object
    dwID* {.importc: "dwID".}: DWORD ##  The ID_MPQ_USERDATA ('MPQ\x1B') signature
    ##  Maximum size of the user data
    cbUserDataSize* {.importc: "cbUserDataSize".}: DWORD ##  Offset of the MPQ header, relative to the begin of this header
    dwHeaderOffs* {.importc: "dwHeaderOffs".}: DWORD ##  Appears to be size of user data header (Starcraft II maps)
    cbUserDataHeader* {.importc: "cbUserDataHeader".}: DWORD


##  MPQ file header
## 
##  We have to make sure that the header is packed OK.
##  Reason: A 64-bit integer at the beginning of 3.0 part,
##  which is offset 0x2C

type
  TMPQHeader* {.importcpp: "TMPQHeader", header: "StormLib.h".} = object
    dwID* {.importc: "dwID".}: DWORD ##  The ID_MPQ ('MPQ\x1A') signature
    ##  Size of the archive header
    dwHeaderSize* {.importc: "dwHeaderSize".}: DWORD ##  32-bit size of MPQ archive
                                                 ##  This field is deprecated in the Burning Crusade MoPaQ format, and the size of the archive
                                                 ##  is calculated as the size from the beginning of the archive to the end of the hash table,
                                                 ##  block table, or hi-block table (whichever is largest).
    dwArchiveSize* {.importc: "dwArchiveSize".}: DWORD ##  0 = Format 1 (up to The Burning Crusade)
                                                   ##  1 = Format 2 (The Burning Crusade and newer)
                                                   ##  2 = Format 3 (WoW - Cataclysm beta or newer)
                                                   ##  3 = Format 4 (WoW - Cataclysm beta or newer)
    wFormatVersion* {.importc: "wFormatVersion".}: USHORT ##  Power of two exponent specifying the number of 512-byte disk sectors in each file sector
                                                      ##  in the archive. The size of each file sector in the archive is 512 * 2 ^ wSectorSize.
    wSectorSize* {.importc: "wSectorSize".}: USHORT ##  Offset to the beginning of the hash table, relative to the beginning of the archive.
    dwHashTablePos* {.importc: "dwHashTablePos".}: DWORD ##  Offset to the beginning of the block table, relative to the beginning of the archive.
    dwBlockTablePos* {.importc: "dwBlockTablePos".}: DWORD ##  Number of entries in the hash table. Must be a power of two, and must be less than 2^16 for
                                                       ##  the original MoPaQ format, or less than 2^20 for the Burning Crusade format.
    dwHashTableSize* {.importc: "dwHashTableSize".}: DWORD ##  Number of entries in the block table
    dwBlockTableSize* {.importc: "dwBlockTableSize".}: DWORD ## -- MPQ HEADER v 2 -------------------------------------------
                                                         ##  Offset to the beginning of array of 16-bit high parts of file offsets.
    HiBlockTablePos64* {.importc: "HiBlockTablePos64".}: ULONGLONG ##  High 16 bits of the hash table offset for large archives.
    wHashTablePosHi* {.importc: "wHashTablePosHi".}: USHORT ##  High 16 bits of the block table offset for large archives.
    wBlockTablePosHi* {.importc: "wBlockTablePosHi".}: USHORT ## -- MPQ HEADER v 3 -------------------------------------------
                                                          ##  64-bit version of the archive size
    ArchiveSize64* {.importc: "ArchiveSize64".}: ULONGLONG ##  64-bit position of the BET table
    BetTablePos64* {.importc: "BetTablePos64".}: ULONGLONG ##  64-bit position of the HET table
    HetTablePos64* {.importc: "HetTablePos64".}: ULONGLONG ## -- MPQ HEADER v 4 -------------------------------------------
                                                       ##  Compressed size of the hash table
    HashTableSize64* {.importc: "HashTableSize64".}: ULONGLONG ##  Compressed size of the block table
    BlockTableSize64* {.importc: "BlockTableSize64".}: ULONGLONG ##  Compressed size of the hi-block table
    HiBlockTableSize64* {.importc: "HiBlockTableSize64".}: ULONGLONG ##  Compressed size of the HET block
    HetTableSize64* {.importc: "HetTableSize64".}: ULONGLONG ##  Compressed size of the BET block
    BetTableSize64* {.importc: "BetTableSize64".}: ULONGLONG ##  Size of raw data chunk to calculate MD5.
                                                         ##  MD5 of each data chunk follows the raw file data.
    dwRawChunkSize* {.importc: "dwRawChunkSize".}: DWORD ##  MD5 of MPQ tables
    MD5_BlockTable* {.importc: "MD5_BlockTable".}: array[MD5_DIGEST_SIZE, cuchar] ##  MD5 of the block table before decryption
    MD5_HashTable* {.importc: "MD5_HashTable".}: array[MD5_DIGEST_SIZE, cuchar] ##  MD5 of the hash table before decryption
    MD5_HiBlockTable* {.importc: "MD5_HiBlockTable".}: array[MD5_DIGEST_SIZE, cuchar] ##  MD5 of the hi-block table
    MD5_BetTable* {.importc: "MD5_BetTable".}: array[MD5_DIGEST_SIZE, cuchar] ##  MD5 of the BET table before decryption
    MD5_HetTable* {.importc: "MD5_HetTable".}: array[MD5_DIGEST_SIZE, cuchar] ##  MD5 of the HET table before decryption
    MD5_MpqHeader* {.importc: "MD5_MpqHeader".}: array[MD5_DIGEST_SIZE, cuchar] ##  MD5 of the MPQ header from signature to (including) MD5_HetTable
  

##  Hash table entry. All files in the archive are searched by their hashes.

type
  TMPQHash* {.importcpp: "TMPQHash", header: "StormLib.h".} = object
    dwName1* {.importc: "dwName1".}: DWORD ##  The hash of the file path, using method A.
    ##  The hash of the file path, using method B.
    dwName2* {.importc: "dwName2".}: DWORD
    when defined(PLATFORM_LITTLE_ENDIAN):
      ##  The language of the file. This is a Windows LANGID data type, and uses the same values.
      ##  0 indicates the default language (American English), or that the file is language-neutral.
      lcLocale* {.importc: "lcLocale".}: USHORT
      ##  The platform the file is used for. 0 indicates the default platform.
      ##  No other values have been observed.
      Platform* {.importc: "Platform".}: BYTE
      Reserved* {.importc: "Reserved".}: BYTE
    else:
      Platform* {.importc: "Platform".}: BYTE
      Reserved* {.importc: "Reserved".}: BYTE
      lcLocale* {.importc: "lcLocale".}: USHORT
    dwBlockIndex* {.importc: "dwBlockIndex".}: DWORD 
    ##  
    ##        If the hash table entry is valid, this is the index into the block table of the file.
    ##        Otherwise, one of the following two values:
    ##         - FFFFFFFFh: Hash table entry is empty, and has always been empty.
    ##                      Terminates searches for a given file.
    ##         - FFFFFFFEh: Hash table entry is empty, but was valid at some point (a deleted file).
    ##                      Does not terminate searches for a given file.
    ## 
  

##  File description block contains informations about the file

type
  TMPQBlock* {.importcpp: "TMPQBlock", header: "StormLib.h".} = object
    dwFilePos* {.importc: "dwFilePos".}: DWORD ##  Offset of the beginning of the file, relative to the beginning of the archive.
    ##  Compressed file size
    dwCSize* {.importc: "dwCSize".}: DWORD ##  Only valid if the block is a file; otherwise meaningless, and should be 0.
                                       ##  If the file is compressed, this is the size of the uncompressed file data.
    dwFSize* {.importc: "dwFSize".}: DWORD ##  Flags for the file. See MPQ_FILE_XXXX constants
    dwFlags* {.importc: "dwFlags".}: DWORD


##  Patch file information, preceding the sector offset table

type
  TPatchInfo* {.importcpp: "TPatchInfo", header: "StormLib.h".} = object
    dwLength* {.importc: "dwLength".}: DWORD ##  Length of patch info header, in bytes
    dwFlags* {.importc: "dwFlags".}: DWORD ##  Flags. 0x80000000 = MD5 (?)
    dwDataSize* {.importc: "dwDataSize".}: DWORD ##  Uncompressed size of the patch file
    md5* {.importc: "md5".}: array[0x00000010, BYTE] ##  MD5 of the entire patch file after decompression
                                                ##  Followed by the sector table (variable length)
  

##  This is the combined file entry for maintaining file list in the MPQ.
##  This structure is combined from block table, hi-block table,
##  (attributes) file and from (listfile).

type
  TFileEntry* {.importcpp: "TFileEntry", header: "StormLib.h".} = object
    FileNameHash* {.importc: "FileNameHash".}: ULONGLONG ##  Jenkins hash of the file name. Only used when the MPQ has BET table.
    ByteOffset* {.importc: "ByteOffset".}: ULONGLONG ##  Position of the file content in the MPQ, relative to the MPQ header
    FileTime* {.importc: "FileTime".}: ULONGLONG ##  FileTime from the (attributes) file. 0 if not present.
    dwFileSize* {.importc: "dwFileSize".}: DWORD ##  Decompressed size of the file
    dwCmpSize* {.importc: "dwCmpSize".}: DWORD ##  Compressed size of the file (i.e., size of the file data in the MPQ)
    dwFlags* {.importc: "dwFlags".}: DWORD ##  File flags (from block table)
    dwCrc32* {.importc: "dwCrc32".}: DWORD ##  CRC32 from (attributes) file. 0 if not present.
    md5* {.importc: "md5".}: array[MD5_DIGEST_SIZE, BYTE] ##  File MD5 from the (attributes) file. 0 if not present.
    szFileName* {.importc: "szFileName".}: cstring ##  File name. NULL if not known.
  

##  Common header for HET and BET tables

type
  TMPQExtHeader* {.importcpp: "TMPQExtHeader", header: "StormLib.h".} = object
    dwSignature* {.importc: "dwSignature".}: DWORD ##  'HET\x1A' or 'BET\x1A'
    dwVersion* {.importc: "dwVersion".}: DWORD ##  Version. Seems to be always 1
    dwDataSize* {.importc: "dwDataSize".}: DWORD ##  Size of the contained table
                                             ##  Followed by the table header
                                             ##  Followed by the table data
  

##  Structure for HET table header

type
  TMPQHetHeader* {.importcpp: "TMPQHetHeader", header: "StormLib.h".} = object
    ExtHdr* {.importc: "ExtHdr".}: TMPQExtHeader
    dwTableSize* {.importc: "dwTableSize".}: DWORD ##  Size of the entire HET table, including HET_TABLE_HEADER (in bytes)
    dwEntryCount* {.importc: "dwEntryCount".}: DWORD ##  Number of occupied entries in the HET table
    dwTotalCount* {.importc: "dwTotalCount".}: DWORD ##  Total number of entries in the HET table
    dwNameHashBitSize* {.importc: "dwNameHashBitSize".}: DWORD ##  Size of the name hash entry (in bits)
    dwIndexSizeTotal* {.importc: "dwIndexSizeTotal".}: DWORD ##  Total size of file index (in bits)
    dwIndexSizeExtra* {.importc: "dwIndexSizeExtra".}: DWORD ##  Extra bits in the file index
    dwIndexSize* {.importc: "dwIndexSize".}: DWORD ##  Effective size of the file index (in bits)
    dwIndexTableSize* {.importc: "dwIndexTableSize".}: DWORD ##  Size of the block index subtable (in bytes)
  

##  Structure for BET table header

type
  TMPQBetHeader* {.importcpp: "TMPQBetHeader", header: "StormLib.h".} = object
    ExtHdr* {.importc: "ExtHdr".}: TMPQExtHeader
    dwTableSize* {.importc: "dwTableSize".}: DWORD ##  Size of the entire BET table, including the header (in bytes)
    dwEntryCount* {.importc: "dwEntryCount".}: DWORD ##  Number of entries in the BET table. Must match HET_TABLE_HEADER::dwEntryCount
    dwUnknown08* {.importc: "dwUnknown08".}: DWORD
    dwTableEntrySize* {.importc: "dwTableEntrySize".}: DWORD ##  Size of one table entry (in bits)
    dwBitIndex_FilePos* {.importc: "dwBitIndex_FilePos".}: DWORD ##  Bit index of the file position (within the entry record)
    dwBitIndex_FileSize* {.importc: "dwBitIndex_FileSize".}: DWORD ##  Bit index of the file size (within the entry record)
    dwBitIndex_CmpSize* {.importc: "dwBitIndex_CmpSize".}: DWORD ##  Bit index of the compressed size (within the entry record)
    dwBitIndex_FlagIndex* {.importc: "dwBitIndex_FlagIndex".}: DWORD ##  Bit index of the flag index (within the entry record)
    dwBitIndex_Unknown* {.importc: "dwBitIndex_Unknown".}: DWORD ##  Bit index of the ??? (within the entry record)
    dwBitCount_FilePos* {.importc: "dwBitCount_FilePos".}: DWORD ##  Bit size of file position (in the entry record)
    dwBitCount_FileSize* {.importc: "dwBitCount_FileSize".}: DWORD ##  Bit size of file size (in the entry record)
    dwBitCount_CmpSize* {.importc: "dwBitCount_CmpSize".}: DWORD ##  Bit size of compressed file size (in the entry record)
    dwBitCount_FlagIndex* {.importc: "dwBitCount_FlagIndex".}: DWORD ##  Bit size of flags index (in the entry record)
    dwBitCount_Unknown* {.importc: "dwBitCount_Unknown".}: DWORD ##  Bit size of ??? (in the entry record)
    dwBitTotal_NameHash2* {.importc: "dwBitTotal_NameHash2".}: DWORD ##  Total bit size of the NameHash2
    dwBitExtra_NameHash2* {.importc: "dwBitExtra_NameHash2".}: DWORD ##  Extra bits in the NameHash2
    dwBitCount_NameHash2* {.importc: "dwBitCount_NameHash2".}: DWORD ##  Effective size of NameHash2 (in bits)
    dwNameHashArraySize* {.importc: "dwNameHashArraySize".}: DWORD ##  Size of NameHash2 table, in bytes
    dwFlagCount* {.importc: "dwFlagCount".}: DWORD ##  Number of flags in the following array
  

##  Structure for parsed HET table

type
  TMPQHetTable* {.importcpp: "TMPQHetTable", header: "StormLib.h".} = object
    pBetIndexes* {.importc: "pBetIndexes".}: ptr TBitArray ##  Bit array of FileIndex values
    pNameHashes* {.importc: "pNameHashes".}: LPBYTE ##  Array of NameHash1 values (NameHash1 = upper 8 bits of FileName hashe)
    AndMask64* {.importc: "AndMask64".}: ULONGLONG ##  AND mask used for calculating file name hash
    OrMask64* {.importc: "OrMask64".}: ULONGLONG ##  OR mask used for setting the highest bit of the file name hash
    dwEntryCount* {.importc: "dwEntryCount".}: DWORD ##  Number of occupied entries in the HET table
    dwTotalCount* {.importc: "dwTotalCount".}: DWORD ##  Number of entries in both NameHash and FileIndex table
    dwNameHashBitSize* {.importc: "dwNameHashBitSize".}: DWORD ##  Size of the name hash entry (in bits)
    dwIndexSizeTotal* {.importc: "dwIndexSizeTotal".}: DWORD ##  Total size of one entry in pBetIndexes (in bits)
    dwIndexSizeExtra* {.importc: "dwIndexSizeExtra".}: DWORD ##  Extra bits in the entry in pBetIndexes
    dwIndexSize* {.importc: "dwIndexSize".}: DWORD ##  Effective size of one entry in pBetIndexes (in bits)
  

##  Structure for parsed BET table

type
  TMPQBetTable* {.importcpp: "TMPQBetTable", header: "StormLib.h".} = object
    pNameHashes* {.importc: "pNameHashes".}: ptr TBitArray ##  Array of NameHash2 entries (lower 24 bits of FileName hash)
    pFileTable* {.importc: "pFileTable".}: ptr TBitArray ##  Bit-based file table
    pFileFlags* {.importc: "pFileFlags".}: LPDWORD ##  Array of file flags
    dwTableEntrySize* {.importc: "dwTableEntrySize".}: DWORD ##  Size of one table entry, in bits
    dwBitIndex_FilePos* {.importc: "dwBitIndex_FilePos".}: DWORD ##  Bit index of the file position in the table entry
    dwBitIndex_FileSize* {.importc: "dwBitIndex_FileSize".}: DWORD ##  Bit index of the file size in the table entry
    dwBitIndex_CmpSize* {.importc: "dwBitIndex_CmpSize".}: DWORD ##  Bit index of the compressed size in the table entry
    dwBitIndex_FlagIndex* {.importc: "dwBitIndex_FlagIndex".}: DWORD ##  Bit index of the flag index in the table entry
    dwBitIndex_Unknown* {.importc: "dwBitIndex_Unknown".}: DWORD ##  Bit index of ??? in the table entry
    dwBitCount_FilePos* {.importc: "dwBitCount_FilePos".}: DWORD ##  Size of file offset (in bits) within table entry
    dwBitCount_FileSize* {.importc: "dwBitCount_FileSize".}: DWORD ##  Size of file size (in bits) within table entry
    dwBitCount_CmpSize* {.importc: "dwBitCount_CmpSize".}: DWORD ##  Size of compressed file size (in bits) within table entry
    dwBitCount_FlagIndex* {.importc: "dwBitCount_FlagIndex".}: DWORD ##  Size of flag index (in bits) within table entry
    dwBitCount_Unknown* {.importc: "dwBitCount_Unknown".}: DWORD ##  Size of ??? (in bits) within table entry
    dwBitTotal_NameHash2* {.importc: "dwBitTotal_NameHash2".}: DWORD ##  Total size of the NameHash2
    dwBitExtra_NameHash2* {.importc: "dwBitExtra_NameHash2".}: DWORD ##  Extra bits in the NameHash2
    dwBitCount_NameHash2* {.importc: "dwBitCount_NameHash2".}: DWORD ##  Effective size of the NameHash2
    dwEntryCount* {.importc: "dwEntryCount".}: DWORD ##  Number of entries
    dwFlagCount* {.importc: "dwFlagCount".}: DWORD ##  Number of file flags in pFileFlags
  

##  Structure for patch prefix

type
  TMPQNamePrefix* {.importcpp: "TMPQNamePrefix", header: "StormLib.h".} = object
    nLength* {.importc: "nLength".}: csize ##  Length of this patch prefix. Can be 0
    szPatchPrefix* {.importc: "szPatchPrefix".}: array[1, char] ##  Patch name prefix (variable length). If not empty, it always starts with backslash.
  

##  Structure for name cache

type
  TMPQNameCache* {.importcpp: "TMPQNameCache", header: "StormLib.h".} = object
    FirstNameOffset* {.importc: "FirstNameOffset".}: DWORD ##  Offset of the first name in the name list (in bytes)
    FreeSpaceOffset* {.importc: "FreeSpaceOffset".}: DWORD ##  Offset of the first free byte in the name cache (in bytes)
    TotalCacheSize* {.importc: "TotalCacheSize".}: DWORD ##  Size, in bytes, of the cache. Includes wildcard
    SearchOffset* {.importc: "SearchOffset".}: DWORD ##  Used by SListFileFindFirstFile
                                                 ##  Followed by search mask (ASCIIZ, '\0' if none)
                                                 ##  Followed by name cache (ANSI multistring)
  

##  Archive handle structure

type
  TMPQArchive* {.importcpp: "TMPQArchive", header: "StormLib.h".} = object
    pStream* {.importc: "pStream".}: ptr TFileStream ##  Open stream for the MPQ
    UserDataPos* {.importc: "UserDataPos".}: ULONGLONG ##  Position of user data (relative to the begin of the file)
    MpqPos* {.importc: "MpqPos".}: ULONGLONG ##  MPQ header offset (relative to the begin of the file)
    FileSize* {.importc: "FileSize".}: ULONGLONG ##  Size of the file at the moment of file open
    haPatch* {.importc: "haPatch".}: ptr TMPQArchive ##  Pointer to patch archive, if any
    haBase* {.importc: "haBase".}: ptr TMPQArchive ##  Pointer to base ("previous version") archive, if any
    pPatchPrefix* {.importc: "pPatchPrefix".}: ptr TMPQNamePrefix ##  Patch prefix to precede names of patch files
    pUserData* {.importc: "pUserData".}: ptr TMPQUserData ##  MPQ user data (NULL if not present in the file)
    pHeader* {.importc: "pHeader".}: ptr TMPQHeader ##  MPQ file header
    pHashTable* {.importc: "pHashTable".}: ptr TMPQHash ##  Hash table
    pHetTable* {.importc: "pHetTable".}: ptr TMPQHetTable ##  HET table
    pFileTable* {.importc: "pFileTable".}: ptr TFileEntry ##  File table
    pfnHashString* {.importc: "pfnHashString".}: HASH_STRING ##  Hashing function that will convert the file name into hash
    UserData* {.importc: "UserData".}: TMPQUserData ##  MPQ user data. Valid only when ID_MPQ_USERDATA has been found
    HeaderData* {.importc: "HeaderData".}: array[MPQ_HEADER_DWORDS, DWORD] ##  Storage for MPQ header
    dwHETBlockSize* {.importc: "dwHETBlockSize".}: DWORD
    dwBETBlockSize* {.importc: "dwBETBlockSize".}: DWORD
    dwMaxFileCount* {.importc: "dwMaxFileCount".}: DWORD ##  Maximum number of files in the MPQ. Also total size of the file table.
    dwFileTableSize* {.importc: "dwFileTableSize".}: DWORD ##  Current size of the file table, e.g. index of the entry past the last occupied one
    dwReservedFiles* {.importc: "dwReservedFiles".}: DWORD ##  Number of entries reserved for internal MPQ files (listfile, attributes)
    dwSectorSize* {.importc: "dwSectorSize".}: DWORD ##  Default size of one file sector
    dwFileFlags1* {.importc: "dwFileFlags1".}: DWORD ##  Flags for (listfile)
    dwFileFlags2* {.importc: "dwFileFlags2".}: DWORD ##  Flags for (attributes)
    dwFileFlags3* {.importc: "dwFileFlags3".}: DWORD ##  Flags for (signature)
    dwAttrFlags* {.importc: "dwAttrFlags".}: DWORD ##  Flags for the (attributes) file, see MPQ_ATTRIBUTE_XXX
    dwFlags* {.importc: "dwFlags".}: DWORD ##  See MPQ_FLAG_XXXXX
    dwSubType* {.importc: "dwSubType".}: DWORD ##  See MPQ_SUBTYPE_XXX
    pfnAddFileCB* {.importc: "pfnAddFileCB".}: SFILE_ADDFILE_CALLBACK ##  Callback function for adding files
    pvAddFileUserData* {.importc: "pvAddFileUserData".}: pointer ##  User data thats passed to the callback
    pfnCompactCB* {.importc: "pfnCompactCB".}: SFILE_COMPACT_CALLBACK ##  Callback function for compacting the archive
    CompactBytesProcessed* {.importc: "CompactBytesProcessed".}: ULONGLONG ##  Amount of bytes that have been processed during a particular compact call
    CompactTotalBytes* {.importc: "CompactTotalBytes".}: ULONGLONG ##  Total amount of bytes to be compacted
    pvCompactUserData* {.importc: "pvCompactUserData".}: pointer ##  User data thats passed to the callback
  

##  File handle structure

type
  TMPQFile* {.importcpp: "TMPQFile", header: "StormLib.h".} = object
    pStream* {.importc: "pStream".}: ptr TFileStream ##  File stream. Only used on local files
    ha* {.importc: "ha".}: ptr TMPQArchive ##  Archive handle
    pHashEntry* {.importc: "pHashEntry".}: ptr TMPQHash ##  Pointer to hash table entry, if the file was open using hash table
    pFileEntry* {.importc: "pFileEntry".}: ptr TFileEntry ##  File entry for the file
    RawFilePos* {.importc: "RawFilePos".}: ULONGLONG ##  Offset in MPQ archive (relative to file begin)
    MpqFilePos* {.importc: "MpqFilePos".}: ULONGLONG ##  Offset in MPQ archive (relative to MPQ header)
    dwHashIndex* {.importc: "dwHashIndex".}: DWORD ##  Hash table index (0xFFFFFFFF if not used)
    dwFileKey* {.importc: "dwFileKey".}: DWORD ##  Decryption key
    dwFilePos* {.importc: "dwFilePos".}: DWORD ##  Current file position
    dwMagic* {.importc: "dwMagic".}: DWORD ##  'FILE'
    hfPatch* {.importc: "hfPatch".}: ptr TMPQFile ##  Pointer to opened patch file
    pPatchInfo* {.importc: "pPatchInfo".}: ptr TPatchInfo ##  Patch info block, preceding the sector table
    SectorOffsets* {.importc: "SectorOffsets".}: LPDWORD ##  Position of each file sector, relative to the begin of the file. Only for compressed files.
    SectorChksums* {.importc: "SectorChksums".}: LPDWORD ##  Array of sector checksums (either ADLER32 or MD5) values for each file sector
    pbFileData* {.importc: "pbFileData".}: LPBYTE ##  Data of the file (single unit files, patched files)
    cbFileData* {.importc: "cbFileData".}: DWORD ##  Size of file data
    dwCompression0* {.importc: "dwCompression0".}: DWORD ##  Compression that will be used on the first file sector
    dwSectorCount* {.importc: "dwSectorCount".}: DWORD ##  Number of sectors in the file
    dwPatchedFileSize* {.importc: "dwPatchedFileSize".}: DWORD ##  Size of patched file. Used when saving patch file to the MPQ
    dwDataSize* {.importc: "dwDataSize".}: DWORD ##  Size of data in the file (on patch files, this differs from file size in block table entry)
    pbFileSector* {.importc: "pbFileSector".}: LPBYTE ##  Last loaded file sector. For single unit files, entire file content
    dwSectorOffs* {.importc: "dwSectorOffs".}: DWORD ##  File position of currently loaded file sector
    dwSectorSize* {.importc: "dwSectorSize".}: DWORD ##  Size of the file sector. For single unit files, this is equal to the file size
    hctx* {.importc: "hctx".}: array[HASH_STATE_SIZE, cuchar] ##  Hash state for MD5. Used when saving file to MPQ
    dwCrc32* {.importc: "dwCrc32".}: DWORD ##  CRC32 value, used when saving file to MPQ
    nAddFileError* {.importc: "nAddFileError".}: cint ##  Result of the "Add File" operations
    bLoadedSectorCRCs* {.importc: "bLoadedSectorCRCs".}: bool ##  If true, we already tried to load sector CRCs
    bCheckSectorCRCs* {.importc: "bCheckSectorCRCs".}: bool ##  If true, then SFileReadFile will check sector CRCs when reading the file
    bIsWriteHandle* {.importc: "bIsWriteHandle".}: bool ##  If true, this handle has been created by SFileCreateFile
  

##  Structure for SFileFindFirstFile and SFileFindNextFile

type
  SFILE_FIND_DATA* {.importcpp: "SFILE_FIND_DATA", header: "StormLib.h".} = object
    cFileName* {.importc: "cFileName".}: array[MAX_PATH, char] ##  Full name of the found file
    szPlainName* {.importc: "szPlainName".}: cstring ##  Plain name of the found file
    dwHashIndex* {.importc: "dwHashIndex".}: DWORD ##  Hash table index for the file (HAH_ENTRY_FREE if no hash table)
    dwBlockIndex* {.importc: "dwBlockIndex".}: DWORD ##  Block table index for the file
    dwFileSize* {.importc: "dwFileSize".}: DWORD ##  File size in bytes
    dwFileFlags* {.importc: "dwFileFlags".}: DWORD ##  MPQ file flags
    dwCompSize* {.importc: "dwCompSize".}: DWORD ##  Compressed file size
    dwFileTimeLo* {.importc: "dwFileTimeLo".}: DWORD ##  Low 32-bits of the file time (0 if not present)
    dwFileTimeHi* {.importc: "dwFileTimeHi".}: DWORD ##  High 32-bits of the file time (0 if not present)
    lcLocale* {.importc: "lcLocale".}: LCID ##  Locale version
  
  PSFILE_FIND_DATA* = ptr SFILE_FIND_DATA
  SFILE_CREATE_MPQ* {.importcpp: "SFILE_CREATE_MPQ", header: "StormLib.h".} = object
    cbSize* {.importc: "cbSize".}: DWORD ##  Size of this structure, in bytes
    dwMpqVersion* {.importc: "dwMpqVersion".}: DWORD ##  Version of the MPQ to be created
    pvUserData* {.importc: "pvUserData".}: pointer ##  Reserved, must be NULL
    cbUserData* {.importc: "cbUserData".}: DWORD ##  Reserved, must be 0
    dwStreamFlags* {.importc: "dwStreamFlags".}: DWORD ##  Stream flags for creating the MPQ
    dwFileFlags1* {.importc: "dwFileFlags1".}: DWORD ##  File flags for (listfile). 0 = default
    dwFileFlags2* {.importc: "dwFileFlags2".}: DWORD ##  File flags for (attributes). 0 = default
    dwFileFlags3* {.importc: "dwFileFlags3".}: DWORD ##  File flags for (signature). 0 = default
    dwAttrFlags* {.importc: "dwAttrFlags".}: DWORD ##  Flags for the (attributes) file. If 0, no attributes will be created
    dwSectorSize* {.importc: "dwSectorSize".}: DWORD ##  Sector size for compressed files
    dwRawChunkSize* {.importc: "dwRawChunkSize".}: DWORD ##  Size of raw data chunk
    dwMaxFileCount* {.importc: "dwMaxFileCount".}: DWORD ##  File limit for the MPQ
  
  PSFILE_CREATE_MPQ* = ptr SFILE_CREATE_MPQ

## -----------------------------------------------------------------------------
##  Stream support - functions
##  Structure used by FileStream_GetBitmap

type
  TStreamBitmap* {.importcpp: "TStreamBitmap", header: "StormLib.h".} = object
    StreamSize* {.importc: "StreamSize".}: ULONGLONG ##  Size of the stream, in bytes
    BitmapSize* {.importc: "BitmapSize".}: DWORD ##  Size of the block map, in bytes
    BlockCount* {.importc: "BlockCount".}: DWORD ##  Number of blocks in the stream
    BlockSize* {.importc: "BlockSize".}: DWORD ##  Size of one block
    IsComplete* {.importc: "IsComplete".}: DWORD ##  Nonzero if the file is complete
                                             ##  Followed by the BYTE array, each bit means availability of one block
  

##  UNICODE versions of the file access functions

proc FileStream_CreateFile*(szFileName: ptr TCHAR; dwStreamFlags: DWORD): ptr TFileStream {.
    importcpp: "FileStream_CreateFile(@)", header: "StormLib.h".}
proc FileStream_OpenFile*(szFileName: ptr TCHAR; dwStreamFlags: DWORD): ptr TFileStream {.
    importcpp: "FileStream_OpenFile(@)", header: "StormLib.h".}
proc FileStream_GetFileName*(pStream: ptr TFileStream): ptr TCHAR {.
    importcpp: "FileStream_GetFileName(@)", header: "StormLib.h".}
proc FileStream_Prefix*(szFileName: ptr TCHAR; pdwProvider: ptr DWORD): csize {.
    importcpp: "FileStream_Prefix(@)", header: "StormLib.h".}
proc FileStream_SetCallback*(pStream: ptr TFileStream;
                            pfnCallback: SFILE_DOWNLOAD_CALLBACK;
                            pvUserData: pointer): bool {.
    importcpp: "FileStream_SetCallback(@)", header: "StormLib.h".}
proc FileStream_GetBitmap*(pStream: ptr TFileStream; pvBitmap: pointer;
                          cbBitmap: DWORD; pcbLengthNeeded: LPDWORD): bool {.
    importcpp: "FileStream_GetBitmap(@)", header: "StormLib.h".}
proc FileStream_Read*(pStream: ptr TFileStream; pByteOffset: ptr ULONGLONG;
                     pvBuffer: pointer; dwBytesToRead: DWORD): bool {.
    importcpp: "FileStream_Read(@)", header: "StormLib.h".}
proc FileStream_Write*(pStream: ptr TFileStream; pByteOffset: ptr ULONGLONG;
                      pvBuffer: pointer; dwBytesToWrite: DWORD): bool {.
    importcpp: "FileStream_Write(@)", header: "StormLib.h".}
proc FileStream_SetSize*(pStream: ptr TFileStream; NewFileSize: ULONGLONG): bool {.
    importcpp: "FileStream_SetSize(@)", header: "StormLib.h".}
proc FileStream_GetSize*(pStream: ptr TFileStream; pFileSize: ptr ULONGLONG): bool {.
    importcpp: "FileStream_GetSize(@)", header: "StormLib.h".}
proc FileStream_GetPos*(pStream: ptr TFileStream; pByteOffset: ptr ULONGLONG): bool {.
    importcpp: "FileStream_GetPos(@)", header: "StormLib.h".}
proc FileStream_GetTime*(pStream: ptr TFileStream; pFT: ptr ULONGLONG): bool {.
    importcpp: "FileStream_GetTime(@)", header: "StormLib.h".}
proc FileStream_GetFlags*(pStream: ptr TFileStream; pdwStreamFlags: LPDWORD): bool {.
    importcpp: "FileStream_GetFlags(@)", header: "StormLib.h".}
proc FileStream_Replace*(pStream: ptr TFileStream; pNewStream: ptr TFileStream): bool {.
    importcpp: "FileStream_Replace(@)", header: "StormLib.h".}
proc FileStream_Close*(pStream: ptr TFileStream) {.importcpp: "FileStream_Close(@)",
    header: "StormLib.h".}


## -----------------------------------------------------------------------------
##  Functions for manipulation with StormLib global flags

proc SFileGetLocale*(): LCID {.importcpp: "SFileGetLocale(@)", header: "StormLib.h".}
proc SFileSetLocale*(lcNewLocale: LCID): LCID {.importcpp: "SFileSetLocale(@)",
    header: "StormLib.h".}
## -----------------------------------------------------------------------------
##  Functions for archive manipulation

proc SFileOpenArchive*(szMpqName: ptr TCHAR; dwPriority: DWORD; dwFlags: DWORD;
                      phMpq: ptr HANDLE): bool {.importcpp: "SFileOpenArchive(@)",
    header: "StormLib.h".}
proc SFileCreateArchive*(szMpqName: ptr TCHAR; dwCreateFlags: DWORD;
                        dwMaxFileCount: DWORD; phMpq: ptr HANDLE): bool {.
    importcpp: "SFileCreateArchive(@)", header: "StormLib.h".}
proc SFileCreateArchive2*(szMpqName: ptr TCHAR; pCreateInfo: PSFILE_CREATE_MPQ;
                         phMpq: ptr HANDLE): bool {.
    importcpp: "SFileCreateArchive2(@)", header: "StormLib.h".}
proc SFileSetDownloadCallback*(hMpq: HANDLE; DownloadCB: SFILE_DOWNLOAD_CALLBACK;
                              pvUserData: pointer): bool {.
    importcpp: "SFileSetDownloadCallback(@)", header: "StormLib.h".}
proc SFileFlushArchive*(hMpq: HANDLE): bool {.importcpp: "SFileFlushArchive(@)",
    header: "StormLib.h".}
proc SFileCloseArchive*(hMpq: HANDLE): bool {.importcpp: "SFileCloseArchive(@)",
    header: "StormLib.h".}
##  Adds another listfile into MPQ. The currently added listfile(s) remain,
##  so you can use this API to combining more listfiles.
##  Note that this function is internally called by SFileFindFirstFile

proc SFileAddListFile*(hMpq: HANDLE; szListFile: cstring): cint {.
    importcpp: "SFileAddListFile(@)", header: "StormLib.h".}
##  Archive compacting

proc SFileSetCompactCallback*(hMpq: HANDLE; CompactCB: SFILE_COMPACT_CALLBACK;
                             pvUserData: pointer): bool {.
    importcpp: "SFileSetCompactCallback(@)", header: "StormLib.h".}
proc SFileCompactArchive*(hMpq: HANDLE; szListFile: cstring; bReserved: bool): bool {.
    importcpp: "SFileCompactArchive(@)", header: "StormLib.h".}
##  Changing the maximum file count

proc SFileGetMaxFileCount*(hMpq: HANDLE): DWORD {.
    importcpp: "SFileGetMaxFileCount(@)", header: "StormLib.h".}
proc SFileSetMaxFileCount*(hMpq: HANDLE; dwMaxFileCount: DWORD): bool {.
    importcpp: "SFileSetMaxFileCount(@)", header: "StormLib.h".}
##  Changing (attributes) file

proc SFileGetAttributes*(hMpq: HANDLE): DWORD {.importcpp: "SFileGetAttributes(@)",
    header: "StormLib.h".}
proc SFileSetAttributes*(hMpq: HANDLE; dwFlags: DWORD): bool {.
    importcpp: "SFileSetAttributes(@)", header: "StormLib.h".}
proc SFileUpdateFileAttributes*(hMpq: HANDLE; szFileName: cstring): bool {.
    importcpp: "SFileUpdateFileAttributes(@)", header: "StormLib.h".}
## -----------------------------------------------------------------------------
##  Functions for manipulation with patch archives

proc SFileOpenPatchArchive*(hMpq: HANDLE; szPatchMpqName: ptr TCHAR;
                           szPatchPathPrefix: cstring; dwFlags: DWORD): bool {.
    importcpp: "SFileOpenPatchArchive(@)", header: "StormLib.h".}
proc SFileIsPatchedArchive*(hMpq: HANDLE): bool {.
    importcpp: "SFileIsPatchedArchive(@)", header: "StormLib.h".}
## -----------------------------------------------------------------------------
##  Functions for file manipulation
##  Reading from MPQ file

proc SFileHasFile*(hMpq: HANDLE; szFileName: cstring): bool {.
    importcpp: "SFileHasFile(@)", header: "StormLib.h".}
proc SFileOpenFileEx*(hMpq: HANDLE; szFileName: cstring; dwSearchScope: DWORD;
                     phFile: ptr HANDLE): bool {.importcpp: "SFileOpenFileEx(@)",
    header: "StormLib.h".}
proc SFileGetFileSize*(hFile: HANDLE; pdwFileSizeHigh: LPDWORD): DWORD {.
    importcpp: "SFileGetFileSize(@)", header: "StormLib.h".}
proc SFileSetFilePointer*(hFile: HANDLE; lFilePos: LONG; plFilePosHigh: ptr LONG;
                         dwMoveMethod: DWORD): DWORD {.
    importcpp: "SFileSetFilePointer(@)", header: "StormLib.h".}
proc SFileReadFile*(hFile: HANDLE; lpBuffer: pointer; dwToRead: DWORD;
                   pdwRead: LPDWORD; lpOverlapped: LPOVERLAPPED): bool {.
    importcpp: "SFileReadFile(@)", header: "StormLib.h".}
proc SFileCloseFile*(hFile: HANDLE): bool {.importcpp: "SFileCloseFile(@)",
                                        header: "StormLib.h".}
##  Retrieving info about a file in the archive

proc SFileGetFileInfo*(hMpqOrFile: HANDLE; InfoClass: SFileInfoClass;
                      pvFileInfo: pointer; cbFileInfo: DWORD;
                      pcbLengthNeeded: LPDWORD): bool {.
    importcpp: "SFileGetFileInfo(@)", header: "StormLib.h".}
proc SFileGetFileName*(hFile: HANDLE; szFileName: cstring): bool {.
    importcpp: "SFileGetFileName(@)", header: "StormLib.h".}
proc SFileFreeFileInfo*(pvFileInfo: pointer; InfoClass: SFileInfoClass): bool {.
    importcpp: "SFileFreeFileInfo(@)", header: "StormLib.h".}
##  High-level extract function

proc SFileExtractFile*(hMpq: HANDLE; szToExtract: cstring; szExtracted: ptr TCHAR;
                      dwSearchScope: DWORD): bool {.
    importcpp: "SFileExtractFile(@)", header: "StormLib.h".}
## -----------------------------------------------------------------------------
##  Functions for file and archive verification
##  Generates file CRC32

proc SFileGetFileChecksums*(hMpq: HANDLE; szFileName: cstring; pdwCrc32: LPDWORD;
                           pMD5: cstring): bool {.
    importcpp: "SFileGetFileChecksums(@)", header: "StormLib.h".}
##  Verifies file against its checksums stored in (attributes) attributes (depending on dwFlags).
##  For dwFlags, use one or more of MPQ_ATTRIBUTE_MD5

proc SFileVerifyFile*(hMpq: HANDLE; szFileName: cstring; dwFlags: DWORD): DWORD {.
    importcpp: "SFileVerifyFile(@)", header: "StormLib.h".}
##  Verifies raw data of the archive. Only works for MPQs version 4 or newer

proc SFileVerifyRawData*(hMpq: HANDLE; dwWhatToVerify: DWORD; szFileName: cstring): cint {.
    importcpp: "SFileVerifyRawData(@)", header: "StormLib.h".}
##  Verifies the signature, if present

proc SFileSignArchive*(hMpq: HANDLE; dwSignatureType: DWORD): bool {.
    importcpp: "SFileSignArchive(@)", header: "StormLib.h".}
proc SFileVerifyArchive*(hMpq: HANDLE): DWORD {.importcpp: "SFileVerifyArchive(@)",
    header: "StormLib.h".}
## -----------------------------------------------------------------------------
##  Functions for file searching

proc SFileFindFirstFile*(hMpq: HANDLE; szMask: cstring;
                        lpFindFileData: ptr SFILE_FIND_DATA; szListFile: cstring): HANDLE {.
    importcpp: "SFileFindFirstFile(@)", header: "StormLib.h".}
proc SFileFindNextFile*(hFind: HANDLE; lpFindFileData: ptr SFILE_FIND_DATA): bool {.
    importcpp: "SFileFindNextFile(@)", header: "StormLib.h".}
proc SFileFindClose*(hFind: HANDLE): bool {.importcpp: "SFileFindClose(@)",
                                        header: "StormLib.h".}
proc SListFileFindFirstFile*(hMpq: HANDLE; szListFile: cstring; szMask: cstring;
                            lpFindFileData: ptr SFILE_FIND_DATA): HANDLE {.
    importcpp: "SListFileFindFirstFile(@)", header: "StormLib.h".}
proc SListFileFindNextFile*(hFind: HANDLE; lpFindFileData: ptr SFILE_FIND_DATA): bool {.
    importcpp: "SListFileFindNextFile(@)", header: "StormLib.h".}
proc SListFileFindClose*(hFind: HANDLE): bool {.importcpp: "SListFileFindClose(@)",
    header: "StormLib.h".}
##  Locale support

proc SFileEnumLocales*(hMpq: HANDLE; szFileName: cstring; plcLocales: ptr LCID;
                      pdwMaxLocales: LPDWORD; dwSearchScope: DWORD): cint {.
    importcpp: "SFileEnumLocales(@)", header: "StormLib.h".}
## -----------------------------------------------------------------------------
##  Support for adding files to the MPQ

proc SFileCreateFile*(hMpq: HANDLE; szArchivedName: cstring; FileTime: ULONGLONG;
                     dwFileSize: DWORD; lcLocale: LCID; dwFlags: DWORD;
                     phFile: ptr HANDLE): bool {.importcpp: "SFileCreateFile(@)",
    header: "StormLib.h".}
proc SFileWriteFile*(hFile: HANDLE; pvData: pointer; dwSize: DWORD;
                    dwCompression: DWORD): bool {.importcpp: "SFileWriteFile(@)",
    header: "StormLib.h".}
proc SFileFinishFile*(hFile: HANDLE): bool {.importcpp: "SFileFinishFile(@)",
    header: "StormLib.h".}
proc SFileAddFileEx*(hMpq: HANDLE; szFileName: ptr TCHAR; szArchivedName: cstring;
                    dwFlags: DWORD; dwCompression: DWORD; dwCompressionNext: DWORD): bool {.
    importcpp: "SFileAddFileEx(@)", header: "StormLib.h".}
proc SFileAddFile*(hMpq: HANDLE; szFileName: ptr TCHAR; szArchivedName: cstring;
                  dwFlags: DWORD): bool {.importcpp: "SFileAddFile(@)",
                                       header: "StormLib.h".}
proc SFileAddWave*(hMpq: HANDLE; szFileName: ptr TCHAR; szArchivedName: cstring;
                  dwFlags: DWORD; dwQuality: DWORD): bool {.
    importcpp: "SFileAddWave(@)", header: "StormLib.h".}
proc SFileRemoveFile*(hMpq: HANDLE; szFileName: cstring; dwSearchScope: DWORD): bool {.
    importcpp: "SFileRemoveFile(@)", header: "StormLib.h".}
proc SFileRenameFile*(hMpq: HANDLE; szOldFileName: cstring; szNewFileName: cstring): bool {.
    importcpp: "SFileRenameFile(@)", header: "StormLib.h".}
proc SFileSetFileLocale*(hFile: HANDLE; lcNewLocale: LCID): bool {.
    importcpp: "SFileSetFileLocale(@)", header: "StormLib.h".}
proc SFileSetDataCompression*(DataCompression: DWORD): bool {.
    importcpp: "SFileSetDataCompression(@)", header: "StormLib.h".}
proc SFileSetAddFileCallback*(hMpq: HANDLE; AddFileCB: SFILE_ADDFILE_CALLBACK;
                             pvUserData: pointer): bool {.
    importcpp: "SFileSetAddFileCallback(@)", header: "StormLib.h".}
## -----------------------------------------------------------------------------
##  Compression and decompression

proc SCompImplode*(pvOutBuffer: pointer; pcbOutBuffer: ptr cint; pvInBuffer: pointer;
                  cbInBuffer: cint): cint {.importcpp: "SCompImplode(@)",
    header: "StormLib.h".}
proc SCompExplode*(pvOutBuffer: pointer; pcbOutBuffer: ptr cint; pvInBuffer: pointer;
                  cbInBuffer: cint): cint {.importcpp: "SCompExplode(@)",
    header: "StormLib.h".}
proc SCompCompress*(pvOutBuffer: pointer; pcbOutBuffer: ptr cint; pvInBuffer: pointer;
                   cbInBuffer: cint; uCompressionMask: cuint; nCmpType: cint;
                   nCmpLevel: cint): cint {.importcpp: "SCompCompress(@)",
    header: "StormLib.h".}
proc SCompDecompress*(pvOutBuffer: pointer; pcbOutBuffer: ptr cint;
                     pvInBuffer: pointer; cbInBuffer: cint): cint {.
    importcpp: "SCompDecompress(@)", header: "StormLib.h".}
proc SCompDecompress2*(pvOutBuffer: pointer; pcbOutBuffer: ptr cint;
                      pvInBuffer: pointer; cbInBuffer: cint): cint {.
    importcpp: "SCompDecompress2(@)", header: "StormLib.h".}
## -----------------------------------------------------------------------------
##  Non-Windows support for SetLastError/GetLastError

when not defined(PLATFORM_WINDOWS):
  proc SetLastError*(err: DWORD) {.importcpp: "SetLastError(@)", header: "StormLib.h".}
  proc GetLastError*(): DWORD {.importcpp: "GetLastError(@)", header: "StormLib.h".}

