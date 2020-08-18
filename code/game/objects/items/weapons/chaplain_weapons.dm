/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of paranormal phenomenae."
	icon_state = "nullrod"
	item_state = "nullrod"
	slot_flags = SLOT_FLAGS_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	light_color = "#4c4cff"
	light_power = 3
	w_class = ITEM_SIZE_SMALL
	var/last_process = 0
	var/datum/cult/reveal/power
	var/static/list/scum

	var/tried_replacing = FALSE

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message("<span class='userdanger'>[user] is impaling himself with the [name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/nullrod/atom_init()
	. = ..()
	if(!scum)
		scum = typecacheof(list(/mob/living/simple_animal/construct, /obj/structure/cult, /obj/effect/rune, /mob/dead/observer))
	power = new(src)

/obj/item/weapon/nullrod/attack_self(mob/living/user)
	if(user.mind && user.mind.holy_role && !tried_replacing)
		if(!global.chaplain_religion)
			to_chat(user, "<span class='warning'>The stars are not in position for this tribute. Await round start.</span>")
			return

		var/list/choices = list()
		var/list/nullrod_list = list()
		for(var/null_type in typesof(/obj/item/weapon/nullrod))
			var/obj/item/weapon/nullrod/N = null_type
			choices[initial(N.name)] = N
			nullrod_list[initial(N.name)] = image(icon = initial(N.icon), icon_state = initial(N.icon_state))

		var/choice = show_radial_menu(user, src, nullrod_list, require_near = TRUE, tooltips = TRUE)

		if(choice && Adjacent(user))
			qdel(src)
			var/chosen_type = choices[choice]
			var/obj/item/weapon/nullrod/new_rod = new chosen_type(user.loc)
			new_rod.tried_replacing = TRUE
			user.put_in_hands(new_rod)
		return

	return ..()

/obj/item/weapon/nullrod/equipped(mob/user, slot)
	if(user.mind && user.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
		START_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/nullrod/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(power)
	return ..()

/obj/item/weapon/nullrod/dropped(mob/user)
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/nullrod/process()
	if(last_process + 60 >= world.time)
		return
	last_process = world.time
	var/turf/turf = get_turf(loc)
	for(var/A in range(6, turf))
		if(iscultist(A) || is_type_in_typecache(A, scum))
			set_light(3)
			addtimer(CALLBACK(src, .atom/proc/set_light, 0), 20)

/obj/item/weapon/nullrod/attack(mob/living/M, mob/living/user) //Paste from old-code to decult with a null rod.
	if (!(ishuman(user) || SSticker) && SSticker.mode.name != "monkey")
		to_chat(user, "<span class='danger'> You don't have the dexterity to do this!</span>")
		return

	M.log_combat(user, "deconvered (attempt) via [name]")

	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='danger'>The rod slips out of your hand and hits your head.</span>")
		user.adjustBruteLoss(10)
		user.Paralyse(20)
		return

	if (M.stat != DEAD)
		if((M.mind in SSticker.mode.cult) && user.mind && user.mind.holy_role == HOLY_ROLE_HIGHPRIEST && prob(33))
			to_chat(M, "<span class='danger'>The power of [src] clears your mind of the cult's influence!</span>")
			to_chat(user, "<span class='danger'>You wave [src] over [M]'s head and see their eyes become clear, their mind returning to normal.</span>")
			SSticker.mode.remove_cultist(M.mind)
		else
			to_chat(user, "<span class='danger'>The rod appears to do nothing.</span>")
		M.visible_message("<span class='danger'>[user] waves [src] over [M.name]'s head</span>")

/obj/item/weapon/nullrod/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (proximity_flag && istype(target, /turf/simulated/floor) && user.mind && user.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
		to_chat(user, "<span class='notice'>You hit the floor with the [src].</span>")
		power.action(user, 1)

/obj/item/weapon/nullrod/staff
	name = "divine staff"
	desc = "A mystical and frightening staff with ancient magic. Only one chaplain remembers how to use it."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "talking_staff"
	item_state = "talking_staff"
	w_class = ITEM_SIZE_NORMAL
	req_access = list(access_chapel_office)

	var/god_name = "Space-Jesus"
	var/god_lore = ""
	var/mob/living/simple_animal/shade/god/brainmob = null
	var/searching = FALSE
	var/next_ping = 0

	var/image/god_image

	var/list/next_apply = list()

/obj/item/weapon/nullrod/staff/atom_init()
	. = ..()
	god_name = pick(global.chaplain_religion.deity_names)
	god_lore = global.chaplain_religion.lore

/obj/item/weapon/nullrod/staff/Destroy()
	// Damn... He's free now.
	if(brainmob)
		brainmob.invisibility = 0
		qdel(brainmob.GetComponent(/datum/component/bounded))
		brainmob.container = null
		brainmob = null

	if((slot_equipped == SLOT_L_HAND || slot_equipped == SLOT_R_HAND) && ismob(loc))
		var/mob/M = loc
		hide_god(M)

	QDEL_NULL(god_image)

	return ..()

/obj/item/weapon/nullrod/staff/proc/show_god(mob/M)
	if(M.client && god_image)
		M.client.images += god_image

/obj/item/weapon/nullrod/staff/proc/hide_god(mob/M)
	if(M.client && god_image)
		M.client.images -= god_image

/obj/item/weapon/nullrod/staff/equipped(mob/user, slot)
	..()
	if(slot != SLOT_L_HAND && slot != SLOT_R_HAND)
		hide_god(user)
	else
		show_god(user)

/obj/item/weapon/nullrod/staff/dropped(mob/user)
	..()
	if(user)
		hide_god(user)

/obj/item/weapon/nullrod/staff/attackby(obj/item/I, mob/user, params)
	if(user.mind && user.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
		if(istype(I, /obj/item/device/soulstone)) //mb, the only way to pull out god
			var/obj/item/device/soulstone/S = I
			if(S.imprinted == "empty")
				S.imprinted = brainmob.name
				S.transfer_soul("SHADE", brainmob, user)

		else if(istype(I, /obj/item/weapon/storage/bible)) //force kick god from staff
			if(brainmob)
				next_apply[brainmob.ckey] = world.time + 10 MINUTES
				qdel(brainmob)
				searching = FALSE
				icon_state = "talking_staff"
				visible_message("<span class='notice'>The energy of \the [src] was dispelled.</span>")

	else
		return ..()

/obj/item/weapon/nullrod/staff/attack_self(mob/living/carbon/human/user)
	if(user.mind && user.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
		if(global.chaplain_religion.aspects.len == 0)
			to_chat(user, "<span class ='warning'>First choose aspects in your religion!</span>")
			return
		if(!brainmob && !searching)
			//Start the process of searching for a new user.
			to_chat(user, "<span class='notice'>You attempt to wake the spirit of the staff...</span>")
			icon_state = "talking_staffanim"
			light_power = 5
			searching = TRUE
			request_player(user)
			addtimer(CALLBACK(src, .proc/reset_search), 600)

/obj/item/weapon/nullrod/staff/proc/request_player(mob/living/user)
	for(var/mob/dead/observer/O in player_list)
		if(O.has_enabled_antagHUD == TRUE && config.antag_hud_restricted)
			continue
		if(jobban_isbanned(O, ROLE_GHOSTLY) && role_available_in_minutes(O, ROLE_GHOSTLY))
			continue
		if(O.client)
			var/client/C = O.client
			if(!C.prefs.ignore_question.Find(IGNORE_TSTAFF) && (ROLE_GHOSTLY in C.prefs.be_role))
				INVOKE_ASYNC(src, .proc/question, C, user)

/obj/item/weapon/nullrod/staff/proc/question(client/C, mob/living/user)
	if(!C)
		return
	var/response = alert(C, "Someone is requesting a your soul in divine staff?", "Staff request", "No", "Yeeesss", "Never for this round")
	if(!C || (brainmob && brainmob.ckey) || !searching)
		return		//handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
	if(response == "Yeeesss")
		if(next_apply[C.ckey] > world.time)
			to_chat(C.mob, "You were forcibly kicked from staff, left [round((next_apply[C.ckey] - world.time) / 600)] minutes")
			return
		transfer_personality(C.mob, user)
	else if (response == "Never for this round")
		C.prefs.ignore_question += IGNORE_TSTAFF

/obj/item/weapon/nullrod/staff/proc/transfer_personality(mob/candidate, mob/living/summoner)
	searching = FALSE

	if(brainmob)
		to_chat(brainmob, "<span class='userdanger'>You are no longer our god!</span>")
		qdel(brainmob) //create new god, otherwise the old mob could not be woken up

	QDEL_NULL(god_image)

	// All of this could be made religion-dependant.
	brainmob = new(get_turf(src))
	brainmob.mutations.Add(XRAY) //its the god
	brainmob.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
	brainmob.status_flags |= GODMODE

	brainmob.invisibility = INVISIBILITY_OBSERVER
	brainmob.see_invisible = SEE_INVISIBLE_OBSERVER

	brainmob.mind = candidate.mind
	brainmob.ckey = candidate.ckey
	brainmob.name = "[god_name] [pick("II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX")]"
	brainmob.real_name = name
	brainmob.mind.assigned_role = "Chaplain`s staff"
	if(god_lore != "")
		brainmob.mind.memory = "<B>YOUR LORE</B><BR>"
		brainmob.mind.memory += god_lore
	brainmob.mind.holy_role = HOLY_ROLE_HIGHPRIEST

	for(var/aspect in global.chaplain_religion.aspects)
		var/datum/aspect/asp = global.chaplain_religion.aspects[aspect]
		if(asp.god_desc)
			brainmob.mind.memory += "<BR><BR><B>Aspect [aspect]</B><BR>[asp.god_desc]"

	candidate.cancel_camera()
	candidate.reset_view()

	brainmob.universal_speak = FALSE

	global.chaplain_religion.add_deity(brainmob)

	for(var/datum/language/L in summoner.languages)
		brainmob.add_language(L.name)

	name = "staff of the [god_name]"
	if(god_name == "Aghanim") //sprite is very similar
		name = "Aghanim's Scepter"

	desc = "Stone sometimes glow. Pray for mercy on [god_name]."
	to_chat(brainmob, "<b>You are an avatar of god, brought into existence on [station_name()].</b>")
	to_chat(brainmob, "<b>[capitalize(summoner.name)], the priest has called you, you can command them, because you are their god.</b>")
	to_chat(brainmob, "<b>All that is required of you is a creative image of god impriosioned in the staff.</b>")
	if(god_lore == "")
		to_chat(brainmob, "<b>You can be both evil Satan thirsting and ordering sacrifices, and a good Jesus who wants more slaves.</b>")
	else
		to_chat(brainmob, "<b>Check your lore in the notes.</b>")
	to_chat(brainmob, "<span class='userdanger'><font size =3><b>You do not know everything that happens and happened in the round!</b></font></span>")

	icon_state = "talking_staffsoul"

	var/image/I = image(brainmob.icon, brainmob.icon_state)
	I.loc = brainmob
	I.appearance = brainmob
	god_image = I

	brainmob.container = src
	brainmob.AddComponent(/datum/component/bounded, src, 0, 3)

	if((slot_equipped == SLOT_L_HAND || slot_equipped == SLOT_R_HAND) && ismob(loc))
		var/mob/M = loc
		show_god(M)

/obj/item/weapon/nullrod/staff/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.
	if(brainmob && brainmob.ckey)
		return

	searching = FALSE
	icon_state = "talking_staff"
	visible_message("<span class='notice'>The stone of \the [src] stopped glowing, why didn't you please the god?</span>")
	if(brainmob)
		qdel(brainmob)

/obj/item/weapon/nullrod/staff/examine(mob/user)
	..()
	var/msg = ""
	if(brainmob && brainmob.ckey)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!brainmob.client)
					msg += "<span class='warning'>Divine presence is weakened.</span>\n" //afk
			if(UNCONSCIOUS)
				msg += "<span class='warning'>Divine presence is not tangible.</span>\n"
			if(DEAD)
				msg += "<span class='deadsay'>Divine presence faded.</span>\n"
		if(msg)
			to_chat(user, msg)

/obj/item/weapon/nullrod/staff/attack_ghost(mob/dead/observer/O)
	if(next_ping > world.time)
		return

	next_ping = world.time + 5 SECONDS
	audible_message("<span class='notice'>\The [src] stone blinked.</span>", deaf_message = "\The [src] stone blinked.")



/obj/item/weapon/nullrod/forcefield_staff
	name = "forcefield staff"
	desc = "Makes the wielder believe that they are protected by something, anything, really. Probably works on AA batteries."

	w_class = ITEM_SIZE_LARGE
	slot_flags = SLOT_FLAGS_BACK

	icon_state = "godstaff"
	item_state = "godstaff"

	var/is_active = FALSE

/obj/item/weapon/nullrod/forcefield_staff/atom_init()
	. = ..()

	var/obj/effect/effect/forcefield/F = new
	AddComponent(/datum/component/forcefield, "forcefield", 20, 5 SECONDS, 3 SECONDS, F)

/obj/item/weapon/nullrod/forcefield_staff/proc/activate(mob/living/user)
	if(is_active)
		return
	is_active = TRUE

	SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, user)

/obj/item/weapon/nullrod/forcefield_staff/proc/deactivate(mob/living/user)
	is_active = FALSE

	SEND_SIGNAL(src, COMSIG_FORCEFIELD_UNPROTECT, user)

/obj/item/weapon/nullrod/forcefield_staff/equipped(mob/living/user, slot)
	if(slot == SLOT_L_HAND || slot == SLOT_R_HAND || slot == SLOT_BACK)
		activate(user)
	else if(slot_equipped == SLOT_L_HAND || slot_equipped == SLOT_R_HAND || slot_equipped == SLOT_BACK)
		deactivate(user)

/obj/item/weapon/nullrod/forcefield_staff/dropped(mob/living/user)
	if(slot_equipped == SLOT_L_HAND || slot_equipped == SLOT_R_HAND || slot_equipped == SLOT_BACK)
		deactivate(user)



/obj/item/weapon/shield/riot/roman/religion
	name = "sacred shield"
	desc = "Go-... Whatever deity you worship protects you!"
	flags = ABSTRACT|DROPDEL
	slot_flags = FALSE

	alpha = 200

/obj/item/weapon/shield/riot/roman/religion/atom_init()
	. = ..()

	filters += filter(type = "outline", size = 1, color = "#fffb0064")
	animate(filters[filters.len], color = "#fffb0000", time = 1 MINUTE)

	QDEL_IN(src, 1 MINUTE)

/obj/item/weapon/claymore/religion
	name = "claymore"
	desc = "Good weapon for the crusade."
	force = 10
	throwforce = 5

	var/can_spawn_shield = TRUE
	var/obj/item/weapon/shield/riot/roman/religion/shield

	var/holy_outline
	var/have_outline = FALSE
	var/can_spawn_shield_timer
	var/image/down_overlay

	/// Force for holy wielders.
	var/holy_force = 10
	/// Force for non-holy wielders.
	var/def_force = 5

/obj/item/weapon/claymore/religion/atom_init()
	. = ..()
	down_overlay = image('icons/effects/effects.dmi', icon_state = "at_shield2", layer = OBJ_LAYER - 0.01)
	down_overlay.alpha = 100
	add_overlay(down_overlay)
	addtimer(CALLBACK(src, .proc/revert_effect), 5 SECONDS)

	holy_outline = filter(type = "outline", size = 1, color = "#fffb0064")

/obj/item/weapon/claymore/religion/Destroy()
	if(can_spawn_shield_timer)
		deltimer(can_spawn_shield_timer)
	return ..()

/obj/item/weapon/claymore/religion/dropped()
	QDEL_NULL(shield)
	remove_holy_outline()
	force = def_force

/obj/item/weapon/claymore/religion/equipped(mob/user, slot)
	if(user.mind.holy_role)
		force = holy_force
		if(!have_outline && can_spawn_shield)
			create_holy_outline()
	else
		force = def_force

/obj/item/weapon/claymore/religion/proc/remove_holy_outline()
	have_outline = FALSE
	filters -= holy_outline

/obj/item/weapon/claymore/religion/proc/create_holy_outline()
	have_outline = TRUE
	filters += holy_outline

/obj/item/weapon/claymore/religion/proc/revert_effect()
	if(down_overlay)
		cut_overlays(down_overlay)
		qdel(down_overlay)

/obj/item/weapon/claymore/religion/proc/ready_shield()
	can_spawn_shield = TRUE
	if(!have_outline && (slot_equipped == SLOT_L_HAND || slot_equipped == SLOT_R_HAND))
		create_holy_outline()

/obj/item/weapon/claymore/religion/proc/scatter_shield()
	if(slot_equipped == SLOT_L_HAND || slot_equipped == SLOT_R_HAND)
		var/mob/M = loc
		to_chat(M, "<span class='warning'>[shield] was scattered.</span>")

	shield = null
	can_spawn_shield_timer = addtimer(CALLBACK(src, .proc/ready_shield), 30 SECONDS)

/obj/item/weapon/claymore/religion/attack_self(mob/living/carbon/human/H)
	if(!H.mind.holy_role || !can_spawn_shield)
		return

	var/obj/item/weapon/shield/riot/roman/religion/R = new (H)
	if(H.put_in_inactive_hand(R))
		can_spawn_shield = FALSE
		can_spawn_shield_timer = addtimer(CALLBACK(src, .proc/ready_shield, H), 3 MINUTES)
		shield = R
		RegisterSignal(R, list(COMSIG_PARENT_QDELETED), .proc/scatter_shield)
		remove_holy_outline()
	else
		qdel(R)
