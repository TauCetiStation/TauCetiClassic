#define MODKIT_FULL 1

/obj/item/device/modkit
	name = "Human hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user."
	icon_state = "modkit"
	item_state_world = "modkit_w"
	var/parts = MODKIT_FULL
	var/target_species = HUMAN

	var/list/forbidden_type = list()

/obj/item/device/modkit/proc/check_exclude(obj/item/clothing/target, mob/user)
	var/excluding = ("exclude" in target.species_restricted)
	var/in_list = (target_species in target.species_restricted)

	if(excluding ^ in_list)
		to_chat(user, "<span class='notice'>[target] is already modified.</span>")
		return FALSE
	return TRUE

/obj/item/device/modkit/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if (!target_species)
		return	//it shouldn't be null, okay?
	if(!istype(target, /obj/item/clothing))
		return
	if(!isturf(target.loc))
		to_chat(user, "<span class='warning'>[target] must be safely placed on the ground for modification.</span>")
		return

	var/obj/item/clothing/suit/space/rig/hardsuit = target
	var/obj/item/clothing/head/helmet/space/rig/helmet = hardsuit?.helmet
	if(hardsuit.can_be_modded == FALSE || helmet.can_be_modded == FALSE)
		to_chat(user, "<span class='notice'>[src] is unable to modify that.</span>")
		return
	if(check_exclude(hardsuit, user) && check_exclude(helmet, user))
		if(hardsuit && helmet && (parts & MODKIT_FULL))
			parts &= ~MODKIT_FULL
		else
			to_chat(user, "<span class='warning'>This kit has no parts for this modification left.</span>")
			return

	playsound(user, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)

	user.visible_message("<span class='red'>[user] opens \the [src] and modifies \the [target].</span>","<span class='red'> You open \the [src] and modify \the [target].</span>")

	hardsuit.refit_for_species(target_species)
	helmet.refit_for_species(target_species)

	if(!parts)
		user.drop_from_inventory(src)
		qdel(src)
		return


/obj/item/device/modkit/examine(mob/user)
	..()
	to_chat(user, "It looks as though it modifies hardsuits to fit [target_species] users.")


/obj/item/device/modkit/tajaran
	name = "Tajaran hardsuit modification kit"
	target_species = TAJARAN

/obj/item/device/modkit/unathi
	name = "Unathi hardsuit modification kit"
	target_species = UNATHI

/obj/item/device/modkit/skrell
	name = "Skrellian hardsuit modification kit"
	target_species = SKRELL

/obj/item/device/modkit/vox
	name = "Vox hardsuit modification kit"
	target_species = VOX
