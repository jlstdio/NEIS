#ifndef __libmwsdrmanager_hpp__
#define __libmwsdrmanager_hpp__

/* version.h includes way too much in a customer codegen environment
 * #include "version.h" 
 */
#include "sdrpackage.h"

#if defined(BUILDING_LIBMWSDRMANAGER)
    #define LIBMWSDRMANAGER_API DLL_EXPORT_SYM
    #define LIBMWSDRMANAGER_API_EXTERN_C EXTERN_C DLL_EXPORT_SYM
#else
    /* for clients including: ML codegen, SL codegen */
    #define LIBMWSDRMANAGER_API DLL_IMPORT_SYM
    #define LIBMWSDRMANAGER_API_EXTERN_C EXTERN_C DLL_IMPORT_SYM
#endif

#endif
