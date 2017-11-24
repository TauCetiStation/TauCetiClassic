//Regular syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate
	name = "Red Space Helmet"
	icon_state = "syndicate-helm"
	item_state = "syndicate-helm"
	desc = "Has a tag: Totally not property of an enemy corporation, honest."
	armor = list(melee = 60, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	action_button_name = "Toggle Helmet Light"
	var/brightness = 3 //luminosity when on
	var/lit = FALSE
	species_restricted = list("exclude" , DIONA , VOX)

/obj/item/clothing/suit/space/syndicate
	name = "Red Space Suit"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "Has a tag on it: Totally not property of of a hostile corporation, honest!"
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1
	armor = list(melee = 60, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	species_restricted = list("exclude" , DIONA , VOX)


/obj/item/clothing/head/helmet/space/syndicate/attack_self(mob/user)
	lit = !lit
	if(lit)
		set_light(brightness)
		icon_state += "-lit"
	else
		set_light(0)
		icon_state = initial(icon_state)

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()


//Civilian syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/civilian
	name = "Civilian Space Helmet"
	desc = "Space helmet made by unknown manufacturer."
	icon_state = "syndicate-helm-civ"
	item_state = "syndicate-helm-jailbreaker"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)
	species_restricted = list("exclude" , UNATHI , TAJARAN , SKRELL , DIONA , VOX)

/obj/item/clothing/suit/space/syndicate/civilian
	name = "Civilian Space Suit"
	desc = "Space suit made by unknown manufacturer."
	icon_state = "syndicate-civ"
	item_state = "s_suit"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)


//Striker syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/striker
	name = "Striker Space Helmet"
	desc = "That's obviously some kind of military space helmet."
	icon_state = "syndicate-helm-striker"
	item_state = "syndicate-helm-striker"
	armor = list(melee = 60, bullet = 45, laser = 40,energy = 45, bomb = 50, bio = 100, rad = 30)
	brightness = 4

/obj/item/clothing/suit/space/syndicate/striker
	name = "Striker Space Suit"
	desc = "That's obviously some kind of military space suit."
	icon_state = "syndicate-striker"
	item_state = "syndicate-striker"
	armor = list(melee = 60, bullet = 45, laser = 40,energy = 45, bomb = 50, bio = 100, rad = 30)
	breach_threshold = 12


//Jailbreaker syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/jailbreaker
	name = "Jailbreaker Space Helmet"
	desc = "The look of this space helmet gives you an urge to buckle up and dismantle the floor in a crowded room."
	icon_state = "syndicate-helm-jailbreaker"
	item_state = "syndicate-helm-jailbreaker"

/obj/item/clothing/suit/space/syndicate/jailbreaker
	name = "Jailbreaker Space Suit"
	desc = "The look of this space suit gives you an urge to buckle up and dismantle the floor in a crowded room."
	icon_state = "syndicate-jailbreaker"
	item_state = "syndicate-jailbreaker"


//Infiltrator syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/infiltrator
	name = "Infiltrator Space Helmet"
	desc = "Space helmet made by unknown manufacturer. It's made from some strange composite material."
	icon_state = "syndicate-helm-infiltrator"
	item_state = "syndicate-helm-trooper"
	action_button_name = null

/obj/item/clothing/suit/space/syndicate/infiltrator
	name = "Infiltrator Space Suit"
	desc = "Space suit made by unknown manufacturer. It's made from some strange composite material."
	icon_state = "syndicate-trooper"
	item_state = "syndicate-trooper"

/obj/item/clothing/head/helmet/space/syndicate/infiltrator/attack_self(mob/user)
	return


//Striketeam syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/edgy
	name = "Edgy Trooper Space Helmet"
	desc = "It looks like the person wearing this should be death incarnate wannabe."
	icon_state = "syndicate-helm-edgy-trooper"
	item_state = "syndicate-helm-trooper"
	armor = list(melee = 75, bullet = 65, laser = 65, energy = 65, bomb = 70, bio = 100, rad = 20)

/obj/item/clothing/head/helmet/space/syndicate/edgy/attack_self(mob/user)
	return

/obj/item/clothing/suit/space/syndicate/edgy
	name = "Edgy Trooper Space Suit"
	desc = "It looks like the person wearing this should be death incarnate wannabe."
	icon_state = "syndicate-trooper"
	item_state = "syndicate-trooper"
	armor = list(melee = 75, bullet = 65, laser = 65, energy = 65, bomb = 70, bio = 100, rad = 20)
	breach_threshold = 32


/obj/item/clothing/head/helmet/space/syndicate/edgy/leader
	name = "Edgy Leader Space Helmet"
	desc = "Person wearing this was the death incarnate. You still feel edgy vibes coming from the inside."
	icon_state = "syndicate-helm-edgy-leader"
	item_state = "syndicate-helm-edgy-leader"

/obj/item/clothing/suit/space/syndicate/edgy/leader
	name = "Edgy Leader Space Suit"
	desc = "Person wearing this was the death incarnate. You still feel edgy vibes coming from the inside."
	icon_state = "syndicate-edgy"
	item_state = "syndicate-edgy"
