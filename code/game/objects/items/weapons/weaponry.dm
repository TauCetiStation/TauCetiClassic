/obj/item/weapon/banhammer
	desc = "A banhammer."
	name = "banhammer"
	icon = 'icons/obj/items.dmi'
	icon_state = "toyhammer"
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 0
	w_class = ITEM_SIZE_SMALL
	throw_speed = 7
	throw_range = 15
	attack_verb = list("banned")

/obj/item/weapon/banhammer/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is hitting \himself with the [src.name]! It looks like \he's trying to ban \himself from life.</b></span>")
	return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)

/obj/item/weapon/sord/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(src, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)
	return ..()

/obj/item/weapon/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 40
	throwforce = 10
	sharp = 1
	edge = 1
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/claymore/Get_shield_chance()
	return 50

/obj/item/weapon/claymore/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</b></span>")
	return(BRUTELOSS)

/obj/item/weapon/claymore/light
	force = 20
	can_embed = 0

/obj/item/weapon/claymore/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(src, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)
	return ..()

/obj/item/weapon/katana
	name = "katana"
	desc = "Woefully underpowered in D20."
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_BACK
	force = 40
	throwforce = 10
	sharp = 1
	edge = 1
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/katana/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b></span>")
	return(BRUTELOSS)

/obj/item/weapon/katana/Get_shield_chance()
		return 50

/obj/item/weapon/katana/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(src, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)
	return ..()

/obj/item/weapon/harpoon
	name = "harpoon"
	sharp = 1
	edge = 0
	desc = "Tharr she blows!"
	icon_state = "harpoon"
	item_state = "harpoon"
	force = 20
	throwforce = 15
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("jabbed","stabbed","ripped")

/obj/item/weapon/switchblade
	name = "switchblade"
	icon_state = "switchblade"
	desc = "A sharp, concealable, spring-loaded knife."
	flags = CONDUCT
	force = 1
	w_class = ITEM_SIZE_SMALL
	throwforce = 5
	edge = FALSE
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"
	hitsound = list('sound/weapons/Genhit.ogg')
	attack_verb = list("stubbed", "poked")
	var/extended = FALSE
	tools = list(
		TOOL_KNIFE = 1
		)

/obj/item/weapon/switchblade/attack_self(mob/user)
	extended = !extended
	playsound(src, 'sound/weapons/batonextend.ogg', VOL_EFFECTS_MASTER)
	if(extended)
		force = 20
		w_class = ITEM_SIZE_NORMAL
		throwforce = 15
		edge = TRUE
		icon_state = "switchblade_ext"
		attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
		hitsound = list('sound/weapons/bladeslice.ogg')
	else
		force = 1
		w_class = ITEM_SIZE_SMALL
		throwforce = 5
		edge = FALSE
		icon_state = "switchblade"
		attack_verb = list("stubbed", "poked")
		hitsound = list('sound/weapons/Genhit.ogg')

/obj/item/weapon/switchblade/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting \his own throat with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS)
