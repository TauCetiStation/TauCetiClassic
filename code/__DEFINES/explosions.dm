// The severity of explosions. Why are these inverted? Only the ancestors know and that's not a fact
#define EXPLODE_DEVASTATE 1 /// The (current) highest possible explosion severity.
#define EXPLODE_HEAVY     2 /// The (current) middling explosion severity.
#define EXPLODE_LIGHT     3 /// The (current) lowest possible explosion severity.
#define EXPLODE_NONE      0 /// The default explosion severity used to mark that an object is beyond the impact range of the explosion.

// Explosion Subsystem subtasks
#define SSEXPLOSIONS_MOVABLES 1
#define SSEXPLOSIONS_TURFS 2
#define SSEXPLOSIONS_THROWS 3
