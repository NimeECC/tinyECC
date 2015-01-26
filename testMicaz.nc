
includes tpresult;
includes ECC;

includes Cricket;   //used for debug

configuration testMicaz{
}

implementation {
  components Main, testMicazM, LedsC, TimerC, NNM, ECCC;

  components SerialM,  //used by Cricket
  	     HPLUARTC, 
  	     SysTimeC;
  
  Main.StdControl -> TimerC;
  Main.StdControl -> testMicazM;
  testMicazM.Timer -> TimerC.Timer[unique("Timer")];
  testMicazM.Leds -> LedsC;

  testMicazM.SysTime -> SysTimeC;
  //used for Cricket  
  testMicazM.Serial -> SerialM;
  SerialM.HPLUART -> HPLUARTC;
  SerialM.Leds -> LedsC;

  testMicazM.NN -> NNM;
  testMicazM.ECC -> ECCC.ECC;
}
