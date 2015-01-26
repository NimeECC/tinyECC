
includes tpresult;
includes ECC;

#ifdef MICA
includes Cricket;
#endif

configuration testTP{
}

implementation {
  components Main, testTPM, LedsC, TimerC, NNM, NN2C, TPC;

#ifdef IMOTE2
  components SysTimeC;
  #ifdef MANUALFREQ
	components DVFSC, PMICC;
  #endif
#endif

#ifdef MICA
  components SysTimeC, SerialM, HPLUARTC;
#endif
  
  Main.StdControl -> TimerC;
  Main.StdControl -> testTPM;
  testTPM.Timer -> TimerC.Timer[unique("Timer")];
  testTPM.Leds -> LedsC;

#ifdef IMOTE2
  testTPM.SysTime64 -> SysTimeC;
  Main.StdControl -> SysTimeC;
#ifdef MANUALFREQ
  testTPM.DVFS -> DVFSC;
  testTPM.PMIC -> PMICC;
  Main.StdControl -> PMICC;
#endif
#endif

#ifdef MICA
  testTPM.SysTime -> SysTimeC;
  testTPM.Serial -> SerialM;
  SerialM.HPLUART -> HPLUARTC;
#endif

  testTPM.NN -> NNM;
  testTPM.NN2 -> NN2C;
  testTPM.TP -> TPC;
}
