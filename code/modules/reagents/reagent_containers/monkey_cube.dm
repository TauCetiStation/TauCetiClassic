/obj/item/weapon/reagent_containers/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon = 'icons/obj/food.dmi'
	icon_state = "monkeycube"
	list_reagents = list("nutriment" = 10)

	var/wrapped = 0
	var/monkey_type = /mob/living/carbon/monkey

/obj/item/weapon/reagent_containers/monkeycube/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(target,/obj/structure/sink) && !wrapped)
		to_chat(user, "<span class='notice'>You place \the [name] under a stream of water...</span>")
		user.drop_item()
		loc = get_turf(target)
		return Expand()
	..()

/obj/item/weapon/reagent_containers/monkeycube/entered_water_turf()
	Expand()

/obj/item/weapon/reagent_containers/monkeycube/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)

/obj/item/weapon/reagent_containers/monkeycube/digest_act(obj/item/organ/internal/stomach/S)
	to_chat(S.owner, "<span class = 'warning'>Something inside of you suddently expands!</span>")

	var/mob/living/carbon/human/H = S.owner
	var/mob/living/carbon/monkey/ook = new monkey_type(S) //no other way to get access to the vars, alas
	qdel(src)
	reagents.trans_to(S, reagents.total_volume)
	if(S.get_fullness() - get_storage_cost() <= S.stomach_capacity)
		return

	//Do not try to understand.
	var/obj/item/weapon/surprise = new/obj/item/weapon(H)
	surprise.icon = ook.icon
	surprise.icon_state = ook.icon_state
	surprise.name = "malformed [ook.name]"
	surprise.desc = "Looks like \a very deformed [ook.name], a little small for its kind. It shows no signs of life."
	qdel(ook)	//rip nullspace monkey
	surprise.transform *= 0.6
	surprise.add_blood(H)
	var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_CHEST]
	BP.fracture()
	for (var/obj/item/organ/internal/IO in BP.bodypart_organs)
		IO.take_damage(rand(IO.min_bruised_damage, IO.min_broken_damage + 1))

	if (!BP.hidden && prob(60)) //set it snuggly
		BP.hidden = surprise
		BP.cavity = 0
	else 		//someone is having a bad day
		BP.embed(surprise)
		BP.take_damage(30, 0, DAM_SHARP|DAM_EDGE, "Animal escaping the ribcage")

/obj/item/weapon/reagent_containers/monkeycube/proc/Expand()
	for(var/mob/M in viewers(src,7))
		to_chat(M, "<span class='rose'>\The [src] expands!</span>")
	new monkey_type(loc)
	qdel(src)

/obj/item/weapon/reagent_containers/monkeycube/proc/Unwrap(mob/user)
	icon_state = "monkeycube"
	desc = "Just add water!"
	to_chat(user, "You unwrap the cube.")
	wrapped = 0
	return

/obj/item/weapon/reagent_containers/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	wrapped = 1


/obj/item/weapon/reagent_containers/monkeycube/farwacube
	name = "farwa cube"
	monkey_type = /mob/living/carbon/monkey/tajara

/obj/item/weapon/reagent_containers/monkeycube/wrapped/farwacube
	name = "farwa cube"
	monkey_type = /mob/living/carbon/monkey/tajara


/obj/item/weapon/reagent_containers/monkeycube/stokcube
	name = "stok cube"
	monkey_type = /mob/living/carbon/monkey/unathi

/obj/item/weapon/reagent_containers/monkeycube/wrapped/stokcube
	name = "stok cube"
	monkey_type = /mob/living/carbon/monkey/unathi


/obj/item/weapon/reagent_containers/monkeycube/neaeracube
	name = "neaera cube"
	monkey_type = /mob/living/carbon/monkey/skrell

/obj/item/weapon/reagent_containers/monkeycube/wrapped/neaeracube
	name = "neaera cube"
	monkey_type = /mob/living/carbon/monkey/skrell
