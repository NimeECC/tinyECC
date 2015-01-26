 
includes NN;

#define MAX_ROUNDS 5

module testExpM{
  provides interface StdControl;
  uses{
    interface NN;
    interface ECC;
    interface Timer;
    interface Leds;
#ifdef MICA
    interface SysTime;
    interface Serial;   //used Cricket
#endif
#ifdef IMOTE2
    interface SysTime64;
    #ifdef MANUALFREQ
    	interface DVFS;
    	interface PMIC;
    #endif
#endif
  }
}

implementation {
  TPParams* tpparam; 
  NN_DIGIT o[NUMWORDS],x[NUMWORDS],e[NUMWORDS];
  int round_index;

  #ifdef IMOTE2
  void print_val(NN_DIGIT *num) {
    int i;
    for (i=NUMWORDS-2; i>=0; i--) trace(DBG_USR1,"%8X  ",*(num+i));
    trace(DBG_USR1,"\n\r");
  }
  #endif
  
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
        
        memset(e, 0, NUMWORDS*NN_DIGIT_LEN);
	e[19]=0x47; // 160-bit
	e[9]=0x47; // 80-bit
	e[7]=0x47; // 64-bit
        e[3]=0x47; // 32-bit
        e[2]=0x34;
        e[1]=0x8e;
        e[0]=0x68;
      #endif //ss512k2
    #endif //8-bit processor
    
    #ifdef THIRTYTWO_BIT_PROCESSOR
      #ifdef SS512K2
        x[16]=0x00000000;
        x[15]=0x77a561d8;
        x[14]=0xdd13460c;
        x[13]=0x9c1a4dac;
        x[12]=0xe56355d8;
        x[11]=0x9116ef93;
        x[10]=0xdb5909f6;
        x[9]=0xcba07623;
        x[8]=0xaeedcf36;
        x[7]=0x7489bdd6;
        x[6]=0x37427e41;
        x[5]=0x40ce0f1a;
        x[4]=0xe26363e1;
        x[3]=0x900d74a3;
        x[2]=0x0a8a2889;
        x[1]=0x3abdb108;
        x[0]=0xd71683e2;
        
        memset(e, 0, NUMWORDS*NN_DIGIT_LEN);
	//e[4]=0x47000000; //160-bit
        e[0]=0x47348e68;  
      #endif //ss512k2
    #endif //32-bit processor
  
  }
  
  command result_t StdControl.init(){
    result_t result = SUCCESS;
    call Leds.init();
    #ifdef MICA
      result = rcombine(call Serial.SetStdoutSerial(), result);   //for Cricket
    #endif
    return SUCCESS;
  }

  command result_t StdControl.start(){
    round_index = 1;
    #ifdef IMOTE2
          #ifdef MANUALFREQ
	  	// set the processor frequency to the define in NN.h value
    		call DVFS.SwitchCoreFreq(CORE_FREQ, CORE_BUS);		
  	  #endif
    #endif
    return call Timer.start(TIMER_ONE_SHOT, 1000);
  }

  command result_t StdControl.stop(){
    return call Timer.stop();
  }

  event result_t Timer.fired(){
    uint32_t time_s, time_f, dt1;
    NN_DIGIT inv2[NUMWORDS], two[NUMWORDS];
    
    memset(inv2, 0, NUMWORDS*NN_DIGIT_LEN);
    memset(two, 0, NUMWORDS*NN_DIGIT_LEN);
    two[0] = 0x02;
    
    call ECC.tpinit();
    tpparam = call ECC.get_tpparam();
    initialize();
    call NN.ModInv(inv2, two, tpparam->p, NUMWORDS);
   
    call Leds.yellowToggle();

    while (round_index<=MAX_ROUNDS) {
    
    #ifdef MICA
        time_s = call SysTime.getTime32();
    #endif
    #ifdef IMOTE2
	 time_s = call SysTime64.getTime32();
    #endif
    
    call NN.LucExp(o,x,e,inv2,tpparam->p,NUMWORDS); // Lucas exponentiation
    
    #ifdef MICA
        time_f = call SysTime.getTime32();
    #endif
    #ifdef IMOTE2
         time_f = call SysTime64.getTime32();
    #endif
    dt1 = time_f - time_s;

    #ifdef MICA
	if (round_index==1) { 
		printf("x^e=%2X%2X...%2X%2X \n\r",o[NUMWORDS-2],o[NUMWORDS-3],o[1],o[0]);
		printf("Exp time=\n\r"); }
	printf("%ld\n\r",dt1);
    #endif
    
    
    #ifdef IMOTE2
      if (round_index==1) { trace(DBG_USR1,"\n\r x^e= "); print_val(o); }
      trace(DBG_USR1,"Exp time=%.6f \n\r",(float)(((double)dt1)/3250000));
    #endif
    
    call Leds.yellowToggle();
    
    round_index++;
    }
    
    #ifdef MICA
      printf("ticks\n\r");
      printf("-----------------\n\r");
    #endif

    call Leds.yellowOff();
    call Leds.greenToggle();    
    
    return SUCCESS;
  }

#ifdef MICA // for serial debug
  event result_t Serial.Receive(char * buf, uint8_t data_len) {
    return SUCCESS;
  }
#endif

#ifdef IMOTE2
  async event result_t SysTime64.alarmFired(uint32_t val){
    return SUCCESS;
  }
#endif

}
