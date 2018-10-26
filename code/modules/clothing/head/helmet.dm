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

/obj/item/clothing/head/helmet/band
	var/list/can_hold = list(
		/obj/item/weapon/lighter/zippo = "band_zippo",
		/obj/item/weapon/lighter = "band_lighter",
		/obj/item/weapon/storage/fancy/cigarettes/odetoviceroy_green = "band_odetoviceroy_green",
		/obj/item/weapon/storage/fancy/cigarettes/odetoviceroy_blue = "band_odetoviceroy_blue",
		/obj/item/weapon/storage/fancy/cigarettes/odetoviceroy_red = "band_odetoviceroy_red",
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = "band_chocolatebar",
		/obj/item/toy/singlecard = "band_singlecard",
		/obj/item/stack/medical/bruise_pack = "band_bruise_pack")
	var/obj/item/on_helmet
	var/on_helmet_overlay

/obj/item/clothing/head/helmet/band/attackby(obj/item/W, mob/user)
	if(on_helmet)
		to_chat(user, "<span class='notice'>There is already something on [src].</span>")
		return

	for(var/i in can_hold)
		if(istype(W, i))
			user.drop_from_inventory(W)
			W.forceMove(src)
			on_helmet = W
			to_chat(user, "<span class='notice'>You put [W] on [src].</span>")
			on_helmet_overlay = image('icons/mob/helmet_bands.dmi', can_hold[i])
			user.update_inv_head()
			break

/obj/item/clothing/head/helmet/band/verb/remove_on_helmet()
	set category = "Object"
	set name = "Remove object from helmet"
	set src in usr

	if(!usr.incapacitated())
		return
	if(!on_helmet)
		return
	on_helmet.forceMove(usr.loc)
	on_helmet = null
	QDEL_NULL(on_helmet_overlay)
	usr.update_inv_head()

/obj/item/clothing/head/helmet/band/emp_act(severity)
	on_helmet.emp_act(severity)
	return ..()

/obj/item/clothing/head/helmet/band/Destroy()
	QDEL_NULL(on_helmet)
	QDEL_NULL(on_helmet_overlay)
	return ..()

/obj/item/clothing/head/helmet/band/warden
	name = "Star Vigil Sergeant's hat"
	desc = "It's a special helmet issued to the Star Vigil Sergeant of a security force. Protects the head from impacts."
	icon_state = "helmet_warden"

/obj/item/clothing/head/helmet/HoS
	name = "head of security hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	flags = HEADCOVERSEYES
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEEARS
	body_parts_covered = 0
	siemens_coefficient = 0.8

/obj/item/clothing/head/helmet/HoS/dermal
	name = "dermal armour patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"
	item_state = "dermal"
	siemens_coefficient = 0.6
	body_parts_covered = 1

/obj/item/clothing/head/helmet/band/riot
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

/obj/item/clothing/head/helmet/band/riot/attack_self()
	toggle()

/obj/item/clothing/head/helmet/band/riot/verb/toggle()
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
	name = "\improper thunderdome helmet"
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

/obj/item/clothing/head/helmet/band/warden/blue
	name = "Star Vigil Sergeant's hat"
	desc = "It's a special helmet issued to the Star Vigil Sergeant of a securiy force. Protects the head from impacts."
	icon_state = "oldwardenhelm"
	item_state = "helmet"

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

/obj/item/clothing/head/helmet/erthelmet_cmd
	name = "emergency response team commander helmet"
	desc = "A helmet worn by the commander of a NanoTrasen Emergency Response Team. Has blue highlights."
	icon_state = "erthelmet_cmd"
	item_state = "erthelmet_cmd"
	armor = list(melee = 60, bullet = 65, laser = 55, energy = 30, bomb = 50, bio = 0, rad = 30)
	flags = HEADCOVERSEYES|BLOCKHAIR
	flags_inv = HIDEEARS|HIDEEYES
	siemens_coefficient = 0.7

/obj/item/clothing/head/helmet/erthelmet_sec
	name = "emergency response team security helmet"
	desc = "A helmet worn by security members of a NanoTrasen Emergency Response Team. Has red highlights."
	icon_state = "erthelmet_sec"
	item_state = "erthelmet_sec"
	armor = list(melee = 65, bullet = 55, laser = 55, energy = 25, bomb = 50, bio = 0, rad = 20)
	flags = HEADCOVERSEYES|BLOCKHAIR
	flags_inv = HIDEEARS|HIDEEYES
	siemens_coefficient = 0.7

/obj/item/clothing/head/helmet/erthelmet_med
	name = "emergency response team medical helmet"
	desc = "A helmet worn by medical members of a NanoTrasen Emergency Response Team. Has white highlights."
	icon_state = "erthelmet_med"
	item_state = "erthelmet_med"
	armor = list(melee = 55, bullet = 45, laser = 40, energy = 20, bomb = 50, bio = 20, rad = 50)
	flags = HEADCOVERSEYES|BLOCKHAIR
	flags_inv = HIDEEARS|HIDEEYES
	siemens_coefficient = 0.7

/obj/item/clothing/head/helmet/erthelmet_eng
	name = "emergency response team engineer helmet"
	desc = "A helmet worn by engineering members of a NanoTrasen Emergency Response Team. Has orange highlights."
	icon_state = "erthelmet_eng"
	item_state = "erthelmet_eng"
	armor = list(melee = 55, bullet = 45, laser = 45, energy = 35, bomb = 50, bio = 0, rad = 80)
	flags = HEADCOVERSEYES|BLOCKHAIR
	flags_inv = HIDEEARS|HIDEEYES
	siemens_coefficient = 0.7
