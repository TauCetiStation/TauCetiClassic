/obj/item/weapon/gun/magic/wand/healing
	name = "жезл исцеления"
	desc = "Артефакт, способный поставить на ноги любое сушество.. пока оно живо. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком'' "
	ammo_type = /obj/item/ammo_casing/magic/wand/heal
	recharge_rate = 90
	item_state = "wand_green"
	icon_state = "heal_on"
	item_state_inventory_on = "heal_on"
	item_state_inventory_off = "heal_off"
	item_state_world_on = "heal_on_world"
	item_state_world_off = "heal_off_world"
	var/heal_power = -100
	fire_sound = 'sound/magic/Staff_Healing.ogg'


/obj/item/weapon/gun/magic/wand/healing/zap_self(mob/living/user)
	..()
	if(isliving(user))
		user.apply_damages(heal_power, heal_power, heal_power, heal_power, heal_power, heal_power)
		user.apply_effects(heal_power, heal_power, heal_power, heal_power, heal_power, heal_power, heal_power, heal_power)
		if(ishuman(user))
			var/mob/living/carbon/human/S = target
			for(var/obj/item/organ/internal/IO in S.organs)
				if(IO.damage > 0 && IO.robotic < 2)
					IO.damage = max(IO.damage - (heal_power / 4), 0)
		to_chat(user, "<span class='notice'> Ты чувствуешь себя лучше!</span>")

/obj/item/weapon/gun/magic/wand/blink
	name = "жезл скачка-телепорта"
	desc = "Артефакт, способный случайно телепортировать свою цель. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком''"
	ammo_type = /obj/item/ammo_casing/magic/wand/blink
	recharge_rate = 2
	item_state = "wand_blue"
	icon_state = "teleport_on"
	item_state_inventory_on = "teleport_on"
	item_state_inventory_off = "teleport_off"
	item_state_world_on = "teleport_on_world"
	item_state_world_off = "teleport_off_world"
	var/blink_range = 12

/obj/item/weapon/gun/magic/wand/blink/zap_self(mob/living/user)
	..()
	if(isliving(user))
		do_teleport(user, get_turf(user), blink_range, asoundin = 'sound/magic/blink.ogg')

/obj/item/weapon/gun/magic/wand/fireball
	name = "жезл огненного шара"
	desc = "A useful artefact for burning those you don't like and everyone else too. Point away from face."
	ammo_type = /obj/item/ammo_casing/magic/fireball
	item_state = "wand_red"
	icon_state = "fire_on"
	item_state_inventory_on = "fire_on"
	item_state_inventory_off = "fire_off"
	item_state_world_on = "fire_on_world"
	item_state_world_off = "fire_off_world"
	recharge_rate = 10
	fire_sound = 'sound/magic/Fireball.ogg'

/obj/item/weapon/gun/magic/wand/fireball/zap_self(mob/living/user)
	..()
	explosion(get_turf(user), 0, 0, 1, adminlog = FALSE)

/obj/item/weapon/gun/magic/wand/forcewall
	name = "жезл магической стены"
	desc = "Артефакт, способный создавать магические стены. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком''."
	ammo_type = /obj/item/ammo_casing/magic/wand/forcewall
	item_state = "wand_blue"
	icon_state = "wall_on"
	item_state_inventory_on = "wall_on"
	item_state_inventory_off = "wall_off"
	item_state_world_on = "wall_on_world"
	item_state_world_off = "wall_off_world"
	fire_sound = 'sound/magic/Staff_Door.ogg'
	recharge_rate = 10


/obj/item/weapon/gun/magic/wand/broken_mirror
	name = "жезл разбитого зеркала"
	desc = "Артефакт, способный до неузнаваимости изуродовать личность жертвы. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком''."
	ammo_type = /obj/item/ammo_casing/magic/wand/broken_mirror
	item_state = "wand_white"
	icon_state = "mirror_on"
	item_state_inventory_on = "mirror_on"
	item_state_inventory_off = "mirror_off"
	item_state_world_on = "mirror_on_world"
	item_state_world_off = "mirror_off_world"
	recharge_rate = 2

/obj/item/weapon/gun/magic/wand/broken_mirror/zap_self(mob/living/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/T = user
		T.randomize_appearance()
		to_chat(user, "<span class='notice'> Ты чувствуешь себя иначе.</span>")

/obj/item/weapon/gun/magic/wand/magic_carp
	name = "жезл магического карпа"
	desc = "Артефакт, призывающий магического карпа. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком'' и данный жезл ЗАПРЕЩЁН использован магами-новичками."
	ammo_type = /obj/item/ammo_casing/magic/wand/magicarp
	item_state = "wand_magenta"
	icon_state = "carp_on"
	item_state_inventory_on = "carp_on"
	item_state_inventory_off = "carp_off"
	item_state_world_on = "carp_on_world"
	item_state_world_off = "carp_off_world"
	recharge_rate = 15

/obj/item/weapon/gun/magic/wand/magic_missle
	name = "жезл магической ракеты"
	desc = "Артефакт, призывающий сбивающую c ног магическую ракету. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком''"
	ammo_type = /obj/item/ammo_casing/magic/wand/magic_missle
	item_state = "wand_magenta"
	icon_state = "missle_on"
	item_state_inventory_on = "missle_on"
	item_state_inventory_off = "missle_off"
	item_state_world_on = "missle_on_world"
	item_state_world_off = "missle_off_world"
	recharge_rate = 7
