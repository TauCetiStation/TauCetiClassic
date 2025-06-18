/mob
	var/dirty_hands_transfers = 0
	var/track_blood = 0
	var/list/feet_blood_DNA
	var/datum/dirt_cover/feet_dirt_color

/obj/item/clothing/gloves
	var/dirt_transfers = 0

/obj/item/clothing/shoes
	var/track_blood = 0

/obj/item/weapon/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = SIZE_MINUSCULE
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 5
	can_be_placed_into = null
	pickup_sound = null
	dropped_sound = null

/obj/item/weapon/reagent_containers/glass/rag/attack_self(mob/user)
	return

/obj/item/weapon/reagent_containers/glass/rag/attack(atom/target, mob/user , flag)
	if(ismob(target) && target.reagents && reagents.total_volume)
		user.visible_message("<span class='warning'>\The [target] has been smothered with \the [src] by \the [user]!</span>", "<span class='warning'>You smother \the [target] with \the [src]!</span>", "You hear some struggling and muffled cries of surprise")
		// Yeah, it turns out the rag splashes.
		reagents.standard_splash(target, user=user)
		return
	else
		..()

/obj/item/weapon/reagent_containers/glass/rag/afterattack(atom/target, mob/user, proximity, params)
	if (!proximity || user.is_busy())
		return

	var/is_glass = istype(target, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass)

	if (!is_glass && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target] off before cleaning it.</span>")
	else if (src in user)
		user.visible_message("<span class='notice'>[user] starts to wipe down [target] with [src].</span>")

		var/new_target = is_glass ? user : target

		if (do_after(user, 30, target = new_target))
			user.visible_message("<span class='notice'>[user] finishes wiping off the [new_target].</span>")
			target.clean_blood()

/obj/item/weapon/reagent_containers/glass/rag/examine()
	if (!usr)
		return
	to_chat(usr, "That's \a [src].")
	to_chat(usr, desc)
	return
