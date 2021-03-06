/**
 * All new code in this distribution is Copyright 2007 by North Carolina
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
 *
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
 * Module for curve ss192k2
 *
 * Author: Panos Kampanakis
 * Date: 02/04/2007
 */

includes ECC;

module ss192k2 {
  provides interface TPCurveParam;
  uses interface NN;
}

implementation {

  command void TPCurveParam.get_param(TPParams *tppara)
  {
  	#ifdef THIRTYTWO_BIT_PROCESSOR
	    //init parameters
	    //prime p
	    tppara->p[6] = 0x00000000;
	    tppara->p[5] = 0xF769064B;
	    tppara->p[4] = 0x09938DE6;
	    tppara->p[3] = 0xAE1939DE;
	    tppara->p[2] = 0xCBC9775F;
	    tppara->p[1] = 0x904227C7;
	    tppara->p[0] = 0xA95E9D63;

	    // a = 1 
	    memset(tppara->E.a, 0, NUMWORDS*NN_DIGIT_LEN);
	    tppara->E.a[0] =  0x00000001;
	    // b = 0
	    memset(tppara->E.b, 0, NUMWORDS*NN_DIGIT_LEN);

	    // point P
	    tppara->P.x[6] = 0x00000000;
	    tppara->P.x[5] = 0xf6a71262;
	    tppara->P.x[4] = 0xc3182055;
	    tppara->P.x[3] = 0x5c5686df;
	    tppara->P.x[2] = 0x49cf25be;
	    tppara->P.x[1] = 0xdec3e31f;
	    tppara->P.x[0] = 0x118aa0d6;

	    tppara->P.y[6] = 0x00000000;
	    tppara->P.y[5] = 0xb004ea46;
	    tppara->P.y[4] = 0x8af34bab;
	    tppara->P.y[3] = 0xca2f4c01;
	    tppara->P.y[2] = 0x03d2b57e;
	    tppara->P.y[1] = 0xed02c81f;
	    tppara->P.y[0] = 0x14d20cb1;
	    
	    // group order m
	    memset(tppara->m, 0, NUMWORDS*NN_DIGIT_LEN);
	    tppara->m[1] = 0x10000000;
	    tppara->m[0] = 0x00000021;

	    // c= p^k-1/m
	    tppara->c[6] = 0x00000000;
	    tppara->c[5] = 0x00000000;
	    tppara->c[4] = 0x0000000f;
	    tppara->c[3] = 0x769064b0;
	    tppara->c[2] = 0x9938be86;
	    tppara->c[1] = 0x57c3f1b0;
	    tppara->c[0] = 0xb78e80e4;
	#endif
  }
}
