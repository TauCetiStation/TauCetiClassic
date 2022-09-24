/obj/mecha/combat
	force = 30
	var/melee_cooldown = 10
	var/melee_can_hit = 1
	var/list/destroyable_obj = list(/obj/mecha, /obj/structure/window, /obj/structure/grille, /turf/simulated/wall)
	internal_damage_threshold = 50
	maint_access = 0
	//add_req_access = 0
	//operation_req_access = list(access_hos)
	damage_absorption = list(BRUTE=0.7,BURN=1,BULLET=0.7,LASER=0.85,ENERGY=1,BOMB=0.8)
	var/am = "d3c2fbcadca903a41161ccc9df9cf948"
	var/animated = 0
	speed_skills = list(/datum/skill/combat_mech = SKILL_LEVEL_MASTER)
	interface_skills = list(/datum/skill/combat_mech = SKILL_LEVEL_TRAINED)


/*
/obj/mecha/combat/range_action(target)
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		target = pick(view(3,target))
	if(selected_weapon)
		selected_weapon.fire(target)
	return
*/

/obj/mecha/combat/melee_action(atom/target)
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		target = safepick(oview(1,src))
	if(!melee_can_hit || !isatom(target)) return
	if(isliving(target))
		var/mob/living/M = target
		if(src.occupant.a_intent == INTENT_HARM)
			playsound(src, pick(SOUNDIN_PUNCH_VERYHEAVY), VOL_EFFECTS_MASTER)
			if(damtype == BRUTE)
				step_away(M,src,15)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				var/obj/item/organ/external/BP = H.bodyparts_by_name[pick(BP_CHEST , BP_CHEST , BP_CHEST , BP_HEAD)]
				if(BP)
					switch(damtype)
						if(BRUTE)
							H.Paralyse(1)
							BP.take_damage(rand(force / 2, force), 0)
						if(BURN)
							BP.take_damage(0, rand(force / 2, force))
						if(TOX)
							if(H.reagents)
								if(H.reagents.get_reagent_amount("carpotoxin") + force < force*2)
									H.reagents.add_reagent("carpotoxin", force)
								if(H.reagents.get_reagent_amount("cryptobiolin") + force < force*2)
									H.reagents.add_reagent("cryptobiolin", force)
						else
							return
				H.updatehealth()

			else
				switch(damtype)
					if(BRUTE)
						M.Paralyse(1)
						M.take_overall_damage(rand(force/2, force))
					if(BURN)
						M.take_overall_damage(0, rand(force/2, force))
					if(TOX)
						if(M.reagents)
							if(M.reagents.get_reagent_amount("carpotoxin") + force < force*2)
								M.reagents.add_reagent("carpotoxin", force)
							if(M.reagents.get_reagent_amount("cryptobiolin") + force < force*2)
								M.reagents.add_reagent("cryptobiolin", force)
					else
						return
				M.updatehealth()
			occupant_message("You hit [target].")
			visible_message("<font color='red'><b>[src.name] hits [target].</b></font>")
		else
			step_away(M,src)
			occupant_message("You push [target] out of the way.")
			visible_message("[src] pushes [target] out of the way.")

		melee_can_hit = FALSE
		VARSET_IN(src, melee_can_hit, TRUE, melee_cooldown)
		return

	else
		if(damtype == BRUTE)
			for(var/target_type in destroyable_obj)
				if(istype(target, target_type) && hascall(target, "attackby"))
					occupant_message("You hit [target].")
					visible_message("<font color='red'><b>[name] hits [target]</b></font>")
					if(iswallturf(target))
						var/turf/simulated/wall/W = target
						W.add_dent(WALL_DENT_HIT)
						if(prob(5))
							W.dismantle_wall(TRUE)
							occupant_message("<span class='notice'>You smash through the wall.</span>")
							visible_message("<b>[name] smashes through the wall</b>")
							playsound(src, 'sound/weapons/smash.ogg', VOL_EFFECTS_MASTER)
					else
						target.attackby(src,src.occupant)
					melee_can_hit = FALSE
					VARSET_IN(src, melee_can_hit, TRUE, melee_cooldown)
					break

/obj/mecha/combat/moved_inside(mob/living/carbon/human/H)
	if(..())
		if(H.client)
			H.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0

/obj/mecha/combat/mmi_moved_inside(obj/item/device/mmi/mmi_as_oc,mob/user)
	if(..())
		if(occupant.client)
			occupant.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0


/obj/mecha/combat/go_out()
	if(src.occupant && src.occupant.client)
		src.occupant.client.mouse_pointer_icon = initial(src.occupant.client.mouse_pointer_icon)
	..()
	return

/obj/mecha/combat/Topic(href,href_list)
	..()
	var/datum/topic_input/F = new (href,href_list)
	if(F.get("close"))
		am = null
		return
	/*
	if(F.get("saminput"))
		if(md5(F.get("saminput")) == am)
			occupant_message("From the lies of the Antipath, Circuit preserve us.")
		am = null
	return
	*/
