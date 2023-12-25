/obj/item/clothing/accessory
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/accessory.dmi'
	icon_state = "bluetie"
	slot_flags = SLOT_FLAGS_TIE
	w_class = SIZE_TINY

	var/slot = "decor"
	var/obj/item/clothing/has_suit = null // the suit the accessory may be attached to
	var/image/inv_overlay = null                // overlay used when attached to clothing.
	var/layer_priority = 0                      // so things such as medals won't be drawn under webbings or holsters on mob, still problem with inside inventory.

/obj/item/clothing/accessory/atom_init()
	. = ..()
	inv_overlay = image("icon" = 'icons/obj/clothing/accessory_overlay.dmi', "icon_state" = icon_state)

//when user attached an accessory to S
/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/S, mob/user, silent)
	if(!istype(S))
		return
	has_suit = S
	loc = has_suit
	has_suit.add_overlay(inv_overlay)

	if(!silent)
		to_chat(user, "<span class='notice'>You attach [src] to [has_suit].</span>")
	add_fingerprint(user)

/obj/item/clothing/accessory/proc/on_removed(mob/user)
	if(!has_suit)
		return
	has_suit.cut_overlay(inv_overlay)
	has_suit = null
	usr.put_in_hands(src)
	add_fingerprint(user)

/obj/item/clothing/accessory/attack_hand(mob/user)
	if(has_suit)
		has_suit.remove_accessory(user)
		return // we aren't an object on the ground so don't call parent
	..()

/obj/item/clothing/accessory/attackby(obj/item/I, mob/user, params)
	if(attack_accessory(I, user, params))
		return
	return ..()

/// Return TRUE if accessory should block attackby.
/obj/item/clothing/accessory/proc/attack_accessory(obj/item/I, mob/user, params)
	return FALSE

/obj/item/clothing/accessory/tie
	layer_priority = 0.1

/obj/item/clothing/accessory/tie/blue
	name = "blue tie"
	icon_state = "bluetie"

/obj/item/clothing/accessory/tie/red
	name = "red tie"
	icon_state = "redtie"

/obj/item/clothing/accessory/tie/black
	name = "black tie"
	icon_state = "blacktie"

/obj/item/clothing/accessory/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"

/obj/item/clothing/accessory/tie/waistcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"

/obj/item/clothing/accessory/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	layer_priority = 0.1
	m_amt = 150
	g_amt = 20

/obj/item/clothing/accessory/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		var/obj/item/organ/internal/heart/H = M.organs_by_name[O_HEART]
		if(user.a_intent == INTENT_HELP)
			var/target_zone = parse_zone(user.get_targetzone())
			if(target_zone)
				var/their = "their"
				switch(M.gender)
					if(MALE)	their = "his"
					if(FEMALE)	their = "her"
				if(M == user)
					their = "your"
				user.visible_message("<span class='notice'>[user] places [src] against [M]'s [target_zone] and starts listen attentively.</span>",
									"<span class='notice'>You place [src] against [their] [target_zone] and start to listen attentively.</span>")
				if(M.stat != DEAD && !(M.status_flags & FAKEDEATH))
					if(target_zone == BP_CHEST)
						if(H)
							if(H.heart_status == HEART_FIBR)
								user.playsound_local(null, 'sound/machines/cardio/pulse_fibrillation.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
							else if(H.heart_status == HEART_NORMAL)
								user.playsound_local(null, 'sound/machines/cardio/pulse.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
						var/obj/item/organ/internal/lungs/L = M.organs_by_name[O_LUNGS]
						if(L)
							if(L.is_bruised())
								user.playsound_local(null, 'sound/machines/cardio/wheezes.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
							else if(L.germ_level > INFECTION_LEVEL_ONE)
								user.playsound_local(null, 'sound/machines/cardio/crackles.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
							else
								user.playsound_local(null, 'sound/machines/cardio/normal.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
				if(do_after(user, 25, target = M) && src)
					var/pulse_status = "pulse"
					var/pulse_strength = "hear a weak"
					var/chest_inspected = FALSE

					if(M.stat == DEAD || (M.status_flags & FAKEDEATH) || H.heart_status == HEART_FAILURE)
						pulse_strength = "cannot hear"
						pulse_status = "anything"
					else
						switch(target_zone)
							if(BP_CHEST)
								pulse_status = "pulse"
								if(H.heart_status == HEART_NORMAL && M.oxyloss < 50)
									pulse_strength = "hear a healthy"
								else if(H.heart_status == HEART_FIBR)
									pulse_strength = "hear an odd pulse"
								var/obj/item/organ/internal/lungs/L = M.organs_by_name[O_LUNGS]
								if(L)
									if(L.is_bruised())
										chest_inspected = "<span class='warning'>You can hear noises and wheezing, \the [M]'s [L.name] may be bruised!</span>"
									else if(L.germ_level > INFECTION_LEVEL_ONE)
										chest_inspected = "<span class='warning'>\The [M]'s [L.name] sound like he got respitory tract infection!</span>"
									else
										chest_inspected = "<span class='notice'>\The [M]'s [L.name] sound normal.</span>"
								else
									chest_inspected = "<span class='notice'>You don't hear [M] breathing.</span>"
							if(O_EYES, O_MOUTH)
								pulse_strength = "cannot hear"
								pulse_status = "anything"
					if(!M.pulse)
						pulse_strength = "cannot hear"
						pulse_status = "anything"
					user.visible_message("<span class='notice'>[user] ends up listening to [M]'s [target_zone].</span>",
										"<span class='notice'>You finish listening to [M]'s [target_zone].</span>")
					if(!chest_inspected)
						to_chat(user, "<span class='notice'> You [pulse_strength] [pulse_status].</span>")
					else if(pulse_strength == "hear a healthy")
						to_chat(user, "<span class='notice'> You [pulse_strength] [pulse_status].</span> [chest_inspected]")
					else
						to_chat(user, "<span class='warning'> You [pulse_strength] [pulse_status].</span> [chest_inspected]")
				return
	return ..(M, user)

/obj/item/clothing/accessory/bronze_cross
	name = "bronze cross"
	desc = "That's a little bronze cross for wearing under the clothes."
	icon_state = "bronze_cross"

/obj/item/clothing/accessory/metal_cross
	name = "metal cross"
	desc = "That's a little metal cross for wearing under the clothes."
	icon_state = "metal_cross"

//Medals
/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	layer_priority = 0.1
	m_amt = 1000
	var/medaltype = "medal" //Sprite used for medalbox
	var/commended = FALSE

//Pinning medals on people
/obj/item/clothing/accessory/medal/attack(mob/living/M, mob/living/user, def_zone)
	if(ishuman(M) && user.a_intent != INTENT_HARM)
		var/mob/living/carbon/human/H = M
		var/obj/item/wearing = H.w_uniform

		if(!wearing || H.wear_suit?.flags_inv & HIDEJUMPSUIT) //Check if the jumpsuit is covered
			wearing = H.wear_suit

		if(!wearing || !istype(wearing, /obj/item/clothing))
			to_chat(user, "<span class='warning'>You can't pin a medal to [H].</span>")
			return
		var/obj/item/clothing/C = wearing

		var/delay = 20
		if(user == H)
			delay = 0
		else
			user.visible_message("<span class='notice'>[user] is trying to pin [src] on [H]'s chest.</span>", \
				"<span class='notice'>You try to pin [src] on [H]'s chest.</span>")
		var/input
		if(!commended && user != H)
			input = sanitize(input(user, "Reason for this commendation? Describe their accomplishments", "Commendation") as null|text)
		if(do_after(user, delay, target = H))
			C.attach_accessory(src, user)
			if(user != H)
				user.visible_message("<span class='notice'>[user] pins \the [src] on [H]'s chest.</span>", \
					"<span class='notice'>You pin \the [src] on [H]'s chest.</span>")
				if(input)
					commended = TRUE
					desc += "<br>The inscription reads: [input] - [user.real_name]"
					log_game("<b>[key_name(H)]</b> was given the following commendation by <b>[key_name(user)]</b>: [input]")
					message_admins("<b>[key_name_admin(H)]</b> was given the following commendation by <b>[key_name_admin(user)]</b>: [input]")
		return

	..()

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is the most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/accessory/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/cargo
	name = "\"cargo tech of the shift\" award"
	desc = "An award bestowed only upon those cargotechs who have exhibited devotion to their duty in keeping with the highest traditions of Cargonia."
	icon_state = "ribbon_cargo"

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	medaltype = "medal-silver"
	m_amt = 0

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/accessory/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/accessory/medal/silver/excellence
	name = "\proper the head of personnel award for outstanding achievement in the field of excellence"
	desc = "Nanotrasen's dictionary defines excellence as \"the quality or condition of being excellent\". This is awarded to those rare crewmembers who fit that definition."

/obj/item/clothing/accessory/medal/silver/med_medal
	name = "exemplary performance medal"
	desc = "A medal awarded to those who have shown distinguished conduct, performance, and initiative within the medical department."
	icon_state = "med_medal"

/obj/item/clothing/accessory/medal/silver/med_medal2
	name = "excellence in medicine medal"
	desc = "A medal awarded to those who have shown legendary performance, competence, and initiative beyond all expectations within the medical department."
	icon_state = "med_medal2"

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	medaltype = "medal-gold"
	m_amt = 0
	unacidable = TRUE

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentCom. To receive such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

/obj/item/clothing/accessory/medal/gold/bureaucracy
	name = "\improper Excellence in Bureaucracy Medal"
	desc = "Awarded for exemplary managerial services rendered while under contract with Nanotrasen."
	icon_state = "medal_paperwork"

/obj/item/clothing/accessory/medal/gold/nanotrasen
	name = "NanoTrasen Exclusive award"
	desc = "The most rare golden medal ever awarded only by highest NanoTrasen officers. There aren't any specific instructions how to get this award, because it hasn't been received by anyone before. If you received this one, you are most likely the most helpful person at NanoTrasen."
	icon_state = "gold_nt"

/obj/item/clothing/accessory/medal/plasma
	name = "plasma medal"
	desc = "An eccentric medal made of plasma."
	icon_state = "plasma"
	medaltype = "medal-plasma"

/obj/item/clothing/accessory/medal/plasma/nobel_science
	name = "nobel sciences award"
	desc = "A plasma medal which represents significant contributions to the field of science or engineering."

/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/holobadge
	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW. Also has an in-built camera."
	icon_state = "holobadge"
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_TIE

	var/emagged = FALSE // Emagging removes Sec check.
	var/stored_name = null
	var/obj/machinery/camera/camera

/obj/item/clothing/accessory/holobadge/cord
	icon_state = "holobadge-cord"
	slot_flags = SLOT_FLAGS_MASK | SLOT_FLAGS_TIE

/obj/item/clothing/accessory/holobadge/attack_self(mob/user)
	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
		return
	if(isliving(user))
		user.visible_message(
			"<span class='warning'>[user] displays their NanoTrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>",
			"<span class='warning'>You display your NanoTrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>")

/obj/item/clothing/accessory/holobadge/attack_accessory(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/id) || istype(I, /obj/item/device/pda))
		var/obj/item/weapon/card/id/id_card = null
		user.SetNextMove(CLICK_CD_INTERACT)

		if(istype(I, /obj/item/weapon/card/id))
			id_card = I
		else
			var/obj/item/device/pda/pda = I
			id_card = pda.id

		if(access_security in id_card.access || emagged)
			to_chat(user, "You imprint your ID details onto the badge.")
			stored_name = id_card.registered_name
			name = "holobadge ([stored_name])"
			desc = "This glowing blue badge marks [stored_name] as THE LAW. Also has an in-built camera."

			if(stored_name && !camera)
				camera = new /obj/machinery/camera(src)
				camera.name = "bodycam"
				camera.replace_networks(list("SECURITY UNIT"))
				cameranet.removeCamera(camera)
				camera.status = FALSE
				if(has_suit)
					camera.status = TRUE
					to_chat(user, "<span class='notice'>[bicon(src)]Camera activated.</span>")
			to_chat(user, "<span class='notice'>User registered as [stored_name].</span>")
			if(camera)
				camera.c_tag = "[stored_name] #[rand(999)]"
		else
			to_chat(user, "[src] rejects your insufficient access rights.")
		return TRUE
	return FALSE

/obj/item/clothing/accessory/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message(
			"<span class='warning'>[user] invades [M]'s personal space, thrusting [src] into their face insistently.</span>",
			"<span class='warning'>You invade [M]'s personal space, thrusting [src] into their face insistently. You are the law.</span>")

/obj/item/clothing/accessory/holobadge/emag_act(mob/user)
	if(emagged)
		to_chat(user, "<span class='warning'>[src] is already cracked.</span>")
		return FALSE
	emagged = TRUE
	to_chat(user, "<span class='warning'>You swipe card and crack the holobadge security checks.</span>")
	if(camera)
		camera.status = FALSE
	return TRUE

/obj/item/clothing/accessory/holobadge/on_attached(obj/item/clothing/S, mob/user, silent)
	..()
	if(camera && !emagged)
		camera.status = TRUE
		to_chat(user, "<span class='notice'>[bicon(src)]Camera activated.</span>")

/obj/item/clothing/accessory/holobadge/on_removed(mob/user)
	..()
	if(camera && !emagged)
		camera.status = FALSE
		to_chat(user, "<span class='notice'>[bicon(src)]Camera deactivated.</span>")

/obj/item/clothing/accessory/holobadge/emp_act(severity)
	if(camera)
		camera.emp_act(1)
