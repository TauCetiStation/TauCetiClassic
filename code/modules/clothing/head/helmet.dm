/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	flags = HEADCOVERSEYES | THICKMATERIAL
	item_state = "helmet"
	armor = list(melee = 50, bullet = 60, laser = 50,energy = 20, bomb = 35, bio = 0, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.3
	w_class = 3

/obj/item/clothing/head/helmet/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "helmet_warden"

/obj/item/clothing/head/helmet/HoS
	name = "Head of Security Hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	flags = HEADCOVERSEYES
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEEARS
	body_parts_covered = 0
	siemens_coefficient = 0.8

/obj/item/clothing/head/helmet/HoS/dermal
	name = "Dermal Armour Patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"
	item_state = "dermal"
	siemens_coefficient = 0.6
	body_parts_covered = 1

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	flags = HEADCOVERSEYES | THICKMATERIAL | HEADCOVERSMOUTH
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.3
	action_button_name = "Adjust helmet visor"
	var/up = 0

/obj/item/clothing/head/helmet/riot/attack_self()
	toggle()

/obj/item/clothing/head/helmet/riot/verb/toggle()
	set category = "Object"
	set name = "Adjust helmet visor"
	set src in usr

	if(usr.canmove && !usr.stat && !usr.restrained())
		if(src.up)
			src.up = !src.up
			src.flags |= (HEADCOVERSEYES | HEADCOVERSMOUTH)
			icon_state = initial(icon_state)
			to_chat(usr, "You pull the visor down on")
		else
			src.up = !src.up
			src.flags &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
			icon_state = "[initial(icon_state)]up"
			to_chat(usr, "You push the visor up on")
		usr.update_inv_head()	//so our mob-overlays update

/obj/item/clothing/head/helmet/bulletproof
	name = "bulletproof helmet"
	desc = "A bulletproof security helmet that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "bulletproof"

/obj/item/clothing/head/helmet/laserproof
	name = "ablative helmet"
	desc = "A ablative security helmet that excels in protecting the wearer against energy and laser projectiles."
	icon_state = "laserproof"
	armor = list(melee = 10, bullet = 10, laser = 45,energy = 55, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0

	var/hit_reflect_chance = 40

/obj/item/clothing/head/helmet/laserproof/IsReflect(def_zone)
	if(prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	flags = HEADCOVERSEYES | THICKMATERIAL
	item_state = "swat"
	armor = list(melee = 80, bullet = 75, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.3

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags = HEADCOVERSEYES
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/tactical
	name = "tactical helmet"
	desc = "An armored helmet capable of being fitted with a multitude of attachments."
	icon_state = "swathelm"
	item_state = "helmet"
	flags = HEADCOVERSEYES

	armor = list(melee = 62, bullet = 60, laser = 50,energy = 35, bomb = 10, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.7

/obj/item/clothing/head/helmet/helmet_of_justice
	name = "helmet of justice"
	desc = "Prepare for Justice!"
	icon_state = "shitcuritron_0"
	item_state = "helmet"
	var/on = 0
	action_button_name = "Toggle Helmet"

/obj/item/clothing/head/helmet/helmet_of_justice/attack_self(mob/user)
	on = !on
	icon_state = "shitcuritron_[on]"
	user.update_inv_head()

/obj/item/clothing/head/helmet/warden/blue
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force. Protects the head from impacts."
	icon_state = "oldwardenhelm"
	item_state = "helmet"
