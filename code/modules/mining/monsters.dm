/mob/living/simple_animal/hostile/asteroid
	vision_range = 2
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "mining"
	environment_smash = 2
	minbodytemp = 0
	heat_damage_per_tick = 20
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	status_flags = 0
	w_class = SIZE_HUMAN
	var/throw_message = "bounces off of"
	var/icon_aggro = null // for swapping to when we get aggressive
	weather_immunities = list("ash", "acid")

/mob/living/simple_animal/hostile/asteroid/Aggro()
	..()
	icon_state = icon_aggro

/mob/living/simple_animal/hostile/asteroid/LoseAggro()
	..()
	icon_state = icon_living

/mob/living/simple_animal/hostile/asteroid/bullet_act(obj/item/projectile/Proj, def_zone)
	var/signal_val = SEND_SIGNAL(src, COMSIG_MOB_HOSTILE_BEEN_SHOOTED)
	if(signal_val & PROJECTILE_FORCE_MISS)
		return mance()
	return ..()

/mob/living/simple_animal/hostile/proc/mance()
	if(isliving(target))
		step(src, turn(get_dir(src.loc, target.loc), pick(45, -45, 90, -90))) // moving to the side from target
	return PROJECTILE_FORCE_MISS

/mob/living/simple_animal/hostile/asteroid/hitby(atom/movable/AM, datum/thrownthing/throwingdatum) //No floor tiling them to death, wiseguy
	if(isitem(AM))
		var/obj/item/T = AM
		if(!stat)
			Aggro()
		if(T.throwforce <= 20)
			visible_message("<span class='notice'>The [T.name] [src.throw_message] [src.name]!</span>")
			return
	..()

////////////////////////////////////////////////////////////////


////////////////Basilisk////////////////

/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
	desc = "A territorial beast, covered in a thick shell that absorbs energy. Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/monsters.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	projectiletype = /obj/item/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = TRUE
	ranged_message = "stares"
	ranged_cooldown_cap = 20
	throw_message = "does nothing against the hard shell of"
	vision_range = 2
	speed = 3
	maxHealth = 200
	health = 200
	damage_resistance_percent = 35
	melee_damage = 12
	attacktext = "gnaw"
	attack_sound = list('sound/weapons/bladeslice.ogg')
	ranged_cooldown_cap = 4
	aggro_vision_range = 9
	idle_vision_range = 2
	loot_list = list(/obj/item/weapon/ore/diamond = 5)

/obj/item/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	step_delay = 1.5 // give chance to evade
	flag = "energy"
	temperature = 50
	proj_impact_sound = 'sound/effects/projectiles_acts/freezing.ogg'

/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(new_target)
	target = new_target
	if(target != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
		if(isliving(target))
			var/mob/living/L = target
			if(L.bodytemperature > 261)
				L.bodytemperature = 261
				visible_message("<span class='danger'>The [src.name]'s stare chills [L.name] to the bone!</span>")

/mob/living/simple_animal/hostile/asteroid/basilisk/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
		if(EXPLODE_HEAVY)
			adjustBruteLoss(maxHealth * 0.8)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(maxHealth * 0.4)

////////////Drone(miniBoss)/////////////

/mob/living/simple_animal/hostile/retaliate/malf_drone/mining
	health = 320
	maxHealth = 320
	faction = "mining"
	w_class = SIZE_HUMAN
	projectiletype = /obj/item/projectile/beam/xray


////////////////Goldgrub////////////////

/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/monsters.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	vision_range = 5
	aggro_vision_range = 9
	idle_vision_range = 5
	loot_list = list(/obj/item/goldgrub_core = 1)
	move_to_delay = 2
	friendly = "harmlessly rolls into"
	maxHealth = 60
	health = 60
	damage_resistance_percent = 50
	w_class = SIZE_MASSIVE
	attacktext = "barrell"
	a_intent = INTENT_HELP
	throw_message = "sinks in slowly, before being pushed out of "
	status_flags = CANPUSH
	search_objects = 2

	var/bonus_health_per_ore = 2
	var/chase_time = 4 SECOND
	var/running_away_now = FALSE

/mob/living/simple_animal/hostile/asteroid/goldgrub/atom_init()
	. = ..()
	wanted_objects = subtypesof(/obj/item/weapon/ore)

/mob/living/simple_animal/hostile/asteroid/goldgrub/MobBump(mob/living/L)
	if(ishuman(L))
		L.Weaken(3)
		L.take_overall_damage(5 + sqrt(maxHealth), 0)

/mob/living/simple_animal/hostile/asteroid/goldgrub/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
		if(EXPLODE_HEAVY)
			adjustBruteLoss(maxHealth * 0.95)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(maxHealth * 0.6)

/mob/living/simple_animal/hostile/asteroid/goldgrub/adjustBruteLoss(damage)
	. = ..()
	if(stat != DEAD)
		start_chase()

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(istype(target, /obj/item/weapon/ore))
		EatFromFloor()
	else if(istype(target, /obj/structure/ore_box))
		EatFromOrebox()
	if(target)
		return ..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/Found(atom/A)
	if(istype(A, /obj/structure/ore_box)) // now we hunting for oreboxeees!
		if(!length(A.contents))
			return FALSE // we don't want to hunt for empty oreboxes
		return TRUE

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatFromOrebox()
	for(var/i in 1 to rand(2, 5))
		if(!length(target.contents))
			LoseTarget() // if orebox is empty
			break

		var/obj/item/weapon/ore/picked_ore = pick(target.contents)
		picked_ore.forceMove(src)
		maxHealth += bonus_health_per_ore // Goldgrub becomes healthier from eating ore
		health += bonus_health_per_ore

	visible_message("<span class='warning'>[src.name] eat ore from orebox!</span>")

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatFromFloor()
	for(var/obj/item/weapon/ore/O in target.loc)
		O.forceMove(src)
		maxHealth += bonus_health_per_ore // Goldgrub becomes healthier from eating ore
		health += bonus_health_per_ore

	visible_message("<span class='notice'>The ore was swallowed whole!</span>")

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/start_chase() // Begin the chase
	Aggro()
	stance = HOSTILE_STANCE_ATTACK
	retreat_distance = 15
	minimum_distance = 15
	if(!running_away_now)
		running_away_now = TRUE
		addtimer(CALLBACK(src, .proc/burrow_check), chase_time)

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/burrow_check()
	if(stat == DEAD)
		return
	
	if(health < maxHealth * 0.4) // if we are badly wounded, we burrow
		var/turftype = get_turf(src)
		if(istype(turftype, /turf/simulated/floor/plating/airless/asteroid))
			var/turf/simulated/floor/plating/airless/asteroid/A = turftype
			A.gets_dug()

		move_to_delay = 20 //stop Goldgrub
		walk(src, 0)
		flick("Goldgrub_borrow", src)
		QDEL_IN(src, 1.5 SECOND)

	else // calm down
		LoseTarget()
		retreat_distance = initial(retreat_distance)
		minimum_distance = initial(minimum_distance)
		search_objects = initial(search_objects)
		running_away_now = FALSE

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Reward()
	visible_message("<span class='danger'>[src] spits up the contents of its stomach before dying!</span>")

	for(var/obj/item/weapon/ore/O in contents)
		O.forceMove(get_turf(src))

/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(obj/item/projectile/P, def_zone)
	visible_message("<span class='danger'>The [P.name] was repelled by [src.name]'s girth!</span>")

/mob/living/simple_animal/hostile/asteroid/goldgrub/death()
	Reward()
	return ..()

/obj/item/goldgrub_core
	name = "Goldgrub core"
	desc = "Магическое ядро жадного и голодного червя."
	icon = 'icons/mob/monsters.dmi'
	icon_state = "Goldgrub_core"

/obj/item/goldgrub_core/attack_self(mob/user)
	playsound(src, 'sound/magic/magic_effect.ogg', VOL_EFFECTS_MASTER)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.flash_eyes()

	visible_message("<span class='notice'>Ядро червя раскалывает породу вокруг и исчезает!</span>")
	for(var/turf/simulated/mineral/M in range(2, get_turf(user)))
		M.GetDrilled(mineral_drop_koef = 3)

	qdel(src)

/obj/item/goldgrub_core/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(istype(target, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = target
		P.mineral_multiply_koef += 0.25
		to_chat(user, "<span class='info'>Вы внедрили ядро червя в [target]!</span>")
		qdel(src)

////////////////Hivelord////////////////

/mob/living/simple_animal/hostile/asteroid/hivelord
	name = "hivelord"
	desc = "A truly alien creature, it is a mass of unknown organic material, constantly fluctuating. When attacking, pieces of it split off and attack in tandem with the original."
	icon = 'icons/mob/monsters.dmi'
	icon_state = "Hivelord"
	icon_living = "Hivelord"
	icon_aggro = "Hivelord_alert"
	icon_dead = "Hivelord_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_to_delay = 14
	ranged = TRUE
	vision_range = 5
	aggro_vision_range = 9
	idle_vision_range = 5
	speed = 3
	maxHealth = 75
	health = 75
	damage_resistance_percent = 50
	melee_damage = 0
	attacktext = "lash"
	throw_message = "falls right through the strange body of the"
	ranged_cooldown = 0
	ranged_cooldown_cap = 0
	environment_smash = 0
	retreat_distance = 3
	minimum_distance = 3
	pass_flags = PASSTABLE
	w_class = SIZE_LARGE

/mob/living/simple_animal/hostile/asteroid/hivelord/OpenFire(the_target)
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/A = new /mob/living/simple_animal/hostile/asteroid/hivelordbrood(src.loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/asteroid/hivelord/AttackingTarget()
	OpenFire()

/mob/living/simple_animal/hostile/asteroid/hivelord/death(gibbed)
	mouse_opacity = MOUSE_OPACITY_ICON
	..()
	var/obj/item/asteroid/hivelord_core/core = new /obj/item/asteroid/hivelord_core(loc)
	core.corpse = src
	loc = core  //put dead hivelord in droped core

/obj/item/asteroid/hivelord_core
	name = "hivelord core"
	desc = "All that remains of a hivelord, it seems to be what allows it to break pieces of itself off without being hurt... its healing properties will soon become inert if not used quickly."
	icon = 'icons/mob/monsters.dmi'
	icon_state = "Hivelod_core"
	var/inert = FALSE
	var/mob/living/simple_animal/hostile/asteroid/hivelord/corpse

/obj/item/asteroid/hivelord_core/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/lazarus_injector))
		var/obj/item/weapon/lazarus_injector/L = I
		if(L.loaded)
			if(!corpse)
				corpse = new /mob/living/simple_animal/hostile/asteroid/hivelord(src)
				corpse.death()
				var/obj/item/asteroid/hivelord_core/C = corpse.loc
				C.corpse = null
			corpse.loc = get_turf(loc)
			L.revive(corpse, user)
			corpse = null
			qdel(src)
	else
		return ..()

/obj/item/asteroid/hivelord_core/Destroy()
	QDEL_NULL(corpse)
	return ..()

/obj/item/asteroid/hivelord_core/atom_init()
	. = ..()
	addtimer(CALLBACK(src, .proc/make_inert), 2 MINUTES)

/obj/item/asteroid/hivelord_core/proc/make_inert()
	inert = TRUE
	desc = "The remains of a hivelord that have become useless, having been left alone too long after being harvested."
	icon_state = "Hivelord_dead"

/obj/item/asteroid/hivelord_core/attack(mob/living/M, mob/living/user)
	if(inert)
		to_chat(user, "<span class='notice'>[src] have become inert, its healing properties are no more.</span>")
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.stat == DEAD)
			to_chat(user, "<span class='notice'>[src] are useless on the dead.</span>")
			return
		if(H != user)
			H.visible_message("[user] forces [H] to apply [src]... they quickly regenerate all injuries!")
		else
			to_chat(user, "<span class='notice'>You start to smear [src] on yourself. It feels and smells disgusting, but you feel amazingly refreshed in mere moments.</span>")
		H.revive()
		qdel(src)
	return ..()


////////////////Hivelordbrood////////////////

/mob/living/simple_animal/hostile/asteroid/hivelordbrood
	name = "hivelord brood"
	desc = "A fragment of the original Hivelord, rallying behind its original. One isn't much of a threat, but..."
	icon = 'icons/mob/monsters.dmi'
	icon_state = "Hivelordbrood"
	icon_living = "Hivelordbrood"
	icon_aggro = "Hivelordbrood"
	icon_dead = "Hivelordbrood"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_to_delay = 0
	friendly = "buzzes near"
	vision_range = 10
	speed = 3
	maxHealth = 1
	health = 1
	damage_resistance_percent = 50
	melee_damage = 2
	attacktext = "slash"
	throw_message = "falls right through the strange body of the"
	environment_smash = 0
	pass_flags = PASSTABLE

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/atom_init_late()
	QDEL_IN(src, 10 SECONDS)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/death()
	qdel(src)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/gen_modifiers(special_prob = 30, min_mod_am = 1, max_mod_am = 3, min_rarity_cost = 2, max_rarity_cost = 6)
	return

////////////////Goliath////////////////

/mob/living/simple_animal/hostile/asteroid/goliath
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/monsters.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
	attack_sound = list('sound/weapons/punch4.ogg')
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_to_delay = 37
	ranged = TRUE
	ranged_cooldown = 2 //By default, start the Goliath with his cooldown off so that people can run away quickly on first sight
	ranged_cooldown_cap = 8
	friendly = "wails at"
	vision_range = 4
	loot_list = list(/obj/item/asteroid/goliath_hide = 1)
	speed = 2
	maxHealth = 300
	health = 300
	damage_resistance_percent = 10
	melee_damage = 25
	w_class = SIZE_MASSIVE
	attacktext = "pulveriz"
	throw_message = "does nothing to the rocky hide of the"
	aggro_vision_range = 9
	idle_vision_range = 5
	var/pre_attack = 0

/mob/living/simple_animal/hostile/asteroid/goliath/Life()
	..()
	handle_preattack()

/mob/living/simple_animal/hostile/asteroid/goliath/proc/handle_preattack()
	if(ranged_cooldown <= 2 && !pre_attack)
		pre_attack++
	if(!pre_attack || incapacitated() || stance == HOSTILE_STANCE_IDLE)
		return
	icon_state = "Goliath_preattack"

/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire()
	var/tturf = get_turf(target)
	if(get_dist(src, target) <= 7)//Screen range check, so you can't get tentacle'd offscreen
		visible_message("<span class='warning'>The [src.name] digs its tentacles under [target.name]!</span>")
		new /obj/effect/goliath_tentacle/original(tturf, melee_damage)
		ranged_cooldown = ranged_cooldown_cap
		icon_state = icon_aggro
		pre_attack = 0

/mob/living/simple_animal/hostile/asteroid/goliath/attackby(obj/item/O, mob/user)
	if(stat != DEAD && prob(50))
		new /obj/effect/goliath_tentacle(get_turf(user), melee_damage / 2)
	return ..()

/mob/living/simple_animal/hostile/asteroid/goliath/adjustBruteLoss(damage)
	ranged_cooldown--
	handle_preattack()
	..()

/mob/living/simple_animal/hostile/asteroid/goliath/Aggro()
	vision_range = aggro_vision_range
	handle_preattack()
	if(icon_state != icon_aggro)
		icon_state = icon_aggro

/obj/effect/goliath_tentacle
	name = "Goliath tentacle"
	icon = 'icons/mob/monsters.dmi'
	icon_state = "Goliath_tentacle"
	var/strength
	anchored = TRUE

/obj/effect/goliath_tentacle/atom_init(mapload, mob_damage)
	. = ..()
	strength = mob_damage
	var/turftype = get_turf(src)
	if(istype(turftype, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = turftype
		M.GetDrilled()
	if(istype(turftype, /turf/simulated/floor/plating/airless/asteroid))
		var/turf/simulated/floor/plating/airless/asteroid/A = turftype
		A.gets_dug()
	addtimer(CALLBACK(src, .proc/Trip), 1.7 SECOND)

/obj/effect/goliath_tentacle/original

/obj/effect/goliath_tentacle/original/atom_init()
	. = ..()
	var/list/directions = cardinal.Copy()
	for (var/i in 1 to 3)
		var/spawndir = pick(directions)
		directions -= spawndir
		var/turf/T = get_step(src, spawndir)
		new /obj/effect/goliath_tentacle(T, strength)

/obj/effect/goliath_tentacle/proc/Trip()
	for(var/mob/living/M in src.loc)
		visible_message("<span class='warning'>The [src.name] knocks [M.name] down!</span>")
		playsound(M, 'sound/misc/goliath_tentacle_hit.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
		M.Weaken(strength * 0.1)
		M.adjustBruteLoss(strength * 0.4) // 40% pure damage of Goliath force
	qdel(src)

/obj/effect/goliath_tentacle/Crossed(atom/movable/AM)
	if(isliving(AM))
		Trip()
		return
	return ..()

/obj/item/asteroid/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_hide"
	flags = NOBLUDGEON
	w_class = SIZE_SMALL
	layer = 4

/obj/item/asteroid/goliath_hide/attack(mob/living/M, mob/living/user, proximity)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H.wear_suit, /obj/item/clothing/suit/space))
			var/obj/item/clothing/suit/space/C = H.wear_suit
			return afterattack(C, user, proximity)

/obj/item/asteroid/goliath_hide/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(istype(target, /obj/item/clothing/suit/space) || istype(target, /obj/item/clothing/head/helmet/space))
		var/obj/item/clothing/C = target
		var/list/current_armor = C.armor
		if(current_armor["melee"] < 80)
			current_armor["melee"] = min(current_armor["melee"] + 10, 80)
			if(istype(C, /obj/item/clothing/suit/space))
				var/obj/item/clothing/suit/space/S = C
				S.breach_threshold = min(S.breach_threshold + 2, 24)
				S.repair_breaches(BRUTE, 8, user)
			to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You can't improve [C] any further!</span>")
			return

	if(istype(target, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/D = target
		var/list/damage_absorption = D.damage_absorption
		if(D.hides < 3)
			D.hides++
			damage_absorption["brute"] = max(damage_absorption["brute"] - 0.1, 0.3)
			damage_absorption["bullet"] = damage_absorption["bullet"] - 0.05
			damage_absorption["fire"] = damage_absorption["fire"] - 0.05
			damage_absorption["laser"] = damage_absorption["laser"] - 0.025
			to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
			D.update_icon()
			if(D.hides == 3)
				D.desc = "Autonomous Power Loader Unit. It's wearing a fearsome carapace entirely composed of goliath hide plates - its pilot must be an experienced monster hunter."
			else
				D.desc = "Autonomous Power Loader Unit. Its armour is enhanced with some goliath hide plates."
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You can't improve [D] any further!</span>")
