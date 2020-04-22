//God pick new desire for custom sect
/obj/effect/proc_holder/spell/targeted/pickdesire
	name = "Choose an item to desire"
	favor_cost = 10
	charge_max = 120
	clothes_req = 0
	invocation = "none"
	range = -1
	include_user = 1
	sound = 'sound/magic/Smoke.ogg'
	action_icon_state = "smoke"
	var/list/desire

/obj/effect/proc_holder/spell/targeted/pickdesire/atom_init()
	. = ..()
	desire = list("Cells" = /obj/item/weapon/stock_parts/cell,
				  "Armor" = /obj/item/clothing/suit/armor/riot,
				  "Resourses(Glass, minerals, metalls" = /obj/item/stack/sheet,
				  "Foods" = /obj/item/weapon/reagent_containers/food/snacks,
				  "Drinks" = /obj/item/weapon/reagent_containers/food/drinks,
				  "Energy guns" = /obj/item/weapon/gun/energy,
				  "Bullet guns" = /obj/item/weapon/gun/projectile,
				  "Melee weapons" = /obj/item/weapon/melee,
				  "Armor" = /obj/item/clothing/suit/armor)

/obj/effect/proc_holder/spell/targeted/pickdesire/cast_with_favor()
	..()
	var/new_desire = input(usr, "Select a desire for you", "Select a desire", null) in desire

	var/type_selected = desire[new_desire]
	religious_sect.desired_items += new type_selected()

	religious_sect.desired_items_typecache = typecacheof(religious_sect.desired_items)
	desire -= new_desire
