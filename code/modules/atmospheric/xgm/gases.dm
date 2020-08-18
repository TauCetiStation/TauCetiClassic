/datum/xgm_gas/phoron
	id = "phoron"
	name = "Phoron"

	//Note that this has a significant impact on TTV yield.
	//Because it is so high, any leftover phoron soaks up a lot of heat and drops the yield pressure.
	specific_heat = 200	// J/(mol*K)

	//Hypothetical group 14 (same as carbon), period 8 element.
	//Using multiplicity rule, it's atomic number is 162
	//and following a N/Z ratio of 1.5, the molar mass of a monatomic gas is:
	molar_mass = 0.405	// kg/mol

	tile_overlay = "phoron"
	overlay_limit = 0.7
	flags = XGM_GAS_FUEL | XGM_GAS_CONTAMINANT | XGM_GAS_FUSION_FUEL
	dangerous = TRUE
	knowable = TRUE

/datum/xgm_gas/oxygen
	id = "oxygen"
	name = "Oxygen"
	specific_heat = 20	// J/(mol*K)
	molar_mass = 0.032	// kg/mol

	flags = XGM_GAS_OXIDIZER | XGM_GAS_FUSION_FUEL
	knowable = TRUE

/datum/xgm_gas/nitrogen
	id = "nitrogen"
	name = "Nitrogen"
	specific_heat = 20	// J/(mol*K)
	molar_mass = 0.028	// kg/mol
	knowable = TRUE

/datum/xgm_gas/carbon_dioxide
	id = "carbon_dioxide"
	name = "Carbon Dioxide"
	specific_heat = 30	// J/(mol*K)
	molar_mass = 0.044	// kg/mol
	knowable = TRUE

/datum/xgm_gas/sleeping_agent
	id = "sleeping_agent"
	name = "Nitrous Oxide"
	specific_heat = 40	// J/(mol*K)
	molar_mass = 0.044	// kg/mol. N2O

	tile_overlay = "sleeping_agent"
	overlay_limit = 1
	flags = XGM_GAS_OXIDIZER //N2O is a powerful oxidizer
	dangerous = TRUE
	knowable = TRUE

/datum/xgm_gas/hydrogen
	id = "hydrogen"
	name = "Hydrogen"

	specific_heat = 100	// J/(mol*K)
	molar_mass = 0.002	// kg/mol

	flags = XGM_GAS_FUEL|XGM_GAS_FUSION_FUEL

	burn_product = "watervapor"
	knowable = TRUE

/datum/xgm_gas/hydrogen/deuterium
	id = "deuterium"
	name = "Deuterium"
	knowable = FALSE

/datum/xgm_gas/hydrogen/tritium
	id = "tritium"
	name = "Tritium"
	knowable = FALSE

/datum/xgm_gas/helium
	id = "helium"
	name = "Helium"

	specific_heat = 80	// J/(mol*K)
	molar_mass = 0.004	// kg/mol

	flags = XGM_GAS_FUSION_FUEL

/datum/xgm_gas/vapor
	id = "watervapor"
	name = "Water Vapor"

	specific_heat = 30	// J/(mol*K)
	molar_mass = 0.020	// kg/mol
