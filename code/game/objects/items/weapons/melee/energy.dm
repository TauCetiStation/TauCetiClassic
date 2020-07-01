/obj/item/weapon/melee/energy
	var/active = 0
	flags = NOBLOODY
	can_embed = 0

	sweep_step = 2

/obj/item/weapon/melee/energy/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list()

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE

	SCB.can_sweep_call = CALLBACK(src, /obj/item/weapon/melee/energy.proc/can_sweep)
	SCB.can_spin_call = CALLBACK(src, /obj/item/weapon/melee/energy.proc/can_spin)
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/melee/energy/proc/can_sweep(mob/user)
	return active

/obj/item/weapon/melee/energy/proc/can_spin(mob/user)
	return active

/obj/item/weapon/melee/energy/get_current_temperature()
	if(active)
		return 3500
	else
		return 0

/obj/item/weapon/melee/energy/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='warning'><b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b></span>", \
						"<span class='warning'><b>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</b></span>"))
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

	sweep_step = 5

/obj/item/weapon/melee/energy/axe/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] swings the [src.name] towards /his head! It looks like \he's trying to commit suicide.</b></span>")
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

	var/can_combine = TRUE

/obj/item/weapon/melee/energy/sword/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/melee/energy/sword))
		var/obj/item/weapon/melee/energy/sword/S = I
		if(!S.can_combine || !can_combine)
			return

		to_chat(user, "<span class='notice'>You attach the ends of the two \
			energy swords, making a single double-bladed weapon! \
			You're cool.</span>")
		var/obj/item/weapon/twohanded/dualsaber/newSaber = new(user.loc)
		user.unEquip(I)
		user.unEquip(src)
		qdel(I)
		qdel(src)
		user.put_in_hands(newSaber)

	else if(ismultitool(I))
		if(!hacked)
			hacked = TRUE
			to_chat(user,"<span class='warning'>RNBW_ENGAGE</span>")
			item_color = "rainbow"
			if (active)
				active = FALSE
				icon_state = "sword0"
		else
			to_chat(user,"<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")

	else
		return ..()

/obj/item/weapon/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"

	can_combine = FALSE

/obj/item/weapon/melee/energy/sword/traitor
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."

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
