
// Sets up common environment for Shay Green's libraries.
//
// Don't modify this file directly; #define HAVE_CONFIG_H and put your
// configuration into "config.h".

// Copyright (C) 2004-2005 Shay Green.

#ifndef BLARGG_COMMON_H
#define BLARGG_COMMON_H

#include "limits.h" // for ULONG_MAX

// blargg_err_t (NULL on success, otherwise error string)
typedef const char* blargg_err_t;
const blargg_err_t blargg_success = 0;

// Source files have #include BLARGG_SOURCE_BEGIN at the beginning
#ifndef BLARGG_SOURCE_BEGIN
#define BLARGG_SOURCE_BEGIN "blargg_source.h"
#endif

// Source files use #include BLARGG_ENABLE_OPTIMIZER before performance-critical code
#ifndef BLARGG_ENABLE_OPTIMIZER
#define BLARGG_ENABLE_OPTIMIZER "blargg_common.h"
#endif

#endif

