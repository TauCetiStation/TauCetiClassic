/obj/effect/proc_holder/spell/targeted/gnomecurse
	name = "Gift of the Gnome"
	desc = "This spell grands any person around you a great gift of being a Gnome."
	school = "transmutation"
	charge_type = "recharge"
	charge_max = 200
	charge_counter = 0
	clothes_req = 0
	stat_allowed = 0
	invocation = "YU'V, BN GN'MD!"
	invocation_type = "shout"
	range = 7
	selection_type = "range"
	action_icon_state = "gnomed"

/obj/effect/proc_holder/spell/targeted/gnomecurse/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/T in targets)
		if(T.gnomed)
			targets -= T

	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/target

	while(targets.len)
		target = targets[targets.len]
		targets -= target
		if(istype(target))
			break

	if(!ishuman(target))
		to_chat(user, "<span class='notice'>It'd be stupid to give [target] such a life improvement!</span>")
		return

	var/mob/living/carbon/human/H = target

	if(!(H in oview(range))) // If they are not in overview after selection.
		to_chat(user, "<span class='warning'>They are too far away!</span>")
		return

	H.speech_problem_flag = 1
	H.gnomed = rand(300, 600)

	playsound(H, 'sound/magic/GNOMED.ogg', VOL_EFFECTS_MASTER)

	var/obj/item/clothing/mask/gnome_beard/gnomebeard = new /obj/item/clothing/mask/gnome_beard
	var/obj/item/clothing/head/gnome_hat/gnomehat = new /obj/item/clothing/head/gnome_hat
	var/obj/item/clothing/under/gnome_suit/gnomeunder = new /obj/item/clothing/under/gnome_suit
	var/obj/item/clothing/suit/gnome/gnomesuit = new /obj/item/clothing/suit/gnome

	gnomebeard.canremove = FALSE
	gnomehat.canremove = FALSE
	gnomeunder.canremove = FALSE

	H.remove_from_mob(H.wear_mask)
	H.remove_from_mob(H.w_uniform)
	H.remove_from_mob(H.head)
	H.remove_from_mob(H.wear_suit)
	H.equip_to_slot_if_possible(gnomebeard, SLOT_WEAR_MASK)
	H.equip_to_slot_if_possible(gnomehat, SLOT_HEAD)
	H.equip_to_slot_if_possible(gnomeunder, SLOT_W_UNIFORM)
	H.equip_to_slot_if_possible(gnomesuit, SLOT_WEAR_SUIT)

	if(!(NOCLONE in H.mutations)) // prevents drained people from having their DNA change
		H.dna.SetSEState(SMALLSIZEBLOCK, 1)
		domutcheck(H, null)

	H.flash_eyes()

	H.visible_message("<span class='danger'>[H] bursts into flames, and becomes a gnome!</span>",
						   "<span class='danger'>Suddenly you feel like you've been GNOMED!</span>")

// A GNOMED costume
/obj/item/clothing/mask/gnome_beard
	name = "gnome beard"
	desc = "A nice looking beard, well cut."
	w_class = ITEM_SIZE_TINY
	flags = MASKCOVERSMOUTH
	icon_state = "gnome_beard"
	body_parts_covered = 0

/obj/item/clothing/mask/gnome_beard/attack_hand(mob/user)
	. = ..()
	if(!canremove)
		to_chat(user, "<span class='warning'>But you're GNOMED!</span>")

/obj/item/clothing/head/gnome_hat
	name = "gnome hat"
	desc = "A pointy red hat."
	icon_state = "gnome_hat"

/obj/item/clothing/head/gnome_hat/attack_hand(mob/user)
	. = ..()
	if(!canremove)
		to_chat(user, "<span class='warning'>But you're GNOMED!</span>")

/obj/item/clothing/under/gnome_suit
	name = "gnome's outfit"
	desc = "It's a handy gnome suit, fits you very well."
	icon_state = "gnome"
	item_state = "gnome"
	item_color = "gnome"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/gnome_suit/attack_hand(mob/user)
	. = ..()
	if(!canremove)
		to_chat(user, "<span class='warning'>But you're GNOMED!</span>")

/obj/item/clothing/suit/gnome
	name = "gnome suit"
	icon_state = "golem"
	canremove = FALSE
	flags = ABSTRACT | DROPDEL
