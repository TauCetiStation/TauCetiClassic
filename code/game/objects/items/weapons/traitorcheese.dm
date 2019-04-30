/obj/item/weapon/reagent_containers/food/traitorcheese
    name = "Cheese wedge"
    desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far"
    icon = 'icons/obj/food.dmi'
    icon_state = "cheesewedge"
    origin_tech = "biotech=5;syndicate=2"
var use=1
var strong

/obj/item/weapon/reagent_containers/food/traitorcheese/attack(mob/living/simple_animal/target, mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(target!=user)
			if(use==0)
				to_chat(user, "\blue \b squeeze the cheese to start")
			if(use==1)
				if(istype(target, /mob/living/simple_animal/mouse))
					to_chat(target, "\blue \b [user] is prophet of THE JERY,KING OF MOUSE,SERVE THEM ANY COST")
					to_chat(target, "\blue \b You feel faster")
					to_chat(target, "\blue \b You feel stronger")
					to_chat(target, "\blue \b You feel better")
					to_chat(H, "\blue \b This mouse look..excited")
					var/remembered_info = "\blue \b You master is [user]"
					target.mind.store_memory(remembered_info)
					H.my_mouse+=target
					target.universal_speak = 1
					target.maxHealth = 35
					target.health = 35
					target.melee_damage_lower = 1
					target.melee_damage_upper = 6
					strong=1
					if(istype(target, /mob/living/carbon/human))
						to_chat(user, "\blue \b You cant do this")
						H.drop_item()
		if(target == user)
			if(use==0)
				to_chat(user, "\blue \b You cant do this")
			if(use==1)
				use=0
				H.my_king+=target
				to_chat(target, "\blue \b You are a King of mouses")



