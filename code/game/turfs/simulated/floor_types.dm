/turf/simulated/floor/airless
	icon_state = "floor"
	name = "airless floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

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

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000
	footstep = FOOTSTEP_PLATING

/turf/simulated/floor/goonplaque
	name = "Comemmorative Plaque";
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding.";
	icon_state = "plaque";

/turf/simulated/floor/engine/attackby(obj/item/weapon/C, mob/user)
	if(iswrench(C))
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>Removing rods...</span>")
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

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

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
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	floor_type = null
	intact = 0
	footstep = FOOTSTEP_PLATING

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

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
	heat_capacity = 0
	layer = 2


/turf/simulated/shuttle/wall // It's not even a floor. What is this doing here?!
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/shuttle/floor
	name = "floor"
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
	slowdown = 6



/turf/simulated/floor/beach/water/waterpool
	icon_state = "seadeep"

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
	Stun(2)
	playsound(src, 'sound/effects/water_turf_entered_mob.ogg', VOL_EFFECTS_MASTER)
	wear_suit?.make_wet()
	w_uniform?.make_wet()
	shoes?.make_wet()

/mob/living/silicon/robot/entered_water_turf()
	Stun(2)
	playsound(src, 'sound/effects/water_turf_entered_mob.ogg', VOL_EFFECTS_MASTER)
	if(stat)
		return
	if(prob(25))
		adjustFireLoss(rand(10, 20))
		Weaken(rand(10, 15))
		eye_blind += rand(20, 25)
		playsound(src, 'sound/machines/cfieldfail.ogg', VOL_EFFECTS_MASTER, null, FALSE, -4)
	if(!eye_blind)
		to_chat(src, "<span class='userdanger'>BF%AO@DAT-T[pick("@$%!", "-TEN-TEN%#!", "ENTION")]YAW$!$@@&@CRITI[pick("CAL-CAL", "CAL", "-TI-TI^$#&&@!")]!TAQQ@%@OV[pick("ERL", "ER-ER-ER", "-OAD-D")]%#^WW@ZF%^#D</span>")
		playsound_local(null, 'sound/AI/ionstorm.ogg', VOL_EFFECTS_MASTER, 50, FALSE)
		eye_blind += rand(5, 10)



/turf/simulated/floor/beach/water/atom_init()
	. = ..()
	add_overlay(image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1))

/turf/simulated/floor/beach/water/break_tile()
	return

/turf/simulated/floor/beach/water/burn_tile()
	return

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
	update_icon()
	for(var/direction in cardinal)
		if(istype(get_step(src,direction),/turf/simulated/floor))
			var/turf/simulated/floor/FF = get_step(src,direction)
			FF.update_icon() //so siding get updated properly

/turf/simulated/floor/carpet
	name = "carpet"
	icon_state = "carpet"
	floor_type = /obj/item/stack/tile/carpet
	icon = 'icons/turf/carpets.dmi'
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT

/turf/simulated/floor/carpet/black
	name = "black carpet"
	icon_state = "blackcarpet"
	floor_type = /obj/item/stack/tile/carpet/black

/turf/simulated/floor/carpet/purple
	name = "purple carpet"
	icon_state = "purplecarpet"
	floor_type = /obj/item/stack/tile/carpet/purple

/turf/simulated/floor/carpet/orange
	name = "orange carpet"
	icon_state = "orangecarpet"
	floor_type = /obj/item/stack/tile/carpet/orange

/turf/simulated/floor/carpet/green
	name = "green carpet"
	icon_state = "greencarpet"
	floor_type = /obj/item/stack/tile/carpet/green

/turf/simulated/floor/carpet/blue
	name = "blue carpet"
	icon_state = "bluecarpet"
	floor_type = /obj/item/stack/tile/carpet/blue

/turf/simulated/floor/carpet/blue2
	name = "blue carpet"
	icon_state = "blue2carpet"
	floor_type = /obj/item/stack/tile/carpet/blue2

/turf/simulated/floor/carpet/red
	name = "red carpet"
	icon_state = "redcarpet"
	floor_type = /obj/item/stack/tile/carpet/red

/turf/simulated/floor/carpet/cyan
	name = "cyan carpet"
	icon_state = "cyancarpet"
	floor_type = /obj/item/stack/tile/carpet/cyan

/turf/simulated/floor/carpet/atom_init()
	if(!icon_state)
		icon_state = "carpet"
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/floor/carpet/atom_init_late()
	update_icon()
	for(var/direction in list(1,2,4,8,5,6,9,10))
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

/turf/simulated/floor/plating/ironsand/ex_act()
	return 0

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

/turf/simulated/floor/plating/snow/ex_act(severity)
	return

// CATWALKS
// Space and plating, all in one buggy fucking turf!
/turf/simulated/floor/plating/airless/catwalk
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "catwalk0"
	name = "catwalk"
	desc = "Cats really don't like these things."

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

//	accepts_lighting=0 			// Don't apply overlays

	intact = 0

	footstep = FOOTSTEP_CATWALK

/turf/simulated/floor/plating/airless/catwalk/atom_init()
	. = ..()
	update_icon(1)
	set_light(1.5)

/turf/simulated/floor/plating/airless/catwalk/update_icon(propogate=1)
	underlays.Cut()
	var/image/I = image('icons/turf/space.dmi', SPACE_ICON_STATE, layer=TURF_LAYER)
	I.plane = PLANE_SPACE
	underlays += I

	var/dirs = 0
	for(var/direction in cardinal)
		var/turf/T = get_step(src,direction)
		if(T.is_catwalk())
			var/turf/simulated/floor/plating/airless/catwalk/C=T
			dirs |= direction
			if(propogate)
				C.update_icon(0)
	icon_state="catwalk[dirs]"


/turf/simulated/floor/plating/airless/catwalk/attackby(obj/item/C, mob/user)
	if(isscrewdriver(C))
		user.SetNextMove(CLICK_CD_INTERACT)
		ReplaceWithLattice()
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		return

	if(iscoil(C))
		var/obj/item/stack/cable_coil/coil = C
		coil.turf_place(src, user)

/turf/simulated/floor/plating/airless/catwalk/is_catwalk()
	return TRUE

/turf/simulated/floor/exodus
