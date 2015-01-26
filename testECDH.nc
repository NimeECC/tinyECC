includes result;
includes ECC;
includes sha1;
#ifdef PLATFORM_MICAZ
//includes Cricket;
#endif


configuration testECDH{
}

implementation {
  components Main, testECDHM, LedsC, TimerC, RandomLFSR, GenericComm, NNM, ECCC, ECDHC;
#ifdef PLATFORM_MICAZ
  components SysTimeC;
#ifdef DEBUG_SERIAL
  components SerialM, HPLUARTC;
#endif
#endif //PLATFORM_MICAZ

#ifdef PLATFORM_IMOTE2
  components SysTimeC;
#ifdef MANUALFREQ
  components DVFSC, PMICC;
#endif
#endif
  
  Main.StdControl -> TimerC;
  Main.StdControl -> GenericComm;
  Main.StdControl -> testECDHM;
  
  testECDHM.myTimer -> TimerC.Timer[unique("Timer")];
  testECDHM.Random -> RandomLFSR;
  testECDHM.Leds -> LedsC;

  testECDHM.PubKeyMsg -> GenericComm.SendMsg[AM_PUBLIC_KEY_MSG];
  testECDHM.PriKeyMsg -> GenericComm.SendMsg[AM_PRIVATE_KEY_MSG];
  testECDHM.TimeMsg -> GenericComm.SendMsg[AM_TIME_MSG];
  testECDHM.SndSecret -> GenericComm.SendMsg[AM_ECDH_KEY_MSG];

#ifdef PLATFORM_MICAZ
  testECDHM.SysTime -> SysTimeC;
#ifdef DEBUG_SERIAL
  testECDHM.Serial -> SerialM;
  SerialM.HPLUART -> HPLUARTC;
#endif
#endif

#ifdef PLATFORM_TELOSB
  testECDHM.LocalTime -> TimerC;
#endif

#ifdef PLATFORM_IMOTE2
  testECDHM.SysTime64 -> SysTimeC;
  Main.StdControl -> SysTimeC;
#ifdef MANUALFREQ
  testECDHM.DVFS -> DVFSC;
  testECDHM.PMIC -> PMICC;
  Main.StdControl -> PMICC;
#endif
#endif

  testECDHM.NN -> NNM.NN;
  testECDHM.ECC -> ECCC.ECC;
  testECDHM.ECDH -> ECDHC;



}

