/obj/item/weapon/gun/magic/wand/healing
	name = "wand of healing"
	desc = "Артефакт, способный привести в чувства любое сушество.. пока оно живо. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком'' "
	ammo_type = /obj/item/ammo_casing/magic/wand/heal
	icon_state = "staffofchange"
	item_state = "staffofchange"
	fire_delay = 120
	max_charges = 1
	var/heal_power = -100

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
	name = "staff of blink"
	desc = "An artefact that makes no qualms about depositing teleportees in space, fires, or the center of a black hole."
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	item_state = "staffofanimation"
	var/blink_range = 12

/obj/item/weapon/gun/magic/wand/blink/zap_self(mob/living/user)
	if(isliving(user))
		do_teleport(user, get_turf(user), blink_range, asoundin = 'sound/magic/blink.ogg')

/obj/item/weapon/gun/magic/wand/fireball
	name = "wand of fireball"
	desc = "A useful artefact for burning those you don't like and everyone else too. Point away from face."
	ammo_type = /obj/item/ammo_casing/magic/fireball
	icon_state = "staffofhealing"
	item_state = "staffofhealing"

/obj/item/weapon/gun/magic/wand/fireball/zap_self(mob/living/user)
	..()
	explosion(get_turf(user), 0, 0, 1, adminlog = FALSE)

/obj/item/weapon/gun/magic/wand/forcewall
	name = "Жезл магической стены"
	desc = "Артефакт, способный создавать магические стены. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком''."
	ammo_type = /obj/item/ammo_casing/magic/wand/forcewall
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	fire_sound = 'sound/magic/Staff_Door.ogg'

/obj/item/weapon/gun/magic/wand/broken_mirror
	name = "Жезл разбитого зеркала"
	icon_state = "lavastaff"
	item_state = "lavastaff"
	desc = "Артефакт, способный до неузнаваимости изуродовать личность жертвы. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком''."
	ammo_type = /obj/item/ammo_casing/magic/wand/broken_mirror

/obj/item/weapon/gun/magic/wand/broken_mirror/zap_self(mob/living/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/T = user
		T.randomize_appearance()
		to_chat(user, "<span class='notice'> Ты чувствуешь себя иначе.</span>")

/obj/item/weapon/gun/magic/wand/magic_carp
	name = "Жезл магического карпа"
	icon_state = "lavastaff"
	item_state = "lavastaff"
	desc = "Артефакт, призывающий магического карпа. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком''."
	ammo_type = /obj/item/ammo_casing/magic/wand/magicarp

/obj/item/weapon/gun/magic/wand/magic_missle
	name = "Жезл магической ракеты"
	icon_state = "lavastaff"
	item_state = "lavastaff"
	desc = "Артефакт, призывающий сбивающую c ног магическую ракету. Судя по небольшой надписи, кольцо на жезле ''служит спусковым крючком''"
	ammo_type = /obj/item/ammo_casing/magic/wand/magic_missle
