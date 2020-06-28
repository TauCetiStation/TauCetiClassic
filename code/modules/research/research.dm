/*
General Explination:
The research datum is the "folder" where all the research information is stored in a R&D console. It's also a holder for all the
various procs used to manipulate it. It has four variables and seven procs:

Variables:
- tech_trees is a list of all /datum/tech that can potentially be researched by the player.
- all_technologies is a list of all /datum/technology that can potentially be researched by the player.
- researched_tech contains all researched technologies
- design_by_id contains all existing /datum/design.
- known_designs contains all researched /datum/design.
- experiments contains data related to earning research points, more info in experiment.dm
- research_points is an ammount of points that can be spend on researching technologies
- design_categories_protolathe stores all unlocked categories for protolathe designs
- design_categories_imprinter stores all unlocked categories for circuit imprinter designs

Procs:
- AddDesign2Known: Adds a /datum/design to known_designs.
- IsResearched
- CanResearch
- UnlockTechology
- download_from: Unlocks all technologies from a different /datum/research and syncs experiment data
- forget_techology
- forget_random_technology
- forget_all

The tech datums are the actual "tech trees" that you improve through researching. Each one has five variables:
- Name:		Pretty obvious. This is often viewable to the players.
- Desc:		Pretty obvious. Also player viewable.
- ID:		This is the unique ID of the tech that is used by the various procs to find and/or maniuplate it.
- Level:	This is the current level of the tech. Based on the ammount of researched technologies
- MaxLevel: Maxium level possible for this tech. Based on the ammount of technologies of that tech

*/
/***************************************************************
**						Master Types						  **
**	Includes all the helper procs and basic tech processing.  **
***************************************************************/

/datum/research								//Holder for all the existing, archived, and known tech. Individual to console.
	var/list/known_designs = list()			//List of available designs (at base reliability).
	var/list/design_by_id = list()
	//Increased by each created prototype with formula: reliability += reliability * (RND_RELIABILITY_EXPONENT^created_prototypes)
	var/list/design_reliabilities = list()
	var/list/design_created_prototypes = list()
	var/list/design_categories_protolathe = list()
	var/list/design_categories_imprinter = list()

	var/list/datum/tech/tech_trees = list() // associative
	var/list/all_technologies = list() // associative
	var/list/researched_tech = list()

	var/datum/experiment_data/experiments

	var/research_points = 0

/datum/research/New()
	for(var/D in subtypesof(/datum/design))
		var/datum/design/d = new D(src)
		design_by_id[d.id] = d
		if(d.starts_unlocked)
			design_reliabilities[d.id] = 120
			design_created_prototypes[d.id] = 15
		else
			design_reliabilities[d.id] = 10
			design_created_prototypes[d.id] = 0

	for(var/T in subtypesof(/datum/tech))
		var/datum/tech/Tech_Tree = new T
		tech_trees[Tech_Tree.id] = Tech_Tree
		all_technologies[Tech_Tree.id] = list()

	for(var/T in subtypesof(/datum/technology))
		var/datum/technology/Tech = new T
		if(all_technologies[Tech.tech_type])
			all_technologies[Tech.tech_type][Tech.id] = Tech
		else
			WARNING("Unknown tech_type '[Tech.tech_type]' in technology '[Tech.name]'")

	for(var/tech_tree_id in tech_trees)
		var/datum/tech/Tech_Tree = tech_trees[tech_tree_id]
		Tech_Tree.maxlevel = 1 + length(all_technologies[tech_tree_id])

	for(var/design_id in design_by_id)
		var/datum/design/D = design_by_id[design_id]
		if(D.starts_unlocked)
			AddDesign2Known(D)

	experiments = new /datum/experiment_data()
	// This is a science station. Most tech is already at least somewhat known.
	experiments.init_known_tech()

/datum/research/proc/IsResearched(datum/technology/T)
	return !!researched_tech[T.id]

/datum/research/proc/CanResearch(datum/technology/T)
	if(T.cost > research_points)
		return FALSE

	for(var/t in T.required_tech_levels)
		var/datum/tech/Tech_Tree = tech_trees[t]
		var/level = T.required_tech_levels[t]

		if(Tech_Tree.level < level)
			return FALSE

	for(var/t in T.required_technologies)
		var/datum/technology/OTech = all_technologies[T.tech_type][t]

		if(!IsResearched(OTech))
			return FALSE

	return TRUE

/datum/research/proc/CanUpgrade(datum/technology/T)
	if(T.reliability_upgrade_cost > research_points)
		return FALSE
	return TRUE

/datum/research/proc/GetReliabilityUpgradeCost(datum/technology/T)
	if(!T.unlocks_designs || !T.unlocks_designs.len)
		return 0

	var/reliability_increase = 0
	var/total_reliability = 0

	for(var/t in T.unlocks_designs)
		reliability_increase += design_reliabilities[t] * (RND_RELIABILITY_EXPONENT ** design_created_prototypes[t])
		total_reliability += design_reliabilities[t]

	var/tech_cost_modifier = 1.0
	if(T.cost > 0.0)
		tech_cost_modifier = T.cost

	return round((tech_cost_modifier * (total_reliability + reliability_increase)) / (100 * T.unlocks_designs.len))

/datum/research/proc/GetAverageDesignReliability(datum/technology/T)
	if(!T.unlocks_designs || !T.unlocks_designs.len)
		return 0

	var/total_reliability = 0

	for(var/id in T.unlocks_designs)
		total_reliability += design_reliabilities[id]

	return round(total_reliability / T.unlocks_designs.len)

/datum/research/proc/UnlockTechology(datum/technology/T, force = FALSE)
	if(IsResearched(T))
		return
	if(!CanResearch(T) && !force)
		return

	researched_tech[T.id] = T
	if(!force)
		research_points -= T.cost
	tech_trees[T.tech_type].level += 1

	for(var/t in T.unlocks_designs)
		var/datum/design/D = design_by_id[t]

		AddDesign2Known(D)

	T.reliability_upgrade_cost = GetReliabilityUpgradeCost(T)
	T.avg_reliability = GetAverageDesignReliability(T)

/datum/research/proc/UpgradeTechology(datum/technology/T, force = FALSE)
	if(!IsResearched(T))
		return

	T.reliability_upgrade_cost = GetReliabilityUpgradeCost(T)

	if(!CanUpgrade(T) && !force)
		return

	if(!force)
		research_points -= T.reliability_upgrade_cost

	for(var/t in T.unlocks_designs)
		design_reliabilities[t] += design_reliabilities[t] * (RND_RELIABILITY_EXPONENT ** design_created_prototypes[t])
		design_reliabilities[t] = max(round(design_reliabilities[t], 5), 1)
		design_created_prototypes[t]++ // Since we don't want to be able to increase it infinitely.

	T.reliability_upgrade_cost = GetReliabilityUpgradeCost(T)
	T.avg_reliability = GetAverageDesignReliability(T)

/datum/research/proc/download_from(datum/research/O)
	design_reliabilities = O.design_reliabilities
	design_created_prototypes = O.design_created_prototypes

	for(var/tech_tree_id in O.tech_trees)
		var/datum/tech/Tech_Tree = O.tech_trees[tech_tree_id]
		var/datum/tech/Our_Tech_Tree = tech_trees[tech_tree_id]

		if(Tech_Tree.shown)
			Our_Tech_Tree.shown = Tech_Tree.shown

	for(var/tech_id in O.researched_tech)
		var/datum/technology/T = O.researched_tech[tech_id]
		UnlockTechology(T, force = TRUE)
	experiments.merge_with(O.experiments)

/datum/research/proc/forget_techology(datum/technology/T)
	if(!IsResearched(T))
		return
	var/datum/tech/Tech_Tree = tech_trees[T.tech_type]
	if(!Tech_Tree)
		return
	Tech_Tree.level -= 1
	researched_tech -= T.id

	for(var/t in T.unlocks_designs)
		var/datum/design/D = design_by_id[t]
		known_designs -= D

/datum/research/proc/forget_random_technology()
	if(researched_tech.len > 0)
		var/random_tech = pick(researched_tech)
		var/datum/technology/T = researched_tech[random_tech]

		forget_techology(T)

/datum/research/proc/forget_all(tech_type)
	var/datum/tech/Tech_Tree = tech_trees[tech_type]
	if(!Tech_Tree)
		return
	Tech_Tree.level = 1
	for(var/tech_id in researched_tech)
		var/datum/technology/T = researched_tech[tech_id]
		if(T.tech_type == tech_type)
			researched_tech -= tech_id

			for(var/t in T.unlocks_designs)
				var/datum/design/D = design_by_id[t]
				known_designs -= D

/datum/research/proc/AddDesign2Known(datum/design/D)
	for(var/datum/design/known in known_designs)
		if(D.id == known.id)
			return
	known_designs += D

	if(D.category)
		if(D.build_type & PROTOLATHE)
			for(var/cat in D.category)
				design_categories_protolathe |= cat
		else if(D.build_type & IMPRINTER)
			for(var/cat in D.category)
				design_categories_imprinter |= cat
	else
		if(D.build_type & PROTOLATHE)
			design_categories_protolathe |= "Unspecified"
		else if(D.build_type & IMPRINTER)
			design_categories_imprinter |= "Unspecified"

// Unlocks hidden tech trees
/datum/research/proc/check_item_for_tech(obj/item/I)
	var/list/temp_tech = experiments.ConvertReqString2List(I.origin_tech)
	if(!temp_tech.len)
		return

	for(var/tech_tree_id in tech_trees)
		var/datum/tech/T = tech_trees[tech_tree_id]
		if(T.shown || !T.item_tech_req)
			continue

		for(var/item_tech in temp_tech)
			if(item_tech == T.item_tech_req)
				T.shown = TRUE
				return

/***************************************************************
**						Technology Datums					  **
**	Includes all the various technoliges and what they make.  **
***************************************************************/

/obj/item/weapon/disk/tech_disk
	name = "Empty Disk"
	desc = "Wow. Is that a save icon?"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	m_amt = 30
	g_amt = 10
	var/datum/tech/stored

/obj/item/weapon/disk/tech_disk/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

/datum/tech	//Datum of individual technologies.
	var/name = "name"          //Name of the technology.
	var/shortname = "name"
	var/desc = "description"   //General description of what it does and what it makes.
	var/id = "id"              //An easily referenced ID. Must be alphanumeric, lower-case, and no symbols.
	var/level = 1              //A simple number scale of the research level. Level 0 = Secret tech.
	var/rare = 1               //How much CentCom wants to get that tech. Used in supply shuttle tech cost calculation.
	var/maxlevel               //Calculated based on the ammount of technologies
	var/shown = TRUE           //Used to hide tech that is not supposed to be shown from the start
	var/item_tech_req          //Deconstructing items with this tech will unlock this tech tree

/datum/tech/proc/getCost(current_level = null)
	// Calculates tech disk's supply points sell cost
	if(!current_level)
		current_level = initial(level)

	if(current_level >= level)
		return 0

	var/cost = 0
	for(var/i = current_level + 1 to level)
		if(i == initial(level))
			continue
		cost += i*rare

	return cost

//Trunk Technologies (don't require any other techs and you start knowning them).

/datum/tech/engineering
	name = "Engineering Research"
	shortname = "Engineering"
	desc = "Development of new and improved engineering parts."
	id = RESEARCH_ENGINEERING

/datum/tech/biotech
	name = "Biological Technology"
	shortname = "Biological"
	desc = "Research into the deeper mysteries of life and organic substances."
	id = RESEARCH_BIOTECH

/datum/tech/combat
	name = "Combat Systems Research"
	shortname = "Combat Systems"
	desc = "The development of offensive and defensive systems."
	id = RESEARCH_COMBAT

/datum/tech/powerstorage
	name = "Power Manipulation Technology"
	shortname = "Power Manipulation"
	desc = "The various technologies behind the storage and generation of electicity."
	id = RESEARCH_POWERSTORAGE

/datum/tech/bluespace
	name = "'Blue-space' Research"
	shortname = "Blue-space"
	desc = "Research into the sub-reality known as 'blue-space'."
	id = RESEARCH_BLUESPACE
	rare = 2

/datum/tech/robotics
	name = "Robotics Research"
	shortname = "Robotics"
	desc = "Research into the exosuits"
	id = RESEARCH_ROBOTICS

/datum/tech/illegal
	name = "Illegal Technologies Research"
	shortname = "Illegal Tech"
	desc = "The study of technologies that violate standard Nanotrasen regulations."
	id = RESEARCH_ILLEGAL
	rare = 3
	shown = FALSE
	item_tech_req = "syndicate" // research any traiter item and this tech will show up


/datum/technology
	var/name = "name"
	var/desc = "description"                // Not used because lazy
	var/id = "id"                           // should be unique
	var/tech_type                           // Which tech tree does this techology belongs to

	var/x = 0.5                             // Position on the tech tree map, 0 - left, 1 - right
	var/y = 0.5                             // 0 - down, 1 - top
	var/icon = "gun"                        // css class of techology icon, defined in shared.css

	var/list/required_technologies = list() // Ids of techologies that are required to be unlocked before this one. Should have same tech_type
	var/list/required_tech_levels = list()  // list("biotech" = 5, ...) Ids and required levels of tech
	var/cost = 100                          // How much research points required to unlock this techology

	var/reliability_upgrade_cost = 0        // Is set after researched, updated each time it is upgraded.
	var/avg_reliability = 0                 // Shows the average reliability of designs in this tech. Is set after researched, updated each time it is upgraded.

	var/list/unlocks_designs = list()       // Ids of designs that this technology unlocks

// Engineering

/datum/technology/basic_engineering
	name = "Basic Engineering"
	desc = "Basic"
	id = "basic_engineering"
	tech_type = RESEARCH_ENGINEERING

	x = 0.1
	y = 0.4
	icon = "wrench"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list("science_tool", "basic_micro_laser", "basic_matter_bin", "arcademachine", "libraryconsole", "autolathe", "vendor", "light_replacer", "weldingmask", "mesons")

/datum/technology/monitoring
	name = "Monitoring"
	desc = "Monitoring"
	id = "monitoring"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.4
	icon = "monitoring"

	required_technologies = list("basic_engineering")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("atmosalerts", "air_management")

/datum/technology/ice_and_fire
	name = "Ice And Fire"
	desc = "Ice And Fire"
	id = "ice_and_fire"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.6
	icon = "spaceheater"

	required_technologies = list("monitoring")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("space_heater", "gasheater", "gascooler", "universal_pyrometer")

/datum/technology/adv_engineering
	name = "Advanced Engineering"
	desc = "Advanced Engineering"
	id = "adv_engineering"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.4
	icon = "rd"

	required_technologies = list("monitoring")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("rdconsole", "rdservercontrol", "rdserver", "destructive_analyzer", "protolathe", "circuit_imprinter", "idcardconsole")

/datum/technology/tesla
	name = "Tesla"
	desc = "Tesla"
	id = "tesla"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.2
	icon = "tesla"

	required_technologies = list("adv_engineering")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("tesla_coil", "grounding_rod")

/datum/technology/supplyanddemand
	name = "Supply And Demand"
	desc = "Supply And Demand"
	id = "supply_and_demand"
	tech_type = RESEARCH_ENGINEERING

	x = 0.4
	y = 0.4
	icon = "advmop"

	required_technologies = list("adv_engineering")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("ordercomp", "supplycomp", "advmop", "holosign", "spraycan", "space_suit", "space_suit_helmet", "glowsticks_adv", "stimpack")

/datum/technology/basic_mining
	name = "Basic Mining"
	desc = "Basic Mining"
	id = "basic_mining"
	tech_type = RESEARCH_ENGINEERING

	x = 0.5
	y = 0.4
	icon = "drill"

	required_technologies = list("supply_and_demand")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("ore_redemption", "mining_equipment_vendor", "mining_fabricator", "drill", "excavation_drill", "scaner_imp", "mining_hud", "pick_diamond", "space_suit_science", "space_suit_helmet_science", "space_suit_recycler", "space_suit_helmet_recycler", "space_suit_mining", "space_suit_helmet_mining", "space_suit_engineering", "space_suit_helmet_engineering", "space_suit_atmospherics", "space_suit_helmet_atmospherics", "stimpack_imp")

/datum/technology/advanced_mining
	name = "Advanced Mining"
	desc = "Advanced Mining"
	id = "advanced_mining"
	tech_type = RESEARCH_ENGINEERING

	x = 0.6
	y = 0.4
	icon = "jackhammer"

	required_technologies = list("basic_mining")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("mining_drill", "mining_drill_brace", "excavation_drill_diamond", "drill_diamond", "scaner_adv", "jackhammer", "space_suit_medical", "space_suit_helmet_medical", "space_suit_mining_rig", "space_suit_helmet_mining_rig", "space_suit_security", "space_suit_helmet_security", "resonator", "kinetic_accelerator", "mining_drone", "mining_jetpack", "stimpack_adv")

/datum/technology/basic_handheld
	name = "Basic Handheld"
	desc = "Basic Handheld"
	id = "basic_handheld"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.6
	icon = "pda"

	required_technologies = list("adv_engineering")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("pda", "cart_basic", "cart_engineering", "cart_atmos", "cart_medical", "cart_chemistry", "cart_security", "cart_janitor", "cart_science", "cart_quartermaster")

/datum/technology/adv_handheld
	name = "Advanced Handheld"
	desc = "Advanced Handheld"
	id = "adv_handheld"
	tech_type = RESEARCH_ENGINEERING

	x = 0.6
	y = 0.6
	icon = "goldpda"

	required_technologies = list("basic_handheld")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("cart_hop", "cart_hos", "cart_ce", "cart_cmo", "cart_rd", "cart_captain")

/datum/technology/adv_parts
	name = "Advanced Parts"
	desc = "Advanced Parts"
	id = "adv_parts"
	tech_type = RESEARCH_ENGINEERING

	x = 0.7
	y = 0.5
	icon = "advmatterbin"

	required_technologies = list("adv_handheld", "advanced_mining")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("high_micro_laser", "adv_matter_bin")

/datum/technology/ultra_parts
	name = "Ultra Parts"
	desc = "Ultra Parts"
	id = "ultra_parts"
	tech_type = RESEARCH_ENGINEERING

	x = 0.8
	y = 0.5
	icon = "supermatterbin"

	required_technologies = list("adv_parts")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("ultra_micro_laser", "super_matter_bin", "nanopaste")

/datum/technology/telescience
	name = "Telescience"
	desc = "telescience"
	id = "telescience"
	tech_type = RESEARCH_ENGINEERING

	x = 0.8
	y = 0.3
	icon = "telescience"

	required_technologies = list("ultra_parts")
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list("telepad_concole", "telepad")

/datum/technology/bluespace_parts
	name = "Bluespace Parts"
	desc = "Bluespace Parts"
	id = "bluespace_parts"
	tech_type = RESEARCH_ENGINEERING

	x = 0.9
	y = 0.5
	icon = "bluespacematterbin"

	required_technologies = list("ultra_parts")
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list("quadultra_micro_laser", "bluespace_matter_bin")

/datum/technology/super_adv_engineering
	name = "Super Advanced Engineering"
	desc = "Super Advanced Engineering"
	id = "super_adv_engineering"
	tech_type = RESEARCH_ENGINEERING

	x = 0.8
	y = 0.7
	icon = "rped"

	required_technologies = list("ultra_parts")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("emitter", "rped", "plasmacutter", "magboots")

/datum/technology/adv_tools
	name = "Advanced Tools"
	desc = "Advanced Tools"
	id = "adv_tools"
	tech_type = RESEARCH_ENGINEERING

	x = 0.8
	y = 0.9
	icon = "jawsoflife"

	required_technologies = list("super_adv_engineering")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("exwelder", "jawsoflife", "handdrill")

// Biotech

/datum/technology/basic_biotech
	name = "Basic Biotech"
	desc = "Basic Biotech"
	id = "basic_biotech"
	tech_type = RESEARCH_BIOTECH

	x = 0.1
	y = 0.8
	icon = "healthanalyzer"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list("micro_mani", "basic_sensor")

/datum/technology/basic_med_machines
	name = "Basic Medical Machines"
	desc = "Basic Medical Machines"
	id = "basic_med_machines"
	tech_type = RESEARCH_BIOTECH

	x = 0.25
	y = 0.8
	icon = "operationcomputer"

	required_technologies = list("basic_biotech")
	required_tech_levels = list()
	cost = 200

	unlocks_designs = list("med_data", "operating")

/datum/technology/virology
	name = "Virology"
	desc = "Virology"
	id = "virology"
	tech_type = RESEARCH_BIOTECH

	x = 0.4
	y = 0.8
	icon = "vialbox"

	required_technologies = list("basic_med_machines")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("pandemic")

/datum/technology/adv_med_machines
	name = "Advanced Medical Machines"
	desc = "Advanced Medical Machines"
	id = "adv_med_machines"
	tech_type = RESEARCH_BIOTECH

	x = 0.25
	y = 0.6
	icon = "sleeper"

	required_technologies = list("basic_med_machines")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("sleeper", "cryotube", "crewconsole")

/datum/technology/cloning
	name = "Cloning"
	desc = "Cloning"
	id = "cloning"
	tech_type = RESEARCH_BIOTECH

	x = 0.25
	y = 0.4
	icon = "cloning"

	required_technologies = list("adv_med_machines")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("scan_console", "clonecontrol", "clonepod", "clonescanner")

/datum/technology/hydroponics
	name = "Hydroponics"
	desc = "Hydroponics"
	id = "hydroponics"
	tech_type = RESEARCH_BIOTECH

	x = 0.1
	y = 0.6
	icon = "hydroponics"

	required_technologies = list("basic_biotech")
	required_tech_levels = list()
	cost = 400

	unlocks_designs = list("biogenerator", "hydro_tray", "smartfridge", "seed_extractor")

/datum/technology/basic_food_processing
	name = "Basic Food Processing"
	desc = "Basic Food Processing"
	id = "basic_food_processing"
	tech_type = RESEARCH_BIOTECH

	x = 0.1
	y = 0.4
	icon = "microwave"

	required_technologies = list("hydroponics")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("deepfryer", "microwave", "oven", "grill")

/datum/technology/adv_food_processing
	name = "Advanced Food Processing"
	desc = "Advanced Food Processing"
	id = "adv_food_processing"
	tech_type = RESEARCH_BIOTECH

	x = 0.1
	y = 0.2
	icon = "candymachine"

	required_technologies = list("basic_food_processing")
	required_tech_levels = list()
	cost = 600

	unlocks_designs = list("gibber", "monkey_recycler", "processor", "candymaker")

/datum/technology/basic_medical_tools
	name = "Basic Medical Tools"
	desc = "Basic Medical Tools"
	id = "basic_medical_tools"
	tech_type = RESEARCH_BIOTECH

	x = 0.4
	y = 0.6
	icon = "medhud"

	required_technologies = list("adv_med_machines")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("mass_spectrometer", "reagent_scanner", "defibrillators_back", "scalpel_laser1", "health_hud", "security_hud")

/datum/technology/improved_biotech
	name = "Improved Biotech"
	desc = "Improved Biotech"
	id = "improved_biotech"
	tech_type = RESEARCH_BIOTECH

	x = 0.55
	y = 0.6
	icon = "handheldmonitor"

	required_technologies = list("basic_medical_tools")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("adv_sensor", "nano_mani", "implant_chem", "implant_death", "implant_tracking", "defibrillators_compact", "sensor_device", "scalpel_laser2", "biocan", "secmed_hud", "implanter", "airbag", "lazarus")

/datum/technology/med_teleportation
	name = "Medical Teleportation"
	desc = "Medical Teleportation"
	id = "med_teleportation"
	tech_type = RESEARCH_BIOTECH

	x = 0.7
	y = 0.5
	icon = "medbeacon"

	required_technologies = list("improved_biotech")
	required_tech_levels = list()
	cost = 1200

	unlocks_designs = list("beacon_warp", "body_warp")

/datum/technology/advanced_biotech
	name = "Advanced Biotech"
	desc = "Advanced Biotech"
	id = "advanced_biotech"
	tech_type = RESEARCH_BIOTECH

	x = 0.7
	y = 0.7
	icon = "rapidsyringegun"

	required_technologies = list("improved_biotech")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("phasic_sensor", "pico_mani", "adv_mass_spectrometer", "adv_reagent_scanner", "implant_loyal", "implant_mindshield", "defibrillators_standalone", "scalpel_laser3", "chemsprayer", "rapidsyringe")

/datum/technology/portable_chemistry
	name = "Portable Chemistry"
	desc = "Portable Chemistry"
	id = "portable_chemistry"
	tech_type = RESEARCH_BIOTECH

	x = 0.7
	y = 0.9
	icon = "chemdisp"

	required_technologies = list("advanced_biotech")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("chem_dispenser", "chem_master")

/datum/technology/top_biotech
	name = "Top-tier Biotech"
	desc = "Top-tier Biotech"
	id = "top_biotech"
	tech_type = RESEARCH_BIOTECH

	x = 0.85
	y = 0.7
	icon = "scalpelmanager"

	required_technologies = list("advanced_biotech")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("triphasic_scanning", "femto_mani", "scalpel_manager", "flora_gun")

// Combat

/datum/technology/basic_combat
	name = "Basic Combat Systems"
	desc = "Basic Combat Systems"
	id = "basic_combat"
	tech_type = RESEARCH_COMBAT

	x = 0.1
	y = 0.5
	icon = "stunbaton"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list()

/datum/technology/basic_nonlethal
	name = "Basic Non-Lethal"
	desc = "Basic Non-Lethal"
	id = "basic_nonlethal"
	tech_type = RESEARCH_COMBAT

	x = 0.3
	y = 0.5
	icon = "flash"

	required_technologies = list("basic_combat")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("sflash")

/datum/technology/advanced_nonlethal
	name = "Advanced Non-Lethal"
	desc = "Advanced Non-Lethal"
	id = "advanced_nonlethal"
	tech_type = RESEARCH_COMBAT

	x = 0.3
	y = 0.3
	icon = "stunrevolver"

	required_technologies = list("basic_nonlethal")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("stunrevolver", "stunshell", "beartrap", "riot_shield", "riot_helmet", "riot_suit")

/datum/technology/weapon_recharging
	name = "Weapon Recharging"
	desc = "Weapon Recharging"
	id = "weapon_recharging"
	tech_type = RESEARCH_COMBAT

	x = 0.5
	y = 0.5
	icon = "recharger"

	required_technologies = list("basic_nonlethal")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("recharger")

/datum/technology/sec_computers
	name = "Security Computers"
	desc = "Security Computers"
	id = "sec_computers"
	tech_type = RESEARCH_COMBAT

	x = 0.1
	y = 0.7
	icon = "seccomputer"

	required_technologies = list("basic_combat")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("seccamera", "secdata", "prisonmanage")

/datum/technology/basic_lethal
	name = "Basic Lethal Weapons"
	desc = "Basic Lethal Weapons"
	id = "basic_lethal"
	tech_type = RESEARCH_COMBAT

	x = 0.7
	y = 0.5
	icon = "ammobox"

	required_technologies = list("weapon_recharging")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("large_Grenade", "ammo_9mm")

/datum/technology/exotic_weaponry
	name = "Exotic Weaponry"
	desc = "Exotic Weaponry"
	id = "exotic_weaponry"
	tech_type = RESEARCH_COMBAT

	x = 0.7
	y = 0.3
	icon = "tempgun"

	required_technologies = list("basic_lethal")
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list("temp_gun")

/datum/technology/adv_exotic_weaponry
	name = "Advanced Exotic Weaponry"
	desc = "Advanced Exotic Weaponry"
	id = "adv_exotic_weaponry"
	tech_type = RESEARCH_COMBAT

	x = 0.9
	y = 0.3
	icon = "teslagun"

	required_technologies = list("exotic_weaponry")
	required_tech_levels = list()
	cost = 5000

	unlocks_designs = list("decloner", "tesla_gun", "ppistol")

/datum/technology/adv_lethal
	name = "Advanced Lethal Weapons"
	desc = "Advanced Lethal Weapons"
	id = "adv_lethal"
	tech_type = RESEARCH_COMBAT

	x = 0.7
	y = 0.7
	icon = "submachinegun"

	required_technologies = list("basic_lethal")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("smg")

/datum/technology/laser_weaponry
	name = "Laser Weaponry"
	desc = "Laser Weaponry"
	id = "laser_weaponry"
	tech_type = RESEARCH_COMBAT

	x = 0.9
	y = 0.7
	icon = "gun"

	required_technologies = list("adv_lethal", "adv_exotic_weaponry")
	required_tech_levels = list()
	cost = 5000

	unlocks_designs = list("nuclear_gun", "plasma_10_gun", "plasma_104_gun", "plasma_mag", "lasercannon", "laserrifle")

// Powerstorage

/datum/technology/basic_power
	name = "Basic Power"
	desc = "Basic Power"
	id = "basic_power"
	tech_type = RESEARCH_POWERSTORAGE

	x = 0.5
	y = 0.8
	icon = "cell"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list("powermonitor", "pacman", "basic_capacitor", "basic_cell", "high_cell")

/datum/technology/advanced_power
	name = "Advanced Power"
	desc = "Advanced Power"
	id = "advanced_power"
	tech_type = RESEARCH_POWERSTORAGE

	x = 0.5
	y = 0.6
	icon = "supercell"

	required_technologies = list("basic_power")
	required_tech_levels = list()
	cost = 200

	unlocks_designs = list("adv_capacitor", "super_cell")

/datum/technology/improved_power_generation
	name = "Improved Power Generation"
	desc = "Improved Power Generation"
	id = "improved_power_generation"
	tech_type = RESEARCH_POWERSTORAGE

	x = 0.3
	y = 0.6
	icon = "generator"

	required_technologies = list("advanced_power")
	required_tech_levels = list()
	cost = 400

	unlocks_designs = list("superpacman", "scrapman")

/datum/technology/advanced_power_storage
	name = "Advanced Power Storage"
	desc = "Advanced Power Storage"
	id = "advanced_power_storage"
	tech_type = RESEARCH_POWERSTORAGE

	x = 0.1
	y = 0.6
	icon = "smes"

	required_technologies = list("improved_power_generation")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("smes")

/datum/technology/solar_power
	name = "Solar Power"
	desc = "Solar Power"
	id = "solar_power"
	tech_type = RESEARCH_POWERSTORAGE

	x = 0.7
	y = 0.6
	icon = "solarcontrol"

	required_technologies = list("advanced_power")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("solarcontrol")

/datum/technology/super_power
	name = "Super Power"
	desc = "Super Power"
	id = "super_power"
	tech_type = RESEARCH_POWERSTORAGE

	x = 0.5
	y = 0.4
	icon = "hypercell"

	required_technologies = list("advanced_power")
	required_tech_levels = list()
	cost = 1200

	unlocks_designs = list("super_capacitor", "hyper_cell")

/datum/technology/advanced_power_generation
	name = "Advanced Power Generation"
	desc = "Advanced Power Generation"
	id = "advanced_power_generation"
	tech_type = RESEARCH_POWERSTORAGE

	x = 0.3
	y = 0.4
	icon = "supergenerator"

	required_technologies = list("super_power", "improved_power_generation")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("mrspacman")

/datum/technology/fusion_power_generation
	name = "R-UST Mk. 8 Tokamak Generator"
	desc = "R-UST Mk. 8 Tokamak Generator"
	id = "fusion_power_generation"
	tech_type = RESEARCH_POWERSTORAGE

	x = 0.1
	y = 0.4
	icon = "fusion"

	required_technologies = list("advanced_power_generation")
	required_tech_levels = list()
	cost = 5000

	unlocks_designs = list("fusion_core_control", "fusion_fuel_compressor", "fusion_fuel_control", "gyrotron_control", "fusion_core", "fusion_injector", "gyrotron")

/datum/technology/bluespace_power
	name = "Bluespace Power"
	desc = "Bluespace Power"
	id = "bluespace_power"
	tech_type = RESEARCH_POWERSTORAGE

	x = 0.5
	y = 0.2
	icon = "bluespacecell"

	required_technologies = list("super_power")
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list("quadratic_capacitor", "bluespace_cell")

// Bluespace

/datum/technology/basic_bluespace
	name = "Basic 'Blue-space'"
	desc = "Basic 'Blue-space'"
	id = "basic_bluespace"
	tech_type = RESEARCH_BLUESPACE

	x = 0.2
	y = 0.2
	icon = "gps"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list("telesci_gps", "beacon")

/datum/technology/radio_transmission
	name = "Radio Transmission"
	desc = "Radio Transmission"
	id = "radio_transmission"
	tech_type = RESEARCH_BLUESPACE

	x = 0.2
	y = 0.4
	icon = "headset"

	required_technologies = list("basic_bluespace")
	required_tech_levels = list()
	cost = 200

	unlocks_designs = list("standart_encrypt")

/datum/technology/telecommunications
	name = "Telecommunications"
	desc = "Telecommunications"
	id = "telecommunications"
	tech_type = RESEARCH_BLUESPACE

	x = 0.2
	y = 0.6
	icon = "communications"

	required_technologies = list("radio_transmission")
	required_tech_levels = list()
	cost = 600

	unlocks_designs = list("comconsole")

/datum/technology/bluespace_telecommunications
	name = "Bluespace Telecommunications"
	desc = "Bluespace Telecommunications"
	id = "bluespace_telecommunications"
	tech_type = RESEARCH_BLUESPACE

	x = 0.4
	y = 0.6
	icon = "bluespacething"

	required_technologies = list("telecommunications")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("comm_monitor", "comm_server", "message_monitor", "s-receiver", "s-bus", "s-hub", "s-relay", "s-processor", "s-server", "s-broadcaster", "s-ansible", "s-filter", "s-amplifier", "s-treatment", "s-analyzer", "s-crystal", "s-transmitter")

/datum/technology/bluespace_shield
	name = "Bluespace Shields"
	desc = "Bluespace Shields"
	id = "bluespace_shield"
	tech_type = RESEARCH_BLUESPACE

	x = 0.4
	y = 0.4
	icon = "shield"

	required_technologies = list("bluespace_telecommunications")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("shield_gen", "shield_gen_ex", "shield_cap")

/datum/technology/transmission_encryption
	name = "Transmission Encryption"
	desc = "Transmission Encryption"
	id = "transmission_encryption"
	tech_type = RESEARCH_BLUESPACE

	x = 0.2
	y = 0.8
	icon = "radiogrid"

	required_technologies = list("telecommunications")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("radio_grid")

/datum/technology/teleportation
	name = "Teleportation"
	desc = "Teleportation"
	id = "teleportation"
	tech_type = RESEARCH_BLUESPACE

	x = 0.6
	y = 0.6
	icon = "teleporter"

	required_technologies = list("bluespace_telecommunications")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("teleconsole", "tele_station", "tele_hub", "bluespace_crystal", "jaunter", "slime_management")

/datum/technology/bluespace_tools
	name = "Bluespace Tools"
	desc = "Bluespace Tools"
	id = "bluespace_tools"
	tech_type = RESEARCH_BLUESPACE

	x = 0.8
	y = 0.8
	icon = "bagofholding"

	required_technologies = list("teleportation")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("bluespacebeaker", "splitbeaker", "bag_holding", "minerbag_holding", "blutrash", "survivalcapsule")

/datum/technology/bluespace_rped
	name = "Bluespace RPED"
	desc = "Bluespace RPED"
	id = "bluespace_rped"
	tech_type = RESEARCH_BLUESPACE

	x = 0.8
	y = 0.4
	icon = "bluespacerped"

	required_technologies = list("teleportation")
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list("bs_rped")

// Robotics

/datum/technology/basic_robotics
	name = "Basic Robotics"
	desc = "Basic Robotics"
	id = "basic_robotics"
	tech_type = RESEARCH_ROBOTICS

	x = 0.5
	y = 0.2
	icon = "cyborganalyzer"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list("mechrecharger", "cyborgrecharger", "cyborg_analyzer", "mmi")

/datum/technology/mech_ripley
	name = "Ripley"
	desc = "Ripley"
	id = "mech_ripley"
	tech_type = RESEARCH_ROBOTICS

	x = 0.4
	y = 0.3
	icon = "ripley"

	required_technologies = list("basic_robotics")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("ripley_main", "ripley_peri")

/datum/technology/mech_odysseus
	name = "Odyssey"
	desc = "Odyssey"
	id = "mech_odysseus"
	tech_type = RESEARCH_ROBOTICS

	x = 0.6
	y = 0.3
	icon = "odyssey"

	required_technologies = list("basic_robotics")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("odysseus_main", "odysseus_peri")

/datum/technology/advanced_robotics
	name = "Advanced Robotics"
	desc = "Advanced Robotics"
	id = "advanced_robotics"
	tech_type = RESEARCH_ROBOTICS

	x = 0.5
	y = 0.5
	icon = "posbrain"

	required_technologies = list("mech_odysseus", "mech_ripley")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("mechacontrol", "mechapower", "mechfab", "robocontrol", "dronecontrol", "mmi_radio", "intellicard", "paicard", "posibrain")

/datum/technology/artificial_intelligence
	name = "Artificial intelligence"
	desc = "Artificial intelligence"
	id = "artificial_intelligence"
	tech_type = RESEARCH_ROBOTICS

	x = 0.5
	y = 0.65
	icon = "aicard"

	required_technologies = list("advanced_robotics")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("aifixer", "safeguard_module", "onehuman_module", "protectstation_module", "notele_module", "quarantine_module", "oxygen_module", "freeform_module", "reset_module", "purge_module", "freeformcore_module", "asimov_module", "paladin_module", "holopad", "aicore", "aiupload", "borgupload")

/datum/technology/mech_gyrax
	name = "Gygax"
	desc = "Gygax"
	id = "mech_gyrax"
	tech_type = RESEARCH_ROBOTICS

	x = 0.4
	y = 0.7
	icon = "gygax"

	required_technologies = list("advanced_robotics")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("gygax_main", "gygax_peri", "gygax_targ")

/datum/technology/mech_gyrax_ultra
	name = "Gygax Ultra"
	desc = "Gygax Ultra"
	id = "mech_gyrax_ultra"
	tech_type = RESEARCH_ROBOTICS

	x = 0.4
	y = 0.9
	icon = "gygaxultra"

	required_technologies = list("mech_gyrax")
	required_tech_levels = list()
	cost = 4000

	unlocks_designs = list("ultra_main", "ultra_peri", "ultra_targ")

/datum/technology/mech_durand
	name = "Durand"
	desc = "Durand"
	id = "mech_durand"
	tech_type = RESEARCH_ROBOTICS

	x = 0.6
	y = 0.7
	icon = "durand"

	required_technologies = list("advanced_robotics")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("durand_main", "durand_peri", "durand_targ")

/datum/technology/mech_vindicator
	name = "Vindicator"
	desc = "Vindicator"
	id = "mech_vindicator"
	tech_type = RESEARCH_ROBOTICS

	x = 0.6
	y = 0.9
	icon = "vindicator"

	required_technologies = list("mech_durand")
	required_tech_levels = list()
	cost = 4000

	unlocks_designs = list("vindicator_main", "vindicator_peri", "vindicator_targ")

/datum/technology/mech_utility_modules
	name = "Exosuit Utility Modules"
	desc = "Exosuit Utility Modules"
	id = "mech_utility_modules"
	tech_type = RESEARCH_ROBOTICS

	x = 0.25
	y = 0.5
	icon = "mechrcd"

	required_technologies = list("advanced_robotics")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("mech_wormhole_gen", "mech_rcd", "mech_gravcatapult", "mech_repair_droid", "mech_energy_relay", "mech_syringe_gun", "mech_diamond_drill", "mech_generator_nuclear")

/datum/technology/mech_teleporter_modules
	name = "Exosuit Teleporter Module"
	desc = "Exosuit Teleporter Module"
	id = "mech_teleporter_modules"
	tech_type = RESEARCH_ROBOTICS

	x = 0.1
	y = 0.5
	icon = "mechteleporter"

	required_technologies = list("mech_utility_modules")
	required_tech_levels = list()
	cost = 5000

	unlocks_designs = list("mech_teleporter")

/datum/technology/mech_armor_modules
	name = "Exosuit Armor Modules"
	desc = "Exosuit Armor Modules"
	id = "mech_armor_modules"
	tech_type = RESEARCH_ROBOTICS

	x = 0.25
	y = 0.8
	icon = "mecharmor"

	required_technologies = list("mech_utility_modules")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("mech_ccw_armor", "mech_proj_armor")

/datum/technology/mech_weaponry_modules
	name = "Exosuit Weaponry"
	desc = "Exosuit Weaponry"
	id = "mech_weaponry_modules"
	tech_type = RESEARCH_ROBOTICS

	x = 0.75
	y = 0.5
	icon = "mechgrenadelauncher"

	required_technologies = list("advanced_robotics")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("mech_scattershot", "mech_laser", "mech_grenade_launcher")

/datum/technology/mech_heavy_weaponry_modules
	name = "Exosuit Heavy Weaponry"
	desc = "Exosuit Heavy Weaponry"
	id = "mech_heavy_weaponry_modules"
	tech_type = RESEARCH_ROBOTICS

	x = 0.75
	y = 0.8
	icon = "mechlaser"

	required_technologies = list("mech_weaponry_modules")
	required_tech_levels = list()
	cost = 4000

	unlocks_designs = list("mech_carbine", "mech_laser_heavy", "mech_ion", "mech_pulse", "mech_missile_rack", "clusterbang_launcher")

/datum/technology/basic_hardsuit_modules
	name = "Basic Hardsuit Modules"
	desc = "Basic Hardsuit Modules"
	id = "basic_hardsuit_modules"
	tech_type = RESEARCH_ROBOTICS

	x = 0.35
	y = 0.1
	icon = "rigscanner"

	required_technologies = list()
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("rigsimpleai", "rigflash", "righealthscanner", "riganomalyscanner", "rigorescanner", "rigextinguisher", "rigmetalfoamspray", "rigcoolingunit")

/datum/technology/advanced_hardsuit_modules
	name = "Advanced Hardsuit Modules"
	desc = "Basic Hardsuit Modules"
	id = "advanced_hardsuit_modules"
	tech_type = RESEARCH_ROBOTICS

	x = 0.5
	y = 0.1
	icon = "rigtaser"

	required_technologies = list("basic_hardsuit_modules")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("rigadvancedai", "riggrenadelauncherflashbang", "rigdrill", "rigselfrepair", "rigmountedtaser", "rigcombatinjector", "rigmedicalinjector")

/datum/technology/toptier_hardsuit_modules
	name = "Top-Tier Hardsuit Modules"
	desc = "Top-Tier Hardsuit Modules"
	id = "toptier_hardsuit_modules"
	tech_type = RESEARCH_ROBOTICS

	x = 0.65
	y = 0.1
	icon = "rignuclearreactor"

	required_technologies = list("advanced_hardsuit_modules")
	required_tech_levels = list()
	cost = 5000

	unlocks_designs = list("rigmountedlaserrifle", "rigrcd", "rigmedteleport", "rignuclearreactor")

// Illegal

/datum/technology/binary_encryption_key
	name = "Binary Encrpytion Key"
	desc = "Binary Encrpytion Key"
	id = "binary_encryption_key"
	tech_type = RESEARCH_ILLEGAL

	x = 0.1
	y = 0.5
	icon = "headset"

	required_technologies = list()
	required_tech_levels = list(RESEARCH_BLUESPACE = 5)
	cost = 2000

	unlocks_designs = list("binaryencrypt")

/datum/technology/chameleon_kit
	name = "Chameleon Kit"
	desc = "Chameleon Kit"
	id = "chameleon_kit"
	tech_type = RESEARCH_ILLEGAL

	x = 0.3
	y = 0.5
	icon = "chamelion"

	required_technologies = list("binary_encryption_key")
	required_tech_levels = list(RESEARCH_ENGINEERING = 10)
	cost = 3000

	unlocks_designs = list("chameleon")

/datum/technology/freedom_implant
	name = "Glass Case- 'Freedom'"
	desc = "Glass Case- 'Freedom'"
	id = "freedom_implant"
	tech_type = RESEARCH_ILLEGAL

	x = 0.5
	y = 0.5
	icon = "freedom"

	required_technologies = list("chameleon_kit")
	required_tech_levels = list(RESEARCH_BIOTECH = 5)
	cost = 3000

	unlocks_designs = list("implant_free")

/datum/technology/tyrant_aimodule
	name = "AI Core Module (T.Y.R.A.N.T.)"
	desc = "AI Core Module (T.Y.R.A.N.T.)"
	id = "tyrant_aimodule"
	tech_type = RESEARCH_ILLEGAL

	x = 0.7
	y = 0.5
	icon = "module"

	required_technologies = list("freedom_implant")
	required_tech_levels = list(RESEARCH_ROBOTICS = 5)
	cost = 3000

	unlocks_designs = list("tyrant_module")

/datum/technology/borg_syndicate_module
	name = "Borg Illegal Weapons Upgrade"
	desc = "Borg Illegal Weapons Upgrade"
	id = "borg_syndicate_module"
	tech_type = RESEARCH_ILLEGAL

	x = 0.9
	y = 0.5
	icon = "borgmodule"

	required_technologies = list("tyrant_aimodule")
	required_tech_levels = list(RESEARCH_ROBOTICS = 10)
	cost = 5000

	unlocks_designs = list("borg_syndicate_module")