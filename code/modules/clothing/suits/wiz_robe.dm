/obj/item/clothing/head/wizard
	name = "wizard hat"
	desc = "Strange-looking hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizard"
	//Not given any special protective value since the magic robes are full-body protection --NEO
	siemens_coefficient = 0.4
	body_parts_covered = 0

/obj/item/clothing/head/wizard/atom_init(mapload, ...)
	. = ..()
	AddComponent(/datum/component/magic_item/wizard)

/obj/item/clothing/head/wizard/santa
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags = HEADCOVERSEYES | BLOCKHAIR
	body_parts_covered = HEAD

/obj/item/clothing/head/wizard/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	flags_inv = HIDEEARS
	icon_state = "ushanka_black_brown-down"
	var/ushanka_state = "ushanka_black_brown"
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/wizard/ushanka/atom_init()
	. = ..()
	icon_state = "[ushanka_state]-down"
	item_state = "[ushanka_state]-down"

/obj/item/clothing/head/wizard/ushanka/attack_self(mob/user)
	if(flags_inv & HIDEEARS)
		icon_state = "[ushanka_state]-up"
		item_state = "[ushanka_state]-up"
		flags_inv &= ~HIDEEARS
		to_chat(user, "You raise the ear flaps on the ushanka.")
	else
		icon_state = "[ushanka_state]-down"
		item_state = "[ushanka_state]-down"
		flags_inv |= HIDEEARS
		to_chat(user, "You lower the ear flaps on the ushanka.")

/obj/item/clothing/head/wizard/ushanka/black
	ushanka_state = "ushanka_black"
	icon_state = "ushanka_black-down"

/obj/item/clothing/head/wizard/ushanka/brown
	ushanka_state = "ushanka_brown_brown"
	icon_state = "ushanka_brown_brown-down"

/obj/item/clothing/head/wizard/ushanka/black_white
	ushanka_state = "ushanka_black_white"
	icon_state = "ushanka_black_white-down"

/obj/item/clothing/head/wizard/ushanka/brown_white
	ushanka_state = "ushanka_brown_white"
	icon_state = "ushanka_brown_white-down"

/obj/item/clothing/head/wizard/red
	name = "red wizard hat"
	desc = "Strange-looking, red, hat-wear that most certainly belongs to a real magic user."
	icon_state = "redwizard"

/obj/item/clothing/head/wizard/fake
	name = "wizard hat"
	desc = "It has WIZZARD written across it in sequins. Comes with a cool beard."
	icon_state = "wizard-fake"
	body_parts_covered = HEAD|FACE

/obj/item/clothing/head/wizard/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"

/obj/item/clothing/head/wizard/crusader
	name = "crusader topfhelm"
	desc = "They may call you a buckethead but who'll laugh when crusade begins?"
	icon_state = "crusader"
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

/obj/item/clothing/head/wizard/black_hood
	name = "black hood"
	desc = "It's hood that covers the head."
	icon_state = "necromancer"
	item_state = "necromancer"
	flags = HEADCOVERSEYES|BLOCKHAIR

/obj/item/clothing/head/wizard/nimb
	name = "Nimb"
	desc = "Just a Nimb"
	icon_state = "wizard_nimb"

/obj/item/clothing/head/wizard/cowboy
	name = "cowboy hat"
	icon_state = "cowboy_hat"
	item_state = "cowboy_hat"
	desc = "Howdy, partner!"

/obj/item/clothing/head/wizard/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	item_state = "bearpelt"
	flags = BLOCKHAIR

/obj/item/clothing/head/wizard/gnome_hat
	name = "gnome hat"
	desc = "A pointy red hat."
	icon_state = "gnome_hat"

/obj/item/clothing/head/wizard/marisa
	name = "witch hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"

/obj/item/clothing/head/wizard/magus
	name = "magus helm"
	desc = "A mysterious helmet that hums with an unearthly power."
	icon_state = "magus"
	item_state = "magus"
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/head/wizard/amp
	name = "psychic amplifier"
	desc = "A crown-of-thorns psychic amplifier. Kind of looks like a tiara having sex with an industrial robot."
	icon_state = "amp"

/obj/item/clothing/head/wizard/amp/shielded
	name = "tiara of protection"
	desc = "A crown-of-thorns psychic amplifier. Kind of looks like a tiara having sex with an industrial robot. This one emanates protection aura."

/obj/item/clothing/head/wizard/amp/shielded/atom_init()
	. = ..()

	var/obj/effect/effect/forcefield/F = new
	AddComponent(/datum/component/forcefield, "wizard field", 20, 3 SECONDS, 5 SECONDS, F, TRUE, TRUE)

/obj/item/clothing/head/wizard/amp/shielded/proc/activate(mob/living/user)
	if(iswizard(user) || iswizardapprentice(user))
		SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, user)

/obj/item/clothing/head/wizard/amp/shielded/proc/deactivate(mob/living/user)
	SEND_SIGNAL(src, COMSIG_FORCEFIELD_UNPROTECT, user)

/obj/item/clothing/head/wizard/amp/shielded/equipped(mob/living/user, slot)
	. = ..()

	if(slot == SLOT_HEAD)
		activate(user)

/obj/item/clothing/head/wizard/amp/shielded/dropped(mob/living/user)
	. = ..()
	if(slot_equipped == SLOT_HEAD)
		deactivate(user)

/obj/item/clothing/head/wizard/cap
	name = "gentlemans cap"
	desc = "A checkered gray flat cap woven together with the rarest of threads."
	icon_state = "gentcap"

/obj/item/clothing/head/wizard/redhood
	name = "wizard hood"
	desc = "A strange red gem-lined hoodie"
	icon_state = "wiz_red_hood"

/obj/item/clothing/head/wizard/bluehood
	name = "wizard hood"
	desc = "A strange blue gem-lined hoodie."
	icon_state = "wiz_blue_hood"

/obj/item/clothing/suit/wizrobe
	name = "wizard robe"
	desc = "A magnificant, gem-lined robe that seems to radiate power."
	icon_state = "wizard"
	item_state = "wizrobe"
	gas_transfer_coefficient = 0.01 // IT'S MAGICAL OKAY JEEZ +1 TO NOT DIE
	permeability_coefficient = 0.01
	armor = list(melee = 30, bullet = 10, laser = 10,energy = 20, bomb = 20, bio = 20, rad = 20)
	allowed = list(/obj/item/weapon/teleportation_scroll)
	siemens_coefficient = 0.4
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/wizrobe/atom_init(mapload, ...)
	. = ..()
	AddComponent(/datum/component/magic_item/wizard)

/obj/item/clothing/suit/wizrobe/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"

/obj/item/clothing/suit/wizrobe/wiz_blue
	name = "blue jacket"
	desc = "A stylish gem-lined jacket straight from deep space."
	icon_state = "mage_jacket_blue"
	item_state = "mage_jacket_blue"

/obj/item/clothing/suit/wizrobe/wiz_red
	name = "red jacket"
	desc = "A stylish gem-lined jacket straight from deep space."
	icon_state = "mage_jacket_red"
	item_state = "mage_jacket_red"

/obj/item/clothing/suit/wizrobe/red
	name = "red wizard robe"
	desc = "A magnificant, red, gem-lined robe that seems to radiate power."
	icon_state = "redwizard"
	item_state = "redwizrobe"

/obj/item/clothing/suit/wizrobe/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/wizrobe/crusader
	name = "crusader tabard"
	desc = "It's a chainmail with some cloth draped over. Non nobis domini and stuff."
	icon_state = "crusader"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(/obj/item/weapon/claymore,/obj/item/weapon/shield/riot/roman)

/obj/item/clothing/suit/wizrobe/necromancer_hoodie
	name = "necromancer hoodie"
	desc = "This suit says to you 'hush'!"
	icon_state = "necromancer"
	item_state = "necromancer"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/wizrobe/holidaypriest
	name = "holiday priest"
	desc = "This is a nice holiday my son."
	icon_state = "holidaypriest"
	item_state = "holidaypriest"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/wizrobe/serifcoat
	name = "serif coat"
	desc = "A old coat"
	icon_state = "serif_coat"
	item_state = "det_suit"

/obj/item/clothing/suit/wizrobe/suspenders
	name = "suspenders"
	desc = "Bright red suspenders."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	blood_overlay_type = "armor"
	body_parts_covered = 0

/obj/item/clothing/suit/wizrobe/marisa
	name = "witch robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"

/obj/item/clothing/suit/wizrobe/magusblue
	name = "magus robe"
	desc = "A set of armoured robes that seem to radiate a dark power."
	icon_state = "magusblue"
	item_state = "magusblue"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/wizrobe/magusred
	name = "magus robe"
	desc = "A set of armoured robes that seem to radiate a dark power."
	icon_state = "magusred"
	item_state = "magusred"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/wizrobe/psypurple
	name = "purple robes"
	desc = "Heavy, royal purple robes threaded with psychic amplifiers and weird, bulbous lenses. Do not machine wash."
	icon_state = "psyamp"
	item_state = "psyamp"
	allowed = list(/obj/item/weapon/scythe)

/obj/item/clothing/suit/wizrobe/gentlecoat
	name = "gentlemans coat"
	desc = "A heavy threaded twead gray jacket. For a different sort of Gentleman."
	icon_state = "gentlecoat"
	item_state = "gentlecoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/suit/wizrobe/fake
	name = "wizard robe"
	desc = "A rather dull, blue robe meant to mimick real wizard robes."
	icon_state = "wizard-fake"
	item_state = "wizrobe"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/wizard/marisa/fake
	name = "witch hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/wizrobe/marisa/fake
	name = "witch robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
