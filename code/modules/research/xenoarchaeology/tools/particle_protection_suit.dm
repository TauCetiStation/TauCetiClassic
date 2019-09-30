
/obj/item/clothing/suit/bio_suit/particle_protection
	name = "Particle protection suit"
	desc = "A sealed bio suit that protects from unknown exotic particles."
	icon_state = "particle_protection"
	item_state = "particle_protection"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
	var/cooldown_sound = 0

/obj/item/clothing/suit/bio_suit/particle_protection/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_WEAR_SUIT && world.time > cooldown_sound)
		playsound(src, 'sound/items/zip.ogg', VOL_EFFECTS_MASTER)
		cooldown_sound = world.time + 4

/obj/item/clothing/head/bio_hood/particle_protection
	name = "Particle protection hood"
	desc = "A sealed bio hood that protects the head and face from unknown exotic particles."
	icon_state = "particle_protection_hood"
	item_state = "particle_protection_hood"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
	var/cooldown_sound = 0

/obj/item/clothing/head/bio_hood/particle_protection/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_HEAD && world.time > cooldown_sound)
		playsound(src, 'sound/items/zip.ogg', VOL_EFFECTS_MASTER)
		cooldown_sound = world.time + 4

 // The older version of Particle protection suit
/obj/item/clothing/suit/bio_suit/anomaly
	name = "Anomaly suit"
	desc = "A sealed bio suit capable of insulating against exotic alien energies."
	icon_state = "engspace_suit"
	item_state = "engspace_suit"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)

/obj/item/clothing/head/bio_hood/anomaly
	name = "Anomaly hood"
	desc = "A sealed bio hood capable of insulating against exotic alien energies."
	icon_state = "engspace_helmet"
	item_state = "engspace_helmet"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
