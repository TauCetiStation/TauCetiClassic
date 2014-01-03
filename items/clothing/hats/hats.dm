/obj/item/clothing/head/helmet/helmet_of_justice
	name = "helmet of justice"
	desc = "Prepare for Justice!"
	icon = 'tauceti/items/clothing/hats/helmet_justice.dmi'
	icon_state = "shitcuritron_0"
	tc_custom = 'tauceti/items/clothing/hats/helmet_justice.dmi'
	item_state = "helmet"
	var/on = 0
	icon_action_button = "action_hardhat"

/obj/item/clothing/head/helmet/helmet_of_justice/attack_self(mob/user)
	on = !on
	icon_state = "shitcuritron_[on]"
	user.update_inv_head()
