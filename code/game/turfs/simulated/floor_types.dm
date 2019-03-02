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

/turf/unsimulated/desert
	name = "sand"
	icon_state = "asteroid"

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/engine/attackby(obj/item/weapon/C, mob/user)
	if(istype(C, /obj/item/weapon/wrench))
		if(user.is_busy()) return
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

/turf/simulated/floor/beach/water/atom_init()
	. = ..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)

/turf/simulated/floor/beach/water/break_tile()
	return

/turf/simulated/floor/beach/water/burn_tile()
	return

/turf/simulated/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_type = /obj/item/stack/tile/grass

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
	if(istype(C, /obj/item/weapon/screwdriver))
		user.SetNextMove(CLICK_CD_INTERACT)
		ReplaceWithLattice()
		playsound(src, 'sound/items/Screwdriver.ogg', 80, 1)
		return

	if(istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		coil.turf_place(src, user)

/turf/simulated/floor/plating/airless/catwalk/is_catwalk()
	return TRUE

/turf/simulated/floor/exodus
