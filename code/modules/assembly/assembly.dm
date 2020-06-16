/obj/item/device/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	flags = CONDUCT
	w_class = ITEM_SIZE_SMALL
	m_amt = 100
	g_amt = 0
	w_amt = 0
	throwforce = 2
	throw_speed = 3
	throw_range = 10
	origin_tech = "magnets=1"

	var/secured = 1
	var/list/attached_overlays = null
	var/obj/item/device/assembly_holder/holder = null
	var/cooldown = 0//To prevent spam
	var/wires = WIRE_RECEIVE | WIRE_PULSE

	var/const/WIRE_RECEIVE = 1			//Allows Pulsed(0) to call Activate()
	var/const/WIRE_PULSE = 2				//Allows Pulse(0) to act on the holder
	var/const/WIRE_PULSE_SPECIAL = 4		//Allows Pulse(0) to act on the holders special assembly
	var/const/WIRE_RADIO_RECEIVE = 8		//Allows Pulsed(1) to call Activate()
	var/const/WIRE_RADIO_PULSE = 16		//Allows Pulse(1) to send a radio message

/obj/item/device/assembly/proc/activate()			//What the device does when turned on
	return

/obj/item/device/assembly/proc/pulsed(radio = 0)	//Called when another assembly acts on this one, var/radio will determine where it came from for wire calcs
	return

/obj/item/device/assembly/proc/pulse(radio = 0)	//Called when this device attempts to act on another device, var/radio determines if it was sent via radio or direct
	return

/obj/item/device/assembly/proc/toggle_secure()	//Code that has to happen when the assembly is un\secured goes here
	return

/obj/item/device/assembly/proc/attach_assembly(obj/A, mob/user)	//Called when an assembly is attacked by another
	return

/obj/item/device/assembly/proc/process_cooldown()	//Called via spawn(10) to have it count down the cooldown var
	return

/obj/item/device/assembly/proc/holder_movement()	//Called when the holder is moved
	return

/obj/item/device/assembly/interact(mob/user)	//Called when attack_self is called
	return

/obj/item/device/assembly/hear_talk(mob/living/M, msg) //Called when someone speak
	return

/obj/item/device/assembly/proc/is_secured(mob/user)
	if(!secured)
		to_chat(user, "<span class='warning'>The [name] is unsecured!</span>")
		return 0
	return 1

/obj/item/device/assembly/process_cooldown()
	cooldown--
	if(cooldown <= 0)	return 0
	spawn(10)
		process_cooldown()
	return 1


/obj/item/device/assembly/pulsed(radio = 0)
	if(holder && (wires & WIRE_RECEIVE))
		activate()
	if(radio && (wires & WIRE_RADIO_RECEIVE))
		activate()
	return 1


/obj/item/device/assembly/pulse(radio = 0)
	if(holder && (wires & WIRE_PULSE))
		holder.process_activation(src, 1, 0)
	if(holder && (wires & WIRE_PULSE_SPECIAL))
		holder.process_activation(src, 0, 1)
//	if(radio && (wires & WIRE_RADIO_PULSE))
		//Not sure what goes here quite yet send signal?
	return 1


/obj/item/device/assembly/activate()
	if(!secured || (cooldown > 0))	return 0
	cooldown = 2
	spawn(10)
		process_cooldown()
	return 1

/obj/item/device/assembly/toggle_secure()
	secured = !secured
	update_icon()
	return secured


/obj/item/device/assembly/attach_assembly(obj/item/device/assembly/A, mob/user)
	holder = new/obj/item/device/assembly_holder(get_turf(src))
	if(holder.attach(A,src,user))
		to_chat(user, "<span class='notice'>You attach \the [A] to \the [src]!</span>")
		return 1
	return 0

/obj/item/device/assembly/attackby(obj/item/I, mob/user, params)
	if(isassembly(I))
		var/obj/item/device/assembly/A = I
		if(!A.secured && !secured)
			attach_assembly(A, user)
			return

	if(isscrewdriver(I))
		if(toggle_secure())
			to_chat(user, "<span class='notice'>\The [src] is ready!</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] can now be attached!</span>")
		return
	return ..()

/obj/item/device/assembly/process()
	STOP_PROCESSING(SSobj, src)
	return


/obj/item/device/assembly/examine(mob/user)
	..()
	if(src in view(1, user))
		if(secured)
			to_chat(user, "\The [src] is ready!")
		else
			to_chat(user, "\The [src] can be attached!")


/obj/item/device/assembly/attack_self(mob/user)
	if(!user)	return 0
	user.set_machine(src)
	interact(user)
	return 1


/obj/item/device/assembly/interact(mob/user)
	return //HTML MENU FOR WIRES GOES HERE
