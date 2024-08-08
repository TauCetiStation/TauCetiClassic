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
#define ASPECT_RESCUE         "Salutis"
#define ASPECT_MYSTIC         "Spiritus"
#define ASPECT_TECH           "Arsus"
#define ASPECT_CHAOS          "Chaos"
#define ASPECT_WACKY          "Rabidus"
#define ASPECT_OBSCURE        "Obscurum"
#define ASPECT_LIGHT          "Lux"
#define ASPECT_GREED          "Lucrum"

// Items below this gain are considered "pity" by the deity.
#define MIN_FAVOUR_GAIN 20

// Religion Techs
#define RTECH_MEMORIZE_RUNE         "Memorize Rune"
#define RTECH_REUSABLE_RUNE         "Reusable Rune"
#define RTECH_BUILD_EVERYWHERE      "Build Everywhere"
#define RTECH_MORE_RUNES            "More Runes"
#define RTECH_MIRROR_SHIELD         "Mirror Shield"
#define RTECH_IMPROVED_PYLONS       "Improved Pylons"

/*
 * ENCYCLOPEDIA
 */

// Categories
#define RITES_CAT        "RITES"
#define SECTS_CAT        "SECTS"
#define ASPECTS_CAT      "ASPECTS"
#define GOD_SPELLS_CAT   "GOD SPELLS"
#define HOLY_REAGS_CAT   "HOLY REAGENTS"
#define FAITH_REACTS_CAT "FAITH REACTIONS"

// Rites info
#define RITE_NAME        "name"
#define RITE_DESC        "desc"
#define RITE_TIPS        "tips"
#define RITE_LENGTH      "ritual_length"
#define RITE_FAVOR       "favor_cost"
#define RITE_PIETY       "piety_cost"
#define RITE_ASPECTS     "needed_aspects"
#define RITE_TALISMANED  "can_talismaned"
#define RITE_PATH        "path"

// Sects info
#define SECT_NAME      "name"
#define SECT_DESC      "desc"
#define SECT_PRESET    "aspect_preset"
#define SECT_ASP_COUNT "aspects_count"
#define SECT_PATH      "path"

// Aspect info
#define ASP_NAME       "name"
#define ASP_DESC       "desc"
#define ASP_GOD_DESC   "god_desc"
#define ASP_COLOR      "color"

// Spell info
#define SPELL_NAME    "name"
#define SPELL_COST    "favor_cost"
#define SPELL_CD      "charge_max"
#define SPELL_ASPECTS "needed_aspects"

// Holy reagents info
#define REAGENT_NAME    "name"
#define REAGENT_ASPECTS "needed_aspects"

// Faith reactions info
#define REACTION_CONVERTABLE "convertable_id"
#define REACTION_RESULT      "result_id"
#define REACITON_COST        "favor_cost"
#define REACTION_ASPECTS     "needed_aspects"
