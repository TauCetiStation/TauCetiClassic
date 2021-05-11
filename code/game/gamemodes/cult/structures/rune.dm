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
	var/mob/creator

/obj/effect/rune/atom_init(mapload, datum/religion/R, mob/user, rand_icon = FALSE)
	. = ..()
	if(R)
		ASSERT(user)
		creator = user
		religion = R
		religion.runes += src

		if(!religion.runes_by_mob.Find(creator))
			religion.runes_by_mob[creator] = list(src)
		else
			var/list/L = religion.runes_by_mob[creator]
			L += src

	if(rand_icon)
		var/list/all_words = RUNE_WORDS
		var/list/words = list()
		for(var/i in 1 to 3)
			words += pick_n_take(all_words)
		icon = get_uristrune_cult(TRUE, words)

	var/image/I = image('icons/effects/blood.dmi', src, "mfloor[rand(1, 7)]", 2)
	I.override = TRUE
	I.color = "#a10808"
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_runes", I)

/obj/effect/rune/update_icon()
	color = "#a10808"

/obj/effect/rune/Destroy()
	QDEL_NULL(power)
	if(religion && creator)
		var/list/L = religion.runes_by_mob[creator]
		L -= src
		religion.runes -= src
		religion = null

	creator = null

	return ..()

/obj/effect/rune/examine(mob/user)
	if(iscultist(user) || isobserver(user))
		to_chat(user, "[bicon(src)] That's <span class='[religion?.style_text]'>руна!</span>")
		if(!power)
			return
		to_chat(user, "Руной написано: <span class='[religion?.style_text]'>[power?.name]</span>.")
		if(istype(power, /datum/rune/cult/teleport/teleport))
			var/datum/rune/cult/teleport/teleport/R = power
			to_chat(user, "Id телепорта - <span class='[religion.style_text]'>[R.id ? R.id : "Отсутствует"]</span>.")
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
		to_chat(user, "<span class='notice'>Вы разрушаете мерзкую магию силой [I].</span>")
		qdel(src)
		return

	return ..()

/obj/effect/rune/attack_ghost(mob/dead/observer/user)
	examine(user)
	power?.ghost_action(user)

/obj/effect/rune/attack_hand(mob/living/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(get_dist(user, src) > 1) // anti-telekinesis
		return
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
	if(!iscultist(user))
		return

	power.action_wrapper(user)
