/obj/item/clothing/neck/bundle_of_bubliks
	name = "bundle of bubliks"
	desc = "Бублики на верёвке."
	icon_state = "baranki_7"

	var/bubliksAmount = 7

	item_action_types = list(/datum/action/item_action/hands_free/pickBublik)

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

	Bundle.icon_state = "baranki_[Bundle.bubliksAmount]"
