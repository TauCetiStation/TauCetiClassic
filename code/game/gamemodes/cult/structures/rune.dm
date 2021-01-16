/obj/effect/rune
	name = "blood"
	desc = ""
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	unacidable = 1
	layer = TURF_LAYER

	var/datum/rune/power
	var/datum/religion/religion

/obj/effect/rune/atom_init(mapload, datum/religion/R)
	. = ..()
	religion = R
	religion?.runes += src
	var/image/I = image('icons/effects/blood.dmi', src, "mfloor[rand(1, 7)]", 2)
	I.override = TRUE
	I.color = "#a10808"
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_runes", I)

/obj/effect/rune/update_icon()
	color = "#a10808"

/obj/effect/rune/Destroy()
	QDEL_NULL(power)
	religion.runes -= src
	return ..()

/obj/effect/rune/examine(mob/user)
	if(iscultist(user) || isobserver(user))
		to_chat(user, "[bicon(src)] That's <span class='[religion?.style_text]'>руна!</span>")
		if(!power)
			return
		to_chat(user, "Руной написано: <span class='[religion?.style_text]'>[power?.name]</span>.")
		if(istype(power, /datum/rune/cult/teleport/teleport))
			var/datum/rune/cult/teleport/teleport/R = power
			to_chat(user, "Id телепорта - <span class='[religion.style_text]'>[R.id]</span>.")
		return
	to_chat(user, "[bicon(src)] That's some <span class='danger'>[name]</span>")
	if(issilicon(user))
		to_chat(user, "It's thick and gooey. Perhaps it's the chef's cooking?") // blood desc
	else
		to_chat(user, "A strange collection of symbols drawn in blood.")

/obj/effect/rune/attackby(I, mob/living/user)
	if(istype(I, /obj/item/weapon/storage/bible/tome) && iscultist(user))
		to_chat(user, "<span class='[religion?.style_text]'>Вы заставляете руну исчезнуть.</span>")
		qdel(src)
		return
	if(istype(I, /obj/item/weapon/nullrod) && user.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
		to_chat(user, "<span class='notice'>Вы разрушаете мерзкую магию мертвящем полем [I].</span>")
		qdel(src)
		return

	return ..()

/obj/effect/rune/attack_ghost(mob/dead/observer/user)
	power.ghost_action(user)

/obj/effect/rune/attack_hand(mob/living/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(!iscultist(user))
		if(prob(user.getBrainLoss()))
			user.say(pick("Хаккрутйу гопоенйим.", "Храсаи пивроиашан.", "Фирййи прхив мазенхор.", "Танах ех вакантахе.", "Облияе на ораие.", "Миуф хон внор'с.", "Вакабаи хий фен йусших."))
		return
	if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		to_chat(user, "Вы не можете произнести слова руны.")
		return
	if(!power)
		return

	power.action_wrapper(user)

/obj/effect/rune/attack_animal(mob/user)
	if(!istype(user, /mob/living/simple_animal/construct))
		return

	power.action_wrapper(user)
