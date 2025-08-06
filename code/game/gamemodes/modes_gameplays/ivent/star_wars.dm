/obj/effect/landmark/ivent/star_wars/jedi
	name = "Jedi Spawn"
	icon_state = "x3"

// artifact - force source

/obj/structure/ivent/star_wars/artifact
	name = "bluespace crystal"
	desc = "A green strange crystal"
	icon = 'icons/obj/xenoarchaeology/artifacts.dmi'
	icon_state = "artifact_11"
	density = TRUE
	anchored = TRUE
	light_color = COLOR_GREEN
	light_range = 2
	light_power = 1
	resistance_flags = FULL_INDESTRUCTIBLE

	var/list/force_users = list()
	var/next_touch = 0
	var/next_pulse = 0

/obj/structure/ivent/star_wars/artifact/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/ivent/star_wars/artifact/attack_hand(mob/living/user)
	if(!isliving(user))
		return

	if((world.time < next_touch) || (user in force_users))
		user.adjustFireLoss(15)
		return

	activate()
	force_users += user
	next_touch = world.time + pick(10, 11, 12, 13, 14, 15) MINUTE

/obj/structure/ivent/star_wars/artifact/proc/activate()
	//playsound
	set_light(4, 2)
	icon_state = "artifact_11_active"
	addtimer(CALLBACK(src, PROC_REF(deactivate)), 2 SECOND)

/obj/structure/ivent/star_wars/artifact/proc/deactivate()
	set_light(2, 1)
	icon_state = "artifact_11"

/obj/structure/ivent/star_wars/artifact/process()
	if(world.time > next_pulse)
		pulse()

/obj/structure/ivent/star_wars/artifact/proc/pulse()
	activate()
	next_pulse = world.time + pick(10, 11, 12, 13, 14, 15) MINUTE
	var/list/candidates = player_list - force_users

	for(var/i in 1 to pick(2, 3))
		if(candidates.len == 0)
			break
		force_users += pick_n_take(candidates)

/obj/item/clothing/suit/star_wars
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 20, bio = 20, rad = 20)
	canremove == REMOVE_OWNER_ONLY
	unacidable = 1

/obj/item/clothing/head/star_wars
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 20, bio = 20, rad = 20)
	canremove == REMOVE_OWNER_ONLY
	unacidable = 1

/obj/item/clothing/shoes/star_wars
	name = "leather shoes"
	desc = "A sturdy pair of leather shoes."
	icon_state = "leather"
	canremove == REMOVE_OWNER_ONLY
	unacidable = 1
	flags = NOSLIP

/obj/item/clothing/shoes/star_wars/atom_init()
	. = ..()
	AddComponent(/datum/component/magic_item/wizard)

/obj/item/clothing/suit/star_wars/jedi
	name = "Jedi robe"
	desc = "."
	icon_state = "wizard"
	item_state = "wizrobe"

/obj/item/clothing/head/star_wars/jedi
	name = "Jedi hood"
	desc = "Strange-looking hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizard"

/obj/item/clothing/suit/star_wars/sith
	name = "Sith robe"
	desc = "."
	icon_state = "wizard"
	item_state = "wizrobe"

/obj/item/clothing/head/star_wars/sith
	name = "Sith hood"
	desc = "Strange-looking hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizard"

// swords
/obj/item/weapon/melee/energy/sword/star_wars/attack_self(mob/living/user)
	if(!active && !isrolebytype(/datum/role/star_wars, user))
		return
	. = ..()

//blue for jedi
/obj/item/weapon/melee/energy/sword/star_wars/jedi/atom_init()
	. = ..()
	blade_color = "blue"
	light_color = COLOR_BLUE
/obj/item/weapon/melee/energy/sword/star_wars/jedi/Get_shield_chance()
	if(active)
		return 80
	return 0

// green for master jedi
/obj/item/weapon/melee/energy/sword/star_wars/jedi/leader/atom_init()
	. = ..()
	blade_color = "green"
	light_color = COLOR_GREEN
/obj/item/weapon/melee/energy/sword/star_wars/jedi/leader/Get_shield_chance()
	if(active)
		return 100
	return 0

// red for sith
/obj/item/weapon/melee/energy/sword/star_wars/jedi/atom_init()
	. = ..()
	blade_color = "red"
	light_color = COLOR_RED
/obj/item/weapon/melee/energy/sword/star_wars/jedi/Get_shield_chance()
	if(active)
		return 80
	return 0

// black for master sith
/obj/item/weapon/melee/energy/sword/star_wars/jedi/leader/atom_init()
	. = ..()
	blade_color = "black"
	light_color = COLOR_BLACK
/obj/item/weapon/melee/energy/sword/star_wars/jedi/leader/Get_shield_chance()
	if(active)
		return 100
	return 0
