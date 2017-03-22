//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.

//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity
	priority = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!hasbodyparts(target))
			return 0
		if(!ishuman(target))
			return 0
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		return BP.open >= 2 && !(BP.status & ORGAN_BLEEDING) && (target_zone != "chest" || target.op_stage.ribcage == 2)

	proc/get_max_wclass(obj/item/bodypart/BP)
		switch (BP.name)
			if ("head")
				return 1
			if ("chest")
				return 3
			if ("groin")
				return 2
		return 0

	proc/get_cavity(obj/item/bodypart/BP)
		switch (BP.name)
			if ("head")
				return "cranial"
			if ("chest")
				return "thoracic"
			if ("groin")
				return "abdominal"
		return ""

/datum/surgery_step/cavity/make_space
	allowed_tools = list(
	/obj/item/weapon/surgicaldrill = 100,	\
	/obj/item/weapon/pen = 75
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
			return !BP.cavity && !BP.hidden

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts making some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].", \
		"You start making some space inside [target]'s [get_cavity(BP)] cavity with \the [tool]." )
		target.custom_pain("The pain in your chest is living hell!",1)
		BP.cavity = 1
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/chest/BP = target.get_bodypart(target_zone)
		user.visible_message("\blue [user] makes some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].", \
		"\blue You make some space inside [target]'s [get_cavity(BP)] cavity with \the [tool]." )

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/chest/BP = target.get_bodypart(target_zone)
		user.visible_message("\red [user]'s hand slips, scraping tissue inside [target]'s [BP.display_name] with \the [tool]!", \
		"\red Your hand slips, scraping tissue inside [target]'s [BP.display_name] with \the [tool]!")
		BP.createwound(CUT, 20)

/datum/surgery_step/cavity/close_space
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
			return BP.cavity

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts mending [target]'s [get_cavity(BP)] cavity wall with \the [tool].", \
		"You start mending [target]'s [get_cavity(BP)] cavity wall with \the [tool]." )
		target.custom_pain("The pain in your chest is living hell!",1)
		BP.cavity = 0
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/chest/BP = target.get_bodypart(target_zone)
		user.visible_message("\blue [user] mends [target]'s [get_cavity(BP)] cavity walls with \the [tool].", \
		"\blue You mend [target]'s [get_cavity(BP)] cavity walls with \the [tool]." )

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/chest/BP = target.get_bodypart(target_zone)
		user.visible_message("\red [user]'s hand slips, scraping tissue inside [target]'s [BP.display_name] with \the [tool]!", \
		"\red Your hand slips, scraping tissue inside [target]'s [BP.display_name] with \the [tool]!")
		BP.createwound(CUT, 20)

/datum/surgery_step/cavity/place_item
	priority = 0
	allowed_tools = list(/obj/item = 100)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
			return !BP.hidden && BP.cavity && tool.w_class <= get_max_wclass(BP)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(BP)] cavity.", \
		"You start putting \the [tool] inside [target]'s [get_cavity(BP)] cavity." )
		target.custom_pain("The pain in your chest is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/chest/BP = target.get_bodypart(target_zone)

		user.visible_message("\blue [user] puts \the [tool] inside [target]'s [get_cavity(BP)] cavity.", \
		"\blue You put \the [tool] inside [target]'s [get_cavity(BP)] cavity." )
		if (tool.w_class > get_max_wclass(BP)/2 && prob(50))
			to_chat(user, "\red You tear some blood vessels trying to fit such a big object in this cavity.")
			var/datum/wound/internal_bleeding/I = new (15)
			BP.wounds += I
			BP.owner.custom_pain("You feel something rip in your [BP.display_name]!", 1)
		if(istype(tool, /obj/item/gland))	//Abductor surgery integration
			if(target_zone != "chest")
				return
			else
				var/obj/item/gland/gland = tool
				user.drop_item()
				gland.Inject(target)
				BP.cavity = 0
				return
		user.drop_item()
		BP.hidden = tool
		tool.loc = target
		BP.cavity = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/chest/BP = target.get_bodypart(target_zone)
		user.visible_message("\red [user]'s hand slips, scraping tissue inside [target]'s [BP.display_name] with \the [tool]!", \
		"\red Your hand slips, scraping tissue inside [target]'s [BP.display_name] with \the [tool]!")
		BP.createwound(CUT, 20)

//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity/implant_removal
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
			return ((BP.open == 3 && BP.name == "chest") || (BP.open == 2))

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts poking around inside the incision on [target]'s [BP.display_name] with \the [tool].", \
		"You start poking around inside the incision on [target]'s [BP.display_name] with \the [tool]" )
		target.custom_pain("The pain in your chest is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/chest/BP = target.get_bodypart(target_zone)

		var/find_prob = 0

		if (BP.implants.len)

			var/obj/item/obj = BP.implants[1]

			if(istype(obj,/obj/item/weapon/implant))
				var/obj/item/weapon/implant/imp = obj
				if (imp.islegal())
					find_prob +=60
				else
					find_prob +=40
			else
				find_prob +=50

			if (prob(find_prob))
				user.visible_message("\blue [user] takes something out of incision on [target]'s [BP.display_name] with \the [tool].", \
				"\blue You take [obj] out of incision on [target]'s [BP.display_name]s with \the [tool]." )
				BP.implants -= obj

				target.hud_updateflag |= 1 << IMPLOYAL_HUD

				//Handle possessive brain borers.
				if(istype(obj,/mob/living/simple_animal/borer))
					var/mob/living/simple_animal/borer/worm = obj
					if(worm.controlling)
						target.release_control()
					worm.detatch()

				if(obj)
					obj.loc = get_turf(target)

					if(istype(obj,/obj/item/weapon/implant))
						var/obj/item/weapon/implant/imp = obj
						imp.imp_in = null
						imp.implanted = 0
						if(istype(imp,/obj/item/weapon/implant/storage))
							var/obj/item/weapon/implant/storage/Simp = imp
							Simp.removed()
			else
				user.visible_message("\blue [user] removes \the [tool] from [target]'s [BP.display_name].", \
				"\blue There's something inside [target]'s [BP.display_name], but you just missed it this time." )
		else if (BP.hidden)
			user.visible_message("\blue [user] takes something out of incision on [target]'s [BP.display_name] with \the [tool].", \
			"\blue You take something out of incision on [target]'s [BP.display_name]s with \the [tool]." )
			BP.hidden.loc = get_turf(target)
			if(!BP.hidden.blood_DNA)
				BP.hidden.blood_DNA = list()
			BP.hidden.blood_DNA[target.dna.unique_enzymes] = target.dna.b_type
			BP.hidden.update_icon()
			BP.hidden = null

		else
			user.visible_message("\blue [user] could not find anything inside [target]'s [BP.display_name], and pulls \the [tool] out.", \
			"\blue You could not find anything inside [target]'s [BP.display_name]." )

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/bodypart/chest/BP = target.get_bodypart(target_zone)
		user.visible_message("\red [user]'s hand slips, scraping tissue inside [target]'s [BP.display_name] with \the [tool]!", \
		"\red Your hand slips, scraping tissue inside [target]'s [BP.display_name] with \the [tool]!")
		BP.createwound(CUT, 20)
		if (BP.implants.len)
			var/fail_prob = 10
			fail_prob += 100 - tool_quality(tool)
			if (prob(fail_prob))
				var/obj/item/weapon/implant/imp = BP.implants[1]
				user.visible_message("\red Something beeps inside [target]'s [BP.display_name]!")
				playsound(imp.loc, 'sound/items/countdown.ogg', 75, 1, -3)
				spawn(25)
					imp.activate()

