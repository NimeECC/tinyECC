includes result;
includes ECC;
includes sha1;
#ifdef PLATFORM_MICAZ
//includes Cricket;
#endif


configuration testECIES{
}

implementation {
  components Main, testECIESM, LedsC, TimerC, RandomLFSR, GenericComm, NNM, ECCC, ECIESC;
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
  Main.StdControl -> testECIESM;
  
  testECIESM.myTimer -> TimerC.Timer[unique("Timer")];
  testECIESM.Random -> RandomLFSR;
  testECIESM.Leds -> LedsC;

#ifndef DEBUG_SERIAL
  testECIESM.PubKeyMsg -> GenericComm.SendMsg[AM_PUBLIC_KEY_MSG];
  testECIESM.PriKeyMsg -> GenericComm.SendMsg[AM_PRIVATE_KEY_MSG];
  testECIESM.Uint8Msg -> GenericComm.SendMsg[AM_UINT8_MSG];
  testECIESM.TimeMsg -> GenericComm.SendMsg[AM_TIME_MSG];
#endif

#ifdef PLATFORM_MICAZ
  testECIESM.SysTime -> SysTimeC;
#ifdef DEBUG_SERIAL
  testECIESM.Serial -> SerialM;
  SerialM.HPLUART -> HPLUARTC;
#endif
#endif

#ifdef PLATFORM_TELOSB
  testECIESM.LocalTime -> TimerC;
#endif

#ifdef PLATFORM_IMOTE2
  testECIESM.SysTime64 -> SysTimeC;
  Main.StdControl -> SysTimeC;
#ifdef MANUALFREQ
  testECIESM.DVFS -> DVFSC;
  testECIESM.PMIC -> PMICC;
  Main.StdControl -> PMICC;
#endif
#endif

  testECIESM.NN -> NNM.NN;
  testECIESM.ECC -> ECCC.ECC;
  testECIESM.ECIES -> ECIESC;



}

