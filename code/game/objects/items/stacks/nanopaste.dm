/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	origin_tech = "materials=4;engineering=3"
	amount = 10
	var/delay = 1 SECOND
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)

/obj/item/stack/nanopaste/attack(mob/living/M, mob/user, def_zone)
	var/skill_delay = apply_skill_bonus(user, delay, required_skills, multiplier = -0.25)
	if (isrobot(M))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if (R.getBruteLoss() || R.getFireLoss() )
			if(!use(1))
				to_chat(user, "<span class='danger'>You need more nanite paste to do this.</span>")
				return FALSE
			if(!do_mob(user, R, time = skill_delay, check_target_zone = TRUE))
				return
			R.adjustBruteLoss(-15)
			R.adjustFireLoss(-15)
			R.updatehealth()
			user.visible_message("<span class='notice'>\The [user] applied some [src] at [R]'s damaged areas.</span>",\
				"<span class='notice'>You apply some [src] at [R]'s damaged areas.</span>")
		else
			to_chat(user, "<span class='notice'>All [R]'s systems are nominal.</span>")

	if(ishuman(M)) //Repairing robolimbs
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.get_bodypart(def_zone)

		if(BP && BP.is_robotic())
			if(can_operate(H))
				for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
					if(IO.is_bruised())
						..()
						return TRUE
			if(BP.get_damage())
				if(!use(1))
					to_chat(user, "<span class='danger'>You need more nanite paste to do this.</span>")
					return FALSE
				if(!do_mob(user, H, time = skill_delay, check_target_zone = TRUE))
					return
				BP.heal_damage(15, 15, robo_repair = 1)
				H.updatehealth()
				user.visible_message("<span class='notice'>\The [user] applies some nanite paste at[user != M ? " \the [M]'s " : " \the "][BP.name] with \the [src].</span>",\
				"<span class='notice'>You apply some nanite paste at [user == M ? "your" : "[M]'s"] [BP.name].</span>")
				return TRUE
			else
				to_chat(user, "<span class='notice'>Noting to fix!</span>")
				return FALSE

	return ..()
