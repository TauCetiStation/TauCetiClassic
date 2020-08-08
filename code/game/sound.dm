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

/proc/playsound(atom/source, soundin, volume_channel = NONE, vol = 100, vary = TRUE, extrarange = 0, falloff, channel, wait, ignore_environment = FALSE, voluminosity = TRUE)
	if(isarea(source))
		CRASH("[source] is an area and is trying to make the sound: [soundin]")

	var/turf/turf_source = get_turf(source)
	if(!turf_source) // In null space, no one can hear you scream.
		return

	var/max_distance = (world.view + extrarange) * 3
	var/frequency = get_rand_frequency() // Same frequency for everybody

	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/P in player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue

		var/distance = get_dist(M, turf_source)
		if(distance <= max_distance)
			var/turf/T = get_turf(M)

			if(T && T.z == turf_source.z)
				M.playsound_local(turf_source, soundin, volume_channel, vol, vary, frequency, falloff, channel, null, wait, ignore_environment, voluminosity)

//todo: inconsistent behaviour and meaning of first parameter in playsound/playsound_local
/mob/proc/playsound_local(turf/turf_source, soundin, volume_channel = NONE, vol = 100, vary = TRUE, frequency, falloff, channel, repeat, wait, ignore_environment = FALSE, voluminosity = TRUE)
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
	S.environment = 2 // this is the default environment and should not ever be ignored or overwrited (this exact line).

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
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE) / (ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //in space
			pressure_factor = 0

		if (distance <= 1)
			pressure_factor = max(pressure_factor, 0.15)	//hearing through contact

		S.volume *= pressure_factor

		if (S.volume <= 0)
			return	//no volume means no sound

		if(voluminosity)
			var/dx = turf_source.x - T.x // Hearing from the right/left
			S.x = dx
			var/dz = turf_source.y - T.y // Hearing from infront/behind
			S.z = dz
			// The y value is for above your head, but there is no ceiling in 2d spessmens.
			S.y = 1
			S.falloff = (falloff ? falloff : 0.5)
	if(!ignore_environment) // this is the entry point for any IC environment effects, don't mix this with OOC.
		if(stat == UNCONSCIOUS) // unconscious people will hear illegible sounds
			S.volume *= 0.3
			S.environment = 10
	src << S

/mob/living/parasite/playsound_local(turf/turf_source, soundin, volume_channel = NONE, vol = 100, vary = TRUE, frequency, falloff, channel, repeat, wait, ignore_environment = FALSE, voluminosity = TRUE)
	if(!host || host.ear_deaf > 0)
		return
	return ..()

/mob/proc/playsound_lobbymusic()
	if(!SSticker || !SSticker.login_music || !client)
		return
	playsound_music(SSticker.login_music, VOL_MUSIC, null, null, CHANNEL_MUSIC) // MAD JAMS

/mob/proc/playsound_music(soundin, volume_channel = NONE, repeat = FALSE, wait = FALSE, channel = 0, priority = 0, status = 0) // byond vars sorted by ref order.
	if(!isfile(soundin))
		CRASH("wrong type in \"soundin\" argument [soundin]")

	if(!client || !client.prefs_ready)
		return

	/*
	This will stop stealth sending of music to the client,
	but will kill the feature with the ability to resume music on the fly mid position, especially the ones that started by an admin.

	var/vol = SANITIZE_VOL(100) * client.get_sound_volume(volume_channel)
	if(!vol)
		return
	*/

	var/sound/S = new

	S.file = soundin
	S.repeat = repeat
	S.wait = wait
	S.channel = channel
	S.priority = priority
	S.status = status
	S.volume = SANITIZE_VOL(100) * client.get_sound_volume(volume_channel) // S.volume = vol <- replace line with this while uncommenting block of code from above.
	S.environment = 2
	src << S

/mob/proc/playsound_music_update_volume(volume_channel, channel)
	if(!client || !client.prefs_ready)
		return

	var/sound/S = new
	S.volume = SANITIZE_VOL(100) * client.get_sound_volume(volume_channel)
	S.channel = channel
	S.status = SOUND_UPDATE | SOUND_STREAM
	S.environment = 2
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
			mob.playsound_local(null, 'sound/weapons/saberon.ogg', text2num(href_list["slider"]), channel = CHANNEL_VOLUMETEST)
			return
		else
			return

	if(!isnum(vol_raw) || !isnum(slider))
		return

	set_sound_volume(slider, vol_raw)

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_announce_sound(soundin)
	if(istext(soundin))
		switch(soundin)
			if("delta")
				. = 'sound/AI/delta.ogg'
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
			if("bluspacetrans")
				. = 'sound/AI/mas-blu-spa_anomalies.ogg'
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

//	src << browse(dat, "window=volcontrols")
	var/datum/browser/popup = new(usr, "volcontrols", "Audio Settings:", 620, 500, null, CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()
