/var/const/access_security = 1 // Security equipment
/var/const/access_brig = 2 // Brig timers and permabrig
/var/const/access_armory = 3
/var/const/access_forensics_lockers= 4
/var/const/access_medical = 5
/var/const/access_morgue = 6
/var/const/access_tox = 7
/var/const/access_tox_storage = 8
/var/const/access_genetics = 9
/var/const/access_engine = 10
/var/const/access_engine_equip= 11
/var/const/access_maint_tunnels = 12
/var/const/access_external_airlocks = 13
/var/const/access_emergency_storage = 14
/var/const/access_change_ids = 15
/var/const/access_ai_upload = 16
/var/const/access_teleporter = 17
/var/const/access_eva = 18
/var/const/access_heads = 19
/var/const/access_captain = 20
/var/const/access_all_personal_lockers = 21
/var/const/access_chapel_office = 22
/var/const/access_tech_storage = 23
/var/const/access_atmospherics = 24
/var/const/access_bar = 25
/var/const/access_janitor = 26
/var/const/access_crematorium = 27
/var/const/access_kitchen = 28
/var/const/access_robotics = 29
/var/const/access_rd = 30
/var/const/access_cargo = 31
/var/const/access_construction = 32
/var/const/access_chemistry = 33
/var/const/access_cargoshop = 34
/var/const/access_hydroponics = 35
/var/const/access_manufacturing = 36
/var/const/access_library = 37
/var/const/access_lawyer = 38
/var/const/access_virology = 39
/var/const/access_cmo = 40
/var/const/access_qm = 41
/var/const/access_blueshield = 42
/var/const/access_clown = 43
/var/const/access_mime = 44
/var/const/access_surgery = 45
/var/const/access_theatre = 46
/var/const/access_research = 47
/var/const/access_mining = 48
/var/const/access_mining_office = 49 //not in use
/var/const/access_mailsorting = 50
/var/const/access_mint = 51
/var/const/access_mint_vault = 52
/var/const/access_heads_vault = 53
/var/const/access_mining_station = 54
/var/const/access_xenobiology = 55
/var/const/access_ce = 56
/var/const/access_hop = 57
/var/const/access_hos = 58
/var/const/access_RC_announce = 59 //Request console announcements
/var/const/access_keycard_auth = 60 //Used for events which require at least two people to confirm them
/var/const/access_tcomsat = 61 // has access to the entire telecomms satellite / machinery
/var/const/access_gateway = 62
/var/const/access_sec_doors = 63 // Security front doors
/var/const/access_psychiatrist = 64 // Psychiatrist's office
/var/const/access_xenoarch = 65
/var/const/access_minisat = 66
/var/const/access_recycler = 67
/var/const/access_detective = 68
/var/const/access_barber = 69
/var/const/access_paramedic = 70
/var/const/access_engineering_lobby = 71
/var/const/access_medbay_storage = 72
/var/const/access_oldstation = 73
/var/const/access_space_traders = 74

	//BEGIN CENTCOM ACCESS
	/*Should leave plenty of room if we need to add more access levels.
/var/const/Mostly for admin fun times.*/
/var/const/access_cent_general = 101//General facilities.
/var/const/access_cent_thunder = 102//Thunderdome.
/var/const/access_cent_specops = 103//Special Ops.
/var/const/access_cent_medical = 104//Medical/Research
/var/const/access_cent_living = 105//Living quarters.
/var/const/access_cent_storage = 106//Generic storage areas.
/var/const/access_cent_teleporter = 107//Teleporter.
/var/const/access_cent_creed = 108//Creed's office.
/var/const/access_cent_captain = 109//Captain's office/ID comp/AI.

	//The Syndicate
/var/const/access_syndicate = 150//General Syndicate Access
/var/const/access_syndicate_commander = 151 //Syndicate Commander Access

	//MONEY
/var/const/access_crate_cash = 200

/obj/var/list/req_access = list()
/obj/var/list/req_one_access = list()

///returns 1 if this atom has sufficient access to use this object
/obj/proc/allowed(atom/movable/AM)
	//check if it doesn't require any access at all
	if(check_access(null))
		return TRUE
	if(IsAdminGhost(AM))
		//Access can't stop the abuse
		return TRUE
	if(ismob(AM))
		var/mob/M = AM
		if(SEND_SIGNAL(M, COMSIG_MOB_TRIED_ACCESS, src) & COMSIG_ACCESS_ALLOWED)
			return TRUE
	if(AM.try_access(src))
		return TRUE
	return FALSE

///Internal proc. Use allowed() if possible. TRUE if src has the necessary access for obj
/atom/movable/proc/try_access(obj/O)
	return FALSE

/mob/living/silicon/try_access(obj/O)
	return O.check_access(src)

/mob/living/carbon/try_access(obj/O)
	return O.check_access(get_active_hand())

/mob/living/carbon/human/try_access(obj/O) //if they are holding or wearing a card that has access, that works
	for(var/obj/item/I in list(wear_id) + get_hand_slots())
		if(O.check_access(I))
			return TRUE

/mob/living/carbon/ian/try_access(obj/O)
	for(var/obj/item/I in list(neck) + get_hand_slots())
		if(O.check_access(I))
			return TRUE

/obj/machinery/bot/try_access(obj/O)
	return O.check_access(botcard)

/obj/mecha/try_access(obj/O)
	return occupant && (O.allowed(occupant) || O.check_access_list(operation_req_access))

/obj/structure/stool/bed/chair/wheelchair/try_access(obj/O)
	return pulling && O.allowed(pulling)

/obj/item/try_access(obj/O)
	return O.check_access(src)

/atom/movable/proc/GetAccess()
	return list()

/mob/living/silicon/GetAccess()
	return get_all_accesses()

/mob/living/silicon/robot/syndicate/GetAccess()
	return list(access_maint_tunnels, access_syndicate, access_external_airlocks) //syndicate basic access

/mob/living/silicon/robot/drone/syndi/GetAccess()
	return list(access_maint_tunnels, access_syndicate, access_external_airlocks) //syndicate basic access

/mob/living/silicon/robot/drone/maintenance/malfuction/GetAccess()
	return list(access_maint_tunnels)

/obj/item/proc/GetID()
	return null

/obj/proc/check_access(atom/movable/AM)
	if(ismachinery(src))
		var/obj/machinery/Machine = src
		if(Machine.emagged)
			return TRUE

	if(!length(req_access) && !length(req_one_access)) //no requirements
		return TRUE
	if(!AM)
		return FALSE
	for(var/req in req_access)
		if(!(req in AM.GetAccess())) //doesn't have this access
			return FALSE
	if(req_one_access.len)
		for(var/req in src.req_one_access)
			if(req in AM.GetAccess()) //has an access from the single access list
				return TRUE
		return FALSE
	return TRUE

/obj/proc/check_access_list(list/L)
	if(!req_access.len && !req_one_access.len)
		return TRUE
	if(!islist(L))
		return FALSE
	for(var/req in req_access)
		if(!(req in L)) //doesn't have this access
			return FALSE
	if(req_one_access.len)
		for(var/req in req_one_access)
			if(req in L) //has an access from the single access list
				return TRUE
		return FALSE
	return TRUE

/proc/get_all_accesses()
	return list(access_security, access_sec_doors, access_brig, access_armory, access_forensics_lockers, access_blueshield,
	            access_medical, access_genetics, access_morgue, access_rd, access_cargoshop,
	            access_tox, access_tox_storage, access_chemistry, access_engine, access_engine_equip, access_maint_tunnels,
	            access_external_airlocks, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers,
	            access_tech_storage, access_chapel_office, access_atmospherics, access_kitchen,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_construction,
	            access_hydroponics, access_library, access_virology, access_psychiatrist, access_cmo, access_qm, access_lawyer, access_surgery,
	            access_theatre, access_research, access_mining, access_mailsorting,
	            access_heads_vault, access_mining_station, access_xenobiology, access_ce, access_hop, access_hos, access_RC_announce,
	            access_keycard_auth, access_tcomsat, access_gateway, access_xenoarch, access_minisat, access_recycler, access_detective, access_barber, access_paramedic, access_medbay_storage, access_engineering_lobby)

/proc/get_all_centcom_access()
	return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_medical, access_cent_living, access_cent_storage, access_cent_teleporter, access_cent_creed, access_cent_captain)

/proc/get_all_syndicate_access()
	return list(access_syndicate)

/proc/get_region_accesses(code)
	// todo: we have defines for region codes: REGION_*
	// but in wrong order
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //security
			return list(access_sec_doors, access_security, access_brig, access_armory, access_forensics_lockers, access_hos, access_detective, access_blueshield)
		if(2) //medbay
			return list(access_medical, access_genetics, access_morgue, access_chemistry, access_psychiatrist, access_virology, access_surgery, access_cmo, access_paramedic, access_medbay_storage)
		if(3) //research
			return list(access_research, access_tox, access_tox_storage, access_robotics, access_xenobiology, access_xenoarch, access_minisat, access_rd)
		if(4) //engineering and maintenance
			return list(access_construction, access_maint_tunnels, access_engine, access_engine_equip, access_external_airlocks, access_tech_storage, access_atmospherics, access_minisat, access_ce, access_engineering_lobby)
		if(5) //command
			return list(access_heads, access_RC_announce, access_keycard_auth, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_tcomsat, access_gateway, access_all_personal_lockers, access_heads_vault, access_hop, access_captain)
		if(6) //station general
			return list(access_kitchen,access_bar, access_hydroponics, access_barber, access_janitor, access_chapel_office, access_crematorium, access_library, access_lawyer, access_theatre)
		if(7) //supply
			return list(access_mailsorting, access_cargoshop, access_mining, access_mining_station, access_cargo, access_recycler, access_qm)

/proc/get_region_accesses_name(code)
	switch(code)
		if(0)
			return "All"
		if(1) //security
			return "Security"
		if(2) //medbay
			return "Medbay"
		if(3) //research
			return "Research"
		if(4) //engineering and maintenance
			return "Engineering"
		if(5) //command
			return "Command"
		if(6) //station general
			return "Station General"
		if(7) //supply
			return "Supply"


/proc/get_access_desc(A)
	switch(A)
		if(access_cargo)
			return "Cargo Bay"
		if(access_recycler)
			return "Recycler"
		if(access_detective)
			return "Detective"
		if(access_cargoshop)
			return "Cargo Delivery/Supply Console"
		if(access_security)
			return "Security"
		if(access_blueshield)
			return "Blueshield Office"
		if(access_brig)
			return "Holding Cells"
		if(access_forensics_lockers)
			return "Forensics"
		if(access_medical)
			return "Medical"
		if(access_genetics)
			return "Genetics Lab"
		if(access_morgue)
			return "Morgue"
		if(access_tox)
			return "R&D Lab"
		if(access_tox_storage)
			return "Toxins Lab"
		if(access_chemistry)
			return "Chemistry Lab"
		if(access_rd)
			return "Research Director"
		if(access_bar)
			return "Bar"
		if(access_janitor)
			return "Custodial Closet"
		if(access_engine)
			return "Engineering"
		if(access_engine_equip)
			return "Power Equipment"
		if(access_maint_tunnels)
			return "Maintenance"
		if(access_external_airlocks)
			return "External Airlocks"
		if(access_emergency_storage)
			return "Emergency Storage"
		if(access_change_ids)
			return "ID Computer"
		if(access_ai_upload)
			return "AI Chambers"
		if(access_teleporter)
			return "Teleporter"
		if(access_eva)
			return "EVA"
		if(access_heads)
			return "Bridge"
		if(access_captain)
			return "Captain"
		if(access_all_personal_lockers)
			return "Personal Lockers"
		if(access_chapel_office)
			return "Chapel Office"
		if(access_tech_storage)
			return "Technical Storage"
		if(access_atmospherics)
			return "Atmospherics"
		if(access_crematorium)
			return "Crematorium"
		if(access_armory)
			return "Armory"
		if(access_construction)
			return "Construction Areas"
		if(access_kitchen)
			return "Kitchen"
		if(access_hydroponics)
			return "Hydroponics"
		if(access_library)
			return "Library"
		if(access_lawyer)
			return "IAA Office"
		if(access_robotics)
			return "Robotics"
		if(access_virology)
			return "Virology"
		if(access_psychiatrist)
			return "Psychiatrist's Office"
		if(access_cmo)
			return "Chief Medical Officer"
		if(access_qm)
			return "Quartermaster"
/*		if(access_clown)
			return "HONK! Access"
		if(access_mime)
			return "Silent Access"*/
		if(access_surgery)
			return "Surgery"
		if(access_theatre)
			return "Theatre"
		if(access_manufacturing)
			return "Manufacturing"
		if(access_research)
			return "Science"
		if(access_mining)
			return "Mining"
		if(access_mining_office)
			return "Mining Office"
		if(access_mailsorting)
			return "Cargo Office"
		if(access_mint)
			return "Mint"
		if(access_mint_vault)
			return "Mint Vault"
		if(access_heads_vault)
			return "Main Vault"
		if(access_mining_station)
			return "Mining EVA"
		if(access_xenobiology)
			return "Xenobiology Lab"
		if(access_xenoarch)
			return "Xenoarchaeology"
		if(access_hop)
			return "Head of Personnel"
		if(access_hos)
			return "Head of Security"
		if(access_ce)
			return "Chief Engineer"
		if(access_RC_announce)
			return "RC Announcements"
		if(access_keycard_auth)
			return "Keycode Auth. Device"
		if(access_tcomsat)
			return "Telecommunications"
		if(access_gateway)
			return "Gateway"
		if(access_sec_doors)
			return "Brig"
		if(access_minisat)
			return "AI Satellite"
		if(access_barber)
			return "Barber"
		if(access_paramedic)
			return "Paramedic"
		if(access_engineering_lobby)
			return "Engineering Department"
		if(access_medbay_storage)
			return "Medbay Storage"


/proc/get_centcom_access_desc(A)
	switch(A)
		if(access_cent_general)
			return "Code Grey"
		if(access_cent_thunder)
			return "Code Yellow"
		if(access_cent_storage)
			return "Code Orange"
		if(access_cent_living)
			return "Code Green"
		if(access_cent_medical)
			return "Code White"
		if(access_cent_teleporter)
			return "Code Blue"
		if(access_cent_specops)
			return "Code Black"
		if(access_cent_creed)
			return "Code Silver"
		if(access_cent_captain)
			return "Code Gold"

/proc/get_accesslist_static_data(num_min_region = REGION_GENERAL, num_max_region = REGION_COMMAND)
	var/list/retval
	for(var/i in num_min_region to num_max_region)
		var/list/accesses = list()
		var/list/available_accesses
		if(i == REGION_CENTCOMM) // Override necessary, because get_region_accesses(REGION_CENTCOM) returns BOTH CC and crew accesses.
			available_accesses = get_all_centcom_access()
		else
			available_accesses = get_region_accesses(i)
		for(var/access in available_accesses)
			var/access_desc = (i == REGION_CENTCOMM) ? get_centcom_access_desc(access) : get_access_desc(access)
			if (access_desc)
				accesses += list(list(
					"desc" = replacetext(access_desc, "&nbsp", " "),
					"ref" = access,
				))
		retval += list(list(
			"name" = get_region_accesses_name(i),
			"regid" = i,
			"accesses" = accesses
		))
	return retval
