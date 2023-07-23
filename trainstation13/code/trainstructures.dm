//TRAIN STATION 13

//All train related structures are in this module.

//ANIMATED STRUCTURES

var/global/list/train_animated_structures = list()

ADD_TO_GLOBAL_LIST(/obj/structure/train, global.train_animated_structures)

/obj/structure/train
	name = "mysterious force"
	desc = "These aren't the droids you're looking for."
	anchored = TRUE
	var/still_icon_state = "benkenobi"

/obj/structure/train/gangway //Not really a wall, or a turf, but it's made of resin, allright.
	name = "gangway"
	desc = "A flexible connector fitted to the end of a railway coach, enabling passengers to move from one coach to another without danger of falling from the train."
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "gangway_still" //Does not animate by default when spawned, but will animate if the train is moving.
	max_integrity = 70
	opacity = 1
	density = TRUE
	still_icon_state = "gangway"
	flags_2 = IMMUNE_CONVEYOR_2
	resistance_flags = CAN_BE_HIT

/obj/structure/train/gangway/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/train/gangway/attack_alien(mob/user, damage)
	if (!isxenoadult(user) || user.a_intent != INTENT_HARM)	//Safety check for larva.
		return FALSE
	attack_generic(user, damage, BRUTE, MELEE)

/obj/structure/train/gangway/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(HULK in user.mutations)
		if(user.a_intent != INTENT_HARM)
			return FALSE
		user.do_attack_animation(src)
		user.visible_message("<span class='warning'>[user] destroys the [name]!</span>", self_message = "<span class='notice'>You easily destroy the [name].</span>")
		take_damage(INFINITY, BRUTE, MELEE)
	else
		user.visible_message("<span class='warning'>[user] claws at the [name]!</span>", self_message = "<span class='notice'>You claw at the [name].</span>")
	return

/obj/structure/train/gangway/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/train/gangway/attack_alien(mob/user, damage)
	..(user, rand(40, 60))

/obj/structure/train/proc/change_movement(moving)
	icon_state = "[still_icon_state]_[moving ? "moving" : "still"]"

//CHAMELEON STRUCTURES

var/global/list/train_chameleon = list()

ADD_TO_GLOBAL_LIST(/obj/structure/chameleon, global.train_chameleon)

/obj/structure/chameleon
	name = "bear referee" //Bears can shapeshift now!
	desc = "It's nice to see you!"
	icon = 'trainstation13/icons/television.dmi'
	icon_state = "bear_referee"
	anchored = TRUE

/obj/structure/chameleon/proc/change_state(state)
	switch(state)
		if("station - traditional")
			name = "bear referee"
			desc = "It's nice to see you!"
			icon_state = "bear_referee"
		if("station - rural")
			name = "bear with vodka"
			desc = "Let's have some fun!"
			icon_state = "bear_vodka"
		if("suburb")
			name = "bear with harmonica"
			desc = "Let's play!"
			icon_state = "bear_harmonica"
		if("field")
			name = "red boxing bear"
			desc = "You stepped into wrong forest."
			icon_state = "bear_red"
		if("forest")
			name = "blue boxing bear"
			desc = "This bear is swole and flexing its muscles. Game over!"
			icon_state = "bear_blue"

/obj/structure/chameleon/bench
	name = "wooden bench"
	desc = "A brown wooden bench. It's tougher than it looks, and a lot heavier than you would expect.<br>It's so heavy you can't pick it up even if you tried."
	icon = 'trainstation13/icons/64x32.dmi'
	icon_state = "bench_wood_brown"

/obj/structure/chameleon/bench/change_state(state)
	switch(state)
		if("station - traditional")
			name = "wooden bench"
			desc = "A brown wooden bench. It's tougher than it looks, and a lot heavier than you would expect.<br>It's so heavy you can't pick it up even if you tried."
			icon_state = "bench_wood_brown"
		if("station - rural")
			name = "wooden bench"
			desc = "A wooden bench painted green. It's tougher than it looks, and a lot heavier than you would expect.<br>It's so heavy you can't pick it up even if you tried."
			icon_state = "bench_wood_green"
		if("suburb")
			name = "wooden bench"
			desc = "A wooden bench coated with transparent varnish. It's tougher than it looks, and a lot heavier than you would expect.<br>It's so heavy you can't pick it up even if you tried."
			icon_state = "bench_wood_brown"
		if("field")
			name = "wooden bench"
			desc = "A wooden bench coated with transparent varnish. It's tougher than it looks, and a lot heavier than you would expect.<br>It's so heavy you can't pick it up even if you tried."
			icon_state = "bench_wood_brown"
		if("forest")
			name = "wooden bench"
			desc = "A wooden bench coated with transparent varnish. It's tougher than it looks, and a lot heavier than you would expect.<br>It's so heavy you can't pick it up even if you tried."
			icon_state = "bench_wood_brown"

/obj/structure/chameleon/lamppost
	name = "street light"
	desc = "A traditional, raised source of light with lamp at the top of a pole."
	icon = 'trainstation13/icons/32x96.dmi'
	icon_state = "lamppost_off"
	density = TRUE
	layer = 5

/obj/structure/chameleon/lamppost/change_state(state)
	switch(state)
		if("station - traditional")
			name = "street light"
			desc = "A traditional, raised source of light with lamp at the top of a metal pole."
			icon_state = "lamppost_off"
		if("station - rural")
			name = "light pole"
			desc = "A wooden pole with lamp on top. Typical way of lighting up the street at night in rural areas."
			icon_state = "light_pole_off"
		if("suburb")
			name = "street light"
			desc = "A traditional, raised source of light with lamp at the top of a metal pole."
			icon_state = "lamppost_off"
		if("field")
			name = "light pole"
			desc = "A wooden pole with lamp on top. Typical way of lighting up the street at night in rural areas."
			icon_state = "light_pole_off"
		if("forest")
			name = "light pole"
			desc = "A wooden pole with lamp on top. Typical way of lighting up the street at night in rural areas."
			icon_state = "light_pole_off"

/obj/structure/chameleon/lamppost/on
	icon_state = "lamppost_on"
	light_power = 1
	light_range = 7

/obj/structure/chameleon/lamppost/on/change_state(state)
	switch(state)
		if("station - traditional")
			name = "street light"
			desc = "A traditional, raised source of light with lamp at the top of a metal pole."
			icon_state = "lamppost_on"
			light_power = 1
			light_range = 7
			light_color = "#a0a080"
		if("station - rural")
			name = "light pole"
			desc = "A wooden pole with lamp on top. Typical way of lighting up the street at night in rural areas."
			icon_state = "light_pole_on"
			light_power = 1
			light_range = 5
			light_color = "#ffffff"
		if("suburb")
			name = "street light"
			desc = "A traditional, raised source of light with lamp at the top of a metal pole."
			icon_state = "lamppost_off"
			light_power = 0
			light_range = 0
		if("field")
			name = "light pole"
			desc = "A wooden pole with lamp on top. Typical way of lighting up the street at night in rural areas."
			icon_state = "light_pole_off"
			light_power = 0
			light_range = 0
		if("forest")
			name = "light pole"
			desc = "A wooden pole with lamp on top. Typical way of lighting up the street at night in rural areas."
			icon_state = "light_pole_off"
			light_power = 0
			light_range = 0
	update_light()

//REGULAR STRUCTURES

/obj/structure/trainstation
	name = "BAM 6AH"
	desc = "TE6E 6AHXAMMEP!"
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "ban"
	anchored = TRUE

/obj/structure/trainstation/bench
	name = "wooden bench"
	desc = "A wooden bench coated with transparent varnish. It's tougher than it looks, and a lot heavier than you would expect.<br>It's so heavy you can't pick it up even if you tried."
	icon = 'trainstation13/icons/64x32.dmi'
	icon_state = "bench_wood_brown"

/obj/structure/trainstation/bench/green
	name = "wooden bench"
	desc = "A wooden bench painted green. It's tougher than it looks, and a lot heavier than you would expect.<br>It's so heavy you can't pick it up even if you tried."
	icon = 'trainstation13/icons/64x32.dmi'
	icon_state = "bench_wood_green"

/obj/structure/trainstation/bench/attackby(obj/item/O, mob/user)
	if(iswrenching(O))
		if(user.is_busy(src))
			return
		if (anchored)
			to_chat(user, "<span class='notice'>You begin to loosen \the [src]'s bolts...</span>")
			if (O.use_tool(src, user, 40, volume = 50))
				user.visible_message(
					"<span class='notice'>[user] loosens \the [src]'s bolts.</span>",
					"<span class='notice'>You have loosened \the [src]. Now it can be pulled somewhere else.</span>",
					"<span class='notice'>You hear ratchet.</span>"
				)
		else
			to_chat(user, "<span class='notice'>You begin to tighten \the [src] to the floor...</span>")
			if(O.use_tool(src, user, 20, volume = 50))
				user.visible_message(
					"<span class='notice'>[user] tightens \the [src]'s bolts.</span>",
					"<span class='notice'>You have tightened \the [src]'s bolts. No one will be able to pull it away.</span>",
					"<span class='notice'>You hear ratchet.</span>"
				)

		anchored = !anchored
	else
		..()

/obj/structure/trainstation/lamppost
	name = "street light"
	desc = "A traditional, raised source of light with lamp at the top of a pole."
	icon = 'trainstation13/icons/32x96.dmi'
	icon_state = "lamppost_off"
	layer = 5
	density = TRUE

/obj/structure/trainstation/lamppost/on
	icon_state = "lamppost_on"
	light_power = 1
	light_range = 7
	light_color = "#a0a080"

/obj/structure/trainstation/lamppost/rural
	name = "light pole"
	desc = "A wooden pole with lamp on top. Typical way of lighting up the street at night in rural areas."
	icon_state = "light_pole_off"

/obj/structure/trainstation/lamppost/rural/on
	icon_state = "light_pole_on"
	light_power = 1
	light_range = 5

/obj/structure/trainstation/utilitypole
	name = "utility pole"
	desc = "An old utility pole disconnected from the grid long time ago. It doesn't look sturdy."
	icon = 'trainstation13/icons/32x96.dmi'
	icon_state = "utilitypole"
	layer = 5

/obj/structure/trainstation/narnia
	name = "wooden wardrobe"
	desc = "Fancy wooden wardrobe, looks like it was made with apple wood."
	icon = 'icons/obj/closet.dmi'
	icon_state = "cabinet_open"

//DECALS

/obj/structure/sign/moon
	name = "photo of astronauts"
	desc = "A group photo of legendary astronauts who became the first people on the Moon."
	icon = 'trainstation13/icons/traindecals.dmi'
	icon_state = "photo_moon"

/obj/structure/sign/secretary
	name = "portrait of a person"
	desc = "A formal portrait. Must be someone really important."
	icon = 'trainstation13/icons/traindecals.dmi'
	icon_state = "portrait"

/obj/structure/sign/train
	name = "railcar number"
	desc = "A metal sign with a railcar number on it."
	icon = 'trainstation13/icons/traindecals.dmi'
	icon_state = "zero"
	layer = 4.4

//CARS

/obj/structure/atomobile //Automobile becomes atomobile - by WalterJe
	name = "taxi"
	desc = "A yellow cab with electric engine powered by micro fusion reactor."
	icon = 'trainstation13/icons/96x96.dmi'
	icon_state = "taxi"
	density = TRUE
	anchored = TRUE
	pixel_x = -16

/obj/structure/atomobile/white
	name = "white car"
	desc = "A white car with electric engine powered by micro fusion reactor."
	icon_state = "white"

/obj/structure/atomobile/blue
	name = "blue car"
	desc = "A blue car with electric engine powered by micro fusion reactor."
	icon_state = "blue"

/obj/structure/atomobile/derelict
	name = "scrap car"
	desc = "A rusty automobile carcass.<br>This car is damaged beyond repair."
	icon = 'trainstation13/icons/64x64.dmi'
	icon_state = "derelict_1"
	density = TRUE
	anchored = FALSE
	pixel_x = -20

/obj/structure/atomobile/derelict/atom_init()
	. = ..()
	dir = rand(1, 4)
	icon_state = "derelict_[rand(1, 6)]"

//FURNITURE

/obj/structure/rack/traintable //Sort of a table limited to a single tile
	name = "table"
	desc = "A wedge shaped piece of metal standing on single metal leg.<br>It can not move, but you can fold it." //Add table folding feature.
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "table" //Has 4 directions

/obj/structure/rack/trainshelf //Technically a rack, but really a wall shelf you can pass through because it's attached to a wall slightly above human height.
	name = "wall shelf"
	desc = "A sturdy cargo wall shelf attached to a wall with metal pipes."
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "shelf_metal" //Has 4 directions
	density = FALSE

/obj/structure/stool/bed/chair/wood/fancy //Why does vanilla wooden furniture look so terrible?
	name = "fancy wooden chair"
	desc = "Judging by its soft red velour seat, this chair is too expensive for you."
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "wooden_chair_fancy"

/obj/structure/stool/sofa //Technically a stool, until Tau Ceti gets sofas.
	name = "sofa"
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "sofa"

/obj/structure/bedsheetbin/trainbedsheetbin
	name = "linen bin"
	desc = "A linen bin. Don't forget to turn in your bedsheet."
	icon = 'icons/obj/structures.dmi'
	amount = 5
