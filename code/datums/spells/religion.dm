//God pick new desire for custom sect
/obj/effect/proc_holder/spell/pickdesire
	name = "Choose an item to desire"
	action_icon_state = "smoke"
	charge_max = 6 SECONDS //30min
	favor_cost = 1
	clothes_req = 0
	var/list/desire = list("Cells" = /obj/item/weapon/stock_parts/cell,
						   "Armor" = /obj/item/clothing/suit/armor/riot,
						   "Resourses(Glass, minerals, metalls" = /obj/item/stack/sheet,
						   "Foods" = /obj/item/weapon/reagent_containers/food/snacks,
						   "Drinks" = /obj/item/weapon/reagent_containers/food/drinks,
						   "Energy guns" = /obj/item/weapon/gun/energy,
						   "Bullet guns" = /obj/item/weapon/gun/projectile,
						   "Melee weapons" = /obj/item/weapon/melee,
						   "Armor" = /obj/item/clothing/suit/armor/riot)
 
/obj/effect/proc_holder/spell/pickdesire/cast_with_favor()
	..()
	religious_sect.desired_items += input(religious_sect.god, "Select a desire for you", "Select a desire", null) in desire
	religious_sect.desired_items_typecache = typecacheof(religious_sect.desired_items)
