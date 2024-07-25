/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 10
	hitsound = list('sound/weapons/captainwhip.ogg')
	throwforce = 7
	w_class = SIZE_SMALL
	origin_tech = "combat=4"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")

/obj/item/weapon/melee/chainofcommand/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b></span>")
	return (OXYLOSS)

/obj/item/weapon/melee/chainofcommand/afterattack(atom/target, mob/user, proximity, params)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(!user.isloyal())
		to_chat(user, "<span class='danger'[bicon(src)] SPECIAL FUNCTION DISABLED. LOYALTY IMPLANT NOT FOUND.</span>")
		return
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	user.visible_message("<span class='notice'>[user] flails their [src] at [H]</span>")
	if(HAS_TRAIT_FROM(H, TRAIT_VISUAL_OBEY, FAKE_IMPLANT_TRAIT))
		//like clumsy
		explosion(user.loc, 0, 0, 1, 7)
		to_chat(user, "<span class='danger'>[src] blows up in your face.</span>")
		if(isliving(user))
			var/mob/living/living_user = user
			living_user.Sleeping(15 SECONDS)
			if(ishuman(user))
				var/mob/living/carbon/human/user_human = living_user
				var/obj/item/organ/external/BP = user_human.get_bodypart(BP_ACTIVE_ARM)
				if(BP)
					BP.droplimb(FALSE, FALSE, DROPLIMB_BLUNT)
		to_chat(target, "<span class='userdanger'>COVER BLOWN!!! THEY KNOW ABOUT US!!!</span>")
		qdel(src)
		return
	if(!H.isimplantedobedience())
		return
	H.Stun(5)
	H.apply_effect(5, WEAKEN)
	H.apply_effect(20, AGONY)
	to_chat(H, "<span class='danger'You feel something beep inside of you and a wave of electricity pierces your body!</span>")
	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
	sparks.set_up(3, 0, get_turf(H))
	sparks.start()

/obj/item/weapon/melee/icepick
	name = "ice pick"
	desc = "Used for chopping ice. Also excellent for mafia esque murders."
	icon_state = "ice_pick"
	item_state = "ice_pick"
	force = 15
	throwforce = 10
	w_class = SIZE_TINY
	attack_verb = list("stabbed", "jabbed", "iced,")
