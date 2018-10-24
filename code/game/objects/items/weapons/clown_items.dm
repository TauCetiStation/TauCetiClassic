/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peals
 */
/obj/item/weapon/bananapeel/Crossed(mob/living/carbon/C)
	if(istype(C))
		C.slip("the [src]", 4, 2)

/*
 * Soap
 */
/obj/item/weapon/soap/Crossed(mob/living/carbon/C) //EXACTLY the same as bananapeel for now, so it makes sense to put it in the same dm -- Urist
	if(istype(C))
		C.slip("the [src]", 4, 2)

/obj/item/weapon/soap/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>")
	else if(istype(target,/obj/effect/decal/cleanable))
		to_chat(user, "<span class='notice'>You scrub \the [target.name] out.</span>")
		qdel(target)
	else
		to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
		target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target, mob/user, def_zone)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel && def_zone == O_MOUTH)
		user.visible_message("<span class='red'>\the [user] washes \the [target]'s mouth out with soap!</span>")
		return
	..()

/*
 * Bike Horns
 */
/obj/item/weapon/bikehorn/attack_self(mob/user)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return

/obj/item/weapon/bikehorn/dogtoy
	name = "dog toy"
	desc = "This adorable toy is made with super soft plush and has a squeaker inside for added entertainment."	//Woof!
	icon = 'icons/obj/items.dmi'
	icon_state = "dogtoy"
	item_state = "dogtoy"
