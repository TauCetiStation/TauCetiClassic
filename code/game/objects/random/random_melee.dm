/obj/random/melee
	name = "Random Melee Weapon"
	desc = "This is a random melee weapon."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "swordred"
/obj/random/melee/item_to_spawn()
		return pick(\
						prob(40);/obj/item/weapon/kitchenknife/combat,\
						prob(40);/obj/item/weapon/kitchenknife/butch,\
						prob(40);/obj/item/weapon/kitchen/rollingpin,\
						prob(40);/obj/item/weapon/melee/baton,\
						prob(40);/obj/item/weapon/kitchenknife,\
						prob(40);/obj/item/weapon/melee/telebaton,\
						prob(40);/obj/item/weapon/melee/chainofcommand,\
						prob(40);/obj/item/weapon/melee/icepick,\
						prob(40);/obj/item/weapon/melee/powerfist,\
						prob(40);/obj/item/weapon/spear,\
						prob(60);/obj/item/weapon/hatchet,\
						prob(60);/obj/item/weapon/hatchet/unathiknife,\
						prob(40);/obj/item/weapon/melee/energy/sword,\
						prob(60);/obj/item/weapon/reagent_containers/spray/extinguisher,\
						prob(30);/obj/item/weapon/dualsaber,\
						prob(30);/obj/item/weapon/fireaxe,\
						prob(30);/obj/item/weapon/sledgehammer,\
						prob(40);/obj/item/weapon/circular_saw,\
						prob(40);/obj/item/weapon/claymore,\
						prob(40);/obj/item/weapon/scalpel,\
						prob(40);/obj/item/weapon/broken_bottle,\
						prob(30);/obj/item/weapon/scythe,\
						prob(20);/obj/item/weapon/melee/arm_blade,\
						prob(20);/obj/item/weapon/melee/energy/axe,\
						prob(20);/obj/item/weapon/melee/energy/blade,\
						prob(1);/obj/item/weapon/banhammer
					)
