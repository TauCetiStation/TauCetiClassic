/obj/item/gland
	name = "fleshy mass"
	desc = "Eww!"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gland"
	var/cooldown_low = 300
	var/cooldown_high = 300
	var/next_activation = 0
	var/uses // -1 For inifinite
	var/active = 0
	var/mob/living/carbon/human/host

/obj/item/gland/proc/HostCheck()
	if(ishuman(host) && host == src.loc)
		if(host.stat != DEAD)
			return TRUE
	return FALSE

/obj/item/gland/proc/Start()
	active = 1
	next_activation  = world.time + rand(cooldown_low,cooldown_high)
	START_PROCESSING(SSobj, src)

/obj/item/gland/proc/Inject(mob/living/carbon/human/target)
	host = target
	target.organs += src
	src.loc = target

/obj/item/gland/process()
	if(!active)
		STOP_PROCESSING(SSobj, src)
		return
	if(next_activation <= world.time)
		//This gives a chance to transplant the gland active into someone else if you're fast
		if(!HostCheck())
			active = 0
			return
		activate()
		uses--
		next_activation  = world.time + rand(cooldown_low,cooldown_high)
	if(uses == 0)
	 active = 0

/obj/item/gland/proc/activate()
	return


//HEAL
/obj/item/gland/heals
	desc = "Heals the host."
	cooldown_low = 200
	cooldown_high = 400
	uses = -1
	icon_state = "health"

/obj/item/gland/heals/activate()
	to_chat(host, "<span class='notice'>You feel curiously revitalized.</span>")
	host.adjustBruteLoss(-25)
	host.adjustOxyLoss(-25)
	host.adjustFireLoss(-25)


//SLIME
/obj/item/gland/slime
	desc = "Host vomits slime."
	cooldown_low = 600
	cooldown_high = 1200
	uses = -1
	icon_state = "slime"

/obj/item/gland/slime/activate()
	to_chat(host, "<span class='warning'>You feel nauseous!</span>")

	var/turf/T = get_turf(host)
	if(host.vomit())
		new/mob/living/simple_animal/slime(T)


//SLIME BOOM
/obj/item/gland/true_form
	desc = "Reveals true form of the host"
	cooldown_low = 1200
	cooldown_high = 2400
	uses = 1

/obj/item/gland/true_form/activate()
	host.visible_message("<span class='danger'>[host] explodes into creatures!</span>")
	var/turf/pos = get_turf(host)
	new /mob/living/carbon/slime(pos)
	new /mob/living/simple_animal/corgi(pos)
	new /mob/living/simple_animal/mouse(pos)
	var/obj/effect/proc_holder/spell/S = new /obj/effect/proc_holder/spell/no_target/shapeshift/abductor()
	host.AddSpell(S)
	S.cast(null, host)

//MINDSHOCK
/obj/item/gland/mindshock
	desc = "Confuses everyone near host."
	cooldown_low = 300
	cooldown_high = 300
	uses = -1
	icon_state = "mindshock"

/obj/item/gland/mindshock/activate()
	to_chat(host, "<span class='notice'>You get a headache.</span>")

	var/turf/T = get_turf(host)
	for(var/mob/living/carbon/human/H in orange(4,T))
		if(H == host)
			continue
		to_chat(H, "<span class='alien'> You hear a buzz in your head </span>")
		H.AdjustConfused(20)


//POP
/obj/item/gland/pop
	desc = "Changes host species."
	cooldown_low = 900
	cooldown_high = 1800
	uses = 5
	icon_state = "species"

/obj/item/gland/pop/activate()
	to_chat(host, "<span class='notice'>You feel unlike yourself.</span>")
	host.set_species_soft(pick(HUMAN, UNATHI, TAJARAN, SKRELL, DIONA, PODMAN, VOX))

//Abductor
/obj/item/gland/abductor
	desc = "Creates your new ally"
	uses = 0
	icon_state = "species"
	var/team = 0

/obj/item/gland/abductor/Inject(mob/living/carbon/human/target)
	. = ..()
	if(tgui_alert(target, "Вы станете новым членом команды пришельцев, и за одно предадите всё человечество!", "Стать ассистентом пришельцев?", list("Да", "Нет"), 15 SECONDS) == "Да")
		to_chat(host, "<span class='notice'>You feel something moving in your brain.</span>")
		host.AdjustConfused(8)
		host.make_jittery(60)
		host.emote("scream")
		var/datum/faction/abductors/req_f
		for(var/datum/faction/abductors/F in find_factions_by_type(/datum/faction/abductors))
			if(F.team_number == team)
				req_f = F
				break
		if(!req_f)
			return
		host.setOxyLoss(0) //They can't heal oxyloss, so we need to deal with it right now
		var/datum/role/R = SSticker.mode.CreateRole(/datum/role/abductor/assistant, host)
		req_f.HandleRecruitedRole(R)
		setup_role(R, TRUE)
	else
		host = null
		target.organs -= src
		forceMove(get_turf(target))

//VENTCRAWLING
/obj/item/gland/ventcrawling
	desc = "Gives the host ability to ventcrawl."
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "vent"

/obj/item/gland/ventcrawling/activate()
	to_chat(host, "<span class='notice'>You feel very stretchy.</span>")
	host.ventcrawler = 2
	return


//VIRAL
/obj/item/gland/viral
	desc = "Makes the host carrier of a virus."
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "viral"

/obj/item/gland/viral/activate()
	to_chat(host, "<span class='warning'>You feel sick.</span>")

	var/datum/disease2/disease/D = new /datum/disease2/disease()
	D.makerandom(spread_vector = DISEASE_SPREAD_AIRBORNE)
	D.infectionchance = rand(1,100)

	if(ishuman(host))
		var/mob/living/carbon/human/H = host
		if (H.species)
			D.affected_species = list(H.species.name)

	infect_virus2(host,D,1)


//EMP
/obj/item/gland/emp //TODO : Replace with something more interesting
	desc = "Makes the host emmit emp pulse."
	cooldown_low = 900
	cooldown_high = 1600
	uses = 5
	icon_state = "emp"

/obj/item/gland/emp/activate()
	to_chat(host, "<span class='warning'>You feel a spike of pain in your head.</span>")
	empulse(get_turf(host), 2, 5, 1)


//SPIDERMAN
/obj/item/gland/spiderman
	desc = "Makes host produce spiders."
	cooldown_low = 450
	cooldown_high = 900
	uses = 10
	icon_state = "spider"

/obj/item/gland/spiderman/activate()
	to_chat(host, "<span class='warning'>You feel something crawling in your skin.</span>")
	if(uses == initial(uses))
		host.faction = "spiders"
	new /obj/structure/spider/spiderling(host.loc)


//EGG
/obj/item/gland/egg
	desc = "Makes the host lay eggs filled with acid."
	cooldown_low = 300
	cooldown_high = 400
	uses = -1
	icon_state = "egg"

/obj/item/gland/egg/activate()
	to_chat(host, "<span class='boldannounce'>You lay an egg!</span>")
	var/obj/item/weapon/reagent_containers/food/snacks/egg/egg = new(host.loc)
	egg.reagents.add_reagent("sacid",20)
	egg.desc += " It smells bad."


//BLOODY
/obj/item/gland/bloody
	desc = "Sprays blood on everything in sight and deals damage to host."
	cooldown_low = 200
	cooldown_high = 400
	uses = -1

/obj/item/gland/bloody/activate()
	if(prob(25))
		host.adjustBruteLoss(15)

	host.visible_message("<span class='danger'>[host]'s skin erupts with blood!</span>",\
	"<span class='userdanger'>Blood pours from your skin!</span>")

	for(var/turf/T in oview(2,host)) //Make this respect walls and such
		T.add_blood(host)
	for(var/mob/living/carbon/human/H in oview(3,host)) //Blood decals for simple animals would be neat. aka Carp with blood on it.
		if(H.wear_suit)
			H.wear_suit.add_blood(host)
		else if(H.w_uniform)
			H.w_uniform.add_blood(host)


//BODYSNATCH
/obj/item/gland/bodysnatch
	desc = "Turns host into a cocoon from with hatches body looking like the host."
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1

/obj/item/gland/bodysnatch/activate()
	to_chat(host, "<span class='warning'>You feel something moving around inside you...</span>")

	var/obj/effect/cocoon/abductor/C = new (get_turf(host))

	host.ghostize()
	host.revive()
	host.mutations |= NOCLONE
	host.adjustBrainLoss(100)
	host.loc = C

	C.Start()
	new /obj/effect/gibspawner/human(get_turf(C))
	return

/obj/effect/cocoon/abductor
	name = "slimy cocoon"
	desc = "Something is moving inside."
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon_large3"
	color = rgb(10,120,10)
	density = TRUE
	var/hatch_time = 0

/obj/effect/cocoon/abductor/proc/Start()
	hatch_time = world.time + 600
	START_PROCESSING(SSobj, src)

/obj/effect/cocoon/abductor/process()
	if(world.time > hatch_time)
		STOP_PROCESSING(SSobj, src)
		for(var/mob/M in contents)
			visible_message("<span class='warning'>[src] hatches!</span>")
			M.loc = src.loc
		qdel(src)
