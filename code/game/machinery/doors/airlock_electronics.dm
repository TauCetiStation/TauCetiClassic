/obj/item/weapon/airlock_electronics
	name = "airlock electronics"
	icon = 'icons/obj/doors/door_electronics.dmi'
	icon_state = "door_electronics"
	w_class = SIZE_TINY //It should be tiny! -Agouri
	m_amt = 50
	g_amt = 50

	req_access = list(access_engine)

	var/list/conf_access = list()
	var/one_access = 0 //if set to 1, door would receive req_one_access instead of req_access
	var/last_configurator = null
	var/locked = 1
	var/broken = FALSE

/obj/item/weapon/airlock_electronics/attack_self(mob/user)
	if (!ishuman(user) && !isrobot(user))
		return ..(user)

	var/mob/living/carbon/human/H = user
	if(H.getBrainLoss() >= 60)
		return

	var/t1 = ""


	if (last_configurator)
		t1 += "Operator: [last_configurator]<br>"

	if (locked)
		t1 += "<a href='?src=\ref[src];login=1'>Swipe ID</a><hr>"
	else
		t1 += "<a href='?src=\ref[src];logout=1'>Block</a><hr>"

		t1 += "Access requirement is set to "
		t1 += one_access ? "<a class='green' href='?src=\ref[src];one_access=1'>ONE</a><hr>" : "<a class='red' href='?src=\ref[src];one_access=1'>ALL</a><hr>"

		t1 += conf_access == null ? "<span class='red'>All</span><br>" : "<a href='?src=\ref[src];access=all'>All</a><br>"

		t1 += "<br>"

		var/list/accesses = get_all_accesses()
		for (var/acc in accesses)
			var/aname = get_access_desc(acc)

			if (!conf_access || !conf_access.len || !(acc in conf_access))
				t1 += "<a href='?src=\ref[src];access=[acc]'>[aname]</a><br>"
			else if(one_access)
				t1 += "<a class='green' href='?src=\ref[src];access=[acc]'>[aname]</a><br>"
			else
				t1 += "<a class='red' href='?src=\ref[src];access=[acc]'>[aname]</a><br>"

	var/datum/browser/popup = new(user, "airlock_electronics", "Access control")
	popup.set_content(t1)
	popup.open()

/obj/item/weapon/airlock_electronics/Topic(href, href_list)
	..()
	if (usr.incapacitated() || (!ishuman(usr) && !issilicon(usr)))
		return
	if (href_list["login"])
		if(issilicon(usr))
			src.locked = 0
			src.last_configurator = usr.name
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && check_access(I))
				src.locked = 0
				src.last_configurator = I:registered_name

	if (locked)
		return

	if (href_list["logout"])
		locked = 1

	if (href_list["one_access"])
		one_access = !one_access

	if (href_list["access"])
		toggle_access(href_list["access"])

	attack_self(usr)

/obj/item/weapon/airlock_electronics/proc/toggle_access(acc)
	if (acc == "all")
		conf_access = list()
	else
		var/req = text2num(acc)

		if (!(req in conf_access))
			conf_access += req
		else
			conf_access -= req
