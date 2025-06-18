/mob/living/silicon
	gender = NEUTER
	robot_talk_understand = 1
	voice_name = "synthesized voice"
	hud_possible = list(ANTAG_HUD, HOLY_HUD, DIAG_STAT_HUD, DIAG_HUD)
	typing_indicator_type = "machine"

	var/list/sensor_huds = list(DATA_HUD_MEDICAL, DATA_HUD_SECURITY, DATA_HUD_DIAGNOSTIC)
	var/list/def_sensor_huds
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	immune_to_ssd = 1

	var/list/speech_synthesizer_langs = list()	//which languages can be vocalized by the speech synthesizer
	var/obj/item/device/pda/silicon/pda = null

	var/obj/item/device/camera/siliconcam/aiCamera = null //photography

	var/sensor_mode = FALSE //Determines the current HUD.

/mob/living/silicon/atom_init()
	. = ..()
	silicon_list += src
	def_sensor_huds = sensor_huds
	var/datum/atom_hud/data/diagnostic/diag_hud = global.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)
	diag_hud_set_status()
	diag_hud_set_health()
	update_manifest()

/mob/living/silicon/Destroy()
	silicon_list -= src
	update_manifest()
	return ..()

/mob/living/silicon/death(gibbed)
	diag_hud_set_status()
	diag_hud_set_health()
	update_manifest()
	return ..(gibbed)

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/proc/checklaws()
	return

/mob/living/silicon/proc/show_alerts()
	return

/mob/living/silicon/drop_item()
	return

/mob/living/silicon/med_hud_set_health()
	return //we use a different hud

/mob/living/silicon/med_hud_set_status()
	return //we use a different hud

/mob/living/silicon/emp_act(severity)
	switch(severity)
		if(1)
			take_bodypart_damage(20)
			Stun(rand(5,10))
		if(2)
			take_bodypart_damage(10)
			Stun(rand(1,5))
	if(stat != DEAD)
		flash_eyes(affect_silicon = 1)
		to_chat(src, "<span class='warning'><B>*BZZZT*</B></span>")
		to_chat(src, "<span class='warning'>Warning: Electromagnetic pulse detected.</span>")
		playsound(src, pick(SOUNDIN_SILICON_PAIN), VOL_EFFECTS_MASTER, vary = FALSE, frequency = null)
	..()

/mob/living/silicon/proc/damage_mob(brute = 0, fire = 0, tox = 0)
	return

/mob/living/silicon/IsAdvancedToolUser()
	return 1

/mob/living/silicon/apply_effect(effect = 0,effecttype = STUN, blocked = 0)
	return 0//The only effect that can hit them atm is flashes and they still directly edit so this works for now

/proc/islinked(mob/living/silicon/robot/bot, mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if (bot.connected_ai == ai)
		return 1
	return 0

// This is a pure virtual function, it should be overwritten by all subclasses
/mob/living/silicon/proc/show_malf_ai()
	return 0

// This adds the basic clock, shuttle recall timer, and malf_ai info to all silicon lifeforms
/mob/living/silicon/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Station Time: [worldtime2text()]")

		if(SSshuttle.online && SSshuttle.location < 2)
			stat(null, "ETA-[shuttleeta2text()]")

		if(stat == CONSCIOUS)
			stat(null, text("System integrity: [round((health / maxHealth) * 100)]%"))
		else
			stat(null, text("Systems nonfunctional"))

		show_malf_ai()

// this function displays the stations manifest in a separate window
/mob/living/silicon/proc/show_station_manifest()
	var/dat
	if(data_core)
		dat += data_core.html_manifest(monochrome=1, silicon=1) // make it monochrome
	dat += "<br>"

	var/datum/browser/popup = new(src, "airoster", "Crew Manifest")
	popup.set_content(dat)
	popup.open()

//can't inject synths
/mob/living/silicon/try_inject(mob/user, error_msg)
	if(error_msg)
		to_chat(user, "<span class='alert'>The armoured plating is too tough.</span>")
	return FALSE


//Silicon mob language procs

/mob/living/silicon/can_speak(datum/language/speaking)
	return universal_speak || (speaking in src.speech_synthesizer_langs)	//need speech synthesizer support to vocalize a language

/mob/living/silicon/add_language(language, flags=LANGUAGE_CAN_SPEAK)
	. = ..()
	if(. && flags >= LANGUAGE_CAN_SPEAK)
		speech_synthesizer_langs.Add(all_languages[language])

/mob/living/silicon/remove_language(rem_language)
	..(rem_language)

	for (var/datum/language/L in speech_synthesizer_langs)
		if (L.name == rem_language)
			speech_synthesizer_langs -= L

/mob/living/silicon/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = ""

	for(var/datum/language/L as anything in languages)
		dat += "<b>[L.name] "
		for(var/l_key in L.key)
			dat += "(:[l_key])"
		dat += " </b><br/>Speech Synthesizer: <i>[(L in speech_synthesizer_langs)? "YES":"NOT SUPPORTED"]</i><br/>[L.desc]<br/><br/>"

	var/datum/browser/popup = new(src, "checklanguage", "Known Languages")
	popup.set_content(dat)
	popup.open()

	return

/mob/living/silicon/proc/remove_sensors()
	for(var/hud in sensor_huds)
		var/datum/atom_hud/sensor = global.huds[hud]
		sensor.remove_hud_from(src)
	sensor_mode = FALSE
	to_chat(src, "Sensor augmentations disabled.")

/mob/living/silicon/proc/toggle_sensor_mode()
	//set name = "Set Sensor Augmentation" // Dunno, but it loops if open. ~Zve
	//set desc = "Augment visual feed with internal sensor overlays."
	if(sensor_mode)
		remove_sensors()
		return

	for(var/hud in sensor_huds)
		var/datum/atom_hud/sensor = global.huds[hud]
		sensor.add_hud_to(src)

	sensor_mode = TRUE
	to_chat(src, "Sensor augmentations enabled.")

/mob/living/silicon/proc/write_laws()
	if(laws)
		var/text = laws.write_laws()
		return text

/mob/living/silicon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash/noise)
	if(affect_silicon)
		return ..()

/mob/living/silicon/can_inject(mob/user, def_zone, show_message = TRUE, penetrate_thick = FALSE)
	if(show_message)
		to_chat(user, "<span class='alert'>[src]'s outer shell is too tough.</span>")
	return FALSE

/mob/living/silicon/proc/give_hud(hud, reset_to_def = TRUE)
	if(reset_to_def)
		sensor_huds = def_sensor_huds

	sensor_huds += hud

/mob/living/silicon/proc/update_manifest()
	Silicon_Manifest.Cut()

/mob/living/silicon/examine(mob/user) //Displays a silicon's laws to ghosts
	if(laws && isobserver(user))
		to_chat(user, "<b>[src] has the following laws:</b><br>[write_laws()]")

/mob/living/silicon/update_canmove(no_transform)
	return

/mob/living/silicon/vomit(punched = FALSE, masked = FALSE, vomit_type = DEFAULT_VOMIT, stun = TRUE, force = FALSE)
	return

