/obj/item/stack/telecrystal
	name = "telecrystal"
	desc = "It seems to be pulsing with suspiciously enticing energies."
	singular_name = "telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "telecrystal"
	w_class = SIZE_MINUSCULE
	full_w_class = SIZE_SMALL
	max_amount = 50

/obj/item/stack/telecrystal/attack(atom/target, mob/user, proximity, params)
	if(target == user) //You can't go around smacking people with crystals to find out if they have an uplink or not.
		for(var/obj/item/weapon/implant/uplink/I in target)
			if(I.hidden_uplink)
				I.hidden_uplink.uses += amount
				use(amount)
				to_chat(user, "<span class='notice'>You press [src] onto yourself and charge your hidden uplink.</span>")
				return

/obj/item/stack/telecrystal/afterattack(atom/target, mob/user, proximity, params)
	if(proximity && isitem(target))
		var/obj/item/I = target
		if(I.hidden_uplink)
			I.hidden_uplink.uses += amount
			use(amount)
			to_chat(user, "<span class='notice'>You press [src] against your [target] and charge internal uplink.</span>")
			return

	else
		return ..()

/obj/item/stack/telecrystal/five
	amount = 5

/obj/item/stack/telecrystal/twenty
	amount = 20
