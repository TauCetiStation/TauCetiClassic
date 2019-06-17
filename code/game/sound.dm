/*=====================================================================================================================================
     === Explanation for some variables ===

var/is_global = if true then do not add echo to the sound
var/voluminosity = is that 3d sound? If false then ignore the coordinates of the sound(become a sort of mono sound)
var/src_vol = volume for its source. Separate sound volume for its source and for others? Make a "special" volume for the source?


     === Important notes for all soundmakers ===

* !!! DO NOT USE `<<` !!!. Use send_sound() instead of this.
* Before you create a new new channel, put it in a file which is located in [code\__DEFINES\sound.dm].

=======================================================================================================================================*/
/proc/playsound(atom/source, soundin, vol, vary, extrarange, falloff, channel = 0, is_global, wait = 0, voluminosity = TRUE, src_vol)
	soundin = get_sfx(soundin) // same sound for everyone

	if(isarea(source))
		error("[source] is an area and is trying to make the sound: [soundin]")
		return

	var/frequency = get_rand_frequency() // Same frequency for everybody
	var/turf/turf_source = get_turf(source)

	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/P in player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue
		if((M == source) && (src_vol != null))
			M.playsound_local(null, soundin, src_vol, vary, frequency, falloff, channel)
			continue

		var/distance = get_dist(M, turf_source)
		if(distance <= (world.view + extrarange) * 3)
			var/turf/T = get_turf(M)

			if(T && T.z == turf_source.z)
				M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, channel, is_global, wait, voluminosity)

var/const/FALLOFF_SOUNDS = 0.5

/mob/proc/playsound_local(turf/turf_source, soundin, vol, vary, frequency, falloff, channel = 0, is_global, wait = 0, voluminosity = TRUE)
	if(!src.client || ear_deaf > 0)
		return FALSE
	soundin = get_sfx(soundin) //todo: it is very stupid that we search this sound in sfx every time for every player TWICE, and from start soundin may already be path to sound file...

	var/sound/S = sound(soundin)
	//S.wait = 0 //No queue
	//S.channel = 0 //Any channel
	S.wait = wait
	S.channel = channel // Note. Channel 802 is busy with sound of automatic AI announcements
	S.volume = vol
	S.environment = -1
	if (vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		S.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

		//sound volume falloff with pressure
		var/pressure_factor = 1.0

		var/datum/gas_mixture/hearer_env = T.return_air()
		var/datum/gas_mixture/source_env = turf_source.return_air()

		if (hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())

			if (pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //in space
			pressure_factor = 0

		if (distance <= 1)
			pressure_factor = max(pressure_factor, 0.15)	//hearing through contact

		S.volume *= pressure_factor

		if (S.volume <= 0)
			return FALSE	//no volume means no sound

		if(voluminosity)
			var/dx = turf_source.x - T.x // Hearing from the right/left
			S.x = dx
			var/dz = turf_source.y - T.y // Hearing from infront/behind
			S.z = dz
			// The y value is for above your head, but there is no ceiling in 2d spessmens.
			S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)
	if(!is_global)
		S.environment = 2
	if(src.stat == UNCONSCIOUS || src.sleeping > 0) // unconscious people will hear illegible sounds
		S.volume /= 3
		S.environment = 10
	src << S

/mob/living/parasite/playsound_local(turf/turf_source, soundin, vol, vary, frequency, falloff, channel = 0, is_global)
	if(!host || host.ear_deaf > 0)
		return FALSE
	return ..()

/client/proc/playtitlemusic()
	if(!ticker || !ticker.login_music)	return
	if(prefs.toggles & SOUND_LOBBY)
		send_sound(src, ticker.login_music, 85, CHANNEL_LOBBY_MUSIC) // MAD JAMS

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/send_sound(target, sound, volume = 100, channel = 0, repeat = 0, wait = 0)
	var/sound/S = sound(sound)
	S.volume = volume
	S.channel = channel
	S.repeat = repeat
	S.wait = wait
	S.environment = 2 // To solve all environment problems in playsound() and playsound_local()
	target << S

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("shatter")
				soundin = pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')
			if ("explosion")
				soundin = pick('sound/effects/explosion1.ogg','sound/effects/explosion2.ogg')
			if ("sparks")
				soundin = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
			if ("rustle")
				soundin = pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
			if ("bodyfall")
				soundin = pick('sound/effects/bodyfall1.ogg','sound/effects/bodyfall2.ogg','sound/effects/bodyfall3.ogg','sound/effects/bodyfall4.ogg')
			if ("punch")
				soundin = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
			if ("clownstep")
				soundin = pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
			if ("swing_hit")
				soundin = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
			if ("hiss")
				soundin = pick('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
			if ("pageturn")
				soundin = pick('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
			if ("desceration")
				soundin = pick('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg')
			if ("im_here")
				soundin = pick('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg')
			if ("can_open")
				soundin = pick('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
			if ("law")
				soundin = pick('sound/voice/beepsky/god.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/beepsky/secureday.ogg', 'sound/voice/beepsky/radio.ogg', 'sound/voice/beepsky/insult.ogg', 'sound/voice/beepsky/creep.ogg')
			if ("bandg")
				soundin = pick('sound/items/bandage.ogg', 'sound/items/bandage2.ogg', 'sound/items/bandage3.ogg')
			if ("fracture")
				soundin = pick('sound/effects/bonebreak1.ogg', 'sound/effects/bonebreak2.ogg', 'sound/effects/bonebreak3.ogg', 'sound/effects/bonebreak4.ogg')
			if ("footsteps")
				soundin = pick('sound/effects/tile1.wav', 'sound/effects/tile2.wav', 'sound/effects/tile3.wav', 'sound/effects/tile4.wav')
			if ("rigbreath")
				soundin = pick('sound/misc/rigbreath1.ogg','sound/misc/rigbreath2.ogg','sound/misc/rigbreath3.ogg')
			if ("breathmask")
				soundin = pick('sound/misc/breathmask1.ogg','sound/misc/breathmask2.ogg')
			if ("gasmaskbreath")
				soundin = 'sound/misc/gasmaskbreath.ogg'
			if ("malevomit")
				soundin = pick('sound/misc/mvomit1.ogg','sound/misc/mvomit2.ogg')
			if ("femalevomit")
				soundin = pick('sound/misc/fvomit1.ogg','sound/misc/fvomit2.ogg')
			if ("frigvomit")
				soundin = pick('sound/misc/frigvomit1.ogg','sound/misc/frigvomit2.ogg')
			if ("mrigvomit")
				soundin = pick('sound/misc/mrigvomit1.ogg','sound/misc/mrigvomit2.ogg')
			if ("keyboard")
				soundin = pick('sound/machines/keyboard/keyboard1.ogg', 'sound/machines/keyboard/keyboard2.ogg', 'sound/machines/keyboard/keyboard3.ogg', 'sound/machines/keyboard/keyboard4.ogg', 'sound/machines/keyboard/keyboard5.ogg')
			if ("pda")
				soundin = pick('sound/machines/keyboard/pda1.ogg', 'sound/machines/keyboard/pda2.ogg', 'sound/machines/keyboard/pda3.ogg', 'sound/machines/keyboard/pda4.ogg', 'sound/machines/keyboard/pda5.ogg')
	return soundin

/proc/get_announce_sound(soundin)
	if(istext(soundin))
		switch(soundin)
			if("downtogreen")
				. = 'sound/AI/downtogreen.ogg'
			if("blue")
				. = 'sound/AI/blue.ogg'
			if("downtoblue")
				. = 'sound/AI/downtoblue.ogg'
			if("red")
				. = 'sound/AI/red.ogg'
			if("downtored")
				. = 'sound/AI/downtored.ogg'
			if("radpassed")
				. = 'sound/AI/radpassed.ogg'
			if("radiation")
				. = pick('sound/AI/radiation1.ogg', 'sound/AI/radiation2.ogg', 'sound/AI/radiation3.ogg')
			if("noert")
				. = 'sound/AI/noert.ogg'
			if("yesert")
				. = 'sound/AI/yesert.ogg'
			if("meteors")
				. = pick('sound/AI/meteors1.ogg', 'sound/AI/meteors2.ogg')
			if("meteorcleared")
				. = 'sound/AI/meteorcleared.ogg'
			if("gravanom")
				. = 'sound/AI/gravanomalies.ogg'
			if("fluxanom")
				. = 'sound/AI/flux.ogg'
			if("vortexanom")
				. = 'sound/AI/vortex.ogg'
			if("bluspaceanom")
				. = 'sound/AI/blusp_anomalies.ogg'
			if("pyroanom")
				. = 'sound/AI/pyr_anomalies.ogg'
			if("wormholes")
				. = 'sound/AI/wormholes.ogg'
			if("outbreak7")
				. = 'sound/AI/outbreak7.ogg'
			if("outbreak5")
				. = pick('sound/AI/outbreak5_1.ogg', 'sound/AI/outbreak5_2.ogg')
			if("lifesigns")
				. = pick('sound/AI/lifesigns1.ogg', 'sound/AI/lifesigns2.ogg', 'sound/AI/lifesigns3.ogg')
			if("greytide")
				. = 'sound/AI/greytide.ogg'
			if("rampbrand")
				. = 'sound/AI/rampant_brand_int.ogg'
			if("carps")
				. = 'sound/AI/carps.ogg'
			if("estorm")
				. = 'sound/AI/e-storm.ogg'
			if("istorm")
				. = 'sound/AI/i-storm.ogg'
			if("poweroff")
				. = pick('sound/AI/poweroff1.ogg', 'sound/AI/poweroff2.ogg')
			if("poweron")
				. = 'sound/AI/poweron.ogg'
			if("gravoff")
				. = 'sound/AI/gravityoff.ogg'
			if("gravon")
				. = 'sound/AI/gravityon.ogg'
			if("artillery")
				. = 'sound/AI/artillery.ogg'
			if("icaruslost")
				. = 'sound/AI/icarus.ogg'
			if("fungi")
				. = 'sound/AI/fungi.ogg'
			if("emer_shut_called")
				. = 'sound/AI/emergency_s_called.ogg'
			if("emer_shut_recalled")
				. = 'sound/AI/emergency_s_recalled.ogg'
			if("emer_shut_docked")
				. = 'sound/AI/emergency_s_docked.ogg'
			if("emer_shut_left")
				. = 'sound/AI/emergency_s_left.ogg'
			if("crew_shut_called")
				. = 'sound/AI/crew_s_called.ogg'
			if("crew_shut_recalled")
				. = 'sound/AI/crew_s_recalled.ogg'
			if("crew_shut_docked")
				. = 'sound/AI/crew_s_docked.ogg'
			if("crew_shut_left")
				. = 'sound/AI/crew_s_left.ogg'
			if("malf")
				. = 'sound/AI/aimalf.ogg'
			if("malf1")
				. = 'sound/AI/ai_malf_1.ogg'
			if("malf2")
				. = 'sound/AI/ai_malf_2.ogg'
			if("malf3")
				. = 'sound/AI/ai_malf_3.ogg'
			if("malf4")
				. = 'sound/AI/ai_malf_4.ogg'
			if("aiannounce")
				. = 'sound/AI/aiannounce.ogg'
			if("nuke")
				. = 'sound/AI/nuke.ogg'
			if("animes")
				. = 'sound/AI/animes.ogg'
			if("announce")
				. = 'sound/AI/announce.ogg'
			if("commandreport")
				. = 'sound/AI/commandreport.ogg'
	if(!.)
		WARNING("No sound file for [soundin]")
