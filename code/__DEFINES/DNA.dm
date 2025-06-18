/*ALL DNA, SPECIES, AND GENETICS-RELATED DEFINES GO HERE*/

//Transformation proc stuff
#define TR_KEEPITEMS    (1<<0)
#define TR_KEEPDAMAGE   (1<<2)
#define TR_KEEPIMPLANTS (1<<3)
/// changelings shouldn't edit the DNA's SE when turning into a monkey
#define TR_KEEPSE       (1<<4)
#define TR_DEFAULTMSG   (1<<5)
#define TR_KEEPSTUNS    (1<<6)
#define TR_KEEPREAGENTS (1<<7)

// What each index means:
#define DNA_OFF_LOWERBOUND 1
#define DNA_OFF_UPPERBOUND 2
#define DNA_ON_LOWERBOUND  3
#define DNA_ON_UPPERBOUND  4

// Define block bounds (off-low,off-high,on-low,on-high)
// Used in setupgame.dm
#define DNA_DEFAULT_BOUNDS list(1,2049,2050,4095) //2050 = 8 0 2 #Z2(Added some comments)
#define DNA_HARDER_BOUNDS  list(1,3049,3050,4095) //3050 = B E A
#define DNA_HARD_BOUNDS    list(1,3490,3500,4095) //3500 = D A C ##Z2

// UI Indices (can change to mutblock style, if desired)
#define DNA_UI_HAIR_R      1
#define DNA_UI_HAIR_G      2
#define DNA_UI_HAIR_B      3
#define DNA_UI_BEARD_R     4
#define DNA_UI_BEARD_G     5
#define DNA_UI_BEARD_B     6
#define DNA_UI_SKIN_TONE   7
#define DNA_UI_SKIN_R      8
#define DNA_UI_SKIN_G      9
#define DNA_UI_SKIN_B      10
#define DNA_UI_HEIGHT      11
#define DNA_UI_EYES_R      12
#define DNA_UI_EYES_G      13
#define DNA_UI_EYES_B      14
#define DNA_UI_GENDER      15
#define DNA_UI_BEARD_STYLE 16
#define DNA_UI_HAIR_STYLE  17
#define DNA_UI_BELLY_R     18
#define DNA_UI_BELLY_G     19
#define DNA_UI_BELLY_B     20
#define DNA_UI_LENGTH      20 // Update this when you add something, or you WILL break shit.


#define DNA_SE_LENGTH 27
#define DNA_UNIQUE_ENZYMES_LEN 32
// For later:
//#define DNA_SE_LENGTH 50 // Was STRUCDNASIZE, size 27. 15 new blocks added = 42, plus room to grow.

#define BLOOD_O_PLUS   "O(I) Rh+"
#define BLOOD_O_MINUS  "O(I) Rh-"

#define BLOOD_A_PLUS   "A(II) Rh+"
#define BLOOD_A_MINUS  "A(II) Rh-"

#define BLOOD_B_PLUS   "B(III) Rh+"
#define BLOOD_B_MINUS  "B(III) Rh-"

#define BLOOD_AB_PLUS  "AB(IV) Rh+"
#define BLOOD_AB_MINUS "AB(IV) Rh-"
