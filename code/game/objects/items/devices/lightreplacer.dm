/obj/item/device/lightreplacer
	name = "light replacer"
	desc = "A device to automatically replace lights. Refill with reinforced glass."

	icon = 'icons/obj/janitor.dmi'
	icon_state = "lightreplacer0"
	item_state = "electronic"

	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "magnets=3;materials=2"

	usesound = 'sound/machines/click.ogg'
	//required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED) // janitor don't have any skills, maybe in the future

	var/max_uses = 100
	var/uses = 0
	var/charge_cicle = 1 // for borgs only

	var/obj/item/weapon/light/lamp_type = /obj/item/weapon/light/tube
	var/list/valid_lamp_types = list("tube" = /obj/item/weapon/light/tube, "bulb" = /obj/item/weapon/light/bulb, "smart tube" = /obj/item/weapon/light/tube/smart)

	var/emagged = FALSE // todo

/obj/item/device/lightreplacer/robot
	max_uses = 20

/obj/item/device/lightreplacer/atom_init()
	uses = max_uses / 4
	. = ..()

/obj/item/device/lightreplacer/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "It has [uses] use\s remaining. Print type set on [initial(lamp_type.name)].")

/obj/item/device/lightreplacer/tool_use_check(mob/user, amount, obj/machinery/light/target)
	if(target.fitting != initial(lamp_type.fitting))
		if(user)
			to_chat(user, "<span class='notice'>Wrong fitting type, this type of light requires a [target.fitting]. You need to change printing mode of [src].</span>")
		return FALSE
	if(uses < amount)
		if(user)
			to_chat(user, "<span class='notice'>You need to refill [src].</span>")
		return FALSE
	return TRUE

/obj/item/device/lightreplacer/use(used = 1, mob/user = null)
	if(used < 0)
		stack_trace("[src.type]/use() called with a negative parameter")
		return FALSE

	if(uses < used)
		return FALSE

	uses -= used
	return TRUE

// Negative numbers will subtract
/obj/item/device/lightreplacer/proc/add_uses(amount = 1)
	uses = clamp(uses + amount, 0, max_uses)

/obj/item/device/lightreplacer/proc/Charge(mob/user)
	charge_cicle += 1
	if(charge_cicle > 3)
		add_uses(5)
		charge_cicle = 1

/obj/item/device/lightreplacer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/rglass)) // now it's need rglass. One rglass is 37.5 bulbs if we count by mats (met+glass)
		if(uses == max_uses)
			to_chat(user, "\The [src] is already fully loaded.")
			return
		var/obj/item/stack/sheet/rglass/G = I
		if(G.use_tool(src, user, 10, 1))
			add_uses(35) // count 2.5 uses as efficiency loss (it's not autolathe)
			to_chat(user, "You insert a piece of glass into the [src.name]. It now has [uses] use\s.")
			return
	else
		return ..()

/obj/item/device/lightreplacer/attack_self(mob/user)
	var/new_type = input(user, "Select new bulb type.", "Bulb print type", lamp_type) in valid_lamp_types
	if(new_type)
		lamp_type = valid_lamp_types[new_type]

/obj/item/device/lightreplacer/update_icon()
	icon_state = "lightreplacer[emagged]"

/obj/item/device/lightreplacer/emag_act(mob/user)
	emagged = !emagged
	playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	if(emagged)
		name = "Shortcircuited [initial(name)]"
	else
		name = initial(name)
	update_icon()
	return TRUE
