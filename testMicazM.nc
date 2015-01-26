 
includes NN;

#define ADD_LOOPS 5000
#define SUB_LOOPS 5000
#define MULT_LOOPS 499
#define DIV_LOOPS 100

module testMicazM{
  provides interface StdControl;
  uses{
    interface NN;
    interface ECC;
    interface Timer;
    interface Leds;
    interface SysTime;
    interface Serial;   //used Cricket
  }
}

implementation {
  TPParams* tpparam; 
  NN_DIGIT o[NUMWORDS],x[NUMWORDS];
  
  void initialize() {
    #ifdef EIGHT_BIT_PROCESSOR
      #ifdef SS512K2
        x[64]=0x00;
        x[63]=0x77;
        x[62]=0xa5;
        x[61]=0x61;
        x[60]=0xd8;
        x[59]=0xdd;
        x[58]=0x13;
        x[57]=0x46;
        x[56]=0x0c;
        x[55]=0x9c;
        x[54]=0x1a;
        x[53]=0x4d;
        x[52]=0xac;
        x[51]=0xe5;
        x[50]=0x63;
        x[49]=0x55;
        x[48]=0xd8;
        x[47]=0x91;
        x[46]=0x16;
        x[45]=0xef;
        x[44]=0x93;
        x[43]=0xdb;
        x[42]=0x59;
        x[41]=0x09;
        x[40]=0xf6;
        x[39]=0xcb;
        x[38]=0xa0;
        x[37]=0x76;
        x[36]=0x23;
        x[35]=0xae;
        x[34]=0xed;
        x[33]=0xcf;
        x[32]=0x36;
        x[31]=0x74;
        x[30]=0x89;
        x[29]=0xbd;
        x[28]=0xd6;
        x[27]=0x37;
        x[26]=0x42;
        x[25]=0x7e;
        x[24]=0x41;
        x[23]=0x40;
        x[22]=0xce;
        x[21]=0x0f;
        x[20]=0x1a;
        x[19]=0xe2;
        x[18]=0x63;
        x[17]=0x63;
        x[16]=0xe1;
        x[15]=0x90;
        x[14]=0x0d;
        x[13]=0x74;
        x[12]=0xa3;
        x[11]=0x0a;
        x[10]=0x8a;
        x[9]=0x28;
        x[8]=0x89;
        x[7]=0x3a;
        x[6]=0xbd;
        x[5]=0xb1;
        x[4]=0x08;
        x[3]=0xd7;
        x[2]=0x16;
        x[1]=0x83;
        x[0]=0xe2;
      #endif //ss512k2
    #endif //8-bit processor
  }
  
  command result_t StdControl.init(){
    result_t result = SUCCESS;
    call Leds.init();
    result = rcombine(call Serial.SetStdoutSerial(), result);   //for Cricket
    return SUCCESS;
  }

  command result_t StdControl.start(){
    return call Timer.start(TIMER_ONE_SHOT, 1000);
  }

  command result_t StdControl.stop(){
    return call Timer.stop();
  }

  event result_t Timer.fired(){
    uint32_t time_s, time_f, dt1;
    NN_DIGIT t[NUMWORDS];
    int i;
    
    call ECC.tpinit();
    tpparam = call ECC.get_tpparam();
    initialize();
    
    printf("MicaZ modular operations timing...\n\r");
   
    //additions
    call Leds.yellowToggle();
    time_s = call SysTime.getTime32();
    for (i=0; i<ADD_LOOPS; i++)
       call NN.ModAdd(o, x, x, tpparam->p, NUMWORDS);
    time_f = call SysTime.getTime32();
    dt1 = time_f - time_s;
    printf("%d additions, total time=%ld\n\r",ADD_LOOPS,dt1);
    call Leds.yellowToggle();

    //subtractions
    call Leds.redToggle();
    time_s = call SysTime.getTime32();
    for (i=0; i<SUB_LOOPS; i++)
       call NN.ModSub(o, x, o, tpparam->p, NUMWORDS);
    time_f = call SysTime.getTime32();
    dt1 = time_f - time_s;
    printf("%d subtractions, total time=%ld\n\r",SUB_LOOPS,dt1);
    call Leds.redToggle();
    
    //multiplications
    call NN.ModMult(t, x, x, tpparam->p, NUMWORDS);
    call Leds.yellowToggle();
    time_s = call SysTime.getTime32();
    for (i=0; i<MULT_LOOPS; i++)
       call NN.ModMult(o, x, x, tpparam->p, NUMWORDS);
    time_f = call SysTime.getTime32();
    dt1 = time_f - time_s;
    printf("%d multiplications, total time=%ld\n\r",MULT_LOOPS+1,dt1);
    call Leds.yellowToggle();

    //divisions
    call Leds.redToggle();
    time_s = call SysTime.getTime32();
    for (i=0; i<DIV_LOOPS; i++) 
       //call NN.ModDiv(o, x, t, tpparam->p, NUMWORDS); //depending on which is faster if INLINE_ASM is defined
       call NN.ModDivOpt(o, x, t, tpparam->p, NUMWORDS);
    time_f = call SysTime.getTime32();
    dt1 = time_f - time_s;
    printf("%d divisions, total time=%ld\n\r",DIV_LOOPS,dt1);
    call Leds.redToggle();

    printf("-----------------\n\r");
    call Leds.greenToggle();    
    
    return SUCCESS;
  }

  event result_t Serial.Receive(char * buf, uint8_t data_len) {
    return SUCCESS;
  }

}
