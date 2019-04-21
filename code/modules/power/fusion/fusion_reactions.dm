#define FUSION_HEAT_CAP 1.57e7

var/list/fusion_reactions

/datum/fusion_reaction
	var/p_react = "" // Primary reactant.
	var/s_react = "" // Secondary reactant.
	var/minimum_energy_level = 1
	var/energy_consumption = 0
	var/energy_production = 0
	var/radiation = 0
	var/instability = 0
	var/list/products = list()
	var/minimum_reaction_temperature = 100

/datum/fusion_reaction/proc/handle_reaction_special(obj/effect/fusion_em_field/holder)
	return 0

/proc/get_fusion_reaction(p_react, s_react, m_energy)
	if(!fusion_reactions)
		fusion_reactions = list()
		for(var/rtype in typesof(/datum/fusion_reaction) - /datum/fusion_reaction)
			var/datum/fusion_reaction/cur_reaction = new rtype()
			if(!fusion_reactions[cur_reaction.p_react])
				fusion_reactions[cur_reaction.p_react] = list()
			fusion_reactions[cur_reaction.p_react][cur_reaction.s_react] = cur_reaction
			if(!fusion_reactions[cur_reaction.s_react])
				fusion_reactions[cur_reaction.s_react] = list()
			fusion_reactions[cur_reaction.s_react][cur_reaction.p_react] = cur_reaction

	if(fusion_reactions.Find(p_react))
		var/list/secondary_reactions = fusion_reactions[p_react]
		if(secondary_reactions.Find(s_react))
			return fusion_reactions[p_react][s_react]

// Material fuels
//  deuterium
//  tritium
//  phoron

// Gaseous/reagent fuels
// hydrogen
//  helium
//  lithium
//  boron

// Basic power production reactions.
// This is not necessarily realistic, but it makes a basic failure more spectacular.
/datum/fusion_reaction/hydrogen_hydrogen
	p_react = "hydrogen"
	s_react = "hydrogen"
	energy_consumption = 1
	energy_production = 2
	products = list("helium" = 1)

/datum/fusion_reaction/deuterium_deuterium
	p_react = "deuterium"
	s_react = "deuterium"
	energy_consumption = 1
	energy_production = 2

// Advanced production reactions (todo)
/datum/fusion_reaction/deuterium_helium
	p_react = "deuterium"
	s_react = "helium"
	energy_consumption = 1
	energy_production = 5
	radiation = 2

/datum/fusion_reaction/deuterium_tritium
	p_react = "deuterium"
	s_react = "tritium"
	energy_consumption = 1
	energy_production = 1
	products = list("helium" = 1)
	instability = 0.5
	radiation = 3

/datum/fusion_reaction/deuterium_lithium
	p_react = "deuterium"
	s_react = "lithium"
	energy_consumption = 2
	energy_production = 0
	radiation = 3
	products = list("tritium"= 1)
	instability = 1

// Unideal/material production reactions
/datum/fusion_reaction/oxygen_oxygen
	p_react = "oxygen"
	s_react = "oxygen"
	energy_consumption = 10
	energy_production = 0
	instability = 5
	radiation = 5
	products = list("silicon"= 1)

/datum/fusion_reaction/iron_iron
	p_react = "iron"
	s_react = "iron"
	products = list("silver" = 1, "gold" = 1, "platinum" = 1) // Not realistic but w/e
	energy_consumption = 10
	energy_production = 0
	instability = 2
	minimum_reaction_temperature = 10000

/datum/fusion_reaction/phoron_hydrogen
	p_react = "hydrogen"
	s_react = "phoron"
	energy_consumption = 10
	energy_production = 0
	instability = 5
	products = list("mydrogen" = 1)
	minimum_reaction_temperature = 8000

// High end reactions.
/datum/fusion_reaction/boron_hydrogen
	p_react = "boron"
	s_react = "hydrogen"
	minimum_energy_level = FUSION_HEAT_CAP * 0.5
	energy_consumption = 3
	energy_production = 15
	radiation = 3
	instability = 3

#undef FUSION_HEAT_CAP
