/*
 * $Id: testBarrettM.nc,v 1.1 2007/11/01 23:06:48 aliu3 Exp $
 */

#define MAX_ROUNDS 100

module testBarrettM{
  provides interface StdControl;
  uses{
    interface NN;
    interface ECC;
    interface Timer as myTimer;
    interface Random;
    interface Leds;
    interface SendMsg as PacketMsg;
    interface SendMsg as TimeMsg;
#ifdef PLATFORM_MICAZ
    interface SysTime;
#ifdef DEBUG_SERIAL
    interface Serial;
#endif
#endif
#ifdef PLATFORM_TELOSB
    interface LocalTime;
#endif
#ifdef PLATFORM_IMOTE2
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
  NN_DIGIT a[NUMWORDS];
  NN_DIGIT b[2*NUMWORDS];
  Params *param;
  uint8_t type;
  uint32_t t;


  void init_data();
  void ecc_init();
  void testMod();

  void init_data(){

    t = 0;

    call ECC.init();
    param = call ECC.get_param();
    testMod();
  }

  void testMod(){
    int i,j;
    uint32_t time_a, time_b;
    time_msg *pTime;

    type = 0;

    for(i=0; i<MAX_ROUNDS; i++){

      memset(a, 0, NUMWORDS*NN_DIGIT_LEN);
      memset(b, 0, 2*NUMWORDS*NN_DIGIT_LEN);
      for(j=0; j<2*KEYDIGITS; j++){
	//generate b
#ifdef THIRTYTWO_BIT_PROCESSOR
	b[j] = ((uint32_t)call Random.rand() << 16)^((uint32_t)call Random.rand());
#else
	b[j] = (NN_DIGIT)call Random.rand();
#endif

      }
      
#ifdef PLATFORM_MICAZ
      time_a = call SysTime.getTime32();
#endif
#ifdef PLATFORM_TELOSB
      time_a = call LocalTime.read();
#endif
#ifdef PLATFORM_IMOTE2
      time_a = call SysTime64.getTime32();
#endif
      
      call NN.Mod(a, b, 2*NUMWORDS, param->p, NUMWORDS);


#ifdef PLATFORM_MICAZ
      time_b = call SysTime.getTime32();
#endif
#ifdef PLATFORM_TELOSB
      time_b = call LocalTime.read();
#endif
#ifdef PLATFORM_IMOTE2
      time_b = call SysTime64.getTime32();
#endif
      
      t = (time_b - time_a) + t;
      
    }
    pTime = (time_msg *)report.data;
    pTime->type = 0;
    pTime->t = t;
    pTime->pass = 0;
    call TimeMsg.send(TOS_UART_ADDR, sizeof(time_msg), &report);  
  }


  command result_t StdControl.init(){
    call Random.init();
    call Leds.init();
    return SUCCESS;
  }

  command result_t StdControl.start(){

#ifdef PLATFORM_IMOTE2
#ifdef MANUALFREQ
    // set the processor frequency to the define in ECC.h value
    call DVFS.SwitchCoreFreq(CORE_FREQ, CORE_BUS);		
#endif
#endif
    call myTimer.start(TIMER_ONE_SHOT, 5000);

    return SUCCESS;
  }

  command result_t StdControl.stop(){
    call myTimer.stop();
    return SUCCESS;
  }

  event result_t myTimer.fired(){

    init_data();
    return SUCCESS;
  }


  event result_t PacketMsg.sendDone(TOS_MsgPtr sent, result_t success) {
    time_msg *pTime;

    type = 3;
    pTime = (time_msg *)report.data;
    pTime->type = 3;
    pTime->t = t;
    pTime->pass = 0;
    call TimeMsg.send(TOS_UART_ADDR, sizeof(time_msg), &report);
    return SUCCESS;
  }

  event result_t TimeMsg.sendDone(TOS_MsgPtr sent, result_t success) {

    return SUCCESS;
  }

#ifdef PLATFORM_IMOTE2
  async event result_t SysTime64.alarmFired(uint32_t val){
    return SUCCESS;
  }
#endif

}

