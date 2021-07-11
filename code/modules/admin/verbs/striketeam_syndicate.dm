//SYNDICATE STRIKE TEAMS

var/const/syndicate_commandos_possible = 6 //if more Commandos are needed in the future
var/global/sent_syndicate_strike_team = FALSE

/client/proc/syndicate_strike_team()
	if(!SSticker)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return
	if(world.time < 6000)
		to_chat(usr, "<span class='warning'>Not so fast, buddy. Wait a few minutes until the game gets going. There are [(6000-world.time)/10] seconds remaining.</span>")
		return
	if(sent_syndicate_strike_team == 1)
		to_chat(usr, "<span class='warning'>The Syndicate are already sending a team, Mr. Dumbass.</span>")
		return
	if(tgui_alert(usr, "Do you want to send in the Syndicate Strike Team? Once enabled, this is irreversible.",, list("Yes","No"))=="No")
		return
	tgui_alert(usr, "This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned syndicates have internals cameras which are viewable through a monitor inside the Syndicate Mothership Bridge. Assigning the team's detailed task is recommended from there. While you will be able to manually pick the candidates from active ghosts, their assignment in the squad will be random.")

	if(sent_syndicate_strike_team)
		to_chat(src, "Looks like someone beat you to it.")
		return

	var/mission = null
	mission = sanitize(input(src, "Please specify which mission the syndicate strike team shall undertake.", "Specify Mission", ""))
	if(!mission)
		if(tgui_alert(usr, "Error, no mission set. Do you want to exit the setup process?",, list("Yes","No"))=="Yes")
			return

	var/paper_text = sanitize(input(usr, "Please, enter the text if you want to leave job details for an elite syndicate on paper.", "What?", "") as message|null, MAX_PAPER_MESSAGE_LEN, extra = FALSE)
	var/paper_name = ""
	if(paper_text)
		paper_name = sanitize(input(usr, "Please, enter the name mission paper.", "What?", "") as text|null)

	sent_syndicate_strike_team = TRUE

	if (SSshuttle.direction == 1 && SSshuttle.online == 1)
		SSshuttle.recall()

	var/syndicate_commando_number = syndicate_commandos_possible //for selecting a leader
	var/syndicate_commando_leader = FALSE //when the leader is chosen. The last person spawned.

//Code for spawning a nuke auth code.
	var/nuke_code
	var/temp_code

	for(var/obj/machinery/nuclearbomb/N in poi_list)
		if(N.nuketype == "Syndi")
			temp_code = text2num(N.r_code)
			if(temp_code)//if it's actually a number. It won't convert any non-numericals.
				nuke_code = N.r_code
				break

//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.
	var/list/candidates = list()	//candidates for being a commando out of all the active ghosts in world.
	var/list/commandos = list()			//actual commando ghosts as picked by the user.
	for(var/mob/dead/observer/G	 in player_list)
		if(!G.client.holder && !G.client.is_afk())	//Whoever called/has the proc won't be added to the list.
			if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
				candidates += G.key
	for(var/i=syndicate_commandos_possible,(i > 0 && candidates.len),i--)//Decrease with every commando selected.
		var/candidate = input("Pick characters to spawn as the commandos. The first player will be the syndicate elite commandos leader!  This will go on until there either no more ghosts to pick from or the slots are full.", "Active Players") as null|anything in candidates	//It will auto-pick a person when there is only one candidate.
		candidates -= candidate		//Subtract from candidates.
		commandos += candidate//Add their ghost to commandos.

//Spawns commandos and equips them.
	if(syndicate_commando_number < 0)
		sent_syndicate_strike_team = FALSE
		to_chat(usr, "<span class='danger'>Syndicate elite strike team is abortet. No found candidats on this role.</span>")
		return

	syndicate_commando_leader = TRUE
	var/list/landmarkpos = list()
	var/obj/effect/landmark/SCP = null
	for(var/obj/effect/landmark/L in landmarks_list)
		if (L.name == "Syndicate-Commando")
			landmarkpos += L
		if(L.name == "Syndicate-Commando-Paper")
			SCP = L

	var/datum/faction/strike_team/syndiesquad/S = SSticker.mode.CreateFaction(/datum/faction/strike_team/syndiesquad)
	S.forgeObjectives(mission)
	for(var/i = 1; i <= commandos.len; i++)
		var/mob/living/carbon/human/new_syndicate_commando = new(get_turf(landmarkpos[i]))
		new_syndicate_commando.key = commandos[i]
		initial_syndicate_commando(new_syndicate_commando, syndicate_commando_leader)
		new_syndicate_commando.internal = new_syndicate_commando.s_store
		new_syndicate_commando.internals.icon_state = "internal1"

		//So they don't forget their code or mission.
		if(nuke_code)
			new_syndicate_commando.mind.store_memory("<B>Nuke Code:</B> <span class='warning'>[nuke_code]</span>.")
		else
			new_syndicate_commando.mind.store_memory("<B>Nuke Code:</B> <span class='warning'>Syndicate bomb no found</span>.")

		new_syndicate_commando.mind.store_memory("<B>Mission:</B> <span class='warning'>[mission]</span>.")

		to_chat(new_syndicate_commando, "<span class='notice'>You are an Elite Syndicate. [!syndicate_commando_leader?"commando":"<B>LEADER</B>"] in the service of the Syndicate. \nYour current mission is: <span class='warning'><B>[mission]</B></span></span>")

		syndicate_commando_number--

		if(syndicate_commando_leader)
			syndicate_commando_leader = FALSE

	for(var/obj/effect/landmark/L in landmarkpos)
		qdel(L)

	if(paper_text)
		var/obj/item/weapon/paper/paper_mission = new(SCP.loc)
		var/parsedtext = parsebbcode(paper_text)
		paper_mission.info = parsedtext
		var/obj/item/weapon/stamp/syndicate/SS = new
		SS.stamp_paper(paper_mission)
		paper_mission.update_icon()
		qdel(SS)

		if(paper_name)
			paper_mission.name = paper_name
		else
			paper_mission.name = "Syndicate Elite mission paper"

	qdel(SCP)
	landmarkpos = null
	commandos = null

	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned a Syndicate strike squad.</span>")
	log_admin("[key_name(usr)] used Spawn Syndicate Squad.")
	feedback_add_details("admin_verb","SDTHS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/initial_syndicate_commando(syndicate_commando, syndicate_leader_selected = FALSE)
	var/mob/living/carbon/human/new_syndicate_commando = syndicate_commando
	var/syndicate_commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/syndicate_commando_name = pick(last_names)

	new_syndicate_commando.gender = pick(MALE, FEMALE)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	A.randomize_appearance_for(new_syndicate_commando)

	new_syndicate_commando.real_name = "[!syndicate_leader_selected ? syndicate_commando_rank : syndicate_commando_leader_rank] [syndicate_commando_name]"
	new_syndicate_commando.age = !syndicate_leader_selected ? rand(new_syndicate_commando.species.min_age, new_syndicate_commando.species.min_age * 1.5) : rand(new_syndicate_commando.species.min_age * 1.25, new_syndicate_commando.species.min_age * 1.75)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind_initialize()
	new_syndicate_commando.mind.current.faction = "syndicate"

	new_syndicate_commando.equip_syndicate_commando(syndicate_leader_selected)
	new_syndicate_commando.playsound_local(null, 'sound/antag/ops.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	var/datum/faction/strike_team/syndiesquad/S = find_faction_by_type(/datum/faction/strike_team/syndiesquad)
	if(S)
		add_faction_member(S, new_syndicate_commando, FALSE)

/mob/living/carbon/human/proc/equip_syndicate_commando(syndicate_leader = FALSE)

	var/obj/item/device/radio/headset/syndicate/R = new (src)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	equip_to_slot_or_del(R, SLOT_L_EAR)
	var/obj/item/weapon/implant/dexplosive/DE = new(src)
	DE.imp_in = src
	DE.implanted = TRUE
	var/obj/item/clothing/under/syndicate/US = new (src)
	var/obj/item/clothing/accessory/storage/syndi_vest/SV = new (US)
	US.accessories += SV
	SV.on_attached(US, src, TRUE)
	new /obj/item/weapon/screwdriver/power(SV.hold)
	new /obj/item/weapon/wirecutters/power(SV.hold)
	new /obj/item/weapon/weldingtool/largetank(SV.hold)
	new /obj/item/device/multitool(SV.hold)
	equip_to_slot_or_del(US, SLOT_W_UNIFORM)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/combat(src), SLOT_SHOES)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(src), SLOT_GLOVES)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(src), SLOT_WEAR_MASK)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(src), SLOT_GLASSES)
	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(src), SLOT_BACK)
	equip_to_slot_or_del(new /obj/item/weapon/storage/box(src), SLOT_IN_BACKPACK)
	equip_to_slot_or_del(new /obj/item/ammo_box/magazine/sm45(src), SLOT_IN_BACKPACK)
	equip_to_slot_or_del(new /obj/item/ammo_box/magazine/sm45(src), SLOT_IN_BACKPACK)
	var/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian/SFKE = new (src)
	var/obj/item/stack/medical/suture/ST = new (src)
	SFKE.contents += ST
	SFKE.name = "Emergency Small first-aid kit"
	equip_to_slot_or_del(SFKE, SLOT_IN_BACKPACK)
	equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/small_firstaid_kit/nutriment(src), SLOT_IN_BACKPACK)
	var/obj/item/device/radio/uplink/SDCU = new (src)
	equip_to_slot_or_del(SDCU, SLOT_IN_BACKPACK)
	equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword(src), SLOT_L_STORE)
	equip_to_slot_or_del(new /obj/item/weapon/grenade/empgrenade(src), SLOT_R_STORE)
	equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/silenced(src), SLOT_BELT)
	var/obj/item/clothing/suit/space/rig/syndi/elite/SER = null
	if(syndicate_leader)
		SDCU.hidden_uplink.uses = 15
		SER = new /obj/item/clothing/suit/space/rig/syndi/elite/comander(src)
		equip_to_slot_or_del(SER, SLOT_WEAR_SUIT)
		equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/syndi/elite/comander(src), SLOT_HEAD)
		equip_to_slot_or_del(new /obj/item/weapon/pinpointer/advpinpointer(src), SLOT_IN_BACKPACK)
	else
		SDCU.hidden_uplink.uses = 10
		SER = new(src)
		equip_to_slot_or_del(SER, SLOT_WEAR_SUIT)
		equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/syndi/elite(src), SLOT_HEAD)

	var/obj/item/clothing/shoes/magboots/syndie/SB = new(SER)
	SB.name = "The syndicate magboots"
	SER.boots = SB

	equip_to_slot_or_del(new /obj/item/weapon/tank/oxygen/red(src), SLOT_S_STORE)

	var/obj/item/weapon/card/id/syndicate/W = new(src) //Untrackable by AI
	W.name = "[real_name]'s ID Card"
	if(syndicate_leader)
		W.icon_state = "syndicate-command"
		W.assignment = "Syndicate Commando Leader"
	else
		W.icon_state = "syndicate"
		W.assignment = "Syndicate Commando"
	W.registered_name = real_name

	equip_to_slot_or_del(W, SLOT_WEAR_ID)

	return 1
