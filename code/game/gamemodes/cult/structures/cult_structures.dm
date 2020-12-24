/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

/obj/structure/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"
	light_color = "#2f0e0e"
	light_power = 2
	light_range = 3

/obj/structure/cult/tome
	name = "desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	light_color = "#cc9338"
	light_power = 2
	light_range = 3

/obj/structure/cult/shell
	name = "cursed shell"
	desc = "It looks at you."
	icon_state = "shuttlecurse"
	light_color = "#6d1616"
	light_power = 2
	light_range = 2

/obj/structure/cult/pylon
	name = "pylon"
	desc = "A floating crystal that hums with an unearthly energy."
	icon_state = "pylon"
	light_color = "#ff9595"
	light_power = 2
	light_range = 6
	pass_flags = PASSTABLE

/obj/structure/cult/torture_table
	name = "torture table"
	desc = "For tortures"
	icon_state = "torture_table"
	can_buckle = TRUE
	buckle_lying = TRUE
	climbable = TRUE

	var/image/belt
	var/belt_icon = 'icons/obj/cult.dmi'
	var/belt_icon_state = "torture_restraints"

/obj/structure/cult/torture_table/atom_init()
	. = ..()
	belt = image(belt_icon, belt_icon_state, layer = FLY_LAYER)

/obj/structure/cult/torture_table/buckle_mob(mob/living/M, mob/user)
	..()
	if(M.pixel_x != 0)
		M.pixel_x = 0
	if(M.pixel_y != -1)
		M.pixel_y = -1
	if(M.dir & (EAST|WEST|NORTH))
		M.dir = SOUTH
	add_overlay(belt)

/obj/structure/cult/torture_table/unbuckle_mob(mob/user)
	..()
	cut_overlay(belt)

/obj/structure/cult/torture_table/correct_pixel_shift(mob/living/carbon/C)
	return

/obj/structure/cult/torture_table/attack_hand(mob/living/user)
	if(user == buckled_mob)
		user.resist()
	else
		..()

/obj/structure/mineral_door/cult
	name = "door"
	icon_state = "cult"
	health = 300
	sheetAmount = 2
	sheetType = /obj/item/stack/sheet/metal

/obj/structure/mineral_door/cult/MobChecks(mob/user)
	if(!..())
		return FALSE

	if(!user.my_religion || !istype(user.my_religion, /datum/religion/cult))
		return FALSE

	return TRUE

/obj/effect/spacewhole
	name = "abyss in space"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "space"

/obj/effect/timewhole
	name = "abyss in time"
	desc = "You feel a billion different looks when you gaze into emptiness."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1.0
	light_color = "#550314"
	light_power = 30
	light_range = 3

/obj/effect/orb
	name = "orb"
	desc = "Strange circle."
	icon = 'icons/obj/cult.dmi'
	icon_state = "summoning_orb"
