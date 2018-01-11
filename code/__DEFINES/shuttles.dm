#define PARALLAX_LOOP_TIME 25
#define SYNDICATE_CHALLENGE_TIMER 15000 //20 minutes

// Shuttle moving status.
#define SHUTTLE_IDLE      0
#define SHUTTLE_WARMUP    1
#define SHUTTLE_INTRANSIT 2

// Autodock shuttle processing status.
#define IDLE_STATE   0
#define WAIT_LAUNCH  1
#define FORCE_LAUNCH 2
#define WAIT_ARRIVE  3
#define WAIT_FINISH  4

// Shuttles flags
#define SHUTTLE_FLAGS_NONE		0
#define SHUTTLE_FLAGS_PROCESS	1
#define SHUTTLE_FLAGS_SUPPLY	2
#define SHUTTLE_FLAGS_ALL		(~SHUTTLE_FLAGS_NONE)

// Shuttle jump distance
#define SHUTTLE_JUMP_SHORT	1
#define SHUTTLE_JUMP_LONG	2

// Ferry shuttles locations
#define SHUTTLE_LOCATION_STATION 0
#define SHUTTLE_LOCATION_OFFSITE 1

