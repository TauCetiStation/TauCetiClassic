/obj/item/robot_parts/attack(mob/living/carbon/human/M, mob/living/carbon/user, def_zone)
	var/child = null

	if(!ishuman(M))
		return ..()

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	if((def_zone == BP_L_ARM) && (istype(src, /obj/item/robot_parts/l_arm)))
		child = BP_L_HAND
	else if((def_zone == BP_R_ARM) && (istype(src, /obj/item/robot_parts/r_arm)))
		child = BP_R_HAND
	else if((def_zone == BP_R_LEG) && (istype(src, /obj/item/robot_parts/r_leg)))
		child = BP_R_FOOT
	else if((def_zone == BP_L_LEG) && (istype(src, /obj/item/robot_parts/l_leg)))
		child = BP_L_FOOT
	else
		to_chat(user, "\red That doesn't fit there!")
		return ..()

	var/mob/living/carbon/human/H = M
	var/obj/item/organ/external/BP = H.get_bodypart(def_zone)
	if(BP.status & ORGAN_DESTROYED)
		if(!(BP.status & ORGAN_ATTACHABLE))
			to_chat(user, "\red The wound is not ready for a replacement!")
			return 0
		if(M != user)
			M.visible_message( \
				"\red [user] is beginning to attach \the [src] where [H]'s [BP.name] used to be.", \
				"\red [user] begins to attach \the [src] where your [BP.name] used to be.")
		else
			M.visible_message( \
				"\red [user] begins to attach a robotic limb where \his [BP.name] used to be with [src].", \
				"\red You begin to attach \the [src] where your [BP.name] used to be.")

		if(do_mob(user, H, 100))
			if(M != user)
				M.visible_message( \
					"\red [user] finishes attaching [H]'s new [BP.name].", \
					"\red [user] finishes attaching your new [BP.name].")
			else
				M.visible_message( \
					"\red [user] finishes attaching \his new [BP.name].", \
					"\red You finish attaching your new [BP.name].")

			if(H == user && prob(25))
				to_chat(user, "\red You mess up!")
				BP.take_damage(15)

			BP.status &= ~ORGAN_BROKEN
			BP.status &= ~ORGAN_SPLINTED
			BP.status &= ~ORGAN_ATTACHABLE
			BP.status &= ~ORGAN_DESTROYED
			BP.status |= ORGAN_ROBOT
			var/obj/item/organ/external/T = H.bodyparts_by_name[child]
			T.status &= ~ORGAN_BROKEN
			T.status &= ~ORGAN_SPLINTED
			T.status &= ~ORGAN_ATTACHABLE
			T.status &= ~ORGAN_DESTROYED
			T.status |= ORGAN_ROBOT
			H.update_body()
			M.updatehealth()
			M.UpdateDamageIcon(BP)
			qdel(src)

			return 1
		return 0
