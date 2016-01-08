/mob/living/Life()
	..()
	if(stat != DEAD)
		handle_actions()

/mob/living/verb/succumb()
	set hidden = 1
	if ((src.health < 0 && src.health > -95.0))
		src.adjustOxyLoss(src.health + 200)
		src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss()
		src << "<span class='notice'>You have given up life and succumbed to death.</span>"


/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
		if(mShock in src.mutations) //shockproof
			return 0
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/datum/organ/external/affecting in H.organs)
			if(!affecting)	continue
			if(affecting.take_damage(0, divided_damage+extradam))	//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
				H.UpdateDamageIcon()
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

/mob/living/proc/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	bruteloss = min(max(bruteloss + amount, 0),(maxHealth*2))

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = min(max(oxyloss + amount, 0),(maxHealth*2))

/mob/living/proc/setOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = min(max(toxloss + amount, 0),(maxHealth*2))

/mob/living/proc/setToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	fireloss = min(max(fireloss + amount, 0),(maxHealth*2))

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = min(max(cloneloss + amount, 0),(maxHealth*2))

/mob/living/proc/setCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = min(max(brainloss + amount, 0),(maxHealth*2))

/mob/living/proc/setBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = amount

/mob/living/proc/getHalLoss()
	return halloss

/mob/living/proc/adjustHalLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = min(max(halloss + amount, 0),(maxHealth*2))

/mob/living/proc/setHalLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = amount

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(var/newMaxHealth)
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


/mob/living/proc/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

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
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
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
	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD

/mob/living/proc/rejuvenate()

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)

	//restore all HP
	if(!(health == maxHealth))
		health = initial(health)
		icon_state = initial(icon_state)

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
	if(stat == 2)
		dead_mob_list -= src
		living_mob_list += src
		tod = null
		timeofdeath = 0

	// restore us to conciousness
	stat = CONSCIOUS

	// make the icons look correct
	regenerate_icons()

	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD
	return

/mob/living/proc/UpdateDamageIcon()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			usr << "[src]'s Metainfo:<br>[client.prefs.metadata]"
		else
			usr << "[src] does not have any stored infomation!"
	else
		usr << "OOC Metadata is not supported by this server!"

	return

/mob/living/Move(a, b, flag)
	if (buckled)
		return

	if (restrained())
		stop_pulling()


	var/t7 = 1
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
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
						var/atom/movable/t = M.pulling
						M.stop_pulling()

						//this is the gay blood on floor shit -- Added back -- Skie
						if (M.lying && (prob(M.getBruteLoss() / 6)))
							var/turf/location = M.loc
							if (istype(location, /turf/simulated))
								location.add_blood(M)
						//pull damage with injured people
							if(prob(25))
								M.adjustBruteLoss(1)
								visible_message("<span class='warning'>[M]'s wounds open more from being dragged!</span>")
						if(M.pull_damage())
							if(prob(25))
								M.adjustBruteLoss(2)
								visible_message("<span class='warning'>[M]'s wounds worsen terribly from being dragged!</span>")
								var/turf/location = M.loc
								if (istype(location, /turf/simulated))
									location.add_blood(M)
									if(ishuman(M))
										var/mob/living/carbon/H = M
										var/blood_volume = round(H:vessel.get_reagent_amount("blood"))
										if(blood_volume > 0)
											H:vessel.remove_reagent("blood",1)


						step(pulling, get_dir(pulling.loc, T))
						M.start_pulling(t)
				else
					if (pulling)
						if (istype(pulling, /obj/structure/window))
							if(pulling:ini_dir == NORTHWEST || pulling:ini_dir == NORTHEAST || pulling:ini_dir == SOUTHWEST || pulling:ini_dir == SOUTHEAST)
								for(var/obj/structure/window/win in get_step(pulling,get_dir(pulling.loc, T)))
									stop_pulling()
					if (pulling)
						step(pulling, get_dir(pulling.loc, T))
	else
		stop_pulling()
		. = ..()

	if (s_active && !( s_active in contents ) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents ) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)

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
			M << "<span class='notice'>[H] wriggles out of your grip!</span>"
			src << "<span class='notice'>You wriggle out of [M]'s grip!</span>"
		else if(istype(H.loc,/obj/item))
			src << "<span class='notice'>You struggle free of [H.loc].</span>"
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

		H << "<span class='danger'>You begin doggedly resisting the parasite's control (this will take approximately sixty seconds).</span>"
		B.host << "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>"

		spawn(rand(350,450)+B.host.brainloss)

			if(!B || !B.controlling)
				return

			B.host.adjustBrainLoss(rand(5,10))
			H << "<span class='danger'>With an immense exertion of will, you regain control of your body!</span>"
			B.host << "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>"
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
	if ((!( L.stat ) && !( L.restrained() )))
		if(L.weakened || L.stunned) return

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
					//If the you move when grabbing someone then it's easier for them to break free. Same if the affected mob is immune to stun.
					if (((world.time - G.assailant.l_move_time < 20 || !L.stunned) && prob(15)) || prob(3))
						L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s headlock!</span>")
						qdel(G)
		if(resisting)
			L.visible_message("<span class='danger'>[L] resists!</span>")

	//unbuckling yourself
	if(L.buckled && (L.last_special <= world.time) )
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if( C.handcuffed )
				C.next_move = world.time + 100
				C.last_special = world.time + 100
				C << "<span class='rose'>You attempt to unbuckle yourself. (This will take around 2 minutes and you need to stand still)</span>"
				for(var/mob/O in viewers(L))
					O.show_message("<span class='danger'>[usr] attempts to unbuckle themself!</span>", 1)
				spawn(0)
					if(do_after(usr, 1200, target = usr))
						if(!C.buckled)
							return
						for(var/mob/O in viewers(C))
							O.show_message("<span class='danger'>[usr] manages to unbuckle themself!</span>", 1)
						C << "<span class='notice'>You successfully unbuckle yourself.</span>"
						C.buckled.manual_unbuckle(C)
		else
			L.buckled.manual_unbuckle(L)

	//Breaking out of a locker?
	else if( src.loc && (istype(src.loc, /obj/structure/closet)) )
		var/breakout_time = 2 //2 minutes by default

		var/obj/structure/closet/C = L.loc
		if(C.opened)
			return //Door's open... wait, why are you in it's contents then?
		if(istype(L.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/SC = L.loc
			if(!SC.locked && !SC.welded)
				return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'
		else
			if(!C.welded)
				return //closed but not welded...
		//	else Meh, lets just keep it at 2 minutes for now
		//		breakout_time++ //Harder to get out of welded lockers than locked lockers

		//okay, so the closet is either welded or locked... resist!!!
		usr.next_move = world.time + 100
		L.last_special = world.time + 100
		L << "<span class='rose'>You lean on the back of \the [C] and start pushing the door open. (this will take about [breakout_time] minutes)</span>"
		for(var/mob/O in viewers(usr.loc))
			O.show_message("<span class='danger'>The [L.loc] begins to shake violently!</span>", 1)


		spawn(0)
			if(do_after(usr,(breakout_time*60*10), target = C)) //minutes * 60seconds * 10deciseconds
				if(!C || !L || L.stat != CONSCIOUS || L.loc != C || C.opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
					return

				//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
				if(istype(L.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					if(!SC.locked && !SC.welded)
						return
				else
					if(!C.welded)
						return

				//Well then break it!
				if(istype(usr.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					SC.desc = "It appears to be broken."
					SC.icon_state = SC.icon_off
					flick(SC.icon_broken, SC)
					sleep(10)
					flick(SC.icon_broken, SC)
					sleep(10)
					SC.broken = 1
					SC.locked = 0
					SC.update_icon()
					usr << "<span class='notice'>You successfully break out!</span>"
					for(var/mob/O in viewers(L.loc))
						O.show_message("<span class='danger'>[usr] successfully broke out of \the [SC]!</span>", 1)
					if(istype(SC.loc, /obj/structure/bigDelivery)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
						var/obj/structure/bigDelivery/BD = SC.loc
						BD.attack_hand(usr)
					SC.open()
				else
					C.welded = 0
					C.update_icon()
					usr << "<span class='notice'>You successfully break out!</span>"
					for(var/mob/O in viewers(L.loc))
						O.show_message("<span class='danger'>[usr] successfully broke out of \the [C]!</span>", 1)
					if(istype(C.loc, /obj/structure/bigDelivery)) //nullspace ect.. read the comment above
						var/obj/structure/bigDelivery/BD = C.loc
						BD.attack_hand(usr)
					C.open()

	//breaking out of handcuffs and putting off fires
	else if(iscarbon(L))
		var/mob/living/carbon/CM = L
		if(CM.on_fire)
			if(!CM.canmove & !CM.resting)	return
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
			if(!CM.canmove & !CM.resting)	return
			CM.next_move = world.time + 100
			CM.last_special = world.time + 100
			if(isalienadult(CM) || (HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				usr << "<span class='rose'>You attempt to break your handcuffs. (This will take around 5 seconds and you need to stand still)</span>"
				for(var/mob/O in viewers(CM))
					O.show_message(text("<span class='danger'>[] is trying to break the handcuffs!</span>", CM), 1)
				spawn(0)
					if(do_after(CM, 50, target = usr))
						if(!CM.handcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("<span class='danger'>[] manages to break the handcuffs!</span>", CM), 1)
						CM << "<span class='notice'>You successfully break your handcuffs.</span>"
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
				CM << "<span class='notice'>You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)</span>"
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
			if(!CM.canmove & !CM.resting)	return
			CM.next_move = world.time + 100
			CM.last_special = world.time + 100
			if(isalienadult(CM) || (HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				usr << "<span class='notice'>You attempt to break your legcuffs. (This will take around 5 seconds and you need to stand still)</span>"
				for(var/mob/O in viewers(CM))
					O.show_message(text("<span class='danger'>[] is trying to break the legcuffs!</span>", CM), 1)
				spawn(0)
					if(do_after(CM, 50, target = usr))
						if(!CM.legcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("<span class='danger'>[] manages to break the legcuffs!</span>", CM), 1)
						CM << "<span class='notice'>You successfully break your legcuffs."
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
				CM << "<span class='notice'>You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)</span>"
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

//Already resting and have others debuffs
	if( resting && (sleeping || weakened || paralysis || stunned) )
		src << "<span class='rose'>You can't wake up.</span>"

//Restrained and some debuffs
	else if( restrained() && (paralysis || stunned) )
		src << "<span class='rose'>You can't move.</span>"

//Restrained and lying on optable or simple table
	else if( restrained() && can_operate(src) )	//TO DO: Refactor OpTable code to /bed subtype or "Rest" verb
		src << "<span class='rose'>You can't move.</span>"

//Debuffs check
	else if( paralysis || stunned )
		src << "<span class='rose'>You can't control yourself.</span>"

//Sleep style debuffs
	else if( !resting && (sleeping || weakened) )
		src << "<span class='rose'>You are already sleeping.</span>"

	else
		resting = !resting
		src << "<span class='notice'>You are now [resting ? "resting" : "getting up"].</span>"

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
			if(M.client)
				if(!(M.client.prefs.toggles & SHOW_ANIMATIONS))
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

