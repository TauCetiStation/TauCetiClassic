/obj/item/robot_parts
	name = "robot parts"
	icon = 'icons/obj/robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/part = null
	var/protected = 0 // Protection from EMP.
	var/has_grid = FALSE              // Used for checking, whether limb has a grid inbuilt.
	var/sabotaged = FALSE //Emagging limbs can have repercussions when installed as prosthetics.
	var/hatch_opened = FALSE
	var/datum/robolimb/model

/obj/item/robot_parts/atom_init()
	. = ..()
	if(!model)
		model = all_robolimbs["Unbranded"]
	get_brand()

/obj/item/robot_parts/proc/get_brand()
	name = "[model.company] [initial(name)]"
	desc = "[initial(desc)] Model seems to be [model.company]."
	protected = model.protected
	if(model.low_quality && prob(50)) // 50% chance for a low quality prosthetic to be sabotaged.
		sabotaged = model.low_quality

/obj/item/robot_parts/l_arm
	name = "robot left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	part = BP_L_ARM

/obj/item/robot_parts/r_arm
	name = "robot right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"
	part = BP_R_ARM

/obj/item/robot_parts/l_leg
	name = "robot left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"
	part = BP_L_LEG

/obj/item/robot_parts/r_leg
	name = "robot right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"
	part = BP_R_LEG

/obj/item/robot_parts/chest
	name = "robot torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	icon_state = "chest"
	var/wires = 0.0
	var/obj/item/weapon/stock_parts/cell/cell = null
	part = BP_CHEST

/obj/item/robot_parts/head
	name = "robot head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	icon_state = "head"
	var/obj/item/device/flash/flash1 = null
	var/obj/item/device/flash/flash2 = null
	part = BP_HEAD

/obj/item/robot_parts/groin
	name = "robot groin"
	desc = "A standard chasis for holding leg-pseudomuscles together. Wrapped in wires and other not relatable stuff."
	icon_state = "chest" // Placeholder.
	part = BP_GROIN

/obj/item/robot_parts/robot_suit
	name = "robot endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"
	var/obj/item/robot_parts/l_arm/l_arm = null
	var/obj/item/robot_parts/r_arm/r_arm = null
	var/obj/item/robot_parts/l_leg/l_leg = null
	var/obj/item/robot_parts/r_leg/r_leg = null
	var/obj/item/robot_parts/chest/chest = null
	var/obj/item/robot_parts/head/head = null
	var/created_name = ""
	w_class = 3

/obj/item/robot_parts/robot_suit/atom_init()
	. = ..()
	update_icon()

/obj/item/robot_parts/robot_suit/update_icon()
	overlays.Cut()
	if(l_arm)
		overlays += "l_arm+o"
	if(r_arm)
		overlays += "r_arm+o"
	if(chest)
		overlays += "chest+o"
	if(l_leg)
		overlays += "l_leg+o"
	if(r_leg)
		overlays += "r_leg+o"
	if(head)
		overlays += "head+o"

/obj/item/robot_parts/robot_suit/proc/check_completion()
	if(l_arm && r_arm)
		if(l_leg && r_leg)
			if(chest && head)
				feedback_inc("cyborg_frames_built",1)
				return 1
	return 0

/obj/item/robot_parts/robot_suit/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/stack/sheet/metal) && !l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
		var/obj/item/stack/sheet/metal/M = W
		if(!M.use(1))
			return

		var/obj/item/weapon/ed209_assembly/B = new /obj/item/weapon/ed209_assembly
		B.loc = get_turf(src)
		to_chat(user, "<span class='info'>You armed the robot frame!</span>")

		if (user.get_inactive_hand()==src)
			user.remove_from_mob(src)
			user.put_in_inactive_hand(B)
		qdel(src)
		return

	if(istype(W, /obj/item/weapon/wrench))
		if(contents.len)
			to_chat(user, "<span class='info'>You disassemble robot frame to parts!</span>")
			var/turf/T = get_turf(src)
			T.contents += contents
			l_arm = null
			r_arm = null
			l_leg = null
			r_leg = null
			chest = null
			head = null
			overlays.Cut()
			w_class = initial(w_class)
		else
			to_chat(user, "<span class='warning'>Nothing attached to robot frame!</span>")
		return

	if(istype(W, /obj/item/robot_parts/l_leg))
		if(l_leg)
			return
		user.drop_item()
		W.loc = src
		l_leg = W
		w_class = 4
		update_icon()
		return

	if(istype(W, /obj/item/robot_parts/r_leg))
		if(r_leg)
			return
		user.drop_item()
		W.loc = src
		r_leg = W
		w_class = 4
		update_icon()
		return

	if(istype(W, /obj/item/robot_parts/l_arm))
		if(l_arm)
			return
		user.drop_item()
		W.loc = src
		l_arm = W
		w_class = 4
		update_icon()
		return

	if(istype(W, /obj/item/robot_parts/r_arm))
		if(r_arm)
			return
		user.drop_item()
		W.loc = src
		r_arm = W
		w_class = 4
		update_icon()
		return

	if(istype(W, /obj/item/robot_parts/chest))
		if(chest)
			return
		if(W:wires && W:cell)
			user.drop_item()
			W.loc = src
			chest = W
			w_class = 4
			update_icon()
		else if(!W:wires)
			to_chat(user, "<span class='info'>You need to attach wires to it first!</span>")
		else
			to_chat(user, "<span class='info'>You need to attach a cell to it first!</span>")
		return

	if(istype(W, /obj/item/robot_parts/head))
		if(head)
			return
		if(W:flash2 && W:flash1)
			user.drop_item()
			W.loc = src
			head = W
			w_class = 4
			update_icon()
		else
			to_chat(user, "<span class='info'>You need to attach a flash to it first!</span>")
		return

	if(istype(W, /obj/item/device/mmi))
		var/obj/item/device/mmi/M = W
		if(check_completion())
			if(!istype(loc,/turf))
				to_chat(user, "<span class='warning'>You can't put \the [W] in, the frame has to be standing on the ground to be perfectly precise.</span>")
				return
			if(!M.brainmob)
				to_chat(user, "<span class='warning'>Sticking an empty [W] into the frame would sort of defeat the purpose.</span>")
				return
			if(!M.brainmob.key)
				var/ghost_can_reenter = 0
				if(M.brainmob.mind)
					for(var/mob/dead/observer/G in player_list)
						if(G.can_reenter_corpse && G.mind == M.brainmob.mind)
							ghost_can_reenter = 1
							break
				if(!ghost_can_reenter)
					to_chat(user, "<span class='notice'>\The [W] is completely unresponsive; there's no point.</span>")
					return

			if(M.brainmob.stat == DEAD)
				to_chat(user, "<span class='warning'>Sticking a dead [W] into the frame would sort of defeat the purpose.</span>")
				return

			if((M.brainmob.mind in ticker.mode.head_revolutionaries) || (M.brainmob.mind in ticker.mode.A_bosses) || (M.brainmob.mind in ticker.mode.B_bosses))
				to_chat(user, "<span class='warning'>The frame's firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'. It refuses to accept the [W].</span>")
				return

			if(jobban_isbanned(M.brainmob, "Cyborg"))
				to_chat(user, "<span class='warning'>This [W] does not seem to fit.</span>")
				return

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(loc))
			if(!O)	return

			user.drop_item()

			O.mmi = W
			O.invisibility = 0
			O.custom_name = created_name
			O.updatename("Default")

			M.brainmob.mind.transfer_to(O)

			if(O.mind && O.mind.special_role)
				O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")

			O.job = "Cyborg"

			O.cell = chest.cell
			O.cell.loc = O
			W.loc = O//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.

			// Since we "magically" installed a cell, we also have to update the correct component.
			if(O.cell)
				var/datum/robot_component/cell_component = O.components["power cell"]
				cell_component.wrapped = O.cell
				cell_component.installed = 1

			feedback_inc("cyborg_birth",1)
			var/datum/game_mode/mutiny/mode = get_mutiny_mode()
			if(mode)
				mode.borgify_directive(O)
			O.Namepick()

			qdel(src)
		else
			to_chat(user, "<span class='info'>The MMI must go in after everything else!</span>")
		return

	if (istype(W, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && loc != usr)
			return

		created_name = t

	return

/obj/item/robot_parts/chest/attackby(obj/item/W, mob/user)
	..()

	if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='info'>You have already inserted a cell!</span>")
			return

		user.drop_item()
		W.loc = src
		cell = W
		to_chat(user, "<span class='info'>You insert the cell!</span>")

	else if(istype(W, /obj/item/stack/cable_coil))
		if(wires)
			to_chat(user, "<span class='info'>You have already inserted wire!</span>")
			return

		var/obj/item/stack/cable_coil/coil = W
		if(!coil.use(1))
			return

		wires = 1.0
		to_chat(user, "<span class='info'>You insert the wire!</span>")

	else if(istype(W, /obj/item/weapon/crowbar))
		if(!cell)
			to_chat(user, "<span class='warning'>No cell installed!</span>")
			return

		to_chat(user, "<span class='info'>You took out a cell!</span>")
		cell.loc = get_turf(src)
		cell = null

	else if(istype(W, /obj/item/weapon/wirecutters))
		if(!wires)
			to_chat(user, "<span class='warning'>No wires installed!</span>")
			return

		to_chat(user, "<span class='info'>You cut the wires!</span>")
		new /obj/item/stack/cable_coil(get_turf(src), 1)
		wires = 0.0
		return

/obj/item/robot_parts/head/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/device/flash))
		if(istype(user,/mob/living/silicon/robot))
			to_chat(user, "<span class='warning'>How do you propose to do that?</span>")
			return
		else if(flash1 && flash2)
			to_chat(user, "<span class='info'>You have already inserted the eyes!</span>")
			return
		else
			user.drop_item()
			W.loc = src
			to_chat(user, "<span class='info'>You insert the flash into the eye socket!</span>")
			if(flash1)
				flash2 = W
			else
				flash1 = W
		return

	if(istype(W, /obj/item/weapon/crowbar))
		if(flash1 || flash2)
			to_chat(user, "<span class='info'>You remove the flash from the eye socket!</span>")
			if(flash2)
				flash2.loc = get_turf(src)
				flash2 = null
			else
				flash1.loc = get_turf(src)
				flash1 = null
		else
			to_chat(user, "<span class='warning'>No flash installed!</span>")
		return

	if(istype(W, /obj/item/weapon/stock_parts/manipulator))
		to_chat(user, "<span class='info'>You install some manipulators and modify the head, creating a functional spider-bot!</span>")
		new /mob/living/simple_animal/spiderbot(get_turf(loc))
		user.drop_item()
		qdel(W)
		qdel(src)
		return
	return

/obj/item/robot_parts/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/card/emag))
		if(sabotaged)
			to_chat(user, "<span class='warning'>[src] is already sabotaged!</span>")
		else
			to_chat(user, "<span class='warning'>You slide [W] into the dataport on [src] and short out the safeties.</span>")
			sabotaged = TRUE
		return
	if(istype(W, /obj/item/weapon/screwdriver))
		hatch_opened = !hatch_opened
		user.visible_message("<span class='notice'>[user] [hatch_opened ? "opened" : "closed"] the hatch on [src].</span>",
		"<span class='notice'>You [hatch_opened ? "open" : "close"] the hatch on [src].</span>")
	if(istype(W, /obj/item/device/multitool) && hatch_opened)
		if(sabotaged)
			sabotaged = FALSE
	if(istype(W, /obj/item/device/radio_grid) && hatch_opened && !has_grid)
		protected += 1
		has_grid = TRUE
	..()
