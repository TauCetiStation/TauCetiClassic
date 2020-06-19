/datum/bible_info
	var/list/pos_names

	var/name
	var/icon = 'icons/obj/storage.dmi'
	var/icon_state
	var/item_state

	var/laws_type = /datum/ai_laws/faith/commandments
	var/borg_name = "Blessed"

/datum/bible_info/New(datum/religion/R)
	if(pos_names)
		name = pick(pos_names)

/datum/bible_info/proc/apply_to(obj/item/weapon/storage/bible/B)
	B.name = name
	apply_visuals_to(B)

/datum/bible_info/proc/apply_visuals_to(obj/item/weapon/storage/bible/B)
	B.icon_state = icon_state
	B.item_state = item_state

// The go-to "default".
/datum/bible_info/custom
	icon_state = "bible"
	item_state = "bible"

/datum/bible_info/custom/New(datum/religion/R)
	name = "The Holy Book of [R.name]"

/datum/bible_info/bible
	// why is The Dead Sea Scrolls here? somebody make a seperate religion please. ~Luduk
	pos_names = list("The Holy Bible", "The Dead Sea Scrolls")
	icon_state = "bible"
	item_state = "bible"

/datum/bible_info/bible/white
	icon_state = "white"
	// Should be a white-ish book.
	item_state = "book10"

/datum/bible_info/bible/holylight
	icon_state = "holylight"
	// Should be a cyan-ish book.
	item_state = "book4"

/datum/bible_info/bible/melts
	icon_state = "melted"
	item_state = "melted"

/datum/bible_info/bible/buddhism
	name = "The Tripitaka"

/datum/bible_info/book_of_lorgar
	name = "Book of Lorgar"
	icon_state = "atheist"
	// Should be a red book.
	item_state = "book1"
	laws_type = /datum/ai_laws/faith/chaos
	borg_name = "Marked"

// Inside joke. *tips fedora* (not funny)
/datum/bible_info/book_of_lorgar/imperial_truth
	name = "Imperial Truth"
	laws_type = /datum/ai_laws/faith/emperor
	borg_name = "Imperial"

/datum/bible_info/satanism
	name = "The Unholy Bible"
	icon_state = "tome"
	// Should be a red book.
	item_state = "book1"
	laws_type = /datum/ai_laws/faith/satanism
	borg_name = "Bloody"

/datum/bible_info/necronomicon
	name = "The Necronomicon"
	icon_state = "necronomicon"
	item_state = "necronomicon"
	laws_type = /datum/ai_laws/faith/satanism
	borg_name = "Cthulhu"

/datum/bible_info/islam
	pos_names = list("Koran", "Quran")
	icon_state = "koran"
	item_state = "koran"

/datum/bible_info/scientology
	pos_names = list("The Biography of L. Ron Hubbard", "Dianetics")
	icon_state = "scientology"
	item_state = "scientology"
	laws_type = /datum/ai_laws/faith/scientology
	borg_name = "Good"

/datum/bible_info/scrapbook
	pos_names = list("The Holy Joke Book", "Hymns to the Honkmother", "Prank in the name of Honkmother", "Scrapbook")
	icon_state = "scrapbook"
	item_state = "scrapbook"
	laws_type = /datum/ai_laws/faith/honk
	borg_name = "Funny"

// Why does this exist? ~Luduk
/datum/bible_info/creeper
	name = "The Gamer Manifesto"
	icon_state = "creeper"
	// Should be a green-ish book.
	item_state = "book5"

/datum/bible_info/ithqua
	name = "Ithaqua"
	icon_state = "ithaqua"
	item_state = "ithaqua"

/datum/bible_info/king_in_yellow
	name = "The King in Yellow"
	icon_state = "kingyellow"
	item_state = "kingyellow"
	laws_type = /datum/ai_laws/faith/satanism

/datum/bible_info/atheist
	pos_names = list("Just book", "Recipes", "Space Laws", "Proof of the absence of God", "Bible: Small Edition")
	icon_state = "atheist"
	// Should be a red book.
	item_state = "book1"

/datum/bible_info/toolbox
	name = "Cruel Assistant's Thesis"
	icon_state = "bible"
	item_state = "bible"
	// icon_state = "blue"
	// item_state = "toolbox_blue"

/datum/bible_info/science
	pos_names = list("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology",
	                 "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
	icon_state = "bible"
	item_state = "bible"
	// icon_state = "holdingpack"
	// item_state = "backpack"
	laws_type = /datum/ai_laws/faith/science
	borg_name = "Factorial"

/datum/bible_info/techno
	name = "The Polyhedron"
	icon_state = "bible"
	item_state = "bible"
	// icon_state = "circuit_box"
	// item_state = "syringe_kit"
	laws_type = /datum/ai_laws/faith/science
	borg_name = "Infinity"
