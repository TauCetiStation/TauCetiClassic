/datum/spellbook_entry
	var/name = "Entry Name"

	var/spell_type = null
	var/desc = ""
	var/category = "Offensive"
	var/log_name = "XX" //What it shows up as in logs
	var/cost = 2
	var/refundable = 1
	var/surplus = -1 // -1 for infinite, not used by anything atm
	var/obj/effect/proc_holder/spell/S = null //Since spellbooks can be used by only one person anyway we can track the actual spell
	var/buy_word = "Learn"

/datum/spellbook_entry/proc/IsAvailible() // For config prefs / gamemode restrictions - these are round applied
	return 1

/datum/spellbook_entry/proc/CanBuy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book) // Specific circumstances
	if(book.uses<cost)
		return 0
	for(var/obj/effect/proc_holder/spell/spell in user.mind.spell_list)
		if(istype(spell,spell_type))
			return 0
	return 1

/datum/spellbook_entry/proc/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book) //return 1 on success
	if(!S || QDELETED(S))
		S = new spell_type()
	feedback_add_details("wizard_spell_learned",log_name)
	user.AddSpell(S)
	to_chat(user, "<span class='notice'>You have learned [S.name].</span>")
	return 1

/datum/spellbook_entry/proc/CanRefund(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	if(!refundable)
		return 0
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			return 1
	return 0

/datum/spellbook_entry/proc/Refund(mob/living/carbon/human/user,obj/item/weapon/spellbook/book) //return point value or -1 for failure
	var/area/wizard_station/A = locate()
	if(!(user in A.contents))
		to_chat(user, "<span clas=='warning'>You can only refund spells at the wizard lair</span>")
		return -1
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.spell_list)
		if(initial(S.name) == initial(aspell.name))
			user.spellremove(aspell)
			qdel(S)
			return cost
	return -1
/datum/spellbook_entry/proc/GetInfo()
	if(!S)
		S = new spell_type()
	var/dat =""
	dat += "<b>[initial(S.name)]</b>"
	if(S.charge_type == "recharge")
		dat += " Cooldown:[S.charge_max/10]"
	dat += " Cost:[cost]<br>"
	dat += "<i>[S.desc][desc]</i><br>"
	dat += "[S.clothes_req?"Needs wizard garb":"Can be cast without wizard garb"]<br>"
	return dat

/datum/spellbook_entry/fireball
	name = "Fireball"
	spell_type = /obj/effect/proc_holder/spell/in_hand/fireball
	log_name = "FB"

/datum/spellbook_entry/rod_form
	name = "Rod Form"
	spell_type = /obj/effect/proc_holder/spell/targeted/rod_form
	log_name = "RF"

/datum/spellbook_entry/magicm
	name = "Magic Missile"
	spell_type = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	log_name = "MM"
	category = "Defensive"

/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	spell_type = /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	log_name = "DT"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/repulse
	name = "Repulse"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/repulse
	log_name = "RP"
	category = "Defensive"

/datum/spellbook_entry/timestop
	name = "Time Stop"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop
	log_name = "TS"
	category = "Defensive"

/datum/spellbook_entry/smoke
	name = "Smoke"
	spell_type = /obj/effect/proc_holder/spell/targeted/smoke
	log_name = "SM"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/blind
	name = "Blind"
	spell_type = /obj/effect/proc_holder/spell/targeted/trigger/blind
	log_name = "BD"
	cost = 1

/datum/spellbook_entry/mindswap
	name = "Mindswap"
	spell_type = /obj/effect/proc_holder/spell/targeted/mind_transfer
	log_name = "MT"
	category = "Mobility"

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	spell_type = /obj/effect/proc_holder/spell/targeted/forcewall
	log_name = "FW"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/blink
	name = "Blink"
	spell_type = /obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	log_name = "BL"
	category = "Mobility"

/datum/spellbook_entry/teleport
	name = "Teleport"
	spell_type = /obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	log_name = "TP"
	category = "Mobility"

/datum/spellbook_entry/mutate
	name = "Mutate"
	spell_type = /obj/effect/proc_holder/spell/targeted/genetic/mutate
	log_name = "MU"

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	spell_type = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	log_name = "EJ"
	category = "Mobility"

/datum/spellbook_entry/knock
	name = "Knock"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/knock
	log_name = "KN"
	category = "Mobility"
	cost = 1

/datum/spellbook_entry/summonitem
	name = "Summon Item"
	spell_type = /obj/effect/proc_holder/spell/targeted/summonitem
	log_name = "IS"
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	spell_type = /obj/effect/proc_holder/spell/in_hand/tesla
	log_name = "LB"
	cost = 3

/datum/spellbook_entry/lightningbolt/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book) //return 1 on success
	. = ..()
	user.tesla_ignore = TRUE

/datum/spellbook_entry/arcane_barrage
	name = "Arcane Barrage"
	spell_type = /obj/effect/proc_holder/spell/in_hand/arcane_barrage
	log_name = "AB"

/datum/spellbook_entry/barnyard
	name = "Barnyard Curse"
	spell_type = /obj/effect/proc_holder/spell/targeted/barnyardcurse
	log_name = "BC"

/datum/spellbook_entry/charge
	name = "Charge"
	spell_type = /obj/effect/proc_holder/spell/targeted/charge
	log_name = "CH"
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/spacetime_dist
	name = "Spacetime Distortion"
	spell_type = /obj/effect/proc_holder/spell/targeted/spacetime_dist
	log_name = "STD"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/the_traps
	name = "The Traps!"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps
	log_name = "TT"
	category = "Offensive"
	cost = 1

/datum/spellbook_entry/item
	name = "Buy Item"
	refundable = 0
	buy_word = "Summon"
	var/item_path= null

/datum/spellbook_entry/item/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	new item_path(get_turf(user))
	feedback_add_details("wizard_spell_learned",log_name)
	return 1

/datum/spellbook_entry/item/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	dat += " Cost:[cost]<br>"
	dat += "<i>[desc]</i><br>"
	if(surplus>=0)
		dat += "[surplus] left.<br>"
	return dat

/datum/spellbook_entry/item/staffchange
	name = "Staff of Change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	item_path = /obj/item/weapon/gun/magic/staff/change
	log_name = "ST"

/datum/spellbook_entry/item/staffanimation
	name = "Staff of Animation"
	desc = "An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines."
	item_path = /obj/item/weapon/gun/magic/staff/animate
	log_name = "SA"
	category = "Assistance"

/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "A particular staff that can mold solid metal into ornate doors. Useful for getting around in the absence of other transportation. Does not work on glass."
	item_path = /obj/item/weapon/gun/magic/staff/doorcreation
	log_name = "SD"
	cost = 1
	category = "Mobility"

/datum/spellbook_entry/item/staffhealing
	name = "Staff of Healing"
	desc = "An altruistic staff that can heal the lame and raise the dead."
	item_path = /obj/item/weapon/gun/magic/staff/healing
	log_name = "SH"
	cost = 1
	category = "Defensive"

/datum/spellbook_entry/item/scryingorb
	name = "Scrying Orb"
	desc = "An incandescent orb of crackling energy, using it will allow you to ghost while alive, allowing you to spy upon the station with ease. In addition, buying it will permanently grant you x-ray vision."
	item_path = /obj/item/weapon/scrying
	log_name = "SO"
	category = "Defensive"

/datum/spellbook_entry/item/scryingorb/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	if(..())
		user.mutations.Add(XRAY)
		user.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
		user.see_in_dark = 8
		user.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		user.update_mutations()
	return 1

/datum/spellbook_entry/item/soulstones
	name = "Six Soul Stone Shards and the spell Artificer"
	desc = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot."
	item_path = /obj/item/weapon/storage/belt/soulstone/full
	log_name = "SS"
	category = "Assistance"

/datum/spellbook_entry/item/soulstones/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	. =..()
	if(.)
		user.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(user))
	return .

/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "A Necromantic stone is able to resurrect three dead individuals as skeletal thralls for you to command."
	item_path = /obj/item/device/necromantic_stone
	log_name = "NS"
	category = "Assistance"

/datum/spellbook_entry/item/armor
	name = "Mastercrafted Armor Set"
	desc = "An artefact suit of armor that allows you to cast spells while providing more protection against attacks and the void of space."
	item_path = /obj/item/clothing/suit/space/rig/wizard
	log_name = "HS"
	category = "Defensive"

/datum/spellbook_entry/item/armor/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	. = ..()
	if(.)
		new /obj/item/clothing/shoes/sandal(get_turf(user)) //In case they've lost them.
		new /obj/item/clothing/head/helmet/space/rig/wizard(get_turf(user))//To complete the outfit

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service, using it will summon them to your side."
	item_path = /obj/item/weapon/contract
	log_name = "CT"
	category = "Assistance"

/datum/spellbook_entry/item/contract/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	var/obj/item/weapon/contract/contract = new(get_turf(user))
	contract.wizard = user.mind
	feedback_add_details("wizard_spell_learned",log_name)
	return 1


/*datum/spellbook_entry/item/battlemage
	name = "Battlemage Armour"
	desc = "An ensorcelled suit of armour, protected by a powerful shield. The shield can completly negate sixteen attacks before being permanently depleted."
	item_path = /obj/item/clothing/suit/space/hardsuit/shielded/wizard
	log_name = "BM"
	limit = 1
	category = "Defensive"

/datum/spellbook_entry/item/battlemage_charge
	name = "Battlemage Armour Charges"
	desc = "A powerful defensive rune, it will grant eight additional charges to a suit of battlemage armour."
	item_path = /obj/item/wizard_armour_charge
	log_name = "AC"
	category = "Defensive"
	cost = 1*/

/datum/spellbook_entry/summon
	name = "Summon Stuff"
	category = "Rituals"
	refundable = 0
	buy_word = "Cast"
	var/active = 0

/datum/spellbook_entry/summon/CanBuy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	return ..() && !active

/datum/spellbook_entry/summon/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	if(cost>0)
		dat += " Cost:[cost]<br>"
	else
		dat += " No Cost<br>"
	dat += "<i>[desc]</i><br>"
	if(active)
		dat += "<b>Already cast!</b><br>"
	return dat

/datum/spellbook_entry/summon/IsAvailible()
	if(!ticker.mode) // In case spellbook is placed on map
		return 0
	return 1

/*datum/spellbook_entry/summon/ghosts
	name = "Summon Ghosts"
	desc = "Spook the crew out by making them see dead people. Be warned, ghosts are capricious and occasionally vindicative, and some will use their incredibly minor abilties to frustrate you."
	log_name = "SGH"

/datum/spellbook_entry/summon/ghosts/IsAvailible()
	if(!ticker.mode)
		return FALSE
	else
		return TRUE*/

/datum/spellbook_entry/summon/guns
	name = "Summon Guns"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill you. Just be careful not to stand still too long!"
	log_name = "SG"

/datum/spellbook_entry/summon/guns/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	feedback_add_details("wizard_spell_learned",log_name)
	rightandwrong(0, user)
	active = 1
	to_chat(user, "<span class='notice'>You have cast summon guns!</span>")
	return 1

/datum/spellbook_entry/summon/magic
	name = "Summon Magic"
	desc = "Share the wonders of magic with the crew and show them why they aren't to be trusted with it at the same time."
	log_name = "SU"

/datum/spellbook_entry/summon/magic/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	feedback_add_details("wizard_spell_learned",log_name)
	rightandwrong(1, user)
	active = 1
	to_chat(user, "<span class='notice'>You have cast summon magic!</span>")
	return 1

/*datum/spellbook_entry/summon/ghosts/Buy(mob/living/carbon/human/user, obj/item/weapon/spellbook/book)
	feedback_add_details("wizard_spell_learned", log_name)
	new /datum/round_event/wizard/ghost()
	active = TRUE
	to_chat(user, "<span class='notice'>You have cast summon ghosts!</span>")
	playsound(get_turf(user), 'sound/effects/ghost2.ogg', 50, 1)
	return TRUE*/

/obj/item/weapon/spellbook
	name = "spell book"
	desc = "An unearthly tome that glows with power."
	w_class = 2
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	var/uses = 10
	var/temp = null
	var/tab = null
	var/mob/living/carbon/human/owner
	var/list/datum/spellbook_entry/entries = list()
	var/list/categories = list()

/obj/item/weapon/spellbook/examine(mob/user)
	..()
	if(owner)
		to_chat(user, "There is a small signature on the front cover: \"[owner]\".")
	else
		to_chat(user, "It appears to have no author.")

/obj/item/weapon/spellbook/New()
	..()
	var/entry_types = subtypesof(/datum/spellbook_entry) - /datum/spellbook_entry/item - /datum/spellbook_entry/summon
	for(var/T in entry_types)
		var/datum/spellbook_entry/E = new T
		if(E.IsAvailible())
			entries |= E
			categories |= E.category
		else
			qdel(E)
	tab = categories[1]

/obj/item/weapon/spellbook/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/contract))
		var/obj/item/weapon/contract/contract = O
		if(contract.uses != initial(contract.uses))
			to_chat(user, "<span class='warning'>The contract has been used, you can't get your points back now!</span>")
		else
			to_chat(user, "<span class='notice'>You feed the contract back into the spellbook, refunding your points.</span>")
			uses++
			qdel(O)

/obj/item/weapon/spellbook/proc/GetCategoryHeader(category)
	var/dat = ""
	switch(category)
		if("Offensive")
			dat += "Spells and items geared towards debilitating and destroying.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
		if("Defensive")
			dat += "Spells and items geared towards improving your survivabilty or reducing foes' ability to attack.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
		if("Mobility")
			dat += "Spells and items geared towards improving your ability to move. It is a good idea to take at least one.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
		if("Assistance")
			dat += "Spells and items geared towards bringing in outside forces to aid you or improving upon your other items and abilties.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
		if("Challenges")
			dat += "The Wizard Federation typically has hard limits on the potency and number of spells brought to the station based on risk.<BR>"
			dat += "Arming the station against you will increases the risk, but will grant you one more charge for your spellbook.<BR>"
		if("Rituals")
			dat += "These powerful spells change the very fabric of reality. Not always in your favour.<BR>"
	return dat

/obj/item/weapon/spellbook/proc/wrap(content)
	var/dat = ""
	dat +="<html><head><title>Spellbook</title></head>"
	dat += {"
	<head>
		<style type="text/css">
      		body { font-size: 80%; font-family: 'Lucida Grande', Verdana, Arial, Sans-Serif; }
      		ul#tabs { list-style-type: none; margin: 30px 0 0 0; padding: 0 0 0.3em 0; }
      		ul#tabs li { display: inline; }
      		ul#tabs li a { color: #42454a; background-color: #dedbde; border: 1px solid #c9c3ba; border-bottom: none; padding: 0.3em; text-decoration: none; }
      		ul#tabs li a:hover { background-color: #f1f0ee; }
      		ul#tabs li a.selected { color: #000; background-color: #f1f0ee; font-weight: bold; padding: 0.7em 0.3em 0.38em 0.3em; }
      		div.tabContent { border: 1px solid #c9c3ba; padding: 0.5em; background-color: #f1f0ee; }
      		div.tabContent.hide { display: none; }
    	</style>
  	</head>
	"}
	dat += {"[content]</body></html>"}
	return dat

/obj/item/weapon/spellbook/attack_self(mob/user)
	if(!owner)
		to_chat(user, "<span class='notice'>You bind the spellbook to yourself.</span>")
		owner = user
		return
	if(user != owner)
		to_chat(user, "<span class='warning'>The [name] does not recognize you as its owner and refuses to open!</span>")
		return
	user.set_machine(src)
	var/dat = ""

	dat += "<ul id=\"tabs\">"
	var/list/cat_dat = list()
	for(var/category in categories)
		cat_dat[category] = "<hr>"
		dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=\ref[src];page=[category]'>[category]</a></li>"

	dat += "<li><a><b>Points remaining : [uses]</b></a></li>"
	dat += "</ul>"

	var/datum/spellbook_entry/E
	for(var/i=1,i<=entries.len,i++)
		var/spell_info = ""
		E = entries[i]
		spell_info += E.GetInfo()
		if(E.CanBuy(user,src))
			spell_info+= "<a href='byond://?src=\ref[src];buy=[i]'>[E.buy_word]</A><br>"
		else
			spell_info+= "<span>Can't [E.buy_word]</span><br>"
		if(E.CanRefund(user,src))
			spell_info+= "<a href='byond://?src=\ref[src];refund=[i]'>Refund</A><br>"
		spell_info += "<hr>"
		if(cat_dat[E.category])
			cat_dat[E.category] += spell_info

	for(var/category in categories)
		dat += "<div class=\"[tab==category?"tabContent":"tabContent hide"]\" id=\"[category]\">"
		dat += GetCategoryHeader(category)
		dat += cat_dat[category]
		dat += "</div>"

	user << browse(wrap(dat), "window=spellbook;size=700x500")
	onclose(user, "spellbook")
	return

/obj/item/weapon/spellbook/Topic(href, href_list)
	..()
	if(!ishuman(usr))
		return 1
	var/mob/living/carbon/human/H = usr

	if(H.stat || H.restrained())
		return

	var/datum/spellbook_entry/E = null
	if(loc == H || (in_range(src, H) && isturf(loc)))
		H.set_machine(src)
		if(href_list["buy"])
			E = entries[text2num(href_list["buy"])]
			if(E && E.CanBuy(H,src))
				if(E.Buy(H,src))
					uses -= E.cost
		else if(href_list["refund"])
			E = entries[text2num(href_list["refund"])]
			if(E && E.refundable)
				var/result = E.Refund(H,src)
				if(result > 0)
					uses += result
		else if(href_list["page"])
			tab = sanitize(href_list["page"])
	attack_self(H)
	return
