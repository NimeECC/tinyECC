 
includes NN;
includes NN2;

#define MAX_ROUNDS 1

module testTPM{
  provides interface StdControl;
  uses{
    interface NN;
    interface NN2;
    interface TP;
    interface Timer;
    interface Leds;

#ifdef IMOTE2
    interface SysTime64;
#ifdef MANUALFREQ
    interface DVFS;
    interface PMIC;
#endif
#endif

#ifdef MICA
    interface SysTime;
    interface Serial;
#endif
  }
}

implementation {
  
  Point Q;
  NN_DIGIT res[NUMWORDS];
  NN2_NUMBER f;
  int round_index;

#ifdef IMOTE2
  void print_val(NN_DIGIT *num) {
    int i;
    for (i=NUMWORDS-2; i>=0; i--) trace(DBG_USR1,"%08X  ",*(num+i));
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

  
  void get_PublicKey() {
#ifdef MICA
#ifdef SS192K2
    
#else  //ss512k2
    Q.x[64]=0x00;
    Q.x[63]=0x0B;
    Q.x[62]=0x53;
    Q.x[61]=0x48;
    Q.x[60]=0x39;
    Q.x[59]=0x95;
    Q.x[58]=0x7A;
    Q.x[57]=0xD9;
    Q.x[56]=0x0C;
    Q.x[55]=0x6C;
    Q.x[54]=0xD3;
    Q.x[53]=0xA7;
    Q.x[52]=0x1A;
    Q.x[51]=0x36;
    Q.x[50]=0x4A;
    Q.x[49]=0x03;
    Q.x[48]=0x13;
    Q.x[47]=0x58;
    Q.x[46]=0xA1;
    Q.x[45]=0x3D;
    Q.x[44]=0x0B;
    Q.x[43]=0x4F;
    Q.x[42]=0x26;
    Q.x[41]=0xDD;
    Q.x[40]=0x26;
    Q.x[39]=0xF5;
    Q.x[38]=0xBA;
    Q.x[37]=0xB6;
    Q.x[36]=0xA8;
    Q.x[35]=0x52;
    Q.x[34]=0xF4;
    Q.x[33]=0xCE;
    Q.x[32]=0x8C;
    Q.x[31]=0x92;
    Q.x[30]=0xD8;
    Q.x[29]=0xC8;
    Q.x[28]=0x4E;
    Q.x[27]=0xEF;
    Q.x[26]=0xE0;
    Q.x[25]=0xA9;
    Q.x[24]=0xF0;
    Q.x[23]=0xDD;
    Q.x[22]=0xBE;
    Q.x[21]=0xE2;
    Q.x[20]=0xEA;
    Q.x[19]=0xBE;
    Q.x[18]=0x70;
    Q.x[17]=0xEF;
    Q.x[16]=0x0E;
    Q.x[15]=0x21;
    Q.x[14]=0xE9;
    Q.x[13]=0x02;
    Q.x[12]=0xFE;
    Q.x[11]=0x27;
    Q.x[10]=0x59;
    Q.x[9]=0x5F;
    Q.x[8]=0x56;
    Q.x[7]=0xB7;
    Q.x[6]=0xFA;
    Q.x[5]=0x10;
    Q.x[4]=0xB8;
    Q.x[3]=0xFB;
    Q.x[2]=0x97;
    Q.x[1]=0x76;
    Q.x[0]=0x9D;
    

    Q.y[64]=0x00;
    Q.y[63]=0x70;
    Q.y[62]=0x32;
    Q.y[61]=0xE2;
    Q.y[60]=0x62;
    Q.y[59]=0xB0;
    Q.y[58]=0x68;
    Q.y[57]=0x12;
    Q.y[56]=0x93;
    Q.y[55]=0x5C;
    Q.y[54]=0xFE;
    Q.y[53]=0x57;
    Q.y[52]=0x3F;
    Q.y[51]=0xC8;
    Q.y[50]=0x5A;
    Q.y[49]=0x98;
    Q.y[48]=0xE2;
    Q.y[47]=0xBC;
    Q.y[46]=0xA9;
    Q.y[45]=0xC1;
    Q.y[44]=0x7F;
    Q.y[43]=0x85;
    Q.y[42]=0x77;
    Q.y[41]=0x97;
    Q.y[40]=0x3D;
    Q.y[39]=0xAA;
    Q.y[38]=0xCE;
    Q.y[37]=0xA5;
    Q.y[36]=0xF2;
    Q.y[35]=0xE7;
    Q.y[34]=0xCA;
    Q.y[33]=0xAD;
    Q.y[32]=0xB2;
    Q.y[31]=0xA3;
    Q.y[30]=0xCC;
    Q.y[29]=0x42;
    Q.y[28]=0x94;
    Q.y[27]=0xA4;
    Q.y[26]=0x10;
    Q.y[25]=0x9A;
    Q.y[24]=0x41;
    Q.y[23]=0x25;
    Q.y[22]=0x0E;
    Q.y[21]=0x2E;
    Q.y[20]=0x72;
    Q.y[19]=0x25;
    Q.y[18]=0x18;
    Q.y[17]=0x90;
    Q.y[16]=0xAB;
    Q.y[15]=0x2E;
    Q.y[14]=0xCC;
    Q.y[13]=0x9D;
    Q.y[12]=0x35;
    Q.y[11]=0xD4;
    Q.y[10]=0xFF;
    Q.y[9]=0x88;
    Q.y[8]=0x7D;
    Q.y[7]=0x44;
    Q.y[6]=0x01;
    Q.y[5]=0x41;
    Q.y[4]=0xFD;
    Q.y[3]=0xD0;
    Q.y[2]=0x8F;
    Q.y[1]=0x1B;
    Q.y[0]=0x61;
#endif
#endif

    #ifdef IMOTE2
    #ifdef SS192K2
    
    Q.x[6]=0x00000000;
    Q.x[5]=0xb2421fda;
    Q.x[4]=0x744bb179;
    Q.x[3]=0x202d4d5b;
    Q.x[2]=0xb09b5a1f;
    Q.x[1]=0x8b184eb7;
    Q.x[0]=0xe76167c6;
        
    Q.y[6]=0x00000000;
    Q.y[5]=0xdda6a930;
    Q.y[4]=0x31c53341;
    Q.y[3]=0xecf6ee19;
    Q.y[2]=0x6a6fdda9;
    Q.y[1]=0x81a1dbd3;
    Q.y[0]=0xcca86596;
    
    #else
    #ifdef SS512K2
    
    Q.x[16]=0x00000000;
    Q.x[15]=0x0B534839;
    Q.x[14]=0x957AD90C;
    Q.x[13]=0x6CD3A71A;
    Q.x[12]=0x364A0313;
    Q.x[11]=0x58A13D0B;
    Q.x[10]=0x4F26DD26;
    Q.x[9]=0xF5BAB6A8;
    Q.x[8]=0x52F4CE8C;
    Q.x[7]=0x92D8C84E;
    Q.x[6]=0xEFE0A9F0;
    Q.x[5]=0xDDBEE2EA;
    Q.x[4]=0xBE70EF0E;
    Q.x[3]=0x21E902FE;
    Q.x[2]=0x27595F56;
    Q.x[1]=0xB7FA10B8;
    Q.x[0]=0xFB97769D;
    
    Q.y[16]=0x00000000;
    Q.y[15]=0x7032E262;
    Q.y[14]=0xB0681293;
    Q.y[13]=0x5CFE573F;
    Q.y[12]=0xC85A98E2;
    Q.y[11]=0xBCA9C17F;
    Q.y[10]=0x8577973D;
    Q.y[9]=0xAACEA5F2;
    Q.y[8]=0xE7CAADB2;
    Q.y[7]=0xA3CC4294;
    Q.y[6]=0xA4109A41;
    Q.y[5]=0x250E2E72;
    Q.y[4]=0x251890AB;
    Q.y[3]=0x2ECC9D35;
    Q.y[2]=0xD4FF887D;
    Q.y[1]=0x440141FD;
    Q.y[0]=0xD08F1B61;
    
    #endif // SS192K2 
    #endif // SS512K2
    #endif // IMOTE2  
  }

  command result_t StdControl.init(){
    call Leds.init();
#ifdef MICA
    call Serial.SetStdoutSerial();
#endif
    return SUCCESS;
  }

  command result_t StdControl.start(){
    round_index = 1;
#ifdef IMOTE2
#ifdef MANUALFREQ
    // set the processor frequency to the define in ECC.h value
    call DVFS.SwitchCoreFreq(CORE_FREQ, CORE_BUS);		
#endif
#endif
    return call Timer.start(TIMER_ONE_SHOT, 1000);
  }

  command result_t StdControl.stop(){
    return call Timer.stop();
  }

  event result_t Timer.fired(){
    
    uint32_t time_s, time_f, dt1, dt2;
    

    get_PublicKey();
    call TP.init(Q);
    call Leds.yellowToggle();

    while (round_index<=MAX_ROUNDS) {
    
#ifdef IMOTE2
      time_s = call SysTime64.getTime32();
#endif
#ifdef MICA
      time_s = call SysTime.getTime32();
#endif
      call TP.Miller(&f);
      
#ifdef IMOTE2
      time_f = call SysTime64.getTime32();
#endif
#ifdef MICA
      time_f = call SysTime.getTime32();
#endif
      dt1 = time_f - time_s;
    
#ifdef IMOTE2
      time_s = call SysTime64.getTime32();
#endif
#ifdef MICA
      time_s = call SysTime.getTime32();
#endif
      call TP.final_expon(res,&f);
#ifdef IMOTE2
      time_f = call SysTime64.getTime32();
#endif
#ifdef MICA
      time_f = call SysTime.getTime32();
#endif
      dt2 = time_f - time_s;
      
#ifdef IMOTE2
      if (round_index==1) { trace(DBG_USR1,"\n\rTP= "); print_val(res); }
      trace(DBG_USR1,"round %d, %.6f, %.6f, %.6f \n\r",round_index,(float)((double)dt1/3250000),
	    (float)((double)dt2/3250000),(float)(((double)dt1+(double)dt2)/3250000));
#endif
#ifdef MICA
      
      printf("\n\rTP=\n\r");
      print_val(res);
      printf("time: miller: %ld, exp: %ld, total: %ld\n\r", dt1, dt2, dt1+dt2);
      
#endif

      round_index++;
      
    }
    
    call Leds.yellowOff();
    call Leds.greenToggle();
    return SUCCESS;
  }
  
#ifdef IMOTE2
  async event result_t SysTime64.alarmFired(uint32_t val){
    return SUCCESS;
  }
#endif
#ifdef MICA
  event result_t Serial.Receive(char * buf, uint8_t data_len){
    return SUCCESS;
  }
#endif  
  
}
