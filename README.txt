$Id: README.txt,v 1.2 2007/11/02 21:39:45 aliu3 Exp $

README for TinyECC Version 1.0

Authors/Contact: An Liu, aliu3@ncsu.edu

Introduction
------------

TinyECC is a software package providing ECC-based PKC operations that 
can be flexibly configured and integrated into sensor network 
applications. It provides a digital signature scheme (ECDSA),  a key 
exchange protocol (ECDH), and a public key encryption scheme (ECIES). 
It provides a number of optimization switches, which can turn 
specific optimizations on or off based on developer's needs.

The current version of TinyECC supports MICAz, TelosB/Tmote Sky and 
Imote2 motes. It supports SECG recommended 128-bit, 160-bit and 
192-bit elliptic curve domain parameters.


How to install
--------------

Only steps 1~3 are required for using TinyECC.

1) Install TinyOS 1.1.11 or a later version(1.x).

2) Extract TinyECC.zip to directory /opt/tinyos-1.x/apps/TinyECC.

3) Add the following lines into your makefile if your program is in
another directory. (Note that the maximum payload size in IEEE
802.15.4 is 102 bytes. The test program requires a packet with more
than 29 bytes (the TinyOS default maximum payload size) to include an
ECDSA signature.)


Steps 4~6 are necessary only if you want to use ECDSA in a Java 
program.

4) Install JDK5.0 (http://java.sun.com/j2se/1.5.0/download.jsp) and
Bouncy Castle Provider for JCE (http://www.bouncycastle.org/). (This
step is necessary to use ECDSA in Java program.)

5) Download and install Sun's javax.comm package from
http://java.sun.com/products/javacomm/. You can use the following
steps (instructions for a cygwin shell), assuming you install JDK in
C:\Program Files\Java\jdk1.5.0:

  unzip javacomm20-win32.zip 
  cd commapi 
  cp win32com.dll "c:\Program Files\Java\jdk1.5.0\jre\bin" 
  chmod 755 "c:\Program Files\Java\jdk1.5.0\jre\bin\win32com.dll"
  cp comm.jar "c:\Program Files\Java\jdk1.5.0\jre\lib\ext" 
  cp javax.comm.properties "c:\Program Files\Java\jdk1.5.0\jre\lib"

6) There is a bug in Java Runtime Library (rt.jar). You have to fix
it if you want to use Koblitz curve in your Java programs. Fix it
using following steps, assuming you install JDK in
C:\Program Files\Java\jdk1.5.0:

  - Unzip C:\Program Files\Java\jdk1.5.0\src.zip.
  - Find EllipticCurve.java in
    C:\Program Files\Java\jdk1.5.0\src\java\security\spec\.
    In function checkValidity, modify "c.signum() != 1" to "c.signum() == -1".
  - Compile EllipticCurve.java to EllipticCurve.class.
  - Replace the old EllipticCurve.class in
    C:\Program Files\Java\jdk1.5.0\jre\lib\rt.jar with the newly
    compiled EllipticCurve.class.



Interfaces provided
-------------------

1) NN.nc defines the interface NN, which provides big natural number
operations. Read NN.nc for more details. NNM.nc implements this
interface.

2) ECC.nc defines the interface ECC, which provides the basic
elliptic curve operations and enhanced elliptic curve operations based
on sliding window method and projective coordinate system. ECCM.nc 
implements this interface.

3) ECDSA.nc defines the interface ECDSA, which provides the ECDSA
signature generation and verification. Read ECDSA.nc for more
details. ECDSAM.nc implements this interface.

4) ECIES.nc defines the inerface ECIES, which provides the ECIES 
encryption and decryption. ECIESM.nc implements this interface.

5) ECDH.nc defines the interface ECDH, which provides the ECDH key
establishment. ECDHM.nc implements this interface.

6) SHA1.nc defines the interface SHA1, which provides the SHA-1
functions. SHA1M.nc implements this interface.

7) CurveParam.nc defines the interface CurveParam, which provides one 
function to get the parameters of elliptic curves and another function 
for optimized multiplication with omega. secp128*.nc,
secp160*.nc, secp192*.nc implement this interface to provide
parameters for SECG defined elliptic curves. You only need to define 
curve name in your makefile to select the elliptic curve parameters.


Examples
--------

*** Example 1: ECDSA *** 

testECDSA.nc and testECDSAM.nc are used to measure the execution time 
of ECDSA in TinyECC.

Use the following steps to run this example. Assume you are using MICAz,
mib510 Programming and Serial Interface Board, which is connected to
COM4.

1) Program node, and then leave the node on the programming board.
	
        > make micaz install mib510,/dev/ttyS3

2) Run SerialForwarder.

        > java net.tinyos.sf.SerialForwarder -comm serial@COM4:57600 &

3) Run show_ecdsa in your TinyECC directory.

        > java show_ecdsa micaz

If you are using TelosB/Tmote Sky, take the following steps.

1) Plug TelosB into USB port. Suppose the corresponding serial port is COM5.

	> make telosb install

2) Run SerialForwarder.

	> java net.tinyos.sf.SerialForwarder -comm serial@COM5:telos &

3) in your TinyECC directory.
   
	> java show_ecdsa telosb

If you are using Imote2, take the following steps.

1) Plug debug board into USB port and attach an imote2 to the board. 
Suppose that the USB maps to 2 ports, the second one is COM5.

	> make imote2 install

2) Run SerialForwarder.

	> mv platforms.properties.backup platforms.properties
	> java net.tinyos.sf.SerialForwarder -comm serial@COM4:imote2 &

3) Run show_ecdsa

	> java show_ecdsa imote2

4) If you want to change the frequency of Imote2 you can change it in Makefile.


*** Example 2: ECIES *** 

testECIES.nc and testECIESM.nc are used to measure the execution time 
of ECIES in TinyECC.

Use the following steps to run this example. Assume you are using MICAz,
mib510 Programming and Serial Interface Board, which is connected to
COM4.

1) Program node, and then leave the node on the programming board.
	
        > make -f makefile_ECIES micaz install mib510,/dev/ttyS3

2) Run SerialForwarder.

        > java net.tinyos.sf.SerialForwarder -comm serial@COM4:57600 &

3) Run show_ecdsa in your TinyECC directory.

        > java show_ecies micaz

If you are using TelosB/Tmote Sky, take the following steps.

1) Plug TelosB into USB port. Suppose the corresponding serial port is COM5.

	> make -f makefile_ECIES telosb install

2) Run SerialForwarder.

	> java net.tinyos.sf.SerialForwarder -comm serial@COM5:telos &

3) in your TinyECC directory.
   
	> java show_ecies telosb

If you are using Imote2, take the following steps.

1) Plug debug board into USB port and attach an imote2 to the board. 
Suppose that the USB maps to 2 ports, the second one is COM5.

	> make -f makefile_ECIES imote2 install

2) Run SerialForwarder.

	> mv platforms.properties.backup platforms.properties
	> java net.tinyos.sf.SerialForwarder -comm serial@COM4:imote2 &

3) Run show_ecdsa

	> java show_ecies imote2

4) If you want to change the frequency of Imote2 you can change it in 
makefile_ECIES.

*** Example 3: ECDH *** 

testECDH.nc and testECDHM.nc are used to measure the execution time 
of ECDH in TinyECC.

Use the following steps to run this example. Assume you are using MICAz,
mib510 Programming and Serial Interface Board, which is connected to
COM4.

1) Program node, and then leave the node on the programming board.
	
        > make -f makefile_ECDH micaz install mib510,/dev/ttyS3

2) Run SerialForwarder.

        > java net.tinyos.sf.SerialForwarder -comm serial@COM4:57600 &

3) Run show_ecdsa in your TinyECC directory.

        > java show_ecdh micaz

If you are using TelosB/Tmote Sky, take the following steps.

1) Plug TelosB into USB port. Suppose the corresponding serial port is COM5.

	> make -f makefile_ECDH telosb install

2) Run SerialForwarder.

	> java net.tinyos.sf.SerialForwarder -comm serial@COM5:telos &

3) in your TinyECC directory.
   
	> java show_ecdh telosb

If you are using Imote2, take the following steps.

1) Plug debug board into USB port and attach an imote2 to the board. 
Suppose that the USB maps to 2 ports, the second one is COM5.

	> make -f makefile_ECDH imote2 install

2) Run SerialForwarder.

	> mv platforms.properties.backup platforms.properties
	> java net.tinyos.sf.SerialForwarder -comm serial@COM4:imote2 &

3) Run show_ecdsa

	> java show_ecdh imote2

4) If you want to change the frequency of Imote2 you can change it in 
makefile_ECDH.



Inline Assembly Code
--------------------

There are some inline assembly code in NNM.nc to speed up natural number
operations. These inline assembly code are written in AVR instruction
set and XScale (MicaZ and Imote2). If you want to use TinyECC on other 
8-bit platforms, you must comment "#define INLINE_ASM" in NN.h.



Acknowledgement
---------------

NNM.nc is based on the natural number operations in RSAREF2.0.
