/obj/structure/cult
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/cult.dmi'

/obj/structure/cult/attackby(obj/item/W, mob/user, params)
	if(iswrench(W))
		to_chat(user, "<span class='notice'>You begin [anchored ? "unwrenching" : "wrenching"] the [src].</span>")
		if(W.use_tool(src, user, 20, volume = 50))
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return

	return ..()

/obj/structure/cult/tome
	name = "desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	light_color = "#cc9338"
	light_power = 2
	light_range = 3

/obj/structure/cult/statue
	name = "statue"
	icon_state = "shell" // can be shell_glow

/obj/structure/cult/statue/jew
	name = "statue of jew"
	icon_state = "jew" // cant be jew_glow

/obj/structure/cult/statue/gargoyle
	name = "statue of gargoyle"
	icon_state = "gargoyle" // can be gargoyle_glow

/obj/structure/cult/pylon
	name = "pylon"
	desc = "A floating crystal that hums with an unearthly energy."
	icon_state = "pylon"
	light_color = "#ff9595"
	light_power = 2
	light_range = 6
	pass_flags = PASSTABLE

// For operations
/obj/machinery/optable/torture_table
	name = "torture table"
	desc = "For tortures"
	icon = 'icons/obj/cult.dmi'
	icon_state = "table2-idle"
	can_buckle = TRUE
	buckle_lying = TRUE

	var/datum/religion/cult/religion
	var/charged = FALSE

	var/image/belt
	var/belt_icon = 'icons/obj/cult.dmi'
	var/belt_icon_state = "torture_restraints"

/obj/machinery/optable/torture_table/atom_init()
	. = ..()
	belt = image(belt_icon, belt_icon_state, layer = FLY_LAYER)

/obj/machinery/optable/torture_table/Destroy()
	religion.torture_tables -= src
	return ..()

/obj/machinery/optable/torture_table/attackby(obj/item/W, mob/user, params)
	if(!charged && istype(W, /obj/item/weapon/storage/bible/tome))
		var/obj/item/weapon/storage/bible/tome/T = W
		if(T.religion && istype(T.religion, /datum/religion/cult))
			var/datum/religion/cult/C = T.religion
			C.torture_tables += src
			religion = C
			name = "charged [initial(name)]"
			filters += filter(type = "outline", size = 1, color = "#990066")
			charged = TRUE
			return

	if(iswrench(W))
		to_chat(user, "<span class='notice'>You begin [anchored ? "unwrenching" : "wrenching"] the [src].</span>")
		if(W.use_tool(src, user, 20, volume = 50))
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return

	return ..()

/obj/machinery/optable/torture_table/MouseDrop_T(atom/A, mob/user)
	if(A in loc)
		if(can_buckle && !buckled_mob)
			user_buckle_mob(A, user)
	else
		return ..()

/obj/machinery/optable/torture_table/buckle_mob(mob/living/M, mob/user)
	..()
	if(M.pixel_x != 0)
		M.pixel_x = 0
	if(M.pixel_y != -1)
		M.pixel_y = -1
	if(M.dir & (EAST|WEST|NORTH))
		M.dir = SOUTH
	add_overlay(belt)

/obj/machinery/optable/torture_table/unbuckle_mob(mob/user)
	..()
	cut_overlay(belt)

/obj/machinery/optable/torture_table/attack_hand(mob/living/user)
	if(user == buckled_mob)
		user.resist()
	else
		if(can_buckle && buckled_mob && istype(user))
			user_unbuckle_mob(user)

/obj/structure/mineral_door/cult
	name = "door"
	icon_state = "cult"
	health = 300
	sheetAmount = 2
	sheetType = /obj/item/stack/sheet/metal
	light_color = "#990000"
	light_range = 2

/obj/structure/mineral_door/cult/MobChecks(mob/user)
	if(!..())
		return FALSE

	if(!user.my_religion || !istype(user.my_religion, /datum/religion/cult))
		return FALSE

	return TRUE

// Just trash
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
	anchored = 1
	light_color = "#550314"
	light_power = 30
	light_range = 3

/obj/effect/orb
	name = "orb"
	desc = "Strange circle."
	icon = 'icons/obj/cult.dmi'
	icon_state = "summoning_orb"

/obj/structure/cult/shell
	name = "cursed shell"
	desc = "It looks at you."
	icon_state = "shuttlecurse"
	light_color = "#6d1616"
	light_power = 2
	light_range = 2
