
includes tpresult;
includes ECC;

#ifdef MICA
includes Cricket;   //used for debug
#endif

configuration testExp{
}

implementation {
  components Main, testExpM, LedsC, TimerC, NNM, ECCC;

#ifdef MICA  
  components SerialM,  //used by Cricket
  	     HPLUARTC, 
  	     SysTimeC;
#endif

#ifdef IMOTE2
  components SysTimeC;
  #ifdef MANUALFREQ
	components DVFSC, PMICC;
  #endif
#endif
  
  Main.StdControl -> TimerC;
  Main.StdControl -> testExpM;
  testExpM.Timer -> TimerC.Timer[unique("Timer")];
  testExpM.Leds -> LedsC;

#ifdef MICA
  testExpM.SysTime -> SysTimeC;
  //used for Cricket  
  testExpM.Serial -> SerialM;
  SerialM.HPLUART -> HPLUARTC;
  SerialM.Leds -> LedsC;
#endif

#ifdef IMOTE2
  testExpM.SysTime64 -> SysTimeC;
  Main.StdControl -> SysTimeC;
  #ifdef MANUALFREQ
  	testExpM.DVFS -> DVFSC;
	testExpM.PMIC -> PMICC;
  	Main.StdControl -> PMICC;
  #endif
#endif

  testExpM.NN -> NNM;
  testExpM.ECC -> ECCC;
}
