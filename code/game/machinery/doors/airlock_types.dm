/*************************
* Station airlocks regular
*/

/obj/machinery/door/airlock/command
	icon = 'icons/obj/doors/airlocks/station/command.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_com

/obj/machinery/door/airlock/security
	icon = 'icons/obj/doors/airlocks/station/security.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_sec

/obj/machinery/door/airlock/engineering
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/medical
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/virology
	icon = 'icons/obj/doors/airlocks/station/virology.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_viro

/obj/machinery/door/airlock/maintenance
	name = "maintenance access"
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_mai

/obj/machinery/door/airlock/freezer
	name = "freezer airlock"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/mining
	name = "mining airlock"
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = "atmospherics airlock"
	icon = 'icons/obj/doors/airlocks/station/atmos.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	icon = 'icons/obj/doors/airlocks/station/research.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/science
	icon = 'icons/obj/doors/airlocks/station/science.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_science

/obj/machinery/door/airlock/neutral
	icon = 'icons/obj/doors/airlocks/station/neutral.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_neutral


/***********************
* Station airlocks glass
*/

/obj/machinery/door/airlock/command/glass
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/engineering/glass
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/security/glass
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/medical/glass
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/virology/glass
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/research/glass
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/mining/glass
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/atmos/glass
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/science/glass
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/science/neutral
	opacity = FALSE
	glass   = TRUE


/*************************
* Station airlocks mineral
*/

/obj/machinery/door/airlock/gold
	name = "gold airlock"
	icon = 'icons/obj/doors/airlocks/station/gold.dmi'
	mineral = "gold"

/obj/machinery/door/airlock/silver
	name = "silver airlock"
	icon = 'icons/obj/doors/airlocks/station/silver.dmi'
	mineral = "silver"

/obj/machinery/door/airlock/diamond
	name = "diamond airlock"
	icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
	mineral = "diamond"

/obj/machinery/door/airlock/uranium
	name = "uranium airlock"
	icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
	mineral = "uranium"
	var/last_event = 0

/obj/machinery/door/airlock/uranium/process()
	if(world.time > last_event + 20)
		if(prob(50))
			radiate()
		last_event = world.time
	..()

/obj/machinery/door/airlock/uranium/proc/radiate()
	for(var/mob/living/L in range (3,src))
		L.apply_effect(15, IRRADIATE, 0)

/obj/machinery/door/airlock/phoron
	name = "phoron airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/airlocks/station/phoron.dmi'
	mineral = "phoron"

/obj/machinery/door/airlock/phoron/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PhoronBurn(exposed_temperature)

/obj/machinery/door/airlock/phoron/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PhoronBurn(exposed_temperature)

/obj/machinery/door/airlock/phoron/proc/PhoronBurn(temperature)
	for(var/turf/simulated/floor/target_tile in range(2, loc))
		target_tile.assume_gas("phoron", 35, 400 + T0C)
		INVOKE_ASYNC(target_tile, /turf/simulated/floor.proc/hotspot_expose, temperature, 400)

	for(var/obj/structure/falsewall/phoron/F in range(3, src))//Hackish as fuck, but until temperature_expose works, there is nothing I can do -Sieve
		var/turf/T = get_turf(F)
		T.ChangeTurf(/turf/simulated/wall/mineral/phoron)
		qdel(F)

	for(var/turf/simulated/wall/mineral/phoron/W in range(3, src))
		W.ignite((temperature / 4))//Added so that you can't set off a massive chain reaction with a small flame

	for(var/obj/machinery/door/airlock/phoron/D in range(3, src))
		D.ignite(temperature / 4)

	new/obj/structure/door_assembly( src.loc )
	qdel(src)

/obj/machinery/door/airlock/clown
	name = "bananium airlock"
	icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
	mineral = "clown"
	door_open_sound = 'sound/items/bikehorn.ogg'
	door_close_sound = 'sound/items/bikehorn.ogg'

/obj/machinery/door/airlock/sandstone
	name = "sandstone airlock"
	icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	mineral = "sandstone"


/*******************************
* Station airlocks mineral glass
*/

/obj/machinery/door/airlock/gold/glass
	name    = "glass gold airlock"
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/phoron/glass
	name    = "glass phoron airlock"
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/silver/glass
	name    = "glass silver airlock"
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/diamond/glass
	name    = "glass diamond airlock"
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/uranium/glass
	name    = "glass uranium airlock"
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/clown/glass
	name    = "glass bananium airlock"
	opacity = FALSE
	glass   = TRUE

/obj/machinery/door/airlock/sandstone/glass
	name    = "glass sandstone airlock"
	opacity = FALSE
	glass   = TRUE


/***********************
* Station airlocks glass
*/

/obj/machinery/door/airlock/glass
	name          = "glass airlock"
	icon          = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	opacity       = FALSE
	glass         = TRUE


/******************
* External airlocks
*/

/obj/machinery/door/airlock/external
	name          = "external airlock"
	icon          = 'icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_ext


/***************
* Vault airlocks
*/

/obj/machinery/door/airlock/vault
	name          = "vault airlock"
	icon          = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_vault


/***************
* Hatch airlocks
*/

/obj/machinery/door/airlock/hatch
	name          = "airtight hatch"
	icon          = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_hatch

/obj/machinery/door/airlock/maintenance_hatch
	name          = "maintenance hatch"
	icon          = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_mhatch


/***********************
* High security airlocks
*/

/obj/machinery/door/airlock/highsecurity
	name          = "high tech security airlock"
	icon          = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
	overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity


/*****************
* Shuttle airlocks
*/

/obj/machinery/door/airlock/wagon
	icon          = 'icons/obj/doors/airlocks/shuttle/wagon.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	opacity       = FALSE
	glass         = TRUE

	assembly_type = /obj/structure/door_assembly/door_assembly_neutral

/obj/machinery/door/airlock/erokez
	icon          = 'icons/obj/doors/airlocks/shuttle/erokez.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'

	assembly_type = /obj/structure/door_assembly/door_assembly_neutral


/*****************
* Centcom airlocks
*/

/obj/machinery/door/airlock/centcom
	icon          = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'


/******************
* Mutitile airlocks
*/

/obj/machinery/door/airlock/multi_tile
	var/width = 2

/obj/machinery/door/airlock/multi_tile/atom_init()
	. = ..()
	if(dir in list(EAST, WEST))
		bound_width  = world.icon_size
		bound_height = width * world.icon_size
	else
		bound_width  = width * world.icon_size
		bound_height = world.icon_size

/obj/machinery/door/airlock/multi_tile/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(dir in list(EAST, WEST))
		bound_width  = world.icon_size
		bound_height = width * world.icon_size
	else
		bound_width  = width * world.icon_size
		bound_height = world.icon_size

/obj/machinery/door/airlock/multi_tile/glass
	name          = "glass mutitile airlock"
	icon          = 'icons/obj/doors/airlocks/multi_tile/multi_tile.dmi'
	overlays_file = 'icons/obj/doors/airlocks/multi_tile/overlays.dmi'
	opacity       = FALSE
	glass         = TRUE

	assembly_type = /obj/structure/door_assembly/multi_tile

/obj/machinery/door/airlock/multi_tile/attackby(C, mob/user)
	if(istype(C, /obj/item/weapon/airlock_painter))
		to_chat(user, "<span class='red'>This airlock cannot be painted.</span>")
	else
		return ..()


/*******************
* Mutitile2 airlocks
*/

/obj/machinery/door/airlock/multi_tile/metal
	name          = "metal mutitile airlock"
	icon          = 'icons/obj/doors/airlocks/multi_tile2/multi_tile.dmi'
	overlays_file = 'icons/obj/doors/airlocks/multi_tile2/overlays.dmi'

	assembly_type = /obj/structure/door_assembly/multi_tile
