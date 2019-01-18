/obj/item/weapon/gavelhammer
	name = "gavel hammer"
	desc = "Order, order! No bombs in my courthouse."
	icon = 'icons/obj/items.dmi'
	icon_state = "gavelhammer"
	force = 5
	throwforce = 6
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("bashed", "battered", "judged", "whacked")

/obj/item/weapon/gavelhammer/suicide_act(mob/user)
	user.visible_message("<span class='warning'>[user] has sentenced \himself to death with [src]! It looks like \he's trying to commit suicide!</span>")
	playsound(src, 'sound/items/gavel.ogg', 50, 1, -1)
	return (BRUTELOSS)
