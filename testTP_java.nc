
includes tpresult;
includes ECC;

configuration testTP_java{
}

implementation {
  components Main, testTPM_java, LedsC, TimerC, GenericComm, NNM, NN2C, ECCC, TPC;

#ifdef IMOTE2
  components SysTimeC;
  #ifdef MANUALFREQ
	components DVFSC, PMICC;
  #endif
#endif
  
  Main.StdControl -> TimerC;
  Main.StdControl -> GenericComm;
  Main.StdControl -> testTPM_java;
  testTPM_java.Timer -> TimerC.Timer[unique("Timer")];
  testTPM_java.Leds -> LedsC;
  
  testTPM_java.PubKeyMsg -> GenericComm.SendMsg[AM_PUBLIC_KEY_POINT_MSG];
  testTPM_java.PriKeyMsg -> GenericComm.SendMsg[AM_PRIVATE_KEY_POINT_MSG];
  testTPM_java.SharKeyMsg -> GenericComm.SendMsg[AM_SHARED_KEY_MSG];
  testTPM_java.TimeMsg -> GenericComm.SendMsg[AM_TP_TIME_MSG];

#ifdef IMOTE2
  testTPM_java.SysTime64 -> SysTimeC;
  Main.StdControl -> SysTimeC;
  #ifdef MANUALFREQ
  	testTPM_java.DVFS -> DVFSC;
	testTPM_java.PMIC -> PMICC;
  	Main.StdControl -> PMICC;
  #endif
#endif

  testTPM_java.NN -> NNM;
  testTPM_java.NN2 -> NN2C;
  testTPM_java.ECC -> ECCC;
  testTPM_java.TP -> TPC;
}
