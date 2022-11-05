#define ZASDBG
//#define MULTIZAS

#define AIR_BLOCKED (1<<0)
#define ZONE_BLOCKED (1<<1)
#define BLOCKED (AIR_BLOCKED | ZONE_BLOCKED)

#define ZONE_MIN_SIZE 14 //zones with less than this many turfs will always merge, even if the connection is not direct

#define FAST_C_AIRBLOCK(this, other) ((this.blocks_air || this.can_block_air) && this.c_airblock(other))
#define CAN_FLOW_FAST(source, target, height) (!source.can_block_air || source.CanPass(null, target, height))
