/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 */

/*
 * First Aid Kits
 */
/obj/item/weapon/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	max_storage_space = DEFAULT_BOX_STORAGE
	var/empty = 0


/obj/item/weapon/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"

/obj/item/weapon/storage/firstaid/fire/atom_init()
	. = ..()
	if (empty)
		return

	icon_state = pick("ointment","firefirstaid")

	new /obj/item/device/healthanalyzer(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	for (var/i in 1 to 2)
		new /obj/item/stack/medical/ointment(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/pill/kelotane(src)// Replaced ointment with these since they actually work --Errorage

/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"

/obj/item/weapon/storage/firstaid/regular/atom_init()
	. = ..()
	if (empty)
		return
	for (var/i in 1 to 2)
		new /obj/item/stack/medical/bruise_pack(src)
	for (var/i in 1 to 2)
		new /obj/item/stack/medical/ointment(src)
	new /obj/item/device/healthanalyzer(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
	new /obj/item/stack/medical/suture(src)

/obj/item/weapon/storage/firstaid/toxin
	name = "toxin first aid"
	desc = "Used to treat when you have a high amoutn of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

/obj/item/weapon/storage/firstaid/toxin/atom_init()
	. = ..()
	if (empty)
		return

	icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/syringe/antitoxin( src )
	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/pill/dylovene( src )
	new /obj/item/device/healthanalyzer( src )

/obj/item/weapon/storage/firstaid/o2
	name = "oxygen deprivation first aid"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"

/obj/item/weapon/storage/firstaid/o2/atom_init()
	. = ..()
	if (empty)
		return
	for (var/i in 1 to 4)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/weapon/reagent_containers/syringe/inaprovaline(src)
	new /obj/item/device/healthanalyzer(src)

/obj/item/weapon/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"

/obj/item/weapon/storage/firstaid/adv/atom_init()
	. = ..()
	if (empty)
		return
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
	for (var/i in 1 to 3)
		new /obj/item/stack/medical/advanced/bruise_pack(src)
	for (var/i in 1 to 2)
		new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)

/*
 * Pill Bottles
 */

/obj/item/weapon/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	flags = NOBLUDGEON
	w_class = ITEM_SIZE_SMALL
	max_storage_space = 21
	can_hold = list(/obj/item/weapon/reagent_containers/pill,/obj/item/weapon/dice,/obj/item/weapon/paper)
	allow_quick_gather = 1
	use_to_pickup = 1
	var/wrapper_color
	var/label

/obj/item/weapon/storage/pill_bottle/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || !istype(target) || target != user)
		return 1
	if(!contents.len)
		to_chat(user, "<span class='warning'>It's empty!</span>")
		return 1
	var/zone = user.zone_sel.selecting
	if(zone == O_MOUTH && CanEat(user, target, src, "eat"))
		user.visible_message("<span class='notice'>[user] pops a pill from \the [src].</span>")
		playsound(src, 'sound/effects/peelz.ogg', VOL_EFFECTS_MASTER)
		var/list/peelz = filter_list(contents,/obj/item/weapon/reagent_containers/pill)
		if(peelz.len)
			var/obj/item/weapon/reagent_containers/pill/P = pick(peelz)
			remove_from_storage(P)
			user.SetNextMove(CLICK_CD_MELEE)
			P.attack(target,user)
			return 1

/obj/item/weapon/storage/pill_bottle/atom_init()
	. = ..()
	use_sound = list('sound/effects/pillbottle.ogg')
	update_icon()

/obj/item/weapon/storage/pill_bottle/update_icon()
	cut_overlays()
	if(wrapper_color)
		var/image/I = image(icon, "pillbottle_wrap")
		I.color = wrapper_color
		add_overlay(I)

/obj/item/weapon/storage/pill_bottle/bicaridine
	name = "pill bottle (Bicaridine)"
	desc = "Contains pills used to stabilize the severely injured."

	startswith = list(/obj/item/weapon/reagent_containers/pill/bicaridine = 12)
	wrapper_color = COLOR_MAROON

/obj/item/weapon/storage/pill_bottle/dexalin_plus
	name = "pill bottle (Dexalin Plus)"
	desc = "Contains pills used to treat extreme cases of oxygen deprivation."

	startswith = list(/obj/item/weapon/reagent_containers/pill/dexalin_plus = 12)
	wrapper_color = COLOR_CYAN_BLUE

/obj/item/weapon/storage/pill_bottle/dexalin
	name = "pill bottle (Dexalin)"
	desc = "Contains pills used to treat oxygen deprivation."

	startswith = list(/obj/item/weapon/reagent_containers/pill/dexalin = 12)
	wrapper_color = COLOR_LIGHT_CYAN

/obj/item/weapon/storage/pill_bottle/dermaline
	name = "pill bottle (Dermaline)"
	desc = "Contains pills used to treat burn wounds."

	startswith = list(/obj/item/weapon/reagent_containers/pill/dermaline = 8)
	wrapper_color = "#e8d131"

/obj/item/weapon/storage/pill_bottle/dylovene
	name = "pill bottle (Dylovene)"
	desc = "Contains pills used to treat toxic substances in the blood."

	startswith = list(/obj/item/weapon/reagent_containers/pill/dylovene = 12)
	wrapper_color = COLOR_GREEN

/obj/item/weapon/storage/pill_bottle/inaprovaline
	name = "pill bottle (Inaprovaline)"
	desc = "Contains pills used to stabilize patients."

	startswith = list(/obj/item/weapon/reagent_containers/pill/inaprovaline = 12)
	wrapper_color = COLOR_PALE_BLUE_GRAY

/obj/item/weapon/storage/pill_bottle/kelotane
	name = "pill bottle (Kelotane)"
	desc = "Contains pills used to treat burns."

	startswith = list(/obj/item/weapon/reagent_containers/pill/kelotane = 12)
	wrapper_color = COLOR_SUN

/obj/item/weapon/storage/pill_bottle/spaceacillin
	name = "pill bottle (Spaceacillin)"
	desc = "A theta-lactam antibiotic. Effective against many diseases likely to be encountered in space."

	startswith = list(/obj/item/weapon/reagent_containers/pill/spaceacillin = 7)
	wrapper_color = COLOR_PALE_GREEN_GRAY

/obj/item/weapon/storage/pill_bottle/tramadol
	name = "pill bottle (Tramadol)"
	desc = "Contains pills used to relieve pain."

	startswith = list(/obj/item/weapon/reagent_containers/pill/tramadol = 7)
	wrapper_color = COLOR_PURPLE_GRAY

//Baycode specific Psychiatry pills.
/obj/item/weapon/storage/pill_bottle/citalopram
	name = "pill bottle (Citalopram)"
	desc = "Mild antidepressant. For use in individuals suffering from depression or anxiety. 15u dose per pill."

	startswith = list(/obj/item/weapon/reagent_containers/pill/citalopram = 12)
	wrapper_color = COLOR_GRAY

/obj/item/weapon/storage/pill_bottle/methylphenidate
	name = "pill bottle (Methylphenidate)"
	desc = "Mental stimulant. For use in individuals suffering from ADHD, or general concentration issues. 15u dose per pill."

	startswith = list(/obj/item/weapon/reagent_containers/pill/methylphenidate = 12)
	wrapper_color = COLOR_GRAY

/obj/item/weapon/storage/pill_bottle/paroxetine
	name = "pill bottle (Paroxetine)"
	desc = "High-strength antidepressant. Only for use in severe depression. 10u dose per pill. <span class='warning'>WARNING: side-effects may include hallucinations.</span>"

	startswith = list(/obj/item/weapon/reagent_containers/pill/paroxetine = 7)
	wrapper_color = COLOR_GRAY

/obj/item/weapon/storage/pill_bottle/paracetamol
	name = "pill bottle (Paracetamol)"
	desc = "Mild painkiller, also known as Tylenol. Won't fix the cause of your headache (unlike cyanide), but might make it bearable."

	startswith = list(/obj/item/weapon/reagent_containers/pill/paracetamol = 12)
	wrapper_color = "#a2819e"

/obj/item/weapon/storage/pill_bottle/assorted
	name = "pill bottle (assorted)"
	desc = "Commonly found on paramedics, these assorted pill bottles contain all the basics."

	startswith = list(
			/obj/item/weapon/reagent_containers/pill/inaprovaline = 6,
			/obj/item/weapon/reagent_containers/pill/dylovene = 6,
			/obj/item/weapon/reagent_containers/pill/tramadol = 2,
			/obj/item/weapon/reagent_containers/pill/dexalin = 2,
			/obj/item/weapon/reagent_containers/pill/kelotane = 2,
			/obj/item/weapon/reagent_containers/pill/hyronalin = 2
		)
