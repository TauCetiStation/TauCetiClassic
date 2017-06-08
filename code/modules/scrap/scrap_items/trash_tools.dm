//TODO: Add sounds
/obj/item/weapon/hammer
	name = "hammer"
	desc = "Formerly common tool which became rare in space. Used to hammer nails, metal or someones head."
	icon = 'icons/obj/items.dmi'
	icon_state = "hammer"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 10.0
	throwforce = 10.0
	w_class = 2.0
	m_amt = 150
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")

/obj/item/weapon/machete
	name = "machete"
	desc = "Used to slash space vines."
	icon = 'icons/obj/items.dmi'
	icon_state = "machete"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 15.0
	throwforce = 10.0
	w_class = 3.0
	m_amt = 150
	edge = 1
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("slashed", "chopped", "sliced")

/obj/item/weapon/tongs
	name = "tongs"
	desc = "Smith tongs. Used to move hot metal objects."
	icon = 'icons/obj/items.dmi'
	icon_state = "cutters"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 6.0
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	m_amt = 80
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("pinched", "nipped")

//Stolen from TG (refactored)
/obj/item/weapon/sharpener
	name = "sharpener"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sharpener"
	desc = "A block that makes things sharp."
	var/used = 0
	var/increment = 4
	var/max = 30
	var/prefix = "sharpened"
	var/requires_edge = 1

/obj/item/weapon/sharpener/attackby(obj/item/I, mob/user, params)
	if(used)
		user << "<span class='notice'>The sharpening block is too worn to use again.</span>"
		return
	if(I.force >= max || I.throwforce >= max)//no esword sharpening
		user << "<span class='notice'>[I] is much too powerful to sharpen further.</span>"
		return
	if(requires_edge && !I.edge)
		user << "<span class='notice'>You can only sharpen items with edge, such as knives.</span>"
		return
	if(istype(I, /obj/item/weapon/twohanded))//some twohanded items should still be sharpenable, but handle force differently. therefore i need this stuff
		var/obj/item/weapon/twohanded/TH = I
		if(TH.force_wielded >= max)
			user << "<span class='notice'>[TH] is much too powerful to sharpen further.</span>"
			return
		if(TH.wielded)
			user << "<span class='notice'>[TH] must be unwielded before it can be sharpened.</span>"
			return
		if(TH.force_wielded > initial(TH.force_wielded))
			user << "<span class='notice'>[TH] has already been refined before. It cannot be sharpened further.</span>"
			return
		TH.force_wielded = Clamp(TH.force_wielded + increment, 0, max)//wieldforce is increased since normal force wont stay
	if(I.force > initial(I.force))
		user << "<span class='notice'>[I] has already been refined before. It cannot be sharpened further.</span>"
		return
	user.visible_message("<span class='notice'>[user] sharpens [I] with [src]!</span>", "<span class='notice'>You sharpen [I], making it much more deadly than before.</span>")
	if(!requires_sharpness)
		I.sharpness = IS_SHARP_ACCURATE
	I.sharp = 1
	I.force = Clamp(I.force + increment, 0, max)
	I.throwforce = Clamp(I.throwforce + increment, 0, max)
	I.name = "[prefix] [I.name]"
	name = "worn out [name]"
	desc = "[desc] At least, it used to."
	used = 1