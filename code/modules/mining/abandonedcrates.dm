/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	locked = TRUE
	var/lastattempt = null
	var/attempts = 3
	var/successful_numbers = 0
	var/list/pos_numbers = list(1, 2, 3, 4, 5, 6, 7, 8, 9)
	var/list/buttons_pressed = list(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)
	var/list/code = list()

/obj/structure/closet/crate/secure/loot/atom_init()
	. = ..()
	for (var/i in 1 to 3)
		code += pick_n_take(pos_numbers)

/obj/structure/closet/crate/secure/loot/PopulateContents()
	var/loot = rand(1,30)
	switch(loot)
		if(1)
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/rum(src)
			new/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus(src)
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey(src)
			new/obj/item/weapon/lighter/zippo(src)
		if(2)
			new/obj/item/weapon/pickaxe/drill(src)
			new/obj/item/device/taperecorder(src)
			new/obj/item/clothing/suit/space(src)
			new/obj/item/clothing/head/helmet/space(src)
		if(3)
			new/obj/item/weapon/melee/baton(src)
		if(4)
			new/obj/item/weapon/reagent_containers/glass/beaker/bluespace(src)
		if(5 to 6)
			for (var/i in 1 to 10)
				new/obj/item/weapon/ore/diamond(src)
		if(7)
			new/obj/item/clothing/under/shorts/black(src)
			new/obj/item/clothing/under/shorts/red(src)
			new/obj/item/clothing/under/shorts/blue(src)
		if(8)
			new/obj/item/clothing/under/chameleon(src)
			for (var/i in 1 to 7)
				new/obj/item/clothing/accessory/tie/horrible(src)
		if(9)
			for (var/i in 1 to 3)
				new/obj/machinery/hydroponics/constructable(src)
		if(10)
			for (var/i in 1 to 3)
				new/obj/item/weapon/reagent_containers/glass/beaker/noreact(src)
		if(11 to 12)
			for (var/i in 1 to 9)
				new/obj/item/bluespace_crystal(src)
		if(13)
			new/obj/item/weapon/melee/classic_baton(src)
		if(14 to 30)
			return

/obj/structure/closet/crate/secure/loot/togglelock(mob/user)
	return

/obj/structure/closet/crate/secure/loot/dump_contents()
	if(locked)
		return
	..()

/obj/structure/closet/crate/secure/loot/attackby(obj/item/weapon/W, mob/user)
	if(locked && ismultitool(W))
		user.SetNextMove(CLICK_CD_INTERACT)
		to_chat(user, "<span class='notice'>DECA-CODE LOCK REPORT:</span>")
		if(lastattempt == null)
			to_chat(user, "<span class='notice'> has been made to open the crate thus far.</span>")
		else
			to_chat(user, "<span class='notice'>* Anti-Tamper Bomb will activate after [attempts == 1 ? "on next" : "[attempts]"] failed access attempts.</span>")
			to_chat(user, "<span class='notice'>* Last access attempt [code > lastattempt ? "lower" : "higher"] than expected code.</span>")
		return
	return ..()

/obj/structure/closet/crate/secure/loot/emag_act(mob/user)
	if(locked)
		to_chat(user, "<span class='notice'>The crate unlocks!</span>")
		locked = 0
		return TRUE
	return FALSE

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user)
	ui_interact(user)

/obj/structure/closet/crate/secure/loot/ui_interact(mob/user)
	tgui_interact(user)

/obj/structure/closet/crate/secure/loot/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Lootcrate", name)
		ui.open()

/obj/structure/closet/crate/secure/loot/tgui_data()
	var/data = list()
	data["code"] = code
	data["attempts"] = attempts
	data["buttons_pressed"] = buttons_pressed

	return data

/obj/structure/closet/crate/secure/loot/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("test_for_luck")
			if(!attempts)
				return

			var/number = params["number"]
			if (!buttons_pressed[number])
				buttons_pressed[number] = TRUE
				attempts--
			else
				return

			for(var/i in code)
				if(number == i)
					successful_numbers++

	update_icon()
