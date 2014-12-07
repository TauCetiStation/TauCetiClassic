// **** Security gas mask (TG-stuff) ****
/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device, plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you taze them. Do not tamper with the device."
	icon_action_button = "action_hardhat"
	icon = 'tauceti/items/clothing/masks/sec_maskTG.dmi'
	icon_state = "officermask"
	tc_custom = 'tauceti/items/clothing/masks/sec_maskTG.dmi'
	var/cooldown = 0
	var/aggressiveness = 2

/obj/item/clothing/mask/gas/sechailer/warden
	icon_state = "wardenmask"

/obj/item/clothing/mask/gas/sechailer/hos
	icon_state = "hosmask"

/obj/item/clothing/mask/gas/sechailer/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		switch(aggressiveness)
			if(1)
				user << "\blue You set the restrictor to the middle position."
				aggressiveness = 2
			if(2)
				user << "\blue You set the restrictor to the last position."
				aggressiveness = 3
			if(3)
				user << "\blue You set the restrictor to the first position."
				aggressiveness = 1
			if(4)
				user << "\red You adjust the restrictor but nothing happens, probably because its broken."
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(aggressiveness != 4)
			user << "\red You broke it!"
			aggressiveness = 4
	else
		..()

/obj/item/clothing/mask/gas/sechailer/attack_self()
	halt()

/obj/item/clothing/mask/gas/sechailer/verb/halt()
	set category = "Object"
	set name = "HALT"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

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
				phrase_sound = "halt"
			if(2)
				phrase_text = "Stop in the name of the Law."
				phrase_sound = "bobby"
			if(3)
				phrase_text = "Compliance is in your best interest."
				phrase_sound = "compliance"
			if(4)
				phrase_text = "Prepare for justice!"
				phrase_sound = "justice"
			if(5)
				phrase_text = "Running will only increase your sentence."
				phrase_sound = "running"
			if(6)				// bad cop
				phrase_text = "Don't move, Creep!"
				phrase_sound = "dontmove"
			if(7)
				phrase_text = "Down on the floor, Creep!"
				phrase_sound = "floor"
			if(8)
				phrase_text = "Dead or alive you're coming with me."
				phrase_sound = "robocop"
			if(9)
				phrase_text = "God made today for the crooks we could not catch yesterday."
				phrase_sound = "god"
			if(10)
				phrase_text = "Freeze, Scum Bag!"
				phrase_sound = "freeze"
			if(11)
				phrase_text = "Stop right there, criminal scum!"
				phrase_sound = "imperial"
			if(12)				// LA-PD
				phrase_text = "Stop or I'll bash you."
				phrase_sound = "bash"
			if(13)
				phrase_text = "Go ahead, make my day."
				phrase_sound = "harry"
			if(14)
				phrase_text = "Stop breaking the law, ass hole."
				phrase_sound = "asshole"
			if(15)
				phrase_text = "You have the right to shut the fuck up."
				phrase_sound = "stfu"
			if(16)
				phrase_text = "Shut up crime!"
				phrase_sound = "shutup"
			if(17)
				phrase_text = "Face the wrath of the golden bolt."
				phrase_sound = "super"
			if(18)
				phrase_text = "I am, the LAW!"
				phrase_sound = "dredd"

		usr.visible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[phrase_text]</b></font>")
		playsound(src.loc, "tauceti/sounds/voice/complionator/[phrase_sound].ogg", 100, 0, 4)
		cooldown = world.time