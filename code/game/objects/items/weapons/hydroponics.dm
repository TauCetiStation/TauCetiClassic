/* Hydroponic stuff
 * Contains:
 *		Sunflowers
 *		Nettle
 *		Deathnettle
 *		Corbcob
 */

/*
 * Sunflower
 */

/obj/item/weapon/grown/sunflower/attack(mob/M, mob/user)
	to_chat(M, "<font color='green'><b>[user]</b> smacks you with a sunflower!</font><font color='yellow'><b>FLOWER POWER</b></font>")
	to_chat(user, "<font color='green'>Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>")


/*
 * Nettle
 */
/obj/item/weapon/grown/nettle/pickup(mob/living/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		user.take_bodypart_damage(0, force)
		return

	if(!H.gloves)
		to_chat(H, "<span class='warning'>The [src] burns your bare hand!</span>")
		var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
		BP.take_damage(0, force)

/obj/item/weapon/grown/nettle/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off
		playsound(src, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)
	else
		to_chat(usr, "All the leaves have fallen off the nettle from violent whacking.")
		qdel(src)

/obj/item/weapon/grown/nettle/changePotency(newValue) //-QualityVan
	potency = newValue
	force = round((5+potency/5), 1)

/*
 * Deathnettle
 */

/obj/item/weapon/grown/deathnettle/pickup(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves)
			var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
			BP.take_damage(0, force)
	else
		user.take_bodypart_damage(0, force)

	if(prob(50))
		user.Paralyse(5)
		to_chat(user, "<span class='warning'>You are stunned by \the [src] when you try picking it up!</span>")

/obj/item/weapon/grown/deathnettle/attack(mob/living/carbon/M, mob/user)
	if(!..()) return
	if(istype(M, /mob/living))
		to_chat(M, "<span class='warning'>You are stunned by the powerful acid of the Deathnettle!</span>")

		M.log_combat(user, "stunned with [name]")

		playsound(src, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)

		M.eye_blurry += force/7
		if(prob(20))
			M.Paralyse(force/6)
			M.Weaken(force/15)
		M.drop_item()

/obj/item/weapon/grown/deathnettle/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if (force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off

	else
		to_chat(usr, "All the leaves have fallen off the deathnettle from violent whacking.")
		qdel(src)

/obj/item/weapon/grown/deathnettle/changePotency(newValue) //-QualityVan
	potency = newValue
	force = round((5+potency/2.5), 1)


/*
 * Corncob
 */
/obj/item/weapon/corncob/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/circular_saw) || istype(I, /obj/item/weapon/hatchet) || istype(I, /obj/item/weapon/kitchenknife) || istype(I, /obj/item/weapon/kitchenknife/ritual))
		to_chat(user, "<span class='notice'>You use [I] to fashion a pipe out of the corn cob!</span>")
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		qdel(src)
		return
	else
		return ..()
