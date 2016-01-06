/*
|| A Deck of Cards for playing various games of chance || //from /tg/
*/



obj/item/toy/cards
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'tauceti/items/cards/cards.dmi'
	icon_state = "deck_full"
	w_class = 2.0
	var/list/cards = list()

obj/item/toy/cards/New()
	..()
	for(var/i = 2; i <= 10; i++)
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


obj/item/toy/cards/attack_hand(mob/user as mob)
	var/choice = null
	if(cards.len == 0)
		src.icon_state = "deck_empty"
		user << "<span class='notice'>There are no more cards to draw.</span>"
		return
	var/obj/item/toy/singlecard/H = new/obj/item/toy/singlecard(user.loc)
	choice = cards[1]
	H.cardname = choice
	H.parentdeck = src
	src.cards -= choice
	H.pickup(user)
	user.put_in_active_hand(H)
	src.visible_message("<span class='notice'>[user] draws a card from the deck.</span>", "<span class='notice'>You draw a card from the deck.</span>")
	if(cards.len > 26)
		src.icon_state = "deck_full"
	else if(cards.len > 10)
		src.icon_state = "deck_half"
	else if(cards.len > 1)
		src.icon_state = "deck_low"

obj/item/toy/cards/attack_self(mob/user as mob)
	cards = shuffle(cards)
	playsound(user, 'tauceti/sounds/items/cardshuffle.ogg', 50, 1)
	user.visible_message("<span class='notice'>[user] shuffles the deck.</span>", "<span class='notice'>You shuffle the deck.</span>")

obj/item/toy/cards/attackby(obj/item/toy/singlecard/C, mob/living/user)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			src.cards += C.cardname
			user.remove_from_mob(C)
			user.visible_message("<span class='notice'>[user] adds a card to the bottom of the deck.</span>","<span class='notice'>You add the card to the bottom of the deck.</span>")
			qdel(C)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"
		if(cards.len > 26)
			src.icon_state = "deck_full"
		else if(cards.len > 10)
			src.icon_state = "deck_half"
		else if(cards.len > 1)
			src.icon_state = "deck_low"


obj/item/toy/cards/attackby(obj/item/toy/cardhand/C, mob/living/user)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			src.cards += C.currenthand
			user.remove_from_mob(C)
			user.visible_message("<span class='notice'>[user] puts their hand of cards in the deck.</span>", "<span class='notice'>You put the hand of cards in the deck.</span>")
			qdel(C)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"
		if(cards.len > 26)
			src.icon_state = "deck_full"
		else if(cards.len > 10)
			src.icon_state = "deck_half"
		else if(cards.len > 1)
			src.icon_state = "deck_low"

obj/item/toy/cards/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(Adjacent(usr))
		if(over_object == M)
			M.put_in_hands(src)
			usr << "<span class='notice'>You pick up the deck.</span>"

		else if(istype(over_object, /obj/screen))
			switch(over_object.name)
				if("r_hand")
					M.u_equip(src)
					M.put_in_r_hand(src)
					usr << "<span class='notice'>You pick up the deck.</span>"
				if("l_hand")
					M.u_equip(src)
					M.put_in_l_hand(src)
					usr << "<span class='notice'>You pick up the deck.</span>"
	else
		usr<< "<span class='notice'>You can't reach it from here.</span>"



obj/item/toy/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'tauceti/items/cards/cards.dmi'
	icon_state = "hand2"
	w_class = 1.0
	var/list/currenthand = list()
	var/obj/item/toy/cards/parentdeck = null
	var/choice = null


obj/item/toy/cardhand/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

obj/item/toy/cardhand/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in currenthand)
		dat += "<A href='?src=\ref[src];pick=[t]'>A [t].</A><BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()


obj/item/toy/cardhand/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/cardUser = usr
	if(href_list["pick"])
		if (cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			var/choice = href_list["pick"]
			var/obj/item/toy/singlecard/C = new/obj/item/toy/singlecard(cardUser.loc)
			src.currenthand -= choice
			C.parentdeck = src.parentdeck
			C.cardname = choice
			C.pickup(cardUser)
			cardUser.put_in_any_hand_if_possible(C)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from \his hand.</span>", "<span class='notice'>You take the [C.cardname] from your hand.</span>")

			interact(cardUser)

			if(src.currenthand.len < 3)
				src.icon_state = "hand2"
			else if(src.currenthand.len < 4)
				src.icon_state = "hand3"
			else if(src.currenthand.len < 5)
				src.icon_state = "hand4"

			if(src.currenthand.len == 1)
				var/obj/item/toy/singlecard/N = new/obj/item/toy/singlecard(src.loc)
				N.parentdeck = src.parentdeck
				N.cardname = src.currenthand[1]
				cardUser.remove_from_mob(src)
				N.pickup(cardUser)
				cardUser.put_in_any_hand_if_possible(N)
				cardUser << "<span class='notice'>You also take [currenthand[1]] and hold it.</span>"
				cardUser << browse(null, "window=cardhand")
				qdel(src)
		return

obj/item/toy/cardhand/attackby(obj/item/toy/singlecard/C, mob/living/user)
	if(istype(C))
		if(C.parentdeck == src.parentdeck)
			src.currenthand += C.cardname
			user.remove_from_mob(C)
			user.visible_message("<span class='notice'>[user] adds a card to their hand.</span>", "<span class='notice'>You add the [C.cardname] to your hand.</span>")
			interact(user)
			if(currenthand.len > 4)
				src.icon_state = "hand5"
			else if(currenthand.len > 3)
				src.icon_state = "hand4"
			else if(currenthand.len > 2)
				src.icon_state = "hand3"
			qdel(C)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"





obj/item/toy/singlecard
	name = "card"
	desc = "a card"
	icon = 'tauceti/items/cards/cards.dmi'
	icon_state = "singlecard_down"
	w_class = 1.0
	var/cardname = null
	var/obj/item/toy/cards/parentdeck = null
	var/flipped = 0
	pixel_x = -5

obj/item/toy/singlecard/examine()
	set src in usr.contents
	if(ishuman(usr))
		var/mob/living/carbon/human/cardUser = usr
		if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			cardUser.visible_message("<span class='notice'>[cardUser] checks \his card.</span>", "<span class='notice'>The card reads: [src.cardname]</span>")
		else
			cardUser << "<span class='notice'>You need to have the card in your hand to check it.</span>"


obj/item/toy/singlecard/verb/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(!flipped)
		src.flipped = 1
		if (cardname)
			src.icon_state = "sc_[cardname]"
			src.name = src.cardname
		else
			src.icon_state = "sc_Ace of Spades"
			src.name = "What Card"
		src.pixel_x = 5
	else if(flipped)
		src.flipped = 0
		src.icon_state = "singlecard_down"
		src.name = "card"
		src.pixel_x = -5

obj/item/toy/singlecard/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/toy/singlecard/))
		var/obj/item/toy/singlecard/C = I
		if(C.parentdeck == src.parentdeck)
			var/obj/item/toy/cardhand/H = new/obj/item/toy/cardhand(user.loc)
			H.currenthand += C.cardname
			H.currenthand += src.cardname
			H.parentdeck = C.parentdeck
			user.remove_from_mob(C)
			H.pickup(user)
			user.put_in_active_hand(H)
			user << "<span class='notice'>You combine the [C.cardname] and the [src.cardname] into a hand.</span>"
			qdel(C)
			qdel(src)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"

	if(istype(I, /obj/item/toy/cardhand/))
		var/obj/item/toy/cardhand/H = I
		if(H.parentdeck == parentdeck)
			H.currenthand += cardname
			user.remove_from_mob(src)
			user.visible_message("<span class='notice'>[user] adds a card to \his hand.</span>", "<span class='notice'>You add the [cardname] to your hand.</span>")
			H.interact(user)
			if(H.currenthand.len > 4)
				H.icon_state = "hand5"
			else if(H.currenthand.len > 3)
				H.icon_state = "hand4"
			else if(H.currenthand.len > 2)
				H.icon_state = "hand3"
			qdel(src)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"


obj/item/toy/singlecard/attack_self(mob/user)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	Flip()











