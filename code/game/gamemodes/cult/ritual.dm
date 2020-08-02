//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32
#define CULT_RUNES_LIMIT 26

var/list/cultwords = list() // associated english word = runeword
var/list/cultwords_reverse = list() // associated runeword = english word
var/list/cult_datums = list()

/client/proc/check_words() // -- Urist
	set category = "Special Verbs"
	set name = "Check Rune Words"
	set desc = "Check the rune-word meaning."
	if(!cultwords["travel"])
		runerandom()
	for (var/word in cultwords)
		to_chat(usr, "[word] is [cultwords[word]]")

/proc/runerandom() //randomizes word meaning
	var/list/runewords = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri") ///"orkan" and "allaq" removed.
	var/list/engwords = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
	for(var/word in engwords)
		cultwords[word] = pick_n_take(runewords)
		cultwords_reverse[cultwords[word]] = word

	for(var/type in subtypesof(/datum/cult))
		var/datum/cult/dat = type
		var/word1 = initial(dat.word1)
		var/word2 = initial(dat.word2)
		var/word3 = initial(dat.word3)
		cult_datums[word1 + word2 + word3] = type

/obj/effect/rune
	name = "blood"
	desc = ""
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	unacidable = 1
	layer = TURF_LAYER
	var/datum/cult/power
	var/image/blood_overlay
// travel self [word] - Teleport to random [rune with word destination matching]
// travel other [word] - Portal to rune with word destination matching - kinda doesnt work. At least the icon. No idea why.
// see blood Hell - Create a new tome
// join blood self - Incorporate person over the rune into the group
// Hell join self - Summon TERROR
// destroy see technology - EMP rune
// travel blood self - Drain blood
// see Hell join - See invisible
// blood join Hell - Raise dead

// hide see blood - Hide nearby runes
// blood see hide - Reveal nearby runes  - The point of this rune is that its reversed obscure rune. So you always know the words to reveal the rune once oyu have obscured it.

// Hell travel self - Leave your body and ghost around
// blood see travel - Manifest a ghost into a mortal body
// Hell tech join - Imbue a rune into a talisman
// Hell blood join - Sacrifice rune
// destroy travel self - Wall rune
// join other self - Summon cultist rune
// travel technology other - Freeing rune    //    other blood travel was freedom join other

// hide other see - Deafening rune     //     was destroy see hear
// destroy see other - Blinding rune
// destroy see blood - BLOOD BOIL

// self other technology - Communication rune  //was other hear blood
// join hide technology - stun rune. Rune color: bright pink.
/obj/effect/rune/atom_init()
	. = ..()
	cult_runes += src
	blood_overlay = image('icons/effects/blood.dmi', src, "mfloor[rand(1, 7)]", 2)
	blood_overlay.override = 1
	blood_overlay.color = "#a10808"
	for(var/mob/living/silicon/S in player_list) // we hold mobs in this lists only with clients
		S.client.images += blood_overlay

/obj/effect/rune/update_icon()
	color = "#a10808"

/obj/effect/rune/Destroy()
	QDEL_NULL(power)
	QDEL_NULL(blood_overlay)
	cult_runes -= src
	return ..()

/obj/effect/rune/examine(mob/user)
	if(iscultist(user) || isobserver(user))
		to_chat(user, "[bicon(src)] That's <span class='cult'>cult rune!</span>")
		to_chat(user, "A spell circle drawn in blood. It reads: <i>[desc]</i>.")
		return
	to_chat(user, "[bicon(src)] That's some <span class='danger'>[name]</span>")
	if(issilicon(user))
		to_chat(user, "It's thick and gooey. Perhaps it's the chef's cooking?") // blood desc
	else
		to_chat(user, "A strange collection of symbols drawn in blood.")

/obj/effect/rune/attackby(I, mob/living/user)
	if(istype(I, /obj/item/weapon/book/tome) && iscultist(user))
		to_chat(user, "<span class='cult'>You retrace your steps, carefully undoing the lines of the rune.</span>")
		qdel(src)
	else if(istype(I, /obj/item/weapon/nullrod) && user.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
		to_chat(user, "<span class='notice'>You disrupt the vile magic with the deadening field of the null rod!</span>")
		qdel(src)
	else
		return ..()

/obj/effect/rune/attack_ghost(mob/dead/observer/user)
	if(!istype(power, /datum/cult/teleport) && !istype(power, /datum/cult/item_port))
		return ..()
	var/list/allrunes = list()
	for(var/obj/effect/rune/R in cult_runes)
		if(!istype(R.power, power.type) || R == src)
			continue
		if(R.power.word3 == power.word3 && !is_centcom_level(R.loc.z))
			allrunes += R
	if(length(allrunes) > 0)
		user.forceMove(get_turf(pick(allrunes)))

/obj/effect/rune/attack_hand(mob/living/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(!iscultist(user))
		to_chat(user, "You can't mouth the arcane scratchings without fumbling over them.")
		return
	if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		to_chat(user, "You are unable to speak the words of the rune.")
		return
	if(!power || prob(user.getBrainLoss()))
		user.say(pick("Hakkrutju gopoenjim.", "Nherasai pivroiashan.", "Firjji prhiv mazenhor.",\
		"Tanah eh wakantahe.", "Obliyae na oraie.", "Miyf hon vnor'c.", "Wakabai hij fen juswix."))
		return
	power.action(user)

/obj/item/weapon/book/tome
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	unique = 1
	var/unlocked = FALSE
	var/notedat = ""
	var/tomedat = ""
	var/list/words = list("ire" = "ire", "ego" = "ego", "nahlizet" = "nahlizet", "certum" = "certum", "veri" = "veri", "jatkaa" = "jatkaa", "balaq" = "balaq", "mgar" = "mgar", "karazet" = "karazet", "geeri" = "geeri")

	tomedat = {"<html>
				<head>
				<style>
				h1 {font-size: 25px; margin: 15px 0px 5px;}
				h2 {font-size: 20px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h1>The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood.</h1>

				<i>The book is written in an unknown dialect, there are lots of pictures of various complex geometric shapes. You find some notes in english that give you basic understanding of the many runes written in the book. The notes give you an understanding what the words for the runes should be. However, you do not know how to write all these words in this dialect.</i><br>
				<i>Below is the summary of the runes.</i> <br>

				<h2>Contents</h2>
				<p>
				<b>Teleport self: </b>Travel Self (word)<br>
				<b>Teleport other: </b>Travel Other (word)<br>
				<b>Summon new tome: </b>See Blood Hell<br>
				<b>Convert a person: </b>Join Blood Self<br>
				<b>Summon Nar-Sie: </b>Hell Join Self<br>
				<b>Disable technology: </b>Destroy See Technology<br>
				<b>Drain blood: </b>Travel Blood Self<br>
				<b>Raise dead: </b>Blood Join Hell<br>
				<b>Hide runes: </b>Hide See Blood<br>
				<b>Reveal hidden runes: </b>Blood See Hide<br>
				<b>Leave your body: </b>Hell travel self<br>
				<b>Ghost Manifest: </b>Blood See Travel<br>
				<b>Imbue a talisman: </b>Hell Technology Join<br>
				<b>Sacrifice: </b>Hell Blood Join<br>
				<b>Create a wall: </b>Destroy Travel Self<br>
				<b>Summon cultist: </b>Join Other Self<br>
				<b>Free a cultist: </b>Travel technology other<br>
				<b>Deafen: </b>Hide Other See<br>
				<b>Blind: </b>Destroy See Other<br>
				<b>Blood Boil: </b>Destroy See Blood<br>
				<b>Communicate: </b>Self Other Technology<br>
				<b>Stun: </b>Join Hide Technology<br>
				<b>Summon Cultist Armor: </b>Hell Destroy Other<br>
				<b>See Invisible: </b>See Hell Join<br>
				<b>Construct: </b>Technology Blood Travel<br>
				</p>
				<h2>Rune Descriptions</h2>
				<h3>Teleport self</h3>
				Teleport rune is a special rune, as it only needs two words, with the third word being destination. Basically, when you have two runes with the same destination, invoking one will teleport you to the other one. If there are more than 2 runes, you will be teleported to a random one. Runes with different third words will create separate networks. You can imbue this rune into a talisman, giving you a great escape mechanism.<br>
				<h3>Teleport other</h3>
				Teleport other allows for teleportation for any movable object to another rune with the same third word. You need 3 cultists chanting the invocation for this rune to work.<br>
				<h3>Summon new tome</h3>
				Invoking this rune summons a new arcane tome.
				<h3>Convert a person</h3>
				This rune opens target's mind to the realm of Nar-Sie, which usually results in this person joining the cult. However, some people (mostly the ones who posess high authority) have strong enough will to stay true to their old ideals. <br>
				<h3>Summon Nar-Sie</h3>
				The ultimate rune. It summons the Avatar of Nar-Sie himself, tearing a huge hole in reality and consuming everything around it. Summoning it is the final goal of any cult.<br>
				<h3>Disable Technology</h3>
				Invoking this rune creates a strong electromagnetic pulse in a small radius, making it basically analogic to an EMP grenade. You can imbue this rune into a talisman, making it a decent defensive item.<br>
				<h3>Drain Blood</h3>
				This rune instantly heals you of some brute damage at the expense of a person placed on top of the rune. Whenever you invoke a drain rune, ALL drain runes on the station are activated, draining blood from anyone located on top of those runes. This includes yourself, though the blood you drain from yourself just comes back to you. This might help you identify this rune when studying words. One drain gives up to 25HP per each victim, but you can repeat it if you need more. Draining only works on living people, so you might need to recharge your "Battery" once its empty. Drinking too much blood at once might cause blood hunger.<br>
				<h3>Raise Dead</h3>
				This rune allows for the resurrection of any dead person. You will need a dead human body and a living human sacrifice. Make 2 raise dead runes. Put a living, awake human on top of one, and a dead body on the other one. When you invoke the rune, the life force of the living human will be transferred into the dead body, allowing a ghost standing on top of the dead body to enter it, instantly and fully healing it. Use other runes to ensure there is a ghost ready to be resurrected.<br>
				<h3>Hide runes</h3>
				This rune makes all nearby runes completely invisible. They are still there and will work if activated somehow, but you cannot invoke them directly if you do not see them.<br>
				<h3>Reveal runes</h3>
				This rune is made to reverse the process of hiding a rune. It reveals all hidden runes in a rather large area around it.
				<h3>Leave your body</h3>
				This rune gently rips your soul out of your body, leaving it intact. You can observe the surroundings as a ghost as well as communicate with other ghosts. Your body takes damage while you are there, so ensure your journey is not too long, or you might never come back.<br>
				<h3>Manifest a ghost</h3>
				Unlike the Raise Dead rune, this rune does not require any special preparations or vessels. Instead of using full lifeforce of a sacrifice, it will drain YOUR lifeforce. Stand on the rune and invoke it. If theres a ghost standing over the rune, it will materialise, and will live as long as you dont move off the rune or die. You can put a paper with a name on the rune to make the new body look like that person.<br>
				<h3>Imbue a talisman</h3>
				This rune allows you to imbue the magic of some runes into paper talismans. Create an imbue rune, then an appropriate rune beside it. Put an empty piece of paper on the imbue rune and invoke it. You will now have a one-use talisman with the power of the target rune. Using a talisman drains some health, so be careful with it. You can imbue a talisman with power of the following runes: summon tome, reveal, conceal, teleport, tisable technology, communicate, deafen, blind and stun.<br>
				<h3>Sacrifice</h3>
				Sacrifice rune allows you to sacrifice a living thing or a body to the Geometer of Blood. Monkeys and dead humans are the most basic sacrifices, they might or might not be enough to gain His favor. A living human is what a real sacrifice should be, however, you will need 3 people chanting the invocation to sacrifice a living person.
				<h3>Create a wall</h3>
				Invoking this rune solidifies the air above it, creating an an invisible wall. To remove the wall, simply invoke the rune again.
				<h3>Summon cultist</h3>
				This rune allows you to summon a fellow cultist to your location. The target cultist must be unhandcuffed ant not buckled to anything. You also need to have 3 people chanting at the rune to succesfully invoke it. Invoking it takes heavy strain on the bodies of all chanting cultists.<br>
				<h3>Free a cultist</h3>
				This rune unhandcuffs and unbuckles any cultist of your choice, no matter where he is. You need to have 3 people invoking the rune for it to work. Invoking it takes heavy strain on the bodies of all chanting cultists.<br>
				<h3>Deafen</h3>
				This rune temporarily deafens all non-cultists around you.<br>
				<h3>Blind</h3>
				This rune temporarily blinds all non-cultists around you. Very robust. Use together with the deafen rune to leave your enemies completely helpless.<br>
				<h3>Blood boil</h3>
				This rune boils the blood all non-cultists in visible range. The damage is enough to instantly critically hurt any person. You need 3 cultists invoking the rune for it to work. This rune is unreliable and may cause unpredicted effect when invoked. It also drains significant amount of your health when succesfully invoked.<br>
				<h3>Communicate</h3>
				Invoking this rune allows you to relay a message to all cultists on the station and nearby space objects.
				<h3>Stun</h3>
				Unlike other runes, this ons is supposed to be used in talisman form. When invoked directly, it simply releases some dark energy, briefly stunning everyone around. When imbued into a talisman, you can force all of its energy into one person, stunning him so hard he cant even speak. However, effect wears off rather fast.<br>
				<h3>Equip Armor</h3>
				When this rune is invoked, either from a rune or a talisman, it will equip the user with the armor of the followers of Nar-Sie. To use this rune to its fullest extent, make sure you are not wearing any form of headgear, armor, gloves or shoes, and make sure you are not holding anything in your hands.<br>
				<h3>See Invisible</h3>
				When invoked when standing on it, this rune allows the user to see the the world beyond as long as he does not move.<br>
				</body>
				</html>
				"}

/obj/item/weapon/book/tome/atom_init()
	. = ..()
	if (icon_state == "book")
		icon_state = "book[pick(1,2,3,4,5,6)]"

/obj/item/weapon/book/tome/Topic(href, href_list[])
	if(loc != usr)
		usr << browse(null, "window=notes")
		return
	var/number = text2num(href_list["number"])
	if (usr.stat|| usr.restrained())
		return
	switch(href_list["action"])
		if("clear")
			words[words[number]] = words[number]
		if("change")
			words[words[number]] = input("Enter the translation for [words[number]]", "Word notes") in cultwords
			for (var/w in words)
				if ((words[w] == words[words[number]]) && (w != words[number]))
					words[w] = w
	notedat = {"
	<br><b>Word translation notes</b> <br>
	[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
	[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
	[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
	[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
	[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
	[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
	[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
	[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
	[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
	[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
	"}

	var/datum/browser/popup = new(usr, "window=notes", "Tome", 400, 600, ntheme=CSS_THEME_LIGHT)
	popup.set_content(notedat)
	popup.open()

/obj/item/weapon/book/tome/attack(mob/living/M, mob/living/user)
	M.log_combat(user, "beaten with [name]")

	if(istype(M, /mob/dead))
		M.invisibility = 0
		user.visible_message( \
			"<span class='userdanger'> [user] drags the ghost to our plan of reality!</span>", \
			"<span class='userdanger'>You drag the ghost to our plan of reality!</span>")
		return
	if(!istype(M))
		return
	if(!iscultist(user))
		return ..()
	if(iscultist(M))
		return
	M.adjustBruteLoss(rand(5, 20)) //really lucky - 5 hits for a crit
	M.visible_message("<span class='danger'>[user] beats [M] with the arcane tome!</span>")
	to_chat(M, "<span class='danger'You feel searing heat inside!</span>")

/obj/item/weapon/book/tome/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(iscultist(user) && target.reagents && target.reagents.has_reagent("water"))
		var/water2convert = target.reagents.get_reagent_amount("water")
		target.reagents.del_reagent("water")
		to_chat(user, "<span class='warning'>You curse [target].</span>")
		target.reagents.add_reagent("unholywater",water2convert)

/obj/item/weapon/book/tome/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || user.incapacitated())
		return

	if(!cultwords["travel"])
		runerandom()
	if(!iscultist(user))
		to_chat(user, "This book is completely blank!")
		return
	if (!isturf(user.loc))
		to_chat(user, "<span class='userdanger'>You do not have enough space to write a proper rune.</span>")
		return
	for(var/obj/structure/obj_to_check in user.loc)
		if(obj_to_check.density)
			to_chat(user, "<span class='warning'>There is not enough space to write a proper rune.</span>")
			return
	if (length(cult_runes) >= CULT_RUNES_LIMIT + length(SSticker.mode.cult)) //including the useless rune at the secret room, shouldn't count against the limit of 25 runes - Urist
		alert("The cloth of reality can't take that much of a strain. Remove some runes first!")
		return
	switch(alert("You open the tome",,"Read it","Scribe a rune", "Notes")) //Fuck the "Cancel" option. Rewrite the whole tome interface yourself if you want it to work better. And input() is just ugly. - K0000
		if("Cancel")
			return
		if("Read it")
			if(usr.get_active_hand() != src)
				return
			var/datum/browser/popup = new(user, "window=Arcane Tome", "Tome", 400, 600, ntheme=CSS_THEME_LIGHT)
			popup.set_content(tomedat)
			popup.open()
			return
		if("Notes")
			if(usr.get_active_hand() != src)
				return
			notedat = {"
			<br><b>Word translation notes</b> <br>
			[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
			[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
			[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
			[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
			[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
			[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
			[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
			[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
			[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
			[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
			"}

			var/datum/browser/popup = new(user, "window=notes", "Tome", 400, 600, ntheme=CSS_THEME_LIGHT)
			popup.set_content(notedat)
			popup.open()
			return
	if(usr.get_active_hand() != src)
		return

	if(user.species.flags[NO_BLOOD])
		to_chat(user, "<span class='warning'>You don't have any blood, how do you suppose to write a blood rune?</span>")
		return

	var/w1
	var/w2
	var/w3
	var/list/english = list()
	for(var/w in words)
		english[words[w]] = w
	if(user)
		w1 = input("Write your first rune:", "Rune Scribing") as null|anything in english
		if(!w1)
			return
		if(w1 in cultwords)
			w1 = english[w1]
	if(user)
		w2 = input("Write your second rune:", "Rune Scribing") as null|anything in english
		if(!w2)
			return
		if(w2 in cultwords)
			w2 = english[w2]
	if(user)
		w3 = input("Write your third rune:", "Rune Scribing") as null|anything in english
		if(!w3)
			return
		if(w3 in cultwords)
			w3 = english[w3]


	if(user.get_active_hand() != src || user.is_busy())
		return
	user.visible_message("<span class='danger'> [user] slices open a finger and begins to chant and paint symbols on the floor.</span>",\
	"<span class='danger'> You hear chanting.</span>")
	to_chat(user, "<span class='danger'> You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the\
	ritual that binds your life essence with the dark arcane energies flowing through the surrounding world.</span>")
	user.take_overall_damage((rand(9) + 1) / 10) // 0.1 to 1.0 damage
	if((unlocked || do_after(user, 50, target = user)) && user.get_active_hand() == src)
		var/obj/effect/rune/R = new /obj/effect/rune(user.loc)
		if(w1 == cultwords["travel"])
			if(w2 == cultwords["self"])
				R.power = new /datum/cult/teleport(R, cultwords_reverse[w3])
			else if(w2 == cultwords["other"])
				R.power = new /datum/cult/item_port(R, cultwords_reverse[w3])
		to_chat(user, "<span class='userdanger'>You finish drawing the arcane markings of the Geometer.</span>")
		if(!R.power)
			var/type = cult_datums[cultwords_reverse[w1] + cultwords_reverse[w2] + cultwords_reverse[w3]]
			if(ispath(type))
				R.power = new type(R)
		R.desc = "[w1], [w2], [w3]" // for examine
		R.icon = get_uristrune_cult((R.power ? TRUE : FALSE), w1, w2, w3)
		R.blood_DNA = list()
		R.blood_DNA[user.dna.unique_enzymes] = user.dna.b_type


/obj/item/weapon/book/tome/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/book/tome))
		var/obj/item/weapon/book/tome/T = I
		switch(alert("Copy the runes from your tome?",,"Copy", "Cancel"))
			if("Cancel")
				return
		for(var/w in words)
			words[w] = T.words[w]
		to_chat(user, "<span class='notice'>You copy the translation notes from [T].</span>")
		return
	return ..()

/obj/item/weapon/book/tome/examine(mob/user)
	..()
	if(iscultist(user))
		to_chat(user, "The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Contains the details of every ritual his followers could think of.\
		Most of these are useless, though.")

/obj/item/weapon/book/tome/imbued/atom_init()
	. = ..()
	unlocked = TRUE
	if(!cultwords["travel"])
		runerandom()
	for(var/word in cultwords)
		words[cultwords[word]] = word

/obj/item/weapon/book/tome/old
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister looking cover."
	icon = 'icons/obj/weapons.dmi'
	icon_state ="tome"
