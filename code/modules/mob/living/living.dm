/mob/living/atom_init()
	. = ..()
	living_list += src

	default_transform = transform
	default_pixel_x = pixel_x
	default_pixel_y = pixel_y
	default_layer = layer


/mob/living/Destroy()
	QDEL_LIST(combos_performed)
	QDEL_LIST(combos_saved)

	if(length(status_effects))
		for(var/s in status_effects)
			var/datum/status_effect/S = s
			if(S.on_remove_on_mob_delete) //the status effect calls on_remove when its mob is deleted
				qdel(S)
			else
				S.be_replaced()

	living_list -= src
	return ..()

/mob/living/proc/OpenCraftingMenu()
	return

//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A, yes)
	if (buckled || !yes || now_pushing)
		return
	if(!ismovable(A) || is_blocked_turf(A))
		if(confused && stat == CONSCIOUS && m_intent == "run")
			playsound(get_turf(src), pick(SOUNDIN_PUNCH), VOL_EFFECTS_MASTER)
			visible_message("<span class='warning'>[src] [pick("ran", "slammed")] into \the [A]!</span>")
			apply_damage(3, BRUTE, pick(BP_HEAD , BP_CHEST , BP_L_LEG , BP_R_LEG))
			Stun(3)
			Weaken(2)

	if(ismob(A))
		var/mob/M = A
		if(MobBump(M))
			return
	..()
	if(isobj(A))
		var/obj/O = A
		if(ObjBump(O))
			return
	if(istype(A, /atom/movable))
		var/atom/movable/AM = A
		if(PushAM(AM))
			return

//Called when we bump onto a mob
/mob/living/proc/MobBump(mob/M)
	//Even if we don't push/swap places, we "touched" them, so spread fire
	SpreadFire(M)

	if(now_pushing)
		return 1

	if(prob(10) && iscarbon(src) && iscarbon(M))
		var/mob/living/carbon/C = src
		C.spread_disease_to(M, "Contact")

	if(M.pulling == src)
		M.stop_pulling()

	//BubbleWrap: Should stop you pushing a restrained person out of the way
	if(ishuman(M))
		for(var/mob/MM in range(M, 1))
			if(MM.pinned.len || ((MM.pulling == M && ( M.restrained() && !( MM.restrained() ) && MM.stat == CONSCIOUS)) || locate(/obj/item/weapon/grab, M.grabbed_by.len)) )
				if ( !(world.time % 5) )
					to_chat(src, "<span class='warning'>[M] is restrained, you cannot push past.</span>")
				return 1
			if( M.pulling == MM && ( MM.restrained() && !( M.restrained() ) && M.stat == CONSCIOUS) )
				if ( !(world.time % 5) )
					to_chat(src, "<span class='warning'>[M] is restraining [MM], you cannot push past.</span>")
				return 1

	//switch our position with M
	//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
	if((M.a_intent == INTENT_HELP || M.restrained()) && (a_intent == INTENT_HELP || restrained()) && M.canmove && canmove && !M.buckled && !M.buckled_mob) // mutual brohugs all around!
		var/can_switch = TRUE
		var/turf/T = get_turf(src)
		for(var/atom/A in T.contents - src)
			if(A.density)
				can_switch = FALSE
				break
		if(can_switch && get_dist(M, src) <= 1)
			now_pushing = 1
			//TODO: Make this use Move(). we're pretty much recreating it here.
			//it could be done by setting one of the locs to null to make Move() work, then setting it back and Move() the other mob
			var/oldloc = loc
			forceMove(M.loc)
			M.forceMove(oldloc)
			M.LAssailant = src

			for(var/mob/living/carbon/slime/slime in view(1,M))
				if(slime.Victim == M)
					slime.UpdateFeed()

			now_pushing = 0
			return 1

	//Fat
	if(HAS_TRAIT(M, TRAIT_FAT))
		to_chat(src, "<span class='danger'>You cant to push [M]'s fat ass out of the way.</span>")
		return 1

	//okay, so we didn't switch. but should we push?
	//not if he's not CANPUSH of course
	if(!(M.status_flags & CANPUSH) )
		return 1
	//anti-riot equipment is also anti-push
	if(M.r_hand && istype(M.r_hand, /obj/item/weapon/shield/riot))
		return 1
	if(M.l_hand && istype(M.l_hand, /obj/item/weapon/shield/riot))
		return 1

//Called when we bump onto an obj
/mob/living/proc/ObjBump(obj/O)
	return

//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM)
	if(now_pushing)
		return 1
	if(!AM.anchored)
		now_pushing = 1
		var/t = get_dir(src, AM)
		if(istype(AM, /obj/structure/window))
			var/obj/structure/window/W = AM
			if(W.ini_dir == NORTHWEST || W.ini_dir == NORTHEAST || W.ini_dir == SOUTHWEST || W.ini_dir == SOUTHEAST)
				for(var/obj/structure/window/win in get_step(AM,t))
					now_pushing = 0
					return
//			if(W.fulltile)
//				for(var/obj/structure/window/win in get_step(W,t))
//					now_pushing = 0
//					return
		if(pulling == AM)
			stop_pulling()
		step(AM, t)
		now_pushing = 0

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(AM.Adjacent(src))
		start_pulling(AM)

/mob/living/count_pull_debuff()
	pull_debuff = 0
	if(pulling)
		var/tally = 0

		//General pull debuff for playable mobs (playable without shitspawn, yeah)
		if(ismonkey(src))
			tally += 1
		else if(isslime(src))
			tally += 1.5
		else
			tally += 0.3

		var/atom/movable/AM = pulling
		//Mob pulling
		if(ismob(AM))
			tally += 1
		//Structure pulling
		if(istype(AM, /obj/structure))
			tally += 0.5
			var/obj/structure/S = AM
			if(istype(S, /obj/structure/stool/bed/roller))//should be without debuff
				tally -= 0.5
		//Machinery pulling
		if(istype(AM, /obj/machinery))
			tally += 0.5
		pull_debuff += tally

/mob/living/proc/add_ingame_age()
	if(client && isnum(client.player_ingame_age) && !client.is_afk(5 MINUTES)) // 5 minutes of inactive time will disable this, until player come back.
		var/client/C = client
		if(C.player_next_age_tick == 0) //All clients start with 0, so we need to set next tick for the first time.
			C.player_next_age_tick = world.time + 1 MINUTE
		else if(world.time > C.player_next_age_tick) //Every 60 seconds we add +1 to player ingame age.
			C.player_next_age_tick = world.time + 1 MINUTE
			C.player_ingame_age++

/mob/living/verb/succumb()
	set hidden = 1
	if ((src.health < 0 && src.health > -95.0))
		src.adjustOxyLoss(src.health + 200)
		src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss()
		to_chat(src, "<span class='notice'>You have given up life and succumbed to death.</span>")


/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
		if(NO_SHOCK in src.mutations) //shockproof
			return 0
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = burn_amount / H.bodyparts.len
		var/extradam = 0	//added to when organ is at max dam
		for(var/obj/item/organ/external/BP in H.bodyparts)
			BP.take_damage(0, divided_damage + extradam)	//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/carbon/monkey))
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature


// ==================================
// ========== DAMAGE PROCS ==========
// ==================================

// ========== BRUTE ==========
/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(amount)
	if(status_flags & GODMODE)
		return
	bruteloss = clamp(bruteloss + amount, 0, maxHealth * 2)

// ========== OXY ==========
/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(amount)
	if(status_flags & GODMODE)
		return
	oxyloss = clamp(oxyloss + amount, 0, maxHealth * 2)

/mob/living/proc/setOxyLoss(amount)
	if(status_flags & GODMODE)
		return
	oxyloss = clamp(amount, 0, maxHealth * 2)

// ========== TOX ==========
/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(amount)
	if(status_flags & GODMODE)
		return
	toxloss = clamp(toxloss + amount, 0, maxHealth * 2)

/mob/living/proc/setToxLoss(amount)
	if(status_flags & GODMODE)
		return
	toxloss = clamp(amount, 0, maxHealth * 2)

// ========== FIRE ==========
/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(amount)
	if(status_flags & GODMODE)
		return
	fireloss = clamp(fireloss + amount, 0, maxHealth * 2)

// ========== CLONE ==========
/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(amount)
	if(status_flags & GODMODE)
		return
	cloneloss = clamp(cloneloss + amount, 0, maxHealth * 2)

/mob/living/proc/setCloneLoss(amount)
	if(status_flags & GODMODE)
		return
	cloneloss = clamp(amount, 0, maxHealth * 2)

// ========== BRAIN ==========
/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(amount)
	if(status_flags & GODMODE)
		return
	brainloss = clamp(brainloss + amount, 0, maxHealth * 2)

/mob/living/proc/setBrainLoss(amount)
	if(status_flags & GODMODE)
		return
	brainloss = clamp(amount, 0, maxHealth * 2)

// ========== PAIN ==========
/mob/living/proc/getHalLoss()
	return halloss

/mob/living/proc/adjustHalLoss(amount)
	if(status_flags & GODMODE)
		return
	if(amount > 0)
		add_combo_value_all(amount)
	halloss = clamp(halloss + amount, 0, maxHealth * 2)

/mob/living/proc/setHalLoss(amount)
	if(status_flags & GODMODE)
		return
	if(amount - halloss > 0)
		add_combo_value_all(amount - halloss)
	halloss = clamp(amount, 0, maxHealth * 2)

// ============================================================

/mob/living/proc/check_contents_for(A)
	var/list/L = src.get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null, tesla_shock = 0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emplode(severity)
	..()

/mob/living/singularity_act()
	var/gain = 20
	log_investigate(" has consumed [key_name(src)].",INVESTIGATE_SINGULO) //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/singularity_pull(S)
	step_towards(src,S)

/mob/living/proc/try_inject()
	return TRUE

/mob/living/proc/get_temperature(datum/gas_mixture/environment)
	var/loc_temp = T0C
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		loc_temp =  M.return_temperature()

	else if(istype(loc, /obj/structure/transit_tube_pod))
		loc_temp = environment.temperature

	else if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.temperature

	else if(istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		var/obj/machinery/atmospherics/components/unary/cryo_cell/C = loc
		var/datum/gas_mixture/G = C.AIR1

		if(G.total_moles < 10)
			loc_temp = environment.temperature
		else
			loc_temp = G.temperature

	else
		loc_temp = environment.temperature

	return loc_temp

// heal ONE bodypart, bodypart gets randomly selected from damaged ones.
/mob/living/proc/heal_bodypart_damage(brute, burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE bodypart, bodypart gets randomly selected from damaged ones.
/mob/living/proc/take_bodypart_damage(brute, burn)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY bodyparts, in random order
/mob/living/proc/heal_overall_damage(brute, burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY bodyparts, in random order
/mob/living/proc/take_overall_damage(brute, burn, used_weapon = null)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/restore_all_bodyparts()
	return

/mob/living/proc/revive()
	rejuvenate()
	if(buckled)
		buckled.user_unbuckle_mob(src)
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if (C.handcuffed && !initial(C.handcuffed))
			C.drop_from_inventory(C.handcuffed)
		C.handcuffed = initial(C.handcuffed)

		if (C.legcuffed && !initial(C.legcuffed))
			C.drop_from_inventory(C.legcuffed)
		C.legcuffed = initial(C.legcuffed)
	update_health_hud()

/mob/living/proc/rejuvenate()
	SEND_SIGNAL(src, COMSIG_LIVING_REJUVENATE)

	if(reagents)
		reagents.clear_reagents()

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	setHalLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)

	// shut down ongoing problems
	radiation = 0
	nutrition = 400
	bodytemperature = T20C
	sdisabilities = 0
	disabilities = 0
	ExtinguishMob()
	fire_stacks = 0

	if(pinned.len)
		for(var/obj/O in pinned)
			O.forceMove(loc)
		pinned.Cut()

	// fix blindness and deafness
	blinded = 0
	eye_blind = 0
	eye_blurry = 0
	ear_deaf = 0
	ear_damage = 0
	heal_overall_damage(getBruteLoss(), getFireLoss())

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.shock_stage = 0

		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			H.restore_blood()
			H.full_prosthetic = null
			var/obj/item/organ/internal/heart/Heart = H.organs_by_name[O_HEART]
			Heart.heart_normalize()

	restore_all_bodyparts()
	cure_all_viruses()

	// remove the character from the list of the dead
	if(stat == DEAD)
		dead_mob_list -= src
		alive_mob_list += src
		tod = null
		timeofdeath = 0

	//restore all HP
	if(health != maxHealth)
		health = maxHealth
		icon_state = initial(icon_state)

	// restore us to conciousness
	stat = CONSCIOUS

	// make the icons look correct
	if(HUSK in mutations)
		mutations.Remove(HUSK)
	regenerate_icons()
	update_health_hud()

/mob/living/carbon/human/rejuvenate()
	var/obj/item/organ/external/head/BP = bodyparts_by_name[BP_HEAD]
	if(istype(BP))
		BP.disfigured = FALSE

	for (var/obj/item/organ/external/head/H in organ_head_list) // damn son, where'd you get this?
		if(H.brainmob)
			if(H.brainmob.real_name == real_name)
				if(H.brainmob.mind)
					H.brainmob.mind.transfer_to(src)
					qdel(H)
	..()

/mob/living/proc/update_health_hud()
	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD

/mob/living/proc/UpdateDamageIcon()
	return

/mob/living/proc/cure_all_viruses()
	for(var/datum/disease/virus in viruses)
		virus.cure()

/mob/living/carbon/cure_all_viruses()
	for(var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		V.cure(src)

	..()

/mob/living/proc/remove_any_mutations()
	dna.ResetSE()
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		genemutcheck(src, gene.block, null, MUTCHK_FORCED)

/mob/living/carbon/human/remove_any_mutations()
	var/needs_update = mutations.len > 0

	..()

	// Might need to update appearance for hulk etc.
	if(needs_update)
		update_mutations()

/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(usr, "[src] does not have any stored infomation!")
	else
		to_chat(usr, "OOC Metadata is not supported by this server!")

	return

/mob/living/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if (buckled && buckled.loc != NewLoc)
		if (!buckled.anchored)
			return buckled.Move(NewLoc, Dir)
		else
			return FALSE

	if (restrained())
		stop_pulling()


	var/t7 = 1
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == CONSCIOUS && !( M.restrained() )))
				t7 = null
	if(t7 && pulling && (get_dist(src, pulling) <= 1 || pulling.loc == loc))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				stop_pulling()
				return
			else
				if(Debug)
					log_debug("pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]")
					log_debug("REPORT THIS")

		/////
		if(pulling && pulling.anchored)
			stop_pulling()
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (isliving(pulling))
					var/mob/living/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								M.visible_message("<span class='warning'>[G.affecting] has been pulled from [G.assailant]'s grip by [src].</span>")
								//G = null
								qdel(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/atom/movable/AM = M.pulling
						M.stop_pulling()

						//this is the gay blood on floor shit -- Added back -- Skie
						if(M.lying && (prob(M.getBruteLoss() / 2)))
							makeTrail(T, M)
						if(M.pull_damage())
							if(prob(25))
								M.adjustBruteLoss(2)
								visible_message("<span class='warning'>[M]'s wounds worsen terribly from being dragged!</span>")
								var/turf/location = M.loc
								if (istype(location, /turf/simulated))
									if(ishuman(M))
										var/mob/living/carbon/human/H = M
										var/blood_volume = round(H.vessel.get_reagent_amount("blood"))
										if(blood_volume > 0)
											H.vessel.remove_reagent("blood",1)


						pulling.Move(T, get_dir(pulling, T))
						if(M && AM)
							M.start_pulling(AM)
				else
					if (pulling)
						pulling.Move(T, get_dir(pulling, T))
	else
		stop_pulling()
		. = ..()

	if (s_active && !( s_active in contents ) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents ) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)

/mob/living/proc/makeTrail(turf/T, mob/living/M)
	var/blood_exists = 0
	var/trail_type = M.getTrail()
	for(var/obj/effect/decal/cleanable/blood/trail_holder/C in M.loc) //checks for blood splatter already on the floor
		blood_exists = 1
	if (istype(M.loc, /turf/simulated) && trail_type != null)
		var/newdir = get_dir(T, M.loc)
		if(newdir != M.dir)
			newdir = newdir | M.dir
			if(newdir == 3) //N + S
				newdir = NORTH
			else if(newdir == 12) //E + W
				newdir = EAST
		if((newdir in list(1, 2, 4, 8)) && (prob(50)))
			newdir = turn(get_dir(T, M.loc), 180)
		var/datum/dirt_cover/new_cover
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species)
				new_cover = new(H.species.blood_datum)
		if(!new_cover)
			new_cover = new/datum/dirt_cover/red_blood
		if(!blood_exists)
			var/obj/effect/decal/cleanable/blood/BL = new /obj/effect/decal/cleanable/blood/trail_holder(M.loc)
			BL.basedatum = new_cover
			BL.update_icon()
		else
			for(var/obj/effect/decal/cleanable/blood/trail_holder/TH in M.loc)
				TH.basedatum.add_dirt(new_cover)
				TH.update_icon()
		for(var/obj/effect/decal/cleanable/blood/trail_holder/TH in M.loc)
			if(!TH.amount)
				STOP_PROCESSING(SSobj, TH)
				TH.name = initial(TH.name)
				TH.desc = initial(TH.desc)
				TH.amount = initial(TH.amount)
				TH.drytime = world.time + DRYING_TIME * (TH.amount+1)
				START_PROCESSING(SSobj, TH)
			if((!(newdir in TH.existing_dirs) || trail_type == "trails_1") && TH.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
				TH.existing_dirs += newdir
				TH.add_overlay(image('icons/effects/blood.dmi',trail_type,dir = newdir))
			if(M.dna)
				TH.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type

/mob/living/proc/getTrail() //silicon and simple_animals don't get blood trails
	return null

/mob/living/carbon/getTrail()
	return "trails_1"

/mob/living/carbon/human/getTrail()
	if(!species.flags[NO_BLOOD] && round(vessel.get_reagent_amount("blood")) > 0)
		return ..()

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.next_move > world.time)
		return FALSE

	. = TRUE
	usr.SetNextMove(20)

	var/mob/living/L = usr

	//Getting out of someone's inventory.

	if(istype(src.loc,/obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.loc //Get our item holder.
		var/mob/living/M = H.loc                      //Get our mob holder (if any).

		if(istype(M))
			M.drop_from_inventory(H)
			to_chat(M, "<span class='notice'>[H] wriggles out of your grip!</span>")
			to_chat(src, "<span class='notice'>You wriggle out of [M]'s grip!</span>")
		else if(istype(H.loc,/obj/item))
			to_chat(src, "<span class='notice'>You struggle free of [H.loc].</span>")
			H.forceMove(get_turf(H))
		return

	//Resisting control by an alien mind.
	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		var/mob/living/captive_brain/H = src

		to_chat(H, "<span class='danger'>You begin doggedly resisting the parasite's control (this will take approximately sixty seconds).</span>")
		to_chat(B.host, "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>")

		spawn(rand(350,450)+B.host.brainloss)

			if(!B || !B.controlling)
				return

			B.host.adjustBrainLoss(rand(5,10))
			to_chat(H, "<span class='danger'>With an immense exertion of will, you regain control of your body!</span>")
			to_chat(B.host, "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>")
			B.controlling = 0

			B.ckey = B.host.ckey
			B.host.ckey = H.ckey

			H.ckey = null
			H.name = "host brain"
			H.real_name = "host brain"

			verbs -= /mob/living/carbon/proc/release_control
			verbs -= /mob/living/carbon/proc/punish_host
			verbs -= /mob/living/carbon/proc/spawn_larvae

			return

	//resisting grabs (as if it helps anyone...)
	if (!L.incapacitated())
		var/resisting = 0
		for(var/obj/O in L.requests)
			L.requests.Remove(O)
			qdel(O)
			resisting++
		for(var/obj/item/weapon/grab/G in usr.grabbed_by)
			resisting++
			switch(G.state)
				if(GRAB_PASSIVE)
					if(ishuman(G.assailant))
						var/mob/living/carbon/human/H = G.assailant
						if(H.shoving_fingers && !istype(H.wear_mask, /obj/item/clothing/mask/muzzle))
							H.adjustBruteLoss(5) // We bit them.
							H.shoving_fingers = FALSE
					qdel(G)
				if(GRAB_AGGRESSIVE)
					if(prob(50 - (L.lying ? 35 : 0)))
						L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s grip!</span>")
						qdel(G)
				if(GRAB_NECK)
					if(prob(5 - L.stunned * 2))
						L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s headlock!</span>")
						qdel(G)
		if(resisting)
			L.visible_message("<span class='danger'>[L] resists!</span>")
	//Digging yourself out of a grave
	if(istype(src.loc, /obj/structure/pit))
		var/obj/structure/pit/P = loc
		spawn() P.digout(src)
	//unbuckling yourself
	if(L.buckled && (L.last_special <= world.time) )
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if (istype(C.buckled,/obj/structure/stool/bed/nest))
				C.buckled.user_unbuckle_mob(C)
				return
			if( C.handcuffed )
				C.next_move = world.time + 100
				C.last_special = world.time + 100
				C.visible_message("<span class='danger'>[usr] attempts to unbuckle themself!</span>", self_message = "<span class='rose'>You attempt to unbuckle yourself. (This will take around 2 minutes and you need to stand still)</span>")
				spawn(0)
					if(do_after(usr, 1200, target = usr))
						if(!C.buckled)
							return
						C.visible_message("<span class='danger'>[usr] manages to unbuckle themself!</span>", self_message = "<span class='notice'>You successfully unbuckle yourself.</span>")
						C.buckled.user_unbuckle_mob(C)
		else
			L.buckled.user_unbuckle_mob(L)

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(loc && istype(loc, /obj) && !isturf(loc))
		if(L.stat == CONSCIOUS && !L.stunned && !L.weakened && !L.paralysis)
			var/obj/C = loc
			C.container_resist(L)

	//breaking out of handcuffs and putting off fires
	else if(iscarbon(L))
		var/mob/living/carbon/CM = L
		if(CM.on_fire)
			if(!CM.canmove && !CM.resting)	return
			CM.fire_stacks -= 5
			CM.weakened = 5
			CM.visible_message("<span class='danger'>[CM] rolls on the floor, trying to put themselves out!</span>", \
				"<span class='rose'>You stop, drop, and roll!</span>")
			if(fire_stacks <= 0)
				CM.visible_message("<span class='danger'>[CM] has successfully extinguished themselves!</span>", \
					"<span class='notice'>You extinguish yourself.</span>")
				ExtinguishMob()
			return
		if(CM.handcuffed && (CM.last_special <= world.time))
			CM.next_move = world.time + 100
			CM.last_special = world.time + 100
			if(isxenoadult(CM) || (HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				CM.visible_message("<span class='danger'>[CM] is trying to break the handcuffs!</span>", self_message = "<span class='rose'>You attempt to break your handcuffs. (This will take around 5 seconds and you need to stand still)</span>")
				spawn(0)
					if(do_after(CM, 50, target = usr))
						if(!CM.handcuffed || CM.buckled)
							return
						CM.visible_message("<span class='danger'>[CM] manages to break the handcuffs!</span>", self_message = "<span class='notice'>You successfully break your handcuffs.</span>")
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						qdel(CM.handcuffed)
						CM.handcuffed = null
						CM.update_inv_handcuffed()
			else
				var/obj/item/weapon/handcuffs/HC = CM.handcuffed
				var/breakouttime = 1200 //A default in case you are somehow handcuffed with something that isn't an obj/item/weapon/handcuffs type
				var/displaytime = 2 //Minutes to display in the "this will take X minutes."
				if(istype(HC)) //If you are handcuffed with actual handcuffs... Well what do I know, maybe someone will want to handcuff you with toilet paper in the future...
					breakouttime = HC.breakouttime
					displaytime = breakouttime / 600 //Minutes
				CM.visible_message("<span class='danger'>[usr] attempts to remove \the [HC]!</span>", self_message = "<span class='notice'>You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)</span>")
				spawn(0)
					if(do_after(CM, breakouttime, target = usr))
						if(!CM.handcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server lags so hard that 40s isn't lenient enough - Quarxink
						if(istype(HC, /obj/item/weapon/handcuffs/alien))
							CM.visible_message("<span class='danger'>[CM] break in a discharge of energy!</span>", \
							"<span class='notice'>You successfully break in a discharge of energy!</span>")
							var/datum/effect/effect/system/spark_spread/S = new
							S.set_up(4,0,CM.loc)
							S.start()
						else
							CM.visible_message("<span class='danger'>[CM] manages to remove the handcuffs!</span>", \
								"<span class='notice'>You successfully remove \the [CM.handcuffed].</span>")
						CM.drop_from_inventory(CM.handcuffed)

		else if(CM.legcuffed && (CM.last_special <= world.time))
			if(!CM.canmove && !CM.resting)	return
			CM.next_move = world.time + 100
			CM.last_special = world.time + 100
			if(isxenoadult(CM) || (HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				to_chat(usr, )
				CM.visible_message("<span class='danger'>[CM] is trying to break the legcuffs!</span>", self_message = "<span class='notice'>You attempt to break your legcuffs. (This will take around 5 seconds and you need to stand still)</span>")
				spawn(0)
					if(do_after(CM, 50, target = usr))
						if(!CM.legcuffed || CM.buckled)
							return
						CM.visible_message("<span class='danger'>[CM] manages to break the legcuffs!</span>", self_message = "<span class='notice'>You successfully break your legcuffs.</span>")
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						qdel(CM.legcuffed)
						CM.legcuffed = null
						CM.update_inv_legcuffed()
			else
				var/obj/item/weapon/legcuffs/HC = CM.legcuffed
				var/breakouttime = 1200 //A default in case you are somehow legcuffed with something that isn't an obj/item/weapon/legcuffs type
				var/displaytime = 2 //Minutes to display in the "this will take X minutes."
				if(istype(HC)) //If you are legcuffed with actual legcuffs... Well what do I know, maybe someone will want to legcuff you with toilet paper in the future...
					breakouttime = HC.breakouttime
					displaytime = breakouttime / 600 //Minutes
				CM.visible_message("<span class='danger'>[usr] attempts to remove \the [HC]!</span>", self_message = "<span class='notice'>You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)</span>")
				spawn(0)
					if(do_after(CM, breakouttime, target = usr))
						if(!CM.legcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server lags so hard that 40s isn't lenient enough - Quarxink
						if(istype(HC, /obj/item/weapon/handcuffs/alien))
							CM.visible_message("<span class='danger'>[CM] break in a discharge of energy!</span>", \
							"<span class='notice'>You successfully break in a discharge of energy!</span>")
							var/datum/effect/effect/system/spark_spread/S = new
							S.set_up(4,0,CM.loc)
							S.start()
						else
							CM.visible_message("<span class='danger'>[CM] manages to remove the legcuffs!</span>", \
								"<span class='notice'>You successfully remove \the [CM.legcuffed].</span>")
						CM.drop_from_inventory(CM.legcuffed)

/// What should the mob do when laying down. Return TRUE to prevent default behavior.
/mob/living/proc/on_lay_down()
	return

/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"

	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_all_components()
		to_chat(R, "<span class='notice'>You toggle all your components.</span>")
		return

//Already resting and have others debuffs
	if( resting && (IsSleeping() || weakened || paralysis || stunned) )
		to_chat(src, "<span class='rose'>You can't wake up.</span>")

//Restrained and some debuffs
	else if( restrained() && (paralysis || stunned) )
		to_chat(src, "<span class='rose'>You can't move.</span>")

//Restrained and lying on optable or simple table
	else if( restrained() && can_operate(src) )	//TO DO: Refactor OpTable code to /bed subtype or "Rest" verb
		to_chat(src, "<span class='rose'>You can't move.</span>")

//Debuffs check
	else if(!resting && (IsSleeping() || weakened || paralysis || stunned) )
		to_chat(src, "<span class='rose'>You can't control yourself.</span>")

	else
		if(on_lay_down())
			return
		resting = !resting
		to_chat(src, "<span class='notice'>You are now [resting ? "resting" : "getting up"].</span>")

//called when the mob receives a bright flash
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash)
	if(override_blindness_check || !(disabilities & BLIND))
		overlay_fullscreen("flash", type)
		spawn(0)
			sleep(25)
			if(src)
				clear_fullscreen("flash", 25)
		return 1

/mob/living/proc/has_brain()
	return TRUE

/mob/living/proc/has_eyes()
	return TRUE

//-TG Port for smooth standing/lying animations
/mob/living/proc/get_pixel_x_offset(lying_current = FALSE)
	return initial(pixel_x)

/mob/living/proc/get_pixel_y_offset(lying_current = FALSE)
	return initial(pixel_y)

//Attack animation port below
/atom/movable/proc/do_attack_animation(atom/A, end_pixel_y)
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/final_pixel_y = initial(pixel_y)
	if(end_pixel_y)
		final_pixel_y = end_pixel_y
	var/direction = get_dir(src, A)
	switch(direction)
		if(NORTH)
			pixel_y_diff = 8
		if(SOUTH)
			pixel_y_diff = -8
		if(EAST)
			pixel_x_diff = 8
		if(WEST)
			pixel_x_diff = -8
		if(NORTHEAST)
			pixel_x_diff = 8
			pixel_y_diff = 8
		if(NORTHWEST)
			pixel_x_diff = -8
			pixel_y_diff = 8
		if(SOUTHEAST)
			pixel_x_diff = 8
			pixel_y_diff = -8
		if(SOUTHWEST)
			pixel_x_diff = -8
			pixel_y_diff = -8

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = final_pixel_y, time = 2)


/mob/living/do_attack_animation(atom/A)
	var/final_pixel_y = default_pixel_y
	..(A, final_pixel_y)

	//Show an image of the wielded weapon over the person who got dunked.
	var/image/I
	if(hand)
		if(l_hand)
			I = image(l_hand.icon,A,l_hand.icon_state,A.layer+1)
	else
		if(r_hand)
			I = image(r_hand.icon,A,r_hand.icon_state,A.layer+1)
	if(I)
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		var/list/viewing = list()
		for(var/mob/M in viewers(A))
			if(M.client && (M.client.prefs.toggles & SHOW_ANIMATIONS))
				viewing |= M.client
		flick_overlay(I,viewing,5)
		I.pixel_z = 16 //lift it up...
		animate(I, pixel_z = 0, alpha = 125, time = 3) //smash it down into them!

/mob/living/Stat()
	..()
	if(statpanel("Status"))
		if(SSticker.mode && SSticker.mode.config_tag == "gang")
			var/datum/game_mode/gang/mode = SSticker.mode
			if(isnum(mode.A_timer))
				stat(null, "[gang_name("A")] Gang Takeover: [max(mode.A_timer, 0)]")
			if(isnum(mode.B_timer))
				stat(null, "[gang_name("B")] Gang Takeover: [max(mode.B_timer, 0)]")

/mob/living/update_gravity(has_gravity)
	if(!SSticker)
		return
	float(!has_gravity)

/mob/living/proc/float(on)
	if(on && !floating && !buckled)
		start_floating()
	else if((!on || buckled) && floating)
		stop_floating()

/mob/living/proc/start_floating()

	floating = 1

	var/amplitude = 2 //maximum displacement from original position
	var/period = 36 //time taken for the mob to go up >> down >> original position, in deciseconds. Should be multiple of 4

	var/top = old_y + amplitude
	var/bottom = old_y - amplitude
	var/half_period = period / 2
	var/quarter_period = period / 4

	animate(src, pixel_y = top, time = quarter_period, easing = SINE_EASING | EASE_OUT, loop = -1)		//up
	animate(pixel_y = bottom, time = half_period, easing = SINE_EASING, loop = -1)						//down
	animate(pixel_y = old_y, time = quarter_period, easing = SINE_EASING | EASE_IN, loop = -1)			//back

/mob/living/proc/stop_floating()
	animate(src, pixel_y = old_y, time = 5, easing = SINE_EASING | EASE_IN) //halt animation
	//reset the pixel offsets to zero
	floating = 0

/mob/living/proc/attempt_harvest(obj/item/I, mob/user)
	if(stat == DEAD && butcher_results && istype(buckled, /obj/structure/kitchenspike)) //can we butcher it? Mob must be buckled to a meatspike to butcher it
		if(user.is_busy())
			return
		to_chat(user, "<span class='notice'>You begin to butcher [src]...</span>")
		playsound(src, 'sound/weapons/slice.ogg', VOL_EFFECTS_MASTER)
		if(do_mob(user, src, 80))
			harvest(user)
		return TRUE

/mob/living/proc/harvest(mob/user)
	if(QDELETED(src))
		return
	if(butcher_results.len)
		for(var/path in butcher_results)
			for(var/i = 1 to butcher_results[path])
				new path(src.loc)
			//In case you want to have things like simple_animals drop their butcher results on gib, so it won't double up below.
			butcher_results.Remove(path)
		visible_message("<span class='notice'>[user] butchers [src].</span>")
		gib()

/mob/living/proc/get_taste_sensitivity()
	return TRUE

/mob/living/proc/taste_reagents(datum/reagents/tastes)
	var/t_sens = get_taste_sensitivity()
	if(!t_sens)//this also works for IPCs and stuff that returns 0 here
		return

	var/do_not_taste_at_all = 1//so we don't spam with recent tastes

	var/taste_sum = 0
	var/list/taste_list = list()//associative list so we can stack stuff that tastes the same
	var/list/final_taste_list = list()//final list of taste strings

	for(var/datum/reagent/R in tastes.reagent_list)
		taste_sum += R.volume * R.taste_strength
		if(R.taste_message)
			taste_list[R.taste_message] += R.volume * R.taste_strength

	for(var/R in taste_list)
		if(recent_tastes[R] && (world.time - recent_tastes[R] < 12 SECONDS))
			recent_tastes -= R
			continue

		do_not_taste_at_all = 0//something was fresh enough to taste; could still be bland enough to be unrecognizable

		if(taste_list[R] / taste_sum >= 0.15 / t_sens)
			final_taste_list += R
			recent_tastes[R] = world.time

	if(do_not_taste_at_all)
		return //no message spam

	if(world.time-lasttaste >= 18)//prevent tastes spam
		if(final_taste_list.len == 0)//too many reagents - none meet their thresholds
			to_chat(src, "<span class='notice'>You can't really make out what you're tasting...</span>")
			lasttaste = world.time
			return

		to_chat(src, "<span class='notice'>You can taste [english_list(final_taste_list)].</span>")
		lasttaste = world.time

// This proc returns TRUE if less than given percentage is not covered.
/mob/living/proc/is_nude(maximum_coverage = 0)
	return TRUE // For all intents and purposes we are nude asf.

/mob/living/proc/naturechild_check()
	return TRUE

/mob/living/proc/get_nutrition()
	// This proc gets nutrition value with all possible alters.
	// E.g. see how in carbon nutriment, plant matter, meat reagents are accounted.
	// The difference between this and just nutrition, is that this proc shows how much nutrition a mob has
	// even counting in the nutriments that are not digested yet. You don't feel hunger if you are digesting
	// food, so this proc is used in walk penalty, etc. But you don't see fat of a person if the person is just
	// digesting the giant pizza they ate, so we don't use this in examine code.
	return nutrition

/mob/living/proc/get_metabolism_factor()
	return METABOLISM_FACTOR

/mob/living/proc/CanObtainCentcommMessage()
	return FALSE

/mob/living/proc/vomit(punched = FALSE, masked = FALSE)
	if(stat == DEAD && !punched)
		return FALSE

	Stun(3)

	if(nutrition < 50)
		visible_message("<span class='warning'>[src] convulses in place, gagging!</span>", "<span class='warning'>You try to throw up, but there is nothing!</span>")
		adjustOxyLoss(3)
		adjustHalLoss(5)
		return FALSE

	nutrition -= 50
	eye_blurry = max(5, eye_blurry)

	if(ishuman(src)) // A stupid, snowflakey thing, but I see no point in creating a third argument to define the sound... ~Luduk
		var/list/vomitsound = list()
		var/mob/living/carbon/human/H = src

		if((HULK in H.mutations) && H.hulk_activator == ACTIVATOR_VOMITING)
			H.try_mutate_to_hulk()

		// The main reason why this is here, and not made into a polymorphized proc, is because we need to know from the subclasses that could cover their face, that they do.
		if(masked)
			visible_message("<span class='warning bold'>[name]</span> <span class='warning'>gags on their own puke!</span>","<span class='warning'>You gag on your own puke, damn it, what could be worse!</span>")
			if(gender == FEMALE)
				vomitsound = SOUNDIN_FRIGVOMIT
			else
				vomitsound = SOUNDIN_MRIGVOMIT
			eye_blurry = max(10, eye_blurry)
			losebreath += 20
		else
			visible_message("<span class='warning bold'>[name]</span> <span class='warning'>throws up!</span>","<span class='warning'>You throw up!</span>")
			if(gender == FEMALE)
				vomitsound = SOUNDIN_FEMALEVOMIT
			else
				vomitsound = SOUNDIN_MALEVOMIT
		make_jittery(max(35 - jitteriness, 0))
		playsound(src, pick(vomitsound), VOL_EFFECTS_MASTER, null, FALSE)
	else
		visible_message("<span class='warning bold'>[name]</span> <span class='warning'>throws up!</span>","<span class='warning'>You throw up!</span>")
		playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)

	var/turf/simulated/T = loc
	var/obj/structure/toilet/WC = locate(/obj/structure/toilet) in T
	if(WC && WC.open)
		return TRUE
	if(locate(/obj/structure/sink) in T)
		return TRUE

	if(istype(T))
		T.add_vomit_floor(src, getToxLoss() > 0 ? TRUE : FALSE)

	return TRUE

/mob/living/get_targetzone()
	if(zone_sel)
		return zone_sel.selecting
	return pick(TARGET_ZONE_ALL)

/mob/living/proc/has_bodypart(name)
	switch(name)
		if(BP_HEAD)
			return is_usable_head()
		if(BP_L_ARM, BP_R_ARM)
			return is_usable_arm()
		if(BP_L_LEG, BP_R_LEG)
			return is_usable_leg()
	return FALSE

/mob/living/proc/has_organ(name)
	if(name == O_EYES)
		return is_usable_eyes()
	return FALSE

// Living mobs use can_inject() to make sure that the mob is not syringe-proof in general.
/mob/living/proc/can_inject(mob/user, def_zone, show_message = TRUE, penetrate_thick = FALSE)
	return TRUE

/// Try changing move intent. Return success.
/mob/living/proc/set_m_intent(intent)
	if(m_intent == intent)
		return FALSE

	if(intent == MOVE_INTENT_RUN && HAS_TRAIT(src, TRAIT_NO_RUN))
		to_chat(src, "<span class='notice'>Something prevents you from running!</span>")
		return FALSE

	m_intent = intent
	if(hud_used)
		if(hud_used.move_intent)
			hud_used.move_intent.icon_state = intent == MOVE_INTENT_WALK ? "walking" : "running"

	return TRUE
