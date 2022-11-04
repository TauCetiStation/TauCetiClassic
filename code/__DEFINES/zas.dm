#define ZASDBG
//#define MULTIZAS

#define AIR_BLOCKED 1
#define ZONE_BLOCKED 2
#define BLOCKED AIR_BLOCKED | ZONE_BLOCKED

#define ZONE_MIN_SIZE 14 //zones with less than this many turfs will always merge, even if the connection is not direct

#define fast_c_airblock(this, other) ((this.blocks_air || this.can_block_air) && this.c_airblock(other))
