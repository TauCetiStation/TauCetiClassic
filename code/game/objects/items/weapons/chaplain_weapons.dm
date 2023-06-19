////////////////
//  NULLRODS  //
////////////////
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
	w_class = SIZE_TINY

	// Deconvering mobs
	var/deconverting = FALSE

	// Glowing
	var/last_process = 0
	var/static/list/scum

	// Change type of nullrod
	var/tried_replacing = FALSE

	// Deconverting turfs
	var/deconvert_turf_cd = 5 SECONDS
	var/next_turf_deconvert = 0

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message("<span class='userdanger'>[user] is impaling himself with the [name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/nullrod/atom_init()
	. = ..()
	if(!scum)
		scum = typecacheof(list(/mob/living/simple_animal/construct, /obj/structure/cult, /obj/effect/rune, /mob/dead/observer))

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
	if(user.mind && user.mind.holy_role >= HOLY_ROLE_HIGHPRIEST)
		START_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/nullrod/Destroy()
	STOP_PROCESSING(SSobj, src)
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
		if(ismob(A))
			var/mob/M = A
			if(iscultist(M))
				set_light(3)
				addtimer(CALLBACK(src, .atom/proc/set_light, 0), 20)
		if(is_type_in_typecache(A, scum))
			set_light(3)
			addtimer(CALLBACK(src, .atom/proc/set_light, 0), 20)

/obj/item/weapon/nullrod/proc/convert_effect(turf/T, turf_type)
	new /obj/effect/temp_visual/religion/pulse(T)
	sleep(8)
	T.ChangeTurf(turf_type)

/obj/item/weapon/nullrod/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || !user.my_religion || !global.cult_religion || !isturf(target) || next_turf_deconvert > world.time)
		return

	if(iscultist(user))
		to_chat(user, "<span class='danger'>Жезл выскальзывает из руки и ударяет вас об голову.</span>")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.adjustBruteLoss(10)
			H.Paralyse(20)
		return

	// Captured area is too strong
	var/area/A = get_area(target)
	if(A.religion && istype(A.religion, global.cult_religion.type))
		to_chat(user, "<span class='danger'>Вам не хватает силы для этого!</span>")
		return

	// If it's not a cult type, then don't do it.
	var/turf/T = target
	if(T.type in global.cult_religion.wall_types)
		INVOKE_ASYNC(src, PROC_REF(convert_effect), T, /turf/simulated/wall)
	else if(T.type in global.cult_religion.floor_types)
		INVOKE_ASYNC(src, PROC_REF(convert_effect), T, /turf/simulated/floor)

	next_turf_deconvert = world.time + deconvert_turf_cd

/obj/item/weapon/nullrod/attack(mob/living/M, mob/living/user) //Paste from old-code to decult with a null rod.
	if(user.ClumsyProbabilityCheck(50))
		to_chat(user, "<span class='danger'>Жезл выскальзывает из руки и ударяет вас об голову.</span>")
		user.adjustBruteLoss(10)
		user.Paralyse(20)
		return

	if(user.mind?.holy_role < HOLY_ROLE_HIGHPRIEST || deconverting)
		return

	user.visible_message("<span class='danger'>[user] waves [src] over [M]'s head.</span>")

	deconverting = TRUE
	if(!do_after(user, 50, target = M))
		deconverting = FALSE
		return
	deconverting = FALSE

	M.log_combat(user, "deconvered (attempt) via [name]")

	if(M.stat != DEAD)
		if(iscultist(M))
			if(iscultist(user))
				to_chat(user, "<span class='danger'>Жезл выскальзывает из руки и ударяет вас об голову.</span>")
				user.adjustBruteLoss(10)
				user.Paralyse(20)
				return
			to_chat(M, "<span class='danger'>Сила жезла очищает твой разум от влияния древних богов!</span>")

			var/datum/role/cultist/C = M.mind.GetRole(CULTIST)
			C.Deconvert()
			M.Paralyse(5)
			to_chat(M, "<span class='danger'><FONT size = 3>Незнакомый белый свет очищает твой разум от порчи и воспоминаний, когда ты был Его слугой.</span></FONT>")
			M.mind.memory = ""
			M.visible_message("<span class='danger'><FONT size = 3>[M]'s head and see their eyes become clear, their mind returning to normal!</span></FONT>")

			new /obj/effect/temp_visual/religion/pulse(M.loc)
			M.visible_message("<span class='danger'>[user] spews strength [src] into [M].</span>")
		else
			to_chat(user, "<span class='danger'>Жезл наказывает вас за ложное использование.</span>")
			new /obj/effect/temp_visual/religion/pulse(user.loc)
			user.apply_damage(50, BURN, null, used_weapon="Electrocution")
			user.visible_message("<span class='danger'>[src] spews his power [user].</span>")
			M.AdjustConfused(10)

/obj/item/weapon/nullrod/staff
	name = "divine staff"
	desc = "A mystical and frightening staff with ancient magic. Only one chaplain remembers how to use it."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "talking_staff"
	item_state = "talking_staff"
	w_class = SIZE_SMALL
	req_access = list(access_chapel_office)

	var/mob/living/simple_animal/shade/god/brainmob = null
	var/searching = FALSE
	var/next_ping = 0

	var/image/god_image

	var/list/next_apply = list()

/obj/item/weapon/nullrod/staff/Destroy()
	if((slot_equipped == SLOT_L_HAND || slot_equipped == SLOT_R_HAND) && ismob(loc))
		var/mob/M = loc
		hide_god(M)

	QDEL_NULL(god_image)

	if(brainmob)
		brainmob.container = null
		brainmob.gib()
		brainmob = null

	return ..()

/obj/item/weapon/nullrod/staff/proc/show_god(mob/M)
	if(god_image)
		add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "god_staff", god_image, M)

/obj/item/weapon/nullrod/staff/proc/hide_god(mob/M)
	if(god_image)
		brainmob.remove_alt_appearance("god_staff")

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
	if(user.mind && user.mind.holy_role >= HOLY_ROLE_HIGHPRIEST && brainmob)
		if(istype(I, /obj/item/device/soulstone))
			if(iscultist(user))
				to_chat(user, "<span class ='warning'>You can't use weapon of [brainmob.name] against him!</span>")
				return

			var/obj/item/device/soulstone/S = I
			if(!S.imprinted)
				S.imprinted = brainmob.name
				S.transfer_soul(SOULSTONE_SHADE, brainmob, user)

		else if(istype(I, /obj/item/weapon/storage/bible)) //force kick god from staff
			if(brainmob)
				next_apply[brainmob.ckey] = world.time + 10 MINUTES
				brainmob.ghostize(FALSE)
				qdel(brainmob)
				searching = FALSE
				icon_state = "talking_staff"
				visible_message("<span class='notice'>The energy of \the [src] was dispelled.</span>")

	else
		return ..()

/obj/item/weapon/nullrod/staff/attack_self(mob/living/carbon/human/user)
	if(user.mind && user.mind.holy_role >= HOLY_ROLE_HIGHPRIEST)
		if(user.my_religion.aspects.len == 0)
			to_chat(user, "<span class ='warning'>First choose aspects in your religion!</span>")
			return
		if(!brainmob && !searching)
			//Start the process of searching for a new user.
			to_chat(user, "<span class='notice'>You attempt to wake the spirit of the staff...</span>")
			icon_state = "talking_staffanim"
			light_power = 5
			searching = TRUE
			request_player(user)
			addtimer(CALLBACK(src, PROC_REF(reset_search)), 200)

/obj/item/weapon/nullrod/staff/proc/request_player(mob/living/user)
	var/list/candidates = pollGhostCandidates("Do you want to serve [user.my_religion.name] in divine staff?", ROLE_GHOSTLY, IGNORE_TSTAFF, 100, TRUE)
	for(var/mob/M in candidates) // No random
		if(next_apply[M.client.ckey] > world.time)
			to_chat(M, "You were forcibly kicked from staff, left [round((next_apply[M.client.ckey] - world.time) / 600)] minutes")
			continue
		transfer_personality(M, user)
		break

/obj/item/weapon/nullrod/staff/proc/transfer_personality(mob/candidate, mob/living/summoner)
	searching = FALSE

	if(brainmob)
		to_chat(brainmob, "<span class='userdanger'>You are no longer our god!</span>")
		brainmob.ghostize(FALSE)
		qdel(brainmob) //create new god, otherwise the old mob could not be woken up

	QDEL_NULL(god_image)

	// All of this could be made religion-dependant.
	brainmob = new(get_turf(src))
	brainmob.mutations.Add(XRAY) //its the god
	brainmob.add_status_flags(GODMODE)

	var/god_name = pick(summoner.my_religion.deity_names)
	var/god_lore = summoner.my_religion.lore

	brainmob.ckey = candidate.ckey
	brainmob.name = "[god_name] [pick("II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX")]"
	brainmob.mind.assigned_role = "Chaplain`s staff"
	if(god_lore != "")
		brainmob.mind.memory = "<B>YOUR LORE</B><BR>"
		brainmob.mind.memory += god_lore

	for(var/aspect in summoner.my_religion.aspects)
		var/datum/aspect/asp = summoner.my_religion.aspects[aspect]
		if(asp.god_desc)
			brainmob.mind.memory += "<BR><BR><B>Aspect [aspect]</B>:<BR>[asp.god_desc]"

	candidate.cancel_camera()
	candidate.reset_view()

	summoner.my_religion.add_deity(brainmob)

	for(var/datum/language/L as anything in summoner.languages)
		brainmob.add_language(L.name)

	name = "staff of the [god_name]"
	if(god_name == "Aghanim") //sprite is very similar
		name = "Aghanim's Scepter"

	brainmob.real_name = name

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

	god_image = image(brainmob.icon, brainmob, brainmob.icon_state)

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
		brainmob.ghostize(FALSE)
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

	w_class = SIZE_NORMAL
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
	..()
	if(slot == SLOT_L_HAND || slot == SLOT_R_HAND || slot == SLOT_BACK)
		activate(user)
	else if(slot_equipped == SLOT_L_HAND || slot_equipped == SLOT_R_HAND || slot_equipped == SLOT_BACK)
		deactivate(user)

/obj/item/weapon/nullrod/forcefield_staff/dropped(mob/living/user)
	..()
	if(slot_equipped == SLOT_L_HAND || slot_equipped == SLOT_R_HAND || slot_equipped == SLOT_BACK)
		deactivate(user)


///////////////
// EQUIPMENT //
///////////////
/obj/item/weapon/shield/riot/roman/religion
	name = "sacred shield"
	desc = "Go-... Whatever deity you worship protects you!"
	flags = ABSTRACT|DROPDEL
	slot_flags = FALSE

	alpha = 200

/obj/item/weapon/shield/riot/roman/religion/atom_init()
	. = ..()
	add_filter("shield_outline", 2, outline_filter(1, "#fffb0064"))
	animate(filters[filters.len], color = "#fffb0000", time = 1 MINUTE)

	QDEL_IN(src, 1 MINUTE)

/obj/item/weapon/claymore/religion
	name = "claymore"
	desc = "Good weapon for the crusade."
	force = 10
	throwforce = 5

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
	addtimer(CALLBACK(src, PROC_REF(revert_effect)), 5 SECONDS)

	var/shield_type = /obj/item/weapon/shield/riot/roman/religion
	AddComponent(/datum/component/self_effect, shield_type, "#fffb0064", CALLBACK(src, PROC_REF(only_holy)), 3 MINUTE, 30 SECONDS, 1 MINUTE)

/obj/item/weapon/claymore/religion/proc/only_holy(datum/source, mob/M)
	if(M?.mind?.holy_role)
		return TRUE
	return FALSE

/obj/item/weapon/claymore/religion/dropped()
	..()
	force = def_force + blessed

/obj/item/weapon/claymore/religion/equipped(mob/user, slot)
	..()
	if(user.mind?.holy_role)
		force = holy_force + blessed
	else
		force = def_force + blessed

/obj/item/weapon/claymore/religion/proc/revert_effect()
	if(down_overlay)
		cut_overlays(down_overlay)
		down_overlay = null
