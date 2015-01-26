#ifdef TEST_VECTOR
#define MSG_LEN 3
#else
#define MSG_LEN 52
#endif

#define MAX_ROUNDS 10

module testECDSAtM{
  provides interface StdControl;
  uses{
    interface NN;
    interface ECC;
    interface ECDSA;
    interface Timer as myTimer;
    interface Random;
    interface Leds;
#ifdef MICA
    interface SysTime;
#ifdef DEBUG_SERIAL
    interface Serial;
#endif
#endif
#ifdef TELOSB
    interface LocalTime;
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
  Point PublicKey;
  NN_DIGIT PrivateKey[NUMWORDS];
  uint8_t message[MSG_LEN];
  NN_DIGIT r[NUMWORDS];
  NN_DIGIT s[NUMWORDS];
  uint8_t type;
  uint32_t t;
  uint8_t pass;
  uint16_t round_index;

  uint32_t total_t_public = 0;
  uint32_t total_t_ecc_init = 0;
  uint32_t total_t_ecdsa_init = 0;
  uint32_t total_t_sign = 0;
  uint32_t total_t_verify = 0;


  void init_data();
  void gen_PrivateKey();
  void ecc_init();
  void gen_PublicKey();
  void ecdsa_init();
  void sign();
  void verify();


  void init_data(){

#ifndef TEST_VECTOR
    uint8_t j;
#endif

    pass = 0;
    t = 0;

    //init message
    memset(message, 0, MSG_LEN);
    //init private key
    memset(PrivateKey, 0, NUMWORDS*NN_DIGIT_LEN);
    //init public key
    memset(PublicKey.x, 0, NUMWORDS*NN_DIGIT_LEN);
    memset(PublicKey.y, 0, NUMWORDS*NN_DIGIT_LEN);
    //init signature
    memset(r, 0, NUMWORDS*NN_DIGIT_LEN);
    memset(s, 0, NUMWORDS*NN_DIGIT_LEN);

#ifndef TEST_VECTOR  
    //randomly generate the message
    for (j=0; j<MSG_LEN; j++){
      message[j] = (uint8_t) call Random.rand();
    }
#else  //only for secp160r1
    message[0] = 0x61;
    message[1] = 0x62;
    message[2] = 0x63;
#endif
    gen_PrivateKey();
  }

  void gen_PrivateKey(){

#ifndef TEST_VECTOR  //random private key
    /*
    uint8_t j;

    for (j=0; j<KEYDIGITS; j++){
#ifdef THIRTYTWO_BIT_PROCESSOR
      PrivateKey[j] = ((uint32_t)call Random.rand() << 16)^((uint32_t)call Random.rand());
#else
      PrivateKey[j] = (NN_DIGIT) call Random.rand();
#endif
    }
*/
    call ECC.gen_private_key(PrivateKey);
#else  //only for test vector of secp160r1

#ifdef EIGHT_BIT_PROCESSOR
    PrivateKey[20] = 0x0;
    PrivateKey[19] = 0xAA;
    PrivateKey[18] = 0x37;
    PrivateKey[17] = 0x4F;
    PrivateKey[16] = 0xFC;
    PrivateKey[15] = 0x3C;
    PrivateKey[14] = 0xE1;
    PrivateKey[13] = 0x44;
    PrivateKey[12] = 0xE6;
    PrivateKey[11] = 0xB0;
    PrivateKey[10] = 0x73;
    PrivateKey[9] = 0x30;
    PrivateKey[8] = 0x79;
    PrivateKey[7] = 0x72;
    PrivateKey[6] = 0xCB;
    PrivateKey[5] = 0x6D;
    PrivateKey[4] = 0x57;
    PrivateKey[3] = 0xB2;
    PrivateKey[2] = 0xA4;
    PrivateKey[1] = 0xE9;
    PrivateKey[0] = 0x82;
#else
#ifdef SIXTEEN_BIT_PROCESSOR
    PrivateKey[10] = 0x0;
    PrivateKey[9] = 0xAA37;
    PrivateKey[8] = 0x4FFC;
    PrivateKey[7] = 0x3CE1;
    PrivateKey[6] = 0x44E6;
    PrivateKey[5] = 0xB073;
    PrivateKey[4] = 0x3079;
    PrivateKey[3] = 0x72CB;
    PrivateKey[2] = 0x6D57;
    PrivateKey[1] = 0xB2A4;
    PrivateKey[0] = 0xE982;
#else
#ifdef THIRTYTWO_BIT_PROCESSOR
    PrivateKey[5] = 0x0;
    PrivateKey[4] = 0xAA374FFC;
    PrivateKey[3] = 0x3CE144E6;
    PrivateKey[2] = 0xB0733079;
    PrivateKey[1] = 0x72CB6D57;
    PrivateKey[0] = 0xB2A4E982;
#endif  //end of 32-bit
#endif  //end of 16-bit
#endif  //end of 8-bit
    
#endif  //end of test vector

    gen_PublicKey();
  }

  void ecc_init(){
    uint32_t time_a, time_b;

    type = 0;

#ifdef MICA
    time_a = call SysTime.getTime32();
#endif
#ifdef TELOSB
    time_a = call LocalTime.read();
#endif
#ifdef IMOTE2
    time_a = call SysTime64.getTime32();
#endif

    call ECC.init();


#ifdef MICA
    time_b = call SysTime.getTime32();
#endif
#ifdef TELOSB
    time_b = call LocalTime.read();
#endif
#ifdef IMOTE2
    time_b = call SysTime64.getTime32();
#endif

    t = time_b - time_a;
    total_t_ecc_init = total_t_ecc_init + t;

    init_data();

  }

  void gen_PublicKey(){
    uint32_t time_a, time_b;

    type = 1;

#ifdef MICA
    time_a = call SysTime.getTime32();
#endif
#ifdef TELOSB
    time_a = call LocalTime.read();
#endif
#ifdef IMOTE2
    time_a = call SysTime64.getTime32();
#endif
    //call ECC.win_mul_base(&PublicKey, PrivateKey);
    call ECC.gen_public_key(&PublicKey, PrivateKey);

#ifdef MICA
    time_b = call SysTime.getTime32();
#endif
#ifdef TELOSB
    time_b = call LocalTime.read();
#endif
#ifdef IMOTE2
    time_b = call SysTime64.getTime32();
#endif
    t = time_b - time_a;
    
    total_t_public = total_t_public + t;

    ecdsa_init();
  }

  void ecdsa_init(){
    uint32_t time_a, time_b;

    type = 2;

#ifdef MICA
    time_a = call SysTime.getTime32();
#endif
#ifdef TELOSB
    time_a = call LocalTime.read();
#endif
#ifdef IMOTE2
    time_a = call SysTime64.getTime32();
#endif

    call ECDSA.init(&PublicKey); 

#ifdef MICA
    time_b = call SysTime.getTime32();
#endif
#ifdef TELOSB
    time_b = call LocalTime.read();
#endif
#ifdef IMOTE2
    time_b = call SysTime64.getTime32();
#endif
    t = time_b - time_a;

    total_t_ecdsa_init = total_t_ecdsa_init + t;

    sign();
  }

  void sign(){
    uint32_t time_a, time_b;

    type = 3;

#ifdef MICA
    time_a = call SysTime.getTime32();
#endif
#ifdef TELOSB
    time_a = call LocalTime.read();
#endif
#ifdef IMOTE2
    time_a = call SysTime64.getTime32();
#endif

    call ECDSA.sign(message, MSG_LEN, r, s, PrivateKey);;

#ifdef MICA
    time_b = call SysTime.getTime32();
#endif
#ifdef TELOSB
    time_b = call LocalTime.read();
#endif
#ifdef IMOTE2
    time_b = call SysTime64.getTime32();
#endif
    t = time_b - time_a;

    total_t_sign = total_t_sign + t;

    verify();
  }

  void verify(){
    uint32_t time_a, time_b;

    type = 4;

#ifdef MICA
    time_a = call SysTime.getTime32();
#endif
#ifdef TELOSB
    time_a = call LocalTime.read();
#endif
#ifdef IMOTE2
    time_a = call SysTime64.getTime32();
#endif

    pass = call ECDSA.verify(message, MSG_LEN, r, s, &PublicKey);   

#ifdef MICA
    time_b = call SysTime.getTime32();
#endif
#ifdef TELOSB
    time_b = call LocalTime.read();
#endif
#ifdef IMOTE2
    time_b = call SysTime64.getTime32();
#endif
    t = time_b - time_a;

    total_t_verify = total_t_verify + t;

      if(pass == 1){
	call Leds.greenToggle();
	printfUART("round %i pass\n", round_index);
      }else{
	printfUART("round %i not pass\n", round_index);
      }

      printfUART("ecc_init: ", ""); print_uint32(total_t_ecc_init); 
      printfUART("\n", "");
      printfUART("ecdsa_init: ", ""); print_uint32(total_t_ecdsa_init);
      printfUART("\n", "");
      printfUART("public key: ", ""); print_uint32(total_t_public);
      printfUART("\n", "");
      printfUART("sign: ",""); print_uint32(total_t_sign);
      printfUART("\n", "");
      printfUART("verify: ", ""); print_uint32(total_t_verify);
      printfUART("\n", "");

    if (round_index < MAX_ROUNDS){

      round_index++;
      ecc_init();
    }
    /*
else{
      printfUART("ecc_init: ", ""); print_uint32(total_t_ecc_init); 
      printfUART("\n", "");
      printfUART("ecdsa_init: ", ""); print_uint32(total_t_ecdsa_init);
      printfUART("\n", "");
      printfUART("public key: ", ""); print_uint32(total_t_public);
      printfUART("\n", "");
      printfUART("sign: ",""); print_uint32(total_t_sign);
      printfUART("\n", "");
      printfUART("verify: ", ""); print_uint32(total_t_verify);
      printfUART("\n", "");
    }
    */
  }

  command result_t StdControl.init(){
    call Random.init();
    call Leds.init();
    printfUART_init();

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
    call myTimer.start(TIMER_ONE_SHOT, 5000);
    //call myTimer.start(TIMER_REPEAT, 5000);

    return SUCCESS;
  }

  command result_t StdControl.stop(){
    call myTimer.stop();
    return SUCCESS;
  }

  event result_t myTimer.fired(){

    round_index = 1;

    printfUART("Timer fired\n", "");

    ecc_init();
    return SUCCESS;
  }


#ifdef IMOTE2
  async event result_t SysTime64.alarmFired(uint32_t val){
    return SUCCESS;
  }
#endif

}

