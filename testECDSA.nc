/*
 * $Id: testECDSA.nc,v 1.3 2007/09/12 18:17:06 aliu3 Exp $
 */

includes result;
includes ECC;
includes sha1;

configuration testECDSA{
}

implementation {
  components Main, testECDSAM, LedsC, TimerC, RandomLFSR, GenericComm, NNM, ECCC, ECDSAC;
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
  Main.StdControl -> testECDSAM;
  
  testECDSAM.myTimer -> TimerC.Timer[unique("Timer")];
  testECDSAM.Random -> RandomLFSR;
  testECDSAM.Leds -> LedsC;

  testECDSAM.PubKeyMsg -> GenericComm.SendMsg[AM_PUBLIC_KEY_MSG];
  testECDSAM.PriKeyMsg -> GenericComm.SendMsg[AM_PRIVATE_KEY_MSG];
  testECDSAM.PacketMsg -> GenericComm.SendMsg[AM_PACKET_MSG];
  testECDSAM.TimeMsg -> GenericComm.SendMsg[AM_TIME_MSG];

#ifdef PLATFORM_MICAZ
  testECDSAM.SysTime -> SysTimeC;
#endif

#ifdef PLATFORM_TELOSB
  testECDSAM.LocalTime -> TimerC;
#endif

#ifdef PLATFORM_IMOTE2
  testECDSAM.SysTime64 -> SysTimeC;
  Main.StdControl -> SysTimeC;
#ifdef MANUALFREQ
  testECDSAM.DVFS -> DVFSC;
  testECDSAM.PMIC -> PMICC;
  Main.StdControl -> PMICC;
#endif
#endif

  testECDSAM.NN -> NNM.NN;
  testECDSAM.ECC -> ECCC.ECC;
  testECDSAM.ECDSA -> ECDSAC;



}

