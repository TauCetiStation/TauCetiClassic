/obj/item/clothing/glasses/syndidroneRC	//A traitor item, concealed as mesons.
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "degoggles"
	item_state = "glasses"
	action_button_name = "Toggle Goggles"
	origin_tech = "biotech=2;programming=2;syndicate=1"
	active = FALSE
	toggleable = FALSE

	var/mob/living/silicon/robot/drone/syndi/slave

/obj/item/clothing/glasses/syndidroneRC/atom_init()
	. = ..()
	slave = null

/obj/item/clothing/glasses/syndidroneRC/attack_self(mob/living/carbon/human/user)
	if(user.stat != CONSCIOUS)
		return
	if(src.slot_equipped != SLOT_GLASSES)
		to_chat(user, "The [src.name] needs to be equipped to work properly!")
		return
	if(slave && !slave.is_dead())
		slave.control(user)
	else
		to_chat(user, "The linked drone seems to be unresponsive.")