/obj/item/weapon/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/uses = 4.0
	w_class = SIZE_TINY
	item_state = "paper"
	throw_speed = 4
	throw_range = 20
	origin_tech = "bluespace=4"

	item_action_types = list(/datum/action/item_action/hands_free/use_scroll)

/datum/action/item_action/hands_free/use_scroll
	name = "Use Scroll of Teleportation"

/obj/item/weapon/teleportation_scroll/attack_self(mob/user)
	user.set_machine(src)
	var/dat = ""
	dat += "Number of uses: [src.uses]<BR>"
	dat += "<HR>"
	dat += "<B>Four uses use them wisely:</B><BR>"
	dat += "<A href='byond://?src=\ref[src];spell_teleport=1'>Teleport</A><BR>"
	dat += "Kind regards,<br>Wizards Federation<br><br>P.S. Don't forget to bring your gear, you'll need it to cast most spells.<HR>"

	var/datum/browser/popup = new(user, "scroll", "Teleportation Scroll:", ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()
	return

/obj/item/weapon/teleportation_scroll/Topic(href, href_list)
	..()
	if (usr.incapacitated() || src.loc != usr)
		return
	var/mob/living/carbon/human/H = usr
	if (!( ishuman(H)))
		return 1
	if (Adjacent(usr))
		usr.set_machine(src)
		if (href_list["spell_teleport"])
			if (src.uses >= 1)
				teleportscroll(H)
	attack_self(H)
	return

/obj/item/weapon/teleportation_scroll/proc/teleportscroll(mob/user)

	var/A

	A = tgui_input_list(user, "Area to jump to", "BOOYEA", teleportlocs)
	if(!A)
		return
	var/area/thearea = teleportlocs[A]

	if (user.incapacitated())
		return
	if(!Adjacent(user))
		return

	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(5, 0, user.loc)
	smoke.attach(user)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density && !SEND_SIGNAL(T, COMSIG_ATOM_INTERCEPT_TELEPORT))
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L.len)
		to_chat(user, "The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
		return

	if(user && user.buckled)
		user.buckled.unbuckle_mob()

	var/list/tempL = L
	var/attempt = null
	var/success = 0
	while(tempL.len)
		attempt = pick(tempL)
		success = user.Move(attempt)
		if(!success)
			tempL.Remove(attempt)
		else
			break

	if(!success)
		user.loc = pick(L)

	smoke.start()
	src.uses -= 1
