/datum/role/blob_overmind
	name = BLOBOVERMIND
	id = BLOBOVERMIND
	required_pref = ROLE_BLOB
	logo_state = "blob-logo"
	greets = list(GREET_DEFAULT,GREET_CUSTOM)

	restricted_jobs = list("Cyborg", "AI")
	restricted_species_flags = list(IS_SYNTHETIC)

/datum/role/blob_overmind/cerebrate
	name = BLOBCEREBRATE
	id = BLOBCEREBRATE
	logo_state = "cerebrate-logo"

/datum/role/blob_overmind/OnPostSetup(laterole)
	. = ..()
	var/wait_time = rand(INTERCEPT_TIME_LOW, INTERCEPT_TIME_HIGH)
	var/time_to_stage1 = wait_time
	var/time_to_stage2 = wait_time * 2
	var/time_to_stage3 = wait_time * 2 + wait_time / 2

	addtimer(CALLBACK(src, .proc/stage1), time_to_stage1)
	addtimer(CALLBACK(src, .proc/stage2), time_to_stage2)
	addtimer(CALLBACK(src, .proc/stage3), time_to_stage3)

/datum/role/blob_overmind/proc/stage1()
	if(!antag || !antag.current)
		return

	to_chat(antag.current, "<span class='alert'>You feel tired and bloated.</span>")

/datum/role/blob_overmind/proc/stage2()
	if(!antag || !antag.current)
		return

	to_chat(antag.current, "<span class='alert'>You feel like you are about to burst.</span>")

/datum/role/blob_overmind/proc/stage3()
	if(!antag || !antag.current)
		return

	burst()

/datum/role/blob_overmind/proc/burst()
	if(!antag || isovermind(antag.current))
		return

	var/client/blob_client = null
	var/turf/location = null

	if(iscarbon(antag.current))
		var/mob/living/carbon/C = antag.current
		if(directory[ckey(antag.key)])
			blob_client = directory[ckey(antag.key)]
			location = get_turf(C)
			if(!is_station_level(location.z)|| istype(location, /turf/space))
				location = null
			C.gib()

	if(blob_client && location)
		new /obj/effect/blob/core(location, blob_client, 200, 3)
	Drop()

/datum/role/blob_overmind/Greet(greeting,custom)
	if(!..())
		return FALSE
	if(!antag || isovermind(antag.current))
		return FALSE

	to_chat(antag.current, "<span class='warning'>Your body is ready to give spawn to a new blob core which will eat this station.</span>")
	to_chat(antag.current, "<span class='warning'>Find a good location to spawn the core and then take control and overwhelm the station!</span>")
	to_chat(antag.current, "<span class='warning'>When you have found a location, wait until you spawn; this will happen automatically and you cannot speed up the process.</span>")
	to_chat(antag.current, "<span class='warning'>If you go outside of the station level, or in space, then you will die; make sure your location has lots of ground to cover.</span>")

	return TRUE
