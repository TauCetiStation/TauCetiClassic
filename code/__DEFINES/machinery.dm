// this define should be removed, if power module will ever be updated.
#define TAUCETI_POWER_DRAW_MOD /10 // at the moment, we don't use Bay's machinery power drain rebalance, so for us atmos uses too much power and we need to devide return value

// channel numbers for power
#define TOTAL           1	//for total power used only
#define STATIC_EQUIP    2
#define STATIC_LIGHT    3
#define STATIC_ENVIRON  4

//Power use
#define NO_POWER_USE 0
#define IDLE_POWER_USE 1
#define ACTIVE_POWER_USE 2

//used in design to specify which machine can build it
#define IMPRINTER	1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE	2	//New stuff. Uses glass/metal/chemicals
#define AUTOLATHE	4	//Uses glass/metal only.
#define MINEFAB		8	//Uses for mining fabrricator
#define MECHFAB		16 //Remember, objects utilising this flag should have construction_time and construction_cost vars.
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8		// under maintaince
#define EMPED		16		// temporary broken by EMP pulse

//General-purpose life speed define for plants.
#define HYDRO_SPEED_MULTIPLIER 1

#define NANO_IGNORE_DISTANCE 1

//Where we should check allowed()
#define ALLOWED_CHECK_NONE       0
#define ALLOWED_CHECK_A_HAND     1
#define ALLOWED_CHECK_TOPIC      2
#define ALLOWED_CHECK_EVERYWHERE ~(ALLOWED_CHECK_NONE)

// Alarm modes for /obj/machinery/alarm
#define AALARM_MODE_SCRUBBING   1
#define AALARM_MODE_REPLACEMENT 2 //like scrubbing, but faster.
#define AALARM_MODE_PANIC       3 //constantly sucks all air
#define AALARM_MODE_CYCLE       4 //sucks off all air, then refill and switches to scrubbing
#define AALARM_MODE_FILL        5 //emergency fill
#define AALARM_MODE_OFF         6 //Shuts it all down.

/*
 *	Atmospherics Machinery.
*/
#define MAX_SIPHON_FLOWRATE   2500 // L/s. This can be used to balance how fast a room is siphoned. Anything higher than CELL_VOLUME has no effect.
#define MAX_SCRUBBER_FLOWRATE 200  // L/s. Max flow rate when scrubbing from a turf.

// These balance how easy or hard it is to create huge pressure gradients with pumps and filters.
// Lower values means it takes longer to create large pressures differences.
// Has no effect on pumping gasses from high pressure to low, only from low to high.
#define ATMOS_PUMP_EFFICIENCY   10.0 // 10 is maximum.
#define ATMOS_FILTER_EFFICIENCY 2.5

// Will not bother pumping or filtering if the gas source as fewer than this amount of moles, to help with performance.
#define MINIMUM_MOLES_TO_PUMP   0.01
#define MINIMUM_MOLES_TO_FILTER 0.04

// The flow rate/effectiveness of various atmos devices is limited by their internal volume,
// so for many atmos devices these will control maximum flow rates in L/s.
#define ATMOS_DEFAULT_VOLUME_PUMP   200 // Liters.
#define ATMOS_DEFAULT_VOLUME_FILTER 200 // L.
#define ATMOS_DEFAULT_VOLUME_MIXER  200 // L.
#define ATMOS_DEFAULT_VOLUME_PIPE   70  // L.
