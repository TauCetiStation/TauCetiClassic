/turf/simulated/floor/airless
	icon_state = "floor"
	name = "airless floor"
	airless = TRUE

/turf/simulated/floor/airless/atom_init()
	. = ..()
	name = "floor"

/turf/simulated/floor/airless/ceiling
	icon_state = "rockvault"

/turf/simulated/floor/light
	name = "Light floor"
	light_range = 5
	icon_state = "light_on"
	floor_type = /obj/item/stack/tile/light

/turf/simulated/floor/light/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/floor/light/atom_init_late()
	..()
	update_icon()
	name = initial(name)

/turf/simulated/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_type = /obj/item/stack/tile/wood
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW

/turf/unsimulated/desert
	name = "sand"
	icon_state = "asteroid"

/turf/simulated/floor/smoothtile
	name = "smooth floor tile"
	icon = 'icons/turf/floors/smooth/floortile.dmi'
	icon_state = "center_8"
	smooth = SMOOTH_TRUE

/turf/simulated/floor/smoothtile/neutral
	icon = 'icons/turf/floors/smooth/floortile_neutral.dmi'

/turf/simulated/floor/smoothtile/white
	icon = 'icons/turf/floors/smooth/floortile_white.dmi'

/turf/simulated/floor/smoothtile/dark
	icon = 'icons/turf/floors/smooth/floortile_dark.dmi'

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon = 'icons/turf/floors/smooth/hardfloor_1.dmi'
	icon_state = "center_8"
	thermal_conductivity = 0.025
	footstep = FOOTSTEP_PLATING
	smooth = SMOOTH_TRUE

/turf/simulated/floor/engine/type2
	icon = 'icons/turf/floors/smooth/hardfloor_2.dmi'

/turf/simulated/floor/engine/type3
	icon = 'icons/turf/floors/smooth/hardfloor_3.dmi'

/turf/simulated/floor/engine/type4
	icon = 'icons/turf/floors/smooth/hardfloor_4.dmi'

/turf/simulated/floor/engine/break_tile()
	return

/turf/simulated/floor/engine/burn_tile()
	return

/turf/simulated/floor/engine/attackby(obj/item/weapon/C, mob/user)
	if(iswrenching(C))
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>Вы начинаете удалять стержни.</span>")
		if(C.use_tool(src, user, 30, volume = 80))
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/simulated/floor)
			var/turf/simulated/floor/F = src
			F.make_plating()
			return

/turf/simulated/floor/engine/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(floor_type)
			if(prob(30))
				new floor_type(src)
				ChangeTurf(/turf/simulated/floor)
				make_plating() // why there is return for this floor type in that proc?
		else if(prob(30))
			ReplaceWithLattice()

/turf/simulated/floor/engine/airmix
	oxygen = MOLES_O2ATMOS
	nitrogen = MOLES_N2ATMOS

/turf/simulated/floor/engine/nitrogen
	oxygen = 0
	nitrogen = ATMOSTANK_NITROGEN

/turf/simulated/floor/engine/oxygen
	oxygen = ATMOSTANK_OXYGEN
	nitrogen = 0

/turf/simulated/floor/engine/phoron
	oxygen = 0
	nitrogen = 0
	phoron = ATMOSTANK_PHORON

/turf/simulated/floor/engine/carbon_dioxide
	oxygen = 0
	nitrogen = 0
	carbon_dioxide = ATMOSTANK_CO2

/turf/simulated/floor/engine/n20
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/n20/atom_init()
	. = ..()

	if(!air)
		make_air()

	air.adjust_gas("sleeping_agent", ATMOSTANK_NITROUSOXIDE)

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	airless = TRUE

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	floor_type = null
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	footstep = FOOTSTEP_PLATING

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	airless = TRUE

/turf/simulated/floor/plating/airless/atom_init()
	. = ..()
	name = "plating"

/turf/simulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/simulated/floor/whitegreed
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/simulated/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"


/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	layer = 2


/turf/simulated/shuttle/wall // It's not even a floor. What is this doing here?!
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = TRUE
	blocks_air = AIR_BLOCKED

	explosive_resistance = 5

/turf/simulated/shuttle/floor
	name = "floor"
	cases = list("пол", "пола", "полу", "пол", "полом", "поле")
	icon_state = "floor"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	explosive_resistance = 1

/turf/simulated/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_SAND

/turf/simulated/floor/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/simulated/floor/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"
	footstep = FOOTSTEP_WATER_SHALLOW
	barefootstep = FOOTSTEP_WATER_SHALLOW
	clawfootstep = FOOTSTEP_WATER_SHALLOW
	heavyfootstep = FOOTSTEP_WATER_SHALLOW

/turf/simulated/floor/beach/water
	name = "Water"
	icon_state = "water"
	light_color = "#00bfff"
	light_power = 2
	light_range = 2
	footstep = FOOTSTEP_WATER_DEEP
	barefootstep = FOOTSTEP_WATER_DEEP
	clawfootstep = FOOTSTEP_WATER_DEEP
	heavyfootstep = FOOTSTEP_WATER_DEEP
	static_fluid_depth  = 800

/turf/simulated/floor/beach/water/waterpool
	icon_state = "seadeep"

/turf/simulated/floor/beach/water/waterpool/atom_init()
	. = ..()
	AddComponent(/datum/component/fishing, list(/obj/item/clothing/mask/snorkel = 10, /obj/item/clothing/shoes/swimmingfins = 10, /obj/item/weapon/bikehorn/rubberducky = 10, /obj/item/clothing/under/bathtowel = 10, /obj/item/weapon/reagent_containers/food/snacks/soap = 5, /mob/living/simple_animal/hostile/xenomorph = 1), 10 SECONDS, rand(1, 3) , 20)


/turf/simulated/floor/beach/water/waterpool/Entered(atom/movable/AM, atom/old_loc)
	..()
	if(!istype(old_loc, /turf/simulated/floor/beach/water/waterpool))
		AM.entered_water_turf()

/turf/simulated/floor/beach/water/waterpool/Exited(atom/movable/AM, atom/new_loc)
	..()
	if(!istype(new_loc, /turf/simulated/floor/beach/water/waterpool))
		AM.exited_water_turf()

/atom/movable/proc/exited_water_turf()
	return

/mob/living/carbon/human/exited_water_turf()
	SEND_SIGNAL(src, COMSIG_HUMAN_EXITED_WATER)
	if(get_species() != SKRELL)
		Stun(2)
	playsound(src, 'sound/effects/water_turf_exited_mob.ogg', VOL_EFFECTS_MASTER)

/mob/living/silicon/robot/exited_water_turf()
	Stun(2)
	playsound(src, 'sound/effects/water_turf_exited_mob.ogg', VOL_EFFECTS_MASTER)

/atom/movable/proc/entered_water_turf()
	return

/obj/item/entered_water_turf()
	if(throwing)
		playsound(src, 'sound/effects/water_turf_entered_obj.ogg', VOL_EFFECTS_MASTER)

/mob/living/carbon/human/entered_water_turf()
	SEND_SIGNAL(src, COMSIG_HUMAN_ENTERED_WATER)
	if(get_species() != SKRELL)
		Stun(2)
	playsound(src, 'sound/effects/water_turf_entered_mob.ogg', VOL_EFFECTS_MASTER)
	wear_suit?.make_wet()
	w_uniform?.make_wet()
	shoes?.make_wet()

/mob/living/silicon/robot/entered_water_turf()
	Stun(2)
	playsound(src, 'sound/effects/water_turf_entered_mob.ogg', VOL_EFFECTS_MASTER)
	if(stat != CONSCIOUS)
		return
	if(prob(25))
		adjustFireLoss(rand(10, 20))
		Stun(rand(10, 15))
		eye_blind += rand(20, 25)
		playsound(src, 'sound/machines/cfieldfail.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -4)
	if(!eye_blind)
		to_chat(src, "<span class='userdanger'>БФ%ВО@ВНИ-И[pick("@$%!", "-МА-МАН%#!", "АНИЕ")]ЯВВ$!$@@&@КРИТИ[pick("ЧЕС-ЧЕС", "ЧЕС", "-КА-КА^$#&&@!")]!ЗЯКК@%@ПЕ[pick("РЕГРУЗ", "ГРУЗ-ГРУЗ-ГРУЗ", "-З-З-К-")]%#^ВВ@ЗФ%^#А</span>")
		playsound_local(null, 'sound/AI/ionstorm.ogg', VOL_EFFECTS_MASTER, 50, FALSE)
		eye_blind += rand(5, 10)



/turf/simulated/floor/beach/water/atom_init()
	. = ..()
	add_overlay(image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1))

/turf/simulated/floor/beach/water/break_tile()
	return

/turf/simulated/floor/beach/water/burn_tile()
	return

// indoor wariant of asteroid turfs
// todo: craft
// todo: rename?
// todo: why flood.dmi icons, and not asteroid.dmi
/turf/simulated/floor/garden
	icon_state = "asteroid"

/turf/simulated/floor/garden/atom_init()
	. = ..()
	icon_regular_floor = icon_state // because some stupid hardcode in parent init, asteroid states are ignored for icon_regular_floor

/turf/simulated/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_type = /obj/item/stack/tile/grass
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS

/turf/simulated/floor/grass/atom_init()
	icon_state = "grass[pick("1","2","3","4")]"
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/floor/grass/atom_init_late()
	..()
	update_icon()
	for(var/direction in cardinal)
		if(istype(get_step(src,direction),/turf/simulated/floor))
			var/turf/simulated/floor/FF = get_step(src,direction)
			FF.update_icon() //so siding get updated properly

/turf/simulated/floor/plating/ironsand
	name = "Iron Sand"
	icon_state = "ironsand1"
	basetype = /turf/simulated/floor/plating/ironsand
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	can_deconstruct = FALSE

/turf/simulated/floor/plating/ironsand/ex_act(severity)
	for(var/thing in contents)
		var/atom/movable/movable_thing = thing
		if(QDELETED(movable_thing))
			continue
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += movable_thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += movable_thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += movable_thing

/turf/simulated/floor/plating/ironsand/burn_tile()
	return 0

/turf/simulated/floor/plating/ironsand/atom_init()
	. = ..()
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/snow
	basetype = /turf/simulated/floor/plating/ironsand
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	can_deconstruct = FALSE

/turf/simulated/floor/plating/snow/ex_act(severity)
	for(var/thing in contents)
		var/atom/movable/movable_thing = thing
		if(QDELETED(movable_thing))
			continue
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += movable_thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += movable_thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += movable_thing

// CATWALKS
// Space and plating, all in one buggy fucking turf!
/turf/simulated/floor/plating/airless/catwalk
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "catwalk0"
	name = "catwalk"
	desc = "Рабочий помост с сомнительным функционалом."

	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = HEAT_CAPACITY_VACUUM
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	footstep = FOOTSTEP_CATWALK

	var/image/environment_underlay

	level_light_source = TRUE

/turf/simulated/floor/plating/airless/catwalk/atom_init()
	. = ..()
	update_icon(1)

/turf/simulated/floor/plating/airless/catwalk/Destroy()
	environment_underlay = null
	return ..()

/turf/simulated/floor/plating/airless/catwalk/update_icon(propogate=1)
	if(environment_underlay)
		underlays -= environment_underlay
	environment_underlay = SSenvironment.turf_image[z]
	underlays |= environment_underlay

	var/dirs = 0
	for(var/direction in cardinal)
		var/turf/T = get_step(src,direction)
		if(T.is_catwalk())
			var/turf/simulated/floor/plating/airless/catwalk/C=T
			dirs |= direction
			if(propogate)
				C.update_icon(0)
	icon_state="catwalk[dirs]"

/turf/simulated/floor/plating/airless/catwalk/is_catwalk()
	return TRUE
