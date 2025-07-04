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
	var/list/species_allowed = list(HUMAN, PODMAN,PLUVIAN)

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
	species_allowed = list(HUMAN, UNATHI, DIONA, PODMAN, PLUVIAN)

/datum/sprite_accessory/hair/buzzcut
	name = "Buzz Cut"
	icon_state = "hair_buzzcut"

/datum/sprite_accessory/hair/business
	name = "Business"
	icon_state = "hair_business"

/datum/sprite_accessory/hair/business2
	name = "Business 2"
	icon_state = "hair_business2"

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/bobcut
	name = "Bobcut"
	icon_state = "hair_bobcut"

/datum/sprite_accessory/hair/bobcurls
	name = "Bobcurl"
	icon_state = "hair_bobcurl"

/datum/sprite_accessory/hair/bowlcut
	name = "Bowlcut"
	icon_state = "hair_bowlcut"

/datum/sprite_accessory/hair/blacksword
	name = "Blackswordcut"
	icon_state = "hair_blackswordsman"

/datum/sprite_accessory/hair/bun
	name = "Bun"
	icon_state = "hair_bun"

/datum/sprite_accessory/hair/bunstick
	name = "Bunstick"
	icon_state = "hair_bunstick"

/datum/sprite_accessory/hair/doublebun
	name = "Double Bun"
	icon_state = "hair_doublebun"

/datum/sprite_accessory/hair/doublebun2
	name = "Double Bun 2"
	icon_state = "hair_doublebuns_2"

/datum/sprite_accessory/hair/doublebuns3
	name = "Double Bun 3"
	icon_state = "hair_doublebuns_3"

/datum/sprite_accessory/hair/baum
	name = "Baum"
	icon_state = "hair_baum"

/datum/sprite_accessory/hair/beam
	name = "Beam"
	icon_state = "hair_beam"

/datum/sprite_accessory/hair/beam2
	name = "Beam 2"
	icon_state = "hair_beam_2"

/datum/sprite_accessory/hair/beam3
	name = "Beam 3"
	icon_state = "hair_beam_3"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"

/datum/sprite_accessory/hair/smallbeehive
	name = "Small Beehive"
	icon_state = "hair_smallbeehive"

/datum/sprite_accessory/hair/bao
	name = "Bao"
	icon_state = "hair_bao"

/datum/sprite_accessory/hair/bao2
	name = "Bao 2"
	icon_state = "hair_bao2"

/datum/sprite_accessory/hair/bao3
	name = "Bao 3"
	icon_state = "hair_bao_3"

/datum/sprite_accessory/hair/ponytail
	name = "Ponytail"
	icon_state = "hair_ponytail"

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "hair_ponytail2"

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"

/datum/sprite_accessory/hair/ponytailf
	name = "Ponytail (f)"
	icon_state = "hair_ponytailf"

/datum/sprite_accessory/hair/pushponytail
	name = "Push - Ponytail"
	icon_state = "hair_push_ponytail"

/datum/sprite_accessory/hair/spikyponytail
	name = "Spiky - Ponytail"
	icon_state = "hair_spikyponytail"

/datum/sprite_accessory/hair/zoeponytail
	name = "Zoe - Ponytail"
	icon_state = "hair_zoe_ponytail"

/datum/sprite_accessory/hair/rabbyponytail
	name = "Rabby - Ponytail"
	icon_state = "hair_rabby_ponytail"

/datum/sprite_accessory/hair/wisp
	name = "Wisp - Ponytail"
	icon_state = "hair_wisp_ponytail"

/datum/sprite_accessory/hair/ziglertail
	name = "Ziegler - Ponytail"
	icon_state = "hair_ziegler_ponytail"

/datum/sprite_accessory/hair/halfziglertail
	name = "Half Ziegler - Ponytail"
	icon_state = "hair_halfzinger_ponytail"

/datum/sprite_accessory/hair/brazeskatail
	name = "Brazeska - Ponytail"
	icon_state = "hair_brazeska_ponytail"

/datum/sprite_accessory/hair/longside
	name = "Side Part - Long"
	icon_state = "hair_long_sidepartstraight"

/datum/sprite_accessory/hair/longside2
	name = "Side Part 2 - Long"
	icon_state = "hair_long_sidepartstraight_2"

/datum/sprite_accessory/hair/longgipsy
	name = "Gipsy - Long"
	icon_state = "hair_long_gipsy"

/datum/sprite_accessory/hair/longwild
	name = "Wild - Long"
	icon_state = "hair_long_wild_2"

/datum/sprite_accessory/hair/longshav
	name = "Halfshaved - Long"
	icon_state = "hair_long_halfshaved"

/datum/sprite_accessory/hair/longblunt
	name = "Bluntbangs - Long"
	icon_state = "hair_long_bluntbangs"

/datum/sprite_accessory/hair/longflutter
	name = "Fluttershy - Long"
	icon_state = "hair_long_fluttershy"

/datum/sprite_accessory/hair/longaradia
	name = "Aradia - Long"
	icon_state = "hair_long_aradia"

/datum/sprite_accessory/hair/longnord
	name = "Nord - Long"
	icon_state = "hair_long_nord"

/datum/sprite_accessory/hair/longjudge
	name = "Judge - Long"
	icon_state = "hair_long_judge"

/datum/sprite_accessory/hair/longbedhead
	name = "Bedhead - Long"
	icon_state = "hair_long_bedhead"

/datum/sprite_accessory/hair/longnia
	name = "Nia - Long"
	icon_state = "hair_long_nia"

/datum/sprite_accessory/hair/longcia
	name = "Cia - Long"
	icon_state = "hair_long_cia"

/datum/sprite_accessory/hair/longbrad
	name = "Braid - Long"
	icon_state = "hair_long_braid"

/datum/sprite_accessory/hair/longemo
	name = "Emo - Long"
	icon_state = "hair_long_emo"

/datum/sprite_accessory/hair/longafrican
	name = "African - Long"
	icon_state = "hair_long_african"

/datum/sprite_accessory/hair/newfashionnitori
	name = "Nitori - New Fashion"
	icon_state = "hair_fash_nitori"

/datum/sprite_accessory/hair/newfashionfujiyabash
	name = "Fujiyabash - New Fashion"
	icon_state = "hair_fash_fujiyabashi"

/datum/sprite_accessory/hair/newfashionkanza
	name = "Kanza - New Fashion"
	icon_state = "hair_fash_kanza"

/datum/sprite_accessory/hair/newfashionmodern
	name = "Modern - New Fashion"
	icon_state = "hair_fash_modern"

/datum/sprite_accessory/hair/newfashionvriska
	name = "Vriska - New Fashion"
	icon_state = "hair_fash_vriska"

/datum/sprite_accessory/hair/newfashion80s
	name = "80s - New Fashion"
	icon_state = "hair_fash_80s"

/datum/sprite_accessory/hair/newfashionsidetail
	name = "Side Tail - New Fashion"
	icon_state = "hair_fash_sidetail"

/datum/sprite_accessory/hair/newfashionrose
	name = "Rose - New Fashion"
	icon_state = "hair_fash_rose"

/datum/sprite_accessory/hair/newfashionshortovereye
	name = "Over Eye - New Fashion"
	icon_state = "hair_fash_shortovereye"

/datum/sprite_accessory/hair/newfashionlongemo
	name = "Long Emo - New Fashion"
	icon_state = "hair_fash_longemo"

/datum/sprite_accessory/hair/newfashiononeemo
	name = "One Emo - New Fashion"
	icon_state = "hair_fash_oneemo"

/datum/sprite_accessory/hair/newfashionhimecut
	name = "Hime Cut - New Fashion"
	icon_state = "hair_fash_himecut"

/datum/sprite_accessory/hair/newfashionhime
	name = "Hime - New Fashion"
	icon_state = "hair_fash_hime"

/datum/sprite_accessory/hair/newfashionlamia
	name = "Lamia - New Fashion"
	icon_state = "hair_fash_lamia"

/datum/sprite_accessory/hair/shortgeisha
	name = "Geisha - Short"
	icon_state = "hair_geisha"

/datum/sprite_accessory/hair/shortmillenium
	name = "Millenium - Short"
	icon_state = "hair_millenium"

/datum/sprite_accessory/hair/shortfridge
	name = "Fridge - Short"
	icon_state = "hair_fridge"

/datum/sprite_accessory/hair/shortkitty
	name = "Kitty - Short"
	icon_state = "hair_kitty"

/datum/sprite_accessory/hair/shortkitty2
	name = "Kitty 2 - Short"
	icon_state = "hair_kitty_2"

/datum/sprite_accessory/hair/shortpear
	name = "Pear - Short"
	icon_state = "hair_pear"

/datum/sprite_accessory/hair/shortspicy
	name = "Spicy - Short"
	icon_state = "hair_spicy"

/datum/sprite_accessory/hair/shortpiggy
	name = "Piggy - Short"
	icon_state = "hair_piggy"

/datum/sprite_accessory/hair/shortmaya
	name = "Maya - Short"
	icon_state = "hair_maya"

/datum/sprite_accessory/hair/shortdolly
	name = "Dolly - Short"
	icon_state = "hair_dolly"

/datum/sprite_accessory/hair/shortelly
	name = "Elly - Short"
	icon_state = "hair_elly"

/datum/sprite_accessory/hair/shortchub
	name = "Chub - Short"
	icon_state = "hair_chub"

/datum/sprite_accessory/hair/shortmonk
	name = "Monk - Short"
	icon_state = "hair_monk"

/datum/sprite_accessory/hair/shortcombf
	name = "Combatant - Short"
	icon_state = "hair_combf"

/datum/sprite_accessory/hair/shortlbangs
	name = "Lbang - Short"
	icon_state = "hair_lbangs"

/datum/sprite_accessory/hair/shortfujisaki
	name = "Fujisaki - Short"
	icon_state = "hair_fujisaki"

/datum/sprite_accessory/hair/shortmorj
	name = "Morj - Short"
	icon_state = "hair_morj"

/datum/sprite_accessory/hair/shortmorj2
	name = "Morj 2 - Short"
	icon_state = "hair_morj_2"

/datum/sprite_accessory/hair/shortgentle
	name = "Gentle - Short"
	icon_state = "hair_gentle"

/datum/sprite_accessory/hair/shortdreads
	name = "Dreads - Short"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/shortafro
	name = "Afro 1 - Short"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/shortafro2
	name = "Afro 2 - Short"
	icon_state = "hair_bigafro"

/datum/sprite_accessory/hair/shortakari
	name = "Akari - Short"
	icon_state = "hair_akari"

/datum/sprite_accessory/hair/shortspiky
	name = "Spiky - Short"
	icon_state = "hair_crono"

/datum/sprite_accessory/hair/shortedgeworth
	name = "Edgeworth - Short"
	icon_state = "hair_edgeworth"

/datum/sprite_accessory/hair/shortdemo
	name = "Demo - Short"
	icon_state = "hair_demo"

/datum/sprite_accessory/hair/shortpixie
	name = "Pixie - Short"
	icon_state = "hair_pixie"

/datum/sprite_accessory/hair/shortgamzee
	name = "Gamzee - Short"
	icon_state = "hair_gamzee"

/datum/sprite_accessory/hair/shortgamzee2
	name = "Gamzee 2 - Short"
	icon_state = "hair_gamzee_2"

/datum/sprite_accessory/hair/shortnepeta
	name = "Nepeta - Short"
	icon_state = "hair_nepeta"

/datum/sprite_accessory/hair/shortkanaya
	name = "Kanaya - Short"
	icon_state = "hair_kanaya"

/datum/sprite_accessory/hair/shortdave
	name = "Dave - Short"
	icon_state = "hair_dave"

/datum/sprite_accessory/hair/shortrosa
	name = "Rosa - Short"
	icon_state = "hair_rosa"

/datum/sprite_accessory/hair/shortfeather1
	name = "Feather 1 - Short"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/shortfeather2
	name = "Feathe 2 - Short"
	icon_state = "hair_feather_2"

/datum/sprite_accessory/hair/shortmessy
	name = "Messy - Short"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/shortprotagonist
	name = "Protagonist - Short"
	icon_state = "hair_protagonist"

/datum/sprite_accessory/hair/shortombre
	name = "Ombre - Short"
	icon_state = "hair_ombre"

/datum/sprite_accessory/hair/shortupdo
	name = "Updo - Short"
	icon_state = "hair_updo"

/datum/sprite_accessory/hair/shortzorg
	name = "Zorg - Short"
	icon_state = "hair_zorg"

/datum/sprite_accessory/hair/shortoxton
	name = "Oxton - Short"
	icon_state = "hair_oxton"

/datum/sprite_accessory/hair/shortobjection
	name = "Objection - Short"
	icon_state = "hair_objection"

/datum/sprite_accessory/hair/shortparted
	name = "Parted - Short"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/shortfringe
	name = "Fringe - Short"
	icon_state = "hair_emofringe"

/datum/sprite_accessory/hair/shortelize
	name = "Elize - Short"
	icon_state = "hair_elize"

/datum/sprite_accessory/hair/shortelize2
	name = "Elize 2 - Short"
	icon_state = "hair_elize_2"

/datum/sprite_accessory/hair/shortschierke
	name = "Schierke - Short"
	icon_state = "hair_schierke"

/datum/sprite_accessory/hair/shortscully
	name = "Scully - Short"
	icon_state = "hair_scully"

/datum/sprite_accessory/hair/shorthamster
	name = "Hamster - Short"
	icon_state = "hair_shorthair2"

/datum/sprite_accessory/hair/shortemo
	name = "Hamber - Short"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/shortcurls
	name = "Curls - Short"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/shortsquare
	name = "Square - Short"
	icon_state = "hair_square"

/datum/sprite_accessory/hair/shortpoofy
	name = "Poofy - Short"
	icon_state = "hair_poofy2"

/datum/sprite_accessory/hair/shortfringetail
	name = "Fringe Tail - Short"
	icon_state = "hair_fringetail"

/datum/sprite_accessory/hair/shortougi
	name = "Ougi - Short"
	icon_state = "hair_ougi"

/datum/sprite_accessory/hair/cotton
	name = "Cotton - Old"
	icon_state = "hair_cotton_hair"

/datum/sprite_accessory/hair/shortdad
	name = "Dad - Short"
	icon_state = "hair_h"

/datum/sprite_accessory/hair/shortdad2
	name = "Dad 2 - Short"
	icon_state = "hair_h2"

/datum/sprite_accessory/hair/shortflattop
	name = "Flat top - Short"
	icon_state = "hair_bigflattop"

/datum/sprite_accessory/hair/shortdubs
	name = "Dubs - Short"
	icon_state = "hair_dubs"

/datum/sprite_accessory/hair/shortdirk
	name = "Dirk - Short"
	icon_state = "hair_dirk"

/datum/sprite_accessory/hair/shortmentalist
	name = "Mentalist - Short"
	icon_state = "hair_mentalist"

/datum/sprite_accessory/hair/shortmulder
	name = "Mulder - Short"
	icon_state = "hair_mulder"

/datum/sprite_accessory/hair/shortvegeta
	name = "Vegeta - Short"
	icon_state = "hair_vegeta"

/datum/sprite_accessory/hair/shortcia
	name = "CIA - Short"
	icon_state = "hair_cia"

/datum/sprite_accessory/hair/shortroxy
	name = "Roxy - Short"
	icon_state = "hair_roxy"

/datum/sprite_accessory/hair/shortquiff
	name = "Quiff - Short"
	icon_state = "hair_quiff"

/datum/sprite_accessory/hair/shorthitop
	name = "Hitop - Short"
	icon_state = "hair_hitop"

/datum/sprite_accessory/hair/shortpompadour
	name = "Pompadour - Short"
	icon_state = "hair_pompadour"

/datum/sprite_accessory/hair/shortvegass
	name = "Vegass - Short"
	icon_state = "hair_part"

/datum/sprite_accessory/hair/shortcombover
	name = "Cowboy - Short"
	icon_state = "hair_combover"

/datum/sprite_accessory/hair/shorta
	name = "Arnold - Short"
	icon_state = "hair_a"

/datum/sprite_accessory/hair/shortjensen
	name = "Jensen - Short"
	icon_state = "hair_jensen"

/datum/sprite_accessory/hair/shortjoestar
	name = "Joestar - Short"
	icon_state = "hair_joestar"

/datum/sprite_accessory/hair/sshortcas
	name = "Cas - Super Short"
	icon_state = "hair_c"

/datum/sprite_accessory/hair/sshortccut
	name = "Crew Cut- Super Short"
	icon_state = "hair_crewcut"

/datum/sprite_accessory/hair/sshortdevil
	name = "Devil - Super Short"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/sshortd
	name = "Dumb - Super Short"
	icon_state = "hair_d"

/datum/sprite_accessory/hair/sshortold
	name = "Old - Super Short"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/sshortleader
	name = "Leader - Super Short"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/sshortgelled
	name = "Gelled - Super Short"
	icon_state = "hair_gelled"

/datum/sprite_accessory/hair/sshortmegaeye
	name = "Megabrows - Super Short"
	icon_state = "hair_megaeyebrows"

/datum/sprite_accessory/hair/sshortreverse
	name = "Reverse - Super Short"
	icon_state = "hair_reversemohawk"

/datum/sprite_accessory/hair/sshortarmy
	name = "Sargeant - Super Short"
	icon_state = "hair_sargeant"

/datum/sprite_accessory/hair/sshortskinhead
	name = "Skinhead - Super Short"
	icon_state = "hair_skinhead"

/datum/sprite_accessory/hair/sshortdanny
	name = "Danny - Super Short"
	icon_state = "hair_spikey"

/datum/sprite_accessory/hair/moviefastline
	name = "Fastline Dandy - Movie"
	icon_state = "hair_fastline"

/datum/sprite_accessory/hair/moviemohawk
	name = "Mohawk Randy - Movie"
	icon_state = "hair_mohawk"

/datum/sprite_accessory/hair/movielfrieng
	name = "Longe Fringe Pirat - Movie"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/movieslmessy
	name = "Slight Messy Tereza 1 - Movie"
	icon_state = "hair_slightlymessy"

/datum/sprite_accessory/hair/movieslmessy2
	name = "Slight Messy Tereza 2 - Movie"
	icon_state = "hair_slightmessy_2"

/datum/sprite_accessory/hair/moviebhair
	name = "Braided Sanny - Movie"
	icon_state = "hair_braided_hair"

/datum/sprite_accessory/hair/moviebhair2
	name = "Braided Sanny 2 - Movie"
	icon_state = "hair_braided_hair_2"

/datum/sprite_accessory/hair/moviewild
	name = "Wild Princess - Movie"
	icon_state = "hair_wild"

/datum/sprite_accessory/hair/moviecostoledo
	name = "Costoledo - Movie"
	icon_state = "hair_costoledo"

/datum/sprite_accessory/hair/movieofficer
	name = "Officer Tacklberry - Movie"
	icon_state = "hair_combed"

/datum/sprite_accessory/hair/moviestar
	name = "Star - Movie"
	icon_state = "hair_star"

/datum/sprite_accessory/hair/rows
	name = "Rows - Gang"
	icon_state = "hair_rows1"

/datum/sprite_accessory/hair/rows2
	name = "Rows 2 - Gang"
	icon_state = "hair_rows2"

/datum/sprite_accessory/hair/rowbun
	name = "Row Bun - Gang"
	icon_state = "hair_rowbun"

/datum/sprite_accessory/hair/Topknot
	name = "Chao Topknot - Gang"
	icon_state = "hair_topknot"

/datum/sprite_accessory/hair/ocelot
	name = "Ocelot - Games"
	icon_state = "hair_ocelot"

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
	species_allowed = list(HUMAN, UNATHI, TAJARAN, SKRELL, VOX, IPC, DIONA, PODMAN, PLUVIAN)

/datum/sprite_accessory/facial_hair/fiveoclock
	name = "Five o'Clock Shadow"
	icon_state = "facial_fiveoclock"

/datum/sprite_accessory/facial_hair/sevenoclock
	name = "Seven o'Clock Shadow"
	icon_state = "facial_sevenoclock"

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

/datum/sprite_accessory/hair/ipc_screen_text // it can be selected by setting text to display
	name = "IPC text screen"
	icon_state = "ipc_text"
	species_allowed = list(IPC)
	ipc_head_compatible = null
	do_colouration = FALSE

/datum/sprite_accessory/hair/ipc_screen_alert
	name = "alert IPC screen"
	icon_state = "ipc_alert"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_aquarium
	name = "aquarium IPC screen"
	icon_state = "ipc_aquarium"
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

/datum/sprite_accessory/hair/ipc_screen_chroma
	name = "chroma IPC screen"
	icon_state = "ipc_chroma"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_coffee
	name = "coffee IPC screen"
	icon_state = "ipc_coffee"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_color_array
	name = "colored IPC screen with an eye"
	icon_state = "ipc_color_array"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_color_array_horizontal
	name = "colored horizontal IPC screen"
	icon_state = "ipc_color_array_horizontal"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_color_array_vertical
	name = "colored vertical IPC screen"
	icon_state = "ipc_color_array_vertical"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_console
	name = "console IPC screen"
	icon_state = "ipc_console"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_dot
	name = "dot IPC screen"
	icon_state = "ipc_dot"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_ecgwave
	name = "ecgwave IPC screen"
	icon_state = "ipc_ecgwave"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_eight
	name = "eight IPC screen"
	icon_state = "ipc_eight"
	species_allowed = list(IPC)
	do_colouration = FALSE
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

/datum/sprite_accessory/hair/ipc_screen_equalizer
	name = "equalizer IPC screen"
	icon_state = "ipc_equalizer"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_four
	name = "four IPC screen"
	icon_state = "ipc_four"
	species_allowed = list(IPC)
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

/datum/sprite_accessory/hair/ipc_screen_mask
	name = "mask IPC screen"
	icon_state = "ipc_mask"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_matrix
	name = "matrix IPC screen"
	icon_state = "ipc_matrix"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_miami
	name = "miami IPC screen"
	icon_state = "ipc_miami"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_microwave
	name = "microwave IPC screen"
	icon_state = "ipc_microwave"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_monoeye
	name = "monoeye IPC screen"
	icon_state = "ipc_monoeye"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_nature
	name = "nature IPC screen"
	icon_state = "ipc_nature"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_noise
	name = "noise IPC screen"
	icon_state = "ipc_noise"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_question
	name = "question IPC screen"
	icon_state = "ipc_question"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_shower
	name = "shower IPC screen"
	icon_state = "ipc_shower"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_sinewave
	name = "sinewave IPC screen"
	icon_state = "ipc_sinewave"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_smiley
	name = "smiley IPC screen"
	icon_state = "ipc_smiley"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_static
	name = "static IPC screen"
	icon_state = "ipc_static"
	species_allowed = list(IPC)
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_cobalt
	name = "cobalt IPC screen"
	icon_state = "ipc_cobalt"
	species_allowed = list(IPC)
	ipc_head_compatible = "Cobalt"

/datum/sprite_accessory/hair/ipc_screen_cathod
	name = "cathod IPC screen"
	icon_state = "ipc_cathod"
	species_allowed = list(IPC)
	ipc_head_compatible = "Cathod"

/datum/sprite_accessory/hair/ipc_screen_thorax
	name = "thorax IPC screen"
	icon_state = "ipc_thorax"
	species_allowed = list(IPC)
	ipc_head_compatible = "Thorax"

/datum/sprite_accessory/hair/ipc_screen_axon
	name = "axon IPC screen"
	icon_state = "ipc_axon"
	species_allowed = list(IPC)
	ipc_head_compatible = "Axon"

/datum/sprite_accessory/hair/ipc_tamagotchi
	name = "tamagotchi IPC screen"
	icon_state = "ipc_tamagotchi"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_television
	name = "TV IPC screen"
	icon_state = "ipc_television"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_tetris
	name = "tetris IPC screen"
	icon_state = "ipc_tetris"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_win
	name = "win IPC screen"
	icon_state = "ipc_win"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_screen_yellow
	name = "yellow IPC screen"
	icon_state = "ipc_yellow"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

/datum/sprite_accessory/hair/ipc_litso
	name = "litso IPC screen"
	icon_state = "ipc_litso"
	species_allowed = list(IPC)
	do_colouration = FALSE
	ipc_head_compatible = "Default"

	//UNATHI HAIRS

/datum/sprite_accessory/hair/una_small_horns
	name = "Small Horny"
	icon_state = "una_small_horns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_faun
	name = "Faunus"
	icon_state = "una_faun"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_bullhorn
	name = "Bully"
	icon_state = "una_bullhorn"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_ram2_horns
	name = "Ramming Horns"
	icon_state = "una_ram2_horns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_chin_horns
	name = "Chin Horns"
	icon_state = "una_chin_horns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_drac_horns
	name = "Drac Horns"
	icon_state = "una_drac_horns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_adorns_horns
	name = "Adorns"
	icon_state = "una_adorns_horns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_spikes_horn
	name = "Spikes"
	icon_state = "una_spikes_horns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_big_horns
	name = "Big Horns"
	icon_state = "una_big_horns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_simple_horns
	name = "Simple Horns"
	icon_state = "una_simple_horns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/facial_hair/una_facial_cobrahood
	name = "Cobra Hood"
	icon_state = "una_facial_cobrahood"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_facial_longdorsal
	name = "Long Dorsal 4"
	icon_state = "una_facial_longdorsal"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/hair/una_ramhorn2
	name = "Ram Horns 2"
	icon_state = "una_ramhorn2"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_demonforward
	name = "Demon Horns"
	icon_state = "una_demonforward"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_chameleon
	name = "Chameleon"
	icon_state = "una_chameleon"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_dubhorns
	name = "Dub Horn"
	icon_state = "una_dubhorns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_faun
	name = "Faun"
	icon_state = "una_faun"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/facial_hair/una_facial_hood
	name = "Hood"
	icon_state = "una_facial_hood"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_facial_shortfrills2
	name = "Short Frills 2"
	icon_state = "una_facial_shortfrills2"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_facial_dracfrills
	name = "Drac Frills Full"
	icon_state = "una_facial_dracfrills"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/hair/unathi_warrior_horns
	name = "Warrior Horns"
	icon_state = "una_warrior_horns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/unathi_smallhorns
	name = "Small Horns"
	icon_state = "una_smallhorns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/unathi_dreads
	name = "Dreads"
	icon_state = "una_dreads"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/unathi_dreads_long
	name = "Long Dreads"
	icon_state = "una_dreads_long"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/unathi_dreads_short
	name = "Short Dreads"
	icon_state = "una_dreads_short"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/unathi_dreads_predator
	name = "Predator Dreads"
	icon_state = "una_dreads_predator"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/unathi_hiss_collinss
	name = "Hiss Collinss"
	icon_state = "una_hiss_collinss"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/unathi_horns_curled
	name = "Curled Horns"
	icon_state = "una_horns_curled"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/unathi_horns_ram
	name = "Ram Horns"
	icon_state = "una_horns_ram"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_spines_long
	name = "Long Unathi Spines"
	icon_state = "una_longspines"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_spines_short
	name = "Short Unathi Spines"
	icon_state = "una_shortspines"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/facial_hair/una_facial_longfrills
	name = "Long Unathi Frills"
	icon_state = "una_facial_longfrills"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/hair/una_frills_short
	name = "Short Unathi Frills"
	icon_state = "una_shortfrills"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/hair/una_horns
	name = "Unathi Horns"
	icon_state = "una_horns"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/facial_hair/una_facial_aquaticfrill
	name = "Aquatic Frills"
	icon_state = "una_facial_aquaticfrills"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_facial_aquaticfrills_webbing
	name = "Aquatic Frills Webbed"
	icon_state = "una_facial_aquaticfrills_webbing"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_facial_shortfrills2
	name = "Short Frills 2"
	icon_state = "una_facial_shortfrills2"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_facial_dracfrills
	name = "Drac Frills"
	icon_state = "una_facial_dracfrills"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_facial_dracfrills_webbing
	name = "Drac Frills Webbed"
	icon_state = "una_facial_dracfrills_webbing"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_facial_sidefrills
	name = "Side Frills"
	icon_state = "una_facial_sidefrills"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/hair/una_demonforward
	name = "Demon Forward"
	icon_state = "una_demonforward"
	species_allowed = list(UNATHI, PODMAN)

/datum/sprite_accessory/facial_hair/una_facial_dorsalfrills
	name = "Dorsa Frills"
	icon_state = "una_facial_dorsalfrills"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_facial_dorsalfrills_webbing
	name = "Dorsa Frills Webbed"
	icon_state = "una_facial_dorsalfrills_webbing"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_facial_dorsalfrill3
	name = "Dorsa Frills 3"
	icon_state = "una_facial_dorsalfrill3"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

/datum/sprite_accessory/facial_hair/una_hipbraid_beads
	name = "Bead"
	icon_state = "una_facial_hipbraid_beads"
	species_allowed = list(UNATHI, PODMAN)
	gender = NEUTER

//SKRELL HAIRS

/datum/sprite_accessory/hair/skr_veryshort_m
	name = "Skrell Very Short Male Tentacles"
	icon_state = "skr_veryshort_m"
	species_allowed = list(SKRELL, PODMAN)
	gender = MALE

/datum/sprite_accessory/hair/skr_long
	name = "Skrell Long Tentacles"
	icon_state = "skr_long"
	species_allowed = list(SKRELL, PODMAN)

/datum/sprite_accessory/hair/skr_verylong_f
	name = "Skrell Very Long Female Tentacles"
	icon_state = "skr_verylong_f"
	species_allowed = list(SKRELL, PODMAN)
	gender = FEMALE

/datum/sprite_accessory/hair/skr_tentacle_m
	name = "Skrell Male Tentacles"
	icon_state = "skr_tentacles_m"
	species_allowed = list(SKRELL, PODMAN)

/datum/sprite_accessory/hair/skr_tentacle_f
	name = "Skrell Female Tentacles"
	icon_state = "skr_tentacles_f"
	species_allowed = list(SKRELL, PODMAN)
	gender = FEMALE

/datum/sprite_accessory/hair/skr_wavy_m
	name = "Skrell Wavy Male Tentacles"
	icon_state = "skr_wavy_m"
	species_allowed = list(SKRELL, PODMAN)
	gender = MALE

/datum/sprite_accessory/hair/skr_wavy_f
	name = "Skrell Wavy Female Tentacles"
	icon_state = "skr_wavy_f"
	species_allowed = list(SKRELL, PODMAN)
	gender = FEMALE

/datum/sprite_accessory/hair/skr_pulledback_m
	name = "Skrell Pulled Back Male Tentacles"
	icon_state = "skr_pulledback_m"
	species_allowed = list(SKRELL, PODMAN)
	gender = MALE

/datum/sprite_accessory/hair/skr_pulledback_f
	name = "Skrell Pulled Back Female Tentacles"
	icon_state = "skr_pulledback_f"
	species_allowed = list(SKRELL, PODMAN)

/datum/sprite_accessory/hair/skr_tentacleovereye_f
	name = "Skrell Female Tentacle Over Eye"
	icon_state = "skr_tentacleovereye_f"
	species_allowed = list(SKRELL, PODMAN)
	gender = FEMALE

/datum/sprite_accessory/hair/skr_tentacleovereye_m
	name = "Skrell Male Tentacle Over Eye"
	icon_state = "skr_tentacleovereye_m"
	species_allowed = list(SKRELL, PODMAN)
	gender = MALE

/datum/sprite_accessory/hair/skr_flipflap
	name = "Skrell Flip-flap Tentacles"
	icon_state = "skr_flipflap"
	species_allowed = list(SKRELL, PODMAN)

/datum/sprite_accessory/hair/taj_ears
	name = "Tajaran Ears"
	icon_state = "taj_ears_plain"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_clean
	name = "Tajara Clean"
	icon_state = "taj_hair_clean"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_bangs
	name = "Tajara Bangs"
	icon_state = "taj_hair_bangs"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_braid
	name = "Tajara Braid"
	icon_state = "taj_hair_tbraid"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_shaggy
	name = "Tajara Shaggy"
	icon_state = "taj_hair_shaggy"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_mohawk
	name = "Tajaran Mohawk"
	icon_state = "taj_hair_mohawk"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_plait
	name = "Tajara Plait"
	icon_state = "taj_hair_plait"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_straight
	name = "Tajara Straight"
	icon_state = "taj_hair_straight"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_long
	name = "Tajara Long"
	icon_state = "taj_hair_long"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_rattail
	name = "Tajara Rat Tail"
	icon_state = "taj_hair_rattail"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_spiky
	name = "Tajara Spiky"
	icon_state = "taj_hair_tajspiky"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_messy
	name = "Tajara Messy"
	icon_state = "taj_hair_messy"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_tailshort
	name = "Tajara Short Tail"
	icon_state = "taj_hair_shorttail"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ears_messylong
	name = "Tajara Long Messy"
	icon_state = "taj_hair_messylong"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_sidebraid
	name = "Tajara Side Braid"
	icon_state = "taj_hair_sidebraid"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ribbons
	name = "Tajara Ribbons"
	icon_state = "taj_hair_ribbons"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_earrings
	name = "Tajara Ear Rings"
	icon_state = "taj_hair_earrings"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_combedback
	name = "Tajara Combed Back"
	icon_state = "taj_hair_combedback"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_tailedbangs
	name = "Tajara Tailed Bangs"
	icon_state = "taj_hair_tailedbangs"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_punk
	name = "Tajara Punk"
	icon_state = "taj_hair_punk"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_marmalade
	name = "Tajara Marmalade"
	icon_state = "taj_hair_marmalade"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_lynx
	name = "Tajara Lynx"
	icon_state = "taj_hair_lynx"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_longtail
	name = "Tajara Long Tail"
	icon_state = "taj_hair_longtail"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_shy
	name = "Tajara Shy"
	icon_state = "taj_hair_shy"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_metal
	name = "Tajara Metal"
	icon_state = "taj_hair_metal"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_ponytail
	name = "Tajara Ponytail"
	icon_state = "taj_hair_ponytail"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_overeye
	name = "Tajara Over Eye"
	icon_state = "taj_hair_overeye"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_tough
	name = "Tajara Tough"
	icon_state = "taj_hair_tough"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_cuttail
	name = "Tajara Cut Tail"
	icon_state = "taj_hair_cuttail"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/taj_dreadlocks
	name = "Tajara Dreadlocks"
	icon_state = "taj_hair_dreadlocks"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/tajbun
	name = "Tajara Bun."
	icon_state = "taj_hair_bun"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/tajtail
	name = "Tajara Tail."
	icon_state = "taj_hair_tail"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/vox_quills_short
	name = "Short Vox Quills"
	icon_state = "vox_shortquills"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_punk
	name = "Punk Razor"
	icon_state = "vox_punk"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_razor
	name = "Big Knife"
	icon_state = "vox_razor"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_kingly
	name = "Kingly"
	icon_state = "vox_kingly"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_bayonet
	name = "Bayonet"
	icon_state = "vox_bayonet"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_rome
	name = "Rome Razor"
	icon_state = "vox_rome"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_kinglyq
	name = "Kingly Quills"
	icon_state = "vox_kinglyq"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_whip
	name = "Whip Quills"
	icon_state = "vox_whip"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_long
	name = "Long Quills"
	icon_state = "vox_long"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_classic
	name = "Classic Quills"
	icon_state = "vox_classic"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_dreads
	name = "Vox Dreads"
	icon_state = "vox_dreads"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_long_dreads
	name = "Vox Long Dreads"
	icon_state = "vox_long_dreads"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/hair/vox_king_dreads
	name = "Vox Kingly Dreads"
	icon_state = "vox_kingly_dreads"
	species_allowed = list(VOX, PODMAN)

/datum/sprite_accessory/facial_hair/taj_sideburns
	name = "Tajara Sideburns"
	icon_state = "taj_facial_sideburns"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/facial_hair/taj_mutton
	name = "Tajara Mutton"
	icon_state = "taj_facial_mutton"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/facial_hair/taj_pencilstache
	name = "Tajara Pencilstache"
	icon_state = "taj_facial_pencilstache"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/facial_hair/taj_moustache
	name = "Tajara Moustache"
	icon_state = "taj_facial_moustache"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/facial_hair/taj_goatee
	name = "Tajara Goatee"
	icon_state = "taj_facial_goatee"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/facial_hair/taj_smallstache
	name = "Tajara Smallsatche"
	icon_state = "taj_facial_smallstache"
	species_allowed = list(TAJARAN, PODMAN)

/datum/sprite_accessory/hair/dio_bloom
	name = "Diona Everbloom"
	icon_state = "dio_bloom"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_rose
	name = "Diona Rose"
	icon_state = "dio_rose"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_king
	name = "Diona Flowerking"
	icon_state = "dio_king"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_vines
	name = "Diona Vines Short"
	icon_state = "dio_vines"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_vinel
	name = "Diona Vines Long"
	icon_state = "dio_vinel"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_lotus
	name = "Diona Lotus"
	icon_state = "dio_lotus"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_palm
	name = "Diona Palmhead"
	icon_state = "dio_palm"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_garland
	name = "Diona Garland"
	icon_state = "dio_garland"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_shrub
	name = "Diona Shrub"
	icon_state = "dio_shrub"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_ficus
	name = "Diona Ficus"
	icon_state = "dio_ficus"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_rosey
	name = "Diona Rosey"
	icon_state = "dio_rosey"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_oak
	name = "Diona Oak"
	icon_state = "dio_oak"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_sprout
	name = "Diona Sprout"
	icon_state = "dio_sprout"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_leafy
	name = "Diona Leafy"
	icon_state = "dio_leafy"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)


/datum/sprite_accessory/hair/dio_meadow
	name = "Diona Meadow"
	icon_state = "dio_meadow"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_laurel
	name = "Diona Laurel"
	icon_state = "dio_laurel"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_root
	name = "Diona Root"
	icon_state = "dio_root"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_spinner
	name = "Diona Spinner"
	icon_state = "dio_spinner"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_bracket
	name = "Diona Bracket"
	icon_state = "dio_bracket"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_vine
	name = "Diona Vines"
	icon_state = "dio_vine"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_wildflower
	name = "Diona Wild Flowers"
	icon_state = "dio_wildflower"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_cornflower
	name = "Diona Cornflowers"
	icon_state = "dio_cornflower"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)

/datum/sprite_accessory/hair/dio_brush
	name = "Diona Brush"
	icon_state = "dio_brush"
	do_colouration = FALSE
	species_allowed = list(DIONA, PODMAN)
