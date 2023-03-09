/obj/item/clothing/head/beret
	name = "beret"
	icon_state = "" // so we can spot it as a broken item if we see it ingame
	desc = "A beret, an artists favorite headwear."
	siemens_coefficient = 0.9
	body_parts_covered = 0

/obj/item/clothing/head/beret/red
	name = "red beret"
	desc = "Bonjour, but in red. Smells like baguette, pardon my French."
	icon_state = "beret_red"

/obj/item/clothing/head/beret/blue
	name = "blue beret"
	desc = "Bonjour, but in blue. Smells like baguette, pardon my French."
	icon_state = "beret_blue"

/obj/item/clothing/head/beret/black
	name = "black beret"
	desc = "Bonjour, but in black. Smells like baguette, pardon my French."
	icon_state = "beret_black"

/obj/item/clothing/head/beret/purple
	name = "purple beret"
	desc = "Bonjour, but in purple. Smells like baguette, pardon my French."
	icon_state = "beret_purple"

/obj/item/clothing/head/beret/centcomofficer
	name = "officers beret"
	desc = "A black beret adorned with the shield silver kite shield with an engraved sword of the NanoTrasen security forces, announcing to the world that the wearer is a defender of NanoTrasen."
	icon_state = "centcomofficerberet"

/obj/item/clothing/head/beret/centcomcaptain
	name = "captains beret"
	desc = "A white beret adorned with the shield cobalt kite shield with an engraved sword of the NanoTrasen security forces, worn only by those captaining a vessel of the NanoTrasen Navy."
	icon_state = "centcomcaptain"

/obj/item/clothing/head/beret/rosa
	name = "white beret"
	icon_state = "rosas_hat"
	item_state = "helmet"

// Security

/obj/item/clothing/head/beret/sec
	name = "officer's beret"
	desc = "A beret with the security insignia emblazoned on it. For officers that are more inclined towards style than safety."
	icon_state = "beret_badge"

/obj/item/clothing/head/sec_peakedcap
	name = "officer's peaked cap"
	desc = "A peaked cap with the security insignia emblazoned on it. For officers that are really miss the army."
	icon_state = "sec_peakedcap"
	item_state = "sec_peakedcap"
	w_class = SIZE_TINY
	siemens_coefficient = 0.9
	body_parts_covered = 0

/obj/item/clothing/head/beret/sec/warden
	name = "warden's beret"
	desc = "A beret with the copper security insignia emblazoned on it. For wardens that are more inclined towards style than safety."
	icon_state = "beret_warden"

/obj/item/clothing/head/beret/sec/hos
	name = "head of security's beret"
	desc = "A beret with the gold security insignia emblazoned on it. Shows who has the longest baton on the station. Also has some space for special armor plate."
	icon_state = "beret_hos"
	valid_accessory_slots = list("dermal")
	restricted_accessory_slots = list("dermal")

// Engineering

/obj/item/clothing/head/beret/eng
	name = "engineering beret"
	desc = "A beret with the engineering insignia emblazoned on it. For engineers that are more inclined towards style than safety."
	icon_state = "e_beret_badge"

//Medical


/obj/item/clothing/head/beret/paramed
	name = "first responder beret"
	desc = "A beret with the medical insignia emblazoned on it. Noticable beret for paramedics, shows who's saving lives here."
	icon_state = "beret_fr"

/obj/item/clothing/head/beret/blueshield
	name = "blueshield officer's beret"
	desc = "A beret with the blueshield insignia emblazoned on it. It is advised that blueshield officers do NOT wear non-armored headwear during their shift."
	icon_state = "beret_blueshield"
