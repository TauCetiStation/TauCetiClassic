/obj/item/clothing/neck/bundle_of_bubliks
	name = "bundle of bubliks"
	desc = "Бублики на верёвке."
	icon_state = "baranki_7"
	item_state = "baranki_7"
	item_state_world = "baranki_world"

	var/bubliksAmount = 7

	item_action_types = list(/datum/action/item_action/hands_free/pickBublik)

/obj/item/clothing/neck/bundle_of_bubliks/update_world_icon()
	update_icon()

/obj/item/clothing/neck/bundle_of_bubliks/update_icon()
	if((flags_2 & IN_INVENTORY || flags_2 & IN_STORAGE))
		icon_state = "baranki_[bubliksAmount]"
	else
		icon_state = "baranki_[bubliksAmount]_world"

	item_state = "baranki_[bubliksAmount]"

/datum/action/item_action/hands_free/pickBublik
	name = "Pick a Bublik"

/datum/action/item_action/hands_free/pickBublik/Activate()
	var/obj/item/clothing/neck/bundle_of_bubliks/Bundle = target
	var/mob/user = usr

	var/obj/item/weapon/reagent_containers/food/snacks/bublik/Bublik = new(Bundle)

	if(ishuman(user))
		user.put_in_hands(Bublik)
	else
		Bublik.forceMove(get_turf(Bundle))

	Bundle.bubliksAmount--
	if(!Bundle.bubliksAmount)
		qdel(Bundle)

	Bundle.update_icon()

/obj/item/clothing/head/jesterhat
	name = "Jester's hat"
	desc = "Да, я с виду шут, но в душе король!"
	icon_state = "jester"
	item_state_world = "jester_world"
	flags = HEADCOVERSEYES
	render_flags = parent_type::render_flags | HIDE_ALL_HAIR
	body_parts_covered = HEAD
