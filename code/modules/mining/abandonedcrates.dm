/obj/structure/closet/crate/secure/loot
	name = "заброшенный ящик"
	desc = "Что же может оказаться внутри?"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	locked = TRUE
	var/list/grid
	var/grid_x = 0
	var/grid_y = 0
	var/grid_mines = 0
	var/grid_blanks = 0
	var/grid_pressed = 0
	var/list/nearest_mask = list(list(-1, -1), list(0, -1), list(1, -1), list(-1, 0), list(1, 0), list(-1, 1), list(0, 1), list(1, 1))

/obj/structure/closet/crate/secure/loot/atom_init()
	. = ..()

	grid_x = rand(10,15)
	grid_y = rand(7,10)

	grid_mines = rand(7,17)

	grid = new/list(grid_y, grid_x)

	for(var/i = 1 to grid_y)
		var/list/Line = grid[i]
		for(var/j = 1 to grid_x)
			Line[j] = list("state" = "blank", "x" = j, "y" = i, "nearest" = "")
			grid_blanks++

	for(var/i = 1 to grid_mines)
		while(TRUE)
			var/y = rand(1,grid_y)
			var/x = rand(1,grid_x)
			var/list/L = grid[y][x]
			if(L["state"] == "mine")
				continue
			else
				L["state"] = "mine"
				grid_blanks--
				break

/obj/structure/closet/crate/secure/loot/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/auto_update = 1

	var/title = "Crate Lock. [grid_mines] mines."

	var/data[0]

	data["grid"] = grid

	if(ui)
		ui.load_cached_data(ManifestJSON)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "minesweeper.tmpl", title, grid_x*30, grid_y*30+32)

		ui.load_cached_data(ManifestJSON)

		ui.set_initial_data(data)

		ui.set_window_options("focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=0;titlebar=1;")

		ui.open()
	ui.set_auto_update(auto_update)

/obj/structure/closet/crate/secure/loot/Topic(href, href_list)
	..()

	if(href_list["choice_x"])
		press_button(href_list["choice_x"], href_list["choice_y"])

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user)
	if(!locked)
		return ..()
	ui_interact(user)

/obj/structure/closet/crate/secure/loot/proc/check_in_grid(x, y)
	return x >= 1 && x <= grid_x && y >= 1 && y <= grid_y

/obj/structure/closet/crate/secure/loot/proc/press_button(x, y)
	if(grid[text2num(y)][text2num(x)]["state"] == "mine")
		SpawnDeathLoot()
		return
	reveal_button(text2num(x),text2num(y))
	nanomanager.update_uis(src)

/obj/structure/closet/crate/secure/loot/proc/reveal_button(x,y)
	if(!check_in_grid(x, y) || grid[y][x]["state"] == "empty")
		return
	grid[y][x]["state"] = "empty"
	grid_pressed++
	check_complete()
	var/mi = check_mines(x,y)
	if(mi)
		if(mi == 0)
			mi = ""
		grid[y][x]["nearest"] = num2text(mi)
		return
	for(var/list/mask in nearest_mask)
		reveal_button(x + mask[1], y + mask[2])

/obj/structure/closet/crate/secure/loot/proc/check_mines(x,y)
	var/mins = 0

	for(var/list/mask in nearest_mask)
		if(check_in_grid(x + mask[1], y + mask[2]) && grid[y + mask[2]][x + mask[1]]["state"] == "mine")
			mins++

	return mins

/obj/structure/closet/crate/secure/loot/proc/check_complete()
	if(grid_pressed == grid_blanks)
		var/loot_quality = 2*grid_mines/grid_blanks
		if(prob(loot_quality*100))
			SpawnGoodLoot()
		else
			loot_quality = loot_quality/(1 - loot_quality)
			if(prob(loot_quality*100))
				SpawnMediumLoot()
			else
				SpawnBadLoot()
		visible_message("<span class='notice'>Издавая звук, ящик открывается!</span>")
		locked = FALSE
		add_overlay(greenlight)
		nanomanager.close_uis(src)


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
