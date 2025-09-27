/obj/item/weapon/swab
	name = "swab kit"
	desc = "Sterile cotton swab and test tube for taking DNA samples."
	icon = 'icons/obj/detective_work.dmi'
	icon_state = "swab"
	item_state_inventory = "swab"
	item_state_world = "swab_world"
	item_state = "implantcase"
	throwforce = 1
	w_class = SIZE_TINY
	throw_speed = 3
	throw_range = 5

	var/dispenser = FALSE // Means its one-use only
	var/list/dna
	var/used = FALSE
	var/inuse = FALSE

/obj/item/weapon/swab/proc/get_target_sample_protection(mob/living/carbon/human/H, body_part)
	var/list/protective_gear = list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.gloves, H.shoes)
	for(var/obj/item/clothing/C in protective_gear)
		if(body_part == HEAD) // we dont check C.body_parts_covered because some masks have it set to FALSE
			if(C.flags & HEADCOVERSMOUTH || C.flags & MASKCOVERSMOUTH)
				return C
		else if(C.body_parts_covered & body_part)
			return C
	return FALSE

/obj/item/weapon/swab/attack(mob/living/M, mob/user)
	if(used)
		to_chat(user, "<span class='warning'>[src] is already used.</span>")
		return FALSE
	if(inuse)
		to_chat(user, "<span class='warning'>[src] is being used.</span>")
		return FALSE
	if(!ishuman(M))
		to_chat(user, "<span class='warning'>You can't take a sample from [M] with [src].</span>")
		return FALSE
	var/mob/living/carbon/human/H = M
	var/target_zone = user.get_targetzone()
	if(!target_zone)
		return FALSE
	var/obj/item/organ/external/BP = H.get_bodypart(target_zone)
	if(!BP || BP.is_stump)
		to_chat(user, "<span class='warning'>They have no [BP.name]!</span>")
		return FALSE
	var/obj/item/clothing/C = get_target_sample_protection(H, BP.body_part)
	if(C)
		to_chat(user, "<span class='warning'>[H] has [C] covering their [BP.name].</span>")
		return FALSE
	if(H.isSynthetic(target_zone))
		to_chat(user, "<span class='warning'>[H]'s [target_zone] is synthetic.</span>")
		return FALSE
	inuse = TRUE
	to_chat(user, "<span class='notice'>You start taking a sample from [H].</span>")
	add_fingerprint(user)
	if(!do_after(user, 2 SECONDS, target = user))
		user.visible_message("<span class='warning'>[user] is trying to take a sample from [H], but fails.</span>")
		inuse = FALSE
		return FALSE
	if(!user.Adjacent(H))
		to_chat(user, "<span class='warning'>They moved away!</span>")
		inuse = FALSE
		return FALSE
	if(!BP || BP.is_stump)
		to_chat(user, "<span class='warning'>They have no [BP.name]!</span>")
		inuse = FALSE
		return FALSE
	var/obj/item/clothing/J = get_target_sample_protection(H, BP.body_part)
	if(J)
		to_chat(user, "<span class='warning'>[H] has [J] covering their [BP.name].</span>")
		inuse = FALSE
		return FALSE
	var/target_dna = list()
	user.visible_message("<span class='notice'>[user] takes a sample from [H] with a swab.</span>")
	if(!H.dna || !H.dna.unique_enzymes)
		target_dna = list()
	else
		target_dna[H.dna.unique_enzymes] = H.dna.b_type
	if(!dispenser)
		dna = target_dna
		set_used(H)
	else
		var/obj/item/weapon/swab/S = new(get_turf(user))
		S.dna = target_dna
		S.set_used(H)
		if(ismob(loc))
			var/mob/N = loc
			N.put_in_hands(S)
	inuse = FALSE
	return TRUE

/obj/item/weapon/swab/afterattack(atom/A, mob/user, proximity)
	if(!proximity || istype(A, /obj/machinery/microscope))
		return

	if(isliving(A))
		return

	if(used)
		to_chat(user, "<span class='warning'>[src] is already used.</span>")
		return

	if(inuse)
		to_chat(user, "<span class='warning'>[src] is being used.</span>")
		return

	add_fingerprint(user)

	if(!A.blood_DNA)
		to_chat(user, "<span class='warning'>There is no blood to sample from [A].</span>")
		return

	inuse = TRUE
	to_chat(user, "<span class='notice'>You start sampling [A].</span>")
	if(do_after(user, 2 SECONDS, target = user))
		if(!user.Adjacent(A))
			inuse = FALSE
			return
		var/target_dna
		if(A.blood_DNA && A.blood_DNA.len)
			target_dna = A.blood_DNA.Copy()
		else
			to_chat(user, "<span class='warning'>There is no blood to sample from [A].</span>")
			inuse = FALSE
			return
		if(target_dna)
			user.visible_message(
				"<span class='notice'>[user] takes a sample from [A] with a swab.</span>",
				"<span class='notice'>You take a sample from [A] with a swab.</span>")
			if(!dispenser)
				dna = target_dna
				set_used(A)
			else
				var/obj/item/weapon/swab/S = new(get_turf(user))
				S.dna = target_dna
				S.set_used(A)
				if(ismob(loc))
					var/mob/M = loc
					M.put_in_hands(S)
	inuse = FALSE

/obj/item/weapon/swab/proc/set_used(atom/source)
	name = "[initial(name)] (DNA - [source])"
	desc = "[initial(desc)]: 'DNA sample from [source]'"
	icon_state = "swab_used"
	item_state_inventory = "swab_used"
	item_state_world = "swab_used_world"
	update_world_icon()
	used = TRUE

/obj/item/weapon/forensic_sample_kit
	name = "fiber collection kit"
	desc = "Magnifying glass and tweezers. Used to collect fibers."
	icon = 'icons/obj/detective_work.dmi'
	icon_state = "m_glass"
	item_state_world = "m_glass_world"
	item_state = "m_glass"
	w_class = SIZE_TINY

	var/evidence_type = "fiber"
	var/evidence_path = /obj/item/weapon/forensic_sample/fibers
	var/inuse = FALSE

/obj/item/weapon/forensic_sample_kit/proc/can_take_sample(mob/user, atom/supplied)
	return (supplied.suit_fibers && supplied.suit_fibers.len)

/obj/item/weapon/forensic_sample_kit/proc/take_sample(mob/user, atom/supplied)
	if(inuse)
		to_chat(user, "<span class='warning'>[src] is being used.</span>")
		return
	add_fingerprint(user)
	inuse = TRUE
	to_chat(user, "<span class='notice'>You start sampling [supplied].</span>")
	if(do_after(user, 2 SECONDS, target = user))
		if(!supplied || !user.Adjacent(supplied))
			to_chat(user, "<span class='warning'>Failed to take a sample.</span>")
			inuse = FALSE
			return
		var/obj/item/weapon/forensic_sample/S = new evidence_path(get_turf(user), supplied)
		user.visible_message(
			"<span class='notice'>[user] takes a [evidence_type] sample from [supplied] with a [src]</span>",
			"<span class='notice'>You move [S.evidence.len] [S.evidence.len > 1 ? "[evidence_type]s" : "[evidence_type]"] inside [S].</span>")
		if(ismob(loc))
			var/mob/M = loc
			M.put_in_hands(S)
	inuse = FALSE

/obj/item/weapon/forensic_sample_kit/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(can_take_sample(user, A))
		take_sample(user, A)
	else
		to_chat(user, "<span class='warning'>There is no [evidence_type] to sample from [A].</span>")

/obj/item/weapon/forensic_sample_kit/powder
	name = "fingerprint powder"
	desc = "A jar of aluminum powder and a specialized brush."
	icon_state = "dust"
	item_state_world = "dust_world"
	item_state = "teapot"
	evidence_type = "fingerprint"
	evidence_path = /obj/item/weapon/forensic_sample/print

/obj/item/weapon/forensic_sample_kit/powder/can_take_sample(mob/user, atom/supplied)
	return (supplied.fingerprints && supplied.fingerprints.len)

/obj/item/weapon/forensic_sample
	name = "Analisys sample"
	icon = 'icons/obj/detective_work.dmi'
	w_class = SIZE_MINUSCULE
	var/list/evidence = list()

/obj/item/weapon/forensic_sample/atom_init(mapload, atom/supplied)
	. = ..()
	if(supplied)
		copy_evidence(supplied)
		name = "[initial(name)] (\the [supplied])"

/obj/item/weapon/forensic_sample/proc/copy_evidence(atom/supplied)
	if(supplied.suit_fibers && supplied.suit_fibers.len)
		evidence = supplied.suit_fibers.Copy()

/obj/item/weapon/forensic_sample/fibers
	name = "fiber bag"
	desc = "Used to store fiber evidence for the detective."
	icon_state = "fiberbag"
	item_state_world = "fiberbag_world"

/obj/item/weapon/forensic_sample/fibers/proc/merge_evidence(obj/item/weapon/forensic_sample/supplied, mob/user)
	if(!supplied.evidence || !supplied.evidence.len)
		return FALSE
	evidence |= supplied.evidence
	name = "[initial(name)] (combined)"
	to_chat(user, "<span class='notice'>You transfer \the [supplied] into \the [src].</span>")
	return TRUE

/obj/item/weapon/forensic_sample/fibers/attackby(obj/O, mob/user)
	if(O.type == type)
		if(merge_evidence(O, user))
			user.unEquip(O)
			qdel(O)
		return TRUE
	return ..()

/obj/item/weapon/forensic_sample/print
	name = "fingerprint tape"
	desc = "Used to store fingerprint evidence for the detective."
	icon_state = "fingerprint_tape"
	item_state_world = "fingerprint_tape_world"

/obj/item/weapon/forensic_sample/print/copy_evidence(atom/supplied)
	if(supplied.fingerprints && supplied.fingerprints.len)
		for(var/print in supplied.fingerprints)
			evidence[print] = supplied.fingerprints[print]
