/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	origin_tech = "materials=4;engineering=3"
	amount = 10

/obj/item/stack/nanopaste/attack(mob/living/M, mob/user, def_zone)
	if (istype(M,/mob/living/silicon/robot))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if (R.getBruteLoss() || R.getFireLoss() )
			if(!use(1))
				to_chat(user, "<span class='danger'>You need more nanite paste to do this.</span>")
				return FALSE
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

		if(BP && (BP.is_robotic()))
			if(BP.get_damage())
				if(!use(1))
					to_chat(user, "<span class='danger'>You need more nanite paste to do this.</span>")
					return FALSE
				BP.heal_damage(15, 15, robo_repair = 1)
				H.updatehealth()
				user.visible_message("<span class='notice'>\The [user] applies some nanite paste at[user != M ? " \the [M]'s" : " \the"][BP.name] with \the [src].</span>",\
				"<span class='notice'>You apply some nanite paste at [user == M ? "your" : "[M]'s"] [BP.name].</span>")
				return TRUE

	return ..()
