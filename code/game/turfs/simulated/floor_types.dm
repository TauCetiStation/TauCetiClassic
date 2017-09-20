/turf/simulated/floor/airless
	icon_state = "floor"
	name = "airless floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

	New()
		..()
		name = "floor"

/turf/simulated/floor/airless/ceiling
	icon_state = "rockvault"

/turf/simulated/floor/light
	name = "Light floor"
	light_range = 5
	icon_state = "light_on"
	floor_type = /obj/item/stack/tile/light

	New()
		var/n = name //just in case commands rename it in the ..() call
		..()
		spawn(4)
			if(src)
				update_icon()
				name = n



/turf/simulated/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_type = /obj/item/stack/tile/wood

/turf/unsimulated/desert
	name = "sand"
	icon_state = "asteroid"

/turf/simulated/floor/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/simulated/wall/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/engine/attackby(obj/item/weapon/C, mob/user)
	if(!C)
		return
	if(!user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		to_chat(user, "\blue Removing rods...")
		playsound(src, 'sound/items/Ratchet.ogg', 80, 1)
		if(do_after(user, 30, target = src))
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

/turf/simulated/floor/engine/n20/New()
	..()

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

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

	New()
		..()
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

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/simulated/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/simulated/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/simulated/floor/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'

/turf/simulated/floor/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/simulated/floor/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/floor/beach/water
	name = "Water"
	icon_state = "water"
	light_color = "#00BFFF"
	light_power = 2
	light_range = 2

/turf/simulated/floor/beach/water/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)

/turf/simulated/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_type = /obj/item/stack/tile/grass

	New()
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in cardinal)
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

/turf/simulated/floor/carpet
	name = "Carpet"
	icon_state = "carpet"
	floor_type = /obj/item/stack/tile/carpet

	New()
		if(!icon_state)
			icon_state = "carpet"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in list(1,2,4,8,5,6,9,10))
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

/turf/simulated/floor/plating/ironsand
	name = "Iron Sand"
	icon_state = "ironsand1"
	basetype = /turf/simulated/floor/plating/ironsand

/turf/simulated/floor/plating/ironsand/ex_act()
	return 0

/turf/simulated/floor/plating/ironsand/burn_tile()
	return 0

/turf/simulated/floor/plating/ironsand/New()
	..()
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/snow
	basetype = /turf/simulated/floor/plating/ironsand
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

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

	New()
		..()
		update_icon(1)
		set_light(1.5)

	update_icon(propogate=1)
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


	attackby(obj/item/C, mob/user)
		if(!C || !user)
			return 0
		if(istype(C, /obj/item/weapon/screwdriver))
			ReplaceWithLattice()
			playsound(src, 'sound/items/Screwdriver.ogg', 80, 1)
			return

		if(istype(C, /obj/item/weapon/cable_coil))
			var/obj/item/weapon/cable_coil/coil = C
			coil.turf_place(src, user)

	is_catwalk()
		return 1

/turf/simulated/floor/exodus
