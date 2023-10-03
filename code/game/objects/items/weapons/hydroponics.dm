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

/obj/item/weapon/grown/sunflower/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/cable_piece = I
		if(cable_piece.use(3))
			new /obj/item/clothing/head/sunflower_crown(get_turf(loc))
			qdel(src)
			return
	return ..()

/obj/item/clothing/head/sunflower_crown
	name = "sunflower crown"
	desc = "A bright flower crown made out sunflowers that is sure to brighten up anyone's day!"
	icon_state = "sunflower_crown"

/*
 * Poppy
 */

/obj/item/clothing/head/poppy_crown
	name = "poppy crown"
	desc = "A flower crown made out of a string of bright red poppies."
	icon_state = "poppy_crown"

/*
 * Nettle
 */
/obj/item/weapon/grown/nettle/pickup(mob/living/user)
	. = ..()
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
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.gloves)
			return
		var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
		BP.take_damage(0, force)
	else
		user.take_bodypart_damage(0, force)

	if(prob(50))
		user.Paralyse(5)
		to_chat(user, "<span class='warning'>You are stunned by \the [src] when you try picking it up!</span>")

/obj/item/weapon/grown/deathnettle/attack(mob/living/carbon/M, mob/user)
	if(!..()) return
	if(isliving(M))
		to_chat(M, "<span class='warning'>You are stunned by the powerful acid of the Deathnettle!</span>")

		M.log_combat(user, "stunned with [name]")

		playsound(src, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)

		M.blurEyes(force/7)
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

/*
 * Gourd
 */
var/global/list/gourd_names = list(
	"gourd",
	"pumpkin",
	"pumpkling",
	"bottle gourd",
	"calabash",
	"long melon",
	"opo squash",
	"cabaza",
	"kabocha",
	"pepo",
	"lagenaria",
	"kabak",
	"tykvyak",
	"winter melon",
)
var/global/gourd_name = null

/proc/get_gourd_name()
	if(global.gourd_name)
		return global.gourd_name
	global.gourd_name = pick(global.gourd_names)
	return global.gourd_name

#define MARACA_COOLDOWN (0.1 SECONDS)

/obj/item/weapon/reagent_containers/food/snacks/grown/gourd
	seed_type = /obj/item/seeds/gourdseed
	name = "gourd"
	desc = "Тыквяк. Твёрдый и малосъедобный. Не кушай!"
	icon_state = "gourd"
	item_state = "gourd"
	potency = 10
	filling_color = "#95ba43"

	var/restore_reagent = "gourd"

	COOLDOWN_DECLARE(last_maraca)

	var/bottle_type = /obj/item/weapon/reagent_containers/food/drinks/bottle/gourd

	var/gourd_event = /datum/mood_event/gourd
	var/unathi_gourd_event = /datum/mood_event/unathi_gourd

/obj/item/weapon/reagent_containers/food/snacks/grown/gourd/atom_init()
	. = ..()
	name = "[get_gourd_name()]"

	reagents.maximum_volume = 30 * potency * 0.1

	reagents.add_reagent(restore_reagent, 1 + round(potency * 0.1, 1))
	// Tough fruit, lotsa bites.
	bitesize = 1 + round(reagents.total_volume * 0.1, 1)
	START_PROCESSING(SSobj, src)

/obj/item/weapon/reagent_containers/food/snacks/grown/gourd/magic
	seed_type = /obj/item/seeds/magicgourdseed
	icon_state = "gourd_magic"
	item_state = "gourd_magic"
	potency = 20

	restore_reagent = "gourdbeer"

	bottle_type = /obj/item/weapon/reagent_containers/food/drinks/bottle/gourd/magic

	gourd_event = /datum/mood_event/magic_gourd
	unathi_gourd_event = /datum/mood_event/unathi_magic_gourd

/obj/item/weapon/reagent_containers/food/snacks/grown/gourd/magic/atom_init()
	. = ..()
	name = "refreshing [get_gourd_name()]"

/obj/item/weapon/reagent_containers/food/snacks/grown/gourd/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/gourd/process()
	if(reagents.total_volume >= reagents.maximum_volume)
		return

	reagents.add_reagent(restore_reagent, potency * 0.005)

/obj/item/weapon/reagent_containers/food/snacks/grown/gourd/attackby(obj/item/I, mob/user)
	if(I.get_quality(QUALITY_CUTTING))
		var/turf/T = loc
		if(!isturf(T))
			T = T.loc
		if(!isturf(T))
			return ..()

		user.drop_from_inventory(src)
		var/obj/item/weapon/reagent_containers/food/drinks/bottle/gourd/G = new /obj/item/weapon/reagent_containers/food/drinks/bottle/gourd(T)
		G.volume = reagents.maximum_volume * 3
		G.reagents.maximum_volume = reagents.maximum_volume * 3

		if(user.in_interaction_vicinity(G))
			user.put_in_hands(G)

		qdel(src)
		return

	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/gourd/examine(mob/user)
	. = ..()
	if(user.get_species() == UNATHI)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "gourd", unathi_gourd_event)
	else
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "gourd", gourd_event)

/obj/item/weapon/reagent_containers/food/snacks/grown/gourd/attack_self(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, last_maraca))
		return
	COOLDOWN_START(src, last_maraca, MARACA_COOLDOWN)
	playsound(src, 'sound/musical_instruments/maraca/maraca.ogg', VOL_EFFECTS_INSTRUMENT, 100, TRUE, falloff = 5)

#undef MARACA_COOLDOWN

/obj/item/weapon/reagent_containers/food/drinks/bottle/gourd
	name = "bottle gourd bottle"
	desc = "Бутылка из тыквяка. Бьёт дважды."
	icon_state = "gourd_flask"
	item_state = "gourd_flask"

	amount_per_transfer_from_this = 10
	volume = 100
	is_glass = FALSE
	is_transparent = FALSE

	var/gourd_event = /datum/mood_event/gourd
	var/unathi_gourd_event = /datum/mood_event/unathi_gourd

	var/broken_type = /obj/item/weapon/broken_bottle/gourd

/obj/item/weapon/reagent_containers/food/drinks/bottle/gourd/atom_init()
	. = ..()
	name = "[get_gourd_name()] bottle"
	verbs += /obj/item/weapon/reagent_containers/food/drinks/bottle/verb/spin_bottle

/obj/item/weapon/reagent_containers/food/drinks/bottle/gourd/magic
	icon_state = "gourd_magic_flask"
	item_state = "gourd_magic_flask"

	volume = 200

	broken_type = /obj/item/weapon/broken_bottle/gourd/magic

	gourd_event = /datum/mood_event/magic_gourd
	unathi_gourd_event = /datum/mood_event/unathi_magic_gourd

/obj/item/weapon/reagent_containers/food/drinks/bottle/gourd/magic/atom_init()
	. = ..()
	name = "refreshing [get_gourd_name()] bottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/gourd/can_smash()
	return TRUE

/obj/item/weapon/reagent_containers/food/drinks/bottle/gourd/smash(mob/living/target, mob/living/user)
	//Creates a shattering noise and replaces the bottle with a broken_bottle
	user.drop_from_inventory(src)

	var/obj/item/weapon/broken_bottle/gourd/B = new broken_type(loc)
	if(isturf(loc))
		new /obj/effect/decal/cleanable/gourd(loc)

	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)

	user.put_in_active_hand(B)
	transfer_fingerprints_to(B)

	qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/bottle/gourd/after_throw(datum/callback/callback)
	..()
	reagents.standard_splash(loc)
	if(isturf(loc))
		new /obj/effect/decal/cleanable/gourd(loc)
	qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/bottle/gourd/examine(mob/user)
	. = ..()
	if(user.get_species() == UNATHI)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "gourd", unathi_gourd_event)
	else
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "gourd", gourd_event)

/obj/item/weapon/broken_bottle/gourd
	name = "shatttered gourd bottle"
	desc = "Сломан, но не сломлен. Тыквяк годен ко второму удару!"
	var/const/duration = 13 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)

	icon = 'icons/obj/drinks.dmi'
	icon_state = "gourd_flask_broken"
	item_state = "broken_beer"

/obj/item/weapon/broken_bottle/gourd/atom_init()
	. = ..()
	name = "shattered [get_gourd_name()] bottle"

/obj/item/weapon/broken_bottle/gourd/magic
	icon_state = "gourd_magic_flask_broken"

/obj/item/weapon/broken_bottle/gourd/attack(mob/living/target, mob/living/user, def_zone)
	if(user.a_intent != INTENT_HARM)
		return ..()

	if(!target)
		return

	force = 15 //Smashing bottles over someoen's head hurts.

	var/armor_block = 0 //Get the target's armour values for normal attack damage.
	var/armor_duration = 0 //The more force the bottle has, the longer the duration.

	//Calculating duration and calculating damage.
	armor_block = target.run_armor_check(def_zone, MELEE)
	if(def_zone == BP_HEAD)
		armor_duration = (duration - armor_block) + force
	armor_duration /= 10

	//Apply the damage!
	target.apply_damage(force, BRUTE, def_zone, armor_block)

	// You are going to knock someone out for longer if they are not wearing a helmet.
	if(def_zone == BP_HEAD && iscarbon(target))
		//Display an attack message.
		if(target != user)
			user.visible_message("<span class='bold warning'>[target] has been hit over the head with \a [name], by [user]!</span>")
		else
			user.visible_message("<span class='bold warning'>[target] hit himself with \a [name] on the head!</span>")
		//Weaken the target for the duration that we calculated and divide it by 5.
		if(armor_duration)
			target.apply_effect(min(armor_duration, 10) , WEAKEN) // Never weaken more than a flash!

	else
		//Default attack message and don't weaken the target.
		if(target != user)
			user.visible_message("<span class='bold warning'>[target] has been attacked with \a [name], by [user]!</span>")
		else
			user.visible_message("<span class='bold warning'>[target] has attacked himself with \a [name]!</span>")

	//Attack logs
	target.log_combat(user, "smashed with a [name] (INTENT: [uppertext(user.a_intent)])")

	qdel(src)
