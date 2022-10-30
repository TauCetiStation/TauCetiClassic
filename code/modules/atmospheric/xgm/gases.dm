/datum/xgm_gas/phoron
	id = "phoron"
	name = "Phoron"
	desc = "Volatile and toxic gas with exotic physical properties. Slightly increases SM power generation, but deals damage to it at the same time."

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
	supermatter_power_bonus = 0.8
	supermatter_damage_bonus = 0.2
	dangerous = TRUE
	knowable = TRUE

	initial_rnd_points = 1000

/datum/xgm_gas/oxygen
	id = "oxygen"
	name = "Oxygen"
	desc = "Mild oxidizer. Essential for many lifeforms, including humans, but is highly toxic for vox race. Slightly increases SM power generation"
	specific_heat = 20	// J/(mol*K)
	molar_mass = 0.032	// kg/mol
	supermatter_power_bonus = 0.4

	flags = XGM_GAS_OXIDIZER | XGM_GAS_FUSION_FUEL
	knowable = TRUE

/datum/xgm_gas/nitrogen
	id = "nitrogen"
	name = "Nitrogen"
	desc = "Gas with low chemical activity. It is commonly used in air mix, for restricting pure oxygen volatility. Also essential for vox race. Slightly lowers SM power generation."
	specific_heat = 20	// J/(mol*K)
	molar_mass = 0.028	// kg/mol
	supermatter_power_bonus = -0.4
	knowable = TRUE

/datum/xgm_gas/carbon_dioxide
	id = "carbon_dioxide"
	name = "Carbon Dioxide"
	desc = "By-product of many combustion reactions. Lethal in large quantities."
	specific_heat = 30	// J/(mol*K)
	molar_mass = 0.044	// kg/mol
	knowable = TRUE

/datum/xgm_gas/sleeping_agent
	id = "sleeping_agent"
	name = "Nitrous Oxide"
	desc = "A.K.A nitrogen dioxide or laughing gas. Potent oxidizer, will cause uncontrolled laughter and drowsyness on inhalation."
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
	desc = "Most common element in the universe, hydrogen can be used as fuel, both for classic gas turbines and fusion reactors. Highly volatile."

	specific_heat = 100	// J/(mol*K)
	molar_mass = 0.002	// kg/mol
	supermatter_power_bonus = 0.4

	flags = XGM_GAS_FUEL|XGM_GAS_FUSION_FUEL

	burn_product = "watervapor"
	knowable = TRUE

/datum/xgm_gas/hydrogen/deuterium
	id = "deuterium"
	name = "Deuterium"
	desc = "Isotope of hydrogen with an extra neutron. Good fusion fuel."
	knowable = FALSE

	initial_rnd_points = 500

/datum/xgm_gas/hydrogen/tritium
	id = "tritium"
	name = "Tritium"
	knowable = FALSE
	desc = "Isotope of hydrogen with two extra neutrons. Good fusion fuel."

	initial_rnd_points = 500

/datum/xgm_gas/helium
	id = "helium"
	name = "Helium"
	desc = "Light, chemically inert gas. Good fusion fuel."

	specific_heat = 80	// J/(mol*K)
	molar_mass = 0.004	// kg/mol

	flags = XGM_GAS_FUSION_FUEL

	initial_rnd_points = 500

/datum/xgm_gas/vapor
	id = "watervapor"
	name = "Water Vapor"
	desc = "Regular water vapor."

	specific_heat = 30	// J/(mol*K)
	molar_mass = 0.020	// kg/mol

/datum/xgm_gas/bz
	id = "bz"
	name = "BZ"
	desc = "Hallucinogenic gas with mild toxicity. Used in other gas reactions, and for supressing changeling abilities. Has negative impact on SM stability."

	specific_heat = 100
	molar_mass = 0.12

	tile_overlay = "sleeping_agent"
	overlay_limit = 1
	supermatter_damage_bonus = 0.4

	dangerous = TRUE
	knowable = FALSE
	inhalation_proc = /datum/xgm_gas/bz/on_inhalation

	initial_rnd_points = 5000

/datum/xgm_gas/constantium
	id = "const"
	name = "Constantium"
	desc = "Chemically inert gas. So inert, that it halts synthesis of various other gases. Also may be used to passivise SM crystal in emergency situation."

	specific_heat = 50
	molar_mass = 0.06

	tile_overlay = "meta_stabilium"
	overlay_limit = 1
	supermatter_power_bonus = -2
	supermatter_damage_bonus = -0.4

	knowable = FALSE
	inhalation_proc = /datum/xgm_gas/constantium/on_inhalation

	initial_rnd_points = 5000

/datum/xgm_gas/trioxium
	id = "triox"
	name = "Trioxium"
	desc = "Deriative of oxygen. While being a more potent oxidizer than oxygen, it's also slightly toxic and unstable if heated. Increases SM power generation, but with a risk of delamination."

	specific_heat = 25
	molar_mass = 0.06

	tile_overlay = "trioxium"
	overlay_limit = 0.7
	supermatter_power_bonus = 1
	supermatter_damage_bonus = 0.2

	flags = XGM_GAS_OXIDIZER
	knowable = FALSE
	inhalation_proc = /datum/xgm_gas/trioxium/on_inhalation

	initial_rnd_points = 10000

/datum/xgm_gas/proto_hydrate
	id = "phydr"
	name = "Proto-Hydrate"
	desc = "Deriative of hydrogen. Highly chemically active and volatile. Also stimulates human neural system, supressing pain and tireness, at the cost of mild toxicity. Has negative impact on SM stability."

	specific_heat = 150
	molar_mass = 0.01

	tile_overlay = "proto_hydrate"
	overlay_limit = 0.7
	supermatter_power_bonus = 0.8
	supermatter_damage_bonus = 0.8

	burn_product = "watervapor"
	flags = XGM_GAS_FUEL | XGM_GAS_FUSION_FUEL
	knowable = FALSE
	inhalation_proc = /datum/xgm_gas/proto_hydrate/on_inhalation

	initial_rnd_points = 10000

/datum/xgm_gas/cardotirin
	id = "ctirin"
	name = "Cardotirin"
	desc = "Gas with mild chemical activity. Stimulates human immune and hormonal systems, improving mood and accelerating wound regeneration, at the cost of increased drowsyness."

	tile_overlay = "cardotirin"
	overlay_limit = 0.7

	specific_heat = 50
	molar_mass = 0.06

	knowable = FALSE
	inhalation_proc = /datum/xgm_gas/cardotirin/on_inhalation

	initial_rnd_points = 30000

/datum/xgm_gas/metastabilium
	id = "mstab"
	name = "Meta-Stabilium"
	desc = "Gas with weird physical properties, which in theory should cause gas to instantly decompose, but actually don't. Posseses high scientific interest, but it's synthesis conditions are changing with time, due to local bluespace fluctuations."

	tile_overlay = "meta_stabilium"
	overlay_limit = 1

	specific_heat = 100
	molar_mass = 0.2

	knowable = FALSE

	initial_rnd_points = 100000
