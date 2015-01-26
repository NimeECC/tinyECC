
includes NN;
includes NN2;

#define MAX_ROUNDS 20

module testTPM_java{
  provides interface StdControl;
  uses{
    interface NN;
    interface NN2;
    interface ECC;
    interface TP;
    interface Timer;
    interface Leds;
    interface SendMsg as PubKeyMsg;
    interface SendMsg as PriKeyMsg;
    interface SendMsg as SharKeyMsg;
    interface SendMsg as TimeMsg;
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
  
  TOS_Msg report;
  Point Q;
  NN_DIGIT res[NUMWORDS];
  NN2_NUMBER *f;
  uint8_t coord, type;
  int round_index;
  TPParams* tpparam;

  void get_PublicKey() {
  
    public_key_point_msg *PublicKey;
  
    call Leds.yellowToggle();
  
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
    
    // initialize Tate Pairing
    call TP.init(Q);
    f = (NN2_NUMBER *) malloc(sizeof(NN2_NUMBER));
    
    //report public key
    PublicKey = (public_key_point_msg *)report.data;
    #ifdef SS192K2
    	PublicKey->curve = (1+9+2);
    #endif // SS192K2 
    #ifdef SS512K2
    	PublicKey->curve = (5+1+2);
    #endif // SS512K2
    PublicKey->len = KEYDIGITS*NN_DIGIT_LEN;
    PublicKey->coord = 1; coord = 1;
    call NN.Encode(PublicKey->c, KEYDIGITS*NN_DIGIT_LEN, Q.x, KEYDIGITS);
    call PubKeyMsg.send(TOS_UART_ADDR, sizeof(public_key_point_msg), &report); // send x-coordinate
  }
  
  void give_PrivateKey() {
    private_key_point_msg *PrivateKey;
    
    // report private key
    PrivateKey = (private_key_point_msg *)report.data;
    PrivateKey->len = KEYDIGITS*NN_DIGIT_LEN;
    PrivateKey->coord = 1; coord = 1;
    call NN.Encode(PrivateKey->c, KEYDIGITS*NN_DIGIT_LEN, tpparam->P.x, KEYDIGITS);
    call PriKeyMsg.send(TOS_UART_ADDR, sizeof(private_key_point_msg), &report); // send x-coordinate
  }

  command result_t StdControl.init(){
    call Leds.init();
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
    tpparam = call ECC.get_tpparam(); // get the curve parameters, used to know the P point
    return call Timer.start(TIMER_ONE_SHOT, 1000);
  }

  command result_t StdControl.stop(){
    return call Timer.stop();
  }

  event result_t Timer.fired(){
    
    get_PublicKey();
    return SUCCESS;
  }

  event result_t PubKeyMsg.sendDone(TOS_MsgPtr sent, result_t success) {
    public_key_point_msg *PublicKey;
    
    if (coord==1) { // x-coordinate sent
        PublicKey = (public_key_point_msg *)report.data;
    	PublicKey->len = KEYDIGITS*NN_DIGIT_LEN;
	PublicKey->coord = 2; coord = 2;
	call NN.Encode(PublicKey->c, KEYDIGITS*NN_DIGIT_LEN, Q.y, KEYDIGITS);
    	call PubKeyMsg.send(TOS_UART_ADDR, sizeof(public_key_point_msg), &report); // send y-coordinate
    }
    
    else // y-coordinate
    	give_PrivateKey();

    return SUCCESS;
  }
  
  event result_t PriKeyMsg.sendDone(TOS_MsgPtr sent, result_t success) {
      private_key_point_msg *PrivateKey;
      tp_time_msg *tpTime;
      uint32_t time_s, time_f, dt;
      
      if (coord==1) { // x-coordinate sent
        PrivateKey = (private_key_point_msg *)report.data;
      	PrivateKey->len = KEYDIGITS*NN_DIGIT_LEN;
  	PrivateKey->coord = 2; coord = 2;
  	call NN.Encode(PrivateKey->c, KEYDIGITS*NN_DIGIT_LEN, tpparam->P.y, KEYDIGITS);
      	call PriKeyMsg.send(TOS_UART_ADDR, sizeof(public_key_point_msg), &report); // send y-coordinate
      }
      
      else { // y-coordinate

    	#ifdef IMOTE2
	    time_s = call SysTime64.getTime32();
	#endif
	call TP.Miller(f);
	#ifdef IMOTE2
	    time_f = call SysTime64.getTime32();
	#endif
    	dt = time_f - time_s;
    	
    	tpTime = (tp_time_msg *)report.data;
	tpTime->type = 1; type = 1;
	tpTime->t = dt;
    	call TimeMsg.send(TOS_UART_ADDR, sizeof(tp_time_msg), &report); 
        }
    return SUCCESS;
  }

  event result_t SharKeyMsg.sendDone(TOS_MsgPtr sent, result_t success) {

   if(round_index < MAX_ROUNDS){
	get_PublicKey();
	round_index++;
	}
   else { 
	call Leds.yellowOff(); 
	call Leds.greenOn(); 
	}
    return SUCCESS;
  }

  event result_t TimeMsg.sendDone(TOS_MsgPtr sent, result_t success) {
   tp_time_msg *tpTime;
   shared_key_msg *SharedKey;
   uint32_t time_s, time_f, dt;
   
   if (type==1) {
       #ifdef IMOTE2
   	   time_s = call SysTime64.getTime32();
       #endif
       call TP.final_expon(res,f);
       #ifdef IMOTE2
   	    time_f = call SysTime64.getTime32();
       #endif
       dt = time_f - time_s;
   
       tpTime = (tp_time_msg *)report.data;
       tpTime->type = 2; type = 2;
       tpTime->t = dt;
       call TimeMsg.send(TOS_UART_ADDR, sizeof(tp_time_msg), &report);   
   }
   else if (type==2) {
   	SharedKey = (shared_key_msg *)report.data;
       	SharedKey->sk_len = KEYDIGITS*NN_DIGIT_LEN;
       	call NN.Encode(SharedKey->sk, KEYDIGITS*NN_DIGIT_LEN, res, KEYDIGITS);
    	call SharKeyMsg.send(TOS_UART_ADDR, sizeof(shared_key_msg), &report); // send shared key
   }

   return SUCCESS;
  }

#ifdef IMOTE2
  async event result_t SysTime64.alarmFired(uint32_t val){
    return SUCCESS;
  }
#endif

}

