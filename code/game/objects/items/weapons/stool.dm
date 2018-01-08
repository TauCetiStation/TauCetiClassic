/obj/item/weapon/stool
	name = "stool"
	desc = "Uh-hoh, situation is heating up."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	force = 10
	throwforce = 10
	w_class = 5.0

/obj/item/weapon/stool/throw_at()
	return

/obj/item/weapon/stool/attack_self(mob/user)
	user.drop_from_inventory(src)
	user.visible_message("<span class='notice'>[user] dropped [src].</span>", "<span class='notice'>You dropped [src].</span>")

/obj/item/weapon/stool/attack(mob/M, mob/user)
	if (prob(5) && isliving(M))
		user.visible_message("<span class='red'>[user] breaks [src] over [M]'s back!</span>")
		new /obj/item/stack/sheet/metal(get_turf(src))
		qdel(src)
		var/mob/living/T = M
		T.Weaken(10)
		T.apply_damage(20)
		return
	..()