/*
 * $Id: testECIESM.nc,v 1.4 2007/09/18 22:43:33 aliu3 Exp $
 */

includes ECIES;


#ifdef TEST_VECTOR
#define MSG_LEN 20
#else
#define MSG_LEN 40
#endif

#define MAX_M_LEN 41
#define HMAC_LEN 20

#define MAX_ROUNDS 10

module testECIESM{
  provides interface StdControl;
  uses{
    interface NN;
    interface ECC;
    interface ECIES;
    interface Timer as myTimer;
    interface Random;
    interface Leds;

#ifndef DEBUG_SERIAL
    interface SendMsg as PubKeyMsg;
    interface SendMsg as PriKeyMsg;
    interface SendMsg as Uint8Msg;
    interface SendMsg as TimeMsg;
#endif

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
  Point PublicKey;
  NN_DIGIT PrivateKey[NUMWORDS];
  uint32_t t;
  uint8_t M[MAX_M_LEN];
  int M_len;
  uint8_t C[2*KEYDIGITS*NN_DIGIT_LEN + 1 + MAX_M_LEN + HMAC_LEN];
  int C_len;
  uint8_t dM[MAX_M_LEN];
  int round_index = 1;
  uint8_t type;

#ifdef DEBUG_SERIAL
#ifdef PLATFORM_IMOTE2
  void print_str(char *pstr){
    trace(DBG_USR1, "%s", pstr);
  }

  void print_uint8(uint8_t *num, int len) {
    int i;
    for (i=len-1; i>=0; i--) trace(DBG_USR1,"%02x",*(num+i));
    trace(DBG_USR1,"\n\r");
  }
  void print_val(NN_DIGIT *num, int len) {
    int i;
    for (i=len-1; i>=0; i--) trace(DBG_USR1,"%08x",*(num+i));
    trace(DBG_USR1,"\n\r");
  }

#endif
#ifdef PLATFORM_MICAZ
  void print_str(char *pstr){
    printf("%s", pstr);
  }

  void print_uint8(uint8_t *num, int len){
    int i;
    for(i=0; i<len; i++){
      printf("%02x", num[len-i-1]);
    }
    printf("\n\r");
  }


  void print_val(NN_DIGIT *num, int len){
    int i;
    for(i=0; i<len; i++){
      printf("%02x", num[len-i-1]);
    }
    printf("\n\r");
  }
#endif
#endif

  //generate message and init ecc module
  void init_data(){
    int i;
    uint32_t time_a, time_b;
    uint8_msg *pMsg;


    t = 0;
    type = 0;

    //init private key
    memset(PrivateKey, 0, NUMWORDS*NN_DIGIT_LEN);
    //init public key
    memset(PublicKey.x, 0, NUMWORDS*NN_DIGIT_LEN);
    memset(PublicKey.y, 0, NUMWORDS*NN_DIGIT_LEN);

#ifdef TEST_VECTOR
    M[0] = 0x61;
    M[1] = 0x62;
    M[2] = 0x63;
    M[3] = 0x64;
    M[4] = 0x65;
    M[5] = 0x66;
    M[6] = 0x67;
    M[7] = 0x68;
    M[8] = 0x69;
    M[9] = 0x6A;
    M[10] = 0x6B;
    M[11] = 0x6C;
    M[12] = 0x6D;
    M[13] = 0x6E;
    M[14] = 0x6F;
    M[15] = 0x70;
    M[16] = 0x71;
    M[17] = 0x72;
    M[18] = 0x73;
    M[19] = 0x74;
    M_len = 20;
#else
    for (i=0; i<MAX_M_LEN; i++){
      M[i] = call Random.rand();
    }
    M_len = MSG_LEN;
#endif

#ifdef PLATFORM_MICAZ
    time_a = call SysTime.getTime32();
#endif
#ifdef PLATFORM_TELOSB
    time_a = call LocalTime.read();
#endif
#ifdef PLATFORM_IMOTE2
    time_a = call SysTime64.getTime32();
#endif

    call ECC.init();

#ifdef PLATFORM_MICAZ
    time_b = call SysTime.getTime32();
#endif
#ifdef PLATFORM_TELOSB
    time_b = call LocalTime.read();
#endif
#ifdef PLATFORM_IMOTE2
    time_b = call SysTime64.getTime32();
#endif
    t = time_b - time_a;

    pMsg = (uint8_msg *)report.data;
    pMsg->len = M_len;
    memcpy(pMsg->content, M, M_len);
    call Uint8Msg.send(TOS_UART_ADDR, sizeof(uint8_msg), &report);

  }

  //generate private key
  void V_PrivateKey(){
    private_key_msg *pPrivateKey;

#ifdef TEST_VECTOR  //TEST_VECTOR

#ifdef EIGHT_BIT_PROCESSOR
    PrivateKey[20] = 0x0;
    PrivateKey[19] = 0x45;
    PrivateKey[18] = 0xFB;
    PrivateKey[17] = 0x58;
    PrivateKey[16] = 0xA9;
    PrivateKey[15] = 0x2A;
    PrivateKey[14] = 0x17;
    PrivateKey[13] = 0xAD;
    PrivateKey[12] = 0x4B;
    PrivateKey[11] = 0x15;
    PrivateKey[10] = 0x10;
    PrivateKey[9] = 0x1C;
    PrivateKey[8] = 0x66;
    PrivateKey[7] = 0xE7;
    PrivateKey[6] = 0x4F;
    PrivateKey[5] = 0x27;
    PrivateKey[4] = 0x7E;
    PrivateKey[3] = 0x2B;
    PrivateKey[2] = 0x46;
    PrivateKey[1] = 0x08;
    PrivateKey[0] = 0x66;
#elif defined(SIXTEEN_BIT_PROCESSOR)
    PrivateKey[10] = 0x0;
    PrivateKey[9] = 0x45FB;
    PrivateKey[8] = 0x58A9;
    PrivateKey[7] = 0x2A17;
    PrivateKey[6] = 0xAD4B;
    PrivateKey[5] = 0x1510;
    PrivateKey[4] = 0x1C66;
    PrivateKey[3] = 0xE74F;
    PrivateKey[2] = 0x277E;
    PrivateKey[1] = 0x2B46;
    PrivateKey[0] = 0x0866;
#elif defined(THIRTYTWO_BIT_PROCESSOR)
    PrivateKey[5] = 0x0;
    PrivateKey[4] = 0x45FB58A9;
    PrivateKey[3] = 0x2A17AD4B;
    PrivateKey[2] = 0x15101C66;
    PrivateKey[1] = 0xE74F277E;
    PrivateKey[0] = 0x2B460866;
#endif


#else//random PrivateKey
    call ECC.gen_private_key(PrivateKey);
#endif  //end of test vector

    //report private key
    pPrivateKey = (private_key_msg *)report.data;
    pPrivateKey->len = KEYDIGITS*NN_DIGIT_LEN;
    call NN.Encode(pPrivateKey->d, KEYDIGITS*NN_DIGIT_LEN, PrivateKey, KEYDIGITS);
    call PriKeyMsg.send(TOS_UART_ADDR, sizeof(private_key_msg), &report);

  }


  void V_PublicKey(){
    uint32_t time_a, time_b;
    public_key_msg *pPublicKey;

#ifdef PLATFORM_MICAZ
    time_a = call SysTime.getTime32();
#endif
#ifdef PLATFORM_TELOSB
    time_a = call LocalTime.read();
#endif
#ifdef PLATFORM_IMOTE2
    time_a = call SysTime64.getTime32();
#endif

    call ECC.gen_public_key(&PublicKey, PrivateKey);

#ifdef PLATFORM_MICAZ
    time_b = call SysTime.getTime32();
#endif
#ifdef PLATFORM_TELOSB
    time_b = call LocalTime.read();
#endif
#ifdef PLATFORM_IMOTE2
    time_b = call SysTime64.getTime32();
#endif
    t = time_b - time_a;

#ifdef DEBUG_SERIAL
    print_str("PrivateKey: ");
    print_val(PrivateKey, NUMWORDS);
    print_str("PublicKey: ");
    print_val(PublicKey.x, NUMWORDS);
    print_val(PublicKey.y, NUMWORDS);
#else
    pPublicKey = (public_key_msg *)report.data;
    pPublicKey->len = KEYDIGITS*NN_DIGIT_LEN;
    call NN.Encode(pPublicKey->x, KEYDIGITS*NN_DIGIT_LEN, PublicKey.x, KEYDIGITS);
    call NN.Encode(pPublicKey->y, KEYDIGITS*NN_DIGIT_LEN, PublicKey.y, KEYDIGITS);
    call PubKeyMsg.send(TOS_UART_ADDR, sizeof(public_key_msg), &report);
#endif
  }


  void U_encrypt(){
    uint32_t time_a, time_b;
    uint8_msg *pMsg;

    type = 2;

#ifdef PLATFORM_MICAZ
    time_a = call SysTime.getTime32();
#endif
#ifdef PLATFORM_TELOSB
    time_a = call LocalTime.read();
#endif
#ifdef PLATFORM_IMOTE2
    time_a = call SysTime64.getTime32();
#endif

    C_len = call ECIES.encrypt(C, 2*KEYDIGITS*NN_DIGIT_LEN + 1 + M_len + HMAC_LEN, M, M_len, &PublicKey); 
    
#ifdef PLATFORM_MICAZ
    time_b = call SysTime.getTime32();
#endif
#ifdef PLATFORM_TELOSB
    time_b = call LocalTime.read();
#endif
#ifdef PLATFORM_IMOTE2
    time_b = call SysTime64.getTime32();
#endif
    t = time_b - time_a;

    pMsg = (uint8_msg *)report.data;
    pMsg->len = C_len;
    memcpy(pMsg->content, C, C_len);
    call Uint8Msg.send(TOS_UART_ADDR, sizeof(uint8_msg), &report);
  }


  void V_decrypt(){
    uint32_t time_a, time_b;
    int dM_len = MAX_M_LEN;
    uint8_msg *pMsg;

    type = 3;

#ifdef PLATFORM_MICAZ
    time_a = call SysTime.getTime32();
#endif
#ifdef PLATFORM_TELOSB
    time_a = call LocalTime.read();
#endif
#ifdef PLATFORM_IMOTE2
    time_a = call SysTime64.getTime32();
#endif

    dM_len = call ECIES.decrypt(dM, dM_len, C, C_len, PrivateKey); 
    
#ifdef PLATFORM_MICAZ
    time_b = call SysTime.getTime32();
#endif
#ifdef PLATFORM_TELOSB
    time_b = call LocalTime.read();
#endif
#ifdef PLATFORM_IMOTE2
    time_b = call SysTime64.getTime32();
#endif
    t = time_b - time_a;

    pMsg = (uint8_msg *)report.data;
    pMsg->len = dM_len;
    memcpy(pMsg->content, dM, dM_len);
    call Uint8Msg.send(TOS_UART_ADDR, sizeof(uint8_msg), &report);
     
  }




  command result_t StdControl.init(){
    call Random.init();
    call Leds.init();
#ifdef DEBUG_SERIAL
#ifdef PLATFORM_MICAZ
    call Serial.SetStdoutSerial();
#endif
#endif
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
    //call myTimer.start(TIMER_REPEAT, 5000);
    return SUCCESS;
  }

  command result_t StdControl.stop(){
    call myTimer.stop();
    return SUCCESS;
  }

  event result_t myTimer.fired(){
    init_data();
    /*
    V_PrivateKey();
    V_PublicKey();
    U_encrypt();
    V_decrypt();
    */
    return SUCCESS;
  }

  event result_t TimeMsg.sendDone(TOS_MsgPtr sent, result_t success) {
    if (type == 0){
      V_PrivateKey(); 
    }else if (type == 1){
      U_encrypt();
    }else if (type == 2){
      V_decrypt();
    }else if (type == 3){
      if(round_index < MAX_ROUNDS){
	init_data();
	round_index++;
      }
    }
    return SUCCESS;
  }

  event result_t PriKeyMsg.sendDone(TOS_MsgPtr sent, result_t success) {
    V_PublicKey();
    return SUCCESS;
  }

  event result_t PubKeyMsg.sendDone(TOS_MsgPtr sent, result_t success) {
    time_msg *pTime;

    type = 1;
    pTime = (time_msg *)report.data;
    pTime->type = 1;
    pTime->t = t;
    pTime->pass = 0;
    call TimeMsg.send(TOS_UART_ADDR, sizeof(time_msg), &report);
    return SUCCESS;
  }

  event result_t Uint8Msg.sendDone(TOS_MsgPtr sent, result_t success) {
    time_msg *pTime;

    pTime = (time_msg *)report.data;
    pTime->type = type;
    pTime->t = t;
    pTime->pass = 0;
    call TimeMsg.send(TOS_UART_ADDR, sizeof(time_msg), &report);
    return SUCCESS;
  }
  

#ifdef PLATFORM_IMOTE2
  async event result_t SysTime64.alarmFired(uint32_t val){
    return SUCCESS;
  }
#endif

#ifdef DEBUG_SERIAL
#ifdef PLATFORM_MICAZ
  event result_t Serial.Receive(char * buf, uint8_t data_len){
    return SUCCESS;
  }
#endif  
#endif
}

