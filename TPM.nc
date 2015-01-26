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
 * module for TP
 *
 * Author: Panos Kampanakis
 * Date: 02/04/2005
 */

includes NN;
includes ECC;

#define PROJECTIVE
//#define PROJECTIVE_M
//#define FIXED_P

module TPM {
  provides interface TP;
  uses {
    interface NN;
    interface NN2;
    interface ECC;
    interface TPCurveParam;
  }
}

implementation {
  TPParams tpparam;
  NN_DIGIT Qx[NUMWORDS], mQy[NUMWORDS];
#ifdef BARRETT_REDUCTION
  Barrett Bbuf;
#endif

#ifdef PROJECTIVE

#elif defined(PROJECTIVE_M)

#elif defined(FIXED_P)
  PointSlope *pPointSlope;
#else  //affine coordinate system

#endif
  NN_DIGIT inv2[NUMWORDS]; // used for lucas division

  int pflag=0;

#ifdef IMOTE2
  void print_val(NN_DIGIT *num) {
    int i;
    for (i=NUMWORDS-2; i>=0; i--) trace(DBG_USR1,"%08x",*(num+i));
    trace(DBG_USR1,"\n\r");
  }
#endif
#ifdef MICA
  void print_val(NN_DIGIT *num){
    int i;
    for(i=0; i<NUMWORDS; i++){
      printf("%02x", num[NUMWORDS-i-1]);
    }
    printf("\n\r");
  }
#endif


#ifdef PROJECTIVE
  void dbl_line_projective(NN2_NUMBER *u, Point *P0, NN_DIGIT *Z0, Point *P1, NN_DIGIT *Z1){
    NN_DIGIT t1[NUMWORDS];
    NN_DIGIT t2[NUMWORDS];
    NN_DIGIT t3[NUMWORDS];

    /*
    if(call NN.Zero(Z1, NUMWORDS)){
      //infinity
      return;
    }
    */
    //t2=Z1^2
    call NN.ModSqr(t2, Z1, tpparam.p, NUMWORDS);

    //t3=3*X1^2+a*Z1^4
    call NN.ModSqr(t3, P1->x, tpparam.p, NUMWORDS);  //X1^2
    memcpy(t1, t3, NUMWORDS*NN_DIGIT_LEN);
    call NN.LShift(t1, t1, 1, NUMWORDS);  //2*X1^2
    call NN.ModAdd(t3, t3, t1, tpparam.p, NUMWORDS);  //3*X1^2
    call NN.ModSqr(t1, t2, tpparam.p, NUMWORDS);  //Z1^4
    if(tpparam.E.a_one == FALSE)
      call NN.ModMult(t1, t1, tpparam.E.a, tpparam.p, NUMWORDS);  //a*Z1^4
    call NN.ModAdd(t3, t3, t1, tpparam.p, NUMWORDS);


    //t1=Y1^2
    call NN.ModSqr(t1, P1->y, tpparam.p, NUMWORDS);
    
    //Z3=2Y1*Z1
    call NN.ModMult(Z0, P1->y, Z1, tpparam.p, NUMWORDS);
    call NN.LShift(Z0, Z0, 1, NUMWORDS);
    call NN.ModSmall(Z0, tpparam.p, NUMWORDS);

    //g=Z3*t2*(-yQi) + (2*t1-t3*(t2*xQ+X1))
    call NN.ModMult(u->i, Z0, t2, tpparam.p, NUMWORDS);  //Z3*t2
    call NN.ModMult(u->i, u->i, mQy, tpparam.p, NUMWORDS);  //Z3*t2*(-yQ)
    call NN.ModMult(t2, t2, Qx, tpparam.p, NUMWORDS);  //t2*xQ
    call NN.ModAdd(t2, t2, P1->x, tpparam.p, NUMWORDS);  //t2*xQ+X1
    call NN.ModMult(t2, t2, t3, tpparam.p, NUMWORDS);  //t3*(t2*xQ+X1)
    call NN.LShift(u->r, t1, 1, NUMWORDS);  //2*t1
    call NN.ModSmall(u->r, tpparam.p, NUMWORDS);
    call NN.ModSub(u->r, u->r, t2, tpparam.p, NUMWORDS);  //2*t1 - t3*(t2*xQ+X1)

    //t2=4*X1*t1
    call NN.ModMult(t2, P1->x, t1, tpparam.p, NUMWORDS);  //X1*t1
    call NN.LShift(t2, t2, 2, NUMWORDS);
    call NN.ModSmall(t2, tpparam.p, NUMWORDS);

    //X3=t3^2 - 2*t2 = t3^2 - t2 - t2
    call NN.ModSqr(P0->x, t3, tpparam.p, NUMWORDS);
    call NN.ModSub(P0->x, P0->x, t2, tpparam.p, NUMWORDS);
    call NN.ModSub(P0->x, P0->x, t2, tpparam.p, NUMWORDS);
    //t1=8t1^2
    call NN.ModSqr(t1, t1, tpparam.p, NUMWORDS);
    call NN.LShift(t1, t1, 3, NUMWORDS);
    call NN.ModSmall(t1, tpparam.p, NUMWORDS);
    //Y3=t3(t2-X3)-t1
    call NN.ModSub(P1->y, t2, P1->x, tpparam.p, NUMWORDS);
    call NN.ModMult(P1->y, P1->y, t3, tpparam.p, NUMWORDS);
    call NN.ModSub(P1->y, P1->y, t1, tpparam.p, NUMWORDS);

  }

  void add_line_projective(NN2_NUMBER *u, Point *P0, NN_DIGIT *Z0, Point *P1, NN_DIGIT *Z1, Point *P2){
    NN_DIGIT t1[NUMWORDS];
    NN_DIGIT t2[NUMWORDS];
    NN_DIGIT t3[NUMWORDS];
    NN_DIGIT t4[NUMWORDS];

    //what if infinity

    //t1=Z1^2
    call NN.ModSqr(t1, Z1, tpparam.p, NUMWORDS);
    //t2=Z1*t1
    call NN.ModMult(t2, Z1, t1, tpparam.p, NUMWORDS);
    //t3=X*t1
    call NN.ModMult(t3, P2->x, t1, tpparam.p, NUMWORDS);
    //t1=Y*t2
    call NN.ModMult(t1, P2->y, t2, tpparam.p, NUMWORDS);
    //t2=t3-X1
    call NN.ModSub(t2, t3, P1->x, tpparam.p, NUMWORDS);
    //t3=t1-Y1
    call NN.ModSub(t3, t1, P1->y, tpparam.p, NUMWORDS);
    //Z3=Z1*t2
    call NN.ModMult(Z0, Z1, t2, tpparam.p, NUMWORDS);
    //g=Z3*(-yQi) + (Z3*Y - t3*(xQ + X))
    call NN.ModMult(u->i, Z0, mQy, tpparam.p, NUMWORDS);  //Z3*yQi
    call NN.ModAdd(t4, Qx, P2->x, tpparam.p, NUMWORDS);  //xQ + X
    call NN.ModMult(u->r, t4, t3, tpparam.p, NUMWORDS);  //t3*(xQ+X)
    call NN.ModMult(t4, Z0, P2->y, tpparam.p, NUMWORDS);  //Z3*Y
    call NN.ModSub(u->r, t4, u->r, tpparam.p, NUMWORDS);  //Z3*Y - t3*(xQ + X))
    //t1=t2^2
    call NN.ModSqr(t1, t2, tpparam.p, NUMWORDS);
    //t4=t2*t1
    call NN.ModMult(t4, t2, t1, tpparam.p, NUMWORDS);
    //t2=X1*t1
    call NN.ModMult(t2, P1->x, t1, tpparam.p, NUMWORDS);
    //X3=t3^2-(t4+2*t2)
    call NN.ModSqr(P0->x, t3, tpparam.p, NUMWORDS);
    call NN.ModSub(P0->x, P0->x, t4, tpparam.p, NUMWORDS);
    call NN.ModSub(P0->x, P0->x, t2, tpparam.p, NUMWORDS);
    call NN.ModSub(P0->x, P0->x, t2, tpparam.p, NUMWORDS);
    //Y3=t3*(t2-X3)-Y1*t4
    call NN.ModSub(t1, t2, P0->x, tpparam.p, NUMWORDS);  //t2-X3
    call NN.ModMult(t1, t3, t1, tpparam.p, NUMWORDS);  //t3*(t2-X3)
    call NN.ModMult(P0->y, P1->y, t4, tpparam.p, NUMWORDS);  //Y1*t4
    call NN.ModSub(P0->y, t1, P0->y, tpparam.p, NUMWORDS);  //t3*(t2-X3)-Y1*t4
  }

  //Miller's algorithm based on projective coordinate system
  command result_t TP.Miller(NN2_NUMBER *ef){
    NN2_NUMBER temp1;
    Point V;
    int t;
    NN_DIGIT Z[NUMWORDS];

    memset(ef->r, 0, NUMWORDS*NN_DIGIT_LEN); // f = 1
    ef->r[0] = 0x1;
    memset(ef->i, 0, NUMWORDS*NN_DIGIT_LEN);
    //V = tpparam.P; // V=P
    call NN.Assign(V.x, tpparam.P.x, NUMWORDS);
    call NN.Assign(V.y, tpparam.P.y, NUMWORDS);
    memset(Z, 0, NUMWORDS*NN_DIGIT_LEN);
    Z[0] = 0x1;

    t = (call NN.Bits(tpparam.m,NUMWORDS))-2; // t=bits-2
    
    while (t>-1) {
      dbl_line_projective(&temp1, &V, Z, &V, Z);
      call NN2.ModSqr(ef, ef, tpparam.p, NUMWORDS);  //f=f^2
      call NN2.ModMult(ef, ef, &temp1, tpparam.p, NUMWORDS); // f=f*g

      if ((t>0) && (call NN.TestBit(tpparam.m,t))) {
	add_line_projective(&temp1, &V, Z, &V, Z, &(tpparam.P));
	call NN2.ModMult(ef, ef, &temp1, tpparam.p, NUMWORDS);//f=f*g
      }
      t--;
    }
    return SUCCESS;
  }


#elif defined(PROJECTIVE_M)

  void dbl_line_projective_m(NN2_NUMBER *u, NN2_NUMBER *temp, Point *P0, NN_DIGIT *Z0, Point *P1, NN_DIGIT *Z1, int m){
    NN_DIGIT t1[NUMWORDS];
    NN_DIGIT t2[NUMWORDS];
    NN_DIGIT t3[NUMWORDS];
    NN_DIGIT W[NUMWORDS];
    int i;

    call NN.Assign(P0->x, P1->x, NUMWORDS);
    call NN.Assign(Z0, Z1, NUMWORDS);
    //Y1 = 2Y1
    call NN.LShift(P0->y, P1->y, 1, NUMWORDS);
    call NN.ModSmall(P0->y, tpparam.p, NUMWORDS);
    //W = a*Z1^4
    call NN.ModSqr(W, Z1, tpparam.p, NUMWORDS);
    call NN.ModSqr(W, W, tpparam.p, NUMWORDS);
    call NN.ModMult(W, W, tpparam.E.a, tpparam.p, NUMWORDS);

    for (i=m; i>=0; i--){
      //t1 = Y0^2
      call NN.ModSqr(t1, P0->y, tpparam.p, NUMWORDS);
      //t3 = 3*X0^2 + W
      call NN.ModSqr(t2, P0->x, tpparam.p, NUMWORDS);
      call NN.LShift(t3, t2, 1, NUMWORDS);
      call NN.ModAdd(t3, t3, t2, tpparam.p, NUMWORDS);
      call NN.ModAdd(t3, t3, W, tpparam.p, NUMWORDS);
      //t2 = Z0^2
      call NN.ModSqr(t2, Z1, tpparam.p, NUMWORDS);
      //temp->r = t1/2 - t3*(t2*XQ + X0)
      call NN.Assign(temp->r, t1, NUMWORDS);
      if (t1[0] % 2 == 1)
	call NN.Add(temp->r, temp->r, tpparam.p, NUMWORDS);
      call NN.RShift(temp->r, temp->r, 1, NUMWORDS);
      call NN.ModMult(temp->i, t2, Qx, tpparam.p, NUMWORDS);  //t2*XQ
      call NN.ModAdd(temp->i, temp->i, P0->x, tpparam.p, NUMWORDS);  //t2*XQ + X0
      call NN.ModMult(temp->i, temp->i, t3, tpparam.p, NUMWORDS);  //t3*(t2*XQ + X0)
      call NN.ModSub(temp->r, temp->r, temp->i, tpparam.p, NUMWORDS);
      //Z0 = Z0*Y0
      call NN.ModMult(Z0, Z0, P0->y, tpparam.p, NUMWORDS);
      //temp->i = Z0*t2*(-YQ)
      call NN.ModMult(temp->i, Z0, t2, tpparam.p, NUMWORDS);
      call NN.ModMult(temp->i, temp->i, mQy, tpparam.p, NUMWORDS);
      //t2 = X0*t1
      call NN.ModMult(t2, P0->x, t1, tpparam.p, NUMWORDS);
      //X0 = t3^2 - 2*t2
      call NN.ModSqr(P0->x, t3, tpparam.p, NUMWORDS);
      call NN.ModSub(P0->x, P0->x, t2, tpparam.p, NUMWORDS);
      call NN.ModSub(P0->x, P0->x, t2, tpparam.p, NUMWORDS);
      //t1 = t1^2
      call NN.ModSqr(t1, t1, tpparam.p, NUMWORDS);
      //Y0 = 2*t3(t2-X0)-t1^2
      call NN.ModSub(P0->y, t2, P0->x, tpparam.p, NUMWORDS);
      call NN.ModMult(P0->y, t3, P0->y, tpparam.p, NUMWORDS);
      call NN.LShift(P0->y, P0->y, 1, NUMWORDS);
      call NN.ModSmall(P0->y, tpparam.p, NUMWORDS);
      call NN.ModSub(P0->y, P0->y, t1, tpparam.p, NUMWORDS);
      if(m>0){
	call NN.ModMult(W, W, t1, tpparam.p, NUMWORDS);
      }
      //f = f^2*g
      call NN2.ModSqr(u, u, tpparam.p, NUMWORDS);  //f=f^2
      call NN2.ModMult(u, u, temp, tpparam.p, NUMWORDS); // f=f*g      
    }
    //Y0 = Y0/2
    if (P0->y[0] % 2 == 1)
      call NN.Add(P0->y, P0->y, tpparam.p, NUMWORDS);
    call NN.RShift(P0->y, P0->y, 1, NUMWORDS);
  }

  void add_line_projective(NN2_NUMBER *u, Point *P0, NN_DIGIT *Z0, Point *P1, NN_DIGIT *Z1, Point *P2){
    NN_DIGIT t1[NUMWORDS];
    NN_DIGIT t2[NUMWORDS];
    NN_DIGIT t3[NUMWORDS];
    NN_DIGIT t4[NUMWORDS];

    //what if infinity

    //t1=Z1^2
    call NN.ModSqr(t1, Z1, tpparam.p, NUMWORDS);
    //t2=Z1*t1
    call NN.ModMult(t2, Z1, t1, tpparam.p, NUMWORDS);
    //t3=X*t1
    call NN.ModMult(t3, P2->x, t1, tpparam.p, NUMWORDS);
    //t1=Y*t2
    call NN.ModMult(t1, P2->y, t2, tpparam.p, NUMWORDS);
    //t2=t3-X1
    call NN.ModSub(t2, t3, P1->x, tpparam.p, NUMWORDS);
    //t3=t1-Y1
    call NN.ModSub(t3, t1, P1->y, tpparam.p, NUMWORDS);
    //Z3=Z1*t2
    call NN.ModMult(Z0, Z1, t2, tpparam.p, NUMWORDS);
    //g=Z3*(-yQi) + (Z3*Y - t3*(xQ + X))
    call NN.ModMult(u->i, Z0, mQy, tpparam.p, NUMWORDS);  //Z3*yQi
    call NN.ModAdd(t4, Qx, P2->x, tpparam.p, NUMWORDS);  //xQ + X
    call NN.ModMult(u->r, t4, t3, tpparam.p, NUMWORDS);  //t3*(xQ+X)
    call NN.ModMult(t4, Z0, P2->y, tpparam.p, NUMWORDS);  //Z3*Y
    call NN.ModSub(u->r, t4, u->r, tpparam.p, NUMWORDS);  //Z3*Y - t3*(xQ + X))
    //t1=t2^2
    call NN.ModSqr(t1, t2, tpparam.p, NUMWORDS);
    //t4=t2*t1
    call NN.ModMult(t4, t2, t1, tpparam.p, NUMWORDS);
    //t2=X1*t1
    call NN.ModMult(t2, P1->x, t1, tpparam.p, NUMWORDS);
    //X3=t3^2-(t4+2*t2)
    call NN.ModSqr(P0->x, t3, tpparam.p, NUMWORDS);
    call NN.ModSub(P0->x, P0->x, t4, tpparam.p, NUMWORDS);
    call NN.ModSub(P0->x, P0->x, t2, tpparam.p, NUMWORDS);
    call NN.ModSub(P0->x, P0->x, t2, tpparam.p, NUMWORDS);
    //Y3=t3*(t2-X3)-Y1*t4
    call NN.ModSub(t1, t2, P0->x, tpparam.p, NUMWORDS);  //t2-X3
    call NN.ModMult(t1, t3, t1, tpparam.p, NUMWORDS);  //t3*(t2-X3)
    call NN.ModMult(P0->y, P1->y, t4, tpparam.p, NUMWORDS);  //Y1*t4
    call NN.ModSub(P0->y, t1, P0->y, tpparam.p, NUMWORDS);  //t3*(t2-X3)-Y1*t4
  }

  //return the largest number of consecutive 0s, start is the position of first 0 bit
  int check_m_0(NN_DIGIT *a, int start){
    NN_DIGIT temp;
    int rest, original_rest;
    bool done = FALSE;
    int i, original_i;

    original_i = i = start / NN_DIGIT_BITS;
    temp = *(a+i);
    original_rest = rest = start % NN_DIGIT_BITS;
    while (!done && rest >= 0){
      if (temp & ((NN_DIGIT)1<<rest))
	done = TRUE;
      else
	rest--;
    }
    if (rest >= 0){  //1 in current digit
      return original_rest - rest;
    }
    i--;
    //no 1 in current digit after start
    while(*(a+i) == 0 && i >= 0){
      i--;
    }
    
    if (i < 0){  //all following digits are zero
      return (start + 1);
    }
    //find bit 1 in the following digit
    done = FALSE;
    rest = NN_DIGIT_BITS - 1;
    temp = *(a+i);
    while (!done){
      if (temp & ((NN_DIGIT)1<<rest))
	done = TRUE;
      else
	rest--;
    }
    return ((original_i - 1 - i) * NN_DIGIT_BITS + original_rest + NN_DIGIT_BITS - rest);
  }

  command result_t TP.Miller(NN2_NUMBER *ef){
    
    NN2_NUMBER temp1;
    Point V;
    int t, m;
    NN_DIGIT Z[NUMWORDS];

    memset(ef->r, 0, NUMWORDS*NN_DIGIT_LEN); // f = 1
    ef->r[0] = 0x1;
    memset(ef->i, 0, NUMWORDS*NN_DIGIT_LEN);
    //V = tpparam.P; // V=P
    call NN.Assign(V.x, tpparam.P.x, NUMWORDS);
    call NN.Assign(V.y, tpparam.P.y, NUMWORDS);
    memset(Z, 0, NUMWORDS*NN_DIGIT_LEN);
    Z[0] = 0x1;

    t = (call NN.Bits(tpparam.m,NUMWORDS))-2; // t=bits-2
    
    while (t>-1) {
      //find the largest m consecutive 0 bits
      m = check_m_0(tpparam.m, t);
      dbl_line_projective_m(ef, &temp1, &V, Z, &V, Z, m);
      t = t - m;
      if (t>0) {
	add_line_projective(&temp1, &V, Z, &V, Z, &(tpparam.P));
	call NN2.ModMult(ef, ef, &temp1, tpparam.p, NUMWORDS);//f=f*g
      }
      t--;
    }
    return SUCCESS;

  }

#elif defined(FIXED_P)

  // affine point doubleing, P0 = 2*P1, slope is set slope=[(3x1^2+a)/(2y1)]^2=(y{2P1}-y1)/(x{2P1}-x1)
  // P0 and P1 can be the same point
  void aff_dbl(PointSlope *pNode, Point * P0, Point * P1)
  {
   Point P;
   NN_DIGIT t1[NUMWORDS], t2[NUMWORDS];
   P=*P1;
   pNode->dbl = TRUE;
   
   call NN.ModSqr(t1, P.x, tpparam.p, NUMWORDS); //x1^2
   call NN.LShift(t2, t1, 1, NUMWORDS);
   if(call NN.Cmp(t2, tpparam.p, NUMWORDS) >= 0)
     call NN.Sub(t2, t2, tpparam.p, NUMWORDS); //2x1^2
   call NN.ModAdd(t2, t2, t1, tpparam.p, NUMWORDS); //3x1^2 
   call NN.ModAdd(t1, t2, tpparam.E.a, tpparam.p, NUMWORDS); //3x1^2+a
   call NN.LShift(t2, P.y, 1, NUMWORDS);
   if(call NN.Cmp(t2, tpparam.p, NUMWORDS) >= 0)
     call NN.Sub(t2, t2, tpparam.p, NUMWORDS); //2y1
   call NN.ModDiv(pNode->slope, t1, t2, tpparam.p, NUMWORDS); //(3x1^2+a)/(2y1) 
   call NN.ModSqr(t1, pNode->slope, tpparam.p, NUMWORDS); //[(3x1^2+a)/(2y1)]^2
   call NN.LShift(t2, P.x, 1, NUMWORDS);
   if(call NN.Cmp(t2, tpparam.p, NUMWORDS) >= 0)
     call NN.Sub(t2, t2, tpparam.p, NUMWORDS); //2x1
   call NN.ModSub(P0->x, t1, t2, tpparam.p, NUMWORDS); //P0.x = [(3x1^2+a)/(2y1)]^2 - 2x1
   call NN.ModSub(t1, P.x, P0->x, tpparam.p, NUMWORDS); //x1-P0.x
   call NN.ModMult(t2, pNode->slope, t1, tpparam.p, NUMWORDS); //[(3x1^2+a)/(2y1)](x1-P0.x)
   call NN.ModSub(P0->y, t2, P.y, tpparam.p, NUMWORDS); //[(3x1^2+a)/(2y1)](x1-P0.x)-y1
   
   call NN.Assign(pNode->P.x, P.x, NUMWORDS);
   call NN.Assign(pNode->P.y, P.y, NUMWORDS);

  }

  // affine Point addition, P0 = P1 + P2, slope is set slope=(y2-y1)/(x2-x1)
  // P0, P1 and P2 can be the same point
  void aff_add(PointSlope *pNode, Point * P0, Point * P1, Point * P2)
  {
    NN_DIGIT t1[NUMWORDS], t2[NUMWORDS];
    Point Pt1, Pt2;
    Pt1 = *P1; Pt2 = *P2;
    pNode->dbl = FALSE;
    call NN.ModSub(t1, Pt2.y, Pt1.y, tpparam.p, NUMWORDS); //y2-y1
    call NN.ModSub(t2, Pt2.x, Pt1.x, tpparam.p, NUMWORDS); //y2-y1
    call NN.ModDiv(pNode->slope, t1, t2, tpparam.p, NUMWORDS); //(y2-y1)/(x2-x1) 
    call NN.ModSqr(t1, pNode->slope, tpparam.p, NUMWORDS); //[(y2-y1)/(x2-x1)]^2
    call NN.ModSub(t2, t1, Pt1.x, tpparam.p, NUMWORDS); 
    call NN.ModSub(P0->x, t2, Pt2.x, tpparam.p, NUMWORDS); //P0.x = [(y2-y1)/(x2-x1)]^2 - x1 - x2
    call NN.ModSub(t1, Pt1.x, P0->x, tpparam.p, NUMWORDS); //x1-P0.x
    call NN.ModMult(t2, t1, pNode->slope, tpparam.p, NUMWORDS); //(x1-P0.x)(y2-y1)/(x2-x1)
    call NN.ModSub(P0->y, t2, Pt1.y, tpparam.p, NUMWORDS); //P0.y=(x1-P0.x)(y2-y1)/(x2-x1)-y1

    call NN.Assign(pNode->P.x, Pt1.x, NUMWORDS);
    call NN.Assign(pNode->P.y, Pt1.y, NUMWORDS);
  }

  void precompute(){
    Point V;
    int t;
    bool first_bit = TRUE;
    PointSlope *current;

    V = tpparam.P; // V=P
    t = (call NN.Bits(tpparam.m,NUMWORDS))-2; // t=bits-2

    while (t>-1) {
      if (first_bit){
	pPointSlope = (PointSlope *)malloc(sizeof(PointSlope));
	current = pPointSlope;
	first_bit = FALSE;
      }else{
	current->next = (PointSlope *)malloc(sizeof(PointSlope));
	current = current->next;
      }
      current->next = NULL;
      aff_dbl(current, &V, &V); //V=2V
      if ((t>0) && (call NN.TestBit(tpparam.m,t))) {
	current->next = (PointSlope *)malloc(sizeof(PointSlope));
	current = current->next;
	current->next = NULL;
	aff_add(current, &V, &V, &(tpparam.P)); //V=V+P
      }
      t--;
    }

  }

  // Miller's algorithm
  command result_t TP.Miller(NN2_NUMBER *ef) { 
    NN2_NUMBER temp1;
    PointSlope *current;


    call NN.Assign(temp1.i,mQy,NUMWORDS);
    memset(ef->r, 0, NUMWORDS*NN_DIGIT_LEN); // f = 1
    ef->r[0] = 0x1;
    memset(ef->i, 0, NUMWORDS*NN_DIGIT_LEN);
    
    current = pPointSlope;
    while(current != NULL){
      call NN.ModAdd(temp1.r, current->P.x, Qx, tpparam.p, NUMWORDS); //x+Qx
      call NN.ModMult(temp1.r, current->slope, temp1.r, tpparam.p, NUMWORDS); //slope(x+Qx)
      call NN.ModSub(temp1.r, current->P.y, temp1.r, tpparam.p, NUMWORDS); //y-slope(x+Qx)	
      if(current->dbl){
	call NN2.ModSqr(ef, ef, tpparam.p, NUMWORDS);
	call NN2.ModMult(ef, ef, &temp1, tpparam.p, NUMWORDS);
      }else{
	call NN2.ModMult(ef, ef, &temp1, tpparam.p, NUMWORDS);//f=f*g
      }
      current = current->next;

    }
    return SUCCESS;
  }
  
#else  //affine coordinate

  // affine point doubleing, P0 = 2*P1, slope is set slope=[(3x1^2+a)/(2y1)]^2=(y{2P1}-y1)/(x{2P1}-x1)
  // P0 and P1 can be the same point
  void aff_dbl(NN2_NUMBER *u, Point * P0, Point * P1)
  {
   Point P;
   NN_DIGIT t1[NUMWORDS], t2[NUMWORDS], slope[NUMWORDS];
   P=*P1;
   
   call NN.ModSqr(t1, P.x, tpparam.p, NUMWORDS); //x1^2
   call NN.LShift(t2, t1, 1, NUMWORDS);
   if(call NN.Cmp(t2, tpparam.p, NUMWORDS) >= 0)
     call NN.Sub(t2, t2, tpparam.p, NUMWORDS); //2x1^2
   call NN.ModAdd(t2, t2, t1, tpparam.p, NUMWORDS); //3x1^2 
   call NN.ModAdd(t1, t2, tpparam.E.a, tpparam.p, NUMWORDS); //3x1^2+a
   call NN.LShift(t2, P.y, 1, NUMWORDS);
   if(call NN.Cmp(t2, tpparam.p, NUMWORDS) >= 0)
     call NN.Sub(t2, t2, tpparam.p, NUMWORDS); //2y1
   call NN.ModDiv(slope, t1, t2, tpparam.p, NUMWORDS); //(3x1^2+a)/(2y1) 
   call NN.ModSqr(t1, slope, tpparam.p, NUMWORDS); //[(3x1^2+a)/(2y1)]^2
   call NN.LShift(t2, P.x, 1, NUMWORDS);
   if(call NN.Cmp(t2, tpparam.p, NUMWORDS) >= 0)
     call NN.Sub(t2, t2, tpparam.p, NUMWORDS); //2x1
   call NN.ModSub(P0->x, t1, t2, tpparam.p, NUMWORDS); //P0.x = [(3x1^2+a)/(2y1)]^2 - 2x1
   call NN.ModSub(t1, P.x, P0->x, tpparam.p, NUMWORDS); //x1-P0.x
   call NN.ModMult(t2, slope, t1, tpparam.p, NUMWORDS); //[(3x1^2+a)/(2y1)](x1-P0.x)
   call NN.ModSub(P0->y, t2, P.y, tpparam.p, NUMWORDS); //[(3x1^2+a)/(2y1)](x1-P0.x)-y1
   
   call NN.ModAdd(u->r, P.x, Qx, tpparam.p, NUMWORDS); //x+Qx
   call NN.ModMult(u->r, slope, u->r, tpparam.p, NUMWORDS); //slope(x+Qx)
   call NN.ModSub(u->r, P.y, u->r, tpparam.p, NUMWORDS); //y-slope(x+Qx)


  }

  // affine Point addition, P0 = P1 + P2, slope is set slope=(y2-y1)/(x2-x1)
  // P0, P1 and P2 can be the same point
  void aff_add(NN2_NUMBER *u, Point * P0, Point * P1, Point * P2)
  {
    NN_DIGIT t1[NUMWORDS], t2[NUMWORDS], slope[NUMWORDS];
    Point Pt1, Pt2;
    Pt1 = *P1; Pt2 = *P2;
    call NN.ModSub(t1, Pt2.y, Pt1.y, tpparam.p, NUMWORDS); //y2-y1
    call NN.ModSub(t2, Pt2.x, Pt1.x, tpparam.p, NUMWORDS); //y2-y1
    call NN.ModDiv(slope, t1, t2, tpparam.p, NUMWORDS); //(y2-y1)/(x2-x1) 
    call NN.ModSqr(t1, slope, tpparam.p, NUMWORDS); //[(y2-y1)/(x2-x1)]^2
    call NN.ModSub(t2, t1, Pt1.x, tpparam.p, NUMWORDS); 
    call NN.ModSub(P0->x, t2, Pt2.x, tpparam.p, NUMWORDS); //P0.x = [(y2-y1)/(x2-x1)]^2 - x1 - x2
    call NN.ModSub(t1, Pt1.x, P0->x, tpparam.p, NUMWORDS); //x1-P0.x
    call NN.ModMult(t2, t1, slope, tpparam.p, NUMWORDS); //(x1-P0.x)(y2-y1)/(x2-x1)
    call NN.ModSub(P0->y, t2, Pt1.y, tpparam.p, NUMWORDS); //P0.y=(x1-P0.x)(y2-y1)/(x2-x1)-y1
    
    call NN.ModAdd(u->r, Pt1.x, Qx, tpparam.p, NUMWORDS); //x+Qx
    call NN.ModMult(u->r, slope, u->r, tpparam.p, NUMWORDS); //slope(x+Qx)
    call NN.ModSub(u->r, Pt1.y, u->r, tpparam.p, NUMWORDS); //y-slope(x+Qx)

  }

  // Miller's algorithm
  command result_t TP.Miller(NN2_NUMBER *ef) { 
    NN2_NUMBER temp1;
    Point V;
    int t;

    call NN.Assign(temp1.i,mQy,NUMWORDS);
    memset(ef->r, 0, NUMWORDS*NN_DIGIT_LEN); // f = 1
    ef->r[0] = 0x1;
    memset(ef->i, 0, NUMWORDS*NN_DIGIT_LEN);
    V = tpparam.P; // V=P
    
    t = (call NN.Bits(tpparam.m,NUMWORDS))-2; // t=bits-2
    
    while (t>-1) {
      aff_dbl(&temp1, &V, &V); //V=2V
      call NN2.ModSqr(ef, ef, tpparam.p, NUMWORDS);
      call NN2.ModMult(ef, ef, &temp1, tpparam.p, NUMWORDS);
      
      if ((t>0) && (call NN.TestBit(tpparam.m,t))) {
	aff_add(&temp1, &V, &V, &(tpparam.P)); //V=V+P
	call NN2.ModMult(ef, ef, &temp1, tpparam.p, NUMWORDS);//f=f*g
      }
      t--;

    }

    return SUCCESS;
  }

#endif
  
  // initialize the Pairing with the point to be used along with the private key
  command result_t TP.init(Point Q) {
    NN_DIGIT Qy[NUMWORDS], two[NUMWORDS];
    
    //call ECC.tpinit();
    call TPCurveParam.get_param(&tpparam);
#ifdef BARRETT_REDUCTION
    call NN.ModBarrettInit(tpparam.p, NUMWORDS, &Bbuf);
#endif
    //tpparam = call ECC.get_tpparam();
    call NN.Assign(Qx,Q.x,NUMWORDS); 
    call NN.Assign(Qy,Q.y,NUMWORDS);
    call NN.ModNeg(mQy,Qy,tpparam.p,NUMWORDS); //-Qy
    memset(inv2, 0, NUMWORDS*NN_DIGIT_LEN);
    memset(two, 0, NUMWORDS*NN_DIGIT_LEN);
    two[0] = 0x02;
    call NN.ModInv(inv2, two, tpparam.p, NUMWORDS); //2^(-1)

#ifdef FIXED_P
    //compute all intermediate nodes and slopes
    precompute();
#endif
    
    return SUCCESS;
  }

  
  // final exponentiation in Miller's algorithm
  // using the (u+iv)^(k-1) trick and Lucas exponentiation optimization
  command result_t TP.final_expon(NN_DIGIT *r,NN2_NUMBER *ef) {
    NN_DIGIT t1[NUMWORDS], t2[NUMWORDS], t3[NUMWORDS];
    
    call NN.ModSqr(t1, ef->r, tpparam.p, NUMWORDS); // x^2
    call NN.ModSqr(t2, ef->i, tpparam.p, NUMWORDS); // y^2
    call NN.ModAdd(t3, t1, t2, tpparam.p, NUMWORDS); // x^2+y^2
    call NN.ModSub(t1, t1, t2, tpparam.p, NUMWORDS); // x^2-y^2
#ifdef IMOTE2
    call NN.ModDiv(t1, t1, t3, tpparam.p, NUMWORDS); //(x^2-y^2)/(x^2+y^2)
#else
    call NN.ModDivOpt(t1, t1, t3, tpparam.p, NUMWORDS);
#endif
    call NN.LucExp(r,t1,tpparam.c,inv2,tpparam.p,NUMWORDS); // Lucas exponentiation 
    return SUCCESS;
  }
  
  // Set the res value to be the Tate Pairing result
  command result_t TP.computeTP(NN_DIGIT *res) {
    NN2_NUMBER ef;
    call TP.Miller(&ef);
    call TP.final_expon(res,&ef);
    return SUCCESS;
  }
}
