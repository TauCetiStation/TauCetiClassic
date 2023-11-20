/datum/admins
	var/current_tab = 0

	var/list/datum/tgui_secrets/tgui_secrets = list()

	var/static/datum/announcement/station/gravity_off/announce_gravity_off = new
	var/static/datum/announcement/station/gravity_on/announce_gravity_on = new
	var/static/datum/announcement/centcomm/access_override/announce_override = new

/datum/admins/Destroy()
	QDEL_LIST_ASSOC_VAL(tgui_secrets)
	return ..()

/datum/admins/proc/Secrets()
	if(!check_rights(0))
		return

	var/dat

	dat += "<a href='?src=\ref[src];secretsmenu=tab;tab=0' [current_tab == 0 ? "class='selected'" : ""]>Debug</a>"
	dat += "<a href='?src=\ref[src];secretsmenu=tab;tab=1' [current_tab == 1 ? "class='selected'" : ""]>IC Events</a>"
	dat += "<a href='?src=\ref[src];secretsmenu=tab;tab=2' [current_tab == 2 ? "class='selected'" : ""]>OOC Events</a>"

	switch(current_tab)
		if(0) // Debug
			if(check_rights(R_ADMIN,0))
				dat += {"
					<h4>Game</h4>
					<A href='?src=\ref[src];secretsadmin=showailaws'>Show AI Laws</A><BR>
					<A href='?src=\ref[src];secretsadmin=showgm'>Show Game Mode</A><BR>
					<A href='?src=\ref[src];secretsadmin=manifest'>Show Crew Manifest</A><BR>
					<A href='?src=\ref[src];secretsadmin=check_antagonist'>Show current traitors and objectives</A><BR>
					<A href='?src=\ref[src];secretsadmin=night_shift_set'>Set Night Shift Mode</A><BR>
					<A href='?src=\ref[src];secretsadmin=smartlight_set'>Set Smart Light Mode</A><BR>
					<A href='?src=\ref[src];secretsadmin=clear_virus'>Cure all diseases currently in existence</A><BR>
					<A href='?src=\ref[src];secretsadmin=restore_air'>Restore air in your zone</A><BR>
					<h4>Bombs</h4>
					[check_rights(R_SERVER,0) ? "<A href='?src=\ref[src];secretsfun=togglebombcap'>Toggle bomb cap</A><BR>" : "<BR>"]
					<h4>Lists</h4>
					<A href='?src=\ref[src];secretsadmin=list_bombers'>Bombing List</A><BR>
					<A href='?src=\ref[src];secretsadmin=list_signalers'>Show last [length(lastsignalers)] signalers</A><BR>
					<A href='?src=\ref[src];secretsadmin=list_lawchanges'>Show last [length(lawchanges)] law changes</A><BR>
					<A href='?src=\ref[src];secretsadmin=DNA'>List DNA (Blood)</A><BR>
					<A href='?src=\ref[src];secretsadmin=fingerprints'>List Fingerprints</A><BR>
					<h4>Power</h4>
					<A href='?src=\ref[src];secretsfun=blackout'>Break all lights</A><BR>
					<A href='?src=\ref[src];secretsfun=whiteout'>Fix all lights</A><BR>
					<A href='?src=\ref[src];secretsfun=power'>Make all areas powered</A><BR>
					<A href='?src=\ref[src];secretsfun=unpower'>Make all areas unpowered</A><BR>
					<A href='?src=\ref[src];secretsfun=quickpower'>Power all SMES</A><BR>
					"}
			else
				if(check_rights(R_SERVER,0)) //only add this if admin secrets are unavailiable; otherwise, it's added inline
					dat += "<b>Bomb cap: </b><A href='?src=\ref[src];secretsfun=togglebombcap'>Toggle bomb cap</A><BR>"
					dat += "<BR>"

			if(check_rights(R_DEBUG,0))
				dat += {"
					<h4>Security Level Elevated</h4>
					<A href='?src=\ref[src];secretscoder=maint_access_engiebrig'>Change all maintenance doors to engie/brig access only</A><BR>
					<A href='?src=\ref[src];secretscoder=maint_access_brig'>Change all maintenance doors to brig access only</A><BR>
					<A href='?src=\ref[src];secretscoder=infinite_sec'>Remove cap on security officers</A><BR>
					<h4>Coder Secrets</h4>
					<A href='?src=\ref[src];secretsadmin=list_job_debug'>Show Job Debug</A><BR>
					<A href='?src=\ref[src];secretscoder=spawn_objects'>Admin Log</A><BR>
					<A href='?src=\ref[src];secretscoder=topicspam'>Spam to Topic()</A><BR>
					"}

		if(1) // IC Events
			if(check_rights((R_EVENT|R_FUN),0))
				dat += {"
					<h4>Teams</h4>
					<A href='?src=\ref[src];secretsfun=syndstriketeam'>Send in a Syndicate Strike Team</A><BR>
					<A href='?src=\ref[src];secretsfun=striketeam'>Send in a Deathsquad</A><BR>
					<A href='?src=\ref[src];secretsfun=police'>Send in a Space Police</A><BR>
					<A href='?src=\ref[src];secretsfun=spaceninja'>Send in a Space Ninja</A><BR>
					<h4>Change Security Level</h4>
					<A href='?src=\ref[src];secretsfun=securitylevel0'>Security Level - Green</A><BR>
					<A href='?src=\ref[src];secretsfun=securitylevel1'>Security Level - Blue</A><BR>
					<A href='?src=\ref[src];secretsfun=securitylevel2'>Security Level - Red</A><br>
					<A href='?src=\ref[src];secretsfun=securitylevel3'>Security Level - Delta</A><BR>
					<h4>Do something stupid</h4>
					<A href='?src=\ref[src];secretsfun=spawncompletesandwich'>Create a Complete Sandwich</A><BR>
					<A href='?src=\ref[src];secretsfun=forcedquality'>Force a \"Random\" Quality</A><BR>
					"}

		if(2) // OOC Events
			if(check_rights((R_FUN|R_EVENT),0))
				dat += {"
					<h4>Clothing</h4>
					<A href='?src=\ref[src];secretsfun=sec_clothes'>Remove 'internal' clothing</A><BR>
					<A href='?src=\ref[src];secretsfun=sec_all_clothes'>Remove ALL clothing</A><BR>
					<h4>TDM</h4>
					<A href='?src=\ref[src];secretsfun=traitor_all'>Everyone is the traitor</A><BR>
					<A href='?src=\ref[src];secretsfun=onlyone'>There can only be one!</A><BR>
					<h4>Round-enders</h4>
					<A href='?src=\ref[src];secretsfun=monkey'>Turn all humans into monkeys</A><BR>
					<A href='?src=\ref[src];secretsfun=corgi'>Turn all humans into corgi</A><BR>
					<A href='?src=\ref[src];secretsfun=retardify'>Make all players retarded</A><BR>
					<A href='?src=\ref[src];secretsfun=prisonwarp'>Warp all Players to Prison</A><BR>
					<A href='?src=\ref[src];secretsfun=fakeguns'>Make all items look like guns</A><BR>
					<A href='?src=\ref[src];secretsfun=floorlava'>The floor is lava! (DANGEROUS: extremely lame)</A><BR>
					<A href='?src=\ref[src];secretsfun=advanceddarkness'>Advanced darkness! (DANGEROUS: extremely dark)</A><BR>
					"}
				if(check_rights(R_VAREDIT, 0))
					dat += "<A href='?src=\ref[src];secretsadmin=mass_sleep'>Put everyone to sleep</A><BR>"
				dat += {"
					<h4>AI</h4>
					<A href='?src=\ref[src];secretsfun=tripleAI'>Triple AI mode (needs to be used in the lobby)</A><BR>
					<A href='?src=\ref[src];secretsfun=friendai'>Best Friend AI</A><BR>
					<h4>Modes</h4>
					<A href='?src=\ref[src];secretsfun=flicklights'>Ghost Mode</A><BR>
					<A href='?src=\ref[src];secretsfun=dorf'>Dorf Mode</A><BR>
					<A href='?src=\ref[src];secretsfun=schoolgirl'>Japanese Animes Mode</A><BR>
					<A href='?src=\ref[src];secretsfun=eagles'>Egalitarian Station Mode</A><BR>
					<h4>Shuttles</h4>
					<A href='?src=\ref[src];secretsfun=moveferry'>Move Ferry</A><BR>
					<A href='?src=\ref[src];secretsfun=movealienship'>Move Alien Dinghy</A><BR>
					<A href='?src=\ref[src];secretsfun=moveadminshuttle'>Move Administration Shuttle</A><BR>
					<h4>Misc</h4>
					<A href='?src=\ref[src];secretsfun=gravity'>Toggle Gravity</A><BR>
					<A href='?src=\ref[src];secretsfun=frost'>!Freeze the station!</A><BR>
					<A href='?src=\ref[src];secretsfun=sec_classic1'>Remove firesuits, grilles, and pods</A><BR>
					<A href='?src=\ref[src];secretsfun=drop_asteroid'>Drop asteroid</A><BR>
					<A href='?src=\ref[src];secretsfun=global_sound_speed'>Set global sound speed modifier</A><BR>
					"}

	var/datum/browser/popup = new(usr, "secrets", "<div align='center'>Admin Secrets</div>", 500, 812)
	popup.set_content(dat)
	popup.open()


// SECRETSFUN
/datum/admins/proc/Secretsfun_topic(item,href_list)
	if(!check_rights(R_FUN|R_EVENT))
		return
	var/ok = 0
	switch(href_list["secretsfun"])
		//Remove 'internal' clothing
		if("sec_clothes")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","SC")
			for(var/obj/item/clothing/under/O in world)
				qdel(O)
			ok = 1
		//Remove ALL clothing
		if("sec_all_clothes")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","SAC")
			for(var/obj/item/clothing/O in world)
				qdel(O)
			ok = 1
		//Remove firesuits, grilles, and pods
		if("sec_classic1")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","SC1")
			for(var/obj/item/clothing/suit/fire/O in world)
				qdel(O)
			for(var/obj/structure/grille/O in world)
				qdel(O)
/*					for(var/obj/machinery/vehicle/pod/O in world)
				for(var/mob/M in src)
					M.loc = src.loc
					if (M.client)
						M.client.perspective = MOB_PERSPECTIVE
						M.client.eye = M
				qdel(O)
			ok = 1*/
		// Turn all humans into monkeys
		if("monkey")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","M")
			for(var/mob/living/carbon/human/H as anything in human_list)
				spawn(0)
					H.monkeyize()
			ok = 1
		// Turn all humans into corgi
		if("corgi")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","M")
			for(var/mob/living/carbon/human/H as anything in human_list)
				spawn(0)
					H.corgize()
			ok = 1
		// Send in a Deathsquad
		if("striketeam")
			if(usr.client.call_strike_team())
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","Strike")
		// Send in a Syndicate Strike Team
		if("syndstriketeam")
			if(usr.client.syndicate_strike_team())
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","Syndi Strike")
		// Send in a Space Police
		if("police")
			if(usr.client.send_space_police())
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","Space Police")
		// Triple AI mode (needs to be used in the lobby)
		if("tripleAI")
			usr.client.triple_ai()
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","TriAI")
		// Toggle station artificial gravity
		if("gravity")
			if(!(SSticker && SSticker.mode))
				to_chat(usr, "Please wait until the game starts!  Not sure how it will work otherwise.")
				return
			gravity_is_on = !gravity_is_on
			for(var/area/A in all_areas)
				A.gravitychange(gravity_is_on)
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","Grav")
			if(gravity_is_on)
				log_admin("[key_name(usr)] toggled gravity on.")
				message_admins("<span class='notice'>[key_name_admin(usr)] toggled gravity on.</span>")
				announce_gravity_on.play()
			else
				log_admin("[key_name(usr)] toggled gravity off.")
				message_admins("<span class='notice'>[key_name_admin(usr)] toggled gravity off.</span>")
				announce_gravity_off.play()
		// Make all areas powered
		if("power")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","P")
			log_admin("[key_name(usr)] made all areas powered")
			message_admins("<span class='notice'>[key_name_admin(usr)] made all areas powered</span>")
			power_restore(badminery=1)
		// Make all areas unpowered
		if("unpower")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","UP")
			log_admin("[key_name(usr)] made all areas unpowered")
			message_admins("<span class='notice'>[key_name_admin(usr)] made all areas unpowered</span>")
			power_failure()
		// Power all SMES
		if("quickpower")
			if(power_fail_event)
				to_chat(usr, "Power fail event is in progress.. Please wait or use normal power restore.")
				return
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","QP")
			log_admin("[key_name(usr)] made all SMESs powered")
			message_admins("<span class='notice'>[key_name_admin(usr)] made all SMESs powered</span>")
			power_restore_quick()
		// Warp all Players to Prison
		if("prisonwarp")
			if(!SSticker)
				tgui_alert(usr, "The game hasn't started yet!")
				return
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","PW")
			message_admins("<span class='notice'>[key_name_admin(usr)] teleported all players to the prison station.</span>")
			for(var/mob/living/carbon/human/H as anything in human_list)
				var/turf/loc = find_loc(H)
				var/security = 0
				if(!is_station_level(loc.z) || prisonwarped.Find(H))
			//don't warp them if they aren't ready or are already there
					continue
				H.Paralyse(5)
				if(H.wear_id)
					var/obj/item/weapon/card/id/id = H.get_idcard()
					for(var/A in id.access)
						if(A == access_security)
							security++
				if(!security)
					//strip their stuff before they teleport into a cell :downs:
					for(var/obj/item/weapon/W in H)
						if(isbodypart(W))
							continue
							//don't strip organs
						H.drop_from_inventory(W)
					//teleport person to cell
					H.loc = pick(prisonwarp)
					H.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(H), SLOT_W_UNIFORM)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), SLOT_SHOES)
				else
					//teleport security person
					H.loc = pick(prisonsecuritywarp)
				prisonwarped += H
		// Everyone is the traitor
		if("traitor_all")
			if(!SSticker)
				tgui_alert(usr, "The game hasn't started yet!")
				return
			feedback_inc("admin_secrets_fun_used",1)
			for(var/mob/living/carbon/human/H in player_list)
				if(H.stat == DEAD || !H.client || !H.mind) continue
				if(is_special_character(H)) continue
				create_and_setup_role(/datum/role/traitor/syndbeacon, H)
			for(var/mob/living/silicon/A in player_list)
				create_and_setup_role(/datum/role/traitor/syndbeacon, A)

			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","ShM")
		// Move Administration Shuttle
		if("moveadminshuttle")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","ShA")
			move_admin_shuttle()
			message_admins("<span class='notice'>[key_name_admin(usr)] moved the centcom administration shuttle</span>")
			log_admin("[key_name(usr)] moved the centcom administration shuttle")
		// Move Ferry
		if("moveferry")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","ShF")
			move_ferry()
			message_admins("<span class='notice'>[key_name_admin(usr)] moved the centcom ferry</span>")
			log_admin("[key_name(usr)] moved the centcom ferry")
		// Move Alien Dinghy
		if("movealienship")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","ShX")
			move_alien_ship()
			message_admins("<span class='notice'>[key_name_admin(usr)] moved the alien dinghy</span>")
			log_admin("[key_name(usr)] moved the alien dinghy")
		/*
		// Move Mining Shuttle
		if("moveminingshuttle")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","ShMi")
			move_mining_shuttle()
			message_admins("<span class='notice'>[key_name_admin(usr)] moved the mining shuttle</span>")
			log_admin("[key_name(usr)] moved the alien dinghy")
		*/
		// Toggle bomb cap
		if("togglebombcap")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","BC")
			var/new_cap = input("Enter new cap value, up to 128. Default is [SSexplosions.MAX_EX_LIGHT_RANGE].", "Set Cap") as num|null
			if(isnull(new_cap))
				return
			new_cap = clamp(round(new_cap), 0, 128)
			SSexplosions.MAX_EX_DEVESTATION_RANGE = round(new_cap * 0.25)
			SSexplosions.MAX_EX_HEAVY_RANGE = round(new_cap * 0.5)
			SSexplosions.MAX_EX_LIGHT_RANGE = new_cap
			SSexplosions.MAX_EX_FLASH_RANGE = new_cap
			//SSexplosions.MAX_EX_FLAME_RANGE = new_cap
			message_admins("<span class='warning'><b> [key_name_admin(usr)] changed the bomb cap to [SSexplosions.MAX_EX_DEVESTATION_RANGE], [SSexplosions.MAX_EX_HEAVY_RANGE], [SSexplosions.MAX_EX_LIGHT_RANGE]</b></span>")
			log_admin("[key_name(usr)] changed the bomb cap to [new_cap]")
		// Ghost Mode
		if("flicklights")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","FL")
			while(usr.stat == CONSCIOUS)
				//knock yourself out to stop the ghosts
				for(var/mob/M in player_list)
					if(M.stat != DEAD && prob(25))
						var/area/AffectedArea = get_area(M)
						if(AffectedArea.name != "Space" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
							AffectedArea.power_light = 0
							AffectedArea.power_change()
							spawn(rand(55,185))
								AffectedArea.power_light = 1
								AffectedArea.power_change()
							var/Message = rand(1,4)
							switch(Message)
								if(1)
									M.show_message("<span class='notice'>You shudder as if cold...</span>", SHOWMSG_FEEL)
								if(2)
									M.show_message("<span class='notice'>You feel something gliding across your back...</span>", SHOWMSG_FEEL)
								if(3)
									M.show_message("<span class='notice'>Your eyes twitch, you feel like something you can't see is here...</span>", SHOWMSG_VISUAL)
								if(4)
									M.show_message("<span class='notice'>You notice something moving out of the corner of your eye, but nothing is there...</span>", SHOWMSG_VISUAL)
							for(var/obj/W in orange(5,M))
								if(prob(25) && !W.anchored)
									step_rand(W)
				sleep(rand(100,1000))
			for(var/mob/M in player_list)
				if(M.stat != DEAD)
					to_chat("<span class='notice'>The chilling wind suddenly stops...</span>")
		// !Freeze the station!
		if("frost")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","FROST")
			message_admins("[key_name_admin(usr)] freezed the station")
			var/datum/anomaly_frost/FROST = new /datum/anomaly_frost()
			FROST.set_params(usr)
		// Give guns to crew
		if("spawnguns")
			feedback_inc("admin_secrets_fun_used", 1)
			feedback_add_details("admin_secrets_fun_used", "SG")
			rightandwrong(0, usr)
		// Give spells to crew
		if("spawnspells")
			feedback_inc("admin_secrets_fun_used", 1)
			feedback_add_details("admin_secrets_fun_used", "SP")
			rightandwrong(1, usr)
		// Break all lights
		if("blackout")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","BO")
			message_admins("[key_name_admin(usr)] broke all lights")
			for(var/obj/machinery/light/L in machines)
				L.broken()
		// Fix all lights
		if("whiteout")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","WO")
			for(var/obj/machinery/light/L in machines)
				L.fix()
			message_admins("[key_name_admin(usr)] fixed all lights")
		// Best Friend AI
		if("friendai")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","FA")
			for(var/mob/camera/Eye/ai/aE as anything in ai_eyes_list)
				aE.icon_state = "ai_friend"
			for(var/obj/machinery/ai_status_display/A in ai_status_display_list)
				A.emotion = "Friend Computer"
			for(var/obj/machinery/status_display/A in status_display_list)
				A.friendc = 1
			message_admins("[key_name_admin(usr)] turned all AIs into best friends.")
		// The floor is lava! (DANGEROUS: extremely lame)
		if("floorlava")
			SSweather.run_weather("the floor is lava", ZTRAIT_STATION)
		// Advanced darkness! (DANGEROUS: extremely dark)
		if("advanceddarkness")
			SSweather.run_weather("advanced darkness", ZTRAIT_STATION)
		// Trigger a Virus Outbreak
		if("virus")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","V")
			var/answer = tgui_alert(usr, "Do you want this to be a greater disease or a lesser one?",, list("Greater","Lesser"))
			if(answer=="Lesser")
				virus2_lesser_infection()
				message_admins("[key_name_admin(usr)] has triggered a lesser virus outbreak.")
			else
				virus2_greater_infection()
				message_admins("[key_name_admin(usr)] has triggered a greater virus outbreak.")
		// Make all players retarded
		if("retardify")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","RET")
			for(var/mob/living/carbon/human/H in player_list)
				to_chat(H, "<span class='warning'><B>You suddenly feel stupid.</B></span>")
				H.setBrainLoss(60)
			message_admins("[key_name_admin(usr)] made everybody retarded")
		// Make all items look like guns
		if("fakeguns")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","FG")
			for(var/obj/item/W in world)
				if(istype(W, /obj/item/clothing) || istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/weapon/disk) || istype(W, /obj/item/weapon/tank))
					continue
				W.icon = 'icons/obj/gun.dmi'
				W.icon_state = "revolver"
				W.item_state = "gun"
			message_admins("[key_name_admin(usr)] made every item look like a gun")
		// Japanese Animes Mode
		if("schoolgirl")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","SG")
			for(var/obj/item/clothing/under/W in world)
				W.icon_state = "schoolgirl"
				W.item_state = "schoolgirl"
			message_admins("[key_name_admin(usr)] activated Japanese Animes mode")
			announcement_ping.play("animes")
		// Egalitarian Station Mode
		if("eagles")//SCRAW
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","EgL")
			for(var/obj/machinery/door/airlock/W in airlock_list)
				if(is_station_level(W.z) && !istype(get_area(W), /area/station/bridge) && !istype(get_area(W), /area/station/civilian/dormitories) && !istype(get_area(W), /area/station/security/prison))
					W.req_access = list()
			message_admins("[key_name_admin(usr)] activated Egalitarian Station mode")
			announce_override.play()
		// Dorf Mode
		if("dorf")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","DF")
			for(var/mob/living/carbon/human/H as anything in human_list)
				H.f_style = "Dwarf Beard"
				H.update_hair()
			message_admins("[key_name_admin(usr)] activated dorf mode")
		// Battle to the death (only one)
		if("onlyone")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","OO")
			usr.client.only_one()
			message_admins("[key_name_admin(usr)] has triggered a battle to the death (only one)")
		// Security levels
		if("securitylevel0")
			set_security_level(0)
			message_admins("<span class='notice'>[key_name_admin(usr)] change security level to Green.</span>", 1)
		if("securitylevel1")
			set_security_level(1)
			message_admins("<span class='notice'>[key_name_admin(usr)] change security level to Blue.</span>", 1)
		if("securitylevel2")
			set_security_level(2)
			message_admins("<span class='notice'>[key_name_admin(usr)] change security level to Red.</span>", 1)
		if("securitylevel3")
			set_security_level(3)
			message_admins("<span class='notice'>[key_name_admin(usr)] change security level to Delta.</span>", 1)
		// Drop asteroid
		if("drop_asteroid")
			if(!check_rights(R_EVENT))
				to_chat(usr, "<span class='warning'>You don't have permissions for this</span>")
				return
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","ASTEROID")
			usr.client.drop_asteroid()
		if("spawncompletesandwich")
			if(!check_rights(R_EVENT|R_FUN))
				to_chat(usr, "<span class='warning'>You don't have permissions for this</span>")
				return
			var/turf/T = get_turf(usr)
			message_admins("[key_name_admin(usr)] has created a complete sandwich at location [COORD(T)] [ADMIN_JMP(usr)]")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","DASANDWICH")
			var/obj/item/weapon/reagent_containers/food/snacks/csandwich/CS = new(get_turf(usr))
			CS.complete()
		if("forcedquality")
			if(!check_rights(R_EVENT|R_FUN))
				to_chat(usr, "<span class='warning'>You don't have permissions for this</span>")
				return
			if(!SSqualities)
				to_chat(usr, "<span class='warning'>Please wait untill Qualities Subsystem loads</span>")
				return
			var/quality_name = input("Please choose a quality.", "Choose quality", null) as null|anything in SSqualities.qualities_by_name
			if(!quality_name)
				return

			var/datum/quality/Q = SSqualities.qualities_by_name[quality_name]
			SSqualities.forced_quality_type = Q.type

		if("global_sound_speed")
			if(!check_rights(R_SOUNDS))
				return
			playsound_frequency_admin = clamp(input(usr, "Any value from -100 to 100 will play this sound at a multiple of its normal frequency. Set to 2 to play at double speed, for example, or -1 to play backwards. A value of 0 or 1 will play the sound at its normal frequency.", "Set Sound Speed", 0), -100, 100)
			message_admins("[key_name_admin(usr)] has modified global sound speed to [playsound_frequency_admin]")
			feedback_inc("admin_secrets_fun_used",1)
			feedback_add_details("admin_secrets_fun_used","Global Sound Frequency")
		else
			to_chat(world, "oof, this is ["secretsfun"] not worked")
	if(usr)
		log_admin("[key_name(usr)] used secret [href_list["secretsfun"]]")
		if (ok)
			to_chat(world, text("<B>A secret has been activated by []!</B>", usr.key))


// SECRETSADMIN
/datum/admins/proc/Secretsadmin_topic(item,href_list)
	if(!check_rights(R_ADMIN))
		return
	var/ok = 0
	switch(href_list["secretsadmin"])
		if("clear_bombs")
			//I do nothing
		// Cure all diseases currently in existence
		if("clear_virus")
			var/choice1 = input("Are you sure you want to cure all disease?") in list("Yes", "Cancel")
			if(choice1 == "Yes")
				message_admins("[key_name_admin(usr)] has cured all diseases.")
				for(var/mob/living/carbon/M as anything in carbon_list)
					if(M.virus2.len)
						for(var/ID in M.virus2)
							var/datum/disease2/disease/V = M.virus2[ID]
							V.cure(M)

				for(var/obj/effect/decal/cleanable/O in decal_cleanable)
					if(istype(O,/obj/effect/decal/cleanable/blood))
						var/obj/effect/decal/cleanable/blood/B = O
						if(B.virus2.len)
							B.virus2.Cut()

					else if(istype(O,/obj/effect/decal/cleanable/mucus))
						var/obj/effect/decal/cleanable/mucus/N = O
						if(N.virus2.len)
							N.virus2.Cut()
		// Restore air in your zone
		if("restore_air") // this is unproper way to restore turfs default gas values, since you can delete sleeping agent for example.
			var/turf/simulated/T = get_turf(usr)
			if((isfloorturf(T) || istype(T, /turf/simulated/shuttle/floor)) && T.zone.air)
				var/datum/gas_mixture/GM = T.zone.air

				for(var/g in gas_data.gases)
					GM.gas -= g

				GM.gas["carbon_dioxide"] = T.carbon_dioxide
				GM.gas["phoron"] = T.phoron
				GM.gas["nitrogen"] = T.nitrogen
				GM.gas["oxygen"] = T.oxygen
				GM.temperature = 293
				GM.update_values()

				message_admins("[key_name_admin(usr)] has restored air in [COORD(T)] <a href='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>.")
			else
				to_chat(usr, "<span class='userdanger'>You are staying on incorrect turf.</span>")
		// Bombing List
		if("list_bombers")
			var/dat = ""
			for(var/l in bombers)
				dat += text("[l]<BR>")

			var/datum/browser/popup = new(usr, "bombers", "Bombing List")
			popup.set_content(dat)
			popup.open()

		// Show last [length(lastsignalers)] signalers
		if("list_signalers")
			var/dat = ""
			for(var/sig in lastsignalers)
				dat += "[sig]<BR>"

			var/datum/browser/popup = new(usr, "lastsignalers", "Showing last [length(lastsignalers)] signalers", 800, 500)
			popup.set_content(dat)
			popup.open()

		// how last [length(lawchanges)] law changes
		if("list_lawchanges")
			var/dat = ""
			for(var/sig in lawchanges)
				dat += "[sig]<BR>"

			var/datum/browser/popup = new(usr, "lawchanges", "Showing last [length(lawchanges)] law changes", 800, 500)
			popup.set_content(dat)
			popup.open()

		// Show Job Debug
		if("list_job_debug")
			var/dat = ""
			if(SSjob)
				for(var/line in SSjob.job_debug)
					dat += "[line]<BR>"
				dat+= "*******<BR><BR>"
				for(var/datum/job/job in SSjob.occupations)
					if(!job)	continue
					dat += "job: [job.title], current_positions: [job.current_positions], total_positions: [job.total_positions] <BR>"

				var/datum/browser/popup = new(usr, "jobdebug", "Job Debug info", 600, 500)
				popup.set_content(dat)
				popup.open()

		// Show AI Laws
		if("showailaws")
			output_ai_laws()
		// Show Game Mode
		if("showgm")
			if(!SSticker)
				tgui_alert(usr, "The game hasn't started yet!")
			else if (SSticker.mode)
				tgui_alert(usr, "The game mode is [SSticker.mode.name]")
			else tgui_alert(usr, "For some reason there's a ticker, but not a game mode")
		// Show Crew Manifest
		if("manifest")
			var/dat = "<B>Showing Crew Manifest.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
			for(var/mob/living/carbon/human/H as anything in human_list)
				if(H.ckey)
					dat += text("<tr><td>[]</td><td>[]</td></tr>", H.name, H.get_assignment())
			dat += "</table>"

			var/datum/browser/popup = new(usr, "manifest", "Showing Crew Manifest", 440, 410)
			popup.set_content(dat)
			popup.open()

		// Show current traitors and objectives
		if("check_antagonist")
			check_antagonists()
		// List DNA (Blood)
		if("DNA")
			var/dat = ""
			dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
			for(var/mob/living/carbon/human/H as anything in human_list)
				if(H.dna && H.ckey)
					dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.dna.b_type]</td></tr>"
			dat += "</table>"

			var/datum/browser/popup = new(usr, "DNA", "Showing DNA from blood", 440, 410)
			popup.set_content(dat)
			popup.open()

		// List Fingerprints
		if("fingerprints")
			var/dat = ""
			dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
			for(var/mob/living/carbon/human/H as anything in human_list)
				if(H.ckey)
					if(H.dna && H.dna.uni_identity)
						dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
					else if(H.dna && !H.dna.uni_identity)
						dat += "<tr><td>[H]</td><td>H.dna.uni_identity = null</td></tr>"
					else if(!H.dna)
						dat += "<tr><td>[H]</td><td>H.dna = null</td></tr>"
			dat += "</table>"

			var/datum/browser/popup = new(usr, "fingerprints", "Showing Fingerprints", 440, 410)
			popup.set_content(dat)
			popup.open()

		// Set Night Shift Mode
		if("night_shift_set")
			var/val = tgui_alert(usr, "What do you want to set night shift to?", "Night Shift", list("On", "Off", "Automatic"))
			switch(val)
				if("Automatic")
					SSsmartlight.can_fire = TRUE
					SSsmartlight.check_nightshift()
				if("On")
					SSsmartlight.can_fire = FALSE
					SSsmartlight.toggle_nightshift(TRUE)
				if("Off")
					SSsmartlight.can_fire = FALSE
					SSsmartlight.toggle_nightshift(FALSE)
			if(val)
				message_admins("[key_name_admin(usr)] switched night shift mode to '[val]'.")
				log_admin("[key_name(usr)] switched night shift mode to '[val]'.")

		if("smartlight_set")
			var/val = tgui_alert(usr, "What do you want to set smartlight to?", "Smartlight", list("Force Mode", "Cancel Forced Mode"))
			var/custom_mode
			switch(val)
				if("Force Mode")
					custom_mode = input("Select new lighting mode. Station will be locked in this mode.", "Force Mode") as null|anything in light_modes_by_name
					if(custom_mode)
						SSsmartlight.forced_admin_mode = TRUE
						SSsmartlight.can_fire = FALSE
						SSsmartlight.update_mode(light_modes_by_name[custom_mode], TRUE)
				if("Cancel Forced Mode")
					SSsmartlight.can_fire = TRUE
					SSsmartlight.forced_admin_mode = FALSE
					SSsmartlight.reset_smartlight()
			if(val)
				message_admins("[key_name_admin(usr)] switched smartlight mode to '[val]'[custom_mode && ": '[custom_mode]'"].")
				log_admin("[key_name(usr)] switched smartlight mode to '[val]'[custom_mode && ": '[custom_mode]'"].")
		// Put everyone to sleep
		if("mass_sleep")
			for(var/mob/living/L in global.living_list)
				L.SetSleeping(6000 SECONDS)
		else
			to_chat(world, "oof, this is ["secretsadmin"] not worked")

	if (usr)
		log_admin("[key_name(usr)] used secret [href_list["secretsadmin"]]")
		if (ok)
			to_chat(world, text("<B>A secret has been activated by []!</B>", usr.key))


// SECRETSCODER
/datum/admins/proc/Secretscoder_topic(item,href_list)
	if(!check_rights(R_DEBUG))
		return
	switch(href_list["secretscoder"])
		// Admin Log
		if("spawn_objects")
			var/dat = ""
			for(var/l in admin_log)
				dat += "<li>[l]</li>"
			if(!admin_log.len)
				dat += "No-one has done anything this round!"

			var/datum/browser/popup = new(usr, "admin_log", "Admin Log")
			popup.set_content(dat)
			popup.open()

		// Change all maintenance doors to brig access only
		if("maint_access_brig")
			for(var/obj/machinery/door/airlock/maintenance/M in airlock_list)
				if (access_maint_tunnels in M.req_access)
					M.req_access = list(access_brig)
			message_admins("[key_name_admin(usr)] made all maint doors brig access-only.")
		// Change all maintenance doors to engie/brig access only
		if("maint_access_engiebrig")
			for(var/obj/machinery/door/airlock/maintenance/M in airlock_list)
				if (access_maint_tunnels in M.req_access)
					M.req_access = list()
					M.req_one_access = list(access_brig,access_engine)
			message_admins("[key_name_admin(usr)] made all maint doors engineering and brig access-only.")
		// Remove cap on security officers
		if("infinite_sec")
			var/datum/job/J = SSjob.GetJob("Security Officer")
			if(!J) return
			J.total_positions = -1
			J.spawn_positions = -1
			message_admins("[key_name_admin(usr)] has removed the cap on security officers.")
		if("topicspam")
			var/count = config.minutetopiclimit * 2
			if(tgui_alert(usr, "Are you sure? You will be deadminned and [count] Topic() calls will be generated.",, list("Yes","No")) == "Yes")
				to_chat(usr, "<span class='interface'>You are lost your keys to control this station. Please wait...</span>")
				usr.client.holder.disassociate()
				message_admins("[key_name_admin(usr)] started topic spam.")
				for(var/i in 1 to count)
					sleep(1)
					usr.client.Topic("spam=[i]", list())
				usr.client.deadmin_holder.reassociate()
				to_chat(usr, "<span class='interface'>You again have the keys to control the planet, or at least a small space station.</span>")
		else
			to_chat(world, "oof, this is ["secretcoder"] not worked")

