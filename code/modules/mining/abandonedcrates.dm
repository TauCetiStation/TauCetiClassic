#define GOOD_LOOT 3
#define MEDIUM_LOOT 2
#define BAD_LOOT 1
#define DEATH_LOOT 0

/obj/structure/closet/crate/secure/loot
	name = "заброшенный ящик"
	desc = "Что же может оказаться внутри?"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	locked = TRUE
	var/attempts = 3
	var/successful_numbers = 0
	var/list/buttons_pressed = list(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)
	var/list/code = list()

/obj/structure/closet/crate/secure/loot/atom_init()
	. = ..()
	var/list/possible_numbers = list(1, 2, 3, 4, 5, 6, 7, 8, 9)
	for (var/i in 1 to 3) // generate code
		code += pick_n_take(possible_numbers)

/obj/structure/closet/crate/secure/loot/proc/GetReward(loot_quality)
	visible_message("<span class='notice'>Издавая звук, ящик открывается!</span>")
	locked = FALSE
	add_overlay(greenlight)
	switch(loot_quality)
		if(GOOD_LOOT)
			SpawnGoodLoot()
		if(MEDIUM_LOOT)
			SpawnMediumLoot()
		if(BAD_LOOT)
			SpawnBadLoot()
		if(DEATH_LOOT)
			SpawnDeathLoot()

/obj/structure/closet/crate/secure/loot/proc/SpawnGoodLoot()
	playsound(src, 'sound/misc/mining_reward_3.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
	switch(rand(1, 3))
		if(1)
			new/obj/item/weapon/melee/classic_baton(src)
		if(2)
			new/obj/item/weapon/twohanded/sledgehammer(src)
		if(3)
			new/obj/item/weapon/gun/energy/xray(src)

/obj/structure/closet/crate/secure/loot/proc/SpawnMediumLoot()
	playsound(src, 'sound/misc/mining_reward_2.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
	switch(rand(1, 4))
		if(1)
			new/obj/item/weapon/pickaxe/drill/diamond_drill(src)
			new/obj/item/device/taperecorder(src)
			new/obj/item/clothing/suit/space(src)
			new/obj/item/clothing/head/helmet/space(src)
		if(2)
			for (var/i in 1 to 3)
				new/obj/item/weapon/reagent_containers/glass/beaker/noreact(src)
		if(3)
			for (var/i in 1 to 9)
				new/obj/item/bluespace_crystal(src)
		if(4)
			for (var/i in 1 to 3)
				new/obj/item/weapon/reagent_containers/glass/beaker/bluespace(src)


/obj/structure/closet/crate/secure/loot/proc/SpawnBadLoot()
	playsound(src, 'sound/misc/mining_reward_1.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
	switch(rand(1, 3))
		if(1)
			new/obj/item/clothing/under/shorts/black(src)
			new/obj/item/clothing/under/shorts/red(src)
			new/obj/item/clothing/under/shorts/blue(src)
		if(2)
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/rum(src)
			new/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus(src)
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey(src)
			new/obj/item/weapon/lighter/zippo(src)
		if(3)
			new/obj/item/clothing/under/chameleon(src)
			new/obj/item/clothing/head/chameleon(src)

/obj/structure/closet/crate/secure/loot/proc/SpawnDeathLoot()
	playsound(src, 'sound/misc/mining_reward_0.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
	for(var/mob/living/carbon/C in viewers(src, 2))
		C.flash_eyes()
	new/mob/living/simple_animal/hostile/mimic/crate(loc)
	qdel(src)

/obj/structure/closet/crate/secure/loot/togglelock(mob/user)
	return

/obj/structure/closet/crate/secure/loot/dump_contents()
	if(locked)
		return
	..()

/obj/structure/closet/crate/secure/loot/attackby(obj/item/weapon/W, mob/user)
	if(locked && ismultitool(W))
		if(W.use_tool(src, user, 25, volume = 50))
			var/addition = code[1] + code[2] + code[3]
			to_chat(user, "Сложение трех кодовых чисел равно: [addition]")
			return
	return ..()

/obj/structure/closet/crate/secure/loot/emag_act(mob/user)
	if(locked)
		visible_message("<span class='notice'>Таинственный ящик мерцает и со скрипом приоткрывается!</span>")
		locked = FALSE
		GetReward(rand(0, 4))
		return TRUE
	return FALSE

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user)
	if(!locked)
		return ..()
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
			if(!buttons_pressed[number])
				buttons_pressed[number] = TRUE
				attempts--
				if(number in code)
					successful_numbers++
					playsound(src, 'sound/misc/mining_crate_success.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
				else
					playsound(src, 'sound/misc/mining_crate_fail.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
				if(!attempts)
					GetReward(successful_numbers)

#undef GOOD_LOOT
#undef MEDIUM_LOOT
#undef BAD_LOOT
#undef DEATH_LOOT
