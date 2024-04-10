/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	flags = HEADCOVERSEYES
	item_state = "helmet"
	armor = list(melee = 50, bullet = 45, laser = 40,energy = 25, bomb = 35, bio = 0, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	pierce_protection = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.3
	w_class = SIZE_SMALL
	force = 5
	hitsound = list('sound/items/misc/balloon_small-hit.ogg')
	flashbang_protection = TRUE

	var/obj/item/holochip/holochip

/obj/item/clothing/head/helmet/Destroy()
	QDEL_NULL(holochip)
	return ..()

/obj/item/clothing/head/helmet/equipped(mob/user, slot)
	if(holochip && slot == SLOT_HEAD)
		if(user.hud_used) //NPCs don't need a map
			user.hud_used.init_screen(/atom/movable/screen/holomap)
		holochip.add_action(user)
		holochip.update_freq(holochip.frequency)
	..()

/obj/item/clothing/head/helmet/dropped(mob/user)
	if(holochip)
		holochip.remove_action(user)
		holochip.deactivate_holomap()
	..()

/obj/item/clothing/head/helmet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/holochip))
		if(flags & ABSTRACT)
			return    //You can't insert holochip in abstract item.
		if(holochip)
			to_chat(user, "<span class='notice'>The [src] is already modified with the [holochip]</span>")
			return
		user.drop_from_inventory(I, src)
		holochip = I
		holochip.holder = src
		var/mob/living/carbon/human/H = user
		if(istype(H) && H.head == src)
			holochip.add_action(user)
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You modify the [src] with the [holochip]</span>")
	else if(isscrewing(I))
		if(!holochip)
			to_chat(user, "<span class='notice'>There's no holochip to remove from the [src]</span>")
			return
		holochip.deactivate_holomap()
		holochip.remove_action(user)
		holochip.holder = null
		if(!user.put_in_hands(holochip))
			holochip.forceMove(get_turf(src))
		holochip = null
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You remove the [holochip] from the [src]</span>")

	if(!issignaler(I)) //Eh, but we don't want people making secbots out of space helmets.
		return ..()

	var/obj/item/device/assembly/signaler/S = I
	if(!S.secured)
		to_chat(user, "<span class='notice'>The signaler not secured.</span>")
		return ..()

	var/obj/item/weapon/secbot_assembly/A = new /obj/item/weapon/secbot_assembly
	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>You add \the [I] to the helmet.</span>")
	qdel(I)
	qdel(src)

/obj/item/clothing/head/helmet/psyamp
	name = "psychic amplifier"
	desc = "A crown-of-thorns psychic amplifier. Kind of looks like a tiara having sex with an industrial robot."
	icon_state = "amp"
	item_state = "amp"
	flags_inv = 0
	armor = list(melee = 30, bullet = 30, laser = 30,energy = 30, bomb = 0, bio = 100, rad = 100)

/obj/item/clothing/head/helmet/warden
	name = "warden's helmet"
	desc = "It's a special helmet issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "helmet_warden"

/obj/item/clothing/head/helmet/HoS
	name = "head of security's hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoshat"
	item_state = "hoshat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEEARS
	body_parts_covered = 0
	siemens_coefficient = 0.8
	force = 0
	hitsound = list()

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.3
	var/up = 0
	item_action_types = list(/datum/action/item_action/hands_free/adjust_helmet_visor)

/datum/action/item_action/hands_free/adjust_helmet_visor
	name = "Adjust helmet visor"

/obj/item/clothing/head/helmet/riot/attack_self()
	toggle()

/obj/item/clothing/head/helmet/riot/verb/toggle()
	set category = "Object"
	set name = "Adjust helmet visor"
	set src in usr

	if(!usr.incapacitated())
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
		update_inv_mob() //so our mob-overlays update
		update_item_actions()

/obj/item/clothing/head/helmet/bulletproof
	name = "bulletproof helmet"
	desc = "A bulletproof security helmet that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "bulletproof"
	armor = list(melee = 10, bullet = 80, laser = 20,energy = 20, bomb = 35, bio = 0, rad = 0)
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH	// cause sprite has a drawn mask

/obj/item/clothing/head/helmet/laserproof
	name = "ablative helmet"
	desc = "A ablative security helmet that excels in protecting the wearer against energy and laser projectiles."
	icon_state = "laserproof"
	armor = list(melee = 10, bullet = 10, laser = 65,energy = 75, bomb = 0, bio = 0, rad = 0)
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH	// cause sprite has a drawn mask
	siemens_coefficient = 0
	var/hit_reflect_chance = 40

/obj/item/clothing/head/helmet/laserproof/IsReflect(def_zone)
	if(prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/head/helmet/swat
	name = "SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	item_state = "swat"
	armor = list(melee = 80, bullet = 75, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.3
	flash_protection = FLASHES_FULL_PROTECTION
	flash_protection_slots = list(SLOT_HEAD)

/obj/item/clothing/head/helmet/thunderdome
	name = "thunderdome helmet"
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

/obj/item/clothing/head/helmet/tactical/marinad
	name = "marine helmet"
	desc = "Spectrum alloy helmet. Lightweight and ready for action."
	icon_state = "marinad"
	item_state = "marinad_helmet"

/obj/item/clothing/head/helmet/tactical/marinad/leader
	name = "marine beret"
	desc = "Sturdy kevlar beret in protective colors, issued to low-ranking NTCM officers."
	icon_state = "beret_marinad"

/obj/item/clothing/head/helmet/helmet_of_justice
	name = "helmet of justice"
	desc = "Prepare for Justice!"
	icon_state = "shitcuritron_0"
	item_state = "helmet"
	var/on = 0
	item_action_types = list(/datum/action/item_action/hands_free/toggle_helmet)

/datum/action/item_action/hands_free/toggle_helmet
	name = "Toggle Helmet"

/obj/item/clothing/head/helmet/helmet_of_justice/attack_self(mob/user)
	on = !on
	icon_state = "shitcuritron_[on]"
	update_inv_mob()
	update_item_actions()

/obj/item/clothing/head/helmet/warden/blue
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force. Protects the head from impacts."
	icon_state = "policehelm"
	item_state = "helmet"
	force = 0
	hitsound = list()

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/M89_Helmet
	name = "M89 Helmet"
	desc = "Combat helmet used by the private security corporation."
	icon_state = "m89_helmet"
	item_state = "helmet"

/obj/item/clothing/head/helmet/M35_Helmet
	name = "M35 Helmet"
	desc = "The Basic werhmacht army helmet."
	icon_state = "M35_Helmet"
	item_state = "helmet"

/obj/item/clothing/head/helmet/syndilight
	name = "light helmet"
	desc = "Light and far less armored than it's assault counterpart, this helmet is used by stealthy operators."
	icon_state = "lighthelmet"
	item_state = "lighthelmet"
	armor = list(melee = 50, bullet = 60, laser = 45,energy = 50, bomb = 35, bio = 0, rad = 50)
	siemens_coefficient = 0.2

/obj/item/clothing/head/helmet/syndiassault
	name = "assault helmet"
	desc = "Stylish black and red helmet with armored protective visor."
	icon_state = "assaulthelmet_b"
	item_state = "assaulthelmet_b"
	armor = list(melee = 80, bullet = 70, laser = 55, energy = 70, bomb = 50, bio = 0, rad = 50)
	siemens_coefficient = 0.2
	flash_protection = FLASHES_FULL_PROTECTION
	flash_protection_slots = list(SLOT_HEAD)

/obj/item/clothing/head/helmet/syndiassault/atom_init()
	. = ..()
	holochip = new /obj/item/holochip/nuclear(src)
	holochip.holder = src

/obj/item/clothing/head/helmet/syndiassault/alternate
	icon_state = "assaulthelmet"
	item_state = "assaulthelmet"

/obj/item/clothing/head/helmet/crusader
	name = "crusader topfhelm"
	desc = "They may call you a buckethead but who'll laugh when crusade begins?"
	icon_state = "crusader"
	armor = list(melee = 50, bullet = 30, laser = 20, energy = 20, bomb = 20, bio = 0, rad = 10)
	siemens_coefficient = 1.2
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

/obj/item/clothing/head/helmet/police
	name = "police helmet"
	desc = "Latest fashion of law enforcement organizations. It's big. Like, really big."
	icon_state = "police_helmet"
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

/obj/item/clothing/head/helmet/police/heavy
	name = "heavy police helmet"
	desc = "Latest fashion of law enforcement organizations. It's big. Like, really big. Golden marks on this helmet denote the higher rank of it's wearer."
	icon_state = "police_helmet_heavy"
	armor = list(melee = 55, bullet = 50, laser = 45,energy = 25, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/laserproof/police
	name = "inspector helmet"
	desc = "An experimental helmet that is able to reflect laser projectiles via psionic manipulations with wearer's mind or something. It's also slightly bigger than other police helmets, since big brain and all."
	icon_state = "police_helmet_inspector"
	armor = list(melee = 35, bullet = 35, laser = 65,energy = 75, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/head/helmet/police/elite
	name = "elite police helmet"
	desc = "This is a heavily armored police helmet. The most blockiest of them all."
	icon_state = "police_helmet_elite"
	armor = list(melee = 60, bullet = 65, laser = 55, energy = 60, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/surplus
	name = "surplus helmet"
	desc = "A simple steel helmet - a steelpot, if you will."
	icon_state = "surplus_helmet"
	armor = list(melee = 45, bullet = 40, laser = 40,energy = 25, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/blueshield
	name = "blueshield helmet"
	desc = "An advanced helmet issued to blueshield officers."
	icon_state = "blueshield_helmet"
	armor = list(melee = 60, bullet = 55, laser = 50,energy = 35, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/durathread
	name = "durathread helmet"
	desc = "A helmet crafted from a bunch of metal, durathread, and God's help."
	icon_state = "Durahelmet"
	item_state = "Durahelmet"
	armor = list(melee = 45, bullet = 15, laser = 50, energy = 35, bomb = 0, bio = 0, rad = 0)

	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
