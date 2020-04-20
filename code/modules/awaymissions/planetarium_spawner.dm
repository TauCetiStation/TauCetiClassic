/obj/structure/planetarium_spawner
	name = "strange button"
	desc = "just push me"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl-denied"
	anchored = TRUE
	var/list/loot_types = list(
			/mob/living/simple_animal/hostile/xenomorph,
			/mob/living/simple_animal/hostile/faithless,
			/mob/living/simple_animal/hostile/cyber_horror,
			/mob/living/simple_animal/hostile/viscerator,
			/mob/living/simple_animal/hostile/hivebot,
			/mob/living/simple_animal/cat,
			/mob/living/simple_animal/goose,
			/mob/living/simple_animal/walrus,
			/obj/item/weapon/gun/energy/decloner,
			/obj/item/weapon/gun/projectile/revolver/flare,
			/obj/item/weapon/gun/energy/sniperrifle,
			/obj/item/weapon/gun/projectile/shotgun/bolt_action,
			/obj/item/stack/sheet/mineral/diamond,
			/obj/item/stack/sheet/mineral/uranium,
			/obj/item/stack/sheet/mineral/gold,
			/obj/item/stack/sheet/mineral/silver,
			/obj/item/trash/raisins,
			/obj/item/trash/candy,
			/obj/item/trash/cheesie,
			/obj/item/trash/chips,
			/obj/item/clothing/glasses/gar/super,
			/obj/item/clothing/glasses/thermal,
			/obj/item/clothing/head/helmet/battlebucket,
			/obj/item/clothing/head/helmet/tactical/marinad
	)

/obj/structure/planetarium_spawner/attack_hand(mob/user)
    var/selected_loot = pick(loot_types)
    var/loot =  new selected_loot(loc)
    if(istype(loot,  /obj/item/stack/sheet))
        var/obj/item/stack/sheet/S = loot
        S.amount = rand(5,15)
    qdel(src) // delete after use

/obj/structure/clown_stuff_spawner
	name = "strange button"
	desc = "may honk be with you"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl-denied"
	anchored = TRUE
	var/list/loot_types = list(
			/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
			/obj/item/mecha_parts/part/honker_torso
	)

/obj/structure/clown_stuff_spawner/attack_hand(mob/user)
	var/selected_loot = pick(loot_types)
	new selected_loot(loc)
	qdel(src) // delete after use
