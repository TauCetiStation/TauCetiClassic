// sprite stolen from vgstation

/obj/item/weapon/bell
	name = "bell"
	desc = "A bell to ring to get people's attention. Don't break it."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bell"
	flags = NOBLUDGEON
	hitsound = list('sound/items/oneding.ogg')
	m_amt = 75
	var/next_ring = 0

/obj/item/weapon/bell/attack_hand(mob/user)
	if(user.a_intent == INTENT_GRAB)
		return ..()
	if(next_ring >= world.time)
		return

	if(user.a_intent == INTENT_HARM)
		user.visible_message("<span class='warning'>\The [user] hammers \the [src]!</span>")
		playsound(user, 'sound/items/manydings.ogg', VOL_EFFECTS_MASTER)
	else
		user.visible_message("<span class='notice'>\The [user] rings \the [src].</span>")
		playsound(user, 'sound/items/oneding.ogg', VOL_EFFECTS_MASTER, 20)
	user.SetNextMove(CLICK_CD_INTERACT)
	next_ring = world.time + 3 SECONDS
