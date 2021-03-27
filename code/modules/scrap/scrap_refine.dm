/obj/structure/scrap_cube
	name = "compressed scrap"
	desc = "A cube made of scrap compressed with hydraulic clamp."
	density = 1
	anchored = 0
	icon_state = "trash_cube"
	icon = 'icons/obj/structures/scrap/refine.dmi'

/obj/structure/scrap_cube/proc/make_pile()
	for(var/obj/item in contents)
		item.forceMove(loc)
	qdel(src)

/obj/structure/scrap_cube/atom_init(mapload, size = -1)
	if(size < 0)
		new /obj/random/scrap/moderate_weighted(src)
	. = ..()

/obj/structure/scrap_cube/attackby(obj/item/W, mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	if(istype(W,/obj/item/weapon) && W.force >=8)
		visible_message("<span class='notice'>\The [user] smashes the [src], restoring it's original form.</span>")
		make_pile()
	else
		visible_message("<span class='notice'>\The [user] smashes the [src], but [W] is too weak to break it!</span>")

/obj/item/weapon/scrap_lump
	name = "unrefined scrap"
	desc = "This thing is messed up beyond any recognition. Into the grinder it goes!"
	icon = 'icons/obj/structures/scrap/refine.dmi'
	icon_state = "unrefined"
	w_class = ITEM_SIZE_LARGE

/obj/item/weapon/scrap_lump/atom_init()
	. = ..()
	pixel_x = rand(0, 16) - 8
	pixel_y = rand(0, 8) - 8

var/global/list/datum/stack_recipe/scrap_recipes = list ( \
	new/datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3), \
	new/datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg), \
)

/obj/item/stack/sheet/refined_scrap
	name = "refined scrap"
	desc = "This is ghetto gold! It could be used as fuel or building material. Even central Command would give cargo points for this."
	icon = 'icons/obj/structures/scrap/refine.dmi'
	icon_state = "refined"
	max_amount = 20
	amount = 1
