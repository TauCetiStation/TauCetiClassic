/*
 * Data HUDs have been rewritten in a more generic way.
 * In short, they now use an observer-listener pattern.
 * See code/datum/hud.dm for the generic hud datum.
 * Update the HUD icons when needed with the appropriate hook. (see below)
 */

/* DATA HUD DATUMS */

/atom/proc/add_to_all_human_data_huds()
	for(var/datum/atom_hud/data/human/hud in global.huds)
		hud.add_to_hud(src)

/atom/proc/remove_from_all_data_huds()
	for(var/datum/atom_hud/data/hud in global.huds)
		hud.remove_from_hud(src)

/datum/atom_hud/data

/datum/atom_hud/data/human/medical
	hud_icons = list(STATUS_HUD, HEALTH_HUD, NANITE_HUD)

/datum/atom_hud/data/human/medical/basic

/datum/atom_hud/data/human/medical/basic/proc/check_sensors(mob/living/carbon/human/H)
	if(!istype(H))
		return 0
	var/obj/item/clothing/under/U = H.w_uniform
	if(!istype(U))
		return 0
	if(U.sensor_mode <= SUIT_SENSOR_VITAL)
		return 0
	return 1

/datum/atom_hud/data/human/medical/basic/add_to_single_hud(mob/M, mob/living/carbon/H)
	if(check_sensors(H))
		..()

/datum/atom_hud/data/human/medical/basic/proc/update_suit_sensors(mob/living/carbon/H)
	check_sensors(H) ? add_to_hud(H) : remove_from_hud(H)

// what ever
/datum/atom_hud/data/human/medical/basic/secmed
	hud_icons = list(ID_HUD, IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD, WANTED_HUD, NANITE_HUD, STATUS_HUD, HEALTH_HUD, NANITE_HUD)

/datum/atom_hud/data/human/security

/datum/atom_hud/data/human/security/basic
	hud_icons = list(ID_HUD, IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD, WANTED_HUD, NANITE_HUD)

/datum/atom_hud/data/diagnostic

/datum/atom_hud/data/diagnostic/basic
	hud_icons = list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_BOT_HUD, DIAG_CIRCUIT_HUD, DIAG_TRACK_HUD, DIAG_AIRLOCK_HUD, DIAG_NANITE_FULL_HUD, DIAG_LAUNCHPAD_HUD)

/datum/atom_hud/data/diagnostic/advanced
	hud_icons = list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_BOT_HUD, DIAG_CIRCUIT_HUD, DIAG_TRACK_HUD, DIAG_AIRLOCK_HUD, DIAG_NANITE_FULL_HUD, DIAG_LAUNCHPAD_HUD, DIAG_PATH_HUD)

/datum/atom_hud/data/bot_path
	hud_icons = list(DIAG_PATH_HUD)

/datum/atom_hud/abductor
	hud_icons = list(GLAND_HUD)

/datum/atom_hud/sentient_disease
	hud_icons = list(SENTIENT_DISEASE_HUD)

/* MED/SEC/DIAG HUD HOOKS */

/*
 * THESE HOOKS SHOULD BE CALLED BY THE MOB SHOWING THE HUD
 */

/***********************************************
 Medical HUD! Basic mode needs suit sensors on.
************************************************/

//HELPERS

//called when a carbon changes virus
/mob/living/carbon/proc/check_virus()
	var/threat
	var/severity
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(!(D.hidden[1]))
			if(!threat || D.severity > threat) //a buffing virus gets an icon
				threat = D.severity
				severity = D.severity
	return severity

//HOOKS

//called when a human changes suit sensors
/mob/living/carbon/proc/update_suit_sensors()
	var/datum/atom_hud/data/human/medical/basic/B = global.huds[DATA_HUD_MEDICAL_BASIC]
	B.update_suit_sensors(src)

//called when a living mob changes health
/mob/living/proc/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD]
	holder.icon_state = "hud[RoundHealth(src)]"
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size

//for carbon suit sensors
/mob/living/carbon/med_hud_set_health()
	..()

//called when a carbon changes stat, virus or XENO_HOST
/mob/living/proc/med_hud_set_status()
	var/image/holder = hud_list[STATUS_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(stat == DEAD || status_flags & FAKEDEATH)
		holder.icon_state = "huddead"
	else
		holder.icon_state = "hudhealthy"

/mob/living/carbon/med_hud_set_status()
	var/image/holder = hud_list[STATUS_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	var/virus_threat = check_virus()
	holder.pixel_y = I.Height() - world.icon_size
	if(status_flags & XENO_HOST)
		holder.icon_state = "hudxeno"
	else if(stat == DEAD || status_flags & FAKEDEATH)
		if(key || get_ghost(FALSE, TRUE))
			holder.icon_state = "huddefib"
		else
			holder.icon_state = "huddead"
	else
		switch(virus_threat)
			if(7)
				holder.icon_state = "hudill5"
			if(6)
				holder.icon_state = "hudill4"
			if(5)
				holder.icon_state = "hudill3"
			if(4)
				holder.icon_state = "hudill2"
			if(3)
				holder.icon_state = "hudill1"
			if(2)
				holder.icon_state = "hudill0"
			if(1)
				holder.icon_state = "hudbuff"
			if(null)
				holder.icon_state = "hudhealthy"


/***********************************************
 Security HUDs! Basic mode shows only the job.
************************************************/

//HOOKS

/mob/living/carbon/human/proc/sec_hud_set_ID()
	var/image/holder = hud_list[ID_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "hudno_id"
	if(wear_id && wear_id.GetID())
		holder.icon_state = "hud[ckey(wear_id.GetJobName())]"
	sec_hud_set_security_status()

/mob/living/carbon/human/proc/sec_hud_set_implants()
	var/image/holder
	for(var/i in list(IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD))
		holder = hud_list[i]
		holder.icon_state = null
	for(var/obj/item/organ/external/BP in bodyparts)
		for(var/obj/item/weapon/O in BP.implants)
			if(istype(O, /obj/item/weapon/implant/tracking))
				holder = hud_list[IMPTRACK_HUD]
				var/icon/IC = icon(icon, icon_state, dir)
				holder.pixel_y = IC.Height() - world.icon_size
				holder.icon_state = "hud_imp_tracking"
			else if(istype(O, /obj/item/weapon/implant/chem))
				holder = hud_list[IMPCHEM_HUD]
				var/icon/IC = icon(icon, icon_state, dir)
				holder.pixel_y = IC.Height() - world.icon_size
				holder.icon_state = "hud_imp_chem"
	if(ismindshielded(src))
		holder = hud_list[IMPLOYAL_HUD]
		var/icon/IC = icon(icon, icon_state, dir)
		holder.pixel_y = IC.Height() - world.icon_size
		holder.icon_state = "hud_imp_loyal"

/mob/living/carbon/human/proc/sec_hud_set_security_status()
	var/image/holder = hud_list[WANTED_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	var/perpname = get_face_name(get_id_name(""))
	if(perpname && global.data_core)
		var/datum/data/record/R = find_record("name", perpname, global.data_core.security)
		if(R)
			switch(R.fields["criminal"])
				if("*Arrest*")
					holder.icon_state = "hudwanted"
					return
				if("Incarcerated")
					holder.icon_state = "hudincarcerated"
					return
				if("Paroled")
					holder.icon_state = "hudparolled"
					return
				if("Discharged")
					holder.icon_state = "huddischarged"
					return
	holder.icon_state = null

/***********************************************
 Diagnostic HUDs!
************************************************/

//For Diag health and cell bars!
/proc/RoundDiagBar(value)
	switch(value * 100)
		if(95 to INFINITY)
			return "max"
		if(80 to 100)
			return "good"
		if(60 to 80)
			return "high"
		if(40 to 60)
			return "med"
		if(20 to 40)
			return "low"
		if(1 to 20)
			return "crit"
		else
			return "dead"

//Sillycone hooks
/mob/living/silicon/proc/diag_hud_set_health()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(stat == DEAD)
		holder.icon_state = "huddiagdead"
	else
		holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/silicon/proc/diag_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	switch(stat)
		if(CONSCIOUS)
			holder.icon_state = "hudstat"
		if(UNCONSCIOUS)
			holder.icon_state = "hudoffline"
		else
			holder.icon_state = "huddead2"

//Borgie battery tracking!
/mob/living/silicon/robot/proc/diag_hud_set_borgcell()
	var/image/holder = hud_list[DIAG_BATT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(cell)
		var/chargelvl = (cell.charge/cell.maxcharge)
		holder.icon_state = "hudbatt[RoundDiagBar(chargelvl)]"
	else
		holder.icon_state = "hudnobatt"

/*~~~~~~~~~~~~~~~~~~~~
	BIG STOMPY MECHS
~~~~~~~~~~~~~~~~~~~~~*/
/obj/mecha/proc/diag_hud_set_mechhealth()
	var/image/holder = hud_list[DIAG_MECH_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxhealth)]"


/obj/mecha/proc/diag_hud_set_mechcell()
	var/image/holder = hud_list[DIAG_BATT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(cell)
		var/chargelvl = cell.charge/cell.maxcharge
		holder.icon_state = "hudbatt[RoundDiagBar(chargelvl)]"
	else
		holder.icon_state = "hudnobatt"


/obj/mecha/proc/diag_hud_set_mechstat()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = null
	if(internal_damage)
		holder.icon_state = "hudwarn"

/obj/mecha/proc/diag_hud_set_mechtracking() //Shows tracking beacons on the mech
	var/image/holder = hud_list[DIAG_TRACK_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	var/new_icon_state //This var exists so that the holder's icon state is set only once in the event of multiple mech beacons.
	for(var/obj/item/mecha_parts/mecha_tracking/T in mecha_tracking_list)
		if(!T.in_mecha())
			continue
		new_icon_state = "hudtracking"
	holder.icon_state = new_icon_state

/*~~~~~~~~~
	Bots!
~~~~~~~~~~*/
/obj/machinery/bot/proc/diag_hud_set_bothealth()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxhealth)]"

/obj/machinery/bot/proc/diag_hud_set_botstat() //On (With wireless on or off), Off, EMP'ed
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(on)
		holder.icon_state = "hudstat"
	else if(stat) //Generally EMP causes this
		holder.icon_state = "hudoffline"
	else //Bot is off
		holder.icon_state = "huddead2"

/*~~~~~~~~~~~~
	Airlocks!
~~~~~~~~~~~~~*/
/obj/machinery/door/airlock/proc/diag_hud_set_electrified()
	var/image/holder = hud_list[DIAG_AIRLOCK_HUD]
	if(secondsElectrified != 0) // TODO: Needs defines in code
		holder.icon_state = "electrified"
	else
		holder.icon_state = ""
