/obj/item/weapon/skill_cartridge
	name = "USP cartridge"
	desc = "Used in conjunction with the CMF apparatus to rapidly alter skills."
	icon = 'icons/obj/skills/cartridges.dmi'
	w_class = SIZE_TINY
	icon_state = "green"
	var/points
	var/list/compatible_species = list(HUMAN, TAJARAN, UNATHI)
	var/unpacked = FALSE

/obj/item/weapon/skill_cartridge/green
	name = "USP-5 cartridge"
	icon_state = "green"
	points = 5

/obj/item/weapon/skill_cartridge/blue
	name = "USP-7 cartridge"
	icon_state = "blue"
	points = 7

/obj/item/weapon/skill_cartridge/red
	name = "USP-10 cartridge"
	icon_state = "red"
	points = 10

/obj/item/weapon/skill_cartridge/purple
	name = "USP-15 cartridge"
	item_state = "card-id"
	icon_state = "purple"
	points = 15

/obj/item/weapon/skill_cartridge/ipc
	name = "CSP-15 cartridge"
	desc = "Used together with the CMF apparatus to rapidly alter skills. Specifically, this one can be used with the IPC."
	icon_state = "ipc"
	points = 15
	compatible_species= list(IPC)

/obj/item/weapon/implant/skill
	name = "CMF implant"
	var/datum/skillset/added_skillset


/obj/item/weapon/implant/skill/implanted(mob/source)
	if(!ishuman(source))
		return
	var/mob/living/carbon/human/H = source
	if(H.ismindprotect())
		H.adjustBrainLoss(25)
		return
	H.add_skills_buff(added_skillset)
	return 1

/obj/item/weapon/implant/skill/emp_act(severity)
	if (malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY

	if(severity == 1)
		if(prob(40))	//small chance of obvious meltdown
			meltdown()
	spawn(20)
		malfunction--

/obj/item/weapon/implant/skill/meltdown()
	..()
	if(!imp_in || !ishuman(imp_in))
		return
	var/mob/living/M = imp_in
	M.remove_skills_buff(added_skillset)
	M.adjustBrainLoss(100)

/obj/item/weapon/implant/skill/proc/removed()
	meltdown()