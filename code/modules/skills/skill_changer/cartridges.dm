/obj/item/weapon/skill_cartridge
	name = "USP cartridge"
	desc = "Used in conjunction with the CMF apparatus to rapidly alter skills."
	icon = 'icons/obj/skills/cartridges.dmi'
	w_class = SIZE_TINY
	icon_state = "green"
	var/points
	var/list/compatible_species = list(HUMAN, TAJARAN, UNATHI)
	var/unpacked = FALSE
	var/list/selected_buffs

/obj/item/weapon/skill_cartridge/atom_init()
	. = ..()
	selected_buffs = list()
	for(var/skill_type in all_skills)
		selected_buffs[skill_type] = 0

/obj/item/weapon/skill_cartridge/proc/set_skills_buff(skills_list)
	var/new_points = 0
	for(var/skill_name in skills_list)
		if(skills_list[skill_name] < SKILL_LEVEL_MIN || skills_list[skill_name] > SKILL_LEVEL_HUMAN_MAX)
			return
		new_points += skills_list[skill_name]
	if(new_points > points)
		return
	for(var/skill_name in skills_list)
		for(var/skill_type in selected_buffs)
			var/datum/skill/skill = all_skills[skill_type]
			if(skill.name == skill_name)
				selected_buffs[skill_type] = skills_list[skill_name]

/obj/item/weapon/skill_cartridge/proc/get_used_points()
	var/result = 0
	for(var/skill_type in selected_buffs)
		result += selected_buffs[skill_type]
	return result

/obj/item/weapon/skill_cartridge/proc/get_buff_list()
	var/list/result = list()
	for(var/skill_type in selected_buffs)
		var/datum/skill/skill = all_skills[skill_type]
		result[skill.name] = selected_buffs[skill_type]
	return result

/obj/item/weapon/skill_cartridge/usp5
	name = "USP-5 cartridge"
	icon_state = "green"
	points = 5

/obj/item/weapon/skill_cartridge/usp7
	name = "USP-7 cartridge"
	icon_state = "blue"
	points = 7

/obj/item/weapon/skill_cartridge/usp10
	name = "USP-10 cartridge"
	icon_state = "red"
	points = 10

/obj/item/weapon/skill_cartridge/usp15
	name = "USP-15 cartridge"
	item_state = "card-id"
	icon_state = "purple"
	points = 15

/obj/item/weapon/skill_cartridge/csp15
	name = "CSP-15 cartridge"
	desc = "Used together with the CMF apparatus to rapidly alter skills. Specifically, this one can be used with the IPC."
	icon_state = "ipc"
	points = 15
	compatible_species= list(IPC)
