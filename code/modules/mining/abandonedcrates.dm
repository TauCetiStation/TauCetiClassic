/obj/structure/closet/crate/secure/loot
	name = "Abandoned crate"
	desc = "Что же может оказаться внутри?"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	locked = TRUE
	var/datum/minigame/minesweeper/Game

/obj/structure/closet/crate/secure/loot/atom_init()
	. = ..()

	Game = new()
	Game.setup_game()

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user)
	if(!locked)
		return ..()
	tgui_interact(user)

/obj/structure/closet/crate/secure/loot/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Minesweeper")
		ui.open()

/obj/structure/closet/crate/secure/loot/tgui_data(mob/user)
	var/list/data = list()

	data["grid"] = Game.grid
	data["width"] = Game.grid_x*30
	data["height"] = Game.grid_y*30
	data["mines"] = "Замок ящика. [num2text(Game.grid_mines)] мин."

	return data

/obj/structure/closet/crate/secure/loot/tgui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "button_press")
		if(Game.button_press(text2num(params["choice_y"]), text2num(params["choice_x"])))
			playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
		else
			SpawnDeathLoot()
			return TRUE

	if(action == "button_flag")
		if(Game.button_flag(text2num(params["choice_y"]), text2num(params["choice_x"])))
			playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER, 100, TRUE)


	if(Game.check_complete())
		won()

	return TRUE

/obj/structure/closet/crate/secure/loot/proc/won()
	var/loot_quality = 2 * Game.grid_mines/Game.grid_blanks
	if(prob(loot_quality * 100))
		SpawnGoodLoot()
	else
		loot_quality = loot_quality / (1 - loot_quality)
		if(prob(loot_quality * 100))
			SpawnMediumLoot()
		else
			SpawnBadLoot()

	visible_message("<span class='notice'>Издавая звук, ящик открывается!</span>")
	locked = FALSE
	add_overlay(greenlight)
	SStgui.close_uis(src)

/obj/structure/closet/crate/secure/loot/proc/SpawnGoodLoot()
	playsound(src, 'sound/misc/mining_reward_3.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
	switch(rand(1, 3))
		if(1)
			new/obj/item/weapon/melee/classic_baton(src)
		if(2)
			new/obj/item/weapon/sledgehammer(src)
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
			new/obj/item/weapon/storage/bag/ore/holding(src)
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

/obj/structure/closet/crate/secure/loot/emag_act(mob/user)
	if(locked)
		visible_message("<span class='notice'>Таинственный ящик мерцает и со скрипом приоткрывается!</span>")
		locked = FALSE
		SpawnBadLoot()
		return TRUE
	return FALSE

/obj/structure/closet/crate/secure/loot/deconstruct(disassembled)
	if(locked)
		SpawnDeathLoot()
		return
	..()

/obj/structure/closet/crate/secure/loot/togglelock(mob/user)
	return

/obj/structure/closet/crate/secure/loot/dump_contents()
	if(locked)
		return
	..()
