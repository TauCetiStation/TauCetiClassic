//Regular syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate
	name = "red space helmet"
	icon_state = "syndicate-helm"
	item_state = "syndicate-helm"
	desc = "Has a tag: Totally not property of an enemy corporation, honest."
	armor = list(melee = 60, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	action_button_name = "Toggle Helmet Light"
	var/brightness = 3 //light_range when on
	var/lit = FALSE
	species_restricted = list("exclude" , DIONA , VOX)
	var/image/lamp = null

/obj/item/clothing/suit/space/syndicate
	name = "red space suit"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "Has a tag on it: Totally not property of of a hostile corporation, honest!"
	w_class = ITEM_SIZE_NORMAL
	allowed = list(/obj/item/weapon/gun,
	               /obj/item/ammo_box/magazine,
	               /obj/item/ammo_casing,
	               /obj/item/weapon/melee/baton,
	               /obj/item/weapon/melee/energy/sword,
	               /obj/item/weapon/handcuffs,
	               /obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1
	armor = list(melee = 60, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	species_restricted = list("exclude" , DIONA , VOX)

/obj/item/clothing/head/helmet/space/syndicate/update_icon(mob/user)
	. = ..()
	icon_state = "[initial(icon_state)][lit ? "-lit" : ""]"
	if(user)
		user.update_inv_head()

/obj/item/clothing/head/helmet/space/syndicate/attack_self(mob/user)
	. = ..()
	lit = !lit
	set_light(lit ? brightness : 0)
	update_icon(user)


//Civilian syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/civilian
	name = "civilian space helmet"
	desc = "Space helmet made by unknown manufacturer."
	icon_state = "syndicate-helm-civ"
	item_state = "syndicate-helm-jailbreaker"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)
	species_restricted = list("exclude" , UNATHI , TAJARAN , SKRELL , DIONA , VOX)

/obj/item/clothing/suit/space/syndicate/civilian
	name = "civilian space suit"
	desc = "Space suit made by unknown manufacturer."
	icon_state = "syndicate-civ"
	item_state = "s_suit"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)


//Striker syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/striker
	name = "striker space helmet"
	desc = "That's obviously some kind of military space helmet."
	icon_state = "syndicate-helm-striker"
	item_state = "syndicate-helm-striker"
	armor = list(melee = 60, bullet = 45, laser = 40,energy = 45, bomb = 50, bio = 100, rad = 30)
	brightness = 4

/obj/item/clothing/suit/space/syndicate/striker
	name = "striker space suit"
	desc = "That's obviously some kind of military space suit."
	icon_state = "syndicate-striker"
	item_state = "syndicate-striker"
	armor = list(melee = 60, bullet = 45, laser = 40,energy = 45, bomb = 50, bio = 100, rad = 30)
	breach_threshold = 12


//Jailbreaker syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/jailbreaker
	name = "jailbreaker space helmet"
	desc = "The look of this space helmet gives you an urge to buckle up and dismantle the floor in a crowded room."
	icon_state = "syndicate-helm-jailbreaker"
	item_state = "syndicate-helm-jailbreaker"

/obj/item/clothing/suit/space/syndicate/jailbreaker
	name = "jailbreaker space suit"
	desc = "The look of this space suit gives you an urge to buckle up and dismantle the floor in a crowded room."
	icon_state = "syndicate-jailbreaker"
	item_state = "syndicate-jailbreaker"


//Infiltrator syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/infiltrator
	name = "infiltrator space helmet"
	desc = "Space helmet made by unknown manufacturer. It's made from some strange composite material."
	icon_state = "syndicate-helm-infiltrator"
	item_state = "syndicate-helm-elite"
	action_button_name = null

/obj/item/clothing/suit/space/syndicate/infiltrator
	name = "infiltrator space suit"
	desc = "Space suit made by unknown manufacturer. It's made from some strange composite material."
	icon_state = "syndicate-infiltrator"
	item_state = "syndicate-elite"

/obj/item/clothing/head/helmet/space/syndicate/infiltrator/attack_self(mob/user)
	return


//Striketeam syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/elite
	name = "elite striker space helmet"
	desc = "It looks like the person wearing this should be death incarnate wannabe."
	icon_state = "syndicate-helm-elite"
	item_state = "syndicate-helm-elite"
	armor = list(melee = 75, bullet = 65, laser = 65, energy = 65, bomb = 70, bio = 100, rad = 20)
	action_button_name = null

/obj/item/clothing/head/helmet/space/syndicate/elite/attack_self(mob/user)
	return

/obj/item/clothing/suit/space/syndicate/elite
	name = "elite striker space suit"
	desc = "It looks like the person wearing this should be death incarnate wannabe."
	icon_state = "syndicate-elite"
	item_state = "syndicate-elite"
	armor = list(melee = 75, bullet = 65, laser = 65, energy = 65, bomb = 70, bio = 100, rad = 20)
	breach_threshold = 32


/obj/item/clothing/head/helmet/space/syndicate/elite/commander
	name = "striker commander space helmet"
	desc = "Person wearing this was the death incarnate. You still feel edgy vibes coming from the inside."
	icon_state = "syndicate-helm-commander"
	item_state = "syndicate-helm-commander"

/obj/item/clothing/suit/space/syndicate/elite/commander
	name = "striker commander space suit"
	desc = "Person wearing this was the death incarnate. You still feel edgy vibes coming from the inside."
	icon_state = "syndicate-commander"
	item_state = "syndicate-commander"
