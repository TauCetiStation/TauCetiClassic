/*
	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna2.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/

/datum/sprite_accessory
	var/icon			// the icon file the accessory is located in
	var/icon_state		// the icon_state of the accessory
	var/preview_state	// a custom preview state for whatever reason

	var/name			// the preview name of the accessory

	// Determines if the accessory will be skipped or included in random hair generations
	var/gender = NEUTER

	// Restrict some styles to specific species
	var/list/species_allowed = list(HUMAN)

	// Whether or not the accessory can be affected by colouration
	var/do_colouration = 1

	var/ipc_head_compatible

/*
////////////////////////////
/  =--------------------=  /
/  == Hair Definitions ==  /
/  =--------------------=  /
////////////////////////////
*/

/datum/sprite_accessory/hair
	icon = 'icons/mob/human_face.dmi'	  // default icon for all hairs

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = "bald"
	species_allowed = list(HUMAN , UNATHI , DIONA)

/datum/sprite_accessory/hair/short
	name = "Short Hair"	  // try to capatilize the names please~
	icon_state = "hair_a" // you do not need to define _s or _l sub-states, game automatically does this for you

/datum/sprite_accessory/hair/shorthair2
	name = "Short Hair 2"
	icon_state = "hair_shorthair2"

//datum/sprite_accessory/hair/shorthair3
//	name = "Short Hair 3"
//	icon_state = "hair_shorthair3"

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_c"

/datum/sprite_accessory/hair/long
	name = "Shoulder-length Hair"
	icon_state = "hair_b"

/datum/sprite_accessory/hair/longer
	name = "Long Hair"
	icon_state = "hair_vlong"

//datum/sprite_accessory/hair/over_eye
//	name = "Over Eye"
//	icon_state = "hair_shortovereye"

/datum/sprite_accessory/hair/long_over_eye
	name = "Long Over Eye"
	icon_state = "hair_longovereye"

//datum/sprite_accessory/hair/longest2
//	name = "Very Long Over Eye"
//	icon_state = "hair_longest2"

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair"
	icon_state = "hair_longest"

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/longestalt
	name = "Longer Fringe"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "hair_gentle"

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "hair_halfbang"

/datum/sprite_accessory/hair/halfbang2
	name = "Half-banged Hair 2"
	icon_state = "hair_halfbang2"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail"
	icon_state = "hair_ponytail"

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "hair_ponytail2"

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"

//datum/sprite_accessory/hair/ponytail4
//	name = "Ponytail 4"
//	icon_state = "hair_ponytail4"

//datum/sprite_accessory/hair/ponytail5
//	name = "Ponytail 5"
//	icon_state = "hair_ponytail5"

/datum/sprite_accessory/hair/sidetail
	name = "Side Pony"
	icon_state = "hair_sidetail"

/datum/sprite_accessory/hair/sidetail2
	name = "Side Pony 2"
	icon_state = "hair_sidetail2"

//datum/sprite_accessory/hair/sidetail3
//	name = "Side Pony 3"
//	icon_state = "hair_sidetail3"

//datum/sprite_accessory/hair/sidetail4
//	name = "Side Pony 4"
//	icon_state = "hair_sidetail4"

/datum/sprite_accessory/hair/sideponytail
	name = "Side Pony tail"
	icon_state = "hair_poofy"

/datum/sprite_accessory/hair/oneshoulder
	name = "One Shoulder"
	icon_state = "hair_oneshoulder"

/datum/sprite_accessory/hair/tressshoulder
	name = "Tress Shoulder"
	icon_state = "hair_tressshoulder"

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"

/datum/sprite_accessory/hair/bigpompadour
	name = "Big Pompadour"
	icon_state = "hair_bigpompadour"

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/messy
	name = "Messy"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"

//datum/sprite_accessory/hair/beehive2
//	name = "Beehive 2"
//	icon_state = "hair_beehivev2"

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"

/datum/sprite_accessory/hair/bob
	name = "Bob"
	icon_state = "hair_bobcut"

/datum/sprite_accessory/hair/bowl
	name = "Bowl"
	icon_state = "hair_bowlcut"

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "hair_buzzcut"

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"

/datum/sprite_accessory/hair/cottonhair
	name = "Cotton Hair"
	icon_state = "hair_cotton_hair"

/datum/sprite_accessory/hair/braidedhair
	name = "Braided Hair"
	icon_state = "hair_braided_hair"

/datum/sprite_accessory/hair/africanpigtails
	name = "African Pigtails"
	icon_state = "hair_african_pigtails"

/datum/sprite_accessory/hair/square
	name = "Square"
	icon_state = "hair_square"

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "hair_afro2"

/datum/sprite_accessory/hair/afro_large
	name = "Big Afro"
	icon_state = "hair_bigafro"

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "hair_sargeant"

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"

//datum/sprite_accessory/hair/longemo
//	name = "Long Emo"
//	icon_state = "hair_longemo"

/datum/sprite_accessory/hair/fag
	name = "Flow Hair"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "hair_d"

//datum/sprite_accessory/hair/reversemohawk
//	name = "Reverse Mohawk"
//	icon_state = "hair_reversemohawk"

/datum/sprite_accessory/hair/jensen
	name = "Jensen Hair"
	icon_state = "hair_jensen"

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "hair_gelled"

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spikey"

/datum/sprite_accessory/hair/spiky2
	name = "Spiky 2"
	icon_state = "hair_crono"

/datum/sprite_accessory/hair/spiky3
	name = "Spiky 3"
	icon_state = "hair_vegeta"

/datum/sprite_accessory/hair/protagonist
	name = "Slightly long"
	icon_state = "hair_protagonist"

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/kagami
	name = "Kagami Hair"
	icon_state = "hair_kagami"

/datum/sprite_accessory/hair/pigtail
	name = "Pigtails"
	icon_state = "hair_pigtails"

/datum/sprite_accessory/hair/pigtail2
	name = "Pigtails 2"
	icon_state = "hair_nitori"

//datum/sprite_accessory/hair/pigtail3
//	name = "Pigtails 3"
//	icon_state = "hair_pigtails3"

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"

//datum/sprite_accessory/hair/himecut2
//	name = "Hime Cut 2"
//	icon_state = "hair_himecut2"

//datum/sprite_accessory/hair/himeup
//	name = "Hime Updo"
//	icon_state = "hair_himeup"

/datum/sprite_accessory/hair/antenna
	name = "Ahoge"
	icon_state = "hair_antenna"

/datum/sprite_accessory/hair/lowbraid
	name = "Low Braid"
	icon_state = "hair_hbraid"

/datum/sprite_accessory/hair/not_floorlength_braid
	name = "High Braid"
	icon_state = "hair_braid2"

//datum/sprite_accessory/hair/shortbraid
//	name = "Short Braid"
//	icon_state = "hair_shortbraid"

/datum/sprite_accessory/hair/braid
	name = "Floorlength Braid"
	icon_state = "hair_braid"

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "hair_odango"

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"

//datum/sprite_accessory/hair/longbangs
//	name = "Long Bangs"
//	icon_state = "hair_lbangs"

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_e"

//datum/sprite_accessory/hair/parted
//	name = "Side Part"
//	icon_state = "hair_part"

//datum/sprite_accessory/hair/braided
//	name = "Braided"
//	icon_state = "hair_braided"

/datum/sprite_accessory/hair/bun
	name = "Bun Head"
	icon_state = "hair_bun"

//datum/sprite_accessory/hair/bun2
//	name = "Bun Head 2"
//	icon_state = "hair_bunhead2"

/datum/sprite_accessory/hair/braidtail
	name = "Braided Tail"
	icon_state = "hair_braidtail"

//datum/sprite_accessory/hair/bigflattop
//	name = "Big Flat Top"
//	icon_state = "hair_bigflattop"

/datum/sprite_accessory/hair/drillhair
	name = "Drill Hair"
	icon_state = "hair_drillhair"

/datum/sprite_accessory/hair/keanu
	name = "Keanu Hair"
	icon_state = "hair_edgeworth"

//datum/sprite_accessory/hair/swept
//	name = "Swept Back Hair"
//	icon_state = "hair_swept"

/datum/sprite_accessory/hair/swept2
	name = "Swept Back Hair 2"
	icon_state = "hair_joestar"

//datum/sprite_accessory/hair/business
//	name = "Business Hair"
//	icon_state = "hair_business"

//datum/sprite_accessory/hair/business2
//	name = "Business Hair 2"
//	icon_state = "hair_business2"

/datum/sprite_accessory/hair/business3
	name = "Business Hair 3"
	icon_state = "hair_cia"

/datum/sprite_accessory/hair/business4
	name = "Business Hair 4"
	icon_state = "hair_mulder"

/datum/sprite_accessory/hair/hedgehog
	name = "Hedgehog Hair"
	icon_state = "hair_blackswordsman"

/datum/sprite_accessory/hair/bob
	name = "Bob Hair"
	icon_state = "hair_schierke"

/datum/sprite_accessory/hair/bob2
	name = "Bob Hair 2"
	icon_state = "hair_scully"

/datum/sprite_accessory/hair/long
	name = "Long Hair 1"
	icon_state = "hair_nia"

//datum/sprite_accessory/hair/long2
//	name = "Long Hair 2"
//	icon_state = "hair_long2"

//datum/sprite_accessory/hair/pixie
//	name = "Pixie Cut"
//	icon_state = "hair_pixie"

/datum/sprite_accessory/hair/megaeyebrows
	name = "Mega Eyebrows"
	icon_state = "hair_megaeyebrows"

//datum/sprite_accessory/hair/highponytail
//	name = "High Ponytail"
//	icon_state = "hair_highponytail"

//datum/sprite_accessory/hair/longponytail
//	name = "Long Ponytail"
//	icon_state = "hair_longstraightponytail"

//datum/sprite_accessory/hair/sidepartlongalt
//	name = "Long Side Part"
//	icon_state = "hair_longsidepart"

/datum/sprite_accessory/hair/flair
	name = "Flaired Hair"
	icon_state = "hair_flair"

//datum/sprite_accessory/hair/himecut3
//	name = "Hime Cut 3"
//	icon_state = "hair_himecut3"

/datum/sprite_accessory/hair/big_tails
	name = "Big tails"
	icon_state = "hair_long_d_tails"

/datum/sprite_accessory/hair/long_bedhead
	name = "Long bedhead"
	icon_state = "hair_long_bedhead"

/datum/sprite_accessory/hair/fluttershy
	name = "Fluttershy"
	icon_state = "hair_fluttershy"

/datum/sprite_accessory/hair/judge
	name = "Judge"
	icon_state = "hair_judge"

/datum/sprite_accessory/hair/long_braid
	name = "Long braid"
	icon_state = "hair_long_braid"

/datum/sprite_accessory/hair/elize
	name = "Elize"
	icon_state = "hair_elize"

/datum/sprite_accessory/hair/elize2
	name = "Elize2"
	icon_state = "hair_elize_2"

/datum/sprite_accessory/hair/undercut_fem
	name = "Female undercut"
	icon_state = "hair_undercut_fem"

/datum/sprite_accessory/hair/emo_right
	name = "Emo right"
	icon_state = "hair_emo_r"

/datum/sprite_accessory/hair/applejack
	name = "Applejack"
	icon_state = "hair_applejack"

/datum/sprite_accessory/hair/rosa
	name = "Rosa"
	icon_state = "hair_rosa"

//TC trap powah
/datum/sprite_accessory/hair/dave
	name = "Dave"
	icon_state = "hair_dave"

/datum/sprite_accessory/hair/aradia
	name = "Aradia"
	icon_state = "hair_aradia"

/datum/sprite_accessory/hair/nepeta
	name = "Nepeta"
	icon_state = "hair_nepeta"

/datum/sprite_accessory/hair/kanaya
	name = "Kanaya"
	icon_state = "hair_kanaya"

/datum/sprite_accessory/hair/terezi
	name = "Terezi"
	icon_state = "hair_terezi"

/datum/sprite_accessory/hair/vriska
	name = "Vriska"
	icon_state = "hair_vriska"

/datum/sprite_accessory/hair/equius
	name = "Equius"
	icon_state = "hair_equius"

/datum/sprite_accessory/hair/gamzee
	name = "Gamzee"
	icon_state = "hair_gamzee"

/datum/sprite_accessory/hair/feferi
	name = "Feferi"
	icon_state = "hair_feferi"

/datum/sprite_accessory/hair/rose
	name = "Rose"
	icon_state = "hair_rose"

/datum/sprite_accessory/hair/ramona
	name = "Ramona"
	icon_state = "hair_ramona"

/datum/sprite_accessory/hair/dirk
	name = "Dirk"
	icon_state = "hair_dirk"

/datum/sprite_accessory/hair/jade
	name = "Jade"
	icon_state = "hair_jade"

/datum/sprite_accessory/hair/roxy
	name = "Roxy"
	icon_state = "hair_roxy"

/datum/sprite_accessory/hair/side_tail3
	name = "Side tail 3"
	icon_state = "hair_stail"

/datum/sprite_accessory/hair/familyman
	name = "Big Flat Top"
	icon_state = "hair_thefamilyman"

/datum/sprite_accessory/hair/dubsman
	name = "Dubs Hair "
	icon_state = "hair_dubs"

/datum/sprite_accessory/hair/objection
	name = "Swept Back Hair"
	icon_state = "hair_objection"

/datum/sprite_accessory/hair/metal
	name = "Metal"
	icon_state = "hair_80s"

/datum/sprite_accessory/hair/mentalist
	name = "Mentalist"
	icon_state = "hair_mentalist"

/datum/sprite_accessory/hair/fujisaki
	name = "fujisaki"
	icon_state = "hair_fujisaki"

/datum/sprite_accessory/hair/akari
	name = "Twin Buns"
	icon_state = "hair_akari"

/datum/sprite_accessory/hair/fujiyabashi
	name = "Fujiyabashi"
	icon_state = "hair_fujiyabashi"

/datum/sprite_accessory/hair/shinobu
	name = "Shinibu"
	icon_state = "hair_shinobu"

/datum/sprite_accessory/hair/combed
	name = "Combed Hair"
	icon_state = "hair_combed"

/datum/sprite_accessory/hair/longsidepart
	name = "Long Sideparts"
	icon_state = "hair_longsidepartstraight"

/datum/sprite_accessory/hair/bluntbangs
	name = "Blunt Bangs"
	icon_state = "hair_bluntbangs"

/datum/sprite_accessory/hair/combedbob
	name = "Combed Bob"
	icon_state = "hair_combedbob"

/datum/sprite_accessory/hair/halfshavedlong
	name = "Long Half Shaved"
	icon_state = "hair_halfshaved"

/datum/sprite_accessory/hair/slighlymessy
	name = "Slightly Messed"
	icon_state = "hair_slightlymessy"

/datum/sprite_accessory/hair/gypsy
	name = "Long Gypsy"
	icon_state = "hair_gipsy"

/datum/sprite_accessory/hair/geisha
	name = "Geisha"
	icon_state = "hair_geisha"

/datum/sprite_accessory/hair/fullovereye
	name = "Hair Over Eye"
	icon_state = "hair_baum"

/datum/sprite_accessory/hair/chub
	name = "Chub"
	icon_state = "hair_chub"

/datum/sprite_accessory/hair/ponytail6
	name = "Ponytail female"
	icon_state = "hair_ponytailf"

/datum/sprite_accessory/hair/wisp
	name = "Wisp"
	icon_state = "hair_wisp"

/datum/sprite_accessory/hair/halfshaved
	name = "Half-Shaved Emo"
	icon_state = "hair_halfshaved2"

/datum/sprite_accessory/hair/longeralt2
	name = "Long Hair Alt 2"
	icon_state = "hair_longeralt2"

/datum/sprite_accessory/hair/bun4
	name = "Bun 4"
	icon_state = "hair_bun4"

/datum/sprite_accessory/hair/doublebun
	name = "Double-Bun"
	icon_state = "hair_doublebun"

/datum/sprite_accessory/hair/rows
	name = "Rows"
	icon_state = "hair_rows1"

/datum/sprite_accessory/hair/rows2
	name = "Rows 2"
	icon_state = "hair_rows2"

/datum/sprite_accessory/hair/twintail
	name = "Twintail"
	icon_state = "hair_twintail"

/datum/sprite_accessory/hair/coffeehouse
	name = "Coffee House Cut"
	icon_state = "hair_coffeehouse"

/datum/sprite_accessory/hair/veryshortovereye
	name = "Overeye Very Short"
	icon_state = "hair_veryshortovereye"

/datum/sprite_accessory/hair/oxton
	name = "Oxton"
	icon_state = "hair_oxton"

/datum/sprite_accessory/hair/zieglertail
	name = "Zieglertail"
	icon_state = "hair_ziegler"

/datum/sprite_accessory/hair/fringeemo
	name = "Emo Fringe"
	icon_state = "hair_emofringe"

/datum/sprite_accessory/hair/poofy2
	name = "Poofy2"
	icon_state = "hair_poofy2"

/datum/sprite_accessory/hair/fringetail
	name = "Fringetail"
	icon_state = "hair_fringetail"

/datum/sprite_accessory/hair/bun3
	name = "Bun 3"
	icon_state = "hair_bun3"

/datum/sprite_accessory/hair/veryshortovereyealternate
	name = "Overeye Very Short, Alternate"
	icon_state = "hair_veryshortovereyealternate"

/datum/sprite_accessory/hair/undercut2
	name = "Undercut Swept Right"
	icon_state = "hair_undercut2"

/datum/sprite_accessory/hair/spikyponytail
	name = "Spiky Ponytail"
	icon_state = "hair_spikyponytail"

/datum/sprite_accessory/hair/grandebraid
	name = "Grande Braid"
	icon_state = "hair_grande"

/datum/sprite_accessory/hair/fringetail
	name = "Fringetail"
	icon_state = "hair_fringetail"

/datum/sprite_accessory/hair/rowbun
	name = "Row Bun"
	icon_state = "hair_rowbun"

/datum/sprite_accessory/hair/rowdualbraid
	name = "Row Dual Braid"
	icon_state = "hair_rowdualtail"

/datum/sprite_accessory/hair/rowbraid
	name = "Row Braid"
	icon_state = "hair_rowbraid"

/datum/sprite_accessory/hair/regulationmohawk
	name = "Regulation Mohawk"
	icon_state = "hair_shavedmohawk"

/datum/sprite_accessory/hair/topknot
	name = "Topknot"
	icon_state = "hair_topknot"

/datum/sprite_accessory/hair/ronin
	name = "Ronin"
	icon_state = "hair_ronin"

/datum/sprite_accessory/hair/bowlcut2
	name = "Bowl 2"
	icon_state = "hair_bowlcut2"

/datum/sprite_accessory/hair/manbun
	name = "Manbun"
	icon_state = "hair_manbun"

/datum/sprite_accessory/hair/country
	name = "Country"
	icon_state = "hair_country"

/datum/sprite_accessory/hair/ougi
	name = "Ougi"
	icon_state = "hair_ougi"

//datum/sprite_accessory/hair/modern
//	name = "Modern"
//	icon_state = "hair_modern"

//datum/sprite_accessory/hair/twincurl
//	name = "Twincurl"
//	icon_state = "hair_twincurl"

//datum/sprite_accessory/hair/rapunzel
//	name = "Rapunzel"
//	icon_state = "hair_rapunzel"

//datum/sprite_accessory/hair/quadcurls
//	name = "Quadcurls"
//	icon_state = "hair_quadcurls"

//datum/sprite_accessory/hair/twincurl2
//	name = "Twincurl 2"
//	icon_state = "hair_twincurl2"

//datum/sprite_accessory/hair/birdnest
//	name = "Birdnest "
//	icon_state = "hair_birdnest"

//datum/sprite_accessory/hair/unkept
//	name = "Unkept"
//	icon_state = "hair_unkept"

//datum/sprite_accessory/hair/fastline
//	name = "Fastline"
//	icon_state = "hair_fastline"

//datum/sprite_accessory/hair/duelist
//	name = "Duelist "
//	icon_state = "hair_duelist"

//datum/sprite_accessory/hair/sparta
//	name = "Sparta hair"
//	icon_state = "hair_sparta"


/*
///////////////////////////////////
/  =---------------------------=  /
/  == Facial Hair Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/facial_hair
	icon = 'icons/mob/human_face.dmi'
	gender = MALE // barf (unless you're a dorf, dorfs dig chix /w beards :P)

/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = "bald"
	gender = NEUTER
	species_allowed = list(HUMAN , UNATHI , TAJARAN , SKRELL , VOX , IPC, DIONA)

/datum/sprite_accessory/facial_hair/watson
	name = "Watson Mustache"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/hogan
	name = "Hulk Hogan Mustache"
	icon_state = "facial_hogan" //-Neek

/datum/sprite_accessory/facial_hair/vandyke
	name = "Van Dyke Mustache"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Square Mustache"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/selleck
	name = "Selleck Mustache"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Neckbeard"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Full Beard"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Long Beard"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Very Long Beard"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/elvis
	name = "Elvis Sideburns"
	icon_state = "facial_elvis"

/datum/sprite_accessory/facial_hair/abe
	name = "Abraham Lincoln Beard"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Chinstrap"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/hip
	name = "Hipster Beard"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/gt
	name = "Goatee"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/jensen
	name = "Jensen Beard"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Dwarf Beard"
	icon_state = "facial_dwarf"

//datum/sprite_accessory/facial_hair/fiveoclock
//	name = "Five o Clock Shadow"
//	icon_state = "facial_fiveoclock"

//datum/sprite_accessory/facial_hair/fu
//	name = "Fu Manchu"
//	icon_state = "facial_fumanchu"

/datum/sprite_accessory/facial_hair/postal
	name = "Goat Beard"
	icon_state = "facial_goatbeard"

//datum/sprite_accessory/facial_hair/britstache
//	name = "Britstache"
//	icon_state = "facial_britstache"

//datum/sprite_accessory/facial_hair/martial_artist
//	name = "Martial Artist"
//	icon_state = "facial_martialartist"

//datum/sprite_accessory/facial_hair/moonshiner
//	name = "Moonshiner"
//	icon_state = "facial_moonshiner"

//datum/sprite_accessory/facial_hair/tribeard
//	name = "Tri-Beard"
//	icon_state = "facial_tribeard"

//datum/sprite_accessory/facial_hair/unshaven
//	name = "Unshaven"
//	icon_state = "facial_unshaven"


/*
///////////////////////////////////
/  =---------------------------=  /
/  == Alien Style Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/
/datum/sprite_accessory/hair/ipc_screen_off
	name = "IPC off screen"
	icon_state = "ipc_off"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = null

/datum/sprite_accessory/hair/ipc_screen_pink
	name = "pink IPC screen"
	icon_state = "ipc_pink"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_red
	name = "red IPC screen"
	icon_state = "ipc_red"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_green
	name = "green IPC screen"
	icon_state = "ipc_green"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_blue
	name = "blue IPC screen"
	icon_state = "ipc_blue"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_breakout
	name = "breakout IPC screen"
	icon_state = "ipc_breakout"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_eight
	name = "eight IPC screen"
	icon_state = "ipc_eight"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_goggles
	name = "goggles IPC screen"
	icon_state = "ipc_goggles"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_heart
	name = "heart IPC screen"
	icon_state = "ipc_heart"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_monoeye
	name = "monoeye IPC screen"
	icon_state = "ipc_monoeye"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_nature
	name = "nature IPC screen"
	icon_state = "ipc_nature"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_orange
	name = "orange IPC screen"
	icon_state = "ipc_orange"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_purple
	name = "purple IPC screen"
	icon_state = "ipc_purple"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_shower
	name = "shower IPC screen"
	icon_state = "ipc_shower"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_static
	name = "static IPC screen"
	icon_state = "ipc_static"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_yellow
	name = "yellow IPC screen"
	icon_state = "ipc_yellow"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_dot
	name = "dot IPC screen"
	icon_state = "ipc_dot"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_four
	name = "four IPC screen"
	icon_state = "ipc_four"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_eye
	name = "eye IPC screen"
	icon_state = "ipc_eye"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_eyes
	name = "eyes IPC screen"
	icon_state = "ipc_eyes"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_alien
	name = "alien IPC screen"
	icon_state = "ipc_alien"
	species_allowed = list(IPC)
	ipc_head_compatible = "Alien"

/datum/sprite_accessory/hair/ipc_screen_double
	name = "double IPC screen"
	icon_state = "ipc_double"
	species_allowed = list(IPC)
	ipc_head_compatible = "Double"

/datum/sprite_accessory/hair/ipc_screen_pillar
	name = "pillar IPC screen"
	icon_state = "ipc_pillar"
	species_allowed = list(IPC)
	ipc_head_compatible = "Pillar"

/datum/sprite_accessory/hair/ipc_screen_human
	name = "human IPC screen"
	icon_state = "ipc_human"
	species_allowed = list(IPC)
	ipc_head_compatible = "Human"

/datum/sprite_accessory/hair/ipc_color_array
	name = "colored IPC screen with an eye"
	icon_state = "ipc_color_array"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_television
	name = "TV IPC screen"
	icon_state = "ipc_television"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_color_array_horizontal
	name = "horizontal colored IPC screen"
	icon_state = "ipc_color_array_horizontal"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_color_array_vertical
	name = "vertical colored IPC screen"
	icon_state = "ipc_color_array_vertical"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_miami
	name = "miami IPC screen"
	icon_state = "ipc_miami"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

	//UNATHI HAIRS

/datum/sprite_accessory/hair/una_small_horns
	name = "Small Horny"
	icon_state = "una_small_horns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_faun
	name = "Faunus"
	icon_state = "una_faun"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_bullhorn
	name = "Bully"
	icon_state = "una_bullhorn"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_ram2_horns
	name = "Ramming Horns"
	icon_state = "una_ram2_horns"

/datum/sprite_accessory/hair/una_chin_horns
	name = "Chin Horns"
	icon_state = "una_chin_horns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_drac_horns
	name = "Drac Horns"
	icon_state = "una_drac_horns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_adorns_horns
	name = "Adorns"
	icon_state = "una_adorns_horns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_spikes_horn
	name = "Spikes"
	icon_state = "una_spikes_horns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_big_horns
	name = "Big Horns"
	icon_state = "una_big_horns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_simple_horns
	name = "Simple Horns"
	icon_state = "una_simple_horns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_cobrahood
	name = "Cobra Hood"
	icon_state = "una_facial_cobrahood"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facialhair/una_facial_aquaticfrills
	name = "Aquatic Frills Full"
	icon_state = "una_facial_aquaticfrills"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_longdorsal
	name = "Long Dorsal 4"
	icon_state = "una_facial_longdorsal"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_ramhorn2
	name = "Ram Horns 2"
	icon_state = "una_ramhorn2"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_demonforward
	name = "Demon Horns"
	icon_state = "una_demonforward"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_chameleon
	name = "Chameleon"
	icon_state = "una_chameleon"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_dubhorns
	name = "Dub Horn"
	icon_state = "una_dubhorns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_faun
	name = "Faun"
	icon_state = "una_faun"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_hood
	name = "Hood"
	icon_state = "una_facial_hood"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_shortfrills2
	name = "Short Frills 2"
	icon_state = "una_facial_shortfrills2"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_dracfrills
	name = "Drac Frills Full"
	icon_state = "una_facial_dracfrills"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/unathi_warrior_horns
	name = "Warrior Horns"
	icon_state = "una_warrior_horns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/unathi_smallhorns
	name = "Small Horns"
	icon_state = "una_smallhorns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/unathi_dreads
	name = "Dreads"
	icon_state = "una_dreads"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/unathi_dreads_long
	name = "Long Dreads"
	icon_state = "una_dreads_long"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/unathi_dreads_short
	name = "Short Dreads"
	icon_state = "una_dreads_short"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/unathi_dreads_predator
	name = "Predator Dreads"
	icon_state = "una_dreads_predator"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/unathi_hiss_collinss
	name = "Hiss Collinss"
	icon_state = "una_hiss_collinss"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/unathi_horns_curled
	name = "Curled Horns"
	icon_state = "una_horns_curled"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/unathi_horns_ram
	name = "Ram Horns"
	icon_state = "una_horns_ram"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_spines_long
	name = "Long Unathi Spines"
	icon_state = "una_longspines"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_spines_short
	name = "Short Unathi Spines"
	icon_state = "una_shortspines"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_longfrills
	name = "Long Unathi Frills"
	icon_state = "una_facial_longfrills"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_frills_short
	name = "Short Unathi Frills"
	icon_state = "una_shortfrills"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_horns
	name = "Unathi Horns"
	icon_state = "una_horns"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_aquaticfrill
	name = "Aquatic Frills"
	icon_state = "una_facial_aquaticfrills"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_aquaticfrills_webbing
	name = "Aquatic Frills Webbed"
	icon_state = "una_facial_aquaticfrills_webbing"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_shortfrills2
	name = "Short Frills 2"
	icon_state = "una_facial_shortfrills2"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_dracfrills
	name = "Drac Frills"
	icon_state = "una_facial_dracfrills"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_dracfrills_webbing
	name = "Drac Frills Webbed"
	icon_state = "una_facial_dracfrills_webbing"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_sidefrills
	name = "Side Frills"
	icon_state = "una_facial_sidefrills"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/hair/una_demonforward
	name = "Demon Forward"
	icon_state = "una_demonforward"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_dorsalfrills
	name = "Dorsa Frills"
	icon_state = "una_facial_dorsalfrills"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_dorsalfrills_webbing
	name = "Dorsa Frills Webbed"
	icon_state = "una_facial_dorsalfrills_webbing"
	species_allowed = list(UNATHI)

/datum/sprite_accessory/facial_hair/una_facial_dorsalfrill3
	name = "Dorsa Frills 3"
	icon_state = "una_facial_dorsalfrill3"
	species_allowed = list(UNATHI)


/datum/sprite_accessory/facial_hair/una_hipbraid_beads
	name = "Bead"
	icon_state = "una_facial_hipbraid_beads"
	species_allowed = list(UNATHI)

//SKRELL HAIRS

/datum/sprite_accessory/hair/skr_veryshort_m
	name = "Skrell Very Short Male Tentacles"
	icon_state = "skr_veryshort_m"
	species_allowed = list(SKRELL)
	gender = MALE

/datum/sprite_accessory/hair/skr_long_f
	name = "Skrell Long Female Tentacles"
	icon_state = "skr_long_f"
	species_allowed = list(SKRELL)
	gender = FEMALE

/datum/sprite_accessory/hair/skr_verylong_f
	name = "Skrell Very Long Female Tentacles"
	icon_state = "skr_verylong_f"
	species_allowed = list(SKRELL)
	gender = FEMALE

/datum/sprite_accessory/hair/skr_zeke_f
	name = "Skrell Zeke Female Tentacles"
	icon_state = "skr_zeke_f"
	species_allowed = list(SKRELL)
	gender = FEMALE

/datum/sprite_accessory/hair/skr_tentacle_m
	name = "Skrell Male Tentacles"
	icon_state = "skr_hair_m"
	species_allowed = list(SKRELL)
	gender = MALE

/datum/sprite_accessory/hair/skr_tentacle_f
	name = "Skrell Female Tentacles"
	icon_state = "skr_hair_f"
	species_allowed = list(SKRELL)
	gender = FEMALE

/datum/sprite_accessory/hair/skr_gold_m
	name = "Gold plated Skrell Male Tentacles"
	icon_state = "skr_goldhair_m"
	species_allowed = list(SKRELL)
	gender = MALE

/datum/sprite_accessory/hair/skr_gold_f
	name = "Gold chained Skrell Female Tentacles"
	icon_state = "skr_goldhair_f"
	species_allowed = list(SKRELL)
	gender = FEMALE

/datum/sprite_accessory/hair/skr_clothtentacle_m
	name = "Cloth draped Skrell Male Tentacles"
	icon_state = "skr_clothhair_m"
	species_allowed = list(SKRELL)
	gender = MALE

/datum/sprite_accessory/hair/skr_clothtentacle_f
	name = "Cloth draped Skrell Female Tentacles"
	icon_state = "skr_clothhair_f"
	species_allowed = list(SKRELL)
	gender = FEMALE

/datum/sprite_accessory/hair/taj_ears
	name = "Tajaran Ears"
	icon_state = "taj_ears_plain"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_clean
	name = "Tajara Clean"
	icon_state = "taj_hair_clean"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_bangs
	name = "Tajara Bangs"
	icon_state = "taj_hair_bangs"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_braid
	name = "Tajara Braid"
	icon_state = "taj_hair_tbraid"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_shaggy
	name = "Tajara Shaggy"
	icon_state = "taj_hair_shaggy"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_mohawk
	name = "Tajaran Mohawk"
	icon_state = "taj_hair_mohawk"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_plait
	name = "Tajara Plait"
	icon_state = "taj_hair_plait"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_straight
	name = "Tajara Straight"
	icon_state = "taj_hair_straight"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_long
	name = "Tajara Long"
	icon_state = "taj_hair_long"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_rattail
	name = "Tajara Rat Tail"
	icon_state = "taj_hair_rattail"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_spiky
	name = "Tajara Spiky"
	icon_state = "taj_hair_tajspiky"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_messy
	name = "Tajara Messy"
	icon_state = "taj_hair_messy"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_tailshort
	name = "Tajara Short Tail"
	icon_state = "taj_hair_shorttail"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ears_messylong
	name = "Tajara Long Messy"
	icon_state = "taj_hair_messylong"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_sidebraid
	name = "Tajara Side Braid"
	icon_state = "taj_hair_sidebraid"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ribbons
	name = "Tajara Ribbons"
	icon_state = "taj_hair_ribbons"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_earrings
	name = "Tajara Ear Rings"
	icon_state = "taj_hair_earrings"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_combedback
	name = "Tajara Combed Back"
	icon_state = "taj_hair_combedback"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_tailedbangs
	name = "Tajara Tailed Bangs"
	icon_state = "taj_hair_tailedbangs"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_punk
	name = "Tajara Punk"
	icon_state = "taj_hair_punk"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_marmalade
	name = "Tajara Marmalade"
	icon_state = "taj_hair_marmalade"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_lynx
	name = "Tajara Lynx"
	icon_state = "taj_hair_lynx"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_longtail
	name = "Tajara Long Tail"
	icon_state = "taj_hair_longtail"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_shy
	name = "Tajara Shy"
	icon_state = "taj_hair_shy"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_metal
	name = "Tajara Metal"
	icon_state = "taj_hair_metal"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_ponytail
	name = "Tajara Ponytail"
	icon_state = "taj_hair_ponytail"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_overeye
	name = "Tajara Over Eye"
	icon_state = "taj_hair_overeye"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_tough
	name = "Tajara Tough"
	icon_state = "taj_hair_tough"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_cuttail
	name = "Tajara Cut Tail"
	icon_state = "taj_hair_cuttail"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/taj_dreadlocks
	name = "Tajara Dreadlocks"
	icon_state = "taj_hair_dreadlocks"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/tajbun
	name = "Tajara Bun."
	icon_state = "taj_hair_bun"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/tajtail
	name = "Tajara Tail."
	icon_state = "taj_hair_tail"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/vox_quills_short
	name = "Short Vox Quills"
	icon_state = "vox_shortquills"
	species_allowed = list(VOX)

/datum/sprite_accessory/hair/vox_yasu
	name = "Yasu"
	icon_state = "vox_yasu"
	species_allowed = list(VOX)

/datum/sprite_accessory/hair/vox_razor
	name = "Razor"
	icon_state = "vox_razor"
	species_allowed = list(VOX)

/datum/sprite_accessory/hair/vox_kingly
	name = "Kingly"
	icon_state = "vox_kingly"
	species_allowed = list(VOX)

/datum/sprite_accessory/hair/vox_badhead
	name = "Badhead"
	icon_state = "vox_badhead"
	species_allowed = list(VOX)

/datum/sprite_accessory/facial_hair/taj_sideburns
	name = "Tajara Sideburns"
	icon_state = "taj_facial_sideburns"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/facial_hair/taj_mutton
	name = "Tajara Mutton"
	icon_state = "taj_facial_mutton"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/facial_hair/taj_pencilstache
	name = "Tajara Pencilstache"
	icon_state = "taj_facial_pencilstache"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/facial_hair/taj_moustache
	name = "Tajara Moustache"
	icon_state = "taj_facial_moustache"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/facial_hair/taj_goatee
	name = "Tajara Goatee"
	icon_state = "taj_facial_goatee"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/facial_hair/taj_smallstache
	name = "Tajara Smallsatche"
	icon_state = "taj_facial_smallstache"
	species_allowed = list(TAJARAN)

/datum/sprite_accessory/hair/dio_bloom
	name = "Diona Everbloom"
	icon_state = "dio_bloom"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_rose
	name = "Diona Rose"
	icon_state = "dio_rose"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_king
	name = "Diona Flowerking"
	icon_state = "dio_king"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_vines
	name = "Diona Vines Short"
	icon_state = "dio_vines"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_vinel
	name = "Diona Vines Long"
	icon_state = "dio_vinel"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_lotus
	name = "Diona Lotus"
	icon_state = "dio_lotus"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_palm
	name = "Diona Palmhead"
	icon_state = "dio_palm"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_garland
	name = "Diona Garland"
	icon_state = "dio_garland"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_shrub
	name = "Diona Shrub"
	icon_state = "dio_shrub"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_ficus
	name = "Diona Ficus"
	icon_state = "dio_ficus"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_rosey
	name = "Diona Rosey"
	icon_state = "dio_rosey"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_oak
	name = "Diona Oak"
	icon_state = "dio_oak"
	do_colouration = FALSE
	species_allowed = list(DIONA)


/datum/sprite_accessory/hair/dio_sprout
	name = "Diona Sprout"
	icon_state = "dio_sprout"
	do_colouration = FALSE
	species_allowed = list(DIONA)


/datum/sprite_accessory/hair/dio_leafy
	name = "Diona Leafy"
	icon_state = "dio_leafy"
	do_colouration = FALSE
	species_allowed = list(DIONA)


/datum/sprite_accessory/hair/dio_meadow
	name = "Diona Meadow"
	icon_state = "dio_meadow"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_laurel
	name = "Diona Laurel"
	icon_state = "dio_laurel"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_root
	name = "Diona Root"
	icon_state = "dio_root"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_spinner
	name = "Diona Spinner"
	icon_state = "dio_spinner"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_bracket
	name = "Diona Bracket"
	icon_state = "dio_bracket"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_vine
	name = "Diona Vines"
	icon_state = "dio_vine"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_wildflower
	name = "Diona Wild Flowers"
	icon_state = "dio_wildflower"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_cornflower
	name = "Diona Cornflowers"
	icon_state = "dio_cornflower"
	do_colouration = FALSE
	species_allowed = list(DIONA)

/datum/sprite_accessory/hair/dio_brush
	name = "Diona Brush"
	icon_state = "dio_brush"
	do_colouration = FALSE
	species_allowed = list(DIONA)