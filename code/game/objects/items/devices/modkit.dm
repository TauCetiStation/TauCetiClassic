#define MODKIT_HELMET 1
#define MODKIT_SUIT 2
#define MODKIT_FULL 3

/obj/item/device/modkit
	name = "Human hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user."
	icon_state = "modkit"
	var/parts = MODKIT_FULL
	var/target_species = "Human"

	var/list/permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig,
		/obj/item/clothing/suit/space/rig
		)

	var/list/forbidden_type = list()

/obj/item/device/modkit/afterattack(obj/O, mob/user)
	if(get_dist(src,O)>1)
		return
	if (!target_species)
		return	//it shouldn't be null, okay?

	if(!parts)
		to_chat(user, "<span class='warning'>This kit has no parts for this modification left.</span>")
		user.drop_from_inventory(src)
		qdel(src)
		return

	var/allowed = 0
	for (var/permitted_type in permitted_types)
		if(istype(O, permitted_type) && !(O.type in forbidden_type))
			allowed = 1

	var/obj/item/clothing/I = O
	if (!istype(I) || !allowed)
		to_chat(user, "<span class='notice'>[src] is unable to modify that.</span>")
		return

	var/excluding = ("exclude" in I.species_restricted)
	var/in_list = (target_species in I.species_restricted)
	if (excluding ^ in_list)
		to_chat(user, "<span class='notice'>[I] is already modified.</span>")

	if(!isturf(O.loc))
		to_chat(user, "<span class='warning'>[O] must be safely placed on the ground for modification.</span>")
		return

	playsound(user.loc, 'sound/items/Screwdriver.ogg', 100, 1)

	user.visible_message("<span class='red'>[user] opens \the [src] and modifies \the [O].</span>","<span class='red'> You open \the [src] and modify \the [O].</span>")

	I.refit_for_species(target_species)

	if (istype(I, /obj/item/clothing/head/helmet))
		parts &= ~MODKIT_HELMET
	if (istype(I, /obj/item/clothing/suit))
		parts &= ~MODKIT_SUIT

	if(!parts)
		user.drop_from_inventory(src)
		qdel(src)


/obj/item/device/modkit/examine(mob/user)
	..()
	to_chat(user, "It looks as though it modifies hardsuits to fit [target_species] users.")


/obj/item/device/modkit/tajaran
	name = "Tajaran hardsuit modification kit"
	target_species = "Tajaran"

/obj/item/device/modkit/unathi
	name = "Unathi hardsuit modification kit"
	target_species = "Unathi"

/obj/item/device/modkit/skrell
	name = "Skrellian hardsuit modification kit"
	target_species = "Skrell"


/obj/item/device/modkit/engineering
	name = "Engineering hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/engineering,
		/obj/item/clothing/suit/space/rig/engineering
		)
	forbidden_type = list(
		/obj/item/clothing/head/helmet/space/rig/engineering/chief,
		/obj/item/clothing/suit/space/rig/engineering/chief
	)

/obj/item/device/modkit/engineering/tajaran
	name = "Tajaran engineering hardsuit modification kit"
	target_species = "Tajaran"

/obj/item/device/modkit/engineering/unathi
	name = "Unathi engineering hardsuit modification kit"
	target_species = "Unathi"

/obj/item/device/modkit/engineering/skrell
	name = "Skrellian engineering hardsuit modification kit"
	target_species = "Skrell"


/obj/item/device/modkit/engineering/chief
	name = "Chief-engineers hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/engineering,
		/obj/item/clothing/suit/space/rig/engineering,
		/obj/item/clothing/head/helmet/space/rig/atmos,
		/obj/item/clothing/suit/space/rig/atmos
		)
	forbidden_type = list()

/obj/item/device/modkit/engineering/chief/skrell
	name = "Skrellian chief-engineers hardsuit modification kit"
	target_species = "Skrell"


/obj/item/device/modkit/atmos
	name = "Atmospherics hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/atmos,
		/obj/item/clothing/suit/space/rig/atmos
		)

/obj/item/device/modkit/atmos/tajaran
	name = "Tajaran atmospherics hardsuit modification kit"
	target_species = "Tajaran"

/obj/item/device/modkit/atmos/unathi
	name = "Unathi atmospherics hardsuit modification kit"
	target_species = "Unathi"

/obj/item/device/modkit/atmos/skrell
	name = "Skrellian atmospherics hardsuit modification kit"
	target_species = "Skrell"


/obj/item/device/modkit/med
	name = "Medical hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/medical,
		/obj/item/clothing/suit/space/rig/medical
		)

/obj/item/device/modkit/med/tajaran
	name = "Tajaran medical hardsuit modification kit"
	target_species = "Tajaran"

/obj/item/device/modkit/med/unathi
	name = "Unathi medical hardsuit modification kit"
	target_species = "Unathi"

/obj/item/device/modkit/med/skrell
	name = "Skrellian medical hardsuit modification kit"
	target_species = "Skrell"


/obj/item/device/modkit/sec
	name = "Security hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/security,
		/obj/item/clothing/suit/space/rig/security
		)

/obj/item/device/modkit/sec/tajaran
	name = "Tajaran security hardsuit modification kit"
	target_species = "Tajaran"

/obj/item/device/modkit/sec/unathi
	name = "Unathi security hardsuit modification kit"
	target_species = "Unathi"

/obj/item/device/modkit/sec/skrell
	name = "Skrellian security hardsuit modification kit"
	target_species = "Skrell"


/obj/item/device/modkit/mining
	name = "Mining hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/mining,
		/obj/item/clothing/suit/space/rig/mining
		)

/obj/item/device/modkit/mining/tajaran
	name = "Tajaran mining hardsuit modification kit"
	target_species = "Tajaran"

/obj/item/device/modkit/mining/unathi
	name = "Unathi mining hardsuit modification kit"
	target_species = "Unathi"

/obj/item/device/modkit/mining/skrell
	name = "Skrellian mining hardsuit modification kit"
	target_species = "Skrell"


/obj/item/device/modkit/syndie
	name = "Gorlex hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/syndi,
		/obj/item/clothing/suit/space/rig/syndi
		)

/obj/item/device/modkit/syndie/tajaran
	name = "Tajaran gorlex hardsuit modification kit"
	target_species = "Tajaran"

/obj/item/device/modkit/syndie/unathi
	name = "Unathi gorlex hardsuit modification kit"
	target_species = "Unathi"

/obj/item/device/modkit/syndie/skrell
	name = "Skrellian gorlex hardsuit modification kit"
	target_species = "Skrell"


/obj/item/device/modkit/wizard
	name = "Magical hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/wizard,
		/obj/item/clothing/suit/space/rig/wizard
		)

/obj/item/device/modkit/wizard/tajaran
	name = "Tajaran magical hardsuit modification kit"
	target_species = "Tajaran"

/obj/item/device/modkit/wizard/unathi
	name = "Unathi magical hardsuit modification kit"
	target_species = "Unathi"

/obj/item/device/modkit/wizard/skrell
	name = "Skrellian magical hardsuit modification kit"
	target_species = "Skrell"
