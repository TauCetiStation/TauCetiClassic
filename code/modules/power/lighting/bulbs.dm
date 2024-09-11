// light item
// will fit into empty /obj/machinery/light of the corresponding ``fitting`` type

/obj/item/weapon/light
	name = "default light object"
	desc = "Report to coders if you see this lamp."
	icon = 'icons/obj/lighting.dmi'

	force = 2
	throwforce = 5
	w_class = SIZE_TINY

	m_amt = 50 // in case of mats change tweak lightreplacer

	var/status = LIGHT_OK // LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/fitting = LAMP_FITTING_TUBE
	var/switchcount = 0 // number of times switched
	var/rigged = FALSE // true if rigged to explode

	var/smart = FALSE // should lamp use smart light settings from APC, or bulb light_mode
	var/datum/light_mode/light_mode = /datum/light_mode/default/dim

/obj/item/weapon/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	item_state = "c_tube"
	g_amt = 100
	fitting = LAMP_FITTING_TUBE
	light_mode = /datum/light_mode/default

/obj/item/weapon/light/tube/smart // todo: own white colb sprite (+color!)
	name = "smart light tube"
	desc = "A replacement smart light tube. Can be used with central lighting control systems!"
	icon_state = "lstube" // coder sprite, temp
	smart = TRUE

/obj/item/weapon/light/tube/large // we don't really need this...
	w_class = SIZE_TINY
	name = "large light tube"
	fitting = LAMP_FITTING_LARGE_TUBE
	light_mode = /datum/light_mode/default/spot

/obj/item/weapon/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	item_state = "contvapour"
	g_amt = 100
	fitting = LAMP_FITTING_BULB
	light_mode = /datum/light_mode/default/bulb

/obj/item/weapon/light/bulb/emergency
	name = "emergency light bulb"
	desc = "A replacement emergency bulb."
	//icon_state = "fbulb" // todo: old icon was lost somewhere
	//item_state = "egg4"
	light_mode = /datum/light_mode/default/bulb/emergency

/obj/item/weapon/light/atom_init()
	. = ..()
	update()

// update the icon state and description of the light
/obj/item/weapon/light/proc/update()
	switch(status)
		if(LIGHT_OK)
			icon_state = initial(icon_state)
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			icon_state = "[initial(icon_state)]-burned"
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			icon_state = "[initial(icon_state)]-broken"
			desc = "A broken [name]."

// attack bulb/tube with object
// if a syringe, can inject phoron to make it explode
/obj/item/weapon/light/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I
		user.SetNextMove(CLICK_CD_INTERACT)

		to_chat(user, "You inject the solution into the [src].")

		if(S.reagents.has_reagent("phoron", 5))
			log_admin("LOG: [key_name(user)] injected a light with phoron, rigging it to explode.")
			message_admins("LOG: [key_name_admin(user)] injected a light with phoron, rigging it to explode. [ADMIN_JMP(user)]")

			rigged = TRUE

		S.reagents.clear_reagents()

	else
		return ..()

// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm
/obj/item/weapon/light/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(target, /obj/machinery/light))
		return
	if(user.a_intent != INTENT_HARM)
		return

	shatter()

/obj/item/weapon/light/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	shatter()

/obj/item/weapon/light/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		visible_message("<span class='warning'>[name] shatters.</span>","<span class='warning'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		sharp = 1
		playsound(src, 'sound/effects/light-break.ogg', VOL_EFFECTS_MASTER)
		update()
