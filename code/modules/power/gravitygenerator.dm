// It.. uses a lot of power.  Everything under power is engineering stuff, at least.

/obj/machinery/computer/gravity_control_computer
	name = "Gravity Generator Control"
	desc = "A computer to control a local gravity generator.  Qualified personnel only."
	icon = 'icons/obj/computer.dmi'
	icon_state = "airtunnel"
	state_broken_preset = "atmosb"
	state_nopower_preset = "atmos0"
	anchored = TRUE
	density = TRUE
	var/obj/machinery/gravity_generator = null


/obj/machinery/gravity_generator
	name = "Gravitational Generator"
	desc = "A device which produces a gravaton field when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 1000
	var/on = 1
	var/list/localareas = list()
	var/effectiverange = 25

	// Borrows code from cloning computer
/obj/machinery/computer/gravity_control_computer/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/gravity_control_computer/atom_init_late()
	updatemodules()

/obj/machinery/gravity_generator/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/gravity_generator/atom_init_late()
	locatelocalareas()

/obj/machinery/computer/gravity_control_computer/proc/updatemodules()
	src.gravity_generator = findgenerator()



/obj/machinery/gravity_generator/proc/locatelocalareas()
	for(var/area/A in range(src,effectiverange))
		if(A.name == "Space")
			continue // No (de)gravitizing space.
		if(!(A in localareas))
			localareas += A

/obj/machinery/computer/gravity_control_computer/proc/findgenerator()
	var/obj/machinery/gravity_generator/foundgenerator = null
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		//world << "SEARCHING IN [dir]"
		foundgenerator = locate(/obj/machinery/gravity_generator, get_step(src, dir))
		if (!isnull(foundgenerator))
			//world << "FOUND"
			break
	return foundgenerator

/obj/machinery/computer/gravity_control_computer/ui_interact(mob/user)
	updatemodules()

	var/dat
	if(gravity_generator)
		if(gravity_generator:on)
			dat += "<span class='green'><br>Gravity Status: ON</span><br>"
		else
			dat += "<span class='red'><br>Gravity Status: OFF</span><br>"

		dat += "<br>Currently Supplying Gravitons To:<br>"

		for(var/area/A in gravity_generator:localareas)
			if(A.has_gravity && gravity_generator:on)
				dat += "<span class='green'>[A]</span><br>"
			else if (A.has_gravity)
				dat += "<span class='yellow'>[A]</span><br>"
			else
				dat += "<span class='red'>[A]</span><br>"

		dat += "<br>Maintainence Functions:<br>"
		dat += "TURN GRAVITY GENERATOR: "
		if(gravity_generator:on)
			dat += "<a class='red' href='byond://?src=\ref[src];gentoggle=1'>OFF</a>"
		else
			dat += "<a class='green' href='byond://?src=\ref[src];gentoggle=1'>ON</a>"

	else
		dat += "No local gravity generator detected!"

	var/datum/browser/popup = new(user, "gravgen", "Generator Control System")
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/gravity_control_computer/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["gentoggle"])
		if(gravity_generator:on)
			gravity_generator:on = 0

			for(var/area/A in gravity_generator:localareas)
				var/obj/machinery/gravity_generator/G
				for(G in machines)
					if((A in G.localareas) && (G.on))
						break
				if(!G)
					A.gravitychange(FALSE)


		else
			for(var/area/A in gravity_generator:localareas)
				gravity_generator:on = 1
				A.gravitychange(TRUE)

	updateUsrDialog()
