/obj/item/device/radio/headset
	name = "radio headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys."
	icon_state = "headset_grey"
	item_state = "headset"
	item_state_world = "headset_grey_world"
	item_state_inventory = "headset_grey"
	g_amt = 0
	m_amt = 75
	subspace_transmission = 1
	canhear_range = 0 // can't hear headsets from very far away
	slot_flags = SLOT_FLAGS_EARS
	var/translate_binary = 0
	var/translate_hive = 0
	var/obj/item/device/encryptionkey/keyslot1 = null
	var/obj/item/device/encryptionkey/keyslot2 = null
	maxf = 1489

	var/ks1type = /obj/item/device/encryptionkey
	var/ks2type = null

/obj/item/device/radio/headset/atom_init()
	. = ..()
	if(ks1type)
		keyslot1 = new ks1type(src)
	if(ks2type)
		keyslot2 = new ks2type(src)
	INVOKE_ASYNC(src, PROC_REF(recalculateChannels))

/obj/item/device/radio/headset/Destroy()
	qdel(keyslot1)
	qdel(keyslot2)
	keyslot1 = null
	keyslot2 = null
	return ..()

/obj/item/device/radio/headset/receive_range(freq, level, aiOverride = 0)
	if (aiOverride)
		return ..(freq, level)
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		if(H.l_ear == src || H.r_ear == src)
			return ..(freq, level)
	return -1

/obj/item/device/radio/headset/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/radio_grid))
		if(grid)
			to_chat(user, "<span class='userdanger'>There is already installed Shielded grid!</span>")
			return
		to_chat(user, "<span class='notice'>You attach [I] to [src]!</span>")
		user.drop_from_inventory(I)
		var/obj/item/device/radio_grid/new_grid = I
		new_grid.attach(src)

	else if(iscutter(I))
		if(!grid)
			to_chat(user, "<span class='userdanger'>Nothing to cut here!</span>")
			return
		to_chat(user, "<span class='notice'>You pop out Shielded grid from [src]!</span>")

		var/obj/item/device/radio_grid/new_grid = new(get_turf(loc))
		new_grid.dettach(src)

	else if(isscrewing(I))
		if(!keyslot1 && !keyslot2)
			to_chat(user, "<span class='notice'>This headset doesn't have any encryption keys!  How useless...</span>")
			return

		for(var/ch_name in channels)
			radio_controller.remove_object(src, radiochannels[ch_name])
			secure_radio_connections[ch_name] = null
		var/turf/T = get_turf(user)
		if(keyslot1)
			keyslot1.loc = T
			keyslot1 = null
		if(keyslot2)
			keyslot2.loc = T
			keyslot2 = null
		recalculateChannels()
		playsound(user, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You pop out the encryption keys in the headset!</span>")

	else if(istype(I, /obj/item/device/encryptionkey))
		if(keyslot1 && keyslot2)
			to_chat(user, "<span class='notice'>The headset can't hold another key!</span>")
			return
		if(!keyslot1)
			user.drop_from_inventory(I, src)
			keyslot1 = I
		else
			user.drop_from_inventory(I, src)
			keyslot2 = I

		recalculateChannels()

	else
		return ..()

/obj/item/device/radio/headset/proc/recalculateChannels()
	channels = list()
	translate_binary = 0
	translate_hive = 0
	syndie = 0
	for(var/obj/item/device/encryptionkey/Slot in list(keyslot1, keyslot2))
		for(var/ch_name in Slot.channels)
			if(ch_name in channels)
				continue
			channels += ch_name
			channels[ch_name] = Slot.channels[ch_name]
		if(Slot.translate_binary)
			translate_binary = 1
		if(Slot.translate_hive)
			translate_hive = 1
		if(Slot.syndie)
			syndie = 1
	for (var/ch_name in channels)
		if(!radio_controller)
			sleep(30) // Waiting for the radio_controller to be created.
		if(!radio_controller)
			name = "broken radio headset"
			return
		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)

/obj/item/device/radio/headset/syndicate
	syndie = 1
	ks1type = /obj/item/device/encryptionkey/syndicate
	grid = TRUE

/obj/item/device/radio/headset/syndicate/atom_init()
	. = ..()
	set_frequency(SYND_FREQ)

/obj/item/device/radio/headset/heist
	syndie = TRUE
	ks1type = /obj/item/device/encryptionkey/heist
	grid = TRUE

/obj/item/device/radio/headset/heist/atom_init()
	. = ..()
	set_frequency(HEIST_FREQ)

/obj/item/device/radio/headset/ninja
	grid = TRUE

/obj/item/device/radio/headset/syndicate/alt
	icon_state = "syndie_headset"
	item_state = "syndie_headset"

/obj/item/device/radio/headset/binary
	origin_tech = "syndicate=3"
	ks1type = /obj/item/device/encryptionkey/binary

/obj/item/device/radio/headset/headset_sec
	ks2type = /obj/item/device/encryptionkey/headset_sec

/obj/item/device/radio/headset/headset_sec/alt
	icon_state = "sec_headset_alt"

/obj/item/device/radio/headset/headset_sec/nt_pmc
	name = "NT PMC Radio Headset."
	icon_state = "nt_pmc_earset"

/obj/item/device/radio/headset/headset_sec/marinad
	name = "marine headset"
	icon_state = "marinad"
	item_state = "headset"
	desc = "Buzzz.... That's nine-nine charlie, requesting backup. Buzzz.... To access the security channel, use :s."

/obj/item/device/radio/headset/headset_int
	ks2type = /obj/item/device/encryptionkey/headset_int

/obj/item/device/radio/headset/headset_int/blueshield

/obj/item/device/radio/headset/headset_eng
	ks2type = /obj/item/device/encryptionkey/headset_eng

/obj/item/device/radio/headset/headset_rob
	ks2type = /obj/item/device/encryptionkey/headset_rob

/obj/item/device/radio/headset/headset_med
	ks2type = /obj/item/device/encryptionkey/headset_med

/obj/item/device/radio/headset/headset_sci
	ks2type = /obj/item/device/encryptionkey/headset_sci

/obj/item/device/radio/headset/headset_medsci
	ks2type = /obj/item/device/encryptionkey/headset_medsci

/obj/item/device/radio/headset/headset_com
	ks2type = /obj/item/device/encryptionkey/headset_com

/obj/item/device/radio/headset/heads/captain
	ks2type = /obj/item/device/encryptionkey/heads/captain
	grid = TRUE

/obj/item/device/radio/headset/heads/ai_integrated //No need to care about icons, it should be hidden inside the AI anyway.
	name = "AI Subspace Transceiver"
	desc = "Integrated AI radio transceiver."
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "radio"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/ai_integrated
	var/myAi = null    // Atlantis: Reference back to the AI which has this radio.
	var/disabledAi = 0 // Atlantis: Used to manually disable AI's integrated radio via intellicard menu.

/obj/item/device/radio/headset/heads/ai_integrated/receive_range(freq, level)
	if (disabledAi)
		return -1 //Transciever Disabled.
	return ..(freq, level, 1)

/obj/item/device/radio/headset/heads/ai_integrated/emp_act()
	return

/obj/item/device/radio/headset/heads/rd
	ks2type = /obj/item/device/encryptionkey/heads/rd
	grid = TRUE

/obj/item/device/radio/headset/heads/hos
	ks2type = /obj/item/device/encryptionkey/heads/hos

/obj/item/device/radio/headset/heads/ce
	ks2type = /obj/item/device/encryptionkey/heads/ce
	grid = TRUE

/obj/item/device/radio/headset/heads/cmo
	ks2type = /obj/item/device/encryptionkey/heads/cmo

/obj/item/device/radio/headset/heads/hop
	ks2type = /obj/item/device/encryptionkey/heads/hop
/*
/obj/item/device/radio/headset/headset_mine
	name = "mining radio headset"
	desc = "Headset used by miners. How useless. To access the mining channel, use :d."
	icon_state = "mine_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/headset_mine

/obj/item/device/radio/headset/heads/qm
	name = "quartermaster's headset"
	desc = "The headset of the man who control your toiletpaper supply. To access the cargo channel, use :q. For mining, use :d."
	icon_state = "cargo_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/qm
*/
/obj/item/device/radio/headset/headset_cargo
	ks2type = /obj/item/device/encryptionkey/headset_cargo

/obj/item/device/radio/headset/ert
	name = "CentCom Response Team headset"
	desc = "The headset of the boss's boss. Channels are as follows: :h - Response Team :c - command, :s - security, :e - engineering, :u - supply, :m - medical, :n - science."
	icon_state = "com_headset"
	item_state = "headset"
	freerange = 1
	ks2type = /obj/item/device/encryptionkey/ert
	grid = TRUE

/obj/item/device/radio/headset/deathsquad
	grid = TRUE

/obj/item/device/radio/headset/deathsquad/atom_init()
	. = ..()
	set_frequency(1341)

/obj/item/device/radio/headset/velocity
	name = "velocity crew headset"
	desc = "The headset, if you wish to talk to your fellow crew-nies. ; - Velocity crew channel."
	icon_state = "vel_headset"
	item_state = "headset"
	maxf = 1341

/obj/item/device/radio/headset/velocity/atom_init()
	. = ..()
	set_frequency(1245)

/obj/item/device/radio/headset/velocity/chief
	ks2type = /obj/item/device/encryptionkey/headset_cargo

/obj/item/device/radio/headset/team_red
	name = "Team Red headset"
	icon_state = "com_headset"
	item_state = "headset"
	subspace_transmission = FALSE
	allow_settings = FALSE
	freerange = TRUE

/obj/item/device/radio/headset/team_red/atom_init()
	. = ..()
	set_frequency(FREQ_TEAM_RED)

/obj/item/device/radio/headset/team_blue
	name = "Team Red headset"
	icon_state = "com_headset"
	item_state = "headset"
	subspace_transmission = FALSE
	allow_settings = FALSE
	freerange = TRUE

/obj/item/device/radio/headset/team_blue/atom_init()
	. = ..()
	set_frequency(FREQ_TEAM_BLUE)
