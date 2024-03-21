/* Copyright 2012 The MathWorks, Inc. */

#ifndef SDRFPACKAGE_h
#define SDRFPACKAGE_h


#if !defined(DLL_EXPORT_SYM) || !defined(DLL_IMPORT_SYM)
#ifdef _MSC_VER
  #define DLL_EXPORT_SYM __declspec(dllexport)
  #define DLL_IMPORT_SYM __declspec(dllimport)
#elif __GNUC__ >= 4
  #define DLL_EXPORT_SYM __attribute__ ((visibility("default")))
  #define DLL_IMPORT_SYM __attribute__ ((visibility("default")))
#else
  #define DLL_EXPORT_SYM
  #define DLL_IMPORT_SYM
#endif
#endif

#ifdef __cplusplus
  #define EXTERN_C extern "C"
#else
  #define EXTERN_C extern
#endif

#define IMPORT                          DLL_IMPORT_SYM

#endif /* SDRFPACKAGE_h */
