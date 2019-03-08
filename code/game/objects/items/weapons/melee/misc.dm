/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 10
	hitsound = 'sound/weapons/captainwhip.ogg'
	throwforce = 7
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "combat=4"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")

/obj/item/weapon/melee/chainofcommand/suicide_act(mob/user)
	to_chat(viewers(user), "\red <b>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b>")
	return (OXYLOSS)

/obj/item/weapon/melee/icepick
	name = "ice pick"
	desc = "Used for chopping ice. Also excellent for mafia esque murders."
	icon_state = "ice_pick"
	item_state = "ice_pick"
	force = 15
	throwforce = 10
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("stabbed", "jabbed", "iced,")

/obj/item/weapon/combat_knife
	name = "combat knife"
	desc = "Small blade used for cutting, stabbing and killing if you've lost your primary weapon."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "combatknife"
	item_state = "combatknife"
	flags = CONDUCT
	force = 10
	sharp = 1
	edge = 1
	w_class = ITEM_SIZE_SMALL
	throwforce = 10
	m_amt = 7500
	origin_tech = "materials=2;combat=2"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced")
