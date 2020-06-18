/mob/living/silicon
	gender = NEUTER
	robot_talk_understand = 1
	voice_name = "synthesized voice"
	var/syndicate = 0
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	immune_to_ssd = 1
	var/list/hud_list[9]
	var/list/speech_synthesizer_langs = list()	//which languages can be vocalized by the speech synthesizer
	var/obj/item/device/pda/silicon/pda = null






	var/obj/item/device/camera/siliconcam/aiCamera = null //photography

	var/sensor_mode = 0 //Determines the current HUD.
	#define SEC_HUD 1 //Security HUD mode
	#define MED_HUD 2 //Medical HUD mode

/mob/living/silicon/atom_init()
	. = ..()
	silicon_list += src

/mob/living/silicon/Destroy()
	silicon_list -= src
	return ..()

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/proc/checklaws()
	return

/mob/living/silicon/proc/show_alerts()
	return

/mob/living/silicon/drop_item()
	return

/mob/living/silicon/emp_act(severity)
	switch(severity)
		if(1)
			src.take_bodypart_damage(20)
			Stun(rand(5,10))
		if(2)
			src.take_bodypart_damage(10)
			Stun(rand(1,5))
	flash_eyes(affect_silicon = 1)
	to_chat(src, "<span class='warning'><B>*BZZZT*</B></span>")
	to_chat(src, "<span class='warning'>Warning: Electromagnetic pulse detected.</span>")
	..()

/mob/living/silicon/proc/damage_mob(brute = 0, fire = 0, tox = 0)
	return

/mob/living/silicon/IsAdvancedToolUser()
	return 1

/mob/living/silicon/apply_effect(effect = 0,effecttype = STUN, blocked = 0)
	return 0//The only effect that can hit them atm is flashes and they still directly edit so this works for now
/*
	if(!effect || (blocked >= 2))	return 0
	switch(effecttype)
		if(STUN)
			stunned = max(stunned,(effect/(blocked+1)))
		if(WEAKEN)
			weakened = max(weakened,(effect/(blocked+1)))
		if(PARALYZE)
			paralysis = max(paralysis,(effect/(blocked+1)))
		if(IRRADIATE)
			radiation += min((effect - (effect*getarmor(null, "rad"))), 0)//Rads auto check armor
		if(STUTTER)
			stuttering = max(stuttering,(effect/(blocked+1)))
		if(EYE_BLUR)
			eye_blurry = max(eye_blurry,(effect/(blocked+1)))
		if(DROWSY)
			drowsyness = max(drowsyness,(effect/(blocked+1)))
	updatehealth()
	return 1*/

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
	dat += "<h4>Crew Manifest</h4>"
	if(data_core)
		dat += data_core.get_manifest(1) // make it monochrome
	dat += "<br>"
	src << browse(dat, "window=airoster")
	onclose(src, "airoster")

//can't inject synths
/mob/living/silicon/try_inject(mob/user, error_msg)
	if(error_msg)
		to_chat(user, "<span class='alert'>The armoured plating is too tough.</span>")
	return FALSE


//Silicon mob language procs

/mob/living/silicon/can_speak(datum/language/speaking)
	return universal_speak || (speaking in src.speech_synthesizer_langs)	//need speech synthesizer support to vocalize a language

/mob/living/silicon/add_language(language, can_speak=1)
	if (..(language) && can_speak)
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

	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	for(var/datum/language/L in languages)
		dat += "<b>[L.name] "
		for(var/l_key in L.key)
			dat += "(:[l_key])"
		dat += " </b><br/>Speech Synthesizer: <i>[(L in speech_synthesizer_langs)? "YES":"NOT SUPPORTED"]</i><br/>[L.desc]<br/><br/>"

	src << browse(dat, "window=checklanguage")
	return

/mob/living/silicon/proc/toggle_sensor_mode()
	//set name = "Set Sensor Augmentation" // Dunno, but it loops if open. ~Zve
	//set desc = "Augment visual feed with internal sensor overlays."
	var/sensor_type = input("Please select sensor type.", "Sensor Integration", null) in list("Security", "Medical","Disable")
	switch(sensor_type)
		if ("Security")
			sensor_mode = SEC_HUD
			to_chat(src, "<span class='notice'>Security records overlay enabled.</span>")
		if ("Medical")
			sensor_mode = MED_HUD
			to_chat(src, "<span class='notice'>Life signs monitor overlay enabled.</span>")
		if ("Disable")
			sensor_mode = 0
			to_chat(src, "Sensor augmentations disabled.")

/mob/living/silicon/proc/write_laws()
	if(laws)
		var/text = src.laws.write_laws()
		return text

/mob/living/silicon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash/noise)
	if(affect_silicon)
		return ..()

/mob/living/silicon/can_inject(mob/user, def_zone, show_message = TRUE, penetrate_thick = FALSE)
	if(show_message)
		to_chat(user, "<span class='alert'>[src]'s outer shell is too tough.</span>")
	return FALSE
