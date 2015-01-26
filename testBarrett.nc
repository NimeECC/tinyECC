/*
 * $Id: testBarrett.nc,v 1.1 2007/11/01 23:06:48 aliu3 Exp $
 */

includes result;
includes ECC;
includes sha1;

configuration testBarrett{
}

implementation {
  components Main, testBarrettM, LedsC, TimerC, RandomLFSR, GenericComm, NNM, ECCC;
#ifdef PLATFORM_MICAZ
  components SysTimeC;
#endif //PLATFORM_MICAZ

#ifdef PLATFORM_IMOTE2
  components SysTimeC;
#ifdef MANUALFREQ
  components DVFSC, PMICC;
#endif
#endif
  
  Main.StdControl -> TimerC;
  Main.StdControl -> GenericComm;
  Main.StdControl -> testBarrettM;
  
  testBarrettM.myTimer -> TimerC.Timer[unique("Timer")];
  testBarrettM.Random -> RandomLFSR;
  testBarrettM.Leds -> LedsC;

  testBarrettM.PacketMsg -> GenericComm.SendMsg[AM_PACKET_MSG];
  testBarrettM.TimeMsg -> GenericComm.SendMsg[AM_TIME_MSG];

#ifdef PLATFORM_MICAZ
  testBarrettM.SysTime -> SysTimeC;
#endif

#ifdef PLATFORM_TELOSB
  testBarrettM.LocalTime -> TimerC;
#endif

#ifdef PLATFORM_IMOTE2
  testBarrettM.SysTime64 -> SysTimeC;
  Main.StdControl -> SysTimeC;
#ifdef MANUALFREQ
  testBarrettM.DVFS -> DVFSC;
  testBarrettM.PMIC -> PMICC;
  Main.StdControl -> PMICC;
#endif
#endif

  testBarrettM.NN -> NNM.NN;
  testBarrettM.ECC -> ECCC.ECC;
}

