/**
 * All new code in this distribution is Copyright 2007 by North Carolina
 * State University. All rights reserved. Redistribution and use in
 * source and binary forms are permitted provided that this entire
 * copyright notice is duplicated in all such copies, and that any
 * documentation, announcements, and other materials related to such
 * distribution and use acknowledge that the software was developed at
 * North Carolina State University, Raleigh, NC. No charge may be made
 * for copies, derivations, or distributions of this material without the
 * express written consent of the copyright holder. Neither the name of
 * the University nor the name of the author may be used to endorse or
 * promote products derived from this material without specific prior
 * written permission.
 *
 * IN NO EVENT SHALL THE NORTH CAROLINA STATE UNIVERSITY BE LIABLE TO ANY
 * PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
 * DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 * EVEN IF THE NORTH CAROLINA STATE UNIVERSITY HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN
 * "AS IS" BASIS, AND THE NORTH CAROLINA STATE UNIVERSITY HAS NO
 * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 * MODIFICATIONS. "
 *
 */

/**
 * show_TPresult.java
 *
 * Author: Panos Kampanakis
 * Date: 02/20/2007
 */

// imports
import net.tinyos.message.*;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.*;
import java.security.NoSuchAlgorithmException;
import tatePairingVerJava.*;

public class show_TPresult implements MessageListener
{
    int round = 0;
    int curve;
    Point P= new Point(new BigInteger("0"),new BigInteger("0")); // points initializations
    Point Q = P;
    Curve EC; // the curve
    tatePairingSS m; // the tate pairing checker class
    Zq result;

    int n_ticks = 3250000; //telosb 32768, micaz 921600, imote2 3250000
    int MAX_ROUNDS = 20;
    float tp_total = 0;
    float tp_miller_total = 0;
    float tp_finalexpon_total = 0;
    float mill, luc; // miller and lucas algorithms time

    /**
     * Main driver.
     * @param argv  arguments
     */
    public static void main(String [] argv)
    {
        // try to start get_result application, else report failure
        try{
	    new show_TPresult();
	}catch (Exception e){
	    System.err.println("Exception: " + e);
	    e.printStackTrace();
	}

    }

    /**
     * Implicit constructor.  Connects to the SerialForwarder,
     * registers itself as a listener for DbgMsg's,
     * and starts listening.
     */
    public show_TPresult() throws Exception
    {
        // connect to the SerialForwarder running on the local mote
        MoteIF mote = new MoteIF((net.tinyos.util.Messenger) null);

        // prepare to listen for messages of type result
        mote.registerListener(new private_key_point_msg(), this);
		mote.registerListener(new public_key_point_msg(), this);
		mote.registerListener(new tp_time_msg(), this);
		mote.registerListener(new shared_key_msg(), this);

        // start listening to the mote
        mote.start();
        System.out.println("START...");
    }

    //get big number from array
    public BigInteger get_bn(short[] a, int index, int len)
    {
    	BigInteger tmp;

    	tmp = new BigInteger("0");

    	for (int i=index; i<len+index; i++){
	    tmp = tmp.shiftLeft(8);
	    tmp = tmp.add(BigInteger.valueOf(a[i]));
	}
    	//System.out.println(tmp.toString(16));
    	return tmp;
    }

    /**
     * Event for handling incoming result's.
     *
     * @param dstaddr   destination address
     * @param msg       received message
     */
    public void messageReceived(int dstaddr, Message msg)
    {

    // process any result's received
	if(msg instanceof private_key_point_msg){

	    //private key received
	    private_key_point_msg PrivateKey = (private_key_point_msg) msg;
	    if (PrivateKey.get_coord()==1) // received x-coordinate
	    	P.setX(get_bn(PrivateKey.get_c(), 0, PrivateKey.get_len()));
		else { // received y-coordinate
			P.setY(get_bn(PrivateKey.get_c(), 0, PrivateKey.get_len()));
			System.out.println("\nPrivate key:\n"+P);
			if (curve == (1+9+2)) EC = new SSCk2q192();
			else if (curve == (5+1+2)) EC = new SSCk2q512();
			m = new tatePairingSS();
			result = m.MillerAlg2(Curve.P,Curve.Q);
		}

	}else if(msg instanceof public_key_point_msg){

	    //public key received
	    public_key_point_msg PublicKey = (public_key_point_msg) msg;
	    if (PublicKey.get_coord()==1) { // received x-coordinate
	    	round++;
	    	System.out.println("\n-----------------------------------------");
	    	System.out.println("           ROUND " + round);
	    	System.out.println("-----------------------------------------");
	    	curve = PublicKey.get_curve();
	    	Q.setX(get_bn(PublicKey.get_c(), 0, PublicKey.get_len()));
		}
		else { // received y-coordinate
			Q.setY(get_bn(PublicKey.get_c(), 0, PublicKey.get_len()));
			System.out.println("Other party's public key:\n"+Q);
		}

	}else if(msg instanceof tp_time_msg){

	    //time result
	    tp_time_msg TimeMsg = (tp_time_msg) msg;
	    if (TimeMsg.get_type() == 1){
		mill =  (float)TimeMsg.get_t()/n_ticks;
		tp_miller_total += mill; //miller's algorithm time
		tp_total += mill;
	    }else if(TimeMsg.get_type() == 2){
		luc=(float)TimeMsg.get_t()/n_ticks;
		tp_finalexpon_total += luc; // lucas exponentiation time
		tp_total += luc;
	    }else
			System.out.println("Unknown time msg type.");

	}else if(msg instanceof shared_key_msg){
		//shared key-tate pairing result received
	    shared_key_msg SharedKey = (shared_key_msg) msg;
	    BigInteger sk = get_bn(SharedKey.get_sk(), 0, SharedKey.get_sk_len());
	    System.out.print("\nShared key:\n"+ sk.toString(16));
	    if (result.compareTo(sk)==0) System.out.println(" ( correct )");
	    else System.out.println(" ( incorrect )");

		System.out.println("\n[ time of Miller's alorithm is " + mill + " sec ]");
		System.out.println("[ time of Lucas exponentiation is " + luc + " sec ]");

		System.out.println("\n***********************************");
		System.out.println("Average timing results ("+round+"th round)");
		System.out.println("***********************************");
		System.out.println("Miller's algorithm: " + tp_miller_total/round);
		System.out.println("Lucas exponentiation: " +tp_finalexpon_total/round);
		System.out.println("Tate Pairing: " + tp_total/round);

		if (round > (MAX_ROUNDS-1)) System.exit(0);
	}else{
	    // report error
	    System.out.println("Unknown message type received.");
		}
    }
}
