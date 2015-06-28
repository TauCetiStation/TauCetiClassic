#define MODKIT_HELMET 1
#define MODKIT_SUIT 2
#define MODKIT_FULL 3

/obj/item/device/modkit
	name = "hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user."
	icon_state = "modkit"
	var/parts = MODKIT_FULL
	var/target_species = "Human"

	var/list/permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig,
		/obj/item/clothing/suit/space/rig
		)

/obj/item/device/modkit/afterattack(obj/O, mob/user as mob)
	if(get_dist(src,O)>1)
		return
	if (!target_species)
		return	//it shouldn't be null, okay?

	if(!parts)
		user << "<span class='warning'>This kit has no parts for this modification left.</span>"
		user.drop_from_inventory(src)
		qdel(src)
		return

	var/allowed = 0
	for (var/permitted_type in permitted_types)
		if(istype(O, permitted_type))
			allowed = 1

	var/obj/item/clothing/I = O
	if (!istype(I) || !allowed)
		user << "<span class='notice'>[src] is unable to modify that.</span>"
		return

	var/excluding = ("exclude" in I.species_restricted)
	var/in_list = (target_species in I.species_restricted)
	if (excluding ^ in_list)
		user << "<span class='notice'>[I] is already modified.</span>"

	if(!isturf(O.loc))
		user << "<span class='warning'>[O] must be safely placed on the ground for modification.</span>"
		return

	playsound(user.loc, 'sound/items/Screwdriver.ogg', 100, 1)

	user.visible_message("\red [user] opens \the [src] and modifies \the [O].","\red You open \the [src] and modify \the [O].")

	I.refit_for_species(target_species)

	if (istype(I, /obj/item/clothing/head/helmet))
		parts &= ~MODKIT_HELMET
	if (istype(I, /obj/item/clothing/suit))
		parts &= ~MODKIT_SUIT

	if(!parts)
		user.drop_from_inventory(src)
		qdel(src)

/obj/item/device/modkit/examine()
	..()
	usr << "It looks as though it modifies hardsuits to fit [target_species] users."

/obj/item/device/modkit/tajaran
	name = "tajaran hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajaran."
	target_species = "Tajaran"

/obj/item/device/modkit/unathi
	name = "unathi hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Unathi."
	target_species = "Unathi"

/obj/item/device/modkit/skrell
	name = "skrellian hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Skrell."
	target_species = "Skrell"

/obj/item/device/modkit/tajaran/engineering
	name = "tajaran engineering hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajaran."
	target_species = "Tajaran"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/engineering,
		/obj/item/clothing/suit/space/rig/engineering
		)

/obj/item/device/modkit/tajaran/atmos
	name = "tajaran atmospherics hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajaran."
	target_species = "Tajaran"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/atmos,
		/obj/item/clothing/suit/space/rig/atmos
		)

/obj/item/device/modkit/tajaran/med
	name = "tajaran medical hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajaran."
	target_species = "Tajaran"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/medical,
		/obj/item/clothing/suit/space/rig/medical
		)

/obj/item/device/modkit/tajaran/sec
	name = "tajaran security hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajaran."
	target_species = "Tajaran"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/security,
		/obj/item/clothing/suit/space/rig/security
		)

/obj/item/device/modkit/tajaran/mining
	name = "tajaran mining hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajaran."
	target_species = "Tajaran"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/mining,
		/obj/item/clothing/suit/space/rig/mining
		)

/obj/item/device/modkit/unathi/engineering
	name = "unathi engineering hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Unathi."
	target_species = "Unathi"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/engineering,
		/obj/item/clothing/suit/space/rig/engineering
		)

/obj/item/device/modkit/unathi/atmos
	name = "unathi atmospherics hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Unathi."
	target_species = "Unathi"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/atmos,
		/obj/item/clothing/suit/space/rig/atmos
		)

/obj/item/device/modkit/unathi/med
	name = "unathi medical hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Unathi."
	target_species = "Unathi"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/medical,
		/obj/item/clothing/suit/space/rig/medical
		)

/obj/item/device/modkit/unathi/sec
	name = "unathi security hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Unathi."
	target_species = "Unathi"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/security,
		/obj/item/clothing/suit/space/rig/security
		)

/obj/item/device/modkit/unathi/mining
	name = "unathi mining hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Unathi."
	target_species = "Unathi"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/mining,
		/obj/item/clothing/suit/space/rig/mining
		)

/obj/item/device/modkit/skrell/engineering
	name = "skrellian engineering hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Skrell."
	target_species = "Skrell"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/engineering,
		/obj/item/clothing/suit/space/rig/engineering
		)

/obj/item/device/modkit/skrell/atmos
	name = "skrellian atmospherics hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Skrell."
	target_species = "Skrell"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/atmos,
		/obj/item/clothing/suit/space/rig/atmos
		)

/obj/item/device/modkit/skrell/med
	name = "skrellian medical hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Skrell."
	target_species = "Skrell"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/medical,
		/obj/item/clothing/suit/space/rig/medical
		)

/obj/item/device/modkit/skrell/sec
	name = "skrellian security hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Skrell."
	target_species = "Skrell"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/security,
		/obj/item/clothing/suit/space/rig/security
		)

/obj/item/device/modkit/skrell/mining
	name = "skrellian mining hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Skrell."
	target_species = "Skrell"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/mining,
		/obj/item/clothing/suit/space/rig/mining
		)

/obj/item/device/modkit/human
	name = "human hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Human."
	target_species = "Human"