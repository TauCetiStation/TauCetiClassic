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
		. = prefs.snd_music_vol
	else if(volume_channel & VOL_AMBIENT)
		. = prefs.snd_ambient_vol
	else if(volume_channel & VOL_EFFECTS_MASTER)
		. = prefs.snd_effects_master_vol
		switch(volume_channel) // now for sub categories
			if(VOL_EFFECTS_VOICE_ANNOUNCEMENT)
				. *= prefs.snd_effects_voice_announcement_vol * 0.01
			if(VOL_EFFECTS_MISC)
				. *= prefs.snd_effects_misc_vol * 0.01
			if(VOL_EFFECTS_INSTRUMENT)
				. *= prefs.snd_effects_instrument_vol * 0.01
	else if(volume_channel & VOL_NOTIFICATIONS)
		. = prefs.snd_notifications_vol
	else if(volume_channel & VOL_ADMIN)
		. = prefs.snd_admin_vol
	else if(volume_channel & VOL_JUKEBOX)
		. = prefs.snd_jukebox_vol
	else
		CRASH("unknown volume_channel: [volume_channel]")

	if(. > 0)
		. = max(0.002, VOL_LINEAR_TO_NON(.)) // max(master slider won't kill sub slider's volume if both are less than max value).

/client/proc/set_sound_volume(volume_channel, vol)
	vol = clamp(vol, 0, 100)

	switch(volume_channel)
		if(VOL_MUSIC)
			prefs.snd_music_vol = vol
			mob.playsound_music_update_volume(volume_channel, CHANNEL_MUSIC)
		if(VOL_AMBIENT)
			prefs.snd_ambient_vol = vol
			mob.playsound_music_update_volume(volume_channel, CHANNEL_AMBIENT)
			mob.playsound_music_update_volume(volume_channel, CHANNEL_AMBIENT_LOOP)
		if(VOL_EFFECTS_MASTER)
			prefs.snd_effects_master_vol = vol
		if(VOL_EFFECTS_VOICE_ANNOUNCEMENT)
			prefs.snd_effects_voice_announcement_vol = vol
		if(VOL_EFFECTS_MISC)
			prefs.snd_effects_misc_vol = vol
		if(VOL_EFFECTS_INSTRUMENT)
			prefs.snd_effects_instrument_vol = vol
		if(VOL_NOTIFICATIONS)
			prefs.snd_notifications_vol = vol
		if(VOL_ADMIN)
			prefs.snd_admin_vol = vol
			mob.playsound_music_update_volume(volume_channel, CHANNEL_ADMIN)
		if(VOL_JUKEBOX)
			var/old_vol = prefs.snd_jukebox_vol

			prefs.snd_jukebox_vol = vol

			if(istype(media)) // will be updated in "/mob/living/Login()" if changed in lobby.
				media.update_volume()

				if(!vol && old_vol) // only play/stop if last change is a mute or unmute state.
					media.stop_music()
				else if(vol && !old_vol)
					media.update_music()

/client/proc/update_volume(href_list)
	var/slider
	var/vol_raw

	switch(href_list["proc"])
		if("sliderMoved")
			slider = text2num(href_list["slider"])
			vol_raw = text2num(href_list["volume"])
		if("save")
			if(prefs.save_preferences())
				to_chat(src, "Preferences Saved.")
			else
				to_chat(src, "Preferences saving failed due to unknown reason.")
			return
		if("testVolume")
			mob.playsound_local(null, 'sound/weapons/saberon.ogg', text2num(href_list["slider"]), vary = FALSE, channel = CHANNEL_VOLUMETEST)
			return
		else
			return

	if(!isnum(vol_raw) || !isnum(slider))
		return

	set_sound_volume(slider, vol_raw)

/client/verb/show_volume_controls()
	set name = ".showvolumecontrols"
	set hidden = TRUE

	if(!prefs_ready)
		to_chat(src, "Preferences not ready, please wait and try again.")
		return

	var/list/tables_data = list(
		"Music" = list(
			"Master" = "[VOL_MUSIC]"
			),
		"Ambient" = list(
			"Master" = "[VOL_AMBIENT]"
			),
		"Effects" = list(
			"Master" = "[VOL_EFFECTS_MASTER]",
			"Voice" = "[VOL_EFFECTS_VOICE_ANNOUNCEMENT]",
			"Misc" = "[VOL_EFFECTS_MISC]",
			"Music Instruments" = "[VOL_EFFECTS_INSTRUMENT]"
			),
		"Notifications" = list(
			"Master" = "[VOL_NOTIFICATIONS]"
			),
		"Admin Music/Sounds" = list(
			"Master" = "[VOL_ADMIN]"
			),
		"Jukebox" = list(
			"Master" = "[VOL_JUKEBOX]"
			)
		)

	var/list/prefs_vol_values = list(
		"[VOL_MUSIC]" = prefs.snd_music_vol,
		"[VOL_AMBIENT]" = prefs.snd_ambient_vol,
		"[VOL_EFFECTS_MASTER]" = prefs.snd_effects_master_vol,
		"[VOL_EFFECTS_VOICE_ANNOUNCEMENT]" = prefs.snd_effects_voice_announcement_vol,
		"[VOL_EFFECTS_MISC]" = prefs.snd_effects_misc_vol,
		"[VOL_EFFECTS_INSTRUMENT]" = prefs.snd_effects_instrument_vol,
		"[VOL_NOTIFICATIONS]" = prefs.snd_notifications_vol,
		"[VOL_ADMIN]" = prefs.snd_admin_vol,
		"[VOL_JUKEBOX]" = prefs.snd_jukebox_vol
		)

	var/list/sliders_hint = list(
		"[VOL_MUSIC]" = "Lobby music.",
		"[VOL_AMBIENT]" = "Music and sound effects of ambient type.",
		"[VOL_EFFECTS_MASTER]" = "Controls all sound effects.",
		"[VOL_EFFECTS_VOICE_ANNOUNCEMENT]" = "Voiced global announcements.",
		"[VOL_EFFECTS_MISC]" = "Anything spammy that may annoy e.g.: tesla engine.",
		"[VOL_EFFECTS_INSTRUMENT]" = "Music instruments.",
		"[VOL_NOTIFICATIONS]" = "OOC notifications such as admin PM, cloning.",
		"[VOL_ADMIN]" = "Admin sounds and music.",
		"[VOL_JUKEBOX]" = "In-game jukebox's volume."
		)

	var/dat = {"
		<style>
			.volume_slider {
				width: 100%;
				position: relative;
				padding: 0;
			}
			table {
				line-height: 5px;
				width: 100%;
				border-collapse: collapse;
				border: 1px solid;
				padding: 0;
			}
			td {
				width: 25%;
			}
			td:nth-child(2n+0) {
				width: 65%;
			}
			td:nth-child(3n+0) {
				width: 10%;
			}
			caption {
				line-height: normal;
				color: white;
				background-color: #444;
				font-weight: bold;
			}
		</style>
		"}

	for(var/category in tables_data)
		dat += {"
			<table>
				<caption>[category]</caption>
		"}

		var/list/sliders_data = tables_data[category]

		for(var/slider_name in sliders_data)
			var/slider_id = sliders_data[slider_name]
			var/slider_value = prefs_vol_values[slider_id]
			var/slider_hint = sliders_hint[slider_id]
			dat += {"
				<tr>
					<td>
						[slider_name] <span title="[slider_hint]">(?)</span>:
					</td>
					<td>
						<input type="range" class="volume_slider" min="0" max="100" value="[slider_value]" id="[slider_id]" onchange="updateVolume([slider_id])">
					</td>
					<td>
						<p><b><center><a href='?_src_=updateVolume&proc=testVolume&slider=[slider_id]'><span id="[slider_id]_value">[slider_value]</span></a></center></b></p>
					</td>
				</tr>
			"}

		dat += {"
			</table>
		"}

	dat +={"
		<p><span id="notice">&nbsp;</span></p>
		<input type="button" min="0" max="100" value="Save" id="myRange" onclick="saveVolume()">

		<script>
			var volumeUpdating = false

			function saveVolume() {
				window.location = 'byond://?_src_=updateVolume&proc=save';
				showHint('check \"Preferences Saved\" message in chat, if nothing push \"Save\" again.')
			}

			function updateVolume(slider_id) {
				if (!volumeUpdating) {
					volumeUpdating = true;
					setTimeout(function() {
						setVolume(slider_id);
					}, 300);
				}

			}

			function setVolume(slider_id) {
				var vol = document.getElementById(slider_id).value;
				window.location = 'byond://?_src_=updateVolume&proc=sliderMoved&slider=' + slider_id + '&volume=' + vol;
				volumeUpdating = false;

				document.getElementById(slider_id + "_value").innerHTML = vol;
			}

			function showHint(text) {
				document.getElementById("notice").innerHTML = '<b>Hint: ' + text + '</b>';
			}

		</script>
		"}

	var/datum/browser/popup = new(usr, "volcontrols", "Audio Settings:", 620, 500, null, CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()
