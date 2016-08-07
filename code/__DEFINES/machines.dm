// channel numbers for power
#define EQUIP			1
#define LIGHT			2
#define ENVIRON			3
#define TOTAL			4	//for total power used only
#define STATIC_EQUIP	5
#define STATIC_LIGHT	6
#define STATIC_ENVIRON	7

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
