/**********************Mineral deposits**************************/



/turf/simulated/mineral //wall piece
	name = "Rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock_nochance"
	oxygen = 0
	nitrogen = 0
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = TCMB
	var/mineral/mineral
	var/mined_ore = 0
	var/last_act = 0

	var/datum/geosample/geologic_data
	var/excavation_level = 0
	var/list/finds
	var/next_rock = 0
	var/archaeo_overlay = ""
	var/excav_overlay = ""
	var/obj/item/weapon/last_find
	var/datum/artifact_find/artifact_find

	var/ore_amount = 0

	has_resources = 1

/turf/simulated/mineral/New()
	icon_state = "rock"
	. = ..()

	MineralSpread()

	spawn(1)
		var/turf/T
		if((istype(get_step(src, NORTH), /turf/simulated/floor)) || (istype(get_step(src, NORTH), /turf/space)) || (istype(get_step(src, NORTH), /turf/simulated/shuttle/floor)))
			T = get_step(src, NORTH)
			if (T)
				var/image/I = image('icons/turf/walls.dmi', "rock_side_s", layer=6)
				I.plane = 6
				T.overlays += I
		if((istype(get_step(src, SOUTH), /turf/simulated/floor)) || (istype(get_step(src, SOUTH), /turf/space)) || (istype(get_step(src, SOUTH), /turf/simulated/shuttle/floor)))
			T = get_step(src, SOUTH)
			if (T)
				var/image/I = image('icons/turf/walls.dmi', "rock_side_n", layer=6)
				I.plane = 6
				T.overlays += I
		if((istype(get_step(src, EAST), /turf/simulated/floor)) || (istype(get_step(src, EAST), /turf/space)) || (istype(get_step(src, EAST), /turf/simulated/shuttle/floor)))
			T = get_step(src, EAST)
			if (T)
				var/image/I = image('icons/turf/walls.dmi', "rock_side_w", layer=6)
				I.plane = 6
				T.overlays += I
		if((istype(get_step(src, WEST), /turf/simulated/floor)) || (istype(get_step(src, WEST), /turf/space)) || (istype(get_step(src, WEST), /turf/simulated/shuttle/floor)))
			T = get_step(src, WEST)
			if (T)
				var/image/I = image('icons/turf/walls.dmi', "rock_side_e", layer=6)
				I.plane = 6
				T.overlays += I


/turf/simulated/mineral/ex_act(severity)
	switch(severity)
		if(2.0)
			if (prob(70))
				mined_ore = 1 //some of the stuff gets blown up
				GetDrilled()
		if(1.0)
			mined_ore = 2 //some of the stuff gets blown up
			GetDrilled()


/turf/simulated/mineral/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/weapon/pickaxe)) && (!H.hand))
			if(istype(H.l_hand,/obj/item/weapon/pickaxe/drill))
				var/obj/item/weapon/pickaxe/drill/D = H.l_hand
				if(!D.mode)
					return
			attackby(H.l_hand,H)
		else if((istype(H.r_hand,/obj/item/weapon/pickaxe)) && H.hand)
			if(istype(H.r_hand,/obj/item/weapon/pickaxe/drill))
				var/obj/item/weapon/pickaxe/drill/D = H.r_hand
				if(!D.mode)
					return
			attackby(H.r_hand,H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/weapon/pickaxe))
			attackby(R.module_active,R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)


/turf/simulated/mineral/proc/MineralSpread()
	if(mineral && mineral.spread)
		for(var/trydir in cardinal)
			if(prob(mineral.spread_chance))
				var/turf/simulated/mineral/random/target_turf = get_step(src, trydir)
				if(istype(target_turf) && !target_turf.mineral)
					target_turf.mineral = mineral
					target_turf.UpdateMineral()
					target_turf.MineralSpread()

/turf/simulated/mineral/proc/UpdateMineral()
	if(!mineral)
		name = "\improper Rock"
		icon_state = "rock"
		return
	else
		if(prob(15))
			ore_amount = rand(6,9)
		else if(prob(45))
			ore_amount = rand(4,6)
		else
			ore_amount = rand(3,5)
	if(ore_amount >= 8)
		name = "\improper [mineral.display_name] rich deposit"
		overlays.Cut()
		overlays += "rock_[mineral.name]"
	else
		name = "\improper Rock"
		icon_state = "rock"
		return

/turf/simulated/mineral/proc/CaveSpread()	//Integration of cave system
	if(mineral)
		for(var/trydir in cardinal)
			var/turf/simulated/mineral/random/target_turf = get_step(src, trydir)
			if(istype(target_turf, /turf/simulated/mineral/random/caves))
				if(prob(2))
					new/turf/simulated/floor/plating/airless/asteroid/cave(src)

//Not even going to touch this pile of spaghetti
/turf/simulated/mineral/attackby(obj/item/weapon/W, mob/user)

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(usr, "<span class='danger'>You don't have the dexterity to do this!</span>")
		return

	if (istype(W, /obj/item/device/core_sampler))
		geologic_data.UpdateNearbyArtifactInfo(src)
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
		return

	if (istype(W, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = W
		C.scan_atom(user, src)
		return

	if (istype(W, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = W
		user.visible_message("<span class='notice'>[user] extends [P] towards [src].</span>","<span class='notice'>You extend [P] towards [src].</span>")
		if(do_after(user,25, target = src))
			to_chat(user, "<span class='notice'>[bicon(P)] [src] has been excavated to a depth of [2*excavation_level]cm.</span>")
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		var/obj/item/weapon/pickaxe/P = W
		if(last_act + P.digspeed > world.time)//prevents message spam
			return
		last_act = world.time

		if(istype(P, /obj/item/weapon/pickaxe/drill))
			var/obj/item/weapon/pickaxe/drill/D = P
			if(!(istype(D, /obj/item/weapon/pickaxe/drill/borgdrill) || istype(D, /obj/item/weapon/pickaxe/drill/jackhammer)))	//borgdrill & jackhammer can't lose energy and crit fail
				if(D.state)
					to_chat(user, "<span class='danger'>[D] is not ready!</span>")
					return
				if(!D.power_supply || !D.power_supply.use(D.drill_cost))
					to_chat(user, "<span class='danger'>No power!</span>")
					return
				if(D.mode)
					if(mineral)
						mined_ore = mineral.ore_loss
				D.power_supply.use(D.drill_cost)

		playsound(user, P.drill_sound, 70, 0)

		//handle any archaeological finds we might uncover
		var/fail_message
		if(finds && finds.len)
			var/datum/find/F = finds[1]
			if(excavation_level + P.excavation_amount > F.excavation_required)
				//Chance to destroy / extract any finds here
				fail_message = ", <b>[pick("there is a crunching noise","[W] collides with some different rock","part of the rock face crumbles away","something breaks under [W]")]</b>"

		to_chat(user, "<span class='warning'>You start [P.drill_verb][fail_message ? fail_message : ""].</span>")

		if(fail_message && prob(90))
			if(prob(25))
				excavate_find(5, finds[1])
			else if(prob(50))
				finds.Remove(finds[1])
				if(prob(50))
					artifact_debris()

		if(do_after(user,P.digspeed, target = src))
			to_chat(user, "<span class='notice'>You finish [P.drill_verb] the rock.</span>")

			if(istype(P,/obj/item/weapon/pickaxe/drill/jackhammer))	//Jackhammer will just dig 3 tiles in dir of user
				for(var/turf/simulated/mineral/M in range(user,1))
					if(get_dir(user,M) & user.dir)
						M.GetDrilled()
				return

			if(finds && finds.len)
				var/datum/find/F = finds[1]
				if(round(excavation_level + P.excavation_amount) == F.excavation_required)
					//Chance to extract any items here perfectly, otherwise just pull them out along with the rock surrounding them
					if(excavation_level + P.excavation_amount > F.excavation_required)
						//if you can get slightly over, perfect extraction
						excavate_find(100, F)
					else
						excavate_find(80, F)

				else if(excavation_level + P.excavation_amount > F.excavation_required - F.clearance_range)
					//just pull the surrounding rock out
					excavate_find(0, F)

			if( excavation_level + P.excavation_amount >= 100 )
				//if players have been excavating this turf, leave some rocky debris behind
				var/obj/structure/boulder/B
				if(artifact_find)
					if( excavation_level > 0 || prob(15) )
						//boulder with an artifact inside
						B = new(src)
						if(artifact_find)
							B.artifact_find = artifact_find
					else
						artifact_debris(1)
				else if(prob(15))
					//empty boulder
					B = new(src)

				if(B)
					GetDrilled(0)
				else
					GetDrilled(1)
				return

			excavation_level += P.excavation_amount

			//archaeo overlays
			if(!archaeo_overlay && finds && finds.len)
				var/datum/find/F = finds[1]
				if(F.excavation_required <= excavation_level + F.view_range)
					archaeo_overlay = "overlay_archaeo[rand(1,3)]"
					overlays += archaeo_overlay

			//there's got to be a better way to do this
			var/update_excav_overlay = 0
			if(excavation_level >= 75)
				if(excavation_level - P.excavation_amount < 75)
					update_excav_overlay = 1
			else if(excavation_level >= 50)
				if(excavation_level - P.excavation_amount < 50)
					update_excav_overlay = 1
			else if(excavation_level >= 25)
				if(excavation_level - P.excavation_amount < 25)
					update_excav_overlay = 1

			//update overlays displaying excavation level
			if( !(excav_overlay && excavation_level > 0) || update_excav_overlay )
				var/excav_quadrant = round(excavation_level / 25) + 1
				excav_overlay = "overlay_excv[excav_quadrant]_[rand(1,3)]"
				overlays += excav_overlay

			/* Nope.
			//extract pesky minerals while we're excavating
			while(excavation_minerals.len && excavation_level > excavation_minerals[excavation_minerals.len])
				DropMineral()
				pop(excavation_minerals)
				mineralAmt-- */

			//drop some rocks
			next_rock += P.excavation_amount * 10
			while(next_rock > 100)
				next_rock -= 100
				var/obj/item/weapon/ore/O = new(src)
				geologic_data.UpdateNearbyArtifactInfo(src)
				O.geologic_data = geologic_data

	else
		return attack_hand(user)


/turf/simulated/mineral/proc/DropMineral()
	if(!mineral)
		return

	var/obj/item/weapon/ore/O = new mineral.ore (src)
	if(istype(O))
		geologic_data.UpdateNearbyArtifactInfo(src)
		O.geologic_data = geologic_data
	return O


/turf/simulated/mineral/proc/GetDrilled(artifact_fail = 0)
	//var/destroyed = 0 //used for breaking strange rocks
	if (mineral && ore_amount)

		//if the turf has already been excavated, some of it's ore has been removed
		for (var/i = 1 to ore_amount - mined_ore)
			DropMineral()

	//destroyed artifacts have weird, unpleasant effects
	//make sure to destroy them before changing the turf though
	if(artifact_find && artifact_fail)
		var/pain = 0
		if(prob(50))
			pain = 1
		for(var/mob/living/M in range(src, 200))
			to_chat(M, "<span class='danger'>[pick("A high pitched [pick("keening","wailing","whistle")]","A rumbling noise like [pick("thunder","heavy machinery")]")] somehow penetrates your mind before fading away!</span>")
			if(pain)
				flick("pain",M.pain)
				if(prob(50))
					M.adjustBruteLoss(5)
			else
				M.flash_eyes()
				if(prob(50))
					M.Stun(5)
			M.apply_effect(25, IRRADIATE)

	var/turf/simulated/floor/plating/airless/asteroid/N = ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
	N.fullUpdateMineralOverlays()

	if(rand(1,500) == 1)
		visible_message("<span class='notice'>An old dusty crate was buried within!</span>")
		new /obj/structure/closet/crate/secure/loot(src)

/turf/simulated/mineral/proc/excavate_find(prob_clean = 0, datum/find/F)
	//with skill and luck, players can cleanly extract finds
	//otherwise, they come out inside a chunk of rock
	var/obj/item/weapon/W
	if(prob_clean)
		W = new /obj/item/weapon/archaeological_find(src, new_item_type = F.find_type)
	else
		W = new /obj/item/weapon/ore/strangerock(src, inside_item_type = F.find_type)
		geologic_data.UpdateNearbyArtifactInfo(src)
		W:geologic_data = geologic_data

	//some find types delete the /obj/item/weapon/archaeological_find and replace it with something else, this handles when that happens
	//yuck
	var/display_name = "something"
	if(!W)
		W = last_find
	if(W)
		display_name = W.name

	//many finds are ancient and thus very delicate - luckily there is a specialised energy suspension field which protects them when they're being extracted
	if(prob(F.prob_delicate))
		var/obj/effect/suspension_field/S = locate() in src
		if(!S || S.field_type != get_responsive_reagent(F.find_type))
			if(W)
				visible_message("<span class='danger'>[pick("[display_name] crumbles away into dust","[display_name] breaks apart")].</span>")
				qdel(W)

	finds.Remove(F)


/turf/simulated/mineral/proc/artifact_debris(severity = 0)
	//cael's patented random limited drop componentized loot system!
	//sky's patented not-fucking-retarded overhaul!

	//Give a random amount of loot from 1 to 3 or 5, varying on severity.
	for(var/j in 1 to rand(1, 3 + max(min(severity, 1), 0) * 2))
		switch(rand(1,7))
			if(1)
				var/obj/item/stack/rods/R = new(src)
				R.amount = rand(5,25)

			if(2)
				var/obj/item/stack/tile/R = new(src)
				R.amount = rand(1,5)

			if(3)
				var/obj/item/stack/sheet/metal/R = new(src)
				R.amount = rand(5,25)

			if(4)
				var/obj/item/stack/sheet/plasteel/R = new(src)
				R.amount = rand(5,25)

			if(5)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					new /obj/item/weapon/shard(src)

			if(6)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					new /obj/item/weapon/shard/phoron(src)

			if(7)
				var/obj/item/stack/sheet/mineral/uranium/R = new(src)
				R.amount = rand(5,25)

/turf/simulated/mineral/random
	name = "Mineral deposit"
	icon_state = "rock"

	var/mineralSpawnChanceList = list("Uranium" = 10, "Platinum" = 10, "Iron" = 20, "Coal" = 15, "Diamond" = 5, "Gold" = 15, "Silver" = 15, "Phoron" = 25,)
	var/mineralChance = 10  //means 10% chance of this plot changing to a mineral deposit

/turf/simulated/mineral/random/New()
	if (prob(mineralChance) && !mineral)
		var/mineral_name = pickweight(mineralSpawnChanceList) //temp mineral name

		if(!name_to_mineral)
			SetupMinerals()

		if (mineral_name && mineral_name in name_to_mineral)
			mineral = name_to_mineral[mineral_name]
			UpdateMineral()
			CaveSpread()

	. = ..()

/turf/simulated/mineral/random/caves
	mineralChance = 25

/turf/simulated/mineral/random/caves/New()
	..()

/turf/simulated/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 40
	mineralSpawnChanceList = list("Uranium" = 35, "Platinum" = 45, "Diamond" = 30, "Gold" = 45, "Silver" = 50, "Phoron" = 50)

/turf/simulated/mineral/random/high_chance/New()
	icon_state = "rock"
	..()

/turf/simulated/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 5
	mineralSpawnChanceList = list("Uranium" = 1, "Platinum" = 1, "Iron" = 50, "Coal" = 20, "Diamond" = 1, "Gold" = 1, "Silver" = 1, "Phoron" = 1)

/turf/simulated/mineral/random/low_chance/New()
	icon_state = "rock"
	..()

/turf/simulated/mineral/random/labormineral
	mineralSpawnChanceList = list("Uranium" = 1, "Platinum" = 1, "Iron" = 60, "Coal" = 30, "Diamond" = 1, "Gold" = 1, "Silver" = 1, "Phoron" = 2)
	icon_state = "rock_labor"

/turf/simulated/mineral/random/labormineral/New()
	icon_state = "rock"
	..()

/turf/simulated/mineral/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash >= 2)
		GetDrilled()
	..()

/**********************Caves**************************/


/turf/simulated/floor/plating/airless/asteroid/cave
	var/length = 20
	var/mob_spawn_list = list("Goldgrub" = 4, "Goliath" = 10, "Basilisk" = 8, "Hivelord" = 6, "Drone" = 2)
	var/sanity = 1

/turf/simulated/floor/plating/airless/asteroid/cave/New(loc, var/length, var/go_backwards = 1, var/exclude_dir = -1)

	// If length (arg2) isn't defined, get a random length; otherwise assign our length to the length arg.
	if(!length)
		src.length = rand(25, 50)
	else
		src.length = length

	// Get our directiosn
	var/forward_cave_dir = pick(alldirs - exclude_dir)
	// Get the opposite direction of our facing direction
	var/backward_cave_dir = angle2dir(dir2angle(forward_cave_dir) + 180)

	// Make our tunnels
	make_tunnel(forward_cave_dir)
	if(go_backwards)
		make_tunnel(backward_cave_dir)
	// Kill ourselves by replacing ourselves with a normal floor.
	SpawnFloor(src)
	..()

/turf/simulated/floor/plating/airless/asteroid/cave/proc/make_tunnel(dir)

	var/turf/simulated/mineral/tunnel = src
	var/next_angle = pick(45, -45)

	for(var/i = 0; i < length; i++)
		if(!sanity)
			break

		var/list/L = list(45)
		if(IsOdd(dir2angle(dir))) // We're going at an angle and we want thick angled tunnels.
			L += -45

		// Expand the edges of our tunnel
		for(var/edge_angle in L)
			var/turf/simulated/mineral/edge = get_step(tunnel, angle2dir(dir2angle(dir) + edge_angle))
			if(istype(edge))
				SpawnFloor(edge)

		// Move our tunnel forward
		tunnel = get_step(tunnel, dir)

		if(istype(tunnel))
			// Small chance to have forks in our tunnel; otherwise dig our tunnel.
			if(i > 3 && prob(20))
				new src.type(tunnel, rand(10, 15), 0, dir)
			else
				SpawnFloor(tunnel)
		else //if(!istype(tunnel, src.parent)) // We hit space/normal/wall, stop our tunnel.
			break

		// Chance to change our direction left or right.
		if(i > 2 && prob(33))
			// We can't go a full loop though
			next_angle = -next_angle
			dir = angle2dir(dir2angle(dir) + next_angle)


/turf/simulated/floor/plating/airless/asteroid/cave/proc/SpawnFloor(turf/T)
	for(var/turf/S in range(2,T))
		if(istype(S, /turf/space) || istype(S.loc, /area/mine/explored))
			sanity = 0
			break
	if(!sanity)
		return

	SpawnMonster(T)
	var/turf/simulated/floor/plating/airless/asteroid/t = new /turf/simulated/floor/plating/airless/asteroid(T)
	spawn(2)
		t.fullUpdateMineralOverlays()

/turf/simulated/floor/plating/airless/asteroid/cave/proc/SpawnMonster(turf/T)
	if(prob(30))
		if(istype(loc, /area/mine/explored))
			return
		for(var/atom/A in range(15,T))//Lowers chance of mob clumps
			if(istype(A, /mob/living/simple_animal/hostile/asteroid))
				return
		var/randumb = pickweight(mob_spawn_list)
		switch(randumb)
			if("Goliath")
				new /mob/living/simple_animal/hostile/asteroid/goliath(T)
			if("Goldgrub")
				new /mob/living/simple_animal/hostile/asteroid/goldgrub(T)
			if("Basilisk")
				new /mob/living/simple_animal/hostile/asteroid/basilisk(T)
			if("Hivelord")
				new /mob/living/simple_animal/hostile/asteroid/hivelord(T)
			if("Drone")
				new /mob/living/simple_animal/hostile/retaliate/malf_drone/mining(T)
		if(prob(20))
		 new /obj/machinery/artifact/bluespace_crystal(T)
	return

/**********************Asteroid**************************/


/turf/simulated/floor/plating/airless/asteroid //floor piece
	name = "Asteroid"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	icon_plating = "asteroid"
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug
	has_resources = 1

/turf/simulated/floor/plating/airless/asteroid/New()
	var/proper_name = name
	..()
	name = proper_name
	//if (prob(50))
	//	seedName = pick(list("1","2","3","4"))
	//	seedAmt = rand(1,4)
	if(prob(20))
		icon_state = "asteroid[rand(0,12)]"
	spawn(2)
		updateMineralOverlays()

/turf/simulated/floor/plating/airless/asteroid/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				gets_dug()
		if(1.0)
			gets_dug()
	return

/turf/simulated/floor/plating/airless/asteroid/attackby(obj/item/weapon/W, mob/user)

	if(!W || !user)
		return 0

	if ((istype(W, /obj/item/weapon/shovel)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			to_chat(user, "<span class='danger'>This area has already been dug.</span>")
			return

		to_chat(user, "<span class='warning'>You start digging.</span>")
		playsound(user.loc, 'sound/effects/digging.ogg', 50, 1)

		if(do_after(user,40,target = src))
			if((user.loc == T && user.get_active_hand() == W))
				to_chat(user, "<span class='notice'>You dug a hole.</span>")
				gets_dug()

	if(istype(W,/obj/item/weapon/storage/bag/ore))
		var/obj/item/weapon/storage/bag/ore/S = W
		if(S.collection_mode)
			for(var/obj/item/weapon/ore/O in contents)
				O.attackby(W,user)
				return
	else if(istype(W,/obj/item/weapon/storage/bag/fossils))
		var/obj/item/weapon/storage/bag/fossils/S = W
		if(S.collection_mode)
			for(var/obj/item/weapon/fossil/F in contents)
				F.attackby(W,user)
				return

	else
		..(W,user)
	return

/turf/simulated/floor/plating/airless/asteroid/proc/gets_dug()
	if(dug)
		return
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	dug = 1
	icon_plating = "asteroid_dug"
	icon_state = "asteroid_dug"
	return

/turf/simulated/floor/plating/airless/asteroid/proc/updateMineralOverlays()

	overlays.Cut()

	if(istype(get_step(src, NORTH), /turf/simulated/mineral))
		overlays += image('icons/turf/walls.dmi', "rock_side_n")
	if(istype(get_step(src, SOUTH), /turf/simulated/mineral))
		overlays += image('icons/turf/walls.dmi', "rock_side_s", layer=6)
	if(istype(get_step(src, EAST), /turf/simulated/mineral))
		overlays += image('icons/turf/walls.dmi', "rock_side_e", layer=6)
	if(istype(get_step(src, WEST), /turf/simulated/mineral))
		overlays += image('icons/turf/walls.dmi', "rock_side_w", layer=6)

/turf/simulated/floor/plating/airless/asteroid/proc/fullUpdateMineralOverlays()
	var/turf/simulated/floor/plating/airless/asteroid/A
	if(istype(get_step(src, WEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, WEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, EAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, EAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTH), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTH)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHWEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHEAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHWEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHEAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTH), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTH)
		A.updateMineralOverlays()
	updateMineralOverlays()



/turf/simulated/floor/plating/airless/asteroid/Entered(atom/movable/M as mob|obj)
	..()
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(istype(R.module, /obj/item/weapon/robot_module/miner))
			if(istype(R.module_state_1,/obj/item/weapon/storage/bag/ore))
				attackby(R.module_state_1,R)
			else if(istype(R.module_state_2,/obj/item/weapon/storage/bag/ore))
				attackby(R.module_state_2,R)
			else if(istype(R.module_state_3,/obj/item/weapon/storage/bag/ore))
				attackby(R.module_state_3,R)
			else
				return
