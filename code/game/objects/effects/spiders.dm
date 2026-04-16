//generic procs copied from obj/effect/alien
/obj/structure/spider
	name = "web"
	desc = "It's stringy and sticky."
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	density = FALSE
	max_integrity = 15
	resistance_flags = CAN_BE_HIT

/obj/structure/spider/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)//the stickiness of the web mutes all attack sounds except fire damage type
		playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/spider/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, FIRE)

/obj/structure/spider/stickyweb
	icon_state = "stickyweb1"
	var/passage_mult = 1
	var/passage_mult_proj = 1

/obj/structure/spider/stickyweb/atom_init() //A lil hack so we can have special icons on special types
	. = ..()
	if(prob(50) && icon_state == "stickyweb1")
		icon_state = "stickyweb2"

/obj/structure/spider/stickyweb/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover, /mob/living/simple_animal/hostile/giant_spider))
		return TRUE
	else if(isliving(mover))
		if(mover.pulledby && istype(mover.pulledby, /mob/living/simple_animal/hostile/giant_spider))
			return TRUE
		if(!prob(50 * passage_mult))
			to_chat(mover, "<span class='warning'>You get stuck in \the [src] for a moment.</span>")
			return FALSE
	else if(istype(mover, /obj/item/projectile))
		return prob(30 * passage_mult_proj)
	return TRUE

/obj/structure/spider/stickyweb/sticky
	name = "sticky web"
	desc = "Extremely soft and sticky silk."
	icon_state = "verystickyweb"
	max_integrity = 20
	passage_mult = 0
	passage_mult_proj = 2

/obj/structure/spider/stickyweb/sealed
	name = "sealed web"
	desc = "A solid thick wall of web, airtight enough to block air flow."
	icon_state = "sealedweb"
	can_block_air = TRUE
	passage_mult = 0.7
	max_integrity = 50
	passage_mult_proj = 0.5

/obj/structure/spider/stickyweb/solid
	name = "solid web"
	desc = "A solid wall of web, thick enough to block air flow."
	icon_state = "solidweb"
	can_block_air = TRUE
	opacity = TRUE
	max_integrity = 90
	resistance_flags = FIRE_PROOF
	passage_mult = 0.4
	passage_mult_proj = 0

/obj/structure/spider/spikes
	name = "web spikes"
	desc = "Silk hardened into small yet deadly spikes."
	icon_state = "webspikes1"
	max_integrity = 40
	alpha = 30

/obj/structure/spider/spikes/Crossed(atom/movable/AM)
	. = ..()
	if(ismob(AM))
		if(istype(AM, /mob/living/simple_animal/hostile/giant_spider))
			return
		var/mob/M = AM
		to_chat(M, "<span class='warning'><B>You step on the [src]!</B></span>")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.buckled)
				return
			var/obj/item/organ/external/BP = H.bodyparts_by_name[H.crawling ? pick(BP_CHEST , BP_GROIN) : pick(BP_L_LEG , BP_R_LEG)]
			if(BP && !HAS_TRAIT(AM, TRAIT_NO_MINORCUTS) || !HAS_TRAIT(AM, TRAIT_LIGHT_STEP))
				BP.take_damage(10, 0)
			H.updatehealth()
		M.Stun(1, TRUE)
		M.Weaken(3)
	else
		if(istype(AM, /obj/structure/spider/spiderling))
			return
		AM.take_damage(20, BRUTE)

/obj/structure/spider/stickyweb/reflector
	name = "Reflective silk screen"
	icon = 'icons/effects/effects.dmi'
	desc = "Made up of an extremly reflective silk material looking at it hurts."
	icon_state = "reflector"
	max_integrity = 30
	passage_mult = 0.7
	passage_mult_proj = 0
	opacity = TRUE
	var/static/list/reflects = list(/obj/item/projectile/energy, /obj/item/projectile/beam, /obj/item/projectile/pyrometer,
		/obj/item/projectile/plasma, /obj/item/projectile/bullet/stunshot)

/obj/structure/spider/stickyweb/reflector/bullet_act(obj/item/projectile/P, def_zone)
	if(is_type_in_list(P,reflects))
		if(istype(P, /obj/item/projectile/plasma))
			P.damage /= 4
			return ..()
		if(P.starting)
			var/new_x = P.starting.x + pick(0, 0, 0, 0, -1, 1, -2, 2, -3, 3)
			var/new_y = P.starting.y + pick(0, 0, 0, 0, -1, 1, -2, 2, -3, 3)
			var/turf/curloc = get_turf(src)
			P.redirect(new_x, new_y, curloc)
			return PROJECTILE_FORCE_MISS
	return ..()

/obj/structure/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life."
	icon_state = "eggs"
	var/sentient = FALSE
	var/adaptations = list()
	var/amount_grown = 0

/obj/structure/spider/eggcluster/atom_init()
	. = ..()
	pixel_x = rand(3,-3)
	pixel_y = rand(3,-3)
	START_PROCESSING(SSobj, src)

/obj/structure/spider/eggcluster/process()
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		var/num = sentient ? 6 : rand(6,24)
		for(var/i=0, i<num, i++)
			var/obj/structure/spider/spiderling/S = new (loc, sentient)
			S.adaptations = adaptations
			S.sentient = sentient
		qdel(src)

/obj/structure/spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	anchored = FALSE
	layer = 2.7
	max_integrity = 3
	var/sentient = FALSE
	var/adaptations = list()
	var/amount_grown = -1
	var/grow_as = null
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0

/obj/structure/spider/spiderling/atom_init(mapload)
	. = ..()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	START_PROCESSING(SSobj, src)
	//50% chance to grow up
	if(prob(50))
		amount_grown = 1

/obj/structure/spider/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		forceMove(user.loc)
	else
		..()

/obj/structure/spider/spiderling/attack_hand(mob/living/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You touch [src]!</span>")
		return
	playsound(src, pick(SOUNDIN_PUNCH_MEDIUM), VOL_EFFECTS_MASTER)
	visible_message("<span class='alert'>\The [user] has punched [src]!</span>")
	var/list/damObj = user.get_unarmed_attack()
	take_damage(damObj["damage"], damObj["type"], MELEE)

/obj/structure/spider/spiderling/deconstruct(disassembled)
	visible_message("<span class='alert'>[src] dies!</span>")
	new /obj/effect/decal/cleanable/spiderling_remains(get_turf(src))
	..()

/obj/structure/spider/spiderling/proc/cancel_vent_move()
	if(!entry_vent)
		forceMove(get_turf(src))
		return
	forceMove(entry_vent.loc)
	entry_vent = null

/obj/structure/spider/spiderling/proc/vent_move(obj/machinery/atmospherics/components/unary/vent_pump/exit_vent)
	if(QDELETED(exit_vent) || exit_vent.welded)
		cancel_vent_move()
		return

	forceMove(exit_vent.loc)
	var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
	addtimer(CALLBACK(src, PROC_REF(do_vent_move), exit_vent, travel_time), travel_time)

/obj/structure/spider/spiderling/proc/do_vent_move(obj/machinery/atmospherics/components/unary/vent_pump/exit_vent, travel_time)
	if(QDELETED(exit_vent) || exit_vent.welded)
		cancel_vent_move()
		return

	if(prob(50))
		audible_message("<span class='notice'>You hear something scampering through the ventilation ducts.</span>")

	addtimer(CALLBACK(src, PROC_REF(finish_vent_move), exit_vent), travel_time)

/obj/structure/spider/spiderling/proc/finish_vent_move(obj/machinery/atmospherics/components/unary/vent_pump/exit_vent)
	if(QDELETED(exit_vent) || exit_vent.welded)
		cancel_vent_move()
		return
	forceMove(exit_vent.loc)
	entry_vent = null

/obj/structure/spider/spiderling/process()
	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			var/datum/pipeline/entry_vent_parent = entry_vent.PARENT1
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
			if(prob(40))
				visible_message("<B>[src] scrambles into the ventilation ducts!</B>", \
							"<span class='notice'>You hear something scampering through the ventilation ducts.</span>")

			addtimer(CALLBACK(src, PROC_REF(vent_move), exit_vent), rand(15,30))

	//=================

	else if(prob(33))
		var/list/nearby = oview(1, src)
		if(nearby.len)
			var/target_atom = pick(nearby)
			walk_to(src, target_atom)
			if(prob(40))
				visible_message("<span class='notice'>\The [src] skitters[pick(" away"," around","")].</span>")
	else if(prob(10))
		//ventcrawl!
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in view(3,src))
			if(!v.welded)
				entry_vent = v
				walk_to(src, entry_vent, 1)
				break
	if(isturf(loc) && amount_grown > 0)
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			grow_as = pick(/mob/living/simple_animal/hostile/giant_spider, /mob/living/simple_animal/hostile/giant_spider/hunter, /mob/living/simple_animal/hostile/giant_spider/nurse)
			var/mob/living/simple_animal/hostile/giant_spider/S = new grow_as(loc, adaptations)
			if(sentient || prob(5))
				create_spawner(/datum/spawner/living/spider, S)
				//S.AddComponent(/datum/component/logout_spawner, /datum/spawner/living/spider) //Cause we add it after init
			qdel(src)

/obj/effect/decal/cleanable/spiderling_remains
	name = "spiderling remains"
	desc = "Green squishy mess."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenshatter"

/obj/structure/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	max_integrity = 60

/obj/structure/spider/cocoon/atom_init()
	. = ..()
	icon_state = pick("cocoon1","cocoon2","cocoon3")

/obj/structure/spider/cocoon/container_resist()
	var/mob/living/user = usr
	if(user.is_busy()) return
	var/breakout_time = 2
	user.SetNextMove(100)
	user.last_special = world.time + 100
	to_chat(user, "<span class='notice'>You struggle against the tight bonds! (This will take about [breakout_time] minutes.)</span>")
	visible_message("You see something struggling and writhing in the [src]!")
	if(do_after(user,(breakout_time*60*10),target=src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)

/obj/structure/spider/cocoon/Destroy()
	visible_message("<span class='warning'>\the [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))
	return ..()
