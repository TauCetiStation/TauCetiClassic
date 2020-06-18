/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_mask_tc"
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	body_parts_covered = FACE|EYES
	w_class = ITEM_SIZE_NORMAL
	item_state = "gas_mask_tc"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	var/gas_filter_strength = 1			//For gas mask filters
	var/filter = list("phoron", "sleeping_agent")

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "welding mask"
	desc = "A gas mask with built-in welding goggles and a face shield. Looks like a skull - clearly designed by a nerd."
	icon_state = "weldingmask"
	item_state = "weldingmask"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	origin_tech = "materials=2;engineering=2"
	action_button_name = "Toggle Welding Mask"
	siemens_coefficient = 0.9
	body_parts_covered = FACE|EYES
	w_class = ITEM_SIZE_NORMAL
	var/up = 0

/obj/item/clothing/mask/gas/welding/attack_self()
	toggle()

/obj/item/clothing/mask/gas/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	set src in usr

	if(!usr.incapacitated())
		if(src.up)
			src.up = !src.up
			src.flags |= (HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv |= (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			body_parts_covered |= EYES
			icon_state = initial(icon_state)
			to_chat(usr, "You adjust \the [src] down to protect your eyes.")
		else
			src.up = !src.up
			src.flags &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv &= ~(HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			body_parts_covered &= ~EYES
			icon_state = "[initial(icon_state)]up"
			to_chat(usr, "You push \the [src] up out of your face.")

		usr.update_inv_wear_mask()

// ********************************************************************

// **** Security gas mask (TG-stuff) ****
/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device, plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you taze them. Do not tamper with the device."
	action_button_name = "Toggle Mask"
	icon_state = "secmask"
	var/cooldown = 0
	var/aggressiveness = 2
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS | BLOCKHAIR

/obj/item/clothing/mask/gas/sechailer/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		switch(aggressiveness)
			if(1)
				to_chat(user, "<span class='notice'>You set the restrictor to the middle position.</span>")
				aggressiveness = 2
			if(2)
				to_chat(user, "<span class='notice'>You set the restrictor to the last position.</span>")
				aggressiveness = 3
			if(3)
				to_chat(user, "<span class='notice'>You set the restrictor to the first position.</span>")
				aggressiveness = 1
			if(4)
				to_chat(user, "<span class='warning'>You adjust the restrictor but nothing happens, probably because its broken.</span>")
	else if(iswirecutter(I))
		if(aggressiveness != 4)
			to_chat(user, "<span class='warning'>You broke it!</span>")
			aggressiveness = 4
	else
		return ..()

/obj/item/clothing/mask/gas/sechailer/attack_self()
	halt()

/obj/item/clothing/mask/gas/sechailer/verb/halt()
	set category = "Object"
	set name = "HALT"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.incapacitated())
		return

	var/phrase = 0	//selects which phrase to use
	var/phrase_text = null
	var/phrase_sound = null


	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		switch(aggressiveness)		// checks if the user has unlocked the restricted phrases
			if(1)
				phrase = rand(1,5)	// set the upper limit as the phrase above the first 'bad cop' phrase, the mask will only play 'nice' phrases
			if(2)
				phrase = rand(1,11)	// default setting, set upper limit to last 'bad cop' phrase. Mask will play good cop and bad cop phrases
			if(3)
				phrase = rand(1,18)	// user has unlocked all phrases, set upper limit to last phrase. The mask will play all phrases
			if(4)
				phrase = rand(12,18)	// user has broke the restrictor, it will now only play shitcurity phrases

		switch(phrase)	//sets the properties of the chosen phrase
			if(1)				// good cop
				phrase_text = "HALT! HALT! HALT! HALT!"
				phrase_sound = 'sound/voice/complionator/halt.ogg'
			if(2)
				phrase_text = "Stop in the name of the Law."
				phrase_sound = 'sound/voice/complionator/bobby.ogg'
			if(3)
				phrase_text = "Compliance is in your best interest."
				phrase_sound = 'sound/voice/complionator/compliance.ogg'
			if(4)
				phrase_text = "Prepare for justice!"
				phrase_sound = 'sound/voice/complionator/justice.ogg'
			if(5)
				phrase_text = "Running will only increase your sentence."
				phrase_sound = 'sound/voice/complionator/running.ogg'
			if(6)				// bad cop
				phrase_text = "Don't move, Creep!"
				phrase_sound = 'sound/voice/complionator/dontmove.ogg'
			if(7)
				phrase_text = "Down on the floor, Creep!"
				phrase_sound = "floor"
			if(8)
				phrase_text = "Dead or alive you're coming with me."
				phrase_sound = 'sound/voice/complionator/robocop.ogg'
			if(9)
				phrase_text = "God made today for the crooks we could not catch yesterday."
				phrase_sound = 'sound/voice/complionator/god.ogg'
			if(10)
				phrase_text = "Freeze, Scum Bag!"
				phrase_sound = 'sound/voice/complionator/freeze.ogg'
			if(11)
				phrase_text = "Stop right there, criminal scum!"
				phrase_sound = 'sound/voice/complionator/imperial.ogg'
			if(12)				// LA-PD
				phrase_text = "Stop or I'll bash you."
				phrase_sound = 'sound/voice/complionator/bash.ogg'
			if(13)
				phrase_text = "Go ahead, make my day."
				phrase_sound = 'sound/voice/complionator/harry.ogg'
			if(14)
				phrase_text = "Stop breaking the law, ass hole."
				phrase_sound = 'sound/voice/complionator/asshole.ogg'
			if(15)
				phrase_text = "You have the right to shut the fuck up."
				phrase_sound = 'sound/voice/complionator/stfu.ogg'
			if(16)
				phrase_text = "Shut up crime!"
				phrase_sound = 'sound/voice/complionator/shutup.ogg'
			if(17)
				phrase_text = "Face the wrath of the golden bolt."
				phrase_sound = 'sound/voice/complionator/super.ogg'
			if(18)
				phrase_text = "I am, the LAW!"
				phrase_sound = 'sound/voice/complionator/dredd.ogg'

		usr.visible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[phrase_text]</b></font>")
		playsound(src, phrase_sound, VOL_EFFECTS_MASTER, vary = FALSE)
		cooldown = world.time

//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out phoron but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list(melee = 0, bullet = 0, laser = 2,energy = 2, bomb = 0, bio = 75, rad = 0)
	body_parts_covered = HEAD|FACE

/obj/item/clothing/mask/gas/swat
	name = "SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	siemens_coefficient = 0.7
	body_parts_covered = FACE|EYES

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "mask_syndi"
	item_state = "mask_syndi"
	siemens_coefficient = 0.7

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	icon_state = "gas_mask_orange"
	//desc = "A face-covering mask that can be connected to an air supply. It seems to house some odd electronics."
	var/mode = 0// 0==Scouter | 1==Night Vision | 2==Thermal | 3==Meson
	var/voice = "Unknown"
	var/vchange = 0//This didn't do anything before. It now checks if the mask has special functions/N
	origin_tech = "syndicate=4"

/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	vchange = 1
	siemens_coefficient = 0.2

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"
	flags = MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	icon_state = "sexyclown"
	item_state = "sexyclown"
	flags = MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	flags = MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS

/obj/item/clothing/mask/gas/fawkes //--getup1
	name = "strange mask"
	desc = "Remember, remember, the fifth of November"
	icon_state = "fawkes"

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon_state = "monkeymask"
	item_state = "monkeymask"
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	icon_state = "sexymime"
	flags = MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS

/obj/item/clothing/mask/gas/death_commando
	name = "death commando mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"
	siemens_coefficient = 0.2

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop."
	icon_state = "death"

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"

/obj/item/clothing/mask/gas/coloured
	icon_state = "gas_mask_orange"

/obj/item/clothing/mask/gas/coloured/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "The small label on the back side tells: \"Designed by W&J Company\".")

/obj/item/clothing/mask/gas/coloured/atom_init()
	. = ..()
	var/color = pick("orange", "blue")
	icon_state = "gas_mask_[color]"

/obj/item/clothing/mask/gas/vox
	name = "vox breath mask"
	desc = "A weirdly-shaped breath mask."
	icon_state = "voxmask"
	item_state = "voxmask"
	flags = MASKCOVERSMOUTH | MASKINTERNALS | BLOCK_GAS_SMOKE_EFFECT
	flags_inv = 0
	body_parts_covered = 0
	w_class = ITEM_SIZE_SMALL
	gas_transfer_coefficient = 0.10
	filter = list("phoron", "sleeping_agent", "oxygen")
	species_restricted = list(VOX , VOX_ARMALIS)

/obj/item/clothing/mask/gas/German
	name = "German Gas Mask"
	desc = "Soldier's black gas mask."
	icon_state = "German_gasmask"
	item_color = "German_gasmask"