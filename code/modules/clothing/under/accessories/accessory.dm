/obj/item/clothing/accessory
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	item_state = "" // no inhands
	item_color = "bluetie"
	slot_flags = SLOT_FLAGS_TIE
	w_class = ITEM_SIZE_SMALL

	var/slot = "decor"
	var/obj/item/clothing/under/has_suit = null // the suit the tie may be attached to
	var/image/inv_overlay = null                // overlay used when attached to clothing.
	var/layer_priority = 0                      // so things such as medals won't be drawn under webbings or holsters on mob, still problem with inside inventory.

/obj/item/clothing/accessory/atom_init()
	. = ..()
	inv_overlay = image("icon" = 'icons/obj/clothing/ties_overlay.dmi', "icon_state" = "[item_color ? "[item_color]" : "[icon_state]"]")

//when user attached an accessory to S
/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/under/S, mob/user, silent)
	if(!istype(S))
		return
	has_suit = S
	loc = has_suit
	has_suit.overlays += inv_overlay

	if(!silent)
		to_chat(user, "<span class='notice'>You attach [src] to [has_suit].</span>")
	add_fingerprint(user)

/obj/item/clothing/accessory/proc/on_removed(mob/user)
	if(!has_suit)
		return
	has_suit.overlays -= inv_overlay
	has_suit = null
	usr.put_in_hands(src)
	add_fingerprint(user)

/obj/item/clothing/accessory/attack_hand(mob/user)
	if(has_suit)
		has_suit.remove_accessory(user)
		return // we aren't an object on the ground so don't call parent
	..()

/obj/item/clothing/accessory/tie
	layer_priority = 0.1

/obj/item/clothing/accessory/tie/blue
	name = "blue tie"
	icon_state = "bluetie"
	item_color = "bluetie"

/obj/item/clothing/accessory/tie/red
	name = "red tie"
	icon_state = "redtie"
	item_color = "redtie"

/obj/item/clothing/accessory/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"
	item_color = "horribletie"

/obj/item/clothing/accessory/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	item_color = "stethoscope"
	layer_priority = 0.1

/obj/item/clothing/accessory/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(user.a_intent == "help")
			var/target_zone = parse_zone(user.zone_sel.selecting)
			if(target_zone)
				var/their = "their"
				switch(M.gender)
					if(MALE)	their = "his"
					if(FEMALE)	their = "her"

				var/sound = "pulse"
				var/sound_strength

				if(M.stat == DEAD || (M.status_flags & FAKEDEATH))
					sound_strength = "cannot hear"
					sound = "anything"
				else
					sound_strength = "hear a weak"
					switch(target_zone)
						if(BP_CHEST)
							if(M.oxyloss < 50)
								sound_strength = "hear a healthy"
							sound = "pulse and respiration"
						if(O_EYES, O_MOUTH)
							sound_strength = "cannot hear"
							sound = "anything"
						else
							sound_strength = "hear a weak"

				user.visible_message("[user] places [src] against [M]'s [target_zone] and listens attentively.", "You place [src] against [their] [target_zone]. You [sound_strength] [sound].")
				return
	return ..(M, user)


//Medals
/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	item_color = "bronze"
	layer_priority = 0.1

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/accessory/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/nobel_science
	name = "nobel sciences award"
	desc = "A bronze medal which represents significant contributions to the field of science or engineering."

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	item_color = "silver"

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/accessory/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	item_color = "gold"

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."
	icon_state = "gold_nt"

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentComm. To recieve such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/holobadge

	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	item_color = "holobadge"
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_TIE

	var/emagged = FALSE // Emagging removes Sec check.
	var/stored_name = null

/obj/item/clothing/accessory/holobadge/cord
	icon_state = "holobadge-cord"
	item_color = "holobadge-cord"
	slot_flags = SLOT_FLAGS_MASK | SLOT_FLAGS_TIE

/obj/item/clothing/accessory/holobadge/attack_self(mob/user)
	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
		return
	if(isliving(user))
		user.visible_message(
			"<span class='warning'>[user] displays their NanoTrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>",
			"<span class='warning'>You display your NanoTrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>")

/obj/item/clothing/accessory/holobadge/attackby(obj/item/O, mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if (istype(O, /obj/item/weapon/card/emag))
		if (emagged)
			to_chat(user, "<span class='warning'>[src] is already cracked.</span>")
			return
		else
			emagged = TRUE
			to_chat(user, "<span class='warning'>You swipe [O] and crack the holobadge security checks.</span>")
			return

	else if(istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))

		var/obj/item/weapon/card/id/id_card = null

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_security in id_card.access || emagged)
			to_chat(user, "You imprint your ID details onto the badge.")
			stored_name = id_card.registered_name
			name = "holobadge ([stored_name])"
			desc = "This glowing blue badge marks [stored_name] as THE LAW."
		else
			to_chat(user, "[src] rejects your insufficient access rights.")
		return
	..()

/obj/item/clothing/accessory/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message(
			"<span class='warning'>[user] invades [M]'s personal space, thrusting [src] into their face insistently.</span>",
			"<span class='warning'>You invade [M]'s personal space, thrusting [src] into their face insistently. You are the law.</span>")
