#define TIME_MIN 600
#define TIME_MAX 1800

/datum/role/blob_overmind
	name = BLOBOVERMIND
	id = BLOBOVERMIND
	required_pref = ROLE_BLOB
	logo_state = "blob-logo"
	greets = list(GREET_DEFAULT,GREET_CUSTOM)

	restricted_jobs = list("Cyborg", "AI")
	restricted_species_flags = list(IS_SYNTHETIC)

	var/countdown = 0

	var/time_to_burst

/datum/role/blob_overmind/cerebrate
	name = BLOBCEREBRATE
	id = BLOBCEREBRATE
	logo_state = "cerebrate-logo"

/datum/role/blob_overmind/New()
	..()
	time_to_burst = rand(TIME_MIN, TIME_MAX)

/datum/role/blob_overmind/process()
	..()
	if(!antag || istype(antag.current,/mob/camera/blob) || !antag.current || isobserver(antag.current))
		return
	if(countdown > time_to_burst)
		return

	countdown++
	if(countdown == time_to_burst / 4)
		to_chat(antag.current, "<span class='alert'>You feel tired and bloated.</span>")
	else if(countdown == time_to_burst / 2)
		to_chat(antag.current, "<span class='alert'>You feel like you are about to burst.</span>")
	else if(countdown == time_to_burst)
		burst()

/datum/role/blob_overmind/proc/burst()
	if(!antag || istype(antag.current,/mob/camera/blob))
		return

	var/client/blob_client = null
	var/turf/location = null

	if (faction)
		var/datum/faction/blob_conglomerate/the_bleb = faction
		the_bleb.declared = TRUE

	if(iscarbon(antag.current))
		var/mob/living/carbon/C = antag.current
		if(directory[ckey(antag.key)])
			blob_client = directory[ckey(antag.key)]
			location = get_turf(C)
			if(!is_station_level(location.z)|| istype(location, /turf/space))
				location = null
			C.gib()

	if(blob_client && location)
		new /obj/effect/blob/core(location, 200, blob_client, 3)
	Drop()

/datum/role/blob_overmind/Greet(greeting,custom)
	if(!..())
		return FALSE
	if(!antag || istype(antag.current,/mob/camera/blob))
		return FALSE

	to_chat(antag.current, "<span class='warning'>Your body is ready to give spawn to a new blob core which will eat this station.</span>")
	to_chat(antag.current, "<span class='warning'>Find a good location to spawn the core and then take control and overwhelm the station!</span>")
	to_chat(antag.current, "<span class='warning'>When you have found a location, wait until you spawn; this will happen automatically and you cannot speed up the process.</span>")
	to_chat(antag.current, "<span class='warning'>If you go outside of the station level, or in space, then you will die; make sure your location has lots of ground to cover.</span>")

	return TRUE

#undef TIME_MIN
#undef TIME_MAX
