/*
 * Contains:
 *		Lasertag
 *		Costume
 *		Misc
 */

/*
 * Lasertag
 */
/obj/item/clothing/suit/lasertag
	name = "laser tag armour"
	desc = "Be none's man, shoot everybody!"
	icon_state = "bluetag"
	item_state = "bluetag"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO
	allowed = list(/obj/item/weapon/gun/energy/laser/lasertag)
	siemens_coefficient = 3.0

	var/lasertag_color = "none"

/obj/item/clothing/suit/lasertag/bluetag
	name = "blue laser tag armour"
	desc = "Blue Pride, Station Wide."
	icon_state = "bluetag"
	item_state = "bluetag"
	allowed = list(/obj/item/weapon/gun/energy/laser/lasertag/bluetag)
	lasertag_color = "blue"

/obj/item/clothing/suit/lasertag/redtag
	name = "red laser tag armour"
	desc = "Reputed to go faster."
	icon_state = "redtag"
	item_state = "redtag"
	allowed = list(/obj/item/weapon/gun/energy/laser/lasertag/redtag)
	lasertag_color = "red"

/*
 * Costume
 */
/obj/item/clothing/suit/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	body_parts_covered = UPPER_TORSO|ARMS


/obj/item/clothing/suit/hgpirate
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	item_state = "hgpirate"
	flags_inv = HIDEJUMPSUIT
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS


/obj/item/clothing/suit/cyborg_suit
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	icon_state = "death"
	item_state = "death"
	flags = CONDUCT
	fire_resist = T0C+5200
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/greatcoat
	name = "great coat"
	desc = "A Nazi great coat."
	icon_state = "nazi"
	item_state = "nazi"


/obj/item/clothing/suit/johnny_coat
	name = "johnny~~ coat"
	desc = "Johnny~~"
	icon_state = "johnny"
	item_state = "johnny"


/obj/item/clothing/suit/justice
	name = "justice suit"
	desc = "This pretty much looks ridiculous."
	icon_state = "justice"
	item_state = "justice"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS


/obj/item/clothing/suit/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	item_state = "judge"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/spacecash)
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/suit/wcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "vest"
	item_state = "wcoat"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO


/obj/item/clothing/suit/apron/overalls
	name = "coveralls"
	desc = "A set of denim overalls."
	icon_state = "overalls"
	item_state = "overalls"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS


/obj/item/clothing/suit/syndicatefake
	name = "red space suit replica"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "A plastic replica of the syndicate space suit, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = ITEM_SIZE_NORMAL
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/hastur
	name = "Hastur's Robes"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	item_state = "hastur"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/imperium_monk
	name = "imperium monk"
	desc = "Have YOU killed a xenos today?"
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = HEAD|UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/chickensuit
	name = "chicken suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	item_state = "chickensuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 2.0


/obj/item/clothing/suit/monkeysuit
	name = "monkey suit"
	desc = "A suit that looks like a primate."
	icon_state = "monkeysuit"
	item_state = "monkeysuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 2.0


/obj/item/clothing/suit/holidaypriest
	name = "holiday priest"
	desc = "This is a nice holiday my son."
	icon_state = "holidaypriest"
	item_state = "holidaypriest"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/suit/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	item_state = "cardborg"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/byzantine_dress
	name = "Byzantine dress"
	desc = "Fancy expensive clothes from Space Byzantium"
	icon_state = "Byzantine_dress"
	item_state = "Byzantine_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/*
 * Misc
 */

/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that completely restrains the wearer."
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL

/obj/item/clothing/suit/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	item_state = "ianshirt"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/nerdshirt
	name = "gamer shirt"
	desc = "A baggy shirt with a vintage game character on it. Why would someone wear this?"
	icon_state = "nerdshirt"
	item_state = "nerdshirt"

/obj/item/clothing/suit/blueshirt
	name = "blue shirt"
	desc = "A blue shirt with some strange symbols. Look out for aliens!"
	icon_state = "blueshirt"
	item_state = "blueshirt"

/obj/item/clothing/suit/chemshirt
	name = "chemistry shirt"
	desc = "A nice orange shirt made from a special fabric that hides any reagent stains. Has a drawn beaker with some glowy acid inside. Wanna cook?"
	icon_state = "chemshirt"
	item_state = "chemshirt"

/obj/item/clothing/suit/roundshirt
	name = "science shirt"
	desc = "A purple, sciency t-shirt with a picture of a burning star. Save the Earth! Oh wait, already too late for that"
	icon_state = "roundshirt"
	item_state = "roundshirt"

/obj/item/clothing/suit/catshirt
	name = "cat shirt"
	desc = "Very comfy, grey t-shirt with a picture of a cute kitty. And the best part: any cat or tajaran hair blends into the design very well!"
	icon_state = "catshirt"
	item_state = "catshirt"

/obj/item/clothing/suit/engishirt
	name = "engineer shirt"
	desc = "Loose t-shirt made of insulating material. Trust me i'm an engineer"
	icon_state = "engishirt"
	item_state = "engishirt"

/obj/item/clothing/suit/badengishirt
	name = "bad engineer shirt"
	desc = "A loose T-shirt made of insulating material with a picture of gravitational singularity on it. Don't trust me i'm a bad engineer"
	icon_state = "badengishirt"
	item_state = "badengishirt"

/obj/item/clothing/suit/docshirt
	name = "doc shirt"
	desc = "Nice white T-shirt, designed to show that you are a fashionable doctor. Blood stains are not included"
	icon_state = "docshirt"
	item_state = "docshirt"

/obj/item/clothing/suit/battonshirt
	name = "stunning shirt"
	desc = "A red T-shirt made from durable Rip-Stop material with a picture of bloody stun batton on it. It makes you stunned"
	icon_state = "battonshirt"
	item_state = "battonshirt"

/obj/item/clothing/suit/arstotzkashirt
	name = "dictator shirt"
	desc = "Grim-looking T-shirt with a picture of red eagle. A good banner for creating your own state in a single department"
	icon_state = "arstotzkashirt"
	item_state = "arstotzkashirt"

/obj/item/clothing/suit/toxicshirt
	name = "toxic shirt"
	desc = "Acidic-green t-shirt in order to show who is the biggest asshole here"
	icon_state = "toxicshirt"
	item_state = "toxicshirt"

/obj/item/clothing/suit/jacket
	name = "bomber jacket"
	desc = "Aviators not included."
	icon_state = "bomberjacket"
	item_state = "johnny"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter)

/obj/item/clothing/suit/jacket/leather
	name = "leather jacket"
	desc = "Pompadour not included."
	icon_state = "leatherjacket"
	item_state = "hostrench"

/obj/item/clothing/suit/jacket/leather/overcoat
	name = "leather overcoat"
	desc = "That's a damn fine coat."
	icon_state = "leather_overcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/jacket/puffer
	name = "puffer jacket"
	desc = "A thick jacket with a rubbery, water-resistant shell."
	icon_state = "pufferjacket"
	item_state = "hostrench"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 35, rad = 0)

/obj/item/clothing/suit/jacket/puffer/vest
	name = "puffer vest"
	desc = "A thick vest with a rubbery, water-resistant shell."
	icon_state = "puffervest"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 30, rad = 0)

/obj/item/clothing/suit/storage/postal_dude_coat
	name = "black trenchcoat"
	desc = "A black trenchcoat."
	icon_state = "dude_coat"
	item_state = "jensensuit"
	item_color = "dude_coat"

//pyjamas
//originally intended to be pinstripes >.>

/obj/item/clothing/under/bluepyjamas
	name = "blue pyjamas"
	desc = "Slightly old-fashioned sleepwear."
	icon_state = "blue_pyjamas"
	item_state = "blue_pyjamas"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/under/redpyjamas
	name = "red pyjamas"
	desc = "Slightly old-fashioned sleepwear."
	icon_state = "red_pyjamas"
	item_state = "red_pyjamas"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

//coats

/obj/item/clothing/suit/leathercoat
	name = "leather coat"
	desc = "A flowing, black coat."
	icon_state = "leathercoat"
	item_state = "leathercoat"

/obj/item/clothing/suit/serifcoat
	name = "serif coat"
	desc = "A old coat"
	icon_state = "serif_coat"
	item_state = "det_suit"

//stripper
/obj/item/clothing/under/stripper
	body_parts_covered = 0

/obj/item/clothing/under/stripper/stripper_pink
	name = "pink swimsuit"
	desc = "A rather skimpy pink swimsuit."
	icon_state = "stripper_p"
	item_color = "stripper_p"
	siemens_coefficient = 1

/obj/item/clothing/under/stripper/stripper_green
	name = "green swimsuit"
	desc = "A rather skimpy green swimsuit."
	icon_state = "stripper_g"
	item_color = "stripper_g"
	siemens_coefficient = 1

/obj/item/clothing/suit/stripper_pink
	name = "pink skimpy dress"
	desc = "A rather skimpy pink dress."
	icon_state = "stripper_p"
	item_state = "stripper_p"
	siemens_coefficient = 1

/obj/item/clothing/suit/stripper_green
	name = "green skimpy dress"
	desc = "A rather skimpy green dress."
	icon_state = "stripper_g"
	item_state = "stripper_g"
	siemens_coefficient = 1

/obj/item/clothing/under/stripper/mankini
	name = "the mankini"
	desc = "No honest man would wear this abomination"
	icon_state = "mankini"
	item_color = "mankini"
	siemens_coefficient = 1

/obj/item/clothing/suit/xenos
	name = "xenos suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	item_state = "xenos_helm"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 2.0
//swimsuit
/obj/item/clothing/under/swimsuit
	siemens_coefficient = 1
	body_parts_covered = 0

/obj/item/clothing/under/swimsuit/black
	name = "black swimsuit"
	desc = "An oldfashioned black swimsuit."
	icon_state = "swim_black"
	item_color = "swim_black"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/blue
	name = "blue swimsuit"
	desc = "An oldfashioned blue swimsuit."
	icon_state = "swim_blue"
	item_color = "swim_blue"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/purple
	name = "purple swimsuit"
	desc = "An oldfashioned purple swimsuit."
	icon_state = "swim_purp"
	item_color = "swim_purp"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/green
	name = "green swimsuit"
	desc = "An oldfashioned green swimsuit."
	icon_state = "swim_green"
	item_color = "swim_green"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/red
	name = "red swimsuit"
	desc = "An oldfashioned red swimsuit."
	icon_state = "swim_red"
	item_color = "swim_red"
	siemens_coefficient = 1

/obj/item/clothing/suit/batman
	name = "Batman costume"
	desc = "My parents are dead"
	icon_state = "batman"
	item_state = "batman"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/superman
	name = "Superman costume"
	desc = "Is it a bird? Is it a plane?"
	icon_state = "superman"
	item_state = "superman"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/storage/miljacket_army
	name = "field jacket olive"
	desc = "Initially designed for the US military under the MIL-DTL-43455K standard, it is now also worn as a civilian item of clothing. Classic olive."
	icon_state = "miljacket_army"
	item_state = "miljacket_army"
	var/can_button_up = 1
	var/is_button_up = 1
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/suit/storage/miljacket_army/verb/toggle()
	set name = "Toggle Jacket Buttons"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return 0
	if(!can_button_up)
		to_chat(usr, "You attempt to button-up the velcro on your [src], before promptly realising how silly you are.")
		return 0

	if(!src.is_button_up)
		src.icon_state = initial(icon_state)
		to_chat(usr, "You button up your jacket.")
		src.is_button_up = 1
	else
		src.icon_state += "_open"
		to_chat(usr, "You unbutton your jacket.")
		src.is_button_up = 0
	usr.update_inv_wear_suit()	//so our overlays update

/obj/item/clothing/suit/storage/miljacket_army/miljacket_ranger
	name = "field jacket desert"
	desc = "Initially designed for the US military under the MIL-DTL-43455K standard, it is now also worn as a civilian item of clothing. Marine cold desert."
	icon_state = "miljacket_ranger"
	item_state = "miljacket_ranger"

/obj/item/clothing/suit/storage/miljacket_army/miljacket_navy
	name = "field jacket navy"
	desc = "Initially designed for the US military under the MIL-DTL-43455K standard, it is now also worn as a civilian item of clothing. Like a navy seal,"
	icon_state = "miljacket_navy"
	item_state = "miljacket_navy"

/obj/item/clothing/suit/poncho
	name = "poncho"
	desc = "Your classic, non-racist poncho."
	icon_state = "classicponcho"
	item_state = "classicponcho"

/obj/item/clothing/suit/poncho/green
	name = "green poncho"
	desc = "Your classic, non-racist poncho. This one is green."
	icon_state = "greenponcho"
	item_state = "greenponcho"

/obj/item/clothing/suit/poncho/rainbow
	name = "green poncho"
	desc = "Your classic, non-racist poncho. This one is rainbow."
	icon_state = "rainbowponcho"
	item_state = "rainbowponcho"

/obj/item/clothing/suit/poncho/red
	name = "red poncho"
	desc = "Your classic, non-racist poncho. This one is red."
	icon_state = "redponcho"
	item_state = "redponcho"

/obj/item/clothing/suit/poncho/ponchoshame
	name = "poncho of shame"
	desc = "Forced to live on your shameful acting as a fake mexican, you and your poncho have grown inseperable. Literally."
	icon_state = "ponchoshame"
	item_state = "ponchoshame"

//Mafia
/obj/item/clothing/suit/browntrenchcoat
	name = "brown trench coat"
	desc = "It makes you stand out. Just the opposite of why it's typically worn. Nice try trying to blend in while wearing it."
	icon_state = "trenchcoat_brown"
	item_state = "trenchcoat_brown"

/obj/item/clothing/suit/blacktrenchcoat
	name = "black trench coat"
	desc = "That shade of black just makes you look a bit more evil. Good for those mafia types."
	icon_state = "trenchcoat_black"
	item_state = "trenchcoat_black"

/obj/item/clothing/suit/necromancer_hoodie
	name = "necromancer hoodie"
	desc = "This suit says to you 'hush'!"
	icon_state = "necromancer"
	item_state = "necromancer"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/chaplain_hoodie/brown
	name = "brown robe"
	icon_state = "brown_robe"
	item_state = "brown_robe"

/obj/item/clothing/suit/chaplain_hoodie/green
	name = "green robe"
	icon_state = "green_robe"
	item_state = "green_robe"

/obj/item/clothing/suit/chaplain_hoodie/black
	name = "black robe"
	icon_state = "black_robe"

/obj/item/clothing/suit/armor/vest/cuirass
	name = "cuirass"
	desc = "A metal armor, which cover torso."
	icon_state = "cuirass"
	item_state = "cuirass"
	blood_overlay_type = "armor"
	flags = THICKMATERIAL
	armor = list(melee = 50, bullet = 30, laser = 10, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/suit/goodman_jacket
	name = "brown jacket"
	desc = "A good jacket for good men."
	icon_state = "gmjacket"

/obj/item/clothing/suit/goodman_jacket/verb/toggle()
	set name = "Toggle Jacket Buttons"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return 0

	if(src.icon_state == "gmjacket_open")
		src.icon_state = "gmjacket"
		src.item_state = "gmjacket"
		to_chat(usr, "You button up the suit jacket.")
	else if(src.icon_state == "gmjacket")
		src.icon_state = "gmjacket_open"
		src.item_state = "gmjacket_open"
		to_chat(usr, "You unbutton the suit jacket.")
	else
		to_chat(usr, "You button-up some imaginary buttons on your [src].")
		return
	usr.update_inv_wear_suit()

/obj/item/clothing/suit/hooded/carp_costume
	name = "carp costume"
	desc = "A costume made from 'synthetic' carp scales, it smells."
	icon_state = "carp_casual"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS //Space carp like space, so you should too
	allowed = list(/obj/item/weapon/tank/emergency_oxygen)
	hoodtype = /obj/item/clothing/head/hooded/carp_hood

/obj/item/clothing/suit/hooded/ian_costume	//It's Ian, rub his bell- oh god what happened to his inside parts?
	name = "corgi costume"
	desc = "A costume that looks like someone made a human-like corgi, it won't guarantee belly rubs."
	icon_state = "ian"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list()
	hoodtype = /obj/item/clothing/head/hooded/ian_hood

/obj/item/clothing/suit/hooded/angel_suit
	name = "Angel Suit"
	desc = "Angel costume, which Emits aura of light."
	icon_state = "angela_suit"
	hoodtype = /obj/item/clothing/head/angel_nimb

/obj/item/clothing/suit/student_jacket
	name = "Student Jacket"
	desc = "A Student's jacket from the eighties."
	icon_state = "student_jacket"
	action_button_name = "To Fasten"
	var/fastened = TRUE

/obj/item/clothing/suit/student_jacket/ui_action_click()
	if(fastened)
		icon_state = "student_jacket_open"
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.wear_suit == src)
				H.update_inv_wear_suit()
	else
		icon_state = "student_jacket"
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.wear_suit == src)
				H.update_inv_wear_suit()
	fastened = !fastened

/obj/item/clothing/suit/atlas_jacket
	name = "atlas jacket"
	desc = "Stylish white satin jacket with a scorpion embroidered on the back."
	icon_state = "atlas_jacket"

/obj/item/clothing/suit/shawl
	name = "shawl"
	desc = "A pink Shawl for Hindi Womans."
	icon_state = "shawl"

/obj/item/clothing/suit/sukeban_coat
	name = "sukeban coat"
	desc = "Just a Street Japanese coat"
	icon_state = "sukeban_coat"

/obj/item/clothing/suit/plaid
	name = "plaid"
	desc = "Home warm plaid"
	icon_state = "plaid"

/obj/item/clothing/suit/tuxedo
	name = "tuxedo"
	desc = "A semi-formal evening suit distinguished primarily by satin or grosgrain facings on the jacket's lapels"
	icon_state = "tuxedo"

/obj/item/clothing/suit/syndieshirt
	name = "red shirt"
	desc = "Brand new, incredibly comfortable t-shirt with a logo of Syndicate."
	icon_state = "syndieshirt"
	item_state = "syndieshirt"
	body_parts_covered = UPPER_TORSO|ARMS
