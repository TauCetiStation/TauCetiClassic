/*=====================================================================================================================================
     === Explanation for some variables ===

volume_channel = must always present in args, connected with the slider that controls its volume for client. Check VOL_* defines for available sliders [code\__DEFINES\sound.dm].
ignore_environment = when you need to ignore environment effects that may change sound if mob is unconscious or anything else (e.g. global OOC announcement).
voluminosity = if FALSE, removes the difference between left and right ear.

     === Important notes for all soundmakers ===

* !!! DO NOT USE `<<` !!!. Use playsound_local() instead of this with right arguments.
* Before you create a new channel, put it in a file which is located in [code\__DEFINES\sound.dm].
* For music there is playsound_music() proc.

=======================================================================================================================================*/

// Default override for echo
/sound
	echo = list(
		0,		// Direct
		0,		// DirectHF
		-10000,	// Room, -10000 means no low frequency sound reverb
		-10000,	// RoomHF, -10000 means no high frequency sound reverb
		0,		// Obstruction
		0,		// ObstructionLFRatio
		0,		// Occlusion
		0.25,	// OcclusionLFRatio
		1.5,	// OcclusionRoomRatio
		1.0,	// OcclusionDirectRatio
		0,		// Exclusion
		1.0,	// ExclusionLFRatio
		0,		// OutsideVolumeHF
		0,		// DopplerFactor
		0,		// RolloffFactor
		0,		// RoomRolloffFactor
		1.0,	// AirAbsorptionFactor
		0,		// Flags (1 = Auto Direct, 2 = Auto Room, 4 = Auto RoomHF)
	)

/turf
	var/sound_coefficient = 1.0

/proc/playsound(atom/source, soundin, volume_channel = NONE, vol = 100, vary = TRUE, frequency = null, extrarange = 0, falloff, channel, wait, ignore_environment = FALSE, voluminosity = TRUE, use_reverb = TRUE)
	if(isarea(source))
		CRASH("[source] is an area and is trying to make the sound: [soundin]")

	var/turf/turf_source = get_turf(source)
	if(!turf_source) // In null space, no one can hear you scream.
		return

	var/max_distance = (world.view + extrarange) * 3

	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/P in player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue

		var/distance = get_dist(M, turf_source)
		if(distance <= max_distance)
			var/turf/T = get_turf(M)

			if(T && T.z == turf_source.z)
				M.playsound_local(turf_source, soundin, volume_channel, vol, vary, frequency, falloff, channel, null, wait, ignore_environment, use_reverb)

// little helper for timed sounds, because we can't use named arguments in callback and it's hard to track all these null, null, null...
/mob/proc/playsound_local_timed(delay, turf/turf_source, soundin, volume_channel, vol, vary, frequency, falloff, channel, repeat, wait, ignore_environment, voluminosity, use_reverb, distance_multiplier)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob, playsound_local), turf_source, soundin, volume_channel, vol, vary, frequency, falloff, channel, repeat, wait, ignore_environment, voluminosity, use_reverb, distance_multiplier), delay)

// todo: inconsistent behaviour and meaning of first parameter in playsound/playsound_local
// we have different arguments order compared to tg or other codebases, keep it in mind while porting stuff
/mob/proc/playsound_local(turf/turf_source, soundin, volume_channel = NONE, vol = 100, vary = TRUE, frequency = null, falloff, channel, repeat, wait, ignore_environment = FALSE, voluminosity = TRUE, use_reverb = TRUE, distance_multiplier = 1)
	if(!client || !client.prefs_ready || !ignore_environment && ear_deaf > 0)
		return

	vol = SANITIZE_VOL(vol) // only required as long as environment is used, otherwise remove everywhere.
	vol *= client.get_sound_volume(volume_channel)
	if(!vol)
		return

	var/sound/S = sound(soundin)
	S.repeat = repeat
	S.wait = wait
	S.channel = channel // Note. Channel 802 is busy with sound of automatic AI announcements
	S.volume = vol
	S.environment = SOUND_AREA_DEFAULT // this is the default environment and should not ever be ignored or overwrited (this exact line).
	S.frequency = 1

	if(frequency)
		S.frequency = frequency
	if(playsound_frequency_admin)
		S.frequency *= playsound_frequency_admin
	if(vary)
		S.frequency *= rand(8, 12) * 0.1

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source) * distance_multiplier

		S.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

		if (S.volume <= 0) // no volume means no sound, early check to save on atmos calls
			return

		//sound volume falloff with pressure
		var/pressure_factor = 1.0

		var/datum/gas_mixture/hearer_env = T.return_air()
		var/datum/gas_mixture/source_env = turf_source.return_air()

		if (hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())

			if (pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE) / (ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //in space
			pressure_factor = 0

		if (distance <= 1)
			pressure_factor = max(pressure_factor, 0.15)	//hearing through contact

		S.volume *= pressure_factor
		S.volume *= turf_source.sound_coefficient
		S.volume *= max(T.sound_coefficient, 0.0)

		if (S.volume <= 0)
			return	//no volume means no sound

		if(voluminosity)
			var/dx = turf_source.x - T.x // Hearing from the right/left
			S.x = dx * distance_multiplier
			var/dz = turf_source.y - T.y // Hearing from infront/behind
			S.z = dz * distance_multiplier
			// The y value is for above your head, but there is no ceiling in 2d spessmens.
			S.y = 1
			S.falloff = (falloff ? falloff : 0.5)

	if(!ignore_environment)
		var/area/A = get_area(src)
		S.environment = A.sound_environment // area's defaults is SOUND_AREA_DEFAULT

		if(stat == UNCONSCIOUS) // unconscious people will hear illegible sounds
			S.volume *= 0.3
			S.environment = SOUND_ENVIRONMENT_HANGAR
		else
			if(is_dizzy == TRUE || is_jittery == TRUE)
				S.environment = SOUND_ENVIRONMENT_PSYCHOTIC
			else
				if(isliving(src))
					var/mob/living/L = src
					if(L.drunkenness >= DRUNKENNESS_BLUR || druggy > 0 && get_species(L) != SKRELL)
						S.environment = SOUND_ENVIRONMENT_DRUGGED

		if(use_reverb && S.environment != SOUND_AREA_DEFAULT) // We have reverb, reset our echo setting
			S.echo[3] = 0 //Room setting, 0 means normal reverb
			S.echo[4] = 0 //RoomHF setting, 0 means normal reverb.

	src << S

/mob/living/parasite/playsound_local(turf/turf_source, soundin, volume_channel = NONE, vol = 100, vary = TRUE, frequency = null, falloff, channel, repeat, wait, ignore_environment = FALSE, voluminosity = TRUE, use_reverb = TRUE, distance_multiplier = 1)
	if(!host || host.ear_deaf > 0)
		return
	return ..()

/mob/proc/playsound_lobbymusic()
	if(!SSticker || !SSticker.login_music || !client)
		return
	playsound_music(SSticker.login_music, VOL_MUSIC, null, null, CHANNEL_MUSIC) // MAD JAMS

/mob/proc/playsound_music(soundin, volume_channel = NONE, repeat = FALSE, wait = FALSE, channel = 0, priority = 0, status = 0) // byond vars sorted by ref order.
	if(!client || !client.prefs_ready)
		return

	var/vol = SANITIZE_VOL(100) * client.get_sound_volume(volume_channel)

	/*
	This will stop stealth sending of ambient music to the client,
	but still keep ability to resume admin music on the fly mid position
	*/

	if(!vol && volume_channel != VOL_ADMIN)
		return

	var/sound/S

	if(istext(soundin))
		S = new(soundin) // for S.file byond expects 'files', dinamic path works only in new/sound
		if(!S)
			CRASH("wrong path in \"soundin\" argument [soundin]")
	else if(isfile(soundin))
		S = new
		S.file = soundin
	else
		CRASH("wrong type in \"soundin\" argument [soundin]")

	S.repeat = repeat
	S.wait = wait
	S.channel = channel
	S.priority = priority
	S.status = status
	S.volume = vol
	S.environment = SOUND_AREA_DEFAULT
	src << S

/mob/proc/playsound_music_update_volume(volume_channel, channel)
	if(!client || !client.prefs_ready)
		return

	var/sound/S = new
	S.volume = SANITIZE_VOL(100) * client.get_sound_volume(volume_channel)
	S.channel = channel
	S.status = SOUND_UPDATE | SOUND_STREAM
	S.environment = SOUND_AREA_DEFAULT
	src << S

/mob/proc/playsound_stop(_channel)
	src << sound(null, repeat = 0, wait = 0, channel = _channel)

/client/proc/get_sound_volume(volume_channel)
	if(!isnum(volume_channel) || !volume_channel)
		CRASH("type mismatch for volume_channel or volume channel is not set.")

	if(volume_channel & VOL_MUSIC)
		. = prefs.get_pref(/datum/pref/player/audio/lobby)
	else if(volume_channel & VOL_AMBIENT)
		. = prefs.get_pref(/datum/pref/player/audio/ambient)
	else if(volume_channel & VOL_EFFECTS_MASTER)
		. = prefs.get_pref(/datum/pref/player/audio/effect_master)
		switch(volume_channel) // now for sub categories
			if(VOL_EFFECTS_VOICE_ANNOUNCEMENT)
				. *= prefs.get_pref(/datum/pref/player/audio/effect_announcement) * 0.01
			if(VOL_EFFECTS_MISC)
				. *= prefs.get_pref(/datum/pref/player/audio/effect_misc) * 0.01
			if(VOL_EFFECTS_INSTRUMENT)
				. *= prefs.get_pref(/datum/pref/player/audio/effect_instrument) * 0.01
	else if(volume_channel & VOL_NOTIFICATIONS)
		. = prefs.get_pref(/datum/pref/player/audio/notifications)
	else if(volume_channel & VOL_ADMIN)
		. = prefs.get_pref(/datum/pref/player/audio/admin_sound)
	else if(volume_channel & VOL_JUKEBOX)
		. = prefs.get_pref(/datum/pref/player/audio/jukebox)
	else
		CRASH("unknown volume_channel: [volume_channel]")

	if(. > 0)
		. = max(0.002, VOL_LINEAR_TO_NON(.)) // max(master slider won't kill sub slider's volume if both are less than max value).
