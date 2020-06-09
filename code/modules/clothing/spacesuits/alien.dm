//Skrell space gear. Sleek like a wetsuit.
/obj/item/clothing/head/helmet/space/skrell
	name = "skrellian helmet"
	desc = "Smoothly contoured and polished to a shine. Still looks like a fishbowl."
	armor = list(melee = 20, bullet = 20, laser = 25,energy = 50, bomb = 50, bio = 100, rad = 100)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list(SKRELL , HUMAN)


	action_button_name = "Toggle Helmet Light" //this copypaste everywhere!
	var/brightness_on = 4 //luminosity when on
	var/on = 0

	light_color = "#00ffff"

/obj/item/clothing/head/helmet/space/skrell/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc]")//To prevent some lighting anomalities.
		return
	on = !on
	icon_state = "[initial(icon_state)][on ? "-light" : ""]"
	usr.update_inv_head()

	if(on)	set_light(brightness_on)
	else	set_light(0)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

/obj/item/clothing/head/helmet/space/skrell/white
	icon_state = "skrell_helmet_white"
	item_state = "skrell_helmet_white"
	item_color = "skrell_helmet_white"

/obj/item/clothing/head/helmet/space/skrell/black
	icon_state = "skrell_helmet_black"
	item_state = "skrell_helmet_black"
	item_color = "skrell_helmet_black"

/obj/item/clothing/suit/space/skrell
	name = "skrellian hardsuit"
	desc = "Seems like a wetsuit with reinforced plating seamlessly attached to it. Very chic."
	armor = list(melee = 20, bullet = 20, laser = 25,energy = 50, bomb = 50, bio = 100, rad = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list(SKRELL , HUMAN)

/obj/item/clothing/suit/space/skrell/white
	icon_state = "skrell_suit_white"
	item_state = "skrell_suit_white"
	item_color = "skrell_suit_white"

/obj/item/clothing/suit/space/skrell/black
	icon_state = "skrell_suit_black"
	item_state = "skrell_suit_black"
	item_color = "skrell_suit_black"

//Unathi space gear. Huge and restrictive.
/obj/item/clothing/head/helmet/space/unathi
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 50)
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	var/up = 1 //So Unathi helmets play nicely with the weldervision check.
	species_restricted = list(UNATHI)

/obj/item/clothing/head/helmet/space/unathi/helmet_cheap
	name = "NT breacher helmet"
	desc = "Hey! Watch it with that thing! It's a knock-off of a Unathi battle-helm, and that spike could put someone's eye out."
	icon_state = "unathi_helm_cheap"
	item_state = "unathi_helm_cheap"
	item_color = "unathi_helm_cheap"

	action_button_name = "Toggle Helmet Light"
	var/brightness_on = 4 //luminosity when on
	var/on = 0

	light_color = "#00ffff"

/obj/item/clothing/head/helmet/space/unathi/helmet_cheap/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc]")//To prevent some lighting anomalities.
		return
	on = !on
	icon_state = "unathi_helm_cheap[on ? "-light" : ""]"
	usr.update_inv_head()

	if(on)	set_light(brightness_on)
	else	set_light(0)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

/obj/item/clothing/suit/space/unathi
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list(UNATHI)

/obj/item/clothing/suit/space/unathi/rig_cheap
	name = "NT breacher chassis"
	desc = "A cheap NT knock-off of a Unathi battle-rig. Looks like a fish, moves like a fish, steers like a cow."
	icon_state = "rig-unathi-cheap"
	item_state = "rig-unathi-cheap"
	slowdown = 2.3

/obj/item/clothing/head/helmet/space/unathi/breacher
	name = "breacher helm"
	desc = "Weathered, ancient and battle-scarred. The helmet is too."
	icon_state = "unathi_breacher"
	item_state = "unathi_breacher"
	item_color = "unathi_breacher"

/obj/item/clothing/suit/space/unathi/breacher
	name = "breacher chassis"
	desc = "Huge, bulky and absurdly heavy. It must be like wearing a tank."
	icon_state = "unathi_breacher"
	item_state = "unathi_breacher"
	item_color = "unathi_breacher"
	slowdown = 1

// Vox space gear (vaccuum suit, low pressure armour)
// Can't be equipped by any other species due to bone structure and vox cybernetics.
/obj/item/clothing/suit/space/vox
	w_class = ITEM_SIZE_NORMAL
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank)
	slowdown = 1.5
	armor = list(melee = 60, bullet = 50, laser = 40, energy = 15, bomb = 30, bio = 30, rad = 30)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list(VOX , VOX_ARMALIS)

/obj/item/clothing/head/helmet/space/vox
	armor = list(melee = 60, bullet = 50, laser = 40, energy = 15, bomb = 30, bio = 30, rad = 30)
	flags = HEADCOVERSEYES
	species_restricted = list(VOX , VOX_ARMALIS)

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"
	armor = list(melee = 80, bullet = 75, laser = 50, energy = 10, bomb = 35, bio = 30, rad = 30)

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."
	slowdown = 2
	armor = list(melee = 80, bullet = 75, laser = 50, energy = 10, bomb = 35, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	armor = list(melee = 65, bullet = 50, laser = 70, energy = 20, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."
	armor = list(melee = 65, bullet = 50, laser = 70, energy = 20, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An alien helmet with enormous goggled lenses."
	armor = list(melee = 50, bullet = 40, laser = 45, energy = 15, bomb = 25, bio = 30, rad = 30)

/obj/item/clothing/suit/space/vox/medic
	name = "alien armour"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An almost organic looking nonhuman pressure suit."
	slowdown = 1
	var/mob/living/carbon/human/wearer
	armor = list(melee = 50, bullet = 40, laser = 45, energy = 15, bomb = 25, bio = 30, rad = 30)

/obj/item/clothing/suit/space/vox/medic/equipped(mob/user, slot)
	..()
	if(slot == SLOT_WEAR_SUIT)
		wearer = user
		START_PROCESSING(SSobj, src)
		wearer.playsound_local(null, 'sound/rig/shortbeep.wav', VOL_EFFECTS_MASTER, null, FALSE)
		to_chat(wearer, "<span class='notice'>The medical system is ready for use. Make sure your helmet supports this system.</span>")

/obj/item/clothing/suit/space/vox/medic/dropped(mob/user)
	wearer = null
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/clothing/suit/space/vox/medic/Destroy()
	STOP_PROCESSING(SSobj, src)
	wearer = null
	return ..()

/obj/item/clothing/suit/space/vox/medic/process()
	if(!wearer)
		STOP_PROCESSING(SSobj, src)
		return
	if(wearer.stat == DEAD)
		STOP_PROCESSING(SSobj, src)
		return
	if(!istype(wearer.head, /obj/item/clothing/head/helmet/space/vox/medic))
		return
	if(damage > 9)
		wearer.adjustToxLoss(0.7) // this will kill the wearer after a while if the suit is not repaired or removed
	else if(wearer.reagents.get_reagent_amount("tricordrazine") > 5)
		return // safe tricordrazine injection
	if(damage > 19)
		wearer.adjustToxLoss(1) // this will kill the wearer much faster
	wearer.reagents.add_reagent("tricordrazine", REAGENTS_METABOLISM)

#define MAX_STEALTH_SPACESUIT_CHARGE 300

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A smoothly contoured, matte-black alien helmet."

	armor = list(melee = 45, bullet = 20, laser = 25, energy = 5, bomb = 15, bio = 30, rad = 30)

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."

	armor = list(melee = 45, bullet = 20, laser = 25, energy = 5, bomb = 15, bio = 30, rad = 30)

	slowdown = 0.5
	action_button_name = "Toggle Stealth Technology"
	var/on = FALSE
	var/mob/living/carbon/human/wearer
	var/current_charge = MAX_STEALTH_SPACESUIT_CHARGE
	var/last_try = 0

/obj/item/clothing/suit/space/vox/stealth/examine(mob/user)
	..()
	if(wearer)
		to_chat(wearer, "On your left wrist you see <span class='electronicblue'>\[ [current_charge] \]</span>. [damage ? "Looks like the reactor is damaged" : "The reactor is functioning stably"].")

/obj/item/clothing/suit/space/vox/stealth/ui_action_click()
	toggle_stealth()

/obj/item/clothing/suit/space/vox/stealth/Destroy()
	STOP_PROCESSING(SSobj, src)
	wearer = null
	return ..()

/obj/item/clothing/suit/space/vox/stealth/process()
	if(on)
		var/power_decrease = 2 // 5 minutes to full discharge
		if(damage > 0)
			power_decrease = 5 // 2 minutes to full discharge
		if(damage > 3)
			power_decrease = 10 // 1 minute to full discharge
		if(damage > 6)
			power_decrease = 0
			current_charge = 0
			STOP_PROCESSING(SSobj, src)
		current_charge -= power_decrease
		if(is_damaged())
			toggle_stealth(TRUE)
			return
		if(current_charge <= 0)
			current_charge = 0
			toggle_stealth(TRUE)
			return
		if(wearer)
			wearer.alpha = 4
			wearer.mouse_opacity = 0
			if(current_charge <= (power_decrease * 15)) // there are 30 seconds to full discharge
				wearer.playsound_local(null, 'sound/rig/loudbeep.wav', VOL_EFFECTS_MASTER, null, FALSE)
				to_chat(wearer, "<span class='danger'>Critically low charge:</span> <span class='electronicblue'>\[ [current_charge] \]</span>")
	else
		var/power_increase = 20 // 30 seconds to full charge
		if(damage > 0)
			power_increase = 10 // 1 minutes to full charge
		if(damage > 3)
			power_increase = 5 // 2 minutes to full charge
		if(damage > 6)
			power_increase = 0
			current_charge = 0
			STOP_PROCESSING(SSobj, src)
		current_charge += power_increase
		if(current_charge > MAX_STEALTH_SPACESUIT_CHARGE)
			current_charge = 300
			STOP_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/vox/stealth/equipped(mob/user, slot)
	..()
	if(slot == SLOT_WEAR_SUIT)
		wearer = user

/obj/item/clothing/suit/space/vox/stealth/dropped(mob/user)
	toggle_stealth(TRUE)
	wearer = null
	..()

/obj/item/clothing/suit/space/vox/stealth/proc/toggle_stealth(deactive = FALSE)
	if(on)
		playsound(src, 'sound/rig/stealthrig_turn_off.ogg', VOL_EFFECTS_MASTER, null, null, -4)
		on = FALSE
		slowdown = 0.5
		wearer.alpha = 255
		wearer.mouse_opacity = 1
	else if(!deactive)
		if(!istype(wearer.head, /obj/item/clothing/head/helmet/space/vox/stealth))
			to_chat(wearer, "<span class='warning'>The cloaking system cannot function without a helmet.</span>")
		if(last_try > world.time)
			return
		if(wearer.is_busy())
			return
		last_try = world.time + 4 SECONDS
		to_chat(wearer, "<span class='notice'>Turning on stealth mode...</span>")
		playsound(src, 'sound/rig/stealthrig_starting_up.ogg', VOL_EFFECTS_MASTER, null, FALSE, -5)
		if(do_after(wearer, 20, target = wearer))
			if(!istype(wearer) || wearer.wear_suit != src)
				return
			if(is_damaged(TRUE))
				return
			playsound(src, 'sound/rig/stealthrig_turn_on.ogg', VOL_EFFECTS_MASTER, null, null, -5)
			on = TRUE
			to_chat(wearer, "<span class='notice'>Stealth mode in now on!</span>")
			slowdown = 2
			wearer.alpha = 4
			wearer.mouse_opacity = 0
			START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/vox/stealth/proc/is_damaged(low_damage_check = FALSE)
	if(damage > 6)
		to_chat(wearer, "<span class='warning'>[src] is too damaged to support stealth mode!</span>")
		var/datum/effect/effect/system/spark_spread/s = new
		s.set_up(5, 1, src)
		s.start()
		return TRUE
	else if(low_damage_check)
		if(prob(33) && (damage > 3))
			to_chat(wearer, "<span class='warning'>[src] is damaged and failed to generate a cloaking field!</span>")
			return TRUE
	return FALSE

/obj/item/clothing/suit/space/vox/stealth/proc/overload()
	wearer.visible_message(
	"<span class='warning'>[wearer] appears from nowhere!</span>",
	"<span class='warning'>Your stealth got overloaded and no longer can sustain itself!</span>"
	)
	var/datum/effect/effect/system/spark_spread/s = new
	s.set_up(5, 1, src)
	s.start()
	toggle_stealth()

/obj/item/clothing/suit/space/vox/stealth/attack_reaction(mob/living/L, reaction_type, mob/living/carbon/human/T = null)
	if(on)
		if(reaction_type == REACTION_ITEM_TAKE || reaction_type == REACTION_ITEM_TAKEOFF)
			var/charge_decrease = max(rand(20, 30), round((damage * 25) + rand(1, 5)))
			current_charge -= charge_decrease
			if(wearer)
				to_chat(wearer, "<span class='warning'>Attention. The cloaking system is overloaded. Redistributed [charge_decrease] conventional units of energy.</span>")
				wearer.playsound_local(null, 'sound/rig/beep.wav', VOL_EFFECTS_MASTER, null, FALSE)
			return
		overload()

#undef MAX_STEALTH_SPACESUIT_CHARGE

/obj/item/clothing/under/vox
	has_sensor = 0
	species_restricted = list(VOX)

/obj/item/clothing/under/vox/vox_casual
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon_state = "vox-casual-1"
	item_color = "vox-casual-1"
	item_state = "vox-casual-1"
	body_parts_covered = LEGS

/obj/item/clothing/under/vox/vox_robes
	name = "alien robes"
	desc = "Weird and flowing!"
	icon_state = "vox-casual-2"
	item_color = "vox-casual-2"
	item_state = "vox-casual-2"

/obj/item/clothing/gloves/yellow/vox
	desc = "These bizarre gauntlets seem to be fitted for... bird claws?"
	name = "insulated gauntlets"
	icon_state = "gloves-vox"
	item_state = "gloves-vox"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	item_color = "gloves-vox"
	species_restricted = list(VOX , VOX_ARMALIS)

/obj/item/clothing/shoes/magboots/vox
	desc = "A pair of heavy, jagged armoured foot pieces, seemingly suitable for a velociraptor."
	name = "vox magclaws"
	item_state = "boots-vox"
	icon_state = "boots-vox"

	species_restricted = list(VOX , VOX_ARMALIS)
	action_button_name = "Toggle the magclaws"

/obj/item/clothing/shoes/magboots/vox/attack_self(mob/user)
	if(src.magpulse)
		flags &= ~NOSLIP
		magpulse = 0
		canremove = 1
		to_chat(user, "You relax your deathgrip on the flooring.")
	else
		//make sure these can only be used when equipped.
		if(!ishuman(user))
			return
		var/mob/living/carbon/human/H = user
		if (H.shoes != src)
			to_chat(user, "You will have to put on the [src] before you can do that.")
			return


		flags |= NOSLIP
		magpulse = 1
		canremove = 0	//kinda hard to take off magclaws when you are gripping them tightly.
		to_chat(user, "You dig your claws deeply into the flooring, bracing yourself.")
		to_chat(user, "It would be hard to take off the [src] without relaxing your grip first.")

//In case they somehow come off while enabled.
/obj/item/clothing/shoes/magboots/vox/dropped(mob/user)
	..()
	if(src.magpulse)
		user.visible_message("The [src] go limp as they are removed from [usr]'s feet.", "The [src] go limp as they are removed from your feet.")
		flags &= ~NOSLIP
		magpulse = 0
		canremove = 1

/obj/item/clothing/shoes/magboots/vox/examine(mob/user)
	..()
	if (magpulse)
		to_chat(user, "It would be hard to take these off without relaxing your grip first.")//theoretically this message should only be seen by the wearer when the claws are equipped.
