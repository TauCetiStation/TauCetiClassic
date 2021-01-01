/turf/simulated/snow
	icon = 'icons/turf/snow2.dmi'
	name = "snow"
	icon_state = "snow"
	dynamic_lighting = TRUE

	basetype = /turf/simulated/snow
	footstep = FOOTSTEP_SNOWSTEP
	barefootstep = FOOTSTEP_SNOWSTEP
	clawfootstep = FOOTSTEP_SNOWSTEP
	heavyfootstep = FOOTSTEP_SNOWSTEP

	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = TM50C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

	//plane = GAME_PLANE

	var/static/datum/dirt_cover/basedatum = /datum/dirt_cover/snow
	var/static/image/snow_fall_overlay

/turf/simulated/snow/atom_init(mapload)
	. = ..()

	if(it_is_a_snow_day)
		if(!snow_fall_overlay)
			snow_fall_overlay = image(icon, "snow_fall")
			snow_fall_overlay.plane = LIGHTING_PLANE + 1
			//win snow_fall_overlay.plane = LIGHTING_PLANE
			//snow_fall_overlay.layer = LIGHTING_LAYER - 1
		add_overlay(snow_fall_overlay)

	if(IS_EVEN(x) && IS_EVEN(y))
		set_light(1.4, 1, "#0000ff")

	if(type == /turf/simulated/snow)
		icon_state = pick(
			prob(80);icon_state + "0",
			prob(30);icon_state + "[rand(1,12)]"
			)
		if(mapload && populate_flora())
			return
		if(ispath(basedatum))
			basedatum = new basedatum

/turf/simulated/snow/Destroy()
	return QDEL_HINT_LETMELIVE

/turf/simulated/snow/proc/populate_flora()
	if(locate(/obj/structure/, src)) // shuttles
		return
	if(snow_map_noise)
		var/land_type = snow_map_noise.map_array[x][y]
		switch(land_type)
			if("flora")
				if(!prob(35))
					return
				var/snow_flora = pick(
					prob(65);/obj/structure/flora/grass/both,
					prob(35);/obj/structure/flora/bush,
					prob(10);/obj/structure/flora/tree/pine,
					prob(10);/obj/structure/flora/tree/dead
					)

				var/obj/O = new snow_flora(src)

				if(!QDELETED(O) && prob(1) && prob(5))
					new /mob/living/simple_animal/hostile/mimic/copy(src, O)
			if("mine_rocks")
				new /obj/structure/flora/mine_rocks(src)
			if("ice")
				ChangeTurf(/turf/simulated/snow/ice)
				return TRUE

/turf/simulated/snow/attack_paw(mob/user)
	return attack_hand(user)

/turf/simulated/snow/attackby(obj/item/C, mob/user)
	if (istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		user.SetNextMove(CLICK_CD_RAPID)
		if(L)
			if(R.get_amount() < 2)
				to_chat(user, "<span class='warning'>You don't have enough rods to do that.</span>")
				return
			if(user.is_busy()) return
			to_chat(user, "<span class='notice'>You begin to build a catwalk.</span>")
			if(do_after(user,30,target = src))
				if(!R.use(2))
					return
				playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You build a catwalk!</span>")
				ChangeTurf(/turf/simulated/floor/plating/airless/catwalk)
				qdel(L)
				return

		if(!R.use(1))
			return
		to_chat(user, "<span class='notice'>Constructing support lattice ...</span>")
		playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER)
		ReplaceWithLattice()

	else if (istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(!S.use(1))
				return
			qdel(L)
			user.SetNextMove(CLICK_CD_RAPID)
			playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER)
			S.build(src)
			return
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support.</span>")

/turf/simulated/snow/Entered(atom/movable/AM)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		to_chat(usr, "<span class='warning'>Movement is admin-disabled.</span>")//This is to identify lag problems
		return

	..()

	if(!SSticker || !SSticker.mode)
		return

	if(type == /turf/simulated/snow && iscarbon(AM))
		var/mob/living/carbon/perp = AM

		var/amount = 7
		var/hasfeet = TRUE
		var/skip = FALSE
		if (ishuman(perp))
			var/mob/living/carbon/human/H = perp
			var/obj/item/organ/external/l_foot = H.bodyparts_by_name[BP_L_LEG]
			var/obj/item/organ/external/r_foot = H.bodyparts_by_name[BP_R_LEG]
			if((!l_foot || l_foot.is_stump) && (!r_foot || r_foot.is_stump))
				hasfeet = FALSE
			if(perp.shoes && !perp.buckled)//Adding blood to shoes
				var/obj/item/clothing/shoes/S = perp.shoes
				if(istype(S))
					if((dirt_overlay && dirt_overlay.color != basedatum.color) || (!dirt_overlay))
						S.cut_overlays()
						S.add_dirt_cover(basedatum)
					S.track_blood = max(amount,S.track_blood)
					if(!S.blood_DNA)
						S.blood_DNA = list()
				skip = TRUE

		if (hasfeet && !skip) // Or feet
			if(perp.feet_dirt_color)
				perp.feet_dirt_color.add_dirt(basedatum)
			else
				perp.feet_dirt_color = new/datum/dirt_cover(basedatum)
			perp.track_blood = max(amount,perp.track_blood)
			if(!perp.feet_blood_DNA)
				perp.feet_blood_DNA = list()

		perp.update_inv_shoes()

/turf/simulated/snow/ChangeTurf(path, force_lighting_update = 0)
	return ..(path, TRUE)

/turf/simulated/snow/singularity_act()
	return

/turf/simulated/snow/ice
	name = "ice"
	icon = 'icons/turf/snow2.dmi'
	icon_state = "ice"

	basetype = /turf/simulated/snow/ice
	footstep = FOOTSTEP_ICESTEP
	barefootstep = FOOTSTEP_ICESTEP
	clawfootstep = FOOTSTEP_ICESTEP
	heavyfootstep = FOOTSTEP_ICESTEP

/turf/simulated/snow/ice/ChangeTurf(path, force_lighting_update = 0)
	if(path != type)
		var/obj/effect/overlay/ice_hole/IH = locate() in contents
		if(IH)
			qdel(IH)
	return ..(path, TRUE)

/turf/simulated/snow/ice/attackby(obj/item/O, mob/user)
	. = ..()
	if(locate(/obj/effect/overlay/ice_hole) in range(4))
		to_chat(user, "<span class='notice'>Too close to the other ice hole.</span>")
		return
	if(!O.has_edge())
		to_chat(user, "<span class='notice'>You can't make ice hole with [O].</span>")
		return
	if(user.is_busy())
		return
	playsound(src, 'sound/effects/digging.ogg', VOL_EFFECTS_MASTER)
	var/type = src.type
	if(!do_after(user, 20 SECONDS, target = src) || type != src.type)
		return
	new /obj/effect/overlay/ice_hole(src)
	playsound(src, 'sound/effects/digging.ogg', VOL_EFFECTS_MASTER)

/atom/movable
	var/ice_slide_count = 0

/turf/simulated/snow/ice/Entered(atom/movable/AM)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		to_chat(usr, "<span class='warning'>Movement is admin-disabled.</span>")//This is to identify lag problems
		return

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

	if(AM.ice_slide_count)
		stoplag() // Let a diagonal move finish, if necessary
		AM.newtonian_move(AM.inertia_dir)

/obj/structure/flora/mine_rocks
	name = "rock"
	desc = "Can be mined with proper tools."
	icon = 'icons/turf/rocks.dmi'
	icon_state = "basalt1"
	anchored = TRUE
	density = TRUE

	var/last_act = 0
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
		if(last_act > world.time)//prevents message spam
			return
		last_act = world.time + P.toolspeed

		if(istype(P, /obj/item/weapon/pickaxe/drill))
			var/obj/item/weapon/pickaxe/drill/D = P
			if(!D.on)
				last_act = world.time + 10
				to_chat(user, "<span class='danger'>[D] is turned off!</span>")
				return
			if(!(istype(D, /obj/item/weapon/pickaxe/drill/borgdrill) || istype(D, /obj/item/weapon/pickaxe/drill/jackhammer)))	//borgdrill & jackhammer can't lose energy and crit fail
				if(D.state)
					to_chat(user, "<span class='danger'>[D] is not ready!</span>")
					return
				if(!D.power_supply || !D.power_supply.use(D.drill_cost))
					to_chat(user, "<span class='danger'>No power!</span>")
					return
				if(D.mode)
					if(mineral)
						mined_ore_loss = mineral.ore_loss
				D.power_supply.use(D.drill_cost)

		playsound(user, P.usesound, VOL_EFFECTS_INSTRUMENT)
		to_chat(user, "<span class='warning'>You start [P.drill_verb].</span>")

		if(!user.is_busy() && do_after(user,P.toolspeed, target = src))
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

/obj/effect/overlay/frozen
	icon = 'icons/turf/overlays.dmi'
	icon_state = "snowfloor"
	anchored = 1
	mouse_opacity = 0

	var/list/spread_dirs

/obj/effect/overlay/frozen/atom_init()
	. = ..()
	var/turf/simulated/T = loc
	if(!istype(T) || !T.zone || T.air_unsim)
		return INITIALIZE_HINT_QDEL

	plane = T.plane
	layer = T.layer + 0.01

	spread_dirs = cardinal.Copy()

	addtimer(CALLBACK(src, .proc/spread), rand(3 SECONDS, 15 SECONDS))

	T.frozen_overlay = src
	T.zone.frozen_objs += src

	playsound(src, 'sound/effects/icestep.ogg', VOL_EFFECTS_MASTER)

/obj/effect/overlay/frozen/Destroy()
	var/turf/simulated/T = loc
	if(istype(T) && T.frozen_overlay)
		T.frozen_overlay = null
		if(T.zone)
			T.zone.frozen_objs -= src
	return ..()

/obj/effect/overlay/frozen/proc/spread()
	var/picked_dir = pick(spread_dirs)
	spread_dirs -= picked_dir

	var/turf/simulated/T = get_step(src, picked_dir)
	if(istype(T) && !T.air_unsim)
		var/obj/machinery/door/airlock/A = locate() in T
		if(A)
			A.check_temperature(T0C-1, TRUE)

		var/datum/gas_mixture/GM = T.return_air()
		if(GM.temperature < T0C && !T.frozen_overlay)
			new type(T)

	if(spread_dirs.len)
		addtimer(CALLBACK(src, .proc/spread), rand(3 SECONDS, 15 SECONDS))
	else
		spread_dirs = null

/obj/effect/overlay/ice_hole
	name = "ice hole"
	icon = 'icons/turf/snow2.dmi'
	icon_state = "ice_hole"
	anchored = 1
	var/fish_amount = 0

/obj/effect/overlay/ice_hole/atom_init()
	. = ..()
	fish_amount = rand(1, 30)

/obj/effect/overlay/ice_hole/attackby(obj/O, mob/user)
	. = ..()
	if (istype(O, /obj/item/weapon/wirerod) && !user.is_busy())
		if(fish_amount && fish_amount < 3)
			to_chat(user, "<span class='warning'>Looks like there is almost no fish left in this location.</span>")
		visible_message("<span class='notice'>[user] starts fishing.</span>")
		if(do_after(user, 10 SECONDS, target = src))
			if(!fish_amount)
				to_chat(user, "<span class='warning'>No fish left here, time to change location.</span>")
			else
				if(prob(20))
					fish_amount--
					var/fish_path = pick(
						prob(90);/obj/item/fish_carp,
						prob(20);/obj/item/fish_carp/mega
						)
					var/obj/fish = new fish_path(loc, get_step(user, get_dir(src, user)))
					visible_message("<span class='notice'>[user] has caught [fish].</span>")
					return
			visible_message("<span class='notice'>[user] fails to catch anything.</span>")
		else
			visible_message("<span class='notice'>[user] stops fishing.</span>")

/obj/random/misc/all/high
	spawn_nothing_percentage = 40

/obj/item/fish_carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/mob/carp.dmi'
	icon_state = "purple_dead"
	var/meat_amount_max = 1
	var/loot_amount = 1

/obj/item/fish_carp/atom_init(mapload, catch_target_turf)
	. = ..()

	update_icon()

	appearance_flags |= PIXEL_SCALE
	var/matrix/Mx = matrix()
	Mx.Scale(0.5)
	transform = Mx

	if(catch_target_turf)
		INVOKE_ASYNC(src, .proc/play_catch_anim, catch_target_turf)

/obj/item/fish_carp/update_icon()
	var/carp_color = pick(
	500;"purple",
	150;"ashy",
	150;"blue",
	150;"white",
	50;"golden")

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

// Noise source: codepen.io/yutt/pen/rICHm
var/datum/perlin/snow_map_noise
var/list/raw_noise
var/list/perlin_noise

/datum/perlin
	var/list/map_array
	var/MAP_WIDTH
	var/MAP_HEIGHT

/datum/perlin/New()
	MAP_WIDTH = world.maxx
	MAP_HEIGHT = world.maxy

	map_array = new/list(MAP_WIDTH,MAP_HEIGHT)
	raw_noise = new/list(MAP_WIDTH,MAP_HEIGHT)
	perlin_noise = new/list(MAP_WIDTH,MAP_HEIGHT)

	for (var/i = 1, i <= MAP_WIDTH, i++)
		for (var/j = 1, j <= MAP_HEIGHT, j++)
			raw_noise[i][j] = rand()

	perlinnoise()

	for (var/i = 1, i <= MAP_WIDTH, i++)
		for (var/j = 1, j <= MAP_HEIGHT, j++)

			var/result

			if (perlin_noise[i][j] > 200)
				result = "empty"
			else if (perlin_noise[i][j] > 100)
				if(prob(1) && prob(15))
					result = "mine_rocks"
				else
					result = "flora"
			else if (perlin_noise[i][j] > 60)
				if(prob(1) && prob(5))
					result = "mine_rocks"
				else
					result = "empty"
			else
				result = "ice"

			map_array[i][j] = result

/datum/perlin/proc/smoothnoise(octave)
	var/smooth[MAP_WIDTH]

	for (var/i = 1, i <= MAP_WIDTH, i++)
		smooth[i] = new/list(MAP_HEIGHT)
		for (var/j = 1, j <= MAP_HEIGHT, j++)
			smooth[i][j] = ""

	var/samplePeriod = 1 << octave
	var/sampleFreq = (1.0 / samplePeriod)

	for (var/k = 1, k <= MAP_WIDTH, k++)
		var/_i0 = FLOOR(k / samplePeriod, 1) * samplePeriod
		var/_i1 = (_i0 + samplePeriod) % MAP_WIDTH
		var/h_blend = (k - _i0) * sampleFreq

		for (var/l = 1, l <= MAP_HEIGHT, l++)
			var/_j0 = FLOOR(l / samplePeriod, 1) * samplePeriod
			var/_j1 = (_j0 + samplePeriod) % MAP_HEIGHT
			var/v_blend = (l - _j0) * sampleFreq

			var/top = raw_noise[_i0+1][_j0+1] * (1 - h_blend) + h_blend * raw_noise[_i1+1][_j0+1]
			var/bottom = raw_noise[_i0+1][_j1+1] * (1 - h_blend) + h_blend * raw_noise[_i1+1][_j1+1]

			smooth[k][l] = FLOOR((top * (1 - v_blend) + v_blend * bottom) * 255, 1)

	return smooth

/datum/perlin/proc/perlinnoise()
	var/persistance = 0.5
	var/amplitude = 1.0
	var/totalAmp = 0.0
	var/octave = 7
	var/smooth[octave]

	for(var/i = 1, i <= octave, i++)
		smooth[i] = new/list(MAP_WIDTH,MAP_HEIGHT)
		smooth[i] = smoothnoise(i)

	for(var/o = (octave - 1), o >= 1, o--)
		amplitude = amplitude * persistance
		totalAmp += amplitude
		for(var/i = 1, i <= MAP_WIDTH, i++)
			for(var/j = 1, j <= MAP_WIDTH, j++)
				if(!isnum(perlin_noise[i][j]))
					perlin_noise[i][j] = 0
				perlin_noise[i][j] += (smooth[o][i][j] * amplitude)

	for(var/i = 1, i <= MAP_WIDTH, i++)
		for(var/j = 1, j <= MAP_WIDTH, j++)
			perlin_noise[i][j] = FLOOR(perlin_noise[i][j] / totalAmp, 1)
