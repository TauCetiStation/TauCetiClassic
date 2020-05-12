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

	// Extra powers:
//#define SHADOW			11 	// shadow teleportation (create in/out portals anywhere) (25%)
//#define SCREAM			12 	// supersonic screaming (25%)
//#define EXPLOSIVE		13 	// exploding on-demand (15%)
//#define REGENERATION	14 	// superhuman regeneration (30%)
//#define REPROCESSOR		15 	// eat anything (50%)
//#define SHAPESHIFTING	16 	// take on the appearance of anything (40%)
//#define PHASING			17 	// ability to phase through walls (40%)
//#define SHIELD			18 	// shielding from all projectile attacks (30%)
//#define SHOCKWAVE		19 	// attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
//#define ELECTRICITY		20 	// ability to shoot electric attacks (15%)
//bitflags for mutations
	// Extra powers:
#define SHADOW			(1<<10)	// shadow teleportation (create in/out portals anywhere) (25%)
#define SCREAM			(1<<11)	// supersonic screaming (25%)
#define EXPLOSIVE		(1<<12)	// exploding on-demand (15%)
#define REGENERATION	(1<<13)	// superhuman regeneration (30%)
#define REPROCESSOR		(1<<14)	// eat anything (50%)
#define SHAPESHIFTING	(1<<15)	// take on the appearance of anything (40%)
#define PHASING			(1<<16)	// ability to phase through walls (40%)
#define SHIELD			(1<<17)	// shielding from all projectile attacks (30%)
#define SHOCKWAVE		(1<<18)	// attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
#define ELECTRICITY		(1<<19)	// ability to shoot electric attacks (15%)

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
