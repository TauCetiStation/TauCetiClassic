var/global/list/card_datums_by_name = list()
var/global/list/card_drop_datums_by_name = list()

#define RARITY_COMMON 100
#define RARITY_UNCOMMON 75
#define RARITY_RARE 50
#define RARITY_ULTRA_RARE 25
#define RARITY_LEGENDARY 10

/datum/playing_cards // For the future possibilities.
	var/name_card = ""
	var/desc_card = ""
	var/examine_card
	var/can_be_gathered = TRUE
	var/number
	var/rarity = RARITY_COMMON
	var/max_in_deck = 3

/datum/playing_cards/sofa_ninja
	name_card = "Sofa Ninja"
	desc_card = "\"Self-proclaimed Quasi-Hero and coupled with that an absolute champion in low productivity in NanoTrasen corporation!\"<BR>While Sofa Ninja is on the field, all personnel on your turn gains a +1 Freedome and Authority bonus. Once a turn, he can get a Service Staff card from your field back into your hand, and exchange it with a Quasi-Hero card from your deck. Gains +1 to his authority for each Quasi-Hero on the field. (Bonus is limited only by field's fields)"
	examine_card = "sofa_ninja_1.png"
	number = 1
	rarity = RARITY_LEGENDARY
	max_in_deck = 1

/datum/playing_cards/shrub
	name_card = "Shrub"
	desc_card = "\"We're. Resting.\" Kindly-cynical exemplar of Dionaea and also a psychiatrist, who will fundamentally, patiently, and very leisurely look into all your menta problems, under a soft, nutritious lamp light.<BR>Once a turn can do an action to any opponent's card(except Beast types), taking away their action in opponent's turn. It's all because a session with Diona requires significant energy reserves!"
	examine_card = "shrub_2.png"
	number = 2
	rarity = RARITY_RARE
	max_in_deck = 1

/datum/playing_cards/space_carp
	name_card = "Space Carp"
	desc_card = "\"Gaaah! Space Carps are breaking through the windows!\"<BR>Space Carps, brutal inhabitants of space, which eat all the trash that is regularly thrown into the cosmos by different corporations, and concerns. But special treat for them is canned human flesh, which is packed on space stations. Gets a bonus of +2 Authority, when attacks Service Staff"
	examine_card = "space_carp_3.png"
	number = 3

/datum/playing_cards/assistant
	name_card = "Assistant"
	desc_card = "\"Spare assistant!... Damn, why am I useless, again? I'll go take a walk through the maintenance tunnels.\"<BR>Each assistant offers his help to his collegues. But usually nobody needs it. So they are goofing around everywhere, and do whatever they want."
	examine_card = "assistant_4.png"
	number = 4

/datum/playing_cards/assistant_in_space_suit
	name_card = "Assistant in a Space Suit"
	desc_card = "\"Hull breach in the main corridor! I'm in the air!\"<BR>Space suits, which are created for an average worked are very bulky and heavy, but when oxygen starts dissapearing, pressure drops, and gravity force is no more - in this space suit, each Assistant feels much better. It's sad, that it doesn't give them any more intelligence, and they begin to dashingly goof around. Even in space"
	examine_card = "assistant_in_space_suit_5.png"
	number = 5

/datum/playing_cards/cakehead
	name_card = "Cakehead"
	desc_card = "\"Hey... Why did you put a cake onto your head?\"<BR>When Cakehead appears onto the field, one of your opponents must pick one card from his deck, and after give it to you. Because of cake's scent, Cakehead has immunity from any Service Staff cards, he gives them a piece of cake, instead of suffering!"
	examine_card = "cakehead_6.png"
	number = 6
	rarity = RARITY_UNCOMMON
	max_in_deck = 1

/datum/playing_cards/space_law
	name_card = "Space Law"
	desc_card = "\"Your charged on behalf of violation of articles 104, 110 and 202, that's 20 minutes total, and 5 more, because you make me sick!\"<BR>Play this card when an opponent plays an effect card with type Service Staff, or cards with Service staff type are using their abilities onto you. When this card is played, this card nullifies the effects of cards it was used again. After that, it gets discarded"
	examine_card = "space_law_7.png"
	number = 7

/datum/playing_cards/clown
	name_card = "Clown"
	desc_card = "\"HONK! Personnel is always in a good mood, when there's a lot of banana peels, which is lubed up by space lube all around the station! Wanna hear a joke? HONK!\"<BR>Once a turn Clown can HONK and induce token on any opponent's card, and while Clown is on the field, Authority and Freedom of HONKed cards are lowwerd by 1(Effect is additive), but not lower than 1. If Clown did not HONK till the moment of using an Effect card, he can cancel out it's effect, HONKing immediatley!"
	examine_card = "clown_8.png"
	number = 8
	rarity = RARITY_UNCOMMON

/datum/playing_cards/light_sources
	name_card = "Light Sources"
	desc_card = "\"Engineers! For Poly's sake, get the power going, and fix up those lights!\"<BR>Play this card during your turn, or after your opponent has drawn a card from the deck. One of the players must show you his hand, and you can pick one of his cards. He must return the card back into the deck, and shuffle it. When this card is used during opponent's turn, he can't use Effect cards until the turn's end."
	examine_card = "light_sources_9.png"
	number = 9

/datum/playing_cards/experienced_assistant
	name_card = "Experienced Assistant"
	desc_card = "\"To get full access we need a welding tool, a welding mask, a scredriwer, a crowbar,  a wrench, a multitool, and... Luck! Let's get going!\"<BR>When Assistants try to stimulate workflow, they become very experienced, in things, seemingly, unnecessary on a Space Station, but they think otherwise."
	examine_card = "experienced_assistant_10.png"
	number = 10

/datum/playing_cards/the_false_wizard
	name_card = "The False Wizard"
	desc_card = "\"After I cast a spell \"GHETTO WAY\" you'll leave the world forever!\"<BR>The False Wizard has got a magister degree in magic, which is based on force of pure imagination. Once a turn he can Belie one of the opponent's cards, decreasing it's Freedom by 1. Once a turn he can Inspire on of the cards on your field, giving it a +1 Authority bonus until the turn's end. His abilities do not work, if there's a real Wizard on the field!"
	examine_card = "the_false_wizard_11.png"
	number = 11
	rarity = RARITY_RARE
	max_in_deck = 1

/datum/playing_cards/vending_machines
	name_card = "Vending Machines"
	desc_card = "\"Damn, everything's sold out... Again...\"<BR>Play this card during your turn. If card is played, you take two cards out of your deck, but discard one card from your hand. Commerce requires sacrifice."
	examine_card = "vending_machines_12.png"
	number = 12

/datum/playing_cards/arcade
	name_card = "Arcade"
	desc_card = "\"Congratulations! You have defeated Green Goo! - Try again?\"<BR>Play this card during opponent's turn. Arcade's gameplay is so addictive, that the chosen card on opponent's field(Except Beast type cards) can't attack or use it's abilities until opponent's current turn ends."
	examine_card = "arcade_13.png"
	number = 13
	rarity = RARITY_UNCOMMON

/datum/playing_cards/unwanted_clone
	name_card = "Unwanted Clone"
	desc_card = "\"HOW CHANGE HAND!!!!???\"<BR>An Unwanted Clon, which somehow escaped from genetic's lab. He's a real find for Clown or Quasi-Heroes, who save him from further experiments. When you card on the field must for any reason be discarded, you can instead discord the Unwanted Clone card, or you can play him out from your hand instead of discarding the card. In this case Unwanted Clone is played, and kept on field."
	examine_card = "unwanted_clone_14.png"
	number = 14
	rarity = RARITY_UNCOMMON

/datum/playing_cards/mattress_ninja
	name_card = "Mattress Ninja"
	desc_card = "\"Mattress Ninja - main follower of Sofa Ninja, who got the wisdom of lazyness and procrastination. One day he will catch up to the mastery of his master, who treats him as a true comrade and brother.\"<BR>Once per Play, when Mattress Ninja is played, chosen opponent must drop all Effect cards. While this card is on the playing field, beaten cards of Quasi-Heroes are put into the Deck, which gets shuffled."
	examine_card = "mattress_ninja_22.png"
	number = 22
	rarity = RARITY_RARE
	max_in_deck = 1

/datum/playing_cards/winged_soldier
	name_card = "Winged Soldier"
	desc_card = "\"Once a nerd and otaku, who was inspired by Sofa Ninja, now always visits him, does fitness and Quasi-Heroness, but never can reject his habits.\"<BR>While Winged Soldier is on the playing field, all cards with Machinery type of the opponent, can only pick this card as their target. When there is a Sofa Ninja on the field, Winged Soldier receives a Freedome bonus of 1."
	examine_card = "winged_soldier_23.png"
	number = 23
	max_in_deck = 1

/datum/playing_cards/bronze_helmet
	name_card = "Bronze Helmet"
	desc_card = "\"Bronze Helmet before was simply a drunkard, who was gulping his misery down with alcohol, before the moment, when he fought Bumblebee, and suddenly became a Quasi-Hero, and now he stimulates happyness by his Quasi-Heroic deeds.\"<BR> Gets a Freedom bonus of 1, when attack by any Security Service type card. Has immunity to attacks and abilities of Bartender and Pun-Pun cards."
	examine_card = "bronze_helmet_24.png"
	number = 24
	max_in_deck = 1

/datum/playing_cards/bumblebee
	name_card = "Bumblebee"
	desc_card = "\"Bumblebee, is one of the first allies of Sofa Ninja, along with Sandalled Griffin. Unfortunately, alone he is nothing more, then past beefcake, who was gathering mass, rejecting doping, and almost became Fat.\""
	examine_card = "bumblebee_25.png"
	number = 25
	rarity = RARITY_UNCOMMON
	max_in_deck = 1

/*
 * An Abstract Deck of Cards
 */

/obj/item/toy/play_cards
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/cards.dmi'
	icon_state = "deck"
	w_class = ITEM_SIZE_SMALL
	var/list/cards = list()
	var/single_card = /obj/item/toy/play_singlecard
	var/hand_card = /obj/item/toy/play_cardhand
	var/normal_deck_size = 0 // How many cards should be in the full deck.
	var/list/integrity = list() // Is populated in atom_init(), determines which cards SHOULD be in the full deck.

/obj/item/toy/play_cards/update_icon()
	if(cards.len > normal_deck_size/2)
		icon_state = "[initial(icon_state)]_full"
	else if(cards.len > normal_deck_size/4)
		icon_state = "[initial(icon_state)]_half"
	else if(cards.len >= 1)
		icon_state = "[initial(icon_state)]_low"
	else if(cards.len == 0)
		icon_state = "[initial(icon_state)]_empty"

/obj/item/toy/play_cards/proc/fill_deck()
	update_icon()

/obj/item/toy/play_cards/attack_hand(mob/user)
	var/choice = null
	if(cards.len == 0)
		to_chat(user, "<span class='notice'>There are no more cards to draw.</span>")
		return
	var/obj/item/toy/play_singlecard/SC = new single_card(user.loc)
	choice = cards[1]
	SC.cardname = choice
	SC.parentdeck = src
	SC.generate_info()
	cards -= choice
	SC.pickup(user)
	user.put_in_active_hand(SC)
	user.visible_message("<span class='notice'>[user] draws a card from the deck.</span>", "<span class='notice'>You draw a card from the deck.</span>")
	update_icon()

/obj/item/toy/play_cards/attack_self(mob/user)
	cards = shuffle(cards)
	user.SetNextMove(CLICK_CD_INTERACT)
	playsound(user, 'sound/items/cardshuffle.ogg', 50, 1)
	user.visible_message("<span class='notice'>[user] shuffles the deck.</span>", "<span class='notice'>You shuffle the deck.</span>")

/obj/item/toy/play_cards/attackby(obj/O, mob/living/user)
	..()
	if(istype(O, /obj/item/toy/play_singlecard))
		var/obj/item/toy/play_singlecard/SC = O
		var/card_count = 0
		if(SC.card_info)
			for(var/i in cards)
				if(i == SC.cardname)
					card_count++
			if(SC.card_info.max_in_deck <= card_count)
				to_chat(user, "<span class='notice'>You can't mix these cards.</span>")
				return
		if(SC.parentdeck == src)
			cards += SC.cardname
			user.remove_from_mob(SC)
			user.visible_message("<span class='notice'>[user] adds a card to the bottom of the deck.</span>","<span class='notice'>You add the card to the bottom of the deck.</span>")
			qdel(SC)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
		update_icon()
	else if(istype(O, /obj/item/toy/play_cardhand))
		var/obj/item/toy/play_cardhand/C = O
		if(C.parentdeck == src)
			cards += C.currenthand
			user.remove_from_mob(C)
			user.visible_message("<span class='notice'>[user] puts their hand of cards in the deck.</span>", "<span class='notice'>You put the hand of cards in the deck.</span>")
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
		update_icon()

/obj/item/toy/play_cards/MouseDrop(atom/over_object)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(H.incapacitated())
		return
	if(Adjacent(usr))
		if(over_object == H)
			H.put_in_hands(src)
			to_chat(usr, "<span class='notice'>You pick up the deck.</span>")
		else if(istype(over_object, /obj/screen))
			switch(over_object.name)
				if("r_hand")
					H.u_equip(src)
					H.put_in_r_hand(src)
					to_chat(usr, "<span class='notice'>You pick up the deck.</span>")
				if("l_hand")
					H.u_equip(src)
					H.put_in_l_hand(src)
					to_chat(usr, "<span class='notice'>You pick up the deck.</span>")
	else
		to_chat(usr, "<span class='notice'>You can't reach it from here.</span>")

/obj/item/toy/play_cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/cards.dmi'
	icon_state = "hand2"
	w_class = ITEM_SIZE_TINY
	var/list/currenthand = list()
	var/single_card = /obj/item/toy/play_singlecard
	var/hand_card = /obj/item/toy/play_cardhand
	var/obj/item/toy/play_cards/parentdeck = null
	var/choice = null

/obj/item/toy/play_cardhand/atom_init()
	. = ..()
	update_icon()

/obj/item/toy/play_cardhand/Destroy()
	parentdeck = null
	return ..()

/obj/item/toy/play_cardhand/update_icon()
	if(currenthand.len < 4)
		icon_state = "hand[currenthand.len]"
	else
		icon_state = "hand5"

/obj/item/toy/play_cardhand/attack_self(mob/user)
	user.set_machine(src)
	interact(user)

/obj/item/toy/play_cardhand/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in currenthand)
		dat += "<A href='?src=\ref[src];pick=[t]'>A [t].</A>"
		if(t in card_datums_by_name)
			dat += "<A href='?src=\ref[src];examine=[t]'>Examine</A><BR>"
		else
			dat += "<BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.set_content(dat)
	popup.open()
	update_icon()

/obj/item/toy/play_cardhand/Topic(href, href_list)
	if(..())
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/cardUser = usr
	if(cardUser.incapacitated())
		return
	if(href_list["pick"])
		if (cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			var/choice = href_list["pick"]
			var/obj/item/toy/play_singlecard/C = new single_card(cardUser.loc)
			C.parentdeck = parentdeck
			C.cardname = choice
			C.generate_info()
			currenthand -= choice
			C.pickup(cardUser)
			cardUser.put_in_any_hand_if_possible(C)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from \his hand.</span>", "<span class='notice'>You take the [C.cardname] from your hand.</span>")

			interact(cardUser)

			if(currenthand.len == 1)
				var/obj/item/toy/play_singlecard/SC = new single_card(loc)
				SC.parentdeck = parentdeck
				SC.cardname = currenthand[1]
				SC.generate_info()
				cardUser.remove_from_mob(src)
				SC.pickup(cardUser)
				cardUser.put_in_any_hand_if_possible(SC)
				to_chat(cardUser, "<span class='notice'>You also take [currenthand[1]] and hold it.</span>")
				cardUser << browse(null, "window=cardhand")
				qdel(src)
		update_icon()

/obj/item/toy/play_cardhand/attackby(obj/O, mob/living/user)
	..()
	if(istype(O, /obj/item/toy/play_singlecard))
		var/obj/item/toy/play_singlecard/SC = O
		if(SC.card_info)
			var/card_count = 0
			for(var/i in currenthand)
				if(i == SC.cardname)
					card_count++
			if(SC.card_info.max_in_deck <= card_count)
				to_chat(user, "<span class='notice'>You can't mix these cards.</span>")
				return
		if(SC.parentdeck == parentdeck)
			currenthand += SC.cardname
			user.remove_from_mob(SC)
			user.visible_message("<span class='notice'>[user] adds a card to their hand.</span>", "<span class='notice'>You add the [SC.cardname] to your hand.</span>")
			interact(user)
			update_icon()
			qdel(SC)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
	else if(istype(O, /obj/item/toy/play_cardhand))
		var/obj/item/toy/play_cardhand/C = O
		if(C.parentdeck == parentdeck)
			currenthand += C.currenthand
			user.remove_from_mob(C)
			user.visible_message("<span class='notice'>[user] puts their hand of cards in the deck.</span>", "<span class='notice'>You put the hand of cards in the deck.</span>")
			interact(user)
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")

/obj/item/toy/play_singlecard
	name = "card"
	desc = "A card."
	icon = 'icons/obj/cards.dmi'
	icon_state = "singlecard_down"
	w_class = ITEM_SIZE_TINY
	var/cardname = null
	var/datum/playing_cards/card_info
	var/single_card = /obj/item/toy/play_singlecard
	var/hand_card = /obj/item/toy/play_cardhand
	var/obj/item/toy/play_cards/parentdeck = null
	var/flipped = FALSE
	var/scribble = null // Text written on the card's back.
	pixel_x = -5

/obj/item/toy/play_singlecard/Destroy()
	parentdeck = null
	return ..()

/obj/item/toy/play_singlecard/examine(mob/user)
	..()
	if(scribble)
		to_chat(user, "On it's back is written: [scribble]")

/obj/item/toy/play_singlecard/proc/generate_info()
	if(cardname in card_datums_by_name)
		card_info = card_datums_by_name[cardname]

/obj/item/toy/play_singlecard/verb/Flipping()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(H.incapacitated())
		return
	Flip()

/obj/item/toy/play_singlecard/proc/Flip()
	if(!flipped)
		flipped = TRUE
		if(cardname)
			icon_state = "sc_[cardname]"
			name = cardname
		else
			icon_state = "sc_Ace of Spades"
			name = "What Card"
		pixel_x = 5
	else if(flipped)
		flipped = FALSE
		icon_state = initial(icon_state)
		name = initial(name)
		pixel_x = -5

/obj/item/toy/play_singlecard/attackby(obj/O, mob/living/user)
	..()
	if(istype(O, /obj/item/toy/play_singlecard))
		var/obj/item/toy/play_singlecard/SC = O
		var/card_count = 0
		if(card_info && SC.card_info && cardname == SC.cardname)
			card_count++
			if(card_info.max_in_deck <= card_count)
				to_chat(user, "<span class='notice'>You can't mix these cards.</span>")
				return
		if(SC.parentdeck == parentdeck)
			var/obj/item/toy/play_cardhand/H = new hand_card(user.loc)
			H.currenthand += SC.cardname
			H.currenthand += cardname
			H.parentdeck = parentdeck
			H.update_icon()
			user.remove_from_mob(SC)
			H.pickup(user)
			user.put_in_active_hand(H)
			to_chat(user, "<span class='notice'>You combine the [SC.cardname] and the [cardname] into a hand.</span>")
			qdel(SC)
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")

	else if(istype(O, /obj/item/toy/play_cardhand))
		var/obj/item/toy/play_cardhand/C = O
		var/card_count = 0
		if(card_info)
			for(var/i in C.currenthand)
				if(i == cardname)
					card_count++
			if(card_info.max_in_deck <= card_count)
				to_chat(user, "<span class='notice'>You can't mix these cards.</span>")
				return
		if(C.parentdeck == parentdeck)
			C.currenthand += cardname
			user.remove_from_mob(src)
			user.visible_message("<span class='notice'>[user] adds a card to \his hand.</span>", "<span class='notice'>You add the [cardname] to your hand.</span>")
			C.interact(user)
			C.update_icon()
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")

	else if(istype(O, /obj/item/weapon/pen))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Card Writing", null) as text, 128)
		if(!user.incapacitated()) // So the person can't input while being incapacitated.
			scribble = txt

	else if(istype(O, /obj/item/weapon/paper))
		scribble = null

/obj/item/toy/play_singlecard/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.incapacitated())
		return
	Flip()

/*
 * A Deck of Cards
 */

/obj/item/toy/play_cards/normal_cards
	normal_deck_size = 52
	single_card = /obj/item/toy/play_singlecard/normal_cards
	hand_card = /obj/item/toy/play_cardhand/normal_cards

/obj/item/toy/play_cards/normal_cards/atom_init()
	. = ..()
	fill_deck(2, 10)
	integrity += cards

/obj/item/toy/play_cards/normal_cards/fill_deck(from_c, to_c)
	for(var/i in from_c to to_c)
		cards += "[i] of Hearts"
		cards += "[i] of Spades"
		cards += "[i] of Clubs"
		cards += "[i] of Diamonds"
	cards += "King of Hearts"
	cards += "King of Spades"
	cards += "King of Clubs"
	cards += "King of Diamonds"
	cards += "Queen of Hearts"
	cards += "Queen of Spades"
	cards += "Queen of Clubs"
	cards += "Queen of Diamonds"
	cards += "Jack of Hearts"
	cards += "Jack of Spades"
	cards += "Jack of Clubs"
	cards += "Jack of Diamonds"
	cards += "Ace of Hearts"
	cards += "Ace of Spades"
	cards += "Ace of Clubs"
	cards += "Ace of Diamonds"
	..()

/obj/item/toy/play_cardhand/normal_cards
	single_card = /obj/item/toy/play_singlecard/normal_cards
	hand_card = /obj/item/toy/play_cardhand/normal_cards

/obj/item/toy/play_singlecard/normal_cards
	single_card = /obj/item/toy/play_singlecard/normal_cards
	hand_card = /obj/item/toy/play_cardhand/normal_cards

/obj/item/toy/play_singlecard/normal_cards/examine(mob/user)
	..()
	if((src in user) && ishuman(user) && flipped)
		var/mob/living/carbon/human/cardUser = user
		if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			cardUser.visible_message("<span class='notice'>[cardUser] checks \his card.</span>", "<span class='notice'>The card reads: [cardname]</span>")
		else
			to_chat(cardUser, "<span class='notice'>You need to have the card in your hand to check it.</span>")

/*
 * A Deck of Halop's Cards
 */

/obj/item/toy/play_cards/halop_cards
	name = "deck of Space Station 13 cards"
	desc = "A deck of space-grade Space Station 13(TM) playing cards."
	icon = 'icons/obj/halop_cards.dmi'
	normal_deck_size = 30
	single_card = /obj/item/toy/play_singlecard/halop_cards
	hand_card = /obj/item/toy/play_cardhand/halop_cards

/obj/item/toy/play_cards/halop_cards/atom_init(mapload, card_list)
	. = ..()
	fill_deck(card_list)
	integrity += cards

/obj/item/toy/play_cards/halop_cards/fill_deck(card_list)
	for(var/a in card_list)
		cards += a
	..()

/obj/item/toy/play_cards/halop_cards/attackby(obj/O, mob/living/user)
	..()
	if(istype(O, /obj/item/weapon/storage/box/halops_booster_pack))
		var/obj/item/weapon/storage/box/halops_booster_pack/HBP = O
		if(HBP.parentdeck)
			to_chat(user, "<span class='warning'>This booster pack has already been attached to a deck.</span>")
		else
			HBP.parentdeck = src
			for(var/i in HBP.contents)
				if(istype(i, /obj/item/toy/play_singlecard/halop_cards))
					var/obj/item/toy/play_singlecard/halop_cards/HC = i
					HC.parentdeck = HBP.parentdeck
			to_chat(user, "<span class='notice'>You have attached [HBP] to [src].</span>")

/obj/item/toy/play_cardhand/halop_cards
	name = "hand of Space Station 13 cards"
	desc = "A number of Space Station 13(TM) cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/halop_cards.dmi'
	single_card = /obj/item/toy/play_singlecard/halop_cards
	hand_card = /obj/item/toy/play_cardhand/halop_cards

/obj/item/toy/play_cardhand/halop_cards/Topic(href, href_list)
	..()
	if(href_list["examine"])
		var/card_name = href_list["examine"]
		var/datum/playing_cards/card = card_datums_by_name[card_name]
		var/datum/asset/simple/assets = get_asset_datum(/datum/asset/simple/halop_cards)
		assets.send(usr)
		var/dat = "<img src=[card.examine_card] width=375 height=500 border=0>"
		usr << browse(entity_ja(dat), "window=Card Picture")

/obj/item/toy/play_singlecard/halop_cards
	name = "Space Station 13 card"
	desc = "A Space Station 13(TM) card."
	icon = 'icons/obj/halop_cards.dmi'
	single_card = /obj/item/toy/play_singlecard/halop_cards
	hand_card = /obj/item/toy/play_cardhand/halop_cards

/obj/item/toy/play_singlecard/halop_cards/examine(mob/user)
	..()
	if((src in view(1)) && ishuman(user) && flipped)
		var/datum/asset/simple/assets = get_asset_datum(/datum/asset/simple/halop_cards)		//Sending pictures to the client
		assets.send(user)
		var/dat = "<img src=[card_info.examine_card] width=375 height=500 border=0>"
		user << browse(entity_ja(dat), "window=Card Picture")

/obj/item/toy/play_singlecard/halop_cards/Flip()
	if(!flipped)
		flipped = TRUE
		if(cardname && card_info)
			icon_state = "sc_[cardname]_[card_info.number]"
			name = "[cardname] #[card_info.number]"
			desc = card_info.desc_card
		else
			icon_state = "sc_Assistant_1"
			name = "What Card?"
		pixel_x = 5
	else if(flipped)
		flipped = FALSE
		icon_state = initial(icon_state)
		name = initial(name)
		desc = initial(desc)

/*
 * Booster packs.
 */

/obj/item/weapon/storage/box/halops_booster_pack
	name = "card booster box"
	desc = "It's a box. With cards. Cards inside a box. Box. Cards in it."
	icon_state = "box"
	item_state = "syringe_kit"
	var/obj/item/toy/play_cards/parentdeck = null
	var/list/cards_possible = list()

/obj/item/weapon/storage/box/halops_booster_pack/atom_init()
	. = ..()
	if(cards_possible.len)
		while(contents.len < 7)
		var/new_card = pick(cards_possible)
		var/datum/playing_cards/new_card_datum = card_datums_by_name[new_card]
		if(prob(new_card_datum.rarity))
			var/obj/item/toy/play_singlecard/halop_cards/SC = new /obj/item/toy/play_singlecard/halop_cards(src)
			SC.cardname = new_card
			SC.generate_info()

/obj/item/weapon/storage/box/halops_booster_pack/attackby(obj/O, mob/living/user)
	if(istype(O, /obj/item/toy/play_cards/halop_cards))
		var/obj/item/toy/play_cards/halop_cards/C = O
		if(parentdeck)
			to_chat(user, "<span class='warning'>This booster pack has already been attached to a deck.</span>")
		else
			parentdeck = C
			for(var/i in contents)
				if(istype(i, /obj/item/toy/play_singlecard/halop_cards))
					var/obj/item/toy/play_singlecard/halop_cards/HC = i
					HC.parentdeck = C
			to_chat(user, "<span class='notice'>You have attached [src] to [C].</span>")
	..()

/obj/item/weapon/storage/box/halops_booster_pack/open(mob/user)
	if(parentdeck)
		..()
	else
		to_chat(user, "<span class='warning'>You need to attach a card deck, before you can open this booster pack.</span>")

/obj/item/weapon/storage/box/halops_booster_pack/random
	name = "random card booster box"

/obj/item/weapon/storage/box/halops_booster_pack/random/atom_init()
	. = ..()
	while(contents.len < 7)
		var/new_card = pick(card_drop_datums_by_name)
		var/datum/playing_cards/new_card_datum = card_drop_datums_by_name[new_card]
		if(prob(new_card_datum.rarity))
			var/obj/item/toy/play_singlecard/halop_cards/SC = new /obj/item/toy/play_singlecard/halop_cards(src)
			SC.cardname = new_card
			SC.generate_info()

/*
 * Halop Card Spawner
 */

/obj/item/weapon/card_spawner
	name = "Space Station 13 cards package"
	desc = "Leaves to wonder, what could be inside?"
	w_class = ITEM_SIZE_NORMAL
	icon = 'icons/obj/storage.dmi'
	icon_state = "box"
	item_state = "syringe_kit"
	var/list/alternative_card_list = list("Assistant", "Assistant", "Assistant", "Space Carp", "Space Carp", "Space Carp", "Shrub")

/obj/item/weapon/card_spawner/attack_hand(mob/user)
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>[src] can not be used by non humanoid lifeforms.</span>")
		return
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='notice'>[src] begins to shake, as [user] has activated it.</span>", "<span class='notice'>[src] begins to shake, as you activated it.</span>")
	if(H.client && H.client.prefs.halop_card_deck)
		if(H.client.prefs.halop_card_deck.len)
			var/obj/item/toy/play_cards/halop_cards/HC = new /obj/item/toy/play_cards/halop_cards(user.loc, H.client.prefs.halop_card_deck)
			user.put_in_active_hand(HC)
			qdel(src)
	else
		var/obj/item/toy/play_cards/halop_cards/HC = new /obj/item/toy/play_cards/halop_cards(user.loc, alternative_card_list)
		user.put_in_hands(HC)
	if(H.mind)
		if(H.mind.assigned_role in list("Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Head of Security"))
			var/obj/item/weapon/storage/box/halops_booster_pack/random/BP = new /obj/item/weapon/storage/box/halops_booster_pack/random(user.loc)
			to_chat(user, "<span class='notice'>As Central Command surely does approve of your work, as a gift, you receive [BP].</span>")
			user.put_in_hands(BP)
		else if(H.mind.special_role)
			var/obj/item/weapon/storage/box/halops_booster_pack/random/BP = new /obj/item/weapon/storage/box/halops_booster_pack/random(user.loc)
			to_chat(user, "<span class='notice'>As a gift from your employers, you receive [BP].</span>")
			user.put_in_hands(BP)
		else if(H.client.donator && config.allow_donators)
			var/obj/item/weapon/storage/box/halops_booster_pack/random/BP = new /obj/item/weapon/storage/box/halops_booster_pack/random(user.loc)
			to_chat(user, "<span class='notice'>For no apperant reason, your [src] seems special enough to contain [BP]. Have fun!</span>")
			user.put_in_hands(BP)
	qdel(src)