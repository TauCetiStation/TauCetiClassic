#define MINIMUM_PRESSURE_DIFFERENCE_TO_SUSPEND (MINIMUM_AIR_TO_SUSPEND*R_IDEAL_GAS_EQUATION*T20C)/CELL_VOLUME			// Minimum pressure difference between zones to suspend
#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.05 // Minimum ratio of air that must move to/from a tile to suspend group processing
#define MINIMUM_AIR_TO_SUSPEND       (MOLES_CELLSTANDARD * MINIMUM_AIR_RATIO_TO_SUSPEND) // Minimum amount of air that has to move before a group processing can be suspended
#define MINIMUM_MOLES_DELTA_TO_MOVE  (MOLES_CELLSTANDARD * MINIMUM_AIR_RATIO_TO_SUSPEND) // Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE  (T20C + 100)

//These control the mole ratio of oxidizer and fuel used in the combustion reaction
#define FIRE_REACTION_OXIDIZER_AMOUNT	3 //should be greater than the fuel amount if fires are going to spread much
#define FIRE_REACTION_FUEL_AMOUNT		2

//These control the speed at which fire burns
#define FIRE_GAS_BURNRATE_MULT			1
#define FIRE_LIQUID_BURNRATE_MULT		0.225

//If the fire is burning slower than this rate then the reaction is going too slow to be self sustaining and the fire burns itself out.
//This ensures that fires don't grind to a near-halt while still remaining active forever.
#define FIRE_GAS_MIN_BURNRATE			0.01
#define FIRE_LIQUD_MIN_BURNRATE			0.0025

//How many moles of fuel are contained within one solid/liquid fuel volume unit
#define LIQUIDFUEL_AMOUNT_TO_MOL		0.45  //mol/volume unit

// XGM gas flags.
#define XGM_GAS_FUEL        1
#define XGM_GAS_OXIDIZER    2
#define XGM_GAS_CONTAMINANT 4
#define XGM_GAS_FUSION_FUEL 8

#define MAX_PUMP_PRESSURE		15000	// Maximal pressure setting for pumps and vents
#define MAX_OMNI_PRESSURE		7500	// Maximal output(s) pressure for omni devices (filters/mixers)
