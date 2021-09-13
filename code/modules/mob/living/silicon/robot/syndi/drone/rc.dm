/obj/item/clothing/glasses/syndidroneRC	//These are now a traitor item, concealed as mesons.
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

/obj/item/clothing/glasses/syndidroneRC/attack_self(mob/user)
	//TODO: force mob to control drone, if glasses are equiped