/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	//icon = 'icons/mob/human.dmi'
	//icon_state = "body_m_s"
	var/dog_owner

	var/scientist = 0	//Vars used in abductors checks and etc. Should be here because in species datums it changes globaly.
	var/agent = 0
	var/team = 0
	var/metadata

	throw_range = 2

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/skrell/New()
	h_style = "Skrell Male Tentacles"
	..(new_species = S_SKRELL)

/mob/living/carbon/human/tajaran/New()
	h_style = "Tajaran Ears"
	..(new_species = S_TAJARAN)

/mob/living/carbon/human/unathi/New()
	h_style = "Unathi Horns"
	..(new_species = S_UNATHI)

/mob/living/carbon/human/vox/New()
	h_style = "Short Vox Quills"
	..(new_species = S_VOX)

/mob/living/carbon/human/voxarmalis/New()
	h_style = "Bald"
	..(new_species = S_VOX_ARMALIS)

/mob/living/carbon/human/diona/New()
	..(new_species = S_DIONA)

/mob/living/carbon/human/machine/New()
	h_style = "blue IPC screen"
	..(new_species = S_IPC)

/mob/living/carbon/human/abductor/New()
	..(new_species = S_ABDUCTOR)

/mob/living/carbon/human/New(loc, new_species = S_HUMAN, list/organ_data)
	//hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	//hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")
	//hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudunknown")
	//hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	//hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	//hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	//hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	//hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")
	//hud_list[STATUS_HUD_OOC]  = image('icons/mob/hud.dmi', src, "hudhealthy")

	..()

/mob/living/carbon/human/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")
		if(internal)
			if(!internal.air_contents)
				qdel(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)
		if(mind)
			if(mind.changeling)
				stat("Chemical Storage", "[mind.changeling.chem_charges]/[mind.changeling.chem_storage]")
				stat("Genetic Damage Time", mind.changeling.geneticdamage)
				stat("Absorbed DNA", mind.changeling.absorbedcount)
		if(istype(wear_suit, /obj/item/clothing/suit/space/space_ninja))
			var/obj/item/clothing/suit/space/space_ninja/SN = wear_suit
			stat("SpiderOS Status:","[SN.s_initialized ? "Initialized" : "Disabled"]")
			stat("Current Time:", "[worldtime2text()]")
			if(SN.s_initialized)
				//Suit gear
				stat("Energy Charge", "[round(SN.cell.charge/100)]%")
				stat("Smoke Bombs:", "\Roman [SN.s_bombs]")
				//Ninja status
				stat("Fingerprints:", "[md5(dna.uni_identity)]")
				stat("Unique Identity:", "[dna.unique_enzymes]")
				stat("Overall Status:", "[stat > 1 ? "dead" : "[health]% healthy"]")
				stat("Nutrition Status:", "[nutrition]")
				stat("Oxygen Loss:", "[getOxyLoss()]")
				stat("Toxin Levels:", "[getToxLoss()]")
				stat("Burn Severity:", "[getFireLoss()]")
				stat("Brute Trauma:", "[getBruteLoss()]")
				stat("Radiation Levels:","[radiation] rad")
				stat("Body Temperature:","[bodytemperature-T0C] degrees C ([bodytemperature*1.8-459.67] degrees F)")


/mob/living/carbon/human/ex_act(severity)
	if(!blinded)
		flash_eyes()

	var/shielded = 0
	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			if (!prob(getarmor(null, "bomb")))
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
			//return
//				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				//user.throw_at(target, 200, 4)

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

			if (!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 30
				ear_deaf += 120
			if (prob(70) && !shielded)
				Paralyse(10)

		if(3.0)
			b_loss += 30
			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/2
			if (!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 15
				ear_deaf += 60
			if (prob(50) && !shielded)
				Paralyse(10)

	// focus most of the blast on one bodypart
	var/obj/item/bodypart/BP = pick(bodyparts)
	BP.take_damage(b_loss * 0.9, f_loss * 0.9, used_weapon = "Explosive blast")

	// distribute the remaining 10% on all limbs equally
	b_loss *= 0.1
	f_loss *= 0.1

	var/weapon_message = "Explosive Blast"
	take_overall_damage(b_loss * 0.2, f_loss * 0.2, used_weapon = weapon_message)

/mob/living/carbon/human/singularity_act()
	var/gain = 20
	if(mind)
		switch(mind.assigned_role)
			if("Station Engineer","Chief Engineer")
				gain = 100
			if("Clown")
				gain = rand(-300, 300)//HONK
	investigate_log(" has consumed [key_name(src)].","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/carbon/human/singularity_pull(S, current_size)
	if(current_size >= STAGE_THREE)
		var/list/handlist = list(l_hand, r_hand)
		for(var/obj/item/hand in handlist)
			if(prob(current_size * 5) && hand.w_class >= ((STAGE_FIVE-current_size)/2)  && dropItemToGround(hand))
				step_towards(hand, src)
				to_chat(src, "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>")
	apply_effect(current_size * 3, IRRADIATE)
	if(mob_negates_gravity())//Magboots protection
		return
	..()

/mob/living/carbon/human/blob_act()
	if(stat == DEAD)	return
	to_chat(src, "<span class='danger'>\The blob attacks you!</span>")
	var/dam_zone = pick(BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)
	var/obj/item/bodypart/BP = get_bodypart(ran_zone(dam_zone))
	apply_damage(rand(30,40), BRUTE, BP, run_armor_check(BP, "melee"))
	return

/mob/living/carbon/human/meteorhit(O)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message("\red [src] has been hit by [O]", 1)
	if (health > 0)
		var/obj/item/bodypart/BP = get_bodypart(pick(BP_CHEST, BP_CHEST, BP_CHEST, BP_HEAD))
		if(!BP)	return
		if (istype(O, /obj/effect/immovablerod))
			BP.take_damage(101, 0)
		else
			BP.take_damage((istype(O, /obj/effect/meteor/small) ? 10 : 25), 30)
		updatehealth()
	return


/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	..()
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/dam_zone = pick(BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)
		var/obj/item/bodypart/BP = get_bodypart(ran_zone(dam_zone))
		var/armor = run_armor_check(BP, "melee")
		apply_damage(damage, BRUTE, BP, armor)
		if(armor >= 2)	return


/mob/living/carbon/human/proc/is_loyalty_implanted(mob/living/carbon/human/M)
	for(var/L in M.contents)
		if(istype(L, /obj/item/weapon/implant/loyalty))
			for(var/obj/item/bodypart/BP in M.bodyparts)
				if(L in BP.implants)
					return 1
	return 0

/mob/living/carbon/human/attack_slime(mob/living/carbon/slime/M)
	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>The [M.name] glomps []!</B>", src), 1)

		var/damage = rand(1, 3)

		if(istype(M, /mob/living/carbon/slime/adult))
			damage = rand(10, 35)
		else
			damage = rand(5, 25)


		var/dam_zone = pick(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_GROIN)

		var/obj/item/bodypart/BP = get_bodypart(ran_zone(dam_zone))
		var/armor_block = run_armor_check(BP, "melee")
		apply_damage(damage, BRUTE, BP, armor_block)


		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>The [M.name] has shocked []!</B>", src), 1)

				Weaken(power)
				if (stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))


		updatehealth()

	return


/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	if (istype(buckled, /obj/structure/stool/bed/nest))
		return 1
	return 0


/mob/living/carbon/human/show_inv(mob/user)
	return ..()

	var/obj/item/clothing/under/suit = null
	if (istype(w_uniform, /obj/item/clothing/under))
		suit = w_uniform

	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask && !(wear_mask.flags&ABSTRACT)) ? wear_mask : "Nothing"]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? l_hand : "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? r_hand : "Nothing"]</A>
	<BR><B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>[(gloves && !(gloves.flags&ABSTRACT)) ? gloves : "Nothing"]</A>
	<BR><B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>[(glasses && !(glasses.flags&ABSTRACT))	? glasses : "Nothing"]</A>
	<BR><B>Left Ear:</B> <A href='?src=\ref[src];item=l_ear'>[(l_ear && !(l_ear.flags&ABSTRACT) ? l_ear : "Nothing")]</A>
	<BR><B>Right Ear:</B> <A href='?src=\ref[src];item=r_ear'>[(r_ear && !(r_ear.flags&ABSTRACT)  ? r_ear : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(head && !(head.flags&ABSTRACT)) ? head : "Nothing"]</A>
	<BR><B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>[(shoes && !(shoes.flags&ABSTRACT)) ? shoes : "Nothing"]</A>
	<BR><B>Belt:</B> <A href='?src=\ref[src];item=belt'>[(belt ? belt : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(belt, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR><B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>[(w_uniform && !(w_uniform.flags&ABSTRACT)) ? w_uniform : "Nothing"]</A> [(suit) ? ((suit.has_sensor == 1) ? text(" <A href='?src=\ref[];item=sensor'>Sensors</A>", src) : "") :]
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(wear_suit && !(wear_suit.flags&ABSTRACT)) ? wear_suit : "Nothing"]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back && !(back.flags&ABSTRACT)) ? back : "Nothing"]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR><B>ID:</B> <A href='?src=\ref[src];item=id'>[(wear_id ? wear_id : "Nothing")]</A>
	<BR><B>Suit Storage:</B> <A href='?src=\ref[src];item=s_store'>[(s_store ? s_store : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(s_store, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR>[(handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(legcuffed ? text("<A href='?src=\ref[src];item=legcuff'>Legcuffed</A>") : text(""))]
	<BR>[(suit) ? ((suit.hastie) ? text(" <A href='?src=\ref[];item=tie'>Remove Accessory</A>", src) : "") :]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=bandages'>Remove Bandages</A>
	<BR><A href='?src=\ref[src];item=splints'>Remove Splints</A>
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x540"))
	onclose(user, "mob[name]")
	return

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null, tesla_shock = 0)
	if(status_flags & GODMODE)	return 0	//godmode
	if(NO_SHOCK in src.mutations)	return 0 //#Z2 no shock with that mutation.

	if(!def_zone)
		def_zone = pick(BP_L_ARM, BP_R_ARM)

	var/obj/item/bodypart/BP = get_bodypart(check_zone(def_zone))

	if(tesla_shock)
		var/total_coeff = 1
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			if(G.siemens_coefficient <= 0)
				total_coeff -= 0.5
		if(wear_suit)
			var/obj/item/clothing/suit/S = wear_suit
			if(S.siemens_coefficient <= 0)
				total_coeff -= 0.95
		siemens_coeff = total_coeff
	else
		siemens_coeff *= get_siemens_coefficient_bodypart(BP)

	. = ..(shock_damage, source, siemens_coeff, def_zone, tesla_shock)
	if(.)
		electrocution_animation(40)

/mob/living/carbon/human/Topic(href, href_list)
	if (href_list["refresh"])
		if(machine && in_range(src, usr))
			show_inv(machine)

	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)

	if ((href_list["item"] && !( usr.stat ) && usr.canmove && !( usr.restrained() ) && in_range(src, usr) && ticker)) //if game hasn't started, can't make an equip_e
		var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human(  )
		O.source = usr
		O.target = src
		O.item = usr.get_active_hand()
		O.s_loc = usr.loc
		O.t_loc = loc
		O.place = href_list["item"]
		requests += O
		spawn( 0 )
			O.process()
			return

	if (href_list["criminal"])
		if(hasHUD(usr,"security"))

			var/modified = 0
			var/perpname = "wot"
			if(wear_id)
				var/obj/item/weapon/card/id/I = wear_id.GetID()
				if(I)
					perpname = I.registered_name
				else
					perpname = name
			else
				perpname = name

			if(perpname)
				for (var/datum/data/record/E in data_core.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in data_core.security)
							if (R.fields["id"] == E.fields["id"])

								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Released", "Cancel")

								if(hasHUD(usr, "security"))
									if(setcriminal != "Cancel")
										R.fields["criminal"] = setcriminal
										modified = 1

										spawn()
											hud_updateflag |= 1 << WANTED_HUD
											if(istype(usr,/mob/living/carbon/human))
												var/mob/living/carbon/human/U = usr
												U.handle_regular_hud_updates()
											if(istype(usr,/mob/living/silicon/robot))
												var/mob/living/silicon/robot/U = usr
												U.handle_regular_hud_updates()

			if(!modified)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["secrecord"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
								to_chat(usr, "<b>Minor Crimes:</b> [R.fields["mi_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_crim_d"]]")
								to_chat(usr, "<b>Major Crimes:</b> [R.fields["ma_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_crim_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=\ref[src];secrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["secrecordComment"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, text("[]", R.fields[text("com_[]", counter)]))
									counter++
								if (counter == 1)
									to_chat(usr, "No comment found")
								to_chat(usr, "<a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["secrecordadd"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								var/t1 = sanitize(copytext(input("Add Comment:", "Sec. records", null, null)  as message,1,MAX_MESSAGE_LEN))
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"security")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [worldtime2text()], [time2text(world.realtime, "DD/MM")]/[game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [worldtime2text()], [time2text(world.realtime, "DD/MM")]/[game_year]<BR>[t1]")

	if (href_list["medical"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/modified = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name

			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.general)
						if (R.fields["id"] == E.fields["id"])

							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")

							if(hasHUD(usr,"medical"))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1
									if(PDA_Manifest.len)
										PDA_Manifest.Cut()

									spawn()
										if(istype(usr,/mob/living/carbon/human))
											var/mob/living/carbon/human/U = usr
											U.handle_regular_hud_updates()
										if(istype(usr,/mob/living/silicon/robot))
											var/mob/living/silicon/robot/U = usr
											U.handle_regular_hud_updates()

			if(!modified)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["medrecord"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Blood Type:</b> [R.fields["b_type"]]")
								to_chat(usr, "<b>DNA:</b> [R.fields["b_dna"]]")
								to_chat(usr, "<b>Minor Disabilities:</b> [R.fields["mi_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_dis_d"]]")
								to_chat(usr, "<b>Major Disabilities:</b> [R.fields["ma_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_dis_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=\ref[src];medrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["medrecordComment"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, text("[]", R.fields[text("com_[]", counter)]))
									counter++
								if (counter == 1)
									to_chat(usr, "No comment found")
								to_chat(usr, "<a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["medrecordadd"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								var/t1 = sanitize(copytext(input("Add Comment:", "Med. records", null, null)  as message,1,MAX_MESSAGE_LEN))
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"medical")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [worldtime2text()], [time2text(world.realtime, "DD/MM")]/[game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [worldtime2text()], [time2text(world.realtime, "DD/MM")]/[game_year]<BR>[t1]")

	if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		usr.examinate(I)

	if (href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		usr.examinate(M)
	..()
	return


///eyecheck()
///Returns a number between -1 to 2
/mob/living/carbon/human/eyecheck()
	var/number = 0
	if(istype(src.head, /obj/item/clothing/head/welding))
		if(!src.head:up)
			number += 2
	if(istype(src.head, /obj/item/clothing/head/helmet/space))
		number += 2
	if(istype(src.glasses, /obj/item/clothing/glasses/thermal))
		number -= 1
	if(istype(src.glasses, /obj/item/clothing/glasses/sunglasses))
		number += 1
	if(istype(src.wear_mask, /obj/item/clothing/mask/gas/welding))
		var/obj/item/clothing/mask/gas/welding/W = src.wear_mask
		if(!W.up)
			number += 2
	if(istype(src.glasses, /obj/item/clothing/glasses/welding))
		var/obj/item/clothing/glasses/welding/W = src.glasses
		if(!W.up)
			number += 2
	if(istype(src.glasses, /obj/item/clothing/glasses/night/shadowling))
		number -= 1
	return number

//Used by various things that knock people out by applying blunt trauma to the head.
//Checks that the species has a "head" (brain containing organ) and that hit_zone refers to it.
/mob/living/carbon/human/proc/headcheck(target_zone, brain_tag = BP_BRAIN)

	var/obj/item/organ/IO = organs_by_name[brain_tag]

	target_zone = check_zone(target_zone)
	if(!IO || IO.parent_bodypart != target_zone)
		return 0

	//if the parent bodypart is significantly larger than the brain organ, then hitting it is not guaranteed
	var/obj/item/bodypart/BP = get_bodypart(target_zone)
	if(!BP)
		return 0

	if(BP.w_class > IO.w_class + 1)
		return prob(100 / 2**(BP.w_class - IO.w_class - 1))

	return 1

/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves)))
		return 1

	if( (src.l_hand && !src.l_hand.abstract) || (src.r_hand && !src.r_hand.abstract) )
		return 1

	return 0


/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("\red [src] begins playing his ribcage like a xylophone. It's quite spooky.","\blue You begin to play a spooky refrain on your ribcage.","\red You hear a spooky xylophone melody.")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/proc/morph()
	set name = "Morph"
	set category = "Superpower"

	if(stat!=CONSCIOUS)
		reset_view(0)
		remoteview_target = null
		return

	if(!(MORPH in mutations))
		src.verbs -= /mob/living/carbon/human/proc/morph
		return

	var/new_facial = input("Please select facial hair color.", "Character Generation",rgb(r_facial,g_facial,b_facial)) as color
	if(new_facial)
		r_facial = hex2num(copytext(new_facial, 2, 4))
		g_facial = hex2num(copytext(new_facial, 4, 6))
		b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation",rgb(r_hair,g_hair,b_hair)) as color
	if(new_facial)
		r_hair = hex2num(copytext(new_hair, 2, 4))
		g_hair = hex2num(copytext(new_hair, 4, 6))
		b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation",rgb(r_eyes,g_eyes,b_eyes)) as color
	if(new_eyes)
		r_eyes = hex2num(copytext(new_eyes, 2, 4))
		g_eyes = hex2num(copytext(new_eyes, 4, 6))
		b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation", "[35-s_tone]")  as text

	if (!new_tone)
		new_tone = 35
	s_tone = max(min(round(text2num(new_tone)), 220), 1)
	s_tone =  -s_tone + 35

	// hair
	var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		qdel(H) // delete the hair after it's all done

	var/new_style = input("Please select hair style", "Character Generation",h_style)  as null|anything in hairs

	// if new style selected (not cancel)
	if (new_style)
		h_style = new_style

	// facial hair
	var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	var/list/fhairs = list()

	for(var/x in all_fhairs)
		var/datum/sprite_accessory/facial_hair/H = new x
		fhairs.Add(H.name)
		qdel(H)

	new_style = input("Please select facial style", "Character Generation",f_style)  as null|anything in fhairs

	if(new_style)
		f_style = new_style

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			gender = MALE
		else
			gender = FEMALE
	regenerate_icons()
	check_dna()

	visible_message("\blue \The [src] morphs and changes [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] appearance!", "\blue You change your appearance!", "\red Oh, god!  What the hell was that?  It sounded like flesh getting squished and bone ground into a different shape!")

/mob/living/carbon/human/proc/remotesay() //#Z2
	set name = "Project mind"
	set category = "Superpower"

	if(stat!=CONSCIOUS)
		reset_view(0)
		remoteview_target = null
		return

	if(!(REMOTE_TALK in src.mutations))
		src.verbs -= /mob/living/carbon/human/proc/remotesay
		return

	var/list/names = list()
	var/list/creatures = list()
	var/list/namecounts = list()

	for(var/mob/living/carbon/M in world)
		var/name = M.real_name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		var/turf/temp_turf = get_turf(M)
		if(temp_turf.z != src.z)
			continue
		creatures[name] += M

	var/mob/target = input ("Who do you want to project your mind to ?") as null|anything in creatures
	if (isnull(target))
		return

	var/say = input ("What do you wish to say")
	if(!say)
		return
	else
		say = sanitize(say)
	var/mob/T = creatures[target]
	if(REMOTE_TALK in T.mutations)
		T.show_message("\blue You hear [src.real_name]'s voice: [say]")
	else
		T.show_message("\blue You hear a voice that seems to echo around the room: [say]")
	usr.show_message("\blue You project your mind into [T.real_name]: [say]")
	for(var/mob/dead/observer/G in world)
		G.show_message("<i>Telepathic message from <b>[src]</b> to <b>[T]</b>: [say]</i>")
	log_say("Telepathic message from [key_name(src)] to [key_name(T)]: [say]")

/mob/living/carbon/human/proc/remoteobserve()
	set name = "Remote View"
	set category = "Superpower"

	if(stat!=CONSCIOUS)
		remoteview_target = null
		reset_view(0)
		return

	if(!(REMOTE_VIEW in src.mutations))
		remoteview_target = null
		reset_view(0)
		src.verbs -= /mob/living/carbon/human/proc/remoteobserve
		return

	if(client.eye != client.mob)
		remoteview_target = null
		reset_view(0)
		return

	if(src.getBrainLoss() >= 100) //#Z2
		to_chat(src, "Too hard to concentrate... Better stop trying!")
		src.adjustBrainLoss(7)
		if(src.getBrainLoss() >= 125) return

	var/list/names = list()
	var/list/creatures = list()
	var/list/namecounts = list()
	var/target = null	   //Chosen target.

	for(var/mob/living/carbon/human/M in world) //#Z2 only carbon/human for now
		var/name = M.real_name
		if(!(REMOTE_TALK in src.mutations))
			namecounts++
			name = "([namecounts])"
		else
			if(name in names)
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
		var/turf/temp_turf = get_turf(M)
		if((temp_turf.z != ZLEVEL_STATION && temp_turf.z != ZLEVEL_ASTEROID || temp_turf.z != src.z) || M.stat!=CONSCIOUS) //Not on mining or the station. Or dead #Z2 + target on the same Z level as player
			continue
		creatures[name] += M

	target = input ("Who do you want to project your mind to ?") as null|anything in creatures

	if (!target)//Make sure we actually have a target
		return
	if(src.getBrainLoss() >= 100)
		to_chat(src, "Too hard to concentrate...")
		return
	if (target && (creatures[target] != src))
		src.adjustBrainLoss(4)
		remoteview_target = creatures[target]
		reset_view(creatures[target])
	else
		remoteview_target = null
		reset_view(0) //##Z2

/mob/living/carbon/human/revive() // TODO check if this proc requires any updates with new bodyparts system.

	var/obj/item/bodypart/check_head = bodyparts_by_name[BP_HEAD]
	if(check_head && check_head.is_stump())
		for (var/obj/item/bodypart/BP in world) // in world... TODO deal with that.
			var/obj/item/organ/brain/BRAIN = BP.organs_by_name[BP_BRAIN]
			if(BRAIN.brainmob && BRAIN.brainmob.real_name == src.real_name)
				BP.replace_stump(src)
				if(istype(BP, /obj/item/bodypart/head))
					var/obj/item/bodypart/head/head = BP
					head.disfigured = FALSE

	for (var/obj/item/bodypart/BP in bodyparts)
		BP.status &= ~ORGAN_BROKEN
		BP.status &= ~ORGAN_BLEEDING
		BP.status &= ~ORGAN_SPLINTED
		BP.status &= ~ORGAN_CUT_AWAY
		//BP.status &= ~ORGAN_ATTACHABLE
		BP.wounds.Cut()
		BP.heal_damage(1000,1000,1,1)

	if(species && !species.flags[NO_BLOOD])
		vessel.add_reagent("blood", species.blood_volume - vessel.total_volume)
		fixblood()

	for(var/obj/item/organ/IO in organs)
		IO.damage = 0

	for (var/datum/disease/virus in viruses)
		virus.cure()
	for (var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		V.cure(src)

	..()

/*
/mob/living/carbon/human/verb/simulate()
	set name = "sim"
	//set background = 1

	var/damage = input("Wound damage","Wound damage") as num

	var/germs = 0
	var/tdamage = 0
	var/ticks = 0
	while (germs < 2501 && ticks < 100000 && round(damage/10)*20)
		log_misc("VIRUS TESTING: [ticks] : germs [germs] tdamage [tdamage] prob [round(damage/10)*20]")
		ticks++
		if (prob(round(damage/10)*20))
			germs++
		if (germs == 100)
			to_chat(world, "Reached stage 1 in [ticks] ticks")
		if (germs > 100)
			if (prob(10))
				damage++
				germs++
		if (germs == 1000)
			to_chat(world, "Reached stage 2 in [ticks] ticks")
		if (germs > 1000)
			damage++
			germs++
		if (germs == 2500)
			to_chat(world, "Reached stage 3 in [ticks] ticks")
	to_chat(world, "Mob took [tdamage] tox damage")
*/
//returns 1 if made bloody, returns 0 otherwise

/mob/living/carbon/human/add_blood(mob/living/carbon/human/M)
	if (!..())
		return 0
	//if this blood isn't already in the list, add it
	if(blood_DNA[M.dna.unique_enzymes])
		return 0 //already bloodied with this blood. Cannot add more.

	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	hand_blood_color = blood_color

	verbs += /mob/living/carbon/human/proc/bloody_doodle
	return 1 //we applied blood to the item

/mob/living/carbon/human/clean_blood(var/clean_feet) // TODO deal with blood on limbs
	. = ..()

	var/obj/item/I = get_equipped_item(slot_shoes)
	if(clean_feet && !I && istype(feet_blood_DNA, /list) && feet_blood_DNA.len)
		feet_blood_color = null
		feet_blood_DNA = null
		return 1

/mob/living/carbon/human/verb/pull_punches()
	set name = "Pull Punches"
	set desc = "Try not to hurt them."
	set category = "IC"

	if(stat)
		return
	pulling_punches = !pulling_punches
	to_chat(src, "<span class='notice'>You are now [pulling_punches ? "pulling your punches" : "not pulling your punches"].</span>")

/mob/living/carbon/human/verb/check_pulse()
	set category = "Object"
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.stat || usr.restrained() || !isliving(usr)) return

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message("<span class='notice'>[usr] kneels down, puts \his hand on [src]'s wrist and begins counting their pulse.</span>",\
		"You begin counting [src]'s pulse")
	else
		usr.visible_message("<span class='notice'>[usr] begins counting their pulse.</span>",\
		"You begin counting your pulse.")

	if(pulse())
		to_chat(usr, "<span class='notice'>[self ? "You have a" : "[src] has a"] pulse! Counting...</span>")
	else
		to_chat(usr, "<span class='danger'>[src] has no pulse!</span>")//it is REALLY UNLIKELY that a dead person would check his own pulse
		return

	to_chat(usr, "You must[self ? "" : " both"] remain still until counting is finished.")
	if(do_mob(usr, src, 60))
		var/message = "<span class='notice'>[self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].</span>"
		to_chat(usr, message)
	else
		to_chat(usr, "<span class='warning'>You failed to check the pulse. Try again.</span>")

/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if (src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	if (!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if (src.gloves)
		to_chat(src, "<span class='warning'>Your [src.gloves] are getting in the way.</span>")
		return

	var/turf/simulated/T = src.loc
	if (!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, "<span class='warning'>You cannot reach the floor.</span>")
		return

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	if (direction != "Here")
		T = get_step(T,text2dir(direction))
	if (!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = sanitize(copytext(stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", ""), 1, MAX_MESSAGE_LEN))

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.basecolor = (hand_blood_color) ? hand_blood_color : "#A10808"
		W.update_icon()
		W.message = message
		W.add_fingerprint(src)

/mob/living/carbon/human/verb/examine_ooc()
	set name = "Examine OOC"
	set category = "OOC"
	set src in oview()

	if(!usr || !src)	return

	to_chat(usr, "<font color='purple'>OOC-info: [src]</font>")
	if(metadata)
		to_chat(usr, "<font color='purple'>[metadata]</font>")
	else
		to_chat(usr, "<font color='purple'>Nothing of interest...</font>")

/mob/living/carbon/try_inject(mob/living/user, error_msg, instant, stealth)
	if(istype(user))
		if(user.is_busy())
			return

		if(!user.IsAdvancedToolUser())
			if(error_msg)
				to_chat(user, "<span class='warning'>You have no idea, how to use this!</span>")
			return FALSE

		if(isSynthetic(user.zone_sel.selecting))
			if(error_msg)
				to_chat(user, "<span class='warning'>You are trying to inject [src]'s synthetic body part!</span>")
			return FALSE

		if (HULK in user.mutations) // TODO - meaty fingers or something like that.
			if(error_msg)
				to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return FALSE


		var/hunt_injection_port = FALSE

		switch(check_thickmaterial(target_zone = user.zone_sel.selecting))
			if(NOLIMB)
				if(error_msg)
					to_chat(user, "<span class='warning'>[src] has no such body part, try to inject somewhere else.</span>")
				return FALSE
			if(THICKMATERIAL)
				if(error_msg)
					to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [user.zone_sel.selecting == BP_HEAD ? "on their head" : "on their body"] to inject into.</span>")
				return FALSE
			if(PHORONGUARD)
				if(user.a_intent == I_HURT)
					if(error_msg)
						to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [user.zone_sel.selecting == BP_HEAD ? "on their head" : "on their body"] to inject into.</span>")
					return FALSE
				hunt_injection_port = TRUE

		if(!instant)
			var/time_to_inject = HUMAN_STRIP_DELAY
			if(hunt_injection_port) // takes additional time
				if(!stealth)
					user.visible_message("<span class='danger'>[user] begins hunting for an injection port on [src]'s suit!</span>")
				if(!do_mob(user, src, time_to_inject / 2, TRUE))
					return FALSE

			if(!stealth)
				user.visible_message("<span class='danger'>[user] is trying to inject [src]!</span>")

			if(!do_mob(user, src, time_to_inject, TRUE))
				return FALSE

		if(!stealth)
			if(user != src)
				user.visible_message("<span class='warning'>[user] injects [src] with the syringe!</span>")
		else
			to_chat(user, "<span class'notice'>You inject [src] with the injector.</span>")
			to_chat(src, "<span class='warning'>You feel a tiny prick!</span>")

	else
		switch(check_thickmaterial(target_zone = BP_CHEST))
			if(NOLIMB)
				return FALSE
			if(THICKMATERIAL, PHORONGUARD)
				return FALSE

	return TRUE

/mob/living/carbon/human/proc/undislocate()
	set category = "Object"
	set name = "Undislocate Joint"
	set desc = "Pop a joint back into place. Extremely painful."
	set src in view(1)

	if(!isliving(usr) || !usr.canClick())
		return

	usr.setClickCooldown(20)

	if(usr.stat != CONSCIOUS)
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/self = null
	if(S == U)
		self = 1 // Removing object from yourself.

	var/list/limbs = list()
	for(var/limb in bodyparts_by_name)
		var/obj/item/bodypart/current_limb = bodyparts_by_name[limb]
		if(current_limb && current_limb.dislocated > 0 && !current_limb.is_parent_dislocated()) //if the parent is also dislocated you will have to relocate that first
			limbs |= current_limb
	var/obj/item/bodypart/current_limb = input(usr,"Which joint do you wish to relocate?") as null|anything in limbs

	if(!current_limb)
		return

	if(self)
		to_chat(src, "<span class='warning'>You brace yourself to relocate your [current_limb.joint]...</span>")
	else
		to_chat(U, "<span class='warning'>You begin to relocate [S]'s [current_limb.joint]...</span>")
	if(!do_after(U, 30, src))
		return
	if(!current_limb || !S || !U)
		return

	if(self)
		to_chat(src, "<span class='danger'>You pop your [current_limb.joint] back in!</span>")
	else
		to_chat(U, "<span class='danger'>You pop [S]'s [current_limb.joint] back in!</span>")
		to_chat(S, "<span class='danger'>[U] pops your [current_limb.joint] back in!</span>")
	current_limb.undislocate()

/mob/living/proc/should_have_organ(organ_check)
	return FALSE

/mob/living/carbon/should_have_organ(organ_check)
	var/obj/item/bodypart/BP
	if(organ_check in list(BP_HEART, BP_LUNGS))
		BP = bodyparts_by_name[BP_CHEST]
	else if(organ_check in list(BP_LIVER, BP_KIDNEYS))
		BP = bodyparts_by_name[BP_GROIN]

	if(BP && (BP.status & ORGAN_ROBOT))
		return 0
	return (species && species.has_organ[organ_check])

/mob/living/carbon/proc/can_feel_pain(obj/item/bodypart/check_bodypart)
	if(isSynthetic())
		return FALSE
	if(check_bodypart)
		if(!istype(check_bodypart))
			return FALSE
		return check_bodypart.can_feel_pain()
	return !(species && species.flags[NO_PAIN])

//Putting a couple of procs here that I don't know where else to dump.
//Mostly going to be used for Vox and Vox Armalis, but other human mobs might like them (for adminbuse).

/mob/living/carbon/human/proc/leap()
	set category = "IC"
	set name = "Leap"
	set desc = "Leap at a target and grab them aggressively."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying)
		to_chat(src, "You cannot leap in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/M in view(6,src))
		if(!istype(M,/mob/living/silicon))
			choices += M
	choices -= src

	var/mob/living/T = input(src,"Who do you wish to leap at?") in null|choices

	if(!T || !src || src.stat) return

	if(get_dist(get_turf(T), get_turf(src)) > 6) return

	last_special = world.time + 100
	status_flags |= LEAPING

	src.visible_message("<span class='warning'><b>\The [src]</b> leaps at [T]!</span>")
	src.throw_at(get_step(get_turf(T),get_turf(src)), 5, 1, src, spin = FALSE, callback = CALLBACK(src, .end_leaping, T))
	playsound(src.loc, 'sound/voice/shriek1.ogg', 50, 1)


/mob/living/carbon/human/proc/end_leaping(mob/living/T)
	if(status_flags & LEAPING)
		status_flags &= ~LEAPING

	if(!src.Adjacent(T))
		to_chat(src, "<span class='warning'>You miss!</span>")
		return

	T.Weaken(5)

	var/use_hand = "left"
	if(l_hand)
		if(r_hand)
			to_chat(src, "<span class='warning'>You need to have one hand free to grab someone.</span>")
			return
		else
			use_hand = "right"

	visible_message("<span class='warning'><b>\The [src]</b> seizes [T] aggressively!</span>")

	var/obj/item/weapon/grab/G = new(src,T)
	if(use_hand == "left")
		l_hand = G
	else
		r_hand = G

	G.state = GRAB_AGGRESSIVE
	G.icon_state = "grabbed1"
	G.synch()

/mob/living/carbon/human/proc/gut()
	set category = "IC"
	set name = "Gut"
	set desc = "While grabbing someone aggressively, rip their guts out or tear them apart."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying)
		to_chat(src, "\red You cannot do that in your current state.")
		return

	var/obj/item/weapon/grab/G = locate() in src
	if(!G || !istype(G))
		to_chat(src, "\red You are not grabbing anyone.")
		return

	if(G.state < GRAB_AGGRESSIVE)
		to_chat(src, "\red You must have an aggressive grab to gut your prey!")
		return

	last_special = world.time + 50

	visible_message("<span class='warning'><b>\The [src]</b> rips viciously at \the [G.affecting]'s body with its claws!</span>")

	if(istype(G.affecting,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = G.affecting
		H.apply_damage(50,BRUTE)
		if(H.stat == DEAD)
			H.gib()
	else
		var/mob/living/M = G.affecting
		if(!istype(M)) return //wut
		M.apply_damage(50,BRUTE)
		if(M.stat == DEAD)
			M.gib()

/mob/living/carbon/human/has_eyes()
	if(organs_by_name[BP_EYES])
		var/obj/item/organ/eyes = organs_by_name[BP_EYES]
		if(eyes && istype(eyes))
			return 1
	return 0

//Turns a mob black, flashes a skeleton overlay
//Just like a cartoon!
/mob/living/carbon/human/proc/electrocution_animation(anim_duration)
	//TG...
	//Handle mutant parts if possible
	//if(species)
	//	species.handle_mutant_bodyparts(src,"black")
	//	species.handle_hair(src,"black")
	//	species.update_color(src,"black")
	//	overlays += "electrocuted_base"
	//	spawn(anim_duration)
	//		if(src)
	//			if(dna && dna.species)
	//				dna.species.handle_mutant_bodyparts(src)
	//				dna.species.handle_hair(src)
	//				dna.species.update_color(src)
	//			overlays -= "electrocuted_base"
	//else //or just do a generic animation
	var/list/viewing = list()
	for(var/mob/M in viewers(src))
		if(M.client)
			viewing += M.client
	flick_overlay(image(icon,src,"electrocuted_generic",MOB_LAYER+1), viewing, anim_duration)

//Get species or synthetic temp if the mob is a FBP. Used when a synthetic type human mob is exposed to a temp check.
//Essentially, used when a synthetic human mob should act diffferently than a normal type mob.
/mob/living/carbon/proc/getSpeciesOrSynthTemp(temptype)
	switch(temptype)
		if(COLD_LEVEL_1)
			return isSynthetic()? SYNTH_COLD_LEVEL_1 : species.cold_level_1
		if(COLD_LEVEL_2)
			return isSynthetic()? SYNTH_COLD_LEVEL_2 : species.cold_level_2
		if(COLD_LEVEL_3)
			return isSynthetic()? SYNTH_COLD_LEVEL_3 : species.cold_level_3
		if(HEAT_LEVEL_1)
			return isSynthetic()? SYNTH_HEAT_LEVEL_1 : species.heat_level_1
		if(HEAT_LEVEL_2)
			return isSynthetic()? SYNTH_HEAT_LEVEL_2 : species.heat_level_2
		if(HEAT_LEVEL_3)
			return isSynthetic()? SYNTH_HEAT_LEVEL_3 : species.heat_level_3
