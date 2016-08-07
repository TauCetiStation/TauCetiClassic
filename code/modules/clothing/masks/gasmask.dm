/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air."
	icon = 'tauceti/items/clothing/masks/gas_tc.dmi'
	tc_custom = 'tauceti/items/clothing/masks/gas_tc.dmi'
	icon_state = "gas_mask_tc"
	flags = FPRINT | TABLEPASS | MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	body_parts_covered = FACE|EYES
	w_class = 3.0
	item_state = "gas_mask_tc"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	var/gas_filter_strength = 1			//For gas mask filters

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "welding mask"
	desc = "A gas mask with built-in welding goggles and a face shield. Looks like a skull - clearly designed by a nerd."
	icon = 'tauceti/items/clothing/masks/gas_tc.dmi'
	tc_custom = 'tauceti/items/clothing/masks/gas_tc.dmi'
	icon_state = "weldingmask"
	item_state = "weldingmask"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	origin_tech = "materials=2;engineering=2"
	action_button_name = "Toggle Welding Mask"
	siemens_coefficient = 0.9
	body_parts_covered = FACE|EYES
	w_class = 3
	var/up = 0

/obj/item/clothing/mask/gas/welding/attack_self()
	toggle()

/obj/item/clothing/mask/gas/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	set src in usr

	if(usr.canmove && !usr.stat && !usr.restrained())
		if(src.up)
			src.up = !src.up
			src.flags |= (HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv |= (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			body_parts_covered |= EYES
			icon_state = initial(icon_state)
			usr << "You adjust \the [src] down to protect your eyes."
		else
			src.up = !src.up
			src.flags &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv &= ~(HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			body_parts_covered &= ~EYES
			icon_state = "[initial(icon_state)]up"
			usr << "You push \the [src] up out of your face."

		usr.update_inv_wear_mask()

// ********************************************************************

//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out phoron but it can also be connected to an air supply."
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list(melee = 0, bullet = 0, laser = 2,energy = 2, bomb = 0, bio = 75, rad = 0)
	body_parts_covered = HEAD|FACE

/obj/item/clothing/mask/gas/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	icon_state = "swat"
	siemens_coefficient = 0.7
	body_parts_covered = FACE|EYES

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	icon_state = "swat"
	siemens_coefficient = 0.7

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	//desc = "A face-covering mask that can be connected to an air supply. It seems to house some odd electronics."
	var/mode = 0// 0==Scouter | 1==Night Vision | 2==Thermal | 3==Meson
	var/voice = "Unknown"
	var/vchange = 0//This didn't do anything before. It now checks if the mask has special functions/N
	origin_tech = "syndicate=4"

/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	vchange = 1
	siemens_coefficient = 0.2

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	icon_state = "clown"
	item_state = "clown_hat"

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	icon_state = "sexyclown"
	item_state = "sexyclown"

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	icon_state = "mime"
	item_state = "mime"

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	icon_state = "monkeymask"
	item_state = "monkeymask"
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	icon_state = "sexymime"
	item_state = "sexymime"

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"
	siemens_coefficient = 0.2

/obj/item/clothing/mask/gas/cyborg
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	name = "cyborg visor"
	desc = "Beep boop."
	icon_state = "death"

/obj/item/clothing/mask/gas/owl_mask
	icon = 'icons/obj/clothing/masks.dmi'
	tc_custom = null
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"

/obj/item/clothing/mask/gas/sechailer/wj
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device, plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you taze them. Do not tamper with the device."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "wjsec"
	tc_custom = null

/obj/item/clothing/mask/gas/sechailer/tactifool
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device, plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you taze them. Do not tamper with the device."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "hailer"
	tc_custom = null
	flags = FPRINT | TABLEPASS | MASKCOVERSMOUTH | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS