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

/obj/item/clothing/head/beret/rosa
	name = "white beret"
	icon = 'tauceti/items/clothing/hats/hats.dmi'
	tc_custom = 'tauceti/items/clothing/hats/hats.dmi'
	icon_state = "rosas_hat"
	item_state = "helmet"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/helmet/warden/blue
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force. Protects the head from impacts."
	icon = 'tauceti/items/clothing/hats/hats.dmi'
	tc_custom = 'tauceti/items/clothing/hats/hats.dmi'
	icon_state = "oldwardenhelm"
	item_state = "helmet"

/obj/item/clothing/head/fedora
	name = "\improper fedora"
	icon = 'tauceti/items/clothing/hats/hats.dmi'
	tc_custom = 'tauceti/items/clothing/hats/hats.dmi'
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A really cool hat if you're a mobster. A really lame hat if you're not."
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/sombrero
	name = "sombrero"
	icon = 'tauceti/items/clothing/hats/hats.dmi'
	tc_custom = 'tauceti/items/clothing/hats/hats.dmi'
	icon_state = "sombrero"
	item_state = "helmet"
	desc = "You feel mexican just wearing this."

/obj/item/clothing/head/sombrero/green
	name = "green sombrero"
	icon = 'tauceti/items/clothing/hats/hats.dmi'
	tc_custom = 'tauceti/items/clothing/hats/hats.dmi'
	icon_state = "greensombrero"
	item_state = "greensombrero"
	desc = "As elegant as a dancing cactus."

/obj/item/clothing/head/sombrero/shamebrero
	name = "shamebrero"
	icon = 'tauceti/items/clothing/hats/hats.dmi'
	tc_custom = 'tauceti/items/clothing/hats/hats.dmi'
	icon_state = "shamebrero"
	item_state = "shamebrero"
	desc = "You never asked for this."

//Mafia
/obj/item/clothing/head/fedora_mafia
	name = "fedora"
	desc = "Someone wearing this definitely makes them cool"
	icon = 'tauceti/items/clothing/hats/mafia.dmi'
	tc_custom = 'tauceti/items/clothing/hats/mafia.dmi'
	icon_state = "hat_black"

/obj/item/clothing/head/fedora_mafia/white
	name = "white fedora"
	desc = "Someone wearing this definitely makes them cool"
	icon_state = "hat_white"

/obj/item/clothing/head/fedora_mafia/brown
 	name = "brown fedora"
 	desc = "Someone wearing this definitely makes them cool"
 	icon_state = "hat_brown"

/obj/item/clothing/head/western
	name = "western hat"
	icon = 'tauceti/items/clothing/hats/hats.dmi'
	tc_custom = 'tauceti/items/clothing/hats/hats.dmi'
	icon_state = "western_hat"
	item_state = "western_hat"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/indiana
	name = "leather hat"
	icon = 'tauceti/items/clothing/hats/hats.dmi'
	tc_custom = 'tauceti/items/clothing/hats/hats.dmi'
	icon_state = "indiana_hat"
	item_state = "indiana_hat"
	flags = FPRINT|TABLEPASS