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
 * $Id: ECCC.nc,v 1.2 2007/09/12 18:17:06 aliu3 Exp $
 * Configuration of Ecc
 *
 * Author: An Liu
 * Date: 09/29/2006
 * Modified by: Panos Kampanakis
 * Date: 02/05/2007
 */

includes NN;
includes ECC;

configuration ECCC {
  provides interface ECC;
}

implementation {
  //secp160k1_16 provides the parameters of secp160k1 in 16 bits form,
  //you can change this to secp160r1 or secp160r1_16. Don't forget to
  //define the correct MACRO in NN.h to support 8 bit or 16 bit form.
  components ECCM, NNM, RandomLFSR,
    secp128r1, secp128r2, 
    secp160k1, secp160r1, secp160r2,
    secp192k1, secp192r1,
    ss192k2, ss512k2,
    ss192k2s, ss512k2s;

  ECC = ECCM.ECC;
  ECCM.NN -> NNM.NN;
  ECCM.Random -> RandomLFSR;

#ifdef TEST_VECTOR
  ECCM.CurveParam -> secp160r1;
  NNM.CurveParam -> secp160r1;
  secp160r1.NN -> NNM;

#else

#ifdef SECP128R1
  ECCM.CurveParam -> secp128r1;
  NNM.CurveParam -> secp128r1;
  secp128r1.NN -> NNM;
#endif

#ifdef SECP128R2
  ECCM.CurveParam -> secp128r2;
  NNM.CurveParam -> secp128r2;
  secp128r2.NN -> NNM;
#endif

#ifdef SECP160K1
  ECCM.CurveParam -> secp160k1;
  NNM.CurveParam -> secp160k1;
  secp160k1.NN -> NNM;
#endif

#ifdef SECP160R1
  ECCM.CurveParam -> secp160r1;
  NNM.CurveParam -> secp160r1;
  secp160r1.NN -> NNM;
#endif

#ifdef SECP160R2
  ECCM.CurveParam -> secp160r2;
  NNM.CurveParam -> secp160r2;
  secp160r2.NN -> NNM;
#endif

#ifdef SECP192K1
  ECCM.CurveParam -> secp192k1;
  NNM.CurveParam -> secp192k1;
  secp192k1.NN -> NNM;
#endif

#ifdef SECP192R1
  ECCM.CurveParam -> secp192r1;
  NNM.CurveParam -> secp192r1;
  secp192r1.NN -> NNM;
#endif

// Tate pairing curves
#ifdef SS192K2
  ECCM.TPCurveParam -> ss192k2;
  ss192k2.NN -> NNM;
#endif

#ifdef SS512K2
  ECCM.TPCurveParam -> ss512k2;
  ss512k2.NN -> NNM;
#endif

#ifdef SS192K2S
  ECCM.TPCurveParam -> ss192k2s;
  ss192k2s.NN -> NNM;
#endif

#ifdef SS512K2S
  ECCM.TPCurveParam -> ss512k2s;
  ss512k2s.NN -> NNM;
#endif

#endif

}
