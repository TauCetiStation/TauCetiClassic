#define MODKIT_HELMET 1
#define MODKIT_SUIT 2
#define MODKIT_FULL 3

/obj/item/device/modkit
	name = "Human hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user."
	icon_state = "modkit"
	var/parts = MODKIT_FULL
	var/target_species = HUMAN

	var/list/permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig,
		/obj/item/clothing/suit/space/rig
		)

	var/list/forbidden_type = list()

/obj/item/device/modkit/afterattack(atom/target, mob/user, proximity, params)
	if(get_dist(src,target)>1)
		return
	if (!target_species)
		return	//it shouldn't be null, okay?

	var/allowed = 0
	for (var/permitted_type in permitted_types)
		if(istype(target, permitted_type) && !(target.type in forbidden_type))
			allowed = 1

	var/obj/item/clothing/I = target
	if (!istype(I) || !allowed)
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
	target_species = TAJARAN

/obj/item/device/modkit/engineering/unathi
	name = "Unathi engineering hardsuit modification kit"
	target_species = UNATHI

/obj/item/device/modkit/engineering/skrell
	name = "Skrellian engineering hardsuit modification kit"
	target_species = SKRELL

/obj/item/device/modkit/engineering/vox
	name = "Vox engineering hardsuit modification kit"
	target_species = VOX



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
	target_species = SKRELL

/obj/item/device/modkit/engineering/chief/tajaran
	name = "Tajaran chief-engineers hardsuit modification kit"
	target_species = TAJARAN

/obj/item/device/modkit/engineering/chief/unathi
	name = "Unathi chief-engineers hardsuit modification kit"
	target_species = UNATHI

/obj/item/device/modkit/engineering/chief/vox
	name = "Vox chief-engineers hardsuit modification kit"
	target_species = VOX



/obj/item/device/modkit/atmos
	name = "Atmospherics hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/atmos,
		/obj/item/clothing/suit/space/rig/atmos
		)

/obj/item/device/modkit/atmos/tajaran
	name = "Tajaran atmospherics hardsuit modification kit"
	target_species = TAJARAN

/obj/item/device/modkit/atmos/unathi
	name = "Unathi atmospherics hardsuit modification kit"
	target_species = UNATHI

/obj/item/device/modkit/atmos/skrell
	name = "Skrellian atmospherics hardsuit modification kit"
	target_species = SKRELL

/obj/item/device/modkit/atmos/vox
	name = "Vox atmospherics hardsuit modification kit"
	target_species = VOX



/obj/item/device/modkit/med
	name = "Medical hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/medical,
		/obj/item/clothing/suit/space/rig/medical
		)
	forbidden_type = list(
		/obj/item/clothing/head/helmet/space/rig/medical/cmo,
		/obj/item/clothing/suit/space/rig/medical/cmo
	)

/obj/item/device/modkit/med/tajaran
	name = "Tajaran medical hardsuit modification kit"
	target_species = TAJARAN

/obj/item/device/modkit/med/unathi
	name = "Unathi medical hardsuit modification kit"
	target_species = UNATHI

/obj/item/device/modkit/med/skrell
	name = "Skrellian medical hardsuit modification kit"
	target_species = SKRELL

/obj/item/device/modkit/med/vox
	name = "Vox medical hardsuit modification kit"
	target_species = VOX



/obj/item/device/modkit/med/cmo
	name = "CMO hardsuit modification kit"
	forbidden_type = list()

/obj/item/device/modkit/med/cmo/skrell
	name = "Skrellian CMO hardsuit modification kit"
	target_species = SKRELL

/obj/item/device/modkit/med/cmo/tajaran
	name = "Tajaran CMO hardsuit modification kit"
	target_species = TAJARAN

/obj/item/device/modkit/med/cmo/unathi
	name = "Unathi CMO hardsuit modification kit"
	target_species = UNATHI

/obj/item/device/modkit/med/cmo/vox
	name = "Unathi CMO hardsuit modification kit"
	target_species = VOX



/obj/item/device/modkit/sec
	name = "Security hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/security,
		/obj/item/clothing/suit/space/rig/security
		)
	forbidden_type = list(
		/obj/item/clothing/head/helmet/space/rig/security/hos,
		/obj/item/clothing/suit/space/rig/security/hos
	)

/obj/item/device/modkit/sec/tajaran
	name = "Tajaran security hardsuit modification kit"
	target_species = TAJARAN

/obj/item/device/modkit/sec/unathi
	name = "Unathi security hardsuit modification kit"
	target_species = UNATHI

/obj/item/device/modkit/sec/skrell
	name = "Skrellian security hardsuit modification kit"
	target_species = SKRELL

/obj/item/device/modkit/sec/vox
	name = "Vox security hardsuit modification kit"
	target_species = VOX



/obj/item/device/modkit/sec/hos
	name = "HoS hardsuit modification kit"
	forbidden_type = list()

/obj/item/device/modkit/sec/hos/skrell
	name = "Skrellian HoS hardsuit modification kit"
	target_species = SKRELL

/obj/item/device/modkit/sec/hos/tajaran
	name = "Tajaran HoS hardsuit modification kit"
	target_species = TAJARAN

/obj/item/device/modkit/sec/hos/unathi
	name = "Unathi HoS hardsuit modification kit"
	target_species = UNATHI

/obj/item/device/modkit/sec/hos/vox
	name = "Vox HoS hardsuit modification kit"
	target_species = VOX



/obj/item/device/modkit/mining
	name = "Mining hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/mining,
		/obj/item/clothing/suit/space/rig/mining
		)

/obj/item/device/modkit/mining/tajaran
	name = "Tajaran mining hardsuit modification kit"
	target_species = TAJARAN

/obj/item/device/modkit/mining/unathi
	name = "Unathi mining hardsuit modification kit"
	target_species = UNATHI

/obj/item/device/modkit/mining/skrell
	name = "Skrellian mining hardsuit modification kit"
	target_species = SKRELL

/obj/item/device/modkit/mining/vox
	name = "Vox mining hardsuit modification kit"
	target_species = VOX



/obj/item/device/modkit/syndie
	name = "Gorlex hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/syndi,
		/obj/item/clothing/suit/space/rig/syndi,
		/obj/item/clothing/head/helmet/space/rig/syndi/heavy,
		/obj/item/clothing/suit/space/rig/syndi/heavy
		)

/obj/item/device/modkit/syndie/tajaran
	name = "Tajaran gorlex hardsuit modification kit"
	target_species = TAJARAN
	parts = MODKIT_SUIT

/obj/item/device/modkit/syndie/unathi
	name = "Unathi gorlex hardsuit modification kit"
	target_species = UNATHI
	parts = MODKIT_SUIT

/obj/item/device/modkit/syndie/skrell
	name = "Skrellian gorlex hardsuit modification kit"
	target_species = SKRELL
	parts = MODKIT_HELMET

/obj/item/device/modkit/syndie/vox
	name = "Vox gorlex hardsuit modification kit"
	target_species = VOX



/obj/item/device/modkit/wizard
	name = "Magical hardsuit modification kit"
	permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig/wizard,
		/obj/item/clothing/suit/space/rig/wizard
		)

/obj/item/device/modkit/wizard/tajaran
	name = "Tajaran magical hardsuit modification kit"
	target_species = TAJARAN

/obj/item/device/modkit/wizard/unathi
	name = "Unathi magical hardsuit modification kit"
	target_species = UNATHI

/obj/item/device/modkit/wizard/skrell
	name = "Skrellian magical hardsuit modification kit"
	target_species = SKRELL

/obj/item/device/modkit/wizard/vox
	name = "Vox magical hardsuit modification kit"
	target_species = VOX
