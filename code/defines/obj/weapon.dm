/obj/item/weapon/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon = 'icons/obj/items.dmi'
	icon_state = "red_phone"
	flags = CONDUCT
	force = 3.0
	throwforce = 2.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("called", "rang")
	hitsound = list('sound/weapons/ring.ogg')

/obj/item/weapon/rsp
	name = "Rapid-Seed-Producer (RSP)"
	desc = "A device used to rapidly deploy seeds."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = 1
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = ITEM_SIZE_SMALL
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/items.dmi'
	icon_state = "c_tube"
	throwforce = 1
	w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 5


/obj/item/weapon/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	flags = CONDUCT
	force = 5.0
	throwforce = 7.0
	w_class = ITEM_SIZE_SMALL
	m_amt = 50
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")

/obj/item/weapon/cane/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.can_push = TRUE
	SCB.can_pull = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/gift
	name = "gift"
	desc = "A wrapped item."
	icon = 'icons/obj/items.dmi'
	icon_state = "gift3"
	item_state = "gift"
	w_class = ITEM_SIZE_NORMAL
	var/size = ITEM_SIZE_NORMAL
	var/sender = FALSE
	var/recipient = FALSE

/obj/item/weapon/legcuffs
	name = "legcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	throwforce = 0
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "materials=1"
	var/breakouttime = 300	//Deciseconds = 30s = 0.5 minute

/obj/item/weapon/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 2
	throw_range = 1
	icon_state = "beartrap0"
	desc = "A trap used to catch bears and other legged creatures."
	var/armed = 0

/obj/item/weapon/legcuffs/beartrap/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is putting the [src.name] on \his head! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS)

/obj/item/weapon/legcuffs/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "beartrap[armed]"
		to_chat(user, "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"].</span>")

/obj/item/weapon/legcuffs/beartrap/Crossed(atom/movable/AM)
	. = ..()
	if(armed)
		if(ishuman(AM))
			if(isturf(src.loc))
				var/mob/living/carbon/H = AM
				if(H.m_intent == "run" && !H.buckled)
					armed = 0
					H.legcuffed = src
					src.loc = H
					H.update_inv_legcuffed()
					H.visible_message("<span class='danger'>[H] steps on \the [src].</span>", "<span class='danger'>You step on \the [src]!</span>")
					feedback_add_details("handcuffs","B") //Yes, I know they're legcuffs. Don't change this, no need for an extra variable. The "B" is used to tell them apart.
		if(isanimal(AM) && !istype(AM, /mob/living/simple_animal/parrot) && !istype(AM, /mob/living/simple_animal/construct) && !istype(AM, /mob/living/simple_animal/shade) && !istype(AM, /mob/living/simple_animal/hostile/viscerator))
			armed = 0
			var/mob/living/simple_animal/SA = AM
			SA.health -= 20

		icon_state = "beartrap[armed]"

/obj/item/weapon/legcuffs/bola
	name = "bola"
	desc = "A restraining device designed to be thrown at the target. Upon connecting with said target, it will wrap around their legs, making it difficult for them to move quickly."
	icon_state = "bola"
	breakouttime = 35 //easy to apply, easy to break out of
	origin_tech = "engineering=3;combat=1"
	throw_speed = 5
	var/weaken = 0.8

/obj/item/weapon/legcuffs/bola/after_throw(datum/callback/callback)
	..()
	playsound(src,'sound/weapons/bolathrow.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/legcuffs/bola/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!iscarbon(hit_atom))//if it gets caught or the target can't be cuffed,
		return
	var/mob/living/carbon/C = hit_atom
	if(!C.legcuffed)
		visible_message("<span class='danger'>\The [src] ensnares [C]!</span>")
		C.legcuffed = src
		src.loc = C
		C.update_inv_legcuffed()
		feedback_add_details("handcuffs","B")
		to_chat(C,"<span class='userdanger'>\The [src] ensnares you!</span>")
		C.Weaken(weaken)

/obj/item/weapon/legcuffs/bola/tactical//traitor variant
	name = "reinforced bola"
	desc = "A strong bola, made with a long steel chain. It looks heavy, enough so that it could trip somebody."
	icon_state = "bola_r"
	breakouttime = 70
	origin_tech = "engineering=4;combat=3"
	weaken = 6


/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/weapon/caution/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon_state = "cone"

/obj/item/weapon/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items.dmi'
	icon_state = "rack_parts"
	flags = CONDUCT
	m_amt = 3750

/obj/item/weapon/shard
	name = "shard"
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	sharp = 1
	edge = 1
	desc = "Could probably be used as ... a throwing weapon?"
	w_class = ITEM_SIZE_SMALL
	force = 5.0
	throwforce = 8.0
	item_state = "shard-glass"
	g_amt = 3750
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	var/on_step_sound = 'sound/effects/glass_step.ogg'

/obj/item/weapon/shard/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his wrists with the shard of glass! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his throat with the shard of glass! It looks like \he's trying to commit suicide.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/shard/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(src, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)
	return ..()

/obj/item/weapon/shard/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(isturf(target))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves && !H.species.flags[NO_MINORCUTS]) //specflags please..
			to_chat(H, "<span class='warning'>[src] cuts into your hand!</span>")
			var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
			BP.take_damage(force / 2, null, damage_flags())
	else if(ismonkey(user))
		var/mob/living/carbon/monkey/M = user
		to_chat(M, "<span class='warning'>[src] cuts into your hand!</span>")
		M.adjustBruteLoss(force / 2)

/*/obj/item/weapon/syndicate_uplink
	name = "station bounced radio"
	desc = "Remain silent about this..."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	var/temp = null
	var/uses = 10.0
	var/selfdestruct = 0.0
	var/traitor_frequency = 0.0
	var/mob/currentUser = null
	var/obj/item/device/radio/origradio = null
	flags = CONDUCT | ONBELT
	w_class = ITEM_SIZE_SMALL
	item_state = "radio"
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	origin_tech = "magnets=2;syndicate=3"*/

/obj/item/weapon/shard/shrapnel
	name = "shrapnel"
	icon = 'icons/obj/shards.dmi'
	icon_state = "shrapnellarge"
	desc = "A bunch of tiny bits of shattered metal."
	on_step_sound = 'sound/effects/metalstep.ogg'

/obj/item/weapon/shard/shrapnel/atom_init()
	. = ..()

	icon_state = pick("shrapnellarge", "shrapnelmedium", "shrapnelsmall")
	switch(icon_state)
		if("shrapnelsmall")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("shrapnelmedium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("shrapnellarge")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)

/obj/item/weapon/SWF_uplink
	name = "station-bounced radio"
	desc = "used to comunicate it appears."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	var/temp = null
	var/uses = 4.0
	var/selfdestruct = 0.0
	var/traitor_frequency = 0.0
	var/obj/item/device/radio/origradio = null
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	item_state = "radio"
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	origin_tech = "magnets=1"

/obj/item/weapon/staff
	name = "wizards staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	force = 3.0
	hitsound = list('sound/effects/magic.ogg')
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	flags = NOSHIELD
	attack_verb = list("bludgeoned", "whacked", "disciplined")

/obj/item/weapon/staff/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.can_push = TRUE
	SCB.can_pull = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"

/obj/item/weapon/staff/broom/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.can_push = TRUE
	SCB.can_pull = TRUE

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/staff/gentcane
	name = "Gentlemans Cane"
	desc = "An ebony can with an ivory tip."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cane"
	item_state = "stick"

/obj/item/weapon/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "stick"
	item_state = "stick"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	flags = NOSHIELD

/obj/item/weapon/table_parts
	name = "table parts"
	desc = "Parts of a table. Poor table."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "table_parts"
	m_amt = 3750
	flags = CONDUCT
	attack_verb = list("slammed", "bashed", "battered", "bludgeoned", "thrashed", "whacked")

/obj/item/weapon/table_parts/reinforced
	name = "reinforced table parts"
	desc = "Hard table parts. Well...harder..."
	icon = 'icons/obj/items.dmi'
	icon_state = "reinf_tableparts"
	m_amt = 7500
	flags = CONDUCT

/obj/item/weapon/table_parts/wood
	name = "wooden table parts"
	desc = "Keep away from fire."
	icon_state = "wood_tableparts"
	flags = null

/obj/item/weapon/table_parts/wood/poker
	name = "poker table parts"
	desc = "Keep away from fire, and keep near seedy dealers."
	icon_state = "poker_tableparts"
	flags = null

/obj/item/weapon/table_parts/wood/fancy
	name = "fancy table parts"
	desc = "Covered with an amazingly fancy, patterned cloth."
	icon_state = "fancy_tableparts"

/obj/item/weapon/table_parts/wood/fancy/black
	icon_state = "fancyblack_tableparts"

/obj/item/weapon/table_parts/glass
	name = "glass table parts"
	desc = "Very fragile."
	icon_state = "glass_tableparts"
	flags = null

/obj/item/weapon/wire
	desc = "This is just a simple piece of regular insulated wire."
	name = "wire"
	icon = 'icons/obj/power.dmi'
	icon_state = "item_wire"
	var/amount = 1.0
	var/laying = 0.0
	var/old_lay = null
	m_amt = 40
	attack_verb = list("whipped", "lashed", "disciplined", "tickled")

/obj/item/weapon/wire/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (OXYLOSS)

/obj/item/weapon/module
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	flags = CONDUCT
	usesound = 'sound/items/Deconstruct.ogg'
	var/mtype = 1						// 1=electronic 2=hardware

/obj/item/weapon/module/card_reader
	name = "card reader module"
	icon_state = "card_mod"
	desc = "An electronic module for reading data and ID cards."

/obj/item/weapon/module/power_control
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."
	m_amt = 50
	g_amt = 50

/obj/item/weapon/module/id_auth
	name = "ID authentication module"
	icon_state = "id_mod"
	desc = "A module allowing secure authorization of ID cards."

/obj/item/weapon/module/cell_power
	name = "power cell regulator module"
	icon_state = "power_mod"
	desc = "A converter and regulator allowing the use of power cells."

/obj/item/weapon/module/cell_power
	name = "power cell charger module"
	icon_state = "power_mod"
	desc = "Charging circuits for power cells."

/obj/item/weapon/syntiflesh
	name = "syntiflesh"
	desc = "Meat that appears...strange..."
	icon = 'icons/obj/food.dmi'
	icon_state = "meat"
	flags = CONDUCT
	w_class = ITEM_SIZE_SMALL
	origin_tech = "biotech=2"

/obj/item/weapon/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hatchet"
	flags = CONDUCT
	force = 12.0
	sharp = 1
	edge = 1
	w_class = ITEM_SIZE_SMALL
	throwforce = 15.0
	throw_speed = 4
	throw_range = 4
	m_amt = 15000
	origin_tech = "materials=2;combat=1"
	attack_verb = list("chopped", "torn", "cut")

/obj/item/weapon/hatchet/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/obj, /turf)

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/hatchet/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(src, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)
	return ..()

/obj/item/weapon/hatchet/unathiknife
	name = "duelling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "unathiknife"
	attack_verb = list("ripped", "torn", "cut")

/obj/item/weapon/scythe
	icon_state = "scythe0"
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13.0
	throwforce = 5.0
	sharp = 1
	edge = 1
	throw_speed = 1
	throw_range = 3
	w_class = ITEM_SIZE_LARGE
	flags = NOSHIELD
	slot_flags = SLOT_FLAGS_BACK
	origin_tech = "materials=2;combat=2"
	attack_verb = list("chopped", "sliced", "cut", "reaped")

/obj/item/weapon/scythe/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf, /obj/effect/effect/weapon_sweep)

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/scythe/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(target, /obj/effect/spacevine))
		for(var/obj/effect/spacevine/B in orange(target, 1))
			if(prob(80))
				qdel(B)
		qdel(target)

/*
/obj/item/weapon/cigarpacket
	name = "Pete's Cuban Cigars"
	desc = "The most robust cigars on the planet."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarpacket"
	item_state = "cigarpacket"
	w_class = ITEM_SIZE_TINY
	throwforce = 2
	var/cigarcount = 6
	flags = ONBELT */

/obj/item/weapon/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"
	flags = NOBLUDGEON | NOATTACKANIMATION | CONDUCT
	w_class = ITEM_SIZE_SMALL

	var/obj/machinery/machine

/obj/item/weapon/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags = NOBLUDGEON
	w_class = ITEM_SIZE_SMALL
	origin_tech = "syndicate=2"
	var/timer = 10
	var/atom/target = null

///////////////////////////////////////Stock Parts /////////////////////////////////

/obj/item/weapon/storage/part_replacer
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	icon_state = "RPED"
	item_state = "RPED"
	w_class = ITEM_SIZE_HUGE
	can_hold = list(/obj/item/weapon/stock_parts)
	storage_slots = 50
	use_to_pickup = 1
	allow_quick_gather = 1
	allow_quick_empty = 1
	collection_mode = 1
	display_contents_with_number = 1
	max_w_class = ITEM_SIZE_NORMAL
	var/works_from_distance = 0
	var/pshoom_or_beepboopblorpzingshadashwoosh = 'sound/items/rped.ogg'
	var/alt_sound = null

/obj/item/weapon/storage/part_replacer/afterattack(atom/target, mob/user, proximity, params)
	if(proximity)
		return
	if(!istype(target, /obj/machinery))
		return
	var/obj/machinery/T = target
	if(works_from_distance && T.component_parts)
		T.exchange_parts(user, src)
		user.Beam(T,icon_state="rped_upgrade",icon='icons/effects/effects.dmi',time=5)

/obj/item/weapon/storage/part_replacer/bluespace
	name = "bluespace rapid part exchange device"
	desc = "A version of the RPED that allows for replacement of parts and scanning from a distance, along with higher capacity for parts."
	icon_state = "BS_RPED"
	item_state = "BS_RPED"
	w_class = ITEM_SIZE_NORMAL
	storage_slots = 400
	max_w_class = ITEM_SIZE_NORMAL
	works_from_distance = 1
	pshoom_or_beepboopblorpzingshadashwoosh = 'sound/items/PSHOOM.ogg'
	alt_sound = 'sound/items/PSHOOM_2.ogg'

/obj/item/weapon/storage/part_replacer/proc/play_rped_sound()
	//Plays the sound for RPED exhanging or installing parts.
	if(alt_sound && prob(1))
		playsound(src, alt_sound, VOL_EFFECTS_MASTER)
	else
		playsound(src, pshoom_or_beepboopblorpzingshadashwoosh, VOL_EFFECTS_MASTER)

//Sorts stock parts inside an RPED by their rating.
//Only use /obj/item/weapon/stock_parts/ with this sort proc!
/proc/cmp_rped_sort(obj/item/weapon/stock_parts/A, obj/item/weapon/stock_parts/B)
	return B.rating - A.rating

/obj/item/weapon/stock_parts
	name = "stock part"
	desc = "What?"
	icon = 'icons/obj/stock_parts.dmi'
	w_class = ITEM_SIZE_SMALL
	var/rating = 1

/obj/item/weapon/stock_parts/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

//Rank 1

/obj/item/weapon/stock_parts/console_screen
	name = "console screen"
	desc = "Used in the construction of computers and other devices with a interactive console."
	icon_state = "screen"
	origin_tech = "materials=1"
	g_amt = 200

/obj/item/weapon/stock_parts/capacitor
	name = "capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon_state = "capacitor"
	origin_tech = "powerstorage=1"
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module
	name = "scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = "magnets=1"
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator
	name = "micro-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	origin_tech = "materials=1;programming=1"
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser
	name = "micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	origin_tech = "magnets=1"
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin
	name = "matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "matter_bin"
	origin_tech = "materials=1"
	m_amt = 80

//Rank 2

/obj/item/weapon/stock_parts/capacitor/adv
	name = "advanced capacitor"
	desc = "An advanced capacitor used in the construction of a variety of devices."
	icon_state = "adv_capacitor"
	origin_tech = "powerstorage=3"
	rating = 2
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module/adv
	name = "advanced scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "adv_scan_module"
	origin_tech = "magnets=3"
	rating = 2
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator/nano
	name = "nano-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "nano_mani"
	origin_tech = "materials=3,programming=2"
	rating = 2
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser/high
	name = "high-power micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "high_micro_laser"
	origin_tech = "magnets=3"
	rating = 2
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin/adv
	name = "advanced matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "advanced_matter_bin"
	origin_tech = "materials=3"
	rating = 2
	m_amt = 80

//Rating 3

/obj/item/weapon/stock_parts/capacitor/super
	name = "super capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "super_capacitor"
	origin_tech = "powerstorage=5;materials=4"
	rating = 3
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module/phasic
	name = "phasic scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	icon_state = "super_scan_module"
	origin_tech = "magnets=5"
	rating = 3
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator/pico
	name = "pico-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "pico_mani"
	origin_tech = "materials=5,programming=2"
	rating = 3
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser/ultra
	name = "ultra-high-power micro-laser"
	icon_state = "ultra_high_micro_laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = "magnets=5"
	rating = 3
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin/super
	name = "super matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "super_matter_bin"
	origin_tech = "materials=5"
	rating = 3
	m_amt = 80

//Rating 4

/obj/item/weapon/stock_parts/capacitor/quadratic
	name = "quadratic capacitor"
	desc = "An capacity capacitor used in the construction of a variety of devices."
	icon_state = "quadratic_capacitor"
	origin_tech = "powerstorage=6;materials=5"
	rating = 4
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module/triphasic
	name = "triphasic scanning module"
	desc = "A compact, ultra resolution triphasic scanning module used in the construction of certain devices."
	icon_state = "triphasic_scan_module"
	origin_tech = "magnets=6"
	rating = 4
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator/femto
	name = "femto-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "femto_mani"
	origin_tech = "materials=6;programming=3"
	rating = 4
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser/quadultra
	name = "quad-ultra micro-laser"
	icon_state = "quadultra_micro_laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = "magnets=6"
	rating = 4
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin/bluespace
	name = "bluespace matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "bluespace_matter_bin"
	origin_tech = "materials=6"
	rating = 4
	m_amt = 80

// Subspace stock parts

/obj/item/weapon/stock_parts/subspace/ansible
	name = "subspace ansible"
	icon_state = "subspace_ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	origin_tech = "programming=3;magnets=5;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/filter
	name = "hyperwave filter"
	icon_state = "hyperwave_filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	origin_tech = "programming=4;magnets=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/amplifier
	name = "subspace amplifier"
	icon_state = "subspace_amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	origin_tech = "programming=3;magnets=4;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/treatment
	name = "subspace treatment disk"
	icon_state = "treatment_disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	origin_tech = "programming=3;magnets=2;materials=5;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/analyzer
	name = "subspace wavelength analyzer"
	icon_state = "wavelength_analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	origin_tech = "programming=3;magnets=4;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/crystal
	name = "ansible crystal"
	icon_state = "ansible_crystal"
	desc = "A crystal made from pure glass used to transmit laser databursts to subspace."
	origin_tech = "magnets=4;materials=4;bluespace=2"
	g_amt = 50

/obj/item/weapon/stock_parts/subspace/transmitter
	name = "subspace transmitter"
	icon_state = "subspace_transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	origin_tech = "magnets=5;materials=5;bluespace=3"
	m_amt = 50

/obj/item/weapon/research//Makes testing much less of a pain -Sieve
	name = "research"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"
	desc = "A debug item for research."
	origin_tech = "materials=8;engineering=8;phorontech=8;powerstorage=8;bluespace=8;biotech=8;combat=8;magnets=8;programming=8;syndicate=8"

/obj/item/weapon/broom
	name = "Broom"
	desc = "This broom is made with the branches and leaves of a tree which secretes aromatic oils."
	icon_state = "broom_sauna"

/obj/item/weapon/broom/attack(mob/living/carbon/human/M, mob/living/user, def_zone)
	if(!istype(M) || user.a_intent == INTENT_HARM)
		return ..()
	if(wet - 5 < 0)
		to_chat(user, "<span class='userdanger'>Soak this [src] first!</span>")
		return
	if(M == user)
		to_chat(user, "<span class='userdanger'>You can't birching yourself!</span>")
		return
	if(!M.lying)
		to_chat(user, "<span class='userdanger'>[M] Must be lie down first!</span>")
		return

	var/zone = check_zone(user.zone_sel.selecting)
	var/obj/item/organ/external/BP = M.get_bodypart(zone)
	for(var/obj/item/clothing/C in M.get_equipped_items())
		if(C.body_parts_covered & BP.body_part)
			to_chat(user, "<span class='userdanger'>Take off [M]'s clothes first!</span>")
			return

	zone = parse_zone(zone)
	wet -= 5
	user.visible_message("<span class='notice'>A [user] lightly Birching [M]'s [zone] with [src]!</span>",
		"<span class='notice'>You lightly Birching [M]'s [zone] with [src]!</span>")




