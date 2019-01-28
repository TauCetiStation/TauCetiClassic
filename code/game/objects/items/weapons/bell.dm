// sprite stolen from vgstation

/obj/item/weapon/bell
	name = "bell"
	desc = "A bell to ring to get people's attention. Don't break it."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bell"
	flags = NOBLUDGEON
	hitsound = 'sound/items/oneding.ogg'
	m_amt = 75

/obj/item/weapon/bell/attack_hand(mob/user)
	if (user.a_intent == I_GRAB)
		return ..()
	else if (user.a_intent == I_HURT)
		user.visible_message("<span class='warning'>\The [user] hammers \the [src]!</span>")
		playsound(user.loc, 'sound/items/manydings.ogg', 60)
	else
		user.visible_message("<span class='notice'>\The [user] rings \the [src].</span>")
		playsound(user.loc, 'sound/items/oneding.ogg', 20)
	user.SetNextMove(CLICK_CD_INTERACT * 8)