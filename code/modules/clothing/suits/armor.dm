/obj/item/clothing/suit/armor
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/clothing/head/helmet)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4

/obj/item/clothing/suit/armor/vest
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(melee = 50, bullet = 45, laser = 40, energy = 25, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/vest/security
	name = "security armor"
	desc = "An armored vest that protects against some damage. This one has NanoTrasen corporate badge."
	icon_state = "armorsec"
	item_state = "armor"

/obj/item/clothing/suit/armor/vest/fullbody
	name = "fullbody armor"
	desc = "A set of armor covering the entire body. Primarily used by various law-enforcements across the galaxy."
	icon_state = "armor_fullbody"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/armor/vest/fullbody/psy_robe
	name = "purple robes"
	desc = "Heavy, royal purple robes threaded with psychic amplifiers and weird, bulbous lenses. Do not machine wash."
	icon_state = "psyamp"
	item_state = "psyamp"
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 0, bio = 100, rad = 100)

/obj/item/clothing/suit/storage/flak
	name = "security armor"
	desc = "An armored vest that protects against some damage. This one has four pockets for storage."
	icon_state = "armorsec"
	item_state = "armor"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/clothing/head/helmet)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4
	armor = list(melee = 50, bullet = 45, laser = 40, energy = 25, bomb = 35, bio = 0, rad = 0)
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/suit/storage/flak/atom_init()
	. = ..()
	pockets = new/obj/item/weapon/storage/internal(src)
	pockets.set_slots(slots = 4, slot_size = SIZE_TINY)

/obj/item/clothing/suit/storage/flak/police
	name = "police armor"
	desc = "An armored vest that protects against some damage. This one has four pockets for storage and a custom paintjob in colors of OCD."
	icon_state = "police_armor"
	flags = HEAR_TALK

/obj/item/clothing/suit/storage/flak/police/fullbody
	name = "police fullbody armor"
	desc = "A set of armor covering the entire body. This variant is used by OCD and is painted accordingly."
	icon_state = "police_armor_fullbody"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/storage/flak/police/fullbody/heavy
	name = "heavy fullbody armor"
	desc = "A set of armor used by special weapons and tactics units of OCD. Justice will be served."
	icon_state = "police_armor_heavy"
	slowdown = 0.2
	armor = list(melee = 60, bullet = 65, laser = 55, energy = 60, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/suit/marinad
	name = "marine armor"
	desc = "This thing will protect you from any angry flora or fauna."
	icon_state = "marinad"
	item_state = "marinad_armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	slowdown = 0.5
	armor = list(melee = 60, bullet = 65, laser = 55, energy = 60, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/vest/warden
	name = "Warden's jacket"
	desc = "An armoured jacket with gold rank pips and livery."
	icon_state = "warden_jacket"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/suit/storage/flak/warden
	name = "Warden's jacket"
	desc = "An armoured jacket with gold rank pips and livery."
	icon_state = "warden_jacket"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	flags = null

/obj/item/clothing/suit/armor/vest/leather
	name = "security overcoat"
	desc = "Lightly armored leather overcoat meant as casual wear for high-ranking officers. Bears the crest of Nanotrasen Security."
	icon_state = "leather_overcoat-sec"
	item_state = "hostrench"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "A greatcoat enhanced with a special alloy for some protection and style."
	icon_state = "hos"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 80, bullet = 60, laser = 55, energy = 35, bomb = 50, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0.6

/obj/item/clothing/suit/armor/riot
	name = "riot suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 80, bullet = 10, laser = 25, energy = 20, bomb = 35, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/armor/bulletproof
	name = "bulletproof fullbody armor"
	desc = "A set of armor covering the entire body that excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "bulletproof_fullbody"
	item_state = "bulletproof_fullbody"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 10, bullet = 80, laser = 20, energy = 20, bomb = 35, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/storage/flak/bulletproof
	name = "bulletproof fullbody armor"
	desc = "A set of armor covering the entire body that excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "bulletproof_fullbody"
	item_state = "bulletproof_fullbody"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 10, bullet = 80, laser = 20, energy = 20, bomb = 35, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	flags = HEAR_TALK

/obj/item/clothing/suit/storage/flak/bulletproof/atom_init()
	. = ..()
	pockets = new/obj/item/weapon/storage/internal(src)
	pockets.set_slots(slots = 5, slot_size = SIZE_TINY)

/obj/item/clothing/suit/armor/laserproof
	name = "ablative fullbody armor"
	desc = "A set of armor covering the entire body that excels in protecting the wearer against energy projectiles."
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 10, bullet = 10, laser = 65, energy = 75, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0
	var/hit_reflect_chance = 40

/obj/item/clothing/suit/armor/laserproof/IsReflect(def_zone)
	if(!(def_zone in list(BP_CHEST , BP_GROIN))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return 0
	if (prob(hit_reflect_chance))
		return 1

/obj/item/clothing/suit/armor/laserproof/police
	name = "police ablative armor"
	desc = "An experimental model of ablative armor issued in limited numbers to special units of OCD. This set of armor protects not only against lasers but is also sturdy enough to withstand other damage types."
	icon_state = "police_armor_inspector"
	armor = list(melee = 35, bullet = 35, laser = 65, energy = 75, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/swat
	name = "swat suit"
	desc = "A heavily armored suit that protects against moderate damage. Used in special operations."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	slowdown = 0.2
	armor = list(melee = 80, bullet = 70, laser = 70,energy = 70, bomb = 70, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/clothing/head/helmet, /obj/item/weapon/tank)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	flags_pressure = STOPS_LOWPRESSUREDMAGE

/obj/item/clothing/suit/armor/swat/officer
	name = "officer jacket"
	desc = "An armored jacket used in special operations."
	icon_state = "detective_trenchcoat_brown"
	item_state = "detective_trenchcoat_brown"
	blood_overlay_type = "coat"
	flags_inv = 0
	body_parts_covered = UPPER_TORSO|ARMS
	pierce_protection = UPPER_TORSO|ARMS

/obj/item/clothing/suit/armor/det_suit
	name = "armor"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	flags = ONESIZEFITSALL
	armor = list(melee = 50, bullet = 55, laser = 25, energy = 20, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/flak/blueshield
	name = "blueshield armor vest"
	desc = "It's heavy and somehow... comfortable?"
	icon_state = "blueshield"
	item_state = "armor"
	armor = list(melee = 60, bullet = 55, laser = 50, energy = 35, bomb = 35, bio = 0, rad = 0)
	flags = ONESIZEFITSALL

//Reactive armor
//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive
	name = "reactive teleport armor"
	desc = "Someone seperated our Research Director from his own head!"
	var/active = 0.0
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	blood_overlay_type = "armor"
	slowdown = 0.5
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/reactive/Get_shield_chance()
	if(active)
		return 35
	return 0

/obj/item/clothing/suit/armor/reactive/attack_self(mob/user)
	src.active = !( src.active )
	if (src.active)
		to_chat(user, "<span class='notice'>The reactive armor is now active.</span>")
		src.icon_state = "reactive"
		src.item_state = "reactive"
	else
		to_chat(user, "<span class='notice'>The reactive armor is now inactive.</span>")
		src.icon_state = "reactiveoff"
		src.item_state = "reactiveoff"
		add_fingerprint(user)
	return

/obj/item/clothing/suit/armor/reactive/emp_act(severity)
	active = 0
	src.icon_state = "reactiveoff"
	src.item_state = "reactiveoff"
	..()


//All of the armor below is mostly unused


/obj/item/clothing/suit/armor/centcomm
	name = "Cent. Com. armor"
	desc = "A suit that protects against some damage."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = SIZE_NORMAL//bulky item
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	w_class = SIZE_NORMAL//bulky item
	gas_transfer_coefficient = 0.90
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	slowdown = 1.5
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/tdome
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/armor/tdome/red
	name = "thunderdome suit (red)"
	desc = "Reddish armor."
	icon_state = "tdred"
	item_state = "tdred"
	siemens_coefficient = 1

/obj/item/clothing/suit/armor/tdome/green
	name = "thunderdome suit (green)"
	desc = "Pukish armor."
	icon_state = "tdgreen"
	item_state = "tdgreen"
	siemens_coefficient = 1

/obj/item/clothing/suit/armor/tactical
	name = "tactical armor"
	desc = "A suit of armor most often used by Special Weapons and Tactics squads. Includes padded vest with pockets along with shoulder and kneeguards."
	icon_state = "swatarmor"
	item_state = "armor"
	var/obj/item/weapon/gun/holstered = null
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	slowdown = 0.5
	armor = list(melee = 60, bullet = 65, laser = 50, energy = 60, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/tactical/verb/holster()
	set name = "Holster"
	set category = "Object"
	set src in usr
	if(!isliving(usr)) return
	if(usr.incapacitated())
		return

	if(!holstered)
		var/obj/item/I = usr.get_active_hand()
		if(!istype(I, /obj/item/weapon/gun) && !I.can_be_holstered)
			to_chat(usr, "<span class='notice'>You need your gun equiped to holster it.</span>")
			return
		if(!I.can_be_holstered)
			to_chat(usr, "<span class='warning'>This gun won't fit in \the belt!</span>")
			return
		holstered = usr.get_active_hand()
		usr.drop_from_inventory(holstered, src)
		usr.visible_message("<span class='notice'>\The [usr] holsters \the [holstered].</span>", "You holster \the [holstered].")
	else
		if(istype(usr.get_active_hand(),/obj) && istype(usr.get_inactive_hand(),/obj))
			to_chat(usr, "<span class='warning'>You need an empty hand to draw the gun!</span>")
		else
			if(usr.a_intent == INTENT_HARM)
				usr.visible_message("<span class='warning'>\The [usr] draws \the [holstered], ready to shoot!</span>", \
				"<span class='warning'>You draw \the [holstered], ready to shoot!</span>")
			else
				usr.visible_message("<span class='notice'>\The [usr] draws \the [holstered], pointing it at the ground.</span>", \
				"<span class='notice'>You draw \the [holstered], pointing it at the ground.</span>")
			usr.put_in_hands(holstered)
		holstered = null

/obj/item/clothing/suit/armor/syndiassault
	name = "assault armor"
	desc = "Heavy armored suit designed to endure all types of damage, from punches to heavy lasers."
	icon_state = "assaultarmor"
	item_state = "assaultarmor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 80, bullet = 70, laser = 55, energy = 70, bomb = 50, bio = 0, rad = 50)
	siemens_coefficient = 0.2
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/armor/syndilight
	name = "recon armor"
	desc = "Light-weight armored vest designed for scouting and recon missions. Provides solid protection, despite all the lightness. Now in fullbody format!"
	icon_state = "lightarmor"
	item_state = "lightarmor"
	armor = list(melee = 50, bullet = 40, laser = 40, energy = 70, bomb = 50, bio = 0, rad = 50)
	siemens_coefficient = 0.2
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/armor/m66_kevlarvest
	name = "M66 Tactical Vest"
	desc = "Black tactical kevlar vest, used by private security coropation. So tactics."
	icon_state = "M66_KevlarVest"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(melee = 60, bullet = 80, laser = 40, energy = 50, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/armor/crusader
	name = "crusader tabard"
	desc = "It's a chainmail with some cloth draped over. Non nobis domini and stuff."
	icon_state = "crusader"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 50, bullet = 30, laser = 20, energy = 20, bomb = 25, bio = 0, rad = 10)
	siemens_coefficient = 1.2

/obj/item/clothing/suit/armor/vest/surplus
	name = "surplus armor vest"
	desc = "An armored vest with outdated armor plates, no longer used by galactic militaries. At least it's cheap."
	icon_state = "armor_surplus_1"
	armor = list(melee = 45, bullet = 40, laser = 40, energy = 25, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/vest/surplus/atom_init()
	. = ..()
	icon_state = "surplus_armor_[rand(1,2)]"

/obj/item/clothing/suit/armor/vest/durathread
	name = "durathread vest"
	desc = "A vest made of durathread and a bunch of rags, tied with wires."
	icon_state = "Duraarmor"
	item_state = "Duraarmor"
	armor = list(melee = 45, bullet = 15, laser = 50, energy = 35, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/duracoat
	name = "durathread coat"
	desc = "A coat made from durathread, looks stylish."
	icon_state = "Duracoat"
	item_state = "Duracoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	armor = list(melee = 40, bullet = 5, laser = 40, energy = 25, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0.4
