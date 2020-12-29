/obj/effect/rune
	name = "blood"
	desc = ""
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	unacidable = 1
	layer = TURF_LAYER
	var/datum/rune/cult/power

/obj/effect/rune/atom_init()
	. = ..()
	cult_runes += src
	var/image/I = image('icons/effects/blood.dmi', src, "mfloor[rand(1, 7)]", 2)
	I.override = TRUE
	I.color = "#a10808"
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_runes", I)

/obj/effect/rune/update_icon()
	color = "#a10808"

/obj/effect/rune/Destroy()
	QDEL_NULL(power)
	cult_runes -= src
	return ..()

/obj/effect/rune/examine(mob/user)
	if(iscultist(user) || isobserver(user))
		to_chat(user, "[bicon(src)] That's <span class='cult'>cult rune!</span>")
		to_chat(user, "A spell circle drawn in blood. It reads: <i>[power?.name]</i>.")
		return
	to_chat(user, "[bicon(src)] That's some <span class='danger'>[name]</span>")
	if(issilicon(user))
		to_chat(user, "It's thick and gooey. Perhaps it's the chef's cooking?") // blood desc
	else
		to_chat(user, "A strange collection of symbols drawn in blood.")

/obj/effect/rune/attackby(I, mob/living/user)
	if(istype(I, /obj/item/weapon/storage/bible/tome) && iscultist(user))
		to_chat(user, "<span class='cult'>You retrace your steps, carefully undoing the lines of the rune.</span>")
		qdel(src)
	else if(istype(I, /obj/item/weapon/nullrod) && user.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
		to_chat(user, "<span class='notice'>You disrupt the vile magic with the deadening field of the null rod!</span>")
		qdel(src)
	else
		return ..()

/obj/effect/rune/attack_ghost(mob/dead/observer/user)
	if(!istype(power, /datum/rune/cult/teleport) && !istype(power, /datum/rune/cult/item_port))
		return ..()
	var/list/allrunes = list()
	for(var/obj/effect/rune/R in cult_runes)
		if(!istype(R.power, power.type) || R == src)
			continue
		var/datum/rune/cult/teleport/T = R.power
		var/datum/rune/cult/teleport/self = power
		if(T.id == self.id && !is_centcom_level(R.loc.z))
			allrunes += R
	if(length(allrunes) > 0)
		user.forceMove(get_turf(pick(allrunes)))

/obj/effect/rune/attack_hand(mob/living/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(!iscultist(user))
		to_chat(user, "You can't mouth the arcane scratchings without fumbling over them.")
		return
	if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		to_chat(user, "You are unable to speak the words of the rune.")
		return
	if(!power || prob(user.getBrainLoss()))
		user.say(pick("Hakkrutju gopoenjim.", "Nherasai pivroiashan.", "Firjji prhiv mazenhor.",\
		"Tanah eh wakantahe.", "Obliyae na oraie.", "Miyf hon vnor'c.", "Wakabai hij fen juswix."))
		return
	power.action(user)
