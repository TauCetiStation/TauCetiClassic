/*
CONTAINS:
BEDSHEETS
LINEN BINS
*/

/obj/item/weapon/bedsheet
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/bedsheets.dmi'
	icon_state = "sheet"
	item_state = "bedsheet"
	slot_flags = SLOT_FLAGS_BACK
	layer = 4.0
	throwforce = 1
	throw_speed = 1
	throw_range = 2
	w_class = SIZE_TINY

	dyed_type = DYED_BEDSHEET

/obj/item/weapon/bedsheet/attack_self(mob/user)
	user.drop_item()
	if(layer == initial(layer))
		layer = 5
	else
		layer = initial(layer)
	add_fingerprint(user)
	return

/obj/item/weapon/bedsheet/attackby(obj/item/I, mob/user, params)
	if(I.sharp && isturf(loc)) // you can cut only bedsheet lying on the floor
		if(!ishuman(user))
			to_chat(user, "<span class='notice'>You try, but you can't.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts cutting \the [src] into cloth.</span>", "<span class='notice'>You start cutting \the [src] into cloth.</span>")
		if(do_after(user, 40, target = src))
			user.visible_message("<span class='notice'>[user] cuts \the [src] into cloth using [I].</span>", "<span class='notice'>You finish cutting \the [src] into cloth.</span>")
			new /obj/item/stack/sheet/cloth(get_turf(src), 3)
			qdel(src)
		return
	return ..()

/obj/item/weapon/bedsheet/blue
	icon_state = "sheetblue"

/obj/item/weapon/bedsheet/green
	icon_state = "sheetgreen"

/obj/item/weapon/bedsheet/orange
	icon_state = "sheetorange"

/obj/item/weapon/bedsheet/purple
	icon_state = "sheetpurple"

/obj/item/weapon/bedsheet/rainbow
	name = "rainbow bedsheet"
	desc = "A multicolored blanket.  It's actually several different sheets cut up and sewn together."
	icon_state = "sheetrainbow"

/obj/item/weapon/bedsheet/red
	icon_state = "sheetred"

/obj/item/weapon/bedsheet/yellow
	icon_state = "sheetyellow"

/obj/item/weapon/bedsheet/mime
	name = "mime's blanket"
	desc = "A very soothing striped blanket.  All the noise just seems to fade out when you're under the covers in this."
	icon_state = "sheetmime"

/obj/item/weapon/bedsheet/clown
	name = "clown's blanket"
	desc = "A rainbow blanket with a clown mask woven in.  It smells faintly of bananas."
	icon_state = "sheetclown"

/obj/item/weapon/bedsheet/captain
	name = "captain's bedsheet"
	desc = "It has a Nanotrasen symbol on it, and was woven with a revolutionary new kind of thread guaranteed to have 0.01% permeability for most non-chemical substances, popular among most modern captains."
	icon_state = "sheetcaptain"

/obj/item/weapon/bedsheet/rd
	name = "research director's bedsheet"
	desc = "It appears to have a beaker emblem, and is made out of fire-resistant material, although it probably won't protect you in the event of fires you're familiar with every day."
	icon_state = "sheetrd"

/obj/item/weapon/bedsheet/medical
	name = "medical blanket"
	desc = "It's a sterilized* blanket commonly used in the Medbay.  *Sterilization is voided if a virologist is present onboard the station."
	icon_state = "sheetmedical"

/obj/item/weapon/bedsheet/hos
	name = "head of security's bedsheet"
	desc = "It is decorated with a shield emblem.  While crime doesn't sleep, you do, but you are still THE LAW!"
	icon_state = "sheethos"

/obj/item/weapon/bedsheet/hop
	name = "head of personnel's bedsheet"
	desc = "It is decorated with a key emblem.  For those rare moments when you can rest and cuddle with Ian without someone screaming for you over the radio."
	icon_state = "sheethop"

/obj/item/weapon/bedsheet/ce
	name = "chief engineer's bedsheet"
	desc = "It is decorated with a wrench emblem.  It's highly reflective and stain resistant, so you don't need to worry about ruining it with oil."
	icon_state = "sheetce"

/obj/item/weapon/bedsheet/brown
	icon_state = "sheetbrown"

/obj/item/weapon/bedsheet/psych
	icon_state = "sheetpsych"

/obj/item/weapon/bedsheet/centcom
	name = "Centcom bedsheet"
	desc = "Woven with advanced nanothread for warmth as well as being very decorated, essential for all officials."
	icon_state = "sheetcentcom"

/obj/item/weapon/bedsheet/syndie
	name = "syndicate bedsheet"
	desc = "It has a syndicate emblem and it has an aura of evil."
	icon_state = "sheetsyndie"

/obj/item/weapon/bedsheet/cult
	name = "cultist's bedsheet"
	desc = "You might dream of Nar'Sie if you sleep with this.  It seems rather tattered and glows of an eldritch presence."
	icon_state = "sheetcult"

/obj/item/weapon/bedsheet/wiz
	name = "wizard's bedsheet"
	desc = "A special fabric enchanted with magic so you can have an enchanted night.  It even glows!"
	icon_state = "sheetwiz"

/obj/item/weapon/bedsheet/gar
	name = "gar bedsheet"
	desc = "A surprisingly soft gar bedsheet."
	icon_state = "sheetgurren"
	item_state = "bedsheet"


/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "A linen bin. It looks rather cosy."
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin"
	anchored = TRUE
	pass_flags = PASSTABLE
	var/sheets_capacity = 10
	var/list/sheets = list()
	var/obj/item/weapon/storage/internal/bedsheetbin/hidden

/obj/item/weapon/storage/internal/bedsheetbin/can_be_inserted(obj/item/W, stop_messages = FALSE)
	. = ..()
	if(loc && istype(loc, /obj/structure/bedsheetbin))
		var/obj/structure/bedsheetbin/B = loc
		if(!B.sheets || !B.sheets.len)
			if(!stop_messages)
				to_chat(usr, "<span class='warning'>There is no bedsheets to hide something under!</span>")
			return FALSE
	if(contents.len)
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>There is already something under the sheets.</span>")
		return FALSE

/obj/structure/bedsheetbin/atom_init()
	. = ..()
	hidden = new/obj/item/weapon/storage/internal/bedsheetbin(src)
	hidden.set_slots(slots = 1, slot_size = SIZE_SMALL)

/obj/structure/bedsheetbin/full/atom_init()
	. = ..()
	for(var/i in 1 to sheets_capacity)
		sheets += new /obj/item/weapon/bedsheet(src)
	update_icon()

/obj/structure/bedsheetbin/examine(mob/user)
	..()
	switch(sheets.len)
		if(0)
			to_chat(user, "There are no bed sheets in the bin.")
		if(1)
			to_chat(user, "There is one bed sheet in the bin.")
		else
			to_chat(user, "There are [sheets.len] bed sheets in the bin.")

/obj/structure/bedsheetbin/update_icon()
	if(!sheets.len)
		icon_state = "[initial(icon_state)]"
	else if(sheets.len < sheets_capacity / 2)
		icon_state = "[initial(icon_state)]-half"
	else
		icon_state = "[initial(icon_state)]-full"
	return ..()

/obj/structure/bedsheetbin/attackby(obj/item/I, mob/user, params)
	if(isscrewing(I))
		to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
		if(I.use_tool(src, user, SKILL_TASK_EASY, volume = 50))
			playsound(loc, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
			deconstruct()
	else if(iswrenching(I))
		to_chat(user, "<span class='notice'>You begin [anchored ? "unwrenching" : "wrenching"] \the [src].</span>")
		if(I.use_tool(src, user, SKILL_TASK_EASY, volume = 50))
			playsound(loc, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
	else if(istype(I, /obj/item/weapon/bedsheet))
		if(sheets.len < sheets_capacity)
			user.drop_from_inventory(I, src)
			sheets.Add(I)
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else
			to_chat(user, "<span class='warning'>The [src] is full!</span>")
	else if(isitem(I) && user.a_intent != INTENT_HARM)
		hidden.attackby(I, user, params)
	else
		return ..()
	update_icon()

/obj/structure/bedsheetbin/MouseDrop(obj/over_object as obj)
	if (hidden && hidden.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/structure/bedsheetbin/hear_talk(mob/M, msg, verb, datum/language/speaking)
	if(hidden)
		hidden.hear_talk(M, msg, verb, speaking)
	..()

/obj/structure/bedsheetbin/attack_paw(mob/living/user)
	return attack_hand(user)

/obj/structure/bedsheetbin/attack_hand(mob/living/user)
	if(sheets.len)
		var/obj/item/weapon/bedsheet/B
		B = sheets[sheets.len]
		sheets.Remove(B)
		user.try_take(B, loc)
		to_chat(user, "<span class='notice'>You take [B] out of [src].</span>")
		if(hidden && hidden.contents.len)
			hidden.hide_from(user)
			for(var/obj/item/I in hidden.contents)
				visible_message("<span class='notice'>[I] falls out of [B]!</span>")
				hidden.remove_from_storage(I, loc)
		update_icon()
	add_fingerprint(user)

/obj/structure/bedsheetbin/deconstruct()
	new /obj/item/stack/sheet/metal(loc, 2)
	if(hidden && hidden.contents.len)
		for(var/obj/item/I in hidden.contents)
			visible_message("<span class='notice'>[I] falls out of [src]!</span>")
			hidden.remove_from_storage(I, loc)
	if(sheets.len)
		for(var/obj/item/weapon/bedsheet/B in sheets)
			sheets.Remove(B)
			B.forceMove(loc)
	..()

/obj/structure/bedsheetbin/Destroy()
	. = ..()
	if(hidden && hidden.contents.len)
		for(var/obj/item/I in hidden.contents)
			QDEL_NULL(I)
	QDEL_NULL(hidden)
	if(sheets.len)
		for(var/obj/item/weapon/bedsheet/B in sheets)
			QDEL_NULL(B)
