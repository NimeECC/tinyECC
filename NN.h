/**
 * All new code in this distribution is Copyright 2005 by North Carolina
 * State University. All rights reserved. Redistribution and use in
 * source and binary forms are permitted provided that this entire
 * copyright notice is duplicated in all such copies, and that any
 * documentation, announcements, and other materials related to such
 * distribution and use acknowledge that the software was developed at
 * North Carolina State University, Raleigh, NC. No charge may be made
 * for copies, derivations, or distributions of this material without the
 * express written consent of the copyright holder. Neither the name of
 * the University nor the name of the author may be used to endorse or
 * promote products derived from this material without specific prior
 * written permission.

 * IN NO EVENT SHALL THE NORTH CAROLINA STATE UNIVERSITY BE LIABLE TO ANY
 * PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
 * DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 * EVEN IF THE NORTH CAROLINA STATE UNIVERSITY HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN
 * "AS IS" BASIS, AND THE NORTH CAROLINA STATE UNIVERSITY HAS NO
 * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 * MODIFICATIONS. "
 *
 */

/**
 * $Id: NN.h,v 1.9 2007/09/12 18:17:06 aliu3 Exp $
 */

#ifndef _NN_H_
#define _NN_H_

// frequency (in MHz) of the imote2 processor
#if CORE_FREQ == 13
#define CORE_BUS 13
#elif CORE_FREQ == 104
#define CORE_BUS 104
#elif CORE_FREQ == 208
#define CORE_BUS 208
#elif CORE_FREQ == 416
#define CORE_BUS 208
#endif

//#define BARRETT_REDUCTION
//#define HYBRID_MULT  //hybrid multiplication
//#define HYBRID_SQR //hybrd squaring
//#define CURVE_OPT  //optimization for SECG curves


#define MODINVOPT

#ifdef TEST_VECTOR

#define KEY_BIT_LEN 160
#define HYBRID_MUL_WIDTH5

#else

#if defined (SECP128R1) || defined (SECP128R2)
#define KEY_BIT_LEN 128
#define HYBRID_MUL_WIDTH4
#else
#if defined (SECP160K1) || defined (SECP160R1) || defined (SECP160R2)
#define KEY_BIT_LEN 160
#define HYBRID_MUL_WIDTH5  //column width=5 for hybrid multiplication
#else
#if defined (SECP192K1) || defined (SECP192R1) || defined (SS192K2) || defined (SS192K2S)
#define KEY_BIT_LEN 192
#define HYBRID_MUL_WIDTH4
#else
#if defined (SS512K2) || defined (SS512K2S)
#define BARRETT_REDUCTION
#define KEY_BIT_LEN 512
#define HYBRID_MUL_WIDTH5
#endif // end of 512
#endif  //end of 192
#endif  //end of 160
#endif  //end of 128

#endif  //TEST_VECTOR



//mica, mica2, micaz
#ifdef PLATFORM_MICAZ
#define EIGHT_BIT_PROCESSOR
#define INLINE_ASM
#endif

//telosb
#ifdef PLATFORM_TELOSB
#define SIXTEEN_BIT_PROCESSOR
#define INLINE_ASM
#endif

//imote2
#ifdef PLATFORM_IMOTE2
#define THIRTYTWO_BIT_PROCESSOR
#define INLINE_ASM
#endif




#ifdef EIGHT_BIT_PROCESSOR

/* Type definitions */
typedef uint8_t NN_DIGIT;
typedef uint16_t NN_DOUBLE_DIGIT;

/* Types for length */
typedef uint8_t NN_UINT;
typedef uint16_t NN_UINT2;

/* Length of digit in bits */
#define NN_DIGIT_BITS 8

/* Length of digit in bytes */
#define NN_DIGIT_LEN (NN_DIGIT_BITS/8)

/* Maximum value of digit */
#define MAX_NN_DIGIT 0xff

/* Number of digits in key
 * used by optimized mod multiplication (ModMultOpt) and optimized mod square (ModSqrOpt)
 *
 */
#define KEYDIGITS (KEY_BIT_LEN/NN_DIGIT_BITS) //20

/* Maximum length in digits */
#define MAX_NN_DIGITS (KEYDIGITS+1)

/* buffer size
 *should be large enough to hold order of base point
 */
#define NUMWORDS MAX_NN_DIGITS

#endif  //EIGHT_BIT_PROCESSOR



#ifdef SIXTEEN_BIT_PROCESSOR

/* Type definitions */
typedef uint16_t NN_DIGIT;
typedef uint32_t NN_DOUBLE_DIGIT;

/* Types for length */
typedef uint8_t NN_UINT;
typedef uint16_t NN_UINT2;

/* Length of digit in bits */
#define NN_DIGIT_BITS 16

/* Length of digit in bytes */
#define NN_DIGIT_LEN (NN_DIGIT_BITS/8)

/* Maximum value of digit */
#define MAX_NN_DIGIT 0xffff

/* Number of digits in key
 * used by optimized mod multiplication (ModMultOpt) and optimized mod square (ModSqrOpt)
 *
 */
#define KEYDIGITS (KEY_BIT_LEN/NN_DIGIT_BITS) //10

/* Maximum length in digits */
#define MAX_NN_DIGITS (KEYDIGITS+1)

/* buffer size
 *should be large enough to hold order of base point
 */
#define NUMWORDS MAX_NN_DIGITS

#endif  //SIXTEEN_BIT_PROCESSOR



#ifdef THIRTYTWO_BIT_PROCESSOR

/* Type definitions */
typedef uint32_t NN_DIGIT;
typedef uint64_t NN_DOUBLE_DIGIT;

/* Types for length */
typedef uint8_t NN_UINT;
typedef uint16_t NN_UINT2;

/* Length of digit in bits */
#define NN_DIGIT_BITS 32

/* Length of digit in bytes */
#define NN_DIGIT_LEN (NN_DIGIT_BITS/8)

/* Maximum value of digit */
#define MAX_NN_DIGIT 0xffffffff

/* Number of digits in key
 * used by optimized mod multiplication (ModMultOpt) and optimized mod square (ModSqrOpt)
 *
 */
#define KEYDIGITS (KEY_BIT_LEN/NN_DIGIT_BITS) //5

/* Maximum length in digits */
#define MAX_NN_DIGITS (KEYDIGITS+1)

/* buffer size
 *should be large enough to hold order of base point
 */
#define NUMWORDS MAX_NN_DIGITS

#endif  //THIRTYTWO_BIT_PROCESSOR



struct Barrett{
  NN_DIGIT mu[2*MAX_NN_DIGITS+1];
  NN_UINT mu_len;
  NN_UINT km;  //length of moduli m, m_{k-1} != 0
};
typedef struct Barrett Barrett;




#endif
