/obj/item/clothing/glasses/syndidroneRC	//A traitor item, concealed as mesons.
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "degoggles"
	item_state = "glasses"
	action_button_name = "Toggle Goggles"
	origin_tech = "biotech=2;programming=2;syndicate=1"
	active = FALSE

	var/mob/living/silicon/robot/drone/syndi/slave
	var/mob/living/carbon/human/operator

/obj/item/clothing/glasses/syndidroneRC/atom_init()
	. = ..()
	slave = null
	operator = null

/obj/item/clothing/glasses/syndidroneRC/attack_self(mob/living/carbon/human/user)
	if(user.stat != CONSCIOUS)
		return
	if(src.slot_equipped != SLOT_GLASSES)
		to_chat(user, "<span class='warning'>The [src.name] needs to be equipped to work properly!</span>")
		return
	if(active)
		remote_view_off()
		return
	if(slave && !slave.is_dead() && !QDELING(slave))
		if(!slave.key)
			slave.control(user)
			return
		else
			to_chat(user, "<span class='notice'>The [slave.real_name] is already controlled by an AI. Switching to its camera...</span>")
			remote_view_on(user)
	else
		to_chat(user, "<span class='warning'>The linked drone seems to be unresponsive.</span>")

/obj/item/clothing/glasses/syndidroneRC/process()
	if(active && operator)
		if(loc == operator)
			if((slot_equipped == SLOT_GLASSES) && (operator.stat == CONSCIOUS))
				return
	remote_view_off()


/obj/item/clothing/glasses/syndidroneRC/proc/remote_view_on(/mob/living/carbon/human/user)
	if(!slave || QDELING(slave))
		return FALSE
	user.force_remote_viewing = TRUE
	user.reset_view(slave)
	active = TRUE
	operator = user
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/item/clothing/glasses/syndidroneRC/proc/remote_view_off()
	if(operator)
		operator.force_remote_viewing = FALSE
		operator.reset_view(operator)
		operator = null
	active = FALSE
	STOP_PROCESSING(SSobj, src)