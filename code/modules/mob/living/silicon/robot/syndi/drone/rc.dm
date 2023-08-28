/obj/item/clothing/glasses/syndidroneRC	//A traitor item, concealed as mesons.
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "degoggles"
	item_state = "glasses"
	origin_tech = "biotech=2;programming=2;syndicate=1"
	active = FALSE
	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

	var/mob/living/silicon/robot/drone/syndi/slave = null
	var/mob/living/carbon/human/operator = null

/datum/action/item_action/hands_free/toggle_goggles
	name = "Toggle Goggles"

/obj/item/clothing/glasses/syndidroneRC/Destroy()
	if(slave)
		if(slave.operator)
			loose_control()
		else
			remote_view_off()
	return ..()

/obj/item/clothing/glasses/syndidroneRC/attack_self(mob/living/carbon/human/user)
	if(user.stat != CONSCIOUS)
		return
	if(slot_equipped != SLOT_GLASSES)
		to_chat(user, "<span class='warning'>The [name] needs to be equipped to work properly!</span>")
		return

	if(active) //Normally the player will not be able to click on the glasses while controlling the drone. So he is definitely spectating.
		remote_view_off()
		return

	if(slave && !slave.is_dead() && !QDELING(slave))
		if(!slave.key)
			gain_control(user)
		else
			to_chat(user, "<span class='notice'>The [slave.real_name] is already controlled by an AI. Switching to its camera...</span>")
			remote_view_on(user)
	else
		to_chat(user, "<span class='warning'>The linked drone seems to be unresponsive.</span>")

/obj/item/clothing/glasses/syndidroneRC/process()
	if(active && operator)
		if(loc == operator)
			if((slot_equipped == SLOT_GLASSES) && (operator.stat == CONSCIOUS) && slave.key)
				return

	if(slave.operator)
		loose_control()
	else
		remote_view_off()

/obj/item/clothing/glasses/syndidroneRC/proc/gain_control(mob/living/carbon/human/user)
	operator = user
	active = TRUE
	START_PROCESSING(SSobj, src)
	slave.control(user)

/obj/item/clothing/glasses/syndidroneRC/proc/loose_control()
	slave.loose_control()
	STOP_PROCESSING(SSobj, src)
	active = FALSE
	operator = null

/obj/item/clothing/glasses/syndidroneRC/proc/remote_view_on(mob/living/carbon/human/user)
	user.force_remote_viewing = TRUE
	user.reset_view(slave)
	operator = user
	active = TRUE
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/item/clothing/glasses/syndidroneRC/proc/remote_view_off()
	if(operator)
		operator.force_remote_viewing = FALSE
		operator.reset_view(operator)
		operator = null
	STOP_PROCESSING(SSobj, src)
	active = FALSE
