// mob/var/list/mutations
//"#49e46e
#define STRUCDNASIZE 27
#define UNIDNASIZE 	 13

	// Generic mutations:
#define	TK				1
#define COLD_RESISTANCE	2
#define XRAY			3
#define HULK			4
#define CLUMSY			5
#define HUSK			6
#define NOCLONE			7
#define LASEREYES		8 	// harm intent - click anywhere to shoot lasers from eyes

// Other Mutations:
#define NO_BREATH		100 	// no need to breathe
#define REMOTE_VIEW		101 	// remote viewing
#define REGEN			102 	// health regen
#define RUN				103 	// no slowdown
#define REMOTE_TALK		104 	// remote talking
#define MORPH			105 	// changing appearance
#define BLEND			106 	// nothing (seriously nothing)
#define HALLUCINATE		107 	// hallucinations
#define FINGERPRINTS	108 	// no fingerprints
#define NO_SHOCK		109 	// insulated hands
#define SMALLSIZE		110 	// table climbing
#define RESIST_HEAT		111 	// Heat-resistance #Z2

//Hulk activators
#define ACTIVATOR_HEAVY_MUSCLE_LOAD "heavy muscle load"
#define ACTIVATOR_ELECTRIC_SHOCK "electric shock"
#define ACTIVATOR_VOMITING "vomiting"
#define ACTIVATOR_BROKEN_BONE "broken bone"
#define ACTIVATOR_EMITTER_BEAM "emitter beam"

#define HULK_ACTIVATION_OPTIONS list(ACTIVATOR_HEAVY_MUSCLE_LOAD, ACTIVATOR_ELECTRIC_SHOCK, ACTIVATOR_VOMITING, ACTIVATOR_BROKEN_BONE, ACTIVATOR_EMITTER_BEAM)

//disabilities
#define NEARSIGHTED		1
#define EPILEPSY		2
#define COUGHING		4
#define TOURETTES		8
#define NERVOUS			16

//sdisabilities
#define BLIND			1
#define MUTE			2
#define DEAF			4

#define MUTCHK_FORCED        1
