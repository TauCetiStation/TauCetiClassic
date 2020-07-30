/obj/item/clothing/suit/space/space_ninja/proc/stealth()
	set name = "Toggle Stealth"
	set desc = "Utilize the internal CLOAK-tech device to activate or deactivate stealth-camo."
	//set category = "Ninja Equip"
	set category = "Ninja Ability"

	if(s_control&&!s_busy)
		toggle_stealth()
	else
		to_chat(affecting, "<span class='warning'>Stealth does not appear to work!</span>")
	return

/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	var/mob/living/carbon/human/U = affecting
	if(s_active)
		cancel_stealth()
	else
		anim(U.loc,U,'icons/mob/mob.dmi',,"cloak",,U.dir)
		s_active=TRUE
		icon_state = U.gender==FEMALE ? "s-ninjasf" : "s-ninjas"
		U.regenerate_icons()	//update their icons
		U.visible_message("[U.name] vanishes into thin air!", "<span class='notice'>You are now invisible to normal detection.</span>")
		U.invisibility = INVISIBILITY_LEVEL_TWO
		if(istype(U.get_active_hand(), /obj/item/weapon/melee/energy/blade))
			U.drop_item()
		if(istype(U.get_inactive_hand(), /obj/item/weapon/melee/energy/blade))
			U.swap_hand()
			U.drop_item()
	return

/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	var/mob/living/carbon/human/U = affecting
	if(s_active)
		anim(U.loc,U,'icons/mob/mob.dmi',,"uncloak",,U.dir)
		s_active=FALSE
		U.invisibility = 0
		U.visible_message("[U.name] appears from thin air!", "<span class='notice'>You are now visible.</span>")
		if(U.mind.protector_role)
			icon_state = U.gender==FEMALE ? "s-ninjakf" : "s-ninjak"
		else
			icon_state = U.gender==FEMALE ? "s-ninjanf" : "s-ninjan"
		U.regenerate_icons()	//update their icons
		return 1
	return 0

/obj/item/clothing/suit/space/space_ninja/proc/pop_stealth()
	var/mob/living/carbon/human/U = affecting
	if(s_active)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, get_turf(U))
		sparks.start()
		sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, get_turf(U))
		sparks.start()

		s_active=FALSE
		U.invisibility = 0
		U.visible_message("[U.name] appears from thin air!", "<span class='notice'>You are now visible.</span>")
		if(U.mind.protector_role)
			icon_state = U.gender==FEMALE ? "s-ninjakf" : "s-ninjak"
		else
			icon_state = U.gender==FEMALE ? "s-ninjanf" : "s-ninjan"
		U.regenerate_icons()	//update their icons
		return 1
	return 0
