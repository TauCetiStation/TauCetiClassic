// Atheism, the religion of course *confused smiley*.
#define DEFAULT_RELIGION_NAMES list( \
		"Christianity", \
		"Satanism", \
		"Yog'Sotherie", \
		"Islam", \
		"Scientology", \
		"Chaos", \
		"Imperium", \
		"Toolboxia", \
		"Science", \
		"Technologism", \
		"Clownism", \
		"Buddhism", \
		"Atheism", \
	)

//Holy role of chaplain
#define HOLY_ROLE_PRIEST 1 //default priestly role
#define HOLY_ROLE_HIGHPRIEST 2 //the one who designates the religion

//Holy role of cultists
#define CULT_ROLE_HIGHPRIEST 2 //the one who designates the religion
#define CULT_ROLE_MASTER 3 //the one who designates the cult

//Apect defines
//Other informations about aspect in aspect.dm
#define ASPECT_DEATH          "Mortem"
#define ASPECT_SCIENCE        "Progressus"
#define ASPECT_FOOD           "Fames"
#define ASPECT_WEAPON         "Telum"
#define ASPECT_RESOURCES      "Metallum"
#define ASPECT_SPAWN          "Partum"
#define ASPECT_FLAGELLATION   "Cruciatu"
#define ASPECT_RESCUE         "Salutis"
#define ASPECT_MYSTIC         "Spiritus"
#define ASPECT_TECH           "Arsus"
#define ASPECT_CHAOS          "Chaos"
#define ASPECT_WACKY          "Rabidus"
#define ASPECT_ABSENCE        "Absentia"
#define ASPECT_OBSCURE        "Obscurum"
#define ASPECT_LIGHT          "Lux"
#define ASPECT_GREED          "Lucrum"
#define ASPECT_HERD           "Turbam"

// Items below this gain are considered "pity" by the deity.
#define MIN_FAVOUR_GAIN 20

// Religion Techs
#define RTECH_MEMORIZE_RUNE         "Memorize Rune"
#define RTECH_REUSABLE_RUNE         "Reusable Rune"
#define RTECH_BUILD_EVERYWHERE      "Build Everywhere"
#define RTECH_MORE_RUNES            "More Runes"
#define RTECH_MIRROR_SHIELD         "Mirror Shield"
