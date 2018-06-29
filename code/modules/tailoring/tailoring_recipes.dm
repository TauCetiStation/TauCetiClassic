/datum/tailoring_progress
	var/obj/item/stack/sheet/cloth/cloth_processed/processee
	var/list/steps_made = list()                       // Counts up all the steps, including buffs.
	var/list/progress_made = list()                    // Counts up progress steps, that recipes require.
	var/list/add_armor_values = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/quality = 0 // The current quality of work.

/datum/tailoring_progress/New(obj/item/stack/sheet/cloth/cloth_processed/C)
	..()
	C = processee

/datum/tailoring_progress/Destroy()
	processee = null
	return ..()

/datum/tailoring_progress/proc/armor_buff_modify(melee_m, bullet_m, laser_m, energy_m, bomb_m, bio_m, rad_m)
	if(melee_m)
		add_armor_values["melee"] += melee_m
	if(bullet_m)
		add_armor_values["bullet"] += bullet_m
	if(laser_m)
		add_armor_values["laser"] += laser_m
	if(energy_m)
		add_armor_values["energy"] += energy_m
	if(bomb_m)
		add_armor_values["bomb"] += bomb_m
	if(bio_m)
		add_armor_values["bio"] += bio_m
	if(rad_m)
		add_armor_values["rad"] += rad_m

var/global/list/tailoring_recipes = list()

/datum/tailoring_recipe
	var/list/steps_required = list()
	var/cloth_amount = 1                       // Required amount of cloth for step to be complete.
	var/list/cloth_colour = "general"    // Required colour of cloth. If set to "general" any colour can be used.
	var/result
	var/result_amount = 1

/datum/tailoring_recipe/proc/is_done(obj/item/stack/sheet/cloth/cloth_processed/C)
	if(!compare_lists(C.tailoring.progress_made, steps_required))
		return FALSE
	if(C.amount < cloth_amount)
		return FALSE
	if(C.color != cloth_colour && cloth_colour != "general")
		return FALSE
	return TRUE

/datum/tailoring_recipe/proc/get_quality_name(obj/item/stack/sheet/cloth/cloth_processed/C)
	switch(C.tailoring.quality)
		if(-INFINITY to -11)
			return "impossibly bad" // Quite literally. It should've been checked in do_tailoring proc, and if it's quality was lower than 10, destroyed.
		if(-10 to -8)
			return "ripped and shred"
		if(-7 to -4)
			return "disgustingly made"
		if(-3 to -1)
			return "horrible"
		if(0)
			return ""
		if(1 to 3)
			return "good"
		if(4 to 7)
			return "well-made"
		if(8 to 10)
			return "terrific"
		if(10 to INFINITY)
			return "master-crafted"

/datum/tailoring_recipe/proc/create_done(obj/item/stack/sheet/cloth/cloth_processed/C)
	for(var/A in 1 to result_amount)
		. = new result(get_turf(C))
		apply_buffs(C, .)
	C.tailoring.quality = 0
	C.tailoring.steps_made = list()
	C.tailoring.progress_made = list()
	C.tailoring.add_armor_values = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	C.use(cloth_amount)

/datum/tailoring_recipe/proc/apply_buffs(obj/item/stack/sheet/cloth/cloth_processed/C, obj/O)
	if(get_quality_name(C))
		O.name = "[get_quality_name(C)] [initial(O.name)]"

/datum/tailoring_recipe/string
	steps_required = list("rolling", "rolling", "rolling", "rolling")
	result = /obj/item/stack/string
	result_amount = 3

/datum/tailoring_recipe/plaid
	steps_required = list("knitting", "knitting", "knitting", "cutting")
	cloth_amount = 3
	cloth_colour = COLOR_BROWN
	result = /obj/item/clothing/suit/plaid

/datum/tailoring_recipe/bedsheet
	steps_required = list("knitting", "knitting", "knitting", "knitting")
	cloth_amount = 3
	cloth_colour = COLOR_WHITE
	result = /obj/item/weapon/bedsheet

/datum/tailoring_recipe/bedsheet/red
	cloth_colour = COLOR_RED
	result = /obj/item/weapon/bedsheet/red

/datum/tailoring_recipe/bedsheet/blue
	cloth_colour = COLOR_BLUE
	result = /obj/item/weapon/bedsheet/blue

/datum/tailoring_recipe/bedsheet/green
	cloth_colour = COLOR_GREEN
	result = /obj/item/weapon/bedsheet/green

/datum/tailoring_recipe/bedsheet/yellow
	cloth_colour = COLOR_YELLOW
	result = /obj/item/weapon/bedsheet/yellow

/datum/tailoring_recipe/bedsheet/orange
	cloth_colour = COLOR_ORANGE
	result = /obj/item/weapon/bedsheet/orange

/datum/tailoring_recipe/bedsheet/purple
	cloth_colour = COLOR_PURPLE
	result = /obj/item/weapon/bedsheet/purple

/datum/tailoring_recipe/bedsheet/brown
	cloth_colour = COLOR_BROWN
	result = /obj/item/weapon/bedsheet/brown

/datum/tailoring_recipe/clothing/apply_buffs(obj/item/stack/sheet/cloth/cloth_processed/C, obj/item/clothing/O)
	..()
	if(C.tailoring.quality < 0)
		O.slowdown = O.slowdown - C.tailoring.quality/2 // So it doesn't slow you down by ALL that much.
	for(var/A in C.tailoring.add_armor_values)
		O.armor[A] += C.tailoring.add_armor_values[A]

/datum/tailoring_recipe/clothing/hat
	cloth_amount = 2

/datum/tailoring_recipe/clothing/hat/cap
	steps_required = list("cutting", "weaving", "needling", "cutting")
	cloth_colour = COLOR_GREY
	result = /obj/item/clothing/head/soft/grey

/datum/tailoring_recipe/clothing/hat/cap/red
	cloth_colour = COLOR_RED
	result = /obj/item/clothing/head/soft/red

/datum/tailoring_recipe/clothing/hat/cap/blue
	cloth_colour = COLOR_BLUE
	result = /obj/item/clothing/head/soft/blue

/datum/tailoring_recipe/clothing/hat/cap/green
	cloth_colour = COLOR_GREEN
	result = /obj/item/clothing/head/soft/green

/datum/tailoring_recipe/clothing/hat/cap/yellow
	cloth_colour = COLOR_YELLOW
	result = /obj/item/clothing/head/soft/yellow

/datum/tailoring_recipe/clothing/hat/cap/orange
	cloth_colour = COLOR_ORANGE
	result = /obj/item/clothing/head/soft/orange

/datum/tailoring_recipe/clothing/hat/cap/white
	cloth_colour = COLOR_WHITE
	result = /obj/item/clothing/head/soft/mime

/datum/tailoring_recipe/clothing/hat/cap/purple
	cloth_colour = COLOR_PURPLE
	result = /obj/item/clothing/head/soft/purple

/datum/tailoring_recipe/clothing/hat/bandana
	steps_required = list("knitting", "weaving", "knitting", "weaving")
	cloth_colour = COLOR_BLACK
	result = /obj/item/clothing/mask/bandana/black

/datum/tailoring_recipe/clothing/hat/bandana/red
	cloth_colour = COLOR_RED
	result = /obj/item/clothing/mask/bandana/red

/datum/tailoring_recipe/clothing/hat/bandana/green
	cloth_colour = COLOR_GREEN
	result = /obj/item/clothing/mask/bandana/green

/datum/tailoring_recipe/clothing/hat/bandana/blue
	cloth_colour = COLOR_BLUE
	result = /obj/item/clothing/mask/bandana/blue

/datum/tailoring_recipe/clothing/hat/bandana/yellow
	cloth_colour = COLOR_YELLOW
	result = /obj/item/clothing/mask/bandana/gold

/datum/tailoring_recipe/clothing/hat/beret
	steps_required = list("cutting", "knitting", "weaving", "needling")
	cloth_colour = COLOR_RED
	result = /obj/item/clothing/head/beret/red

/datum/tailoring_recipe/clothing/hat/beret/blue
	cloth_colour = COLOR_BLUE
	result = /obj/item/clothing/head/beret/blue

/datum/tailoring_recipe/clothing/hat/beret/black
	cloth_colour = COLOR_BLACK
	result = /obj/item/clothing/head/beret/black

/datum/tailoring_recipe/clothing/hat/beret/purple
	cloth_colour = COLOR_PURPLE
	result = /obj/item/clothing/head/beret/purple

/datum/tailoring_recipe/clothing/hat/beret/white
	cloth_colour = COLOR_WHITE
	result = /obj/item/clothing/head/beret/rosa

/datum/tailoring_recipe/clothing/hat/beret/yellow
	cloth_colour = COLOR_YELLOW
	result = /obj/item/clothing/head/beret/eng

/datum/tailoring_recipe/clothing/under
	cloth_amount = 3

/datum/tailoring_recipe/clothing/under/jumpsuit
	steps_required = list("cutting", "needling", "weaving", "needling")
	cloth_colour = COLOR_WHITE
	result = /obj/item/clothing/under/color/white

/datum/tailoring_recipe/clothing/under/jumpsuit/red
	cloth_colour = COLOR_RED
	result = /obj/item/clothing/under/color/red

/datum/tailoring_recipe/jumpsuit/blue
	cloth_colour = COLOR_BLUE
	result = /obj/item/clothing/under/color/blue

/datum/tailoring_recipe/clothing/under/jumpsuit/green
	cloth_colour = COLOR_GREEN
	result = /obj/item/clothing/under/color/green

/datum/tailoring_recipe/clothing/under/jumpsuit/yellow
	cloth_colour = COLOR_YELLOW
	result = /obj/item/clothing/under/color/yellow

/datum/tailoring_recipe/clothing/under/jumpsuit/orange
	cloth_colour = COLOR_ORANGE
	result = /obj/item/clothing/under/color/orange

/datum/tailoring_recipe/clothing/under/jumpsuit/pink
	cloth_colour = COLOR_PINK
	result = /obj/item/clothing/under/color/pink

/datum/tailoring_recipe/clothing/under/jumpsuit/grey
	cloth_colour = COLOR_GREY
	result = /obj/item/clothing/under/color/grey

/datum/tailoring_recipe/clothing/under/jumpsuit/black
	cloth_colour = COLOR_BLACK
	result = /obj/item/clothing/under/color/black

/datum/tailoring_recipe/clothing/gloves
	cloth_amount = 1

/datum/tailoring_recipe/clothing/gloves/gloves_colored
	steps_required = list("cutting", "weaving", "cutting", "weaving")
	cloth_colour = COLOR_WHITE
	result = /obj/item/clothing/gloves/white

/datum/tailoring_recipe/clothing/gloves/gloves_colored/red
	cloth_colour = COLOR_RED
	result = /obj/item/clothing/gloves/red

/datum/tailoring_recipe/clothing/gloves/gloves_colored/blue
	cloth_colour = COLOR_BLUE
	result = /obj/item/clothing/gloves/blue

/datum/tailoring_recipe/clothing/gloves/gloves_colored/green
	cloth_colour = COLOR_GREEN
	result = /obj/item/clothing/gloves/green

/datum/tailoring_recipe/clothing/gloves/insulated
	steps_required = list("cutting", "leathering", "cutting", "leathering")
	cloth_colour = COLOR_YELLOW
	result = /obj/item/clothing/gloves/yellow

/datum/tailoring_recipe/clothing/gloves/gloves_colored/fyellow
	cloth_colour = COLOR_YELLOW
	result = /obj/item/clothing/gloves/fyellow

/datum/tailoring_recipe/clothing/gloves/gloves_colored/orange
	cloth_colour = COLOR_ORANGE
	result = /obj/item/clothing/gloves/orange

/datum/tailoring_recipe/clothing/gloves/gloves_colored/purple
	cloth_colour = COLOR_PURPLE
	result = /obj/item/clothing/gloves/purple

/datum/tailoring_recipe/clothing/gloves/gloves_colored/grey
	cloth_colour = COLOR_GREY
	result = /obj/item/clothing/gloves/grey

/datum/tailoring_recipe/clothing/gloves/thermo_insulated
	steps_required = list("cutting", "leathering", "cutting", "leathering")
	cloth_colour = COLOR_BLACK
	result = /obj/item/clothing/gloves/black

/datum/tailoring_recipe/clothing/shoes
	cloth_amount = 1

/datum/tailoring_recipe/clothing/shoes/apply_buffs(obj/item/stack/sheet/cloth/cloth_processed/C, obj/item/clothing/O)
	..()
	O.slowdown = max(0, O.slowdown - C.tailoring.quality/2) // Good shoes actually make you faster.

/datum/tailoring_recipe/clothing/shoes/colored_shoes
	steps_required = list("rolling", "weaving", "rolling", "weaving")
	cloth_colour = COLOR_WHITE
	result = /obj/item/clothing/shoes/white

/datum/tailoring_recipe/clothing/shoes/colored_shoes/red
	cloth_colour = COLOR_RED
	result = /obj/item/clothing/shoes/red

/datum/tailoring_recipe/clothing/shoes/colored_shoes/blue
	cloth_colour = COLOR_BLUE
	result = /obj/item/clothing/shoes/blue

/datum/tailoring_recipe/clothing/shoes/colored_shoes/green
	cloth_colour = COLOR_GREEN
	result = /obj/item/clothing/shoes/green

/datum/tailoring_recipe/clothing/shoes/galoshes
	steps_required = list("rolling", "leathering", "rolling", "leathering")
	cloth_colour = COLOR_YELLOW
	result = /obj/item/clothing/shoes/galoshes

/datum/tailoring_recipe/clothing/shoes/colored_shoes/yellow
	cloth_colour = COLOR_YELLOW
	result = /obj/item/clothing/shoes/yellow

/datum/tailoring_recipe/clothing/shoes/colored_shoes/orange
	cloth_colour = COLOR_ORANGE
	result = /obj/item/clothing/shoes/orange

/datum/tailoring_recipe/clothing/shoes/colored_shoes/purple
	cloth_colour = COLOR_PURPLE
	result = /obj/item/clothing/shoes/purple

/datum/tailoring_recipe/clothing/shoes/colored_shoes/brown
	cloth_colour = COLOR_BROWN
	result = /obj/item/clothing/shoes/brown

/datum/tailoring_recipe/clothing/shoes/colored_shoes/black
	cloth_colour = COLOR_BLACK
	result = /obj/item/clothing/shoes/black
