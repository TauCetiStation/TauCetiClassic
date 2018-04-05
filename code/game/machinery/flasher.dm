// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "Mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = FALSE
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 10 //How weakened targets are when flashed.
	var/base_state = "mflash"
	anchored = TRUE

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 8
	anchored = FALSE
	base_state = "pflash"
	density = TRUE

/obj/machinery/flasher/power_change()
	if ( powered() )
		stat &= ~NOPOWER
		icon_state = "[base_state]1"
//		src.sd_SetLuminosity(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]1-p"
//		src.sd_SetLuminosity(0)

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wirecutters))
		add_fingerprint(user)
		src.disable = !src.disable
		user.SetNextMove(CLICK_CD_INTERACT)
		if (src.disable)
			user.visible_message("\red [user] has disconnected the [src]'s flashbulb!", "\red You disconnect the [src]'s flashbulb!")
		if (!src.disable)
			user.visible_message("\red [user] has connected the [src]'s flashbulb!", "\red You connect the [src]'s flashbulb!")

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai(mob/user)
	if (anchored)
		return flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("[base_state]_flash", src)
	src.last_flash = world.time
	use_power(1000)

	for (var/mob/O in viewers(src, null))
		if (get_dist(src, O) > src.range)
			continue

		if (istype(O, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = O
			if(!H.eyecheck() <= 0)
				continue

		if (istype(O, /mob/living/carbon/alien))//So aliens don't get flashed (they have no external eyes)/N
			continue

		O.Weaken(strength)
		if (istype(O, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = O
			var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
			if (IO.damage > IO.min_bruised_damage && prob(IO.damage + 50))
				H.flash_eyes()
				IO.damage += rand(1, 5)
		else
			if(!O.blinded && istype(O,/mob/living))
				var/mob/living/L = O
				L.flash_eyes()


/obj/machinery/flasher/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM)
	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if ((M.m_intent != "walk") && (src.anchored))
			src.flash()

/obj/machinery/flasher/portable/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wrench))
		add_fingerprint(user)
		src.anchored = !src.anchored
		user.SetNextMove(CLICK_CD_INTERACT)

		if (!src.anchored)
			user.show_message(text("\red [src] can now be moved."))
			src.overlays.Cut()

		else if (src.anchored)
			user.show_message(text("\red [src] is now secured."))
			src.overlays += "[base_state]-s"

/obj/machinery/flasher_button/attackby(obj/item/weapon/W, mob/user)
	return attack_hand(user)

/obj/machinery/flasher_button/attack_hand(mob/user)
	if(..() || active)
		return 1

	use_power(5)
	user.SetNextMove(CLICK_CD_INTERACT)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/flasher/M in machines)
		if(M.id == id)
			spawn()
				M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0
