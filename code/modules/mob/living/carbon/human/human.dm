/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/mob/human.dmi'
	//icon_state = "body_m_s"
	var/list/hud_list[9]
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/dog_owner
	var/heart_beat = 0
	var/embedded_flag	  //To check if we've need to roll for damage on movement while an item is imbedded in us.

	var/scientist = 0	//Vars used in abductors checks and etc. Should be here because in species datums it changes globaly.
	var/agent = 0
	var/team = 0
	var/metadata
	var/seer = 0 // used in cult datum /cult/seer

	throw_range = 2

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/dummy)

/mob/living/carbon/human/skrell/atom_init(mapload)
	h_style = "Skrell Male Tentacles"
	. = ..(mapload, SKRELL)

/mob/living/carbon/human/tajaran/atom_init(mapload)
	h_style = "Tajaran Ears"
	. = ..(mapload, TAJARAN)

/mob/living/carbon/human/unathi/atom_init(mapload)
	h_style = "Unathi Horns"
	. = ..(mapload, UNATHI)

/mob/living/carbon/human/vox/atom_init(mapload)
	h_style = "Short Vox Quills"
	. = ..(mapload, VOX)

/mob/living/carbon/human/voxarmalis/atom_init(mapload)
	h_style = "Bald"
	. = ..(mapload, VOX_ARMALIS)

/mob/living/carbon/human/diona/atom_init(mapload)
	. = ..(mapload, DIONA)

/mob/living/carbon/human/machine/atom_init(mapload)
	h_style = "blue IPC screen"
	. = ..(mapload, IPC)

/mob/living/carbon/human/abductor/atom_init(mapload)
	. = ..(mapload, ABDUCTOR)

/mob/living/carbon/human/golem/atom_init(mapload)
	. = ..(mapload, GOLEM)

/mob/living/carbon/human/shadowling/atom_init(mapload)
	. = ..(mapload, SHADOWLING)
	var/newNameId = pick(possibleShadowlingNames)
	possibleShadowlingNames.Remove(newNameId)
	real_name = newNameId
	name = real_name

	underwear = 0
	undershirt = 0
	faction = "faithless"
	dna.mutantrace = "shadowling"
	update_mutantrace()
	regenerate_icons()

	spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind
	spell_list += new /obj/effect/proc_holder/spell/targeted/enthrall
	spell_list += new /obj/effect/proc_holder/spell/targeted/glare
	spell_list += new /obj/effect/proc_holder/spell/aoe_turf/veil
	spell_list += new /obj/effect/proc_holder/spell/targeted/shadow_walk
	spell_list += new /obj/effect/proc_holder/spell/aoe_turf/flashfreeze
	spell_list += new /obj/effect/proc_holder/spell/targeted/collective_mind
	spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_regenarmor

/mob/living/carbon/human/slime/atom_init(mapload)
	. = ..(mapload, SLIME)

/mob/living/carbon/human/atom_init(mapload, new_species)

	dna = new

	if(!species)
		if(new_species)
			set_species(new_species, null, TRUE)
		else
			set_species()

	if(species) // Just to be sure.
		metabolism_factor = species.metabolism_mod
		butcher_results = species.butcher_drops

	dna.species = species.name

	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudunknown")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD_OOC]  = image('icons/mob/hud.dmi', src, "hudhealthy")

	. = ..()

	human_list += src

	if(dna)
		dna.real_name = real_name

	handcrafting = new()

	verbs += /mob/living/carbon/proc/crawl

	prev_gender = gender // Debug for plural genders
	make_blood()
	regenerate_icons()

/mob/living/carbon/human/Destroy()
	human_list -= src
	return ..()

/mob/living/carbon/human/OpenCraftingMenu()
	handcrafting.ui_interact(src)

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

		CHANGELING_STATPANEL_STATS(null)

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

	CHANGELING_STATPANEL_POWERS(null)

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

	// focus most of the blast on one organ
	var/obj/item/organ/external/BP = pick(bodyparts)
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
			if(prob(current_size * 5) && hand.w_class >= ((STAGE_FIVE-current_size)/2)  && unEquip(hand))
				step_towards(hand, src)
				to_chat(src, "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>")
	apply_effect(current_size * 3, IRRADIATE)
	if(mob_negates_gravity())//Magboots protection
		return
	..()

/mob/living/carbon/human/blob_act()
	if(stat == DEAD)	return
	to_chat(src, "<span class='danger'>\The blob attacks you!</span>")
	var/dam_zone = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_L_LEG , BP_R_LEG)
	var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(dam_zone)]
	apply_damage(rand(30, 40), BRUTE, BP, run_armor_check(BP, "melee"))
	return

/mob/living/carbon/human/meteorhit(O)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message("\red [src] has been hit by [O]", 1)
	if (health > 0)
		var/obj/item/organ/external/BP = bodyparts_by_name[pick(BP_CHEST , BP_CHEST , BP_CHEST , BP_HEAD)]
		if(!BP)
			return
		if (istype(O, /obj/effect/immovablerod))
			BP.take_damage(101, 0)
		else
			BP.take_damage((istype(O, /obj/effect/meteor/small) ? 10 : 25), 30)
		updatehealth()
	return


/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	if(..())
		return
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='userdanger'><B>[M]</B>[M.attacktext] [src]!</span>")
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/dam_zone = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_L_LEG , BP_R_LEG)
		var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(dam_zone)]
		var/armor = run_armor_check(BP, "melee")
		apply_damage(damage, BRUTE, BP, armor)
		if(armor >= 2)	return

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


		var/dam_zone = pick(BP_HEAD , BP_CHEST , BP_L_ARM , BP_R_ARM , BP_L_LEG , BP_R_LEG , BP_GROIN)

		var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(dam_zone)]
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

/mob/living/carbon/human/proc/can_use_two_hands(broken = TRUE) // Replace arms with hands in case of reverting Kurshan's PR.
	var/obj/item/organ/external/l_arm/BPL = bodyparts_by_name[BP_L_ARM]
	var/obj/item/organ/external/r_arm/BPR = bodyparts_by_name[BP_R_ARM]
	if(broken && (BPL.is_broken() || BPR.is_broken()))
		return FALSE
	if(!BPL.is_usable() || !BPR.is_usable())
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/wield(/obj/item/I, name, wieldsound = null)
	if(!can_use_two_hands())
		to_chat(src, "<span class='warning'>You need both of your hands to be intact to do this.</span>")
		return FALSE
	if(get_inactive_hand())
		to_chat(src, "<span class='warning'>You need your other hand to be empty to do this.</span>")
		return FALSE
	to_chat(src, "<span class='notice'>You grab the [name] with both hands.</span>")
	if(wieldsound)
		playsound(loc, wieldsound, 50, 1)

	if(hand)
		update_inv_l_hand()
	else
		update_inv_r_hand()

	var/obj/item/weapon/twohanded/offhand/O = new(src)
	O.name = "[name] - offhand"
	O.desc = "Your second grip on the [name]"
	put_in_inactive_hand(O)
	return TRUE

/mob/living/carbon/human/proc/is_type_organ(organ, o_type)
	var/obj/item/organ/O
	if(organ in organs_by_name)
		O = organs_by_name[organ]
	if(organ in bodyparts_by_name)
		O = bodyparts_by_name[organ]
	if(!O)
		return FALSE
	return istype(O, o_type)

/mob/living/carbon/human/proc/is_bruised_organ(organ)
	var/obj/item/organ/internal/IO = organs_by_name[organ]
	if(!IO)
		return TRUE
	if(IO.is_bruised())
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/find_damaged_bodypart()
	for(var/obj/item/organ/external/BP in bodyparts) // find a broken/destroyed limb
		if(BP.status & (ORGAN_DESTROYED | ORGAN_BROKEN | ORGAN_SPLINTED))
			if(BP.parent && (BP.parent.status & ORGAN_DESTROYED))
				continue
			else
				return BP
	return FALSE // In case we didn't find anything.

/mob/living/carbon/human/proc/regen_bodyparts(remove_blood_amount = 0, use_cost = FALSE)
	if(vessel && regenerating_bodypart) // start fixing broken/destroyed limb
		if(remove_blood_amount)
			for(var/datum/reagent/blood/B in vessel.reagent_list)
				B.volume -= remove_blood_amount
		var/regenerating_capacity_penalty = 0 // Used as time till organ regeneration.
		if(regenerating_bodypart.status & ORGAN_DESTROYED)
			regenerating_capacity_penalty = regenerating_bodypart.regen_bodypart_penalty
		else
			regenerating_capacity_penalty = regenerating_bodypart.regen_bodypart_penalty/2
		regenerating_organ_time++
		switch(regenerating_organ_time)
			if(1)
				visible_message("<span class='notice'>You see odd movement in [src]'s [regenerating_bodypart.name]...</span>","<span class='notice'> You [species && species.flags[NO_PAIN] ? "notice" : "feel"] strange vibration on tips of your [regenerating_bodypart.name]... </span>")
			if(10)
				visible_message("<span class='notice'>You hear sickening crunch In [src]'s [regenerating_bodypart.name]...</span>")
			if(20)
				visible_message("<span class='notice'>[src]'s [regenerating_bodypart.name] shortly bends...</span>")
			if(30)
				if(regenerating_capacity_penalty == regenerating_bodypart.regen_bodypart_penalty/2)
					visible_message("<span class='notice'>[src] stirs his [regenerating_bodypart.name]...</span>","<span class='userdanger'>You [species && species.flags[NO_PAIN] ? "notice" : "feel"] freedom in moving your [regenerating_bodypart.name]</span>")
				else
					visible_message("<span class='notice'>From [src]'s [regenerating_bodypart.parent.name] grows a small meaty sprout...</span>")
			if(50)
				visible_message("<span class='notice'>You see something resembling [regenerating_bodypart.name] at [src]'s [regenerating_bodypart.parent.name]...</span>")
			if(65)
				visible_message("<span class='userdanger'>A new [regenerating_bodypart.name] has grown from [src]'s [regenerating_bodypart.parent.name]!</span>","<span class='userdanger'>You [species && species.flags[NO_PAIN] ? "notice" : "feel"] your [regenerating_bodypart.name] again!</span>")
		if(prob(50))
			emote("scream",1,null,1)
		if(regenerating_organ_time >= regenerating_capacity_penalty) // recover organ
			regenerating_bodypart.rejuvenate()
			regenerating_organ_time = 0
			if(use_cost)
				nutrition -= regenerating_capacity_penalty
			regenerating_bodypart = null
			update_body()

/mob/living/carbon/human/restrained(check_type = ARMS)
	if ((check_type & ARMS) && handcuffed)
		return TRUE
	if ((check_type & LEGS) && legcuffed)
		return TRUE
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return TRUE
	if (istype(buckled, /obj/structure/stool/bed/nest))
		return TRUE
	return 0

/mob/living/carbon/human/resist()
	..()
	if(usr && !usr.incapacitated())
		var/mob/living/carbon/human/D = usr
		if(D.get_species() == DIONA)
			var/list/choices = list()
			for(var/mob/living/carbon/monkey/diona/V in contents)
				if(istype(V) && V.gestalt == src)
					choices += V
			var/mob/living/carbon/monkey/diona/V = input(D,"Who do wish you to expel from within?") in null|choices
			if(V)
				to_chat(D, "<span class='notice'>You wriggle [V] out of your insides.</span>")
				V.splitting(D)

/mob/living/carbon/human/show_inv(mob/user)
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
	<BR>[(suit) ? ((suit.accessories.len) ? text(" <A href='?src=\ref[];item=tie'>Remove Accessory</A>", src) : "") :]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=bandages'>Remove Bandages</A>
	<BR><A href='?src=\ref[src];item=splints'>Remove Splints</A>
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(entity_ja(dat), text("window=mob[name];size=340x540"))
	onclose(user, "mob[name]")
	return

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

// Get rank from ID, ID inside PDA, PDA, ID in wallet, etc.
/mob/living/carbon/human/proc/get_authentification_rank(if_no_id = "No id", if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	if (istype(pda))
		if (pda.id)
			return pda.id.rank
		else
			return pda.ownrank
	else
		var/obj/item/weapon/card/id/id = get_idcard()
		if(id)
			return id.rank ? id.rank : if_no_job
		else
			return if_no_id

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id && istype(pda.id, /obj/item/weapon/card/id))
			. = pda.id.assignment
		else
			. = pda.ownjob
	else if (istype(id))
		. = id.assignment
	else
		return if_no_id
	if (!.)
		. = if_no_job
	return

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id)
			. = pda.id.registered_name
		else
			. = pda.owner
	else if (istype(id))
		. = id.registered_name
	else
		return if_no_id
	return

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/proc/get_visible_name()
	if( wear_mask && (wear_mask.flags_inv&HIDEFACE) )	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if( head && (head.flags_inv&HIDEFACE) )
		return get_id_name("Unknown")		//Likewise for hats
	if(name_override)
		return name_override
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/obj/item/organ/external/head/BP = bodyparts_by_name[BP_HEAD]
	if( !BP || BP.disfigured || (BP.status & ORGAN_DESTROYED) || !real_name || (HUSK in mutations) )	//disfigured. use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(if_no_id = "Unknown")
	. = if_no_id
	if(istype(wear_id,/obj/item/device/pda))
		var/obj/item/device/pda/P = wear_id
		return P.owner
	if(wear_id)
		var/obj/item/weapon/card/id/I = wear_id.GetID()
		if(I)
			return I.registered_name
	return

//gets ID card object from special clothes slot or null.
/mob/living/carbon/human/proc/get_idcard()
	if(wear_id)
		return wear_id.GetID()

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null, tesla_shock = 0)
	if(status_flags & GODMODE)
		return 0	//godmode
	if(NO_SHOCK in src.mutations)
		return 0 //#Z2 no shock with that mutation.

	if(!def_zone)
		def_zone = pick(BP_L_ARM , BP_R_ARM)

	var/obj/item/organ/external/BP = get_bodypart(check_zone(def_zone))

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
		siemens_coeff *= get_siemens_coefficient_organ(BP)

	if(species)
		siemens_coeff *= species.siemens_coefficient

	. = ..(shock_damage, source, siemens_coeff, def_zone, tesla_shock)
	if(.)
		if(species && species.flags[IS_SYNTHETIC])
			nutrition += . // Electrocute act returns it's shock_damage value.
		if(species.flags[NO_PAIN]) // Because for all intents and purposes, if the mob feels no pain, he was not shocked.
			. = 0
		electrocution_animation(40)

/mob/living/carbon/human/Topic(href, href_list)
	if (href_list["refresh"])
		if((machine)&&(in_range(src, usr)))
			show_inv(machine)

	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)

	if ((href_list["item"] && !( usr.stat ) && usr.canmove && !( usr.restrained() ) && in_range(src, usr) && ticker)) //if game hasn't started, can't make an equip_e
		var/obj/item/item = usr.get_active_hand()
		if(item && (item.flags & (ABSTRACT | DROPDEL)))
			return
		var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human(  )
		O.source = usr
		O.target = src
		O.item = item
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

								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Paroled", "Released", "Cancel")

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
								var/t1 = sanitize(input("Add Comment:", "Sec. records", null, null)  as message)
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
								var/t1 = sanitize(input("Add Comment:", "Med. records", null, null)  as message)
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
	if(blinded)
		return 2
	var/number = 0
	if(istype(src.head, /obj/item/clothing/head/welding))
		if(!src.head:up)
			number += 2
	if(istype(src.head, /obj/item/clothing/head/helmet/space) && !istype(src.head, /obj/item/clothing/head/helmet/space/sk))
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


/mob/living/carbon/human/IsAdvancedToolUser()
	return 1//Humans can use guns and such


/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves)))
		return 1

	if( (src.l_hand && !src.l_hand.abstract) || (src.r_hand && !src.r_hand.abstract) )
		return 1

	return 0


/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)
	return

/mob/living/carbon/human/get_species()

	if(!species)
		set_species()

	if(dna && dna.mutantrace == "golem")
		return "Animated Construct"



	return species.name

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("\red [src] begins playing his ribcage like a xylophone. It's quite spooky.","\blue You begin to play a spooky refrain on your ribcage.","\red You hear a spooky xylophone melody.")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/proc/vomit()

	if(species.flags[IS_SYNTHETIC])
		return //Machines don't throw up.

	if(!lastpuke)
		lastpuke = 1
		to_chat(src, "<span class='warning'>You feel nauseous...</span>")
		spawn(150)	//15 seconds until second warning
			to_chat(src, "<span class='warning'>You feel like you are about to throw up!</span>")
			spawn(100)	//and you have 10 more for mad dash to the bucket
				Stun(5)

				src.visible_message("<span class='warning'>[src] throws up!","<spawn class='warning'>You throw up!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

				var/turf/location = loc
				if (istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1)

				nutrition -= 40
				adjustToxLoss(-3)
				spawn(350)	//wait 35 seconds before next volley
					lastpuke = 0

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

	var/turf/src_turf = get_turf(src)
	if(!src_turf)
		return

	for(var/mob/living/carbon/M in carbon_list)
		var/name = M.real_name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		var/turf/temp_turf = get_turf(M)
		if(!temp_turf || temp_turf.z != src_turf.z)
			continue
		creatures[name] += M

	var/mob/target = input ("Who do you want to project your mind to ?") as null|anything in creatures
	if(isnull(target))
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
	for(var/mob/dead/observer/G in observer_list)
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

	for(var/mob/living/carbon/human/M in human_list) //#Z2 only carbon/human for now
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

/mob/living/carbon/human/proc/get_visible_gender()
	if(wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT && ((head && head.flags_inv & HIDEMASK) || wear_mask))
		return NEUTER
	return gender

/mob/living/carbon/human/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/obj/item/organ/internal/lungs/IO = organs_by_name[O_LUNGS]
	return IO.is_bruised()

/mob/living/carbon/human/proc/rupture_lung()
	var/obj/item/organ/internal/lungs/IO = organs_by_name[O_LUNGS]

	if(!IO.is_bruised())
		src.custom_pain("You feel a stabbing pain in your chest!", 1)
		IO.damage = IO.min_bruised_damage

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
	hand_dirt_color = new/datum/dirt_cover/(dirt_overlay)

	src.update_inv_gloves()	//handles bloody hands overlays and updating
	verbs += /mob/living/carbon/human/proc/bloody_doodle
	return 1 //we applied blood to the item

/mob/living/carbon/human/get_visible_implants(class = 0)

	var/list/visible_implants = list()
	for(var/obj/item/organ/external/BP in bodyparts)
		for(var/obj/item/weapon/O in BP.implants)
			if(!istype(O,/obj/item/weapon/implant) && O.w_class > class)
				visible_implants += O

	return(visible_implants)

/mob/living/carbon/human/proc/handle_embedded_objects()

	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.status & ORGAN_SPLINTED) //Splints prevent movement.
			continue
		for(var/obj/item/weapon/O in BP.implants)
			if(!istype(O,/obj/item/weapon/implant) && prob(5)) //Moving with things stuck in you could be bad.
				// All kinds of embedded objects cause bleeding.
				var/msg = null
				switch(rand(1,3))
					if(1)
						msg ="<span class='warning'>A spike of pain jolts your [BP.name] as you bump [O] inside.</span>"
					if(2)
						msg ="<span class='warning'>Your movement jostles [O] in your [BP.name] painfully.</span>"
					if(3)
						msg ="<span class='warning'>[O] in your [BP.name] twists painfully as you move.</span>"
				to_chat(src, msg)

				BP.take_damage(rand(1,3), 0, 0)
				if(!(BP.status & ORGAN_ROBOT)) //There is no blood in protheses.
					BP.status |= ORGAN_BLEEDING
					src.adjustToxLoss(rand(1,3))

/mob/living/carbon/human/verb/check_pulse()
	set category = "Object"
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.stat == 1 || usr.restrained() || !isliving(usr)) return

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message("\blue [usr] kneels down, puts \his hand on [src]'s wrist and begins counting their pulse.",\
		"You begin counting [src]'s pulse")
	else
		usr.visible_message("\blue [usr] begins counting their pulse.",\
		"You begin counting your pulse.")

	if(src.pulse)
		to_chat(usr, "\blue [self ? "You have a" : "[src] has a"] pulse! Counting...")
	else
		to_chat(usr, "\red [src] has no pulse!")//it is REALLY UNLIKELY that a dead person would check his own pulse
		return

	to_chat(usr, "Don't move until counting is finished.")
	var/time = world.time
	sleep(60)
	if(usr.l_move_time >= time)	//checks if our mob has moved during the sleep()
		to_chat(usr, "You moved while counting. Try again.")
	else
		to_chat(usr, "\blue [self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].")

/mob/living/carbon/human/proc/set_species(new_species, force_organs, default_colour)

	if(!new_species)
		if(dna.species)
			new_species = dna.species
		else
			new_species = HUMAN
	else
		dna.species = new_species

	if(species)
		if(species.name == new_species)
			return FALSE

		if(species.language)
			remove_language(species.language)

		species.on_loose(src)

	species = all_species[new_species]
	maxHealth = species.total_health

	if(force_organs || !bodyparts.len)
		species.create_organs(src)

	if(species.language)
		add_language(species.language)

	if(species.additional_languages)
		for(var/A in species.additional_languages)
			add_language(A)

	if(species.base_color && default_colour)
		//Apply colour.
		r_skin = hex2num(copytext(species.base_color,2,4))
		g_skin = hex2num(copytext(species.base_color,4,6))
		b_skin = hex2num(copytext(species.base_color,6,8))
	else
		r_skin = 0
		g_skin = 0
		b_skin = 0

	species.handle_post_spawn(src)
	species.on_gain(src)

	regenerate_icons()
	full_prosthetic = null

	if(species)
		return TRUE
	else
		return FALSE

// Unlike set_species(), this proc simply changes owner's specie and thats it.
/mob/living/carbon/human/proc/set_species_soft(new_species)
	if(species.name == new_species)
		return

	species.on_loose(src)

	species = all_species[new_species]
	maxHealth = species.total_health

	species.handle_post_spawn(src)
	species.on_gain(src)

	regenerate_icons()

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

	var/message = sanitize(input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", ""), MAX_MESSAGE_LEN)

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"//Should crop any letters? No?
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.basedatum = new/datum/dirt_cover(hand_dirt_color)
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

/mob/living/carbon/try_inject(mob/living/user, error_msg, instant, stealth, pierce_armor)
	if(istype(user))
		if(user.is_busy())
			return

		if(!user.IsAdvancedToolUser())
			if(error_msg)
				to_chat(user, "<span class='warning'>You have no idea, how to use this!</span>")
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
				if(!pierce_armor)
					if(error_msg)
						to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [user.zone_sel.selecting == BP_HEAD ? "on their head" : "on their body"] to inject into.</span>")
					return FALSE
			if(PHORONGUARD)
				if(!pierce_armor)
					if(user.a_intent == I_HURT)
						if(error_msg)
							to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [user.zone_sel.selecting == BP_HEAD ? "on their head" : "on their body"] to inject into.</span>")
						return FALSE
					hunt_injection_port = TRUE

		if(isSynthetic(user.zone_sel.selecting))
			if(error_msg)
				to_chat(user, "<span class='warning'>You are trying to inject [src]'s synthetic body part!</span>")
			return FALSE

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

	return TRUE

/obj/screen/leap
	name = "toggle leap"
	icon = 'icons/mob/screen1_action.dmi'
	icon_state = "action"

	var/on = FALSE
	var/time_used = 0
	var/cooldown = 10 SECONDS


/obj/screen/leap/atom_init()
	. = ..()
	overlays += image(icon, "leap")
	update_icon()

/obj/screen/leap/update_icon()
	icon_state = "[initial(icon_state)]_[on]"

/obj/screen/leap/Click()
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.toggle_leap()

/mob/living/carbon/human/proc/toggle_leap(message = 1)
	leap_icon.on = !leap_icon.on
	leap_icon.update_icon()
	if(message)
		to_chat(src, "<span class='notice'>You will [leap_icon.on ? "now" : "no longer"] leap at enemies!</span>")

/mob/living/carbon/human/ClickOn(atom/A, params)
	if(leap_icon && leap_icon.on && A != src)
		leap_at(A)
	else
		..()

#define MAX_LEAP_DIST 4

/mob/living/carbon/human/proc/leap_at(atom/A)
	if(leap_icon.time_used > world.time)
		to_chat(src, "<span class='warning'>You are too fatigued to leap right now!</span>")
		return

	if(status_flags & LEAPING) // Leap while you leap, so you can leap while you leap
		return

	if(!has_gravity(src))
		to_chat(src, "<span class='notice'>It is unsafe to leap without gravity!</span>")
		return

	if(incapacitated(LEGS) || buckled || pinned.len || stance_damage >= 4) //because you need !restrained legs to leap
		to_chat(src, "<span class='warning'>You cannot leap in your current state.</span>")
		return

	leap_icon.time_used = world.time + leap_icon.cooldown
	status_flags |= LEAPING
	stop_pulling()


	var/prev_intent = a_intent
	a_intent_change("hurt")

	if(wear_suit && istype(wear_suit, /obj/item/clothing/suit/space/vox/stealth))
		for(var/obj/item/clothing/suit/space/vox/stealth/V in list(wear_suit))
			if(V.on)
				V.overload()

	toggle_leap()

	throw_at(A, MAX_LEAP_DIST, 2, null, FALSE, TRUE, CALLBACK(src, .leap_end, prev_intent))

/mob/living/carbon/human/proc/leap_end(prev_intent)
	status_flags &= ~LEAPING
	a_intent_change(prev_intent)

/mob/living/carbon/human/throw_impact(atom/A)
	if(!(status_flags & LEAPING))
		return ..()

	if(isliving(A))
		var/mob/living/L = A
		L.visible_message("<span class='danger'>\The [src] leaps at [L]!</span>", "<span class='userdanger'>[src] leaps on you!</span>")
		if(issilicon(A))
			L.Weaken(1) //Only brief stun
			step_towards(src, L)
		else
			L.Weaken(5)
			sleep(2) // Runtime prevention (infinite bump() calls on hulks)
			step_towards(src, L)

			if(restrained()) //You can leap when you hands are cuffed, but you can't grab
				return

			var/use_hand = "left"
			if(l_hand)
				if(r_hand)
					to_chat(src, "<span class='warning'>You need to have one hand free to grab someone.</span>")
					return
				else
					use_hand = "right"

			visible_message("<span class='warning'><b>\The [src]</b> seizes [L] aggressively!</span>")

			var/obj/item/weapon/grab/G = new(src, L)
			if(use_hand == "left")
				l_hand = G
			else
				r_hand = G

			G.state = GRAB_AGGRESSIVE
			G.icon_state = "grabbed1"
			G.synch()
			L.grabbed_by += G

	else if(A.density)
		visible_message("<span class='danger'>[src] smashes into [A]!</span>", "<span class='danger'>You smashes into [A]!</span>")
		weakened = 2

	update_canmove()

#undef MAX_LEAP_DIST

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
	if(organs_by_name[O_EYES])
		var/obj/item/organ/internal/IO = organs_by_name[O_EYES]
		if(istype(IO))
			return 1
	return 0

/mob/living/carbon/human/slip(slipped_on, stun_duration=4, weaken_duration=2)
	if(shoes && (shoes.flags & NOSLIP))
		return FALSE
	return ..(slipped_on,stun_duration, weaken_duration)

/mob/living/carbon/human/is_nude(maximum_coverage = 0, pos_slots = list(src.head, src.shoes, src.neck, src.mouth, src.wear_suit, src.w_uniform, src.belt, src.gloves, src.glasses)) // Expands our pos_slots arg.
	return ..()

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

/mob/living/carbon/human/proc/should_have_organ(organ_check)

	var/obj/item/organ/external/BP
	if(organ_check in list(O_HEART, O_LUNGS))
		BP = bodyparts_by_name[BP_CHEST]
	else if(organ_check in list(O_LIVER, O_KIDNEYS))
		BP = bodyparts_by_name[BP_GROIN]

	if(BP && (BP.status & ORGAN_ROBOT))
		return FALSE
	return species.has_organ[organ_check]

/mob/living/carbon/human/can_eat(flags = DIET_ALL)
	return species && (species.dietflags & flags)

/mob/living/carbon/human/get_taste_sensitivity()
	if(species)
		return species.taste_sensitivity
	else
		return 1
