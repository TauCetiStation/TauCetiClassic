/turf/simulated/snow
	icon = 'icons/turf/snow2.dmi'
	name = "snow"
	icon_state = "snow"
	dynamic_lighting = TRUE

	basetype = /turf/simulated/snow
	footstep_sound = 'sound/effects/snowstep.ogg'
	footstep_sound_priority = TRUE

	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = TM50C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

	plane = GAME_PLANE

	var/static/datum/dirt_cover/basedatum = /datum/dirt_cover/snow

/turf/simulated/snow/atom_init(mapload)
	. = ..()
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
				to_chat(user, "\red You don't have enough rods to do that.")
				return
			if(user.is_busy()) return
			to_chat(user, "\blue You begin to build a catwalk.")
			if(do_after(user,30,target = src))
				if(!R.use(2))
					return
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				to_chat(user, "\blue You build a catwalk!")
				ChangeTurf(/turf/simulated/floor/plating/airless/catwalk)
				qdel(L)
				return

		if(!R.use(1))
			return
		to_chat(user, "\blue Constructing support lattice ...")
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		ReplaceWithLattice()

	else if (istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(!S.use(1))
				return
			qdel(L)
			user.SetNextMove(CLICK_CD_RAPID)
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			S.build(src)
			return
		else
			to_chat(user, "\red The plating is going to need some support.")

/turf/simulated/snow/Entered(atom/movable/AM)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		to_chat(usr, "\red Movement is admin-disabled.")//This is to identify lag problems
		return

	..()

	if(!ticker || !ticker.mode)
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
			if((!l_foot || l_foot.status & ORGAN_DESTROYED) && (!r_foot || r_foot.status & ORGAN_DESTROYED))
				hasfeet = FALSE
			if(perp.shoes && !perp.buckled)//Adding blood to shoes
				var/obj/item/clothing/shoes/S = perp.shoes
				if(istype(S))
					if((dirt_overlay && dirt_overlay.color != basedatum.color) || (!dirt_overlay))
						S.overlays.Cut()
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
	footstep_sound = 'sound/effects/icestep.ogg'

/atom/movable
	var/ice_slide_count = 0

/turf/simulated/snow/ice/Entered(atom/movable/AM)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		to_chat(usr, "\red Movement is admin-disabled.")//This is to identify lag problems
		return

	..()

	if(QDELETED(AM) || src != AM.loc)
		return

	if(!ticker || !ticker.mode)
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
				result = "flora"
			else if (perlin_noise[i][j] > 60)
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
		var/_i0 = Floor(k / samplePeriod) * samplePeriod
		var/_i1 = (_i0 + samplePeriod) % MAP_WIDTH
		var/h_blend = (k - _i0) * sampleFreq

		for (var/l = 1, l <= MAP_HEIGHT, l++)
			var/_j0 = Floor(l / samplePeriod) * samplePeriod
			var/_j1 = (_j0 + samplePeriod) % MAP_HEIGHT
			var/v_blend = (l - _j0) * sampleFreq

			var/top = raw_noise[_i0+1][_j0+1] * (1 - h_blend) + h_blend * raw_noise[_i1+1][_j0+1]
			var/bottom = raw_noise[_i0+1][_j1+1] * (1 - h_blend) + h_blend * raw_noise[_i1+1][_j1+1]

			smooth[k][l] = Floor((top * (1 - v_blend) + v_blend * bottom) * 255)

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
			perlin_noise[i][j] = Floor(perlin_noise[i][j] / totalAmp)
