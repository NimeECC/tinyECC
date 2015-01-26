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
 * tpresult.h
 *
 * Author: Panos Kampanakis
 * Date: 02/20/2007
 */

struct public_key_point_msg
{
  uint8_t curve; //the curve to be used
  uint8_t len;  //key length
  uint8_t coord; // x or y-coordinate
  uint8_t c[64]; // coordinate
} __attribute__ ((packed));
typedef struct public_key_point_msg public_key_point_msg;

struct private_key_point_msg
{
  uint8_t len;  //key length
  uint8_t coord; // x or y-coordinate
  uint8_t c[64]; // coordinate
} __attribute__ ((packed));
typedef struct private_key_point_msg private_key_point_msg;

struct tp_time_msg
{
  uint32_t t;
  uint8_t type;
} __attribute__ ((packed));
typedef struct tp_time_msg tp_time_msg;

struct shared_key_msg
{
  uint8_t sk_len;  // shared key length
  uint8_t sk[64]; //shared key
} __attribute__ ((packed));
typedef struct shared_key_msg shared_key_msg;


enum {
  AM_PUBLIC_KEY_POINT_MSG = 11,
  AM_PRIVATE_KEY_POINT_MSG = 12,
  AM_TP_TIME_MSG = 13,
  AM_SHARED_KEY_MSG = 14
};
