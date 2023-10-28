//#define ZASDBG
//#define MULTIZAS

//  docs: /code/modules/atmospheric/ZAS/_docs.dm

#define AIR_BLOCKED (1<<0)
#define ZONE_BLOCKED (1<<1)
#define BLOCKED (AIR_BLOCKED | ZONE_BLOCKED)

#define ZONE_MIN_SIZE 14 //zones with less than this many turfs will always merge, even if the connection is not direct

#define FAST_C_AIRBLOCK(turf, other) ((turf.blocks_air || turf.can_block_air) && turf.c_airblock(other))
#define CAN_FLOW_FAST(movable, target, height) (!movable.can_block_air || movable.CanPass(null, target, height))
