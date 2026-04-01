/obj/item/clothing/suit/bio_suit/particle_protection
	name = "particle protection suit"
	desc = "A suit designed for use in hazardous environment conditions. Not for space works!"
	icon_state = "particle_protection"
	item_state = "particle_protection"
	item_state_world = "particle_protection_w"
	armor = list(melee = 25, bullet = 10, laser = 15, energy = 15, bomb = 25, bio = 100, rad = 100)

/obj/item/clothing/head/bio_hood/particle_protection
	name = "particle protection helmet"
	desc = "A special helmet designed for use in hazardous environment conditions. Not for space works!!"
	icon_state = "particle_protection_h"
	item_state = "particle_protection_h"
	item_state_world = "particle_protection_h_w"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(melee = 25, bullet = 10, laser = 15, energy = 15, bomb = 25, bio = 100, rad = 100)
	var/cooldown_sound = 0

/obj/item/clothing/head/bio_hood/particle_protection/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_HEAD && world.time > cooldown_sound)
		playsound(src, 'sound/rig/loudbeep.ogg', VOL_EFFECTS_MASTER)
		cooldown_sound = world.time + 2 SECONDS
