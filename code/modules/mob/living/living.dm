/mob/living/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A, yes)
	if (buckled || !yes || now_pushing)
		return
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
	if(now_pushing)
		return 1

	if(prob(10) && iscarbon(src) && iscarbon(M))
		var/mob/living/carbon/C = src
		C.spread_disease_to(M, "Contact")

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

		//Fat
		if(FAT in M.mutations)
			var/ran = 40
			if(isrobot(src))
				ran = 20
			if(prob(ran))
				to_chat(src, "<span class='danger'>You fail to push [M]'s fat ass out of the way.</span>")
			return 1

	//Leaping mobs just land on the tile, no pushing, no anything.
	if(status_flags & LEAPING)
		loc = M.loc
		status_flags &= ~LEAPING
		return 1

	//switch our position with M
	//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
	if((M.a_intent == "help" || M.restrained()) && (a_intent == "help" || restrained()) && M.canmove && canmove && !M.buckled && !M.buckled_mob) // mutual brohugs all around!
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
		src.start_pulling(AM)
	return

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
	if(client && !client.is_afk()) //5 minutes of inactive time will disable this, until player come back.
		var/client/C = client
		if(C.player_next_age_tick == 0) //All clients start with 0, so we need to set next tick for the first time.
			C.player_next_age_tick = world.time + 600
		else if(world.time > C.player_next_age_tick) //Every 60 seconds we add +1 to player ingame age.
			C.player_next_age_tick = world.time + 600
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
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/datum/organ/external/affecting in H.organs)
			if(!affecting)	continue
			affecting.take_damage(0, divided_damage+extradam)	//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
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


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn
// I touched them without asking... I'm soooo edgy ~Erro (added nodamage checks)

/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	bruteloss = min(max(bruteloss + amount, 0),(maxHealth*2))

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = min(max(oxyloss + amount, 0),(maxHealth*2))

/mob/living/proc/setOxyLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = min(max(toxloss + amount, 0),(maxHealth*2))

/mob/living/proc/setToxLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	fireloss = min(max(fireloss + amount, 0),(maxHealth*2))

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = min(max(cloneloss + amount, 0),(maxHealth*2))

/mob/living/proc/setCloneLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = min(max(brainloss + amount, 0),(maxHealth*2))

/mob/living/proc/setBrainLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = amount

/mob/living/proc/getHalLoss()
	return halloss

/mob/living/proc/adjustHalLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = min(max(halloss + amount, 0),(maxHealth*2))

/mob/living/proc/setHalLoss(amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = amount

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(newMaxHealth)
	maxHealth = newMaxHealth

// ++++ROCKDTBEN++++ MOB PROCS //END


/mob/proc/get_contents()


//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/weapon/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/weapon/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/weapon/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += src.contents
		for(var/obj/item/weapon/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)

		for(var/obj/item/weapon/gift/G in src.contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in src.contents) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

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
		O.emp_act(severity)
	..()

/mob/living/singularity_act()
	var/gain = 20
	investigate_log(" has consumed [key_name(src)].","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/singularity_pull(S)
	step_towards(src,S)

/mob/living/proc/can_inject()
	return 1

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter:zone_sel.selecting
	if ((t in list( "eyes", "mouth" )))
		t = "head"
	var/datum/organ/external/def_zone = ran_zone(t)
	return def_zone


// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(brute, burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(brute, burn)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(brute, burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(brute, burn, used_weapon = null)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/restore_all_organs()
	return



/mob/living/proc/revive()
	rejuvenate()
	buckled = initial(src.buckled)
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
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.shock_stage=0

	// shut down ongoing problems
	radiation = 0
	nutrition = 400
	bodytemperature = T20C
	sdisabilities = 0
	disabilities = 0
	ExtinguishMob()
	fire_stacks = 0

	// fix blindness and deafness
	blinded = 0
	eye_blind = 0
	eye_blurry = 0
	ear_deaf = 0
	ear_damage = 0
	heal_overall_damage(getBruteLoss(), getFireLoss())

	// restore all of a human's blood
	if(ishuman(src))
		var/mob/living/carbon/human/human_mob = src
		human_mob.restore_blood()

	// fix all of our organs
	restore_all_organs()

	// remove the character from the list of the dead
	if(stat == DEAD)
		dead_mob_list -= src
		living_mob_list += src
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
	return

/mob/living/proc/update_health_hud()
	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD

/mob/living/proc/UpdateDamageIcon()
	return


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

/mob/living/Move(atom/newloc, direct)
	if (buckled && buckled.loc != newloc)
		if (!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

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
								for(var/mob/O in viewers(M, null))
									O.show_message(text("<span class='warning'>[] has been pulled from []'s grip by [].</span>", G.affecting, G.assailant, src), 1)
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
										var/mob/living/carbon/H = M
										var/blood_volume = round(H:vessel.get_reagent_amount("blood"))
										if(blood_volume > 0)
											H:vessel.remove_reagent("blood",1)


						pulling.Move(T, get_dir(pulling, T))
						if(M)
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
		if(!blood_exists)
			new /obj/effect/decal/cleanable/blood/trail_holder(M.loc)
		for(var/obj/effect/decal/cleanable/blood/trail_holder/TH in M.loc)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.species)
					if(TH.color != H.species.blood_color)
						TH.basecolor = H.species.blood_color
						TH.update_icon()
			else
				if(TH.color != initial(TH.basecolor))
					TH.basecolor = initial(TH.basecolor)
					TH.update_icon()
			if(!TH.amount)
				SSobj.processing.Remove(TH)
				TH.name = initial(TH.name)
				TH.desc = initial(TH.desc)
				TH.amount = initial(TH.amount)
				TH.drytime = world.time + DRYING_TIME * (TH.amount+1)
				SSobj.processing |= TH
			if((!(newdir in TH.existing_dirs) || trail_type == "trails_1") && TH.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
				TH.existing_dirs += newdir
				TH.overlays.Add(image('icons/effects/blood.dmi',trail_type,dir = newdir))
			if(M.dna)
				TH.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type

/mob/living/proc/getTrail() //silicon and simple_animals don't get blood trails
	return null

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.next_move = world.time + 20

	var/mob/living/L = usr

	//Getting out of someone's inventory.

	if(istype(src.loc,/obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.loc //Get our item holder.
		var/mob/M = H.loc                      //Get our mob holder (if any).

		if(istype(M))
			M.drop_from_inventory(H)
			to_chat(M, "<span class='notice'>[H] wriggles out of your grip!</span>")
			to_chat(src, "<span class='notice'>You wriggle out of [M]'s grip!</span>")
		else if(istype(H.loc,/obj/item))
			to_chat(src, "<span class='notice'>You struggle free of [H.loc].</span>")
			H.forceMove(get_turf(H))

		if(istype(M))
			for(var/atom/A in M.contents)
				if(istype(A,/mob/living/simple_animal/borer) || istype(A,/obj/item/weapon/holder))
					return

		if(ismob(M))
			M.status_flags &= ~PASSEMOTES
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
	if (!L.stat && !L.restrained())
		if(L.stunned > 2 || L.weakened)
			return
		var/resisting = 0
		for(var/obj/O in L.requests)
			L.requests.Remove(O)
			qdel(O)
			resisting++
		for(var/obj/item/weapon/grab/G in usr.grabbed_by)
			resisting++
			switch(G.state)
				if(GRAB_PASSIVE)
					qdel(G)
				if(GRAB_AGGRESSIVE)
					if(prob(60)) //same chance of breaking the grab as disarm
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
				to_chat(C, "<span class='rose'>You attempt to unbuckle yourself. (This will take around 2 minutes and you need to stand still)</span>")
				for(var/mob/O in viewers(L))
					O.show_message("<span class='danger'>[usr] attempts to unbuckle themself!</span>", 1)
				spawn(0)
					if(do_after(usr, 1200, target = usr))
						if(!C.buckled)
							return
						for(var/mob/O in viewers(C))
							O.show_message("<span class='danger'>[usr] manages to unbuckle themself!</span>", 1)
						to_chat(C, "<span class='notice'>You successfully unbuckle yourself.</span>")
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
			if(!CM.canmove && !CM.resting)	return
			CM.next_move = world.time + 100
			CM.last_special = world.time + 100
			if(isalienadult(CM) || (HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				to_chat(usr, "<span class='rose'>You attempt to break your handcuffs. (This will take around 5 seconds and you need to stand still)</span>")
				for(var/mob/O in viewers(CM))
					O.show_message(text("<span class='danger'>[] is trying to break the handcuffs!</span>", CM), 1)
				spawn(0)
					if(do_after(CM, 50, target = usr))
						if(!CM.handcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("<span class='danger'>[] manages to break the handcuffs!</span>", CM), 1)
						to_chat(CM, "<span class='notice'>You successfully break your handcuffs.</span>")
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
				to_chat(CM, "<span class='notice'>You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)</span>")
				for(var/mob/O in viewers(CM))
					O.show_message( "<span class='danger'>[usr] attempts to remove \the [HC]!</span>", 1)
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
							CM.drop_from_inventory(CM.handcuffed)
							qdel(HC)
						else
							CM.visible_message("<span class='danger'>[CM] manages to remove the handcuffs!</span>", \
								"<span class='notice'>You successfully remove \the [CM.handcuffed].</span>")
							CM.drop_from_inventory(CM.handcuffed)

		else if(CM.legcuffed && (CM.last_special <= world.time))
			if(!CM.canmove && !CM.resting)	return
			CM.next_move = world.time + 100
			CM.last_special = world.time + 100
			if(isalienadult(CM) || (HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				to_chat(usr, "<span class='notice'>You attempt to break your legcuffs. (This will take around 5 seconds and you need to stand still)</span>")
				for(var/mob/O in viewers(CM))
					O.show_message(text("<span class='danger'>[] is trying to break the legcuffs!</span>", CM), 1)
				spawn(0)
					if(do_after(CM, 50, target = usr))
						if(!CM.legcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("<span class='danger'>[] manages to break the legcuffs!</span>", CM), 1)
						to_chat(CM, "<span class='notice'>You successfully break your legcuffs.")
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
				to_chat(CM, "<span class='notice'>You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)</span>")
				for(var/mob/O in viewers(CM))
					O.show_message( "<span class='danger'>[usr] attempts to remove \the [HC]!</span>", 1)
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
							CM.drop_from_inventory(CM.legcuffed)
							CM.legcuffed = null
							CM.update_inv_legcuffed()
							qdel(HC)
						else
							CM.visible_message("<span class='danger'>[CM] manages to remove the legcuffs!</span>", \
								"<span class='notice'>You successfully remove \the [CM.legcuffed].</span>")
							CM.drop_from_inventory(CM.legcuffed)
							CM.legcuffed = null
							CM.update_inv_legcuffed()

/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"

	if(issilicon(usr))
		var/mob/living/silicon/robot/R = usr
		for(var/V in R.components)
			if(V == "power cell") continue
			var/datum/robot_component/C = R.components[V]
			if(C.installed)
				C.toggled = !C.toggled
		to_chat(R, "<span class='notice'>You toggle all your components.</span>")
		return

//Already resting and have others debuffs
	if( resting && (sleeping || weakened || paralysis || stunned) )
		to_chat(src, "<span class='rose'>You can't wake up.</span>")

//Restrained and some debuffs
	else if( restrained() && (paralysis || stunned) )
		to_chat(src, "<span class='rose'>You can't move.</span>")

//Restrained and lying on optable or simple table
	else if( restrained() && can_operate(src) )	//TO DO: Refactor OpTable code to /bed subtype or "Rest" verb
		to_chat(src, "<span class='rose'>You can't move.</span>")

//Debuffs check
	else if(!resting && (sleeping || weakened || paralysis || stunned) )
		to_chat(src, "<span class='rose'>You can't control yourself.</span>")

	else
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

/mob/living/proc/has_eyes()
	return 1

//-TG Port for smooth standing/lying animations
/mob/living/proc/get_standard_pixel_x_offset(lying_current = 0)
	return initial(pixel_x)

/mob/living/proc/get_standard_pixel_y_offset(lying_current = 0)
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
	var/final_pixel_y = get_standard_pixel_y_offset(lying_current)
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
		if(ticker)
			if(ticker.mode)
				if(istype(ticker.mode, /datum/game_mode/gang))
					var/datum/game_mode/gang/mode = ticker.mode
					if(isnum(mode.A_timer))
						stat(null, "[gang_name("A")] Gang Takeover: [max(mode.A_timer, 0)]")
					if(isnum(mode.B_timer))
						stat(null, "[gang_name("B")] Gang Takeover: [max(mode.B_timer, 0)]")

/mob/living/update_gravity(has_gravity)
	if(!ticker)
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

/mob/living/proc/harvest(mob/living/user)
	if(qdeleted(src))
		return
	if(butcher_results)
		if(butcher_results.len)
			for(var/path in butcher_results)
				for(var/i = 1 to butcher_results[path])
					new path(src.loc)
				butcher_results.Remove(path)
			visible_message("<span class='notice'>[user] butchers [src].</span>")
			gib()
