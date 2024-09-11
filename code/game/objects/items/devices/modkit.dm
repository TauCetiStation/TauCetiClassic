#define MODKIT_HELMET 1
#define MODKIT_SUIT 2
#define MODKIT_FULL 3

/obj/item/device/modkit
	name = "Human hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user."
	icon_state = "modkit"
	var/parts = MODKIT_FULL
	var/target_species = HUMAN

	var/list/forbidden_type = list()

/obj/item/device/modkit/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if (!target_species)
		return	//it shouldn't be null, okay?

	var/obj/item/clothing/I = target
	if (I.can_be_modded == FALSE)
		to_chat(user, "<span class='notice'>[src] is unable to modify that.</span>")
		return

	var/excluding = ("exclude" in I.species_restricted)
	var/in_list = (target_species in I.species_restricted)

	if (excluding ^ in_list)
		to_chat(user, "<span class='notice'>[I] is already modified.</span>")
		return

	if(!isturf(target.loc))
		to_chat(user, "<span class='warning'>[target] must be safely placed on the ground for modification.</span>")
		return

	if(istype(I, /obj/item/clothing/head/helmet) && (parts & MODKIT_HELMET))
		parts &= ~MODKIT_HELMET
	else if(istype(I, /obj/item/clothing/suit) && (parts & MODKIT_SUIT))
		parts &= ~MODKIT_SUIT
	else
		to_chat(user, "<span class='warning'>This kit has no parts for this modification left.</span>")
		return

	playsound(user, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)

	user.visible_message("<span class='red'>[user] opens \the [src] and modifies \the [target].</span>","<span class='red'> You open \the [src] and modify \the [target].</span>")

	I.refit_for_species(target_species)

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
