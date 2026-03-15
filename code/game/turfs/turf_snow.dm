/turf/environment/snow
	icon = 'icons/turf/snow2.dmi'
	name = "snow"
	icon_state = "snow0"
	plane = FLOOR_PLANE

	basetype = /turf/environment/snow
	footstep = FOOTSTEP_SNOWSTEP
	barefootstep = FOOTSTEP_SNOWSTEP
	clawfootstep = FOOTSTEP_SNOWSTEP
	heavyfootstep = FOOTSTEP_SNOWSTEP

	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = TM50C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 12000 // ~6 snow tiles

	level_light_source = TRUE

	var/static/datum/dirt_cover/basedatum = /datum/dirt_cover/snow
	var/static/image/snow_fall_overlay

/turf/environment/snow/atom_init(mapload)
	. = ..()

	if(it_is_a_snow_day)
		if(!snow_fall_overlay)
			snow_fall_overlay = image(icon, "snow_fall")
			snow_fall_overlay.plane = GAME_PLANE
			snow_fall_overlay.layer = 10
		add_overlay(snow_fall_overlay)

	if(type == /turf/environment/snow)
		if(prob(27)) // ~= 100*30/110
			icon_state = "snow[rand(1,12)]"
		if(ispath(basedatum))
			basedatum = new basedatum

/turf/environment/snow/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	return QDEL_HINT_LETMELIVE

/turf/environment/snow/attack_paw(mob/user)
	return attack_hand(user)

/turf/environment/snow/attackby(obj/item/C, mob/user)
	build_floor_support(C, user, 100)

/turf/environment/snow/Entered(atom/movable/AM)
	..()

	if(!SSticker || !SSticker.mode)
		return

	if(type == /turf/environment/snow && iscarbon(AM))
		var/mob/living/carbon/perp = AM
		perp.add_feet_dirt(basedatum, 7, blood=FALSE)

/turf/environment/snow/singularity_act()
	return

/turf/environment/snow/ice
	name = "ice"
	icon = 'icons/turf/snow2.dmi'
	icon_state = "ice"

	basetype = /turf/environment/snow/ice
	footstep = FOOTSTEP_ICESTEP
	barefootstep = FOOTSTEP_ICESTEP
	clawfootstep = FOOTSTEP_ICESTEP
	heavyfootstep = FOOTSTEP_ICESTEP

/turf/environment/snow/ice/ChangeTurf(path)
	if(path != type)
		var/obj/structure/ice_hole/IH = locate() in contents
		if(IH)
			qdel(IH)
	return ..()

/turf/environment/snow/ice/attackby(obj/item/O, mob/user)
	. = ..()
	if(locate(/obj/structure/ice_hole) in range(4))
		to_chat(user, "<span class='notice'>Too close to the other ice hole.</span>")
		return
	if(!O.has_edge())
		to_chat(user, "<span class='notice'>You can't make ice hole with [O].</span>")
		return
	if(user.is_busy())
		return
	playsound(src, 'sound/effects/shovel_digging.ogg', VOL_EFFECTS_MASTER)
	var/type = src.type
	if(!do_after(user, 20 SECONDS, target = src) || type != src.type)
		return
	new /obj/structure/ice_hole(src)
	playsound(src, 'sound/effects/shovel_digging.ogg', VOL_EFFECTS_MASTER)

/atom/movable
	var/ice_slide_count = 0

/turf/environment/snow/ice/Entered(atom/movable/AM)
	..()

	if(QDELETED(AM) || src != AM.loc)
		return

	if(!SSticker || !SSticker.mode)
		return

	if(AM.inertia_dir && !isturf(get_step(AM, AM.inertia_dir)))
		AM.ice_slide_count = 0
		return

	if(!AM.ice_slide_count)
		AM.ice_slide_count = rand(3,10)

	AM.ice_slide_count--

/obj/structure/flora/mine_rocks
	name = "rock"
	desc = "Can be mined with proper tools."
	icon = 'icons/turf/rocks.dmi'
	icon_state = "basalt1"
	anchored = TRUE
	density = TRUE

	var/next_act = 0
	var/mineral/mineral
	var/mineralSpawnChanceList = list("Uranium" = 5, "Platinum" = 5, "Iron" = 35, "Coal" = 20, "Diamond" = 3, "Gold" = 10, "Silver" = 10, "Phoron" = 20)
	var/ore_amount = 0
	var/mined_ore_loss = 0

/obj/structure/flora/mine_rocks/atom_init()
	. = ..()
	icon_state = "basalt[rand(1,3)]"

	var/mineral_name = pickweight(mineralSpawnChanceList) //temp mineral name

	if(!name_to_mineral)
		SetupMinerals()

	if (mineral_name && (mineral_name in name_to_mineral))
		mineral = name_to_mineral[mineral_name]

		if(prob(15))
			ore_amount = rand(12,18)
		else if(prob(45))
			ore_amount = rand(8,12)
		else
			ore_amount = rand(6,10)

/obj/structure/flora/mine_rocks/attackby(obj/item/weapon/W, mob/user)
	. = ..()

	if (istype(W, /obj/item/weapon/pickaxe))
		var/turf/T = user.loc
		if (!isturf(T))
			return

		var/obj/item/weapon/pickaxe/P = W
		if(next_act > world.time)//prevents message spam
			return
		next_act = world.time + 10 * P.toolspeed

		if(istype(P, /obj/item/weapon/pickaxe/drill))
			var/obj/item/weapon/pickaxe/drill/D = P
			if(!(istype(D, /obj/item/weapon/pickaxe/drill/borgdrill) || istype(D, /obj/item/weapon/pickaxe/drill/jackhammer)))	//borgdrill & jackhammer can't lose energy and crit fail
				if(D.state)
					to_chat(user, "<span class='danger'>[D] is not ready!</span>")
					return
				if(!D.power_supply?.use(D.drill_cost))
					to_chat(user, "<span class='danger'>No power!</span>")
					return

		playsound(user, P.usesound, VOL_EFFECTS_INSTRUMENT)
		to_chat(user, "<span class='warning'>You start [P.drill_verb].</span>")

		if(!user.is_busy(src) && P.use_tool(src, user, 10, volume = 100))
			to_chat(user, "<span class='notice'>You finish [P.drill_verb] the rock.</span>")
			GetDrilled()

/obj/structure/flora/mine_rocks/proc/GetDrilled()
	if (mineral && ore_amount)
		ore_amount -= max(1, mined_ore_loss)
		mined_ore_loss = 0
		DropMineral()

/obj/structure/flora/mine_rocks/proc/DropMineral()
	if(!mineral)
		return
	new mineral.ore(loc)
	if(ore_amount <= 0)
		qdel(src)


/obj/structure/ice_hole
	name = "ice hole"
	icon = 'icons/turf/snow2.dmi'
	icon_state = "ice_hole"
	anchored = 1
	density = 1

/obj/structure/ice_hole/atom_init()
	. = ..()
	AddComponent(/datum/component/fishing, list(/obj/item/fish_carp = 15, /obj/item/fish_carp/mega = 8, /obj/item/fish_carp/full_size = 5, /obj/item/fish_carp/over_size = 3, PATH_OR_RANDOM_PATH(/obj/random/mecha/wreckage) = 1, PATH_OR_RANDOM_PATH(/obj/random/cloth/shittysuit) = 1), 10 SECONDS, rand(1, 30) , 20)

/obj/random/misc/all/high
	spawn_nothing_chance = 40

/obj/item/fish_carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/mob/carp.dmi'
	icon_state = "purple_dead"
	var/scale_icon = 0.5
	var/meat_amount_max = 1
	var/loot_amount = 1

/obj/item/fish_carp/atom_init(mapload, catch_target_turf)
	. = ..()

	update_icon()

	appearance_flags |= PIXEL_SCALE
	var/matrix/Mx = matrix()
	Mx.Scale(scale_icon)
	transform = Mx

	if(catch_target_turf)
		INVOKE_ASYNC(src, PROC_REF(play_catch_anim), catch_target_turf)

/obj/item/fish_carp/update_icon()
	var/carp_color = pick(
		500;"purple",
		150;"ashy",
		150;"blue",
		150;"white",
		50;"golden"
	)

	icon_state = "[carp_color]_dead"

/obj/item/fish_carp/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(W.is_sharp() && !user.is_busy())
		to_chat(user, "<span class='notice'>You begin to butcher [src]...</span>")
		playsound(src, 'sound/weapons/slice.ogg', VOL_EFFECTS_MASTER)
		if(!do_after(user, 80, target = src) || QDELETED(src))
			return
		var/amount = rand(1, meat_amount_max)
		for (var/i in 1 to amount)
			new /obj/item/weapon/reagent_containers/food/snacks/carpmeat(loc)
		for (var/i in 1 to loot_amount)
			new /obj/random/misc/all/high(src)
		for(var/obj/item/loot in contents)
			if(prob(66))
				loot.make_old()
			loot.loc = loc
		visible_message("<span class='notice'>[user] butchers [src].</span>")
		qdel(src)

/obj/item/fish_carp/proc/play_catch_anim(turf/target)
	var/throw_dist = get_dist(src, target)
	var/throw_dist_half = round(throw_dist * 0.5)
	animate(src, pixel_y = 48, time = throw_dist_half, easing = SINE_EASING)
	animate(pixel_y = 0, time = throw_dist_half, easing = BOUNCE_EASING)
	for (var/i in 1 to 2)
		if(QDELETED(src))
			return
		sleep(1)
		loc = get_step(src, get_dir(src, target))

/obj/item/fish_carp/mega
	icon = 'icons/mob/megacarp.dmi'
	icon_state = "megacarp_dead"
	meat_amount_max = 4
	loot_amount = 3

/obj/item/fish_carp/mega/update_icon()
	return

/obj/item/fish_carp/full_size
	scale_icon = 1
	meat_amount_max = 8
	loot_amount = 6

/obj/item/fish_carp/over_size
	scale_icon = 2
	meat_amount_max = 16
	loot_amount = 12
