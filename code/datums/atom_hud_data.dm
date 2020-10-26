#define HIDDEN_SCANNER 1
/*
 * Data HUDs have been rewritten in a more generic way.
 * In short, they now use an observer-listener pattern.
 * See code/datum/hud.dm for the generic hud datum.
 * Update the HUD icons when needed with the appropriate hook. (see below)
 */

/* DATA HUD DATUMS */
/atom/proc/add_to_all_data_huds()
	for(var/datum/atom_hud/data/hud in global.huds)
		hud.add_to_hud(src)

/atom/proc/remove_from_all_data_huds()
	for(var/datum/atom_hud/data/hud in global.huds)
		hud.remove_from_hud(src)

/datum/atom_hud/data
	hud_icons = null

/datum/atom_hud/data/medical
	hud_icons = list(STATUS_HUD, HEALTH_HUD)

/datum/atom_hud/data/medical/proc/check_sensors(mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE
	var/obj/item/clothing/under/U = H.w_uniform
	if(!istype(U))
		return FALSE
	if(U.sensor_mode <= SUIT_SENSOR_BINARY)
		return FALSE
	return TRUE

/datum/atom_hud/data/medical/add_to_single_hud(mob/M, mob/living/carbon/H)
	if(check_sensors(H))
		..()

/datum/atom_hud/data/medical/proc/update_suit_sensors(mob/living/carbon/H)
	if(check_sensors(H))
		add_to_hud(H)
	else
		remove_from_hud(H)

/datum/atom_hud/data/medical/adv

/datum/atom_hud/data/medical/adv/check_sensors()
	return TRUE

/datum/atom_hud/data/security
	hud_icons = list(ID_HUD, IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD, IMPMINDS_HUD, WANTED_HUD)

/datum/atom_hud/data/diagnostic
	hud_icons = list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_AIRLOCK_HUD)

/datum/atom_hud/data/mine
	hud_icons = list(MINE_MINERAL_HUD, MINE_ARTIFACT_HUD)

/datum/atom_hud/broken
	hud_icons = list(BROKEN_HUD)


/* MED/SEC/DIAG HUD HOOKS */

/*
 * THESE HOOKS SHOULD BE CALLED BY THE MOB SHOWING THE HUD
 */

/***********************************************
 Medical HUD! Basic mode needs suit sensors on.
************************************************/

//called when a carbon changes virus
/mob/living/carbon/proc/check_virus()
	var/threat
	var/severity
	for(var/thing in viruses)
		var/datum/disease/D = thing
		if(!D.hidden[HIDDEN_SCANNER])
			if(!threat || D.severity > threat) //a buffing virus gets an icon
				threat = D.severity
				severity = D.severity
	return severity

//called when a human changes suit sensors
/mob/living/carbon/proc/update_suit_sensors()
	var/datum/atom_hud/data/medical/B = global.huds[DATA_HUD_MEDICAL]
	B.update_suit_sensors(src)

//called when a living mob changes health
/mob/living/proc/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD]
	holder.icon_state = "hud[RoundHealth(src)]"

//for carbon suit sensors
/mob/living/carbon/med_hud_set_health()
	..()

//called when a carbon changes stat, virus or XENO_HOST
/mob/living/proc/med_hud_set_status()
	var/image/holder = hud_list[STATUS_HUD]
	if(stat == DEAD || (status_flags & FAKEDEATH))
		holder.icon_state = "huddead"
	else
		holder.icon_state = "hudhealthy"

/mob/living/carbon/med_hud_set_status()
	var/image/holder = hud_list[STATUS_HUD]
	var/virus_threat = check_virus()
	if(status_flags & XENO_HOST)
		holder.icon_state = "hudxeno"
	else if(stat == DEAD || (status_flags & FAKEDEATH))
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
			else
				holder.icon_state = "hudhealthy"

/mob/living/carbon/human/med_hud_set_status()
	..()
	var/image/holder = hud_list[STATUS_HUD]
	if(iszombie(src))
		holder.icon_state = "hudill"

/***********************************************
 Security HUDs! Basic mode shows only the job.
************************************************/
/mob/living/carbon/human/proc/sec_hud_set_ID()
	var/image/holder = hud_list[ID_HUD]
	holder.icon_state = "hudunknown"
	if(wear_id?.GetID())
		holder.icon_state = "hud[ckey(wear_id.GetJobName())]"
	holder.pixel_y = -8
	sec_hud_set_security_status()

/mob/living/proc/sec_hud_set_implants()
	var/image/holder
	var/y = 0
	for(var/i in list(IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD, IMPMINDS_HUD))
		holder = hud_list[i]
		holder.icon_state = null

	if(isloyal(src))
		holder = hud_list[IMPLOYAL_HUD]
		holder.icon_state = "hud_imp_loyal"
		y += -5

	if(ismindshielded(src))
		holder = hud_list[IMPMINDS_HUD]
		holder.icon_state = "hud_imp_mindshield"
		holder.pixel_y = y
		y += -5

	for(var/obj/item/weapon/implant/I in src)
		if(istype(I, /obj/item/weapon/implant/chem))
			holder = hud_list[IMPCHEM_HUD]
			holder.icon_state = "hud_imp_chem"
			holder.pixel_y = y
			y += -5

		if(istype(I, /obj/item/weapon/implant/tracking))
			holder = hud_list[IMPTRACK_HUD]
			holder.icon_state = "hud_imp_tracking"
			holder.pixel_y = y
			y += -5

/mob/living/carbon/human/proc/sec_hud_set_security_status()
	var/image/holder = hud_list[WANTED_HUD]
	var/perpname = get_face_name(get_id_name(""))
	if(perpname && global.data_core)
		var/datum/data/record/R = find_record("name", perpname, global.data_core.security)
		if(R)
			switch(R.fields["criminal"])
				if("*Arrest*")
					holder.icon_state = "hudwanted"
					return
				if("Incarcerated")
					holder.icon_state = "hudprisoner"
					return
				if("Paroled")
					holder.icon_state = "hudparolled"
					return
				if("Released")
					holder.icon_state = "hudreleased"
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
	if(stat == DEAD)
		holder.icon_state = "huddiagdead"
	else
		holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/silicon/proc/diag_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
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
	if(cell)
		var/chargelvl = (cell.charge/cell.maxcharge)
		holder.icon_state = "hudbatt[RoundDiagBar(chargelvl)]"
	else
		holder.icon_state = "hudnobatt"

/*~~~~~~~~~~~~~~~~~~~~
	MINECRAFT HUDs
~~~~~~~~~~~~~~~~~~~~~*/
/turf/simulated/mineral/proc/set_mine_hud()
	var/image/holder1 = hud_list[MINE_ARTIFACT_HUD]
	var/image/holder2 = hud_list[MINE_MINERAL_HUD]
	var/states = 0
	if(finds && finds.len || artifact_find)
		holder1.icon_state = "hudanomaly"
		states += 1
	if(mineral)
		holder2.icon_state = "hud[mineral.ore_type]"
		states += 1
	if(states == 2)
		holder1.pixel_x = 6
		holder2.pixel_x = -6

/*~~~~~~~~~~~~~~~~~~~~
	BROKEN HUUDs
~~~~~~~~~~~~~~~~~~~~~*/
/mob/living/carbon/proc/set_broken_hud_icon()
	var/image/holder = hud_list[BROKEN_HUD]
	var/list/num = list(1, 2, 3, 4, 5, 6, 7)
	holder.icon_state = "hudbroken[pick(num)]"

/*~~~~~~~~~~~~~~~~~~~~
	BIG STOMPY MECHS
~~~~~~~~~~~~~~~~~~~~~*/
/obj/mecha/proc/diag_hud_set_mechhealth()
	var/image/holder = hud_list[DIAG_MECH_HUD]
	holder.icon_state = "huddiag[RoundDiagBar(health/maxhealth)]"

/obj/mecha/proc/diag_hud_set_mechcell()
	var/image/holder = hud_list[DIAG_BATT_HUD]
	if(cell)
		var/chargelvl = cell.charge/cell.maxcharge
		holder.icon_state = "hudbatt[RoundDiagBar(chargelvl)]"
	else
		holder.icon_state = "hudnobatt"

/obj/mecha/proc/diag_hud_set_mechstat()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	holder.icon_state = null
	if(internal_damage)
		holder.icon_state = "hudwarn"

/*~~~~~~~~~~~~
	Airlocks!
~~~~~~~~~~~~~*/
/obj/machinery/door/proc/diag_hud_set_electrified()
	var/image/holder = hud_list[DIAG_AIRLOCK_HUD]
	if(secondsElectrified != 0)
		holder.icon_state = "electrified"
	else
		holder.icon_state = ""

//helper for getting the appropriate health status
/proc/RoundHealth(mob/living/M)
	if(M.stat == DEAD || (M.status_flags & FAKEDEATH))
		return "health-100" //what's our health? it doesn't matter, we're dead, or faking
	var/maxi_health = M.maxHealth
	if(iscarbon(M) && M.health < 0)
		maxi_health = 100 //so crit shows up right for aliens and other high-health carbon mobs; noncarbons don't have crit.
	var/resulthealth = (M.health / maxi_health) * 100
	switch(resulthealth)
		if(100 to INFINITY)
			return "health100"
		if(93 to 100)
			return "health93"
		if(86 to 93)
			return "health86"
		if(78 to 86)
			return "health78"
		if(71 to 78)
			return "health71"
		if(64 to 71)
			return "health64"
		if(56 to 64)
			return "health56"
		if(49 to 56)
			return "health49"
		if(42 to 49)
			return "health42"
		if(35 to 42)
			return "health35"
		if(28 to 35)
			return "health28"
		if(21 to 28)
			return "health21"
		if(14 to 21)
			return "health14"
		if(7 to 14)
			return "health7"
		if(1 to 7)
			return "health1"
		if(-50 to 1)
			return "health0"
		if(-85 to -50)
			return "health-50"
		if(-99 to -85)
			return "health-85"
		else
			return "health-100"

#undef HIDDEN_SCANNER
