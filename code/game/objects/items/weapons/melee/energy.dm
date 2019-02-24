/obj/item/weapon/melee/energy
	var/active = 0
	flags = NOBLOODY
	can_embed = 0

/obj/item/weapon/melee/energy/suicide_act(mob/user)
	to_chat(viewers(user), pick("\red <b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b>", \
						"\red <b>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</b>"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	force = 40.0
	throwforce = 25.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	flags = CONDUCT | NOSHIELD | NOBLOODY
	origin_tech = "combat=3"
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	sharp = 1
	edge = 1

/obj/item/weapon/melee/energy/axe/suicide_act(mob/user)
	to_chat(viewers(user), "\red <b>[user] swings the [src.name] towards /his head! It looks like \he's trying to commit suicide.</b>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	flags = NOSHIELD | NOBLOODY
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = 1
	edge = 1
	var/hacked

/obj/item/weapon/melee/energy/sword/attackby(obj/item/weapon/W, mob/living/user)
	if(istype(W, /obj/item/weapon/melee/energy/sword) && !istype(W, /obj/item/weapon/melee/energy/sword/pirate))
		to_chat(user, "<span class='notice'>You attach the ends of the two \
			energy swords, making a single double-bladed weapon! \
			You're cool.</span>")
		var/obj/item/weapon/twohanded/dualsaber/newSaber = new(user.loc)
		user.unEquip(W)
		user.unEquip(src)
		qdel(W)
		qdel(src)
		user.put_in_hands(newSaber)
	if(istype(W, /obj/item/device/multitool))
		if(!hacked)
			hacked = 1
			to_chat(user,"<span class='warning'>RNBW_ENGAGE</span>")
			item_color = "rainbow"
			if (active)
				active = 0
				icon_state = "sword0"
		else
			to_chat(user,"<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")
	else
		return ..()

/obj/item/weapon/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"

/obj/item/weapon/melee/energy/sword/pirate/attackby()
	return

/obj/item/weapon/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	force = 70.0//Normal attacks deal very high damage.
	sharp = 1
	edge = 1
	throwforce = 1//Throwing or dropping the item deletes it.
	throw_speed = 1
	throw_range = 1
	w_class = ITEM_SIZE_LARGE//So you can't hide it in your pocket or some such.
	flags = NOSHIELD | NOBLOODY | DROPDEL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/datum/effect/effect/system/spark_spread/spark_system
