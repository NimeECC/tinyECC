includes result;
includes ECC;
includes sha1;
includes PrintfUART;

configuration testECDSAt{
}

implementation {
  components Main, testECDSAtM, LedsC, TimerC, RandomLFSR, GenericComm, NNM, ECCC, ECDSAC;
#ifdef MICA
  components SysTimeC;
#ifdef DEBUG_SERIAL
  components SerialM, HPLUARTC;
#endif
#endif //MICA

#ifdef IMOTE2
  components SysTimeC;
#ifdef MANUALFREQ
  components DVFSC, PMICC;
#endif
#endif
  
  Main.StdControl -> TimerC;
  Main.StdControl -> GenericComm;
  Main.StdControl -> testECDSAtM;
  
  testECDSAtM.myTimer -> TimerC.Timer[unique("Timer")];
  testECDSAtM.Random -> RandomLFSR;
  testECDSAtM.Leds -> LedsC;

#ifdef MICA
  testECDSAtM.SysTime -> SysTimeC;
#ifdef DEBUG_SERIAL
  testECDSAtM.Serial -> SerialM;
  SerialM.HPLUART -> HPLUARTC;
#endif
#endif

#ifdef TELOSB
  testECDSAtM.LocalTime -> TimerC;
#endif

#ifdef IMOTE2
  testECDSAtM.SysTime64 -> SysTimeC;
  Main.StdControl -> SysTimeC;
#ifdef MANUALFREQ
  testECDSAtM.DVFS -> DVFSC;
  testECDSAtM.PMIC -> PMICC;
  Main.StdControl -> PMICC;
#endif
#endif

  testECDSAtM.NN -> NNM.NN;
  testECDSAtM.ECC -> ECCC.ECC;
  testECDSAtM.ECDSA -> ECDSAC;



}

