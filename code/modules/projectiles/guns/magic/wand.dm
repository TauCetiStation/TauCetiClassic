/obj/item/weapon/gun/magic/wand/healing
	name = "wand of healing"
	desc = "An artefact that uses healing magics to heal the living and revive the dead. Rarely utilized on others, for some reason"
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	item_state = "staffofchange"
	fire_delay = 120
	max_charges = 1
	var/heal_power = 20
/obj/item/weapon/gun/magic/wand/healing/zap_self(mob/living/user)
	..()
	if(isliving(user))
		user.apply_damages(heal_power, heal_power, heal_power, heal_power, heal_power, heal_power)
		user.apply_effects(heal_power, heal_power, heal_power, heal_power, heal_power, heal_power, heal_power, heal_power)
		to_chat(user, "<span class='notice'> Ты чувствуешь себя лучше! )</span>")

/obj/item/weapon/gun/magic/wand/blink
	name = "staff of blink"
	desc = "An artefact that makes no qualms about depositing teleportees in space, fires, or the center of a black hole."
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	item_state = "staffofanimation"

/obj/item/weapon/gun/magic/wand/fireball
	name = "wand of fireball"
	desc = "A useful artefact for burning those you don't like and everyone else too. Point away from face."
	ammo_type = /obj/item/ammo_casing/magic/heal
	icon_state = "staffofhealing"
	item_state = "staffofhealing"
	ammo_type = /obj/item/ammo_casing/magic/fireball

/obj/item/weapon/gun/magic/wand/forcewall
	name = "staff of walls"
	desc = "An artefact that spits bolts of transformative magic that can create walls."
	ammo_type = /obj/item/projectile/atom_create/magic
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	fire_sound = 'sound/magic/Staff_Door.ogg'

/obj/item/weapon/gun/magic/wand/magic_mirror
	name = "wand of mirrors"
	icon_state = "lavastaff"
	item_state = "lavastaff"
	desc = "An artefact that contains powers of magic mirror."
	ammo_type = /obj/item/ammo_casing/magic/fireball

/obj/item/weapon/gun/magic/wand/mob_alchemy/magic_carp
	name = "wand of corpse melting"
	icon_state = "lavastaff"
	item_state = "lavastaff"
	desc = "An artefact that turns corpses into aggresive blood cloths"
	ammo_type = /obj/item/ammo_casing/magic/fireball

/obj/item/weapon/gun/magic/wand/stone
	name = "wand of corpse melting"
	icon_state = "lavastaff"
	item_state = "lavastaff"
	desc = "An artefact that turns corpses into aggresive blood cloths"
	ammo_type = /obj/item/ammo_casing/magic/fireball
