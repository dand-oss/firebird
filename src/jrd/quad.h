/*************  history ************
*
*       COMPONENT: JRD  MODULE: QUAD.H
*       generated by Marion V2.5     2/6/90
*       from dev              db        on 6-DEC-1993
*****************************************************************
*
*       0       katz    6-DEC-1993
*       history begins
*
 * The contents of this file are subject to the Interbase Public
 * License Version 1.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy
 * of the License at http://www.Inprise.com/IPL.html
 *
 * Software distributed under the License is distributed on an
 * "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express
 * or implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code was created by Inprise Corporation
 * and its predecessors. Portions created by Inprise Corporation are
 * Copyright (C) Inprise Corporation.
 *
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
*/


/*
 *      PROGRAM:        JRD Access Method
 *      MODULE:         quad.h
 *      DESCRIPTION:    Macros to support quad arithmetic
 *
 * copyright (c) 1993 by Borland International
 */

#ifndef JRD_QUAD_H
#define JRD_QUAD_H

#ifndef WORDS_BIGENDIAN
const int LOW_WORD		= 0;
const int HIGH_WORD		= 1;
#else
const int LOW_WORD		= 1;
const int HIGH_WORD		= 0;
#endif

#ifdef NATIVE_QUAD
#define QUAD_ADD(a, b, e)		((a) + (b))
#define QUAD_COMPARE(a, b)		((a == b) ? 0 : (a < b) ? -1 : 1)
#define QUAD_FROM_DOUBLE(a, e)	a
#define QUAD_MULTIPLY(a, b, e)	((a) * (b))
#define QUAD_NEGATE(a, e)		(-(a))
#define QUAD_SUBTRACT(a, b, e)	((a) - (b))
#else
#define QUAD_ADD(a, b, e)		QUAD_add (&(a), &(b), e)
#define QUAD_COMPARE(a, b)		QUAD_compare (&(a), &(b))
#define QUAD_FROM_DOUBLE(a, e)	QUAD_from_double (&(a), e)
#define QUAD_MULTIPLY(a, b, e)	QUAD_multiply (&(a), &(b), e)
#define QUAD_NEGATE(a, e)		QUAD_negate (&(a), e)
#define QUAD_SUBTRACT(a, b, e)	QUAD_subtract (&(a), &(b), e)

#include "../jrd/quad_proto.h"
#endif

#endif /* JRD_QUAD_H */