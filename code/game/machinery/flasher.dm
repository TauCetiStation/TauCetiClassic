// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "Mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	light_color = LIGHT_COLOR_WHITE
	light_power = FLASH_LIGHT_POWER
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = FALSE
	COOLDOWN_DECLARE(cd_flash) //Don't want it getting spammed like regular flashes
	var/strength = 10 //How weakened targets are when flashed.
	var/base_state = "mflash"
	anchored = TRUE

/obj/machinery/flasher/atom_init()
	. = ..()
	flasher_list += src

/obj/machinery/flasher/Destroy()
	flasher_list -= src
	return ..()

/obj/machinery/flasher/powered()
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 8
	anchored = FALSE
	base_state = "pflash"
	density = TRUE
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor

/obj/machinery/flasher/portable/Destroy()
	QDEL_NULL(proximity_monitor)
	return ..()

/obj/machinery/flasher/power_change()
	if (powered())
		stat &= ~NOPOWER
		icon_state = "[base_state]1"
	else
		stat |= NOPOWER
		icon_state = "[base_state]1-p"
	update_power_use()

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/weapon/W, mob/user)
	if (iscutter(W))
		add_fingerprint(user)
		disable = !disable
		user.SetNextMove(CLICK_CD_INTERACT)
		if(disable)
			user.visible_message("<span class='warning'>[user] has disconnected the [src]'s flashbulb!</span>", "<span class='warning'>You disconnect the [src]'s flashbulb!</span>")
		else
			user.visible_message("<span class='warning'>[user] has connected the [src]'s flashbulb!</span>", "<span class='warning'>You connect the [src]'s flashbulb!</span>")

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai(mob/user)
	if (anchored)
		return flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if(disable || !(powered() && COOLDOWN_FINISHED(src, cd_flash)))
		return
	COOLDOWN_START(src, cd_flash, 15 SECONDS)
	playsound(src, 'sound/weapons/flash.ogg', VOL_EFFECTS_MASTER)
	flick("[base_state]_flash", src)
	flash_lighting_fx(FLASH_LIGHT_RANGE, light_power, light_color)
	use_power(1000)

	for (var/mob/O in viewers(range, src))
		if (ishuman(O))
			var/mob/living/carbon/human/H = O
			if(H.eyecheck() > 0)
				continue

		if (isxeno(O))//So aliens don't get flashed (they have no external eyes)/N
			continue

		O.Stun(strength * 0.5)
		O.Weaken(strength)
		if (ishuman(O))
			var/mob/living/carbon/human/H = O
			var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
			if (IO.damage > IO.min_bruised_damage && prob(IO.damage + 50))
				H.flash_eyes()
				IO.damage += rand(1, 5)
		else
			if(!O.blinded && isliving(O))
				var/mob/living/L = O
				L.flash_eyes()


/obj/machinery/flasher/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/flasher/portable/atom_init()
	. = ..()
	proximity_monitor = new(src, anchored ? 1 : null)

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM)
	if(iscarbon(AM) && COOLDOWN_FINISHED(src, cd_flash))
		var/mob/living/carbon/M = AM
		if(M.m_intent != MOVE_INTENT_WALK)
			flash()

/obj/machinery/flasher/portable/attackby(obj/item/weapon/W, mob/user)
	if (iswrenching(W))
		add_fingerprint(user)
		user.SetNextMove(CLICK_CD_INTERACT)
		if(user.is_busy())
			return
		if(anchored)
			if(!allowed(user) && !do_after(user, SKILL_TASK_CHALLENGING, target = src))
				to_chat(user, "<span class='warning'>You don't have access and failed to lift the bolts up.</span>")
				return
			to_chat(user, "<span class='notice'>[src] can now be moved.</span>")
			cut_overlays()
			proximity_monitor.set_range(null)
			anchored = FALSE
		else
			to_chat(user, "<span class='warning'>[src] is now secured, security bolts down.</span>")
			add_overlay("[base_state]-s")
			proximity_monitor.set_range(1)
			req_access = list(access_security)
			anchored = TRUE

/obj/machinery/flasher_button/attackby(obj/item/weapon/W, mob/user)
	return attack_hand(user)

/obj/machinery/flasher_button/attack_hand(mob/user)
	if(..() || active)
		return 1

	use_power(5)
	user.SetNextMove(CLICK_CD_INTERACT)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/flasher/M in flasher_list)
		if(M.id == id)
			spawn()
				M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0
