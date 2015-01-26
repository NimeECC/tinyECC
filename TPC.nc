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
 * configuration for TP
 * 
 * Author: Panos Kampanakis
 * Date: 02/04/2005
 */

configuration TPC {
  provides interface TP;
}

implementation {
  components NNM, NN2M, TPM, ss192k2, ss512k2, ss192k2s, ss512k2s;

  TP = TPM.TP;
  TPM.NN -> NNM.NN;
  TPM.NN2 -> NN2M.NN2;
  //TPM.ECC -> ECCC.ECC;
// Tate pairing curves
#ifdef SS192K2
  TPM.TPCurveParam -> ss192k2;
  ss192k2.NN -> NNM;
#endif

#ifdef SS512K2
  TPM.TPCurveParam -> ss512k2;
  ss512k2.NN -> NNM;
#endif

#ifdef SS192K2S
  TPM.TPCurveParam -> ss192k2s;
  ss192k2s.NN -> NNM;
#endif

#ifdef SS512K2S
  TPM.TPCurveParam -> ss512k2s;
  ss512k2s.NN -> NNM;
#endif
}
