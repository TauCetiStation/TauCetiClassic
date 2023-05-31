
//These are all the different status effects. Use the paths for each effect in the defines.

#define STATUS_EFFECT_MULTIPLE 0 // if it allows multiple instances of the effect

#define STATUS_EFFECT_UNIQUE   1 // if it allows only one, preventing new instances

#define STATUS_EFFECT_REPLACE  2 // if it allows only one, but new instances replace

#define STATUS_EFFECT_REFRESH  3 // if it only allows one, and new instances just instead refresh the timer

///////////
// BUFFS //
///////////

#define STATUS_EFFECT_SWARMS_GIFT /datum/status_effect/swarm_gift

/////////////
// DEBUFFS //
/////////////

#define STATUS_EFFECT_SLEEPING /datum/status_effect/incapacitating/sleeping //the affected is asleep

#define STATUS_EFFECT_STASIS_BAG /datum/status_effect/incapacitating/stasis_bag // Halts biological functions like bleeding, chemical processing, blood regeneration, etc

#define STATUS_EFFECT_REMOVE_WET /datum/status_effect/remove_trait/wet_hands

#define STATUS_EFFECT_REMOVE_GREASY /datum/status_effect/remove_trait/greasy_hands

#define STATUS_EFFECT_CLUMSY /datum/status_effect/clumsy

/////////////
// NEUTRAL //
/////////////

#define STATUS_EFFECT_ARRAY_TURN_BACK /datum/status_effect/array_turn_back

// Stasis helpers

#define IS_IN_STASIS(mob) (mob.has_status_effect(STATUS_EFFECT_STASIS_BAG))
