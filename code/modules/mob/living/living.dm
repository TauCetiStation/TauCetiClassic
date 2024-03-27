/mob/living/atom_init()
	. = ..()
	living_list += src

	default_transform = transform
	default_pixel_x = pixel_x
	default_pixel_y = pixel_y
	default_layer = layer

	for(var/H in get_all_data_huds())
		var/datum/atom_hud/data/hud = H
		hud.add_to_hud(src)

	if(moveset_type)
		add_moveset(new moveset_type(), MOVESET_TYPE)

	beauty = new /datum/modval(0.0)
	RegisterSignal(beauty, list(COMSIG_MODVAL_UPDATE), PROC_REF(update_beauty))

	beauty.AddModifier("stat", additive=beauty_living)

	if(spawner_args)
		spawner_args.Insert(1, /datum/component/logout_spawner)
		AddComponent(arglist(spawner_args))

/mob/living/Destroy()
	allowed_combos = null
	known_combos = null
	movesets_by_source = null
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

/mob/living/prepare_huds()
	..()
	prepare_data_huds()

/mob/living/proc/prepare_data_huds()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/CanPass(atom/movable/mover, turf/target, height)
	if(istype(mover, /obj/item/projectile) && lying && stat != DEAD)
		var/obj/item/projectile/P = mover
		if(get_turf(P.original) == loc)
			return FALSE
	return ..()

//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A, yes)
	if (buckled || !yes || now_pushing)
		return
	SEND_SIGNAL(src, COMSIG_LIVING_BUMPED, A)
	if(!ismovable(A) || is_blocked_turf(A))
		if(confused && stat == CONSCIOUS && m_intent == MOVE_INTENT_RUN && !lying)
			playsound(get_turf(src), pick(SOUNDIN_PUNCH_MEDIUM), VOL_EFFECTS_MASTER)
			visible_message("<span class='warning'>[src] [pick("ran", "slammed")] into \the [A]!</span>")
			apply_damage(3, BRUTE, pick(BP_HEAD , BP_CHEST , BP_L_LEG , BP_R_LEG))
			Stun(1)
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
		C.spread_disease_to(M, DISEASE_SPREAD_CONTACT)

	if(moving_diagonally)
		return 1

	if(M.pulling == src)
		M.stop_pulling()

	//BubbleWrap: Should stop you pushing a restrained person out of the way
	if(ishuman(M))
		if(M.anchored)
			if(!(world.time % 5))
				to_chat(src, "<span class='warning'>[M] is anchored, you cannot push past.</span>")
			return 1
		if((M.pulledby && M.pulledby.stat == CONSCIOUS && !M.pulledby.restrained() && M.restrained()) || locate(/obj/item/weapon/grab, M.grabbed_by))
			if(!(world.time % 5))
				to_chat(src, "<span class='warning'>[M] is restrained, you cannot push past.</span>")
			return 1
		if(ismob(M.pulling))
			var/mob/pulling_mob = M.pulling
			if(pulling_mob.restrained() && !M.restrained() && M.stat == CONSCIOUS)
				if(!(world.time % 5))
					to_chat(src, "<span class='warning'>[M] is restraining [pulling_mob], you cannot push past.</span>")
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
			forceMove(M.loc, pulling == M) // so if we pulling this mob we will continue so
			M.forceMove(oldloc, TRUE)
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
	if(moving_diagonally)
		return 1
	if(!AM.anchored)
		now_pushing = 1
		var/t = get_dir(src, AM)
		if(pulling == AM)
			stop_pulling()
		step(AM, t)
		step(src, t)
		now_pushing = 0

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(AM.Adjacent(src))
		start_pulling(AM)

/mob/living/count_pull_debuff()
	if(!pulling)
		return 0

	var/tally = 0
	var/atom/movable/AM = pulling
	//Mob pulling
	if(ismob(AM))
		var/mob/M = AM
		tally += M.stat == CONSCIOUS ? ( M.a_intent == INTENT_HELP ? 0 : 0.5 ) : 1
	else if(isitem(AM))
		var/obj/item/I = AM
		if(I && !(I.flags & ABSTRACT) && I.w_class >= SIZE_NORMAL)
			tally += 0.5 * (I.w_class - 2)
	//Structure pulling
	else if(istype(AM, /obj/structure))
		tally += 0.3
		var/obj/structure/S = AM
		if(istype(S, /obj/structure/stool/bed/roller))//should be without debuff
			tally -= 0.3
	//Machinery pulling
	else if(ismachinery(AM))
		tally += 0.3

	return tally

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
		adjustOxyLoss(health - config.health_threshold_dead)
		to_chat(src, "<span class='notice'>You have given up life and succumbed to death.</span>")
		death()

/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss
		med_hud_set_health()
		med_hud_set_status()


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(ishuman(src))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
		if(IsShockproof()) //shockproof
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
	else if(ismonkey(src))
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
		return 1
	else if(isAI(src))
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
//	if(ishuman(src))
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

// ========== BLUR ==========

/**
 * Make the mobs vision blurry
 */
/mob/proc/blurEyes(amount)
	if(amount > 0)
		eye_blurry = max(amount, eye_blurry)
	update_eye_blur()

/**
 * Adjust the current blurriness of the mobs vision by amount
 */
/mob/proc/adjustBlurriness(amount)
	eye_blurry = max(eye_blurry + amount, 0)
	update_eye_blur()

/**
 * Set the mobs blurriness of vision to an amount
 */
/mob/proc/setBlurriness(amount)
	eye_blurry = max(amount, 0)
	update_eye_blur()

/**
 * Apply the blurry overlays to a mobs clients screen
 */
/mob/proc/update_eye_blur()
	if(!client)
		return

	if(client.prefs.eye_blur_effect)
		var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/rendering_plate/game_world) in client.screen
		if(eye_blurry)
			PM.add_filter("eye_blur_angular", 1, angular_blur_filter(16, 16, clamp(eye_blurry * 0.1, 0.2, 0.6)))
			PM.add_filter("eye_blur_gauss", 1, gauss_blur_filter(clamp(eye_blurry * 0.05, 0.1, 0.25)))
		else
			PM.remove_filter("eye_blur_angular")
			PM.remove_filter("eye_blur_gauss")

	else
		if(eye_blurry)
			overlay_fullscreen("blurry", /atom/movable/screen/fullscreen/blurry)
		else
			clear_fullscreen("blurry")

// ============================================================

/mob/living/proc/check_contents_for(A)
	var/list/L = get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null, tesla_shock = 0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = get_contents()
	for(var/obj/O in L)
		O.emplode(severity)
	..()

/mob/living/singularity_act()
	var/gain = 20
	log_investigate(" has consumed [key_name(src)].",INVESTIGATE_SINGULO) //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/airlock_crush_act()
	var/turf/mob_turf = get_turf(src)
	for(var/dir in cardinal)
		var/turf/new_turf = get_step(mob_turf, dir)
		if(Move(new_turf))
			break
	AdjustStunned(5)
	AdjustWeakened(5)
	take_overall_damage(brute = DOOR_CRUSH_DAMAGE, used_weapon = "Crushed")
	visible_message("<span class='red'>[src] was crushed by the door.</span>",
					"<span class='danger'>The door crushed you.</span>")

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

	else if(isspaceturf(get_turf(src)))
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
	updatehealth()

// damage ONE bodypart, bodypart gets randomly selected from damaged ones.
/mob/living/proc/take_bodypart_damage(brute, burn)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	updatehealth()

// heal MANY bodyparts, in random order
/mob/living/proc/heal_overall_damage(brute, burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	updatehealth()

// damage MANY bodyparts, in random order
/mob/living/proc/take_overall_damage(brute, burn, used_weapon = null)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	updatehealth()

/mob/living/proc/restore_all_bodyparts()
	return

/mob/living/proc/restore_all_organs()
	return

/mob/living/proc/revive()
	rejuvenate()
	if(buckled)
		buckled.user_unbuckle_mob(src)
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if (C.handcuffed && !initial(C.handcuffed))
			C.drop_from_inventory(C.handcuffed)
		if (C.legcuffed && !initial(C.legcuffed))
			C.drop_from_inventory(C.legcuffed)

	med_hud_set_health()

/mob/living/proc/rejuvenate()
	SEND_SIGNAL(src, COMSIG_LIVING_REJUVENATE)

	if(reagents)
		reagents.clear_reagents()

	beauty.AddModifier("stat", additive=beauty_living)

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	setHalLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
	setDrugginess(0)

	// shut down ongoing problems
	radiation = 0
	nutrition = NUTRITION_LEVEL_NORMAL
	bodytemperature = T20C
	sdisabilities = 0
	disabilities = 0
	ExtinguishMob()
	fire_stacks = 0
	suiciding = FALSE

	// fix blindness and deafness
	blinded = 0
	eye_blind = 0
	setBlurriness(0)
	ear_deaf = 0
	ear_damage = 0
	heal_overall_damage(getBruteLoss(), getFireLoss())

	SetDrunkenness(0)

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.shock_stage = 0

		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			H.restore_blood()
			H.full_prosthetic = null
			var/obj/item/organ/internal/heart/Heart = H.organs_by_name[O_HEART]
			Heart?.heart_normalize()

	restore_all_bodyparts()
	restore_all_organs()
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

	med_hud_set_health()
	med_hud_set_status()

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
/mob/living/proc/UpdateDamageIcon()
	return

/mob/living/proc/cure_all_viruses()
	return

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

/mob/living/drop_item(atom/Target)
	if(!get_active_hand() && !drop_combo_element())
		to_chat(src, "<span class='warning'>You have nothing to drop in your hand!</span>")
		return
	return ..()

/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(client)
		to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
	else
		to_chat(usr, "[src] does not have any stored infomation!")

	return

/mob/living/pointed(atom/A)
	if(incapacitated() || (status_flags & FAKEDEATH))
		return FALSE

	. = ..()
	if(.)
		usr.visible_message("<span class='notice'><b>[usr]</b> points to [A].</span>")

/mob/living/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if (buckled && buckled.loc != NewLoc)
		if (!buckled.anchored)
			return buckled.Move(NewLoc, Dir)
		else
			return FALSE

	if (restrained())
		stop_pulling()

	var/old_dir = dir
	var/turf/old_loc = loc

	if(!moving_diagonally)
		if(pulling && (get_dist(src, pulling) <= 1 || pulling.loc == loc))
			if(pulling.loc)
				if(!isturf(pulling.loc))
					stop_pulling()
					return
			else
				if(Debug)
					log_debug("pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]")
					log_debug("REPORT THIS")

			if(pulling.anchored)
				stop_pulling()
				return
		else
			stop_pulling()

		. = ..()

		if(pulling && !restrained() && old_loc != loc)
			var/diag = get_dir(src, pulling)
			if(get_dist(src, pulling) > 1 || ISDIAGONALDIR(diag))
				if(isliving(pulling))
					var/mob/living/M = pulling
					if(M.grabbed_by.len)
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								M.visible_message("<span class='warning'>[G.affecting] has been pulled from [G.assailant]'s grip by [src].</span>")
								qdel(G)

					if(!M.grabbed_by.len)
						var/atom/movable/AM = M.pulling
						M.stop_pulling()

						pulling.Move(old_loc, get_dir(pulling, old_loc))
						if(M && AM)
							M.start_pulling(AM)
				else
					pulling.Move(old_loc, get_dir(pulling, old_loc))
	else
		. = ..()

	if(!ISDIAGONALDIR(Dir))
		pull_trail_damage(NewLoc, old_loc, old_dir)
		if(moving_diagonally)
			return .

	if (s_active && s_active.loc != src && get_turf(s_active) != get_turf(src))	//check s_active.loc != src first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)

/mob/living/proc/pull_trail_damage(turf/new_loc, turf/old_loc, old_dir)
	if(!isturf(old_loc) || old_loc == loc)
		return FALSE
	if(!lying || buckled || grabbed_by.len || !mob_has_gravity())
		return FALSE
	if(prob(getBruteLoss() / 2))
		makeTrail(new_loc, old_loc, old_dir)
	if(pull_damage() && prob(25))
		adjustBruteLoss(2)
		visible_message("<span class='warning'>[src]'s wounds worsen terribly from being dragged!</span>")
		return TRUE
	return FALSE

/mob/living/carbon/human/pull_trail_damage(turf/new_loc, turf/old_loc, old_dir)
	if(..())
		blood_remove(1)

/mob/living/proc/makeTrail(turf/new_loc, turf/old_loc, old_dir)
	if(!isturf(old_loc))
		return

	var/trail_type = getTrail()
	if(!trail_type)
		return

	var/blood_exists = 0
	for(var/obj/effect/decal/cleanable/blood/trail_holder/C in old_loc) //checks for blood splatter already on the floor
		blood_exists = 1

	var/newdir = turn(dir, 180)
	if(newdir != old_dir)
		newdir = newdir | old_dir
		if(newdir == NORTH_SOUTH) //N + S
			newdir = NORTH
		else if(newdir == EAST_WEST) //E + W
			newdir = EAST
	if((newdir in global.cardinal) && (prob(50)))
		newdir = turn(newdir, 180)

	var/datum/dirt_cover/new_cover
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.species)
			new_cover = new(H.species.blood_datum)
	if(!new_cover)
		new_cover = new/datum/dirt_cover/red_blood
	if(!blood_exists)
		var/obj/effect/decal/cleanable/blood/BL = new /obj/effect/decal/cleanable/blood/trail_holder(old_loc)
		BL.basedatum = new_cover
		BL.update_icon()
	else
		for(var/obj/effect/decal/cleanable/blood/trail_holder/TH in old_loc)
			TH.basedatum.add_dirt(new_cover)
			TH.update_icon()
	for(var/obj/effect/decal/cleanable/blood/trail_holder/TH in old_loc)
		if(!TH.amount)
			STOP_PROCESSING(SSobj, TH)
			TH.name = initial(TH.name)
			TH.desc = initial(TH.desc)
			TH.amount = initial(TH.amount)
			TH.drytime = world.time + DRYING_TIME * (TH.amount+1)
			START_PROCESSING(SSobj, TH)
		if((!(newdir in TH.existing_dirs) || trail_type == "trails_1") && TH.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
			TH.existing_dirs += newdir
			TH.add_overlay(image('icons/effects/blood.dmi', trail_type, dir = newdir))
		if(dna)
			TH.blood_DNA[dna.unique_enzymes] = dna.b_type

/mob/living/proc/getTrail() //silicon and simple_animals don't get blood trails
	return null

/mob/living/carbon/getTrail()
	return "trails_1"

/mob/living/carbon/human/getTrail()
	if(blood_amount() > 0)
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
		else if(isitem(H.loc))
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
					if(prob(5))
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
			if(C.handcuffed || istype(C.buckled, /obj/machinery/optable/torture_table))
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
		if(!L.incapacitated(NONE))
			var/obj/C = loc
			C.container_resist(L)

	//breaking out of handcuffs and putting off fires
	else if(iscarbon(L))
		var/mob/living/carbon/CM = L
		if(CM.on_fire)
			if(!CM.canmove && !CM.crawling)	return
			CM.fire_stacks -= 5
			CM.Stun(5)
			CM.Weaken(5)
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
			if(!CM.canmove && !CM.crawling)	return
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
/mob/living/proc/crawl_can_use()
	var/turf/T = get_turf(src)
	if( (locate(/obj/structure/table) in T) || (locate(/obj/structure/stool/bed) in T) || (locate(/obj/structure/plasticflaps) in T))
		var/obj/structure/S
		for(S in T)
			if(IS_ABOVE(src, S))
				return TRUE
			return FALSE
	return TRUE

/mob/living/var/crawl_getup = FALSE

/mob/living/verb/crawl()
	set name = "Crawl"
	set category = "IC"

	if(!crawling && HAS_TRAIT(src, TRAIT_NO_CRAWL))
		to_chat(src, "<span class='warning'>Нет! ПОЛ ГРЯЗНЫЙ!</span>")
		return

	if(crawl_getup)
		return


	if((status_flags & FAKEDEATH) || buckled)
		return

	if(incapacitated(NONE))
		if(crawling)
			to_chat(src, "<span class='rose'>You can't wake up.</span>")
		else
			to_chat(src, "<span class='rose'>You can't control yourself.</span>")
		return

	if(crawling)
		crawl_getup = TRUE
		if(do_after(src, 10, target = src))
			crawl_getup = FALSE
			if(!crawl_can_use())
				playsound(src, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
					BP.take_damage(5, used_weapon = "Facepalm") // what?.. that guy was insane anyway.
				else
					take_overall_damage(5, used_weapon = "Table")
				Stun(1)
				to_chat(src, "<span class='danger'>Ouch!</span>")
				return
			layer = 4.0
		else
			crawl_getup = FALSE
			return
	else
		if(!crawl_can_use())
			to_chat(src, "<span class='notice'>You can't crawl here!</span>")
			return
	SetCrawling(!crawling)
	update_canmove()
	to_chat(src, "<span class='notice'>You are now [crawling ? "crawling" : "getting up"].</span>")

//called when the mob receives a bright flash
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash)
	if(override_blindness_check || !(disabilities & BLIND))
		overlay_fullscreen("flash", type)
		addtimer(CALLBACK(src, PROC_REF(clear_fullscreen), "flash", 25), 25)
		SEND_SIGNAL(src, COMSIG_FLASH_EYES, intensity)
		return TRUE
	return FALSE

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
/atom/movable/proc/do_attack_animation(atom/A, end_pixel_y, has_effect = TRUE, visual_effect_icon, visual_effect_color)
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


/mob/living/do_attack_animation(atom/A, end_pixel_y, has_effect = TRUE, visual_effect_icon, visual_effect_color)
	end_pixel_y = default_pixel_y
	..()

	if(has_effect)
		do_item_attack_animation(A, visual_effect_icon, visual_effect_color)


/mob/living/proc/do_item_attack_animation(atom/A, visual_effect_icon, visual_effect_color)
	var/list/viewing = list()
	for(var/mob/M in viewers(A))
		if(M.client && (M.client.prefs.toggles & SHOW_ANIMATIONS))
			viewing |= M.client

	//Show an image of the wielded weapon over the person who got dunked.
	var/image/I
	var/obj/item/used_item = get_active_hand()
	if(used_item)
		if(used_item.alternate_appearances)
			viewing = alternate_attack_animation(used_item, A, viewing)
		I = image(used_item.icon, A, used_item.icon_state, A.layer + 1)
	else if(visual_effect_icon)
		I = image('icons/effects/attack_overlays.dmi', A, visual_effect_icon, A.layer + 0.1)
		I.color = visual_effect_color

	if(I)
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA|KEEP_APART
		I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

		flick_overlay(I,viewing,5)
		I.pixel_z = 16 //lift it up...
		animate(I, pixel_z = 0, alpha = 125, time = 3) //smash it down into them!

// returns a new list of viewers without viewers with alternate_appearance
/mob/living/proc/alternate_attack_animation(obj/item/item, atom/target, list/viewing)
	if(item.alternate_appearances)
		var/image/I
		for(var/key in item.alternate_appearances)
			var/list/alt_viewing = list()
			var/datum/atom_hud/alternate_appearance/basic/AA = item.alternate_appearances[key]
			for(var/client/C in viewing)
				if(!(C.mob in AA.hudusers))
					continue
				alt_viewing += C
				viewing -= C

			I = image(AA.theImage.icon, target, AA.theImage.icon_state, target.layer+1)
			I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA|KEEP_APART
			I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

			flick_overlay(I, alt_viewing, 5)
			I.pixel_z = 16
			animate(I, pixel_z = 0, alpha = 125, time = 3)
	return viewing

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

/mob/living/proc/harvest(mob/user, turf/newloc = loc)
	if(QDELETED(src))
		return
	if(length(butcher_results))
		for(var/path in butcher_results)
			for(var/i = 1 to butcher_results[path])
				new path(newloc)
			//In case you want to have things like simple_animals drop their butcher results on gib, so it won't double up below.
			butcher_results.Remove(path)
		if(user)
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

		to_chat(src, "<span class='notice'>You can taste [get_english_list(final_taste_list)].</span>")
		lasttaste = world.time

// This proc returns TRUE if less than given percentage is not covered.
/mob/living/proc/is_nude(maximum_coverage = 0)
	return TRUE // For all intents and purposes we are nude asf.

/mob/living/proc/naturechild_check()
	return TRUE

/mob/living/proc/get_satiation()
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

/mob/living/proc/vomit(punched = FALSE, masked = FALSE, vomit_type = DEFAULT_VOMIT, stun = TRUE, force = FALSE)
	if(stat == DEAD && !punched && !force)
		return FALSE
	SEND_SIGNAL(src, COMSIG_LIVING_VOMITED)
	if(stun)
		Stun(3)
	if(nutrition < 50 && (vomit_type != VOMIT_BLOOD))
		visible_message("<span class='warning'>[src] convulses in place, gagging!</span>",
						"<span class='warning'>You try to throw up, but there is nothing!</span>")
		adjustOxyLoss(3)
		adjustHalLoss(5)
		return FALSE

	nutrition -= 50
	blurEyes(5)

	if(ishuman(src)) // A stupid, snowflakey thing, but I see no point in creating a third argument to define the sound... ~Luduk
		var/list/vomitsound = list()
		var/mob/living/carbon/human/H = src

		if((HULK in H.mutations) && H.hulk_activator == ACTIVATOR_VOMITING)
			H.try_mutate_to_hulk()

		// The main reason why this is here, and not made into a polymorphized proc, is because we need to know from the subclasses that could cover their face, that they do.
		if(masked)
			visible_message("<span class='warning bold'>[name]</span> <span class='warning'>gags on their own puke!</span>",
							"<span class='warning'>You gag on your own puke, damn it, what could be worse!</span>")
			vomitsound = get_sound_by_voice(src, SOUNDIN_MRIGVOMIT, SOUNDIN_FRIGVOMIT)
			eye_blurry = max(10, eye_blurry)
			losebreath += 20
		else
			visible_message("<span class='warning bold'>[name]</span> <span class='warning'>throws up!</span>",
							"<span class='warning'>You throw up!</span>")
			vomitsound = get_sound_by_voice(src, SOUNDIN_MALEVOMIT, SOUNDIN_FEMALEVOMIT)
		make_jittery(max(35 - jitteriness, 0))
		playsound(src, pick(vomitsound), VOL_EFFECTS_MASTER, null, FALSE)
	else
		visible_message("<span class='warning bold'>[name]</span> <span class='warning'>throws up!</span>",
						"<span class='warning'>You throw up!</span>")
		playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)

	var/turf/simulated/T = loc
	var/obj/structure/toilet/WC = locate(/obj/structure/toilet) in T
	if(WC && WC.lid_open)
		return TRUE
	if(locate(/obj/structure/sink) in T)
		return TRUE
	if(istype(T))
		switch(vomit_type)
			if(VOMIT_BLOOD)
				T.add_blood_floor(src)
			else
				T.add_vomit_floor(src, getToxLoss() > 0 ? VOMIT_TOXIC : vomit_type)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "puke", /datum/mood_event/puke)
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
	SHOULD_CALL_PARENT(TRUE)

	if(m_intent == intent)
		return FALSE

	if(intent == MOVE_INTENT_RUN && HAS_TRAIT(src, TRAIT_NO_RUN))
		to_chat(src, "<span class='notice'>Something prevents you from running!</span>")
		return FALSE

	SEND_SIGNAL(src, COMSIG_MOB_SET_M_INTENT, intent)

	m_intent = intent
	if(hud_used)
		move_intent?.update_icon(src)

	return TRUE

/mob/living/proc/swap_hand()
	return

/mob/living/death(gibbed)
	beauty.AddModifier("stat", additive=beauty_dead)
	update_health_hud()
	return ..()

/mob/living/proc/update_beauty(datum/source, old_value)
	if(old_value != 0.0)
		RemoveElement(/datum/element/beauty, old_value)
	if(beauty.Get() == 0.0)
		return
	AddElement(/datum/element/beauty, beauty.Get())

//Throwing stuff
/mob/living/proc/toggle_throw_mode()
	if(in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/proc/throw_mode_off()
	in_throw_mode = FALSE

/mob/living/proc/throw_mode_on()
	in_throw_mode = TRUE

/mob/living/in_interaction_vicinity(atom/target)
	// Telekinetic distance is handled by the larger telekinesis system.
	if(can_tk(level=TK_LEVEL_TWO, show_warnings=FALSE))
		return TRUE

	return ..()

/mob/living/proc/AdjustDrunkenness(amount)
	drunkenness += amount

/mob/living/proc/SetDrunkenness(value)
	drunkenness = value

/mob/living/proc/MakeDrunkenness(value)
	drunkenness = max(value, drunkenness)

/mob/living/proc/handle_drunkenness()
	var/heal_mod = 0.0
	if(drunkenness <= 0)
		drunkenness = 0
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "drunk")
		return

	if(drunkenness >= DRUNKENNESS_PASS_OUT)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "drunk", /datum/mood_event/drunk_catharsis)
	else if(drunkenness >= DRUNKENNESS_CONFUSED)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "drunk", /datum/mood_event/very_drunk)
	else if(drunkenness >= DRUNKENNESS_SLUR)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "drunk", /datum/mood_event/drunk)

	if(drowsyness)
		AdjustDrunkenness(-1)

	if(drunkenness >= DRUNKENNESS_PASS_OUT)
		Paralyse(3)
		drowsyness = max(drowsyness, 3)
		heal_mod = 10.0
		return

	if(drunkenness >= DRUNKENNESS_BLUR)
		eye_blurry = max(eye_blurry, 2)
		heal_mod = 8.0

	if(drunkenness >= DRUNKENNESS_SLUR)
		if(drowsyness)
			drowsyness = max(drowsyness, 3)
		slurring = max(slurring, 3)
		heal_mod = 4.0

	if(drunkenness >= DRUNKENNESS_CONFUSED)
		MakeConfused(2)
		heal_mod = 6.0

	if(HAS_ROUND_ASPECT(ROUND_ASPECT_HEALING_ALCOHOL))
		adjustBruteLoss(-1.0 * heal_mod)
		adjustFireLoss(-1.0 * heal_mod)
		AdjustWeakened(-0.5 * heal_mod)
		adjustHalLoss(-2.0 * heal_mod)

/mob/living/carbon/human/handle_drunkenness()
	. = ..()
	if(drunkenness >= DRUNKENNESS_PASS_OUT)
		var/obj/item/organ/internal/liver/IO = organs_by_name[O_LIVER]
		if(istype(IO))
			IO.take_damage(0.1, 1)
		adjustToxLoss(0.1)

/*
	Try to take AM, if it's impossible
	try to put AM into fallback.
	If it's impossible, return FALSE.
*/
/mob/living/proc/try_take(atom/movable/AM, atom/fallback)
	return AM.taken(src, fallback)

/mob/living/proc/get_pumped(bodypart)
	return 0

// return TRUE if we failed our interaction
/mob/living/interact_prob_brain_damage(atom/object)
	if(getBrainLoss() >= 60)
		visible_message("<span class='warning'>[src] stares cluelessly at [isturf(object.loc) ? object : ismob(object.loc) ? object : "something"] and drools.</span>")
		return TRUE
	else if(prob(getBrainLoss()))
		to_chat(src, "<span class='warning'>You momentarily forget how to use [object].</span>")
		return TRUE

//Quality proc
/mob/living/proc/trigger_syringe_fear()
	to_chat(src, "<span class='userdanger'>IT'S A SYRINGE!!!</span>")
	if(prob(5))
		eye_blind = 20
		blurEyes(40)
		to_chat(src, "<span class='warning'>Darkness closes in...</span>")
	if(prob(5))
		hallucination = max(hallucination, 200)
		to_chat(src, "<span class='warning'>Ringing in your ears...</span>")
	if(prob(10))
		SetSleeping(40 SECONDS)
		to_chat(src, "<span class='warning'>Your will to fight wavers.</span>")
	if(prob(30))
		Paralyse(20)
	if(prob(40))
		make_dizzy(150)
	SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "scared", /datum/mood_event/scared)

/mob/living/proc/pickup_ore()
	return

/mob/living/carbon/human/trigger_syringe_fear() // move to carbon/human
	..()
	if(prob(15))
		var/bodypart_name = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_GROIN)
		var/obj/item/organ/external/BP = get_bodypart(bodypart_name)
		if(BP)
			BP.take_damage(8, used_weapon = "Syringe") 	//half kithen-knife damage
			to_chat(src, "<span class='warning'>You got a cut with a syringe.</span>")

/mob/living/reset_view(atom/A, force_remote_viewing)
	..()
	src.force_remote_viewing = force_remote_viewing
