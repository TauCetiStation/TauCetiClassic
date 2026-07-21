// Edicts ("указы") are persistent, cross-round station laws stored in the `edicts` DB table.
// Each define here is a unique edict key and MUST be registered in global.available_edicts.
#define EDICT_CARGO_GUARD "cargo_guard"

// How long after round start the QM may request the Cargo Guard edict from the QM console.
#define CARGO_GUARD_REQUEST_WINDOW (15 MINUTES)

// The edict cannot be created or changed with fewer than this many living players present.
#define CARGO_GUARD_MIN_POP 20

// Credits per active guard slot that must sit on the cargo account at round end. To maintain N
// guards you hold N * this; to grow to N+1 you hold (N+1) * this.
#define CARGO_GUARD_PRICE 10000

// Maximum number of Cargo Guard slots the edict can ever scale up to.
#define CARGO_GUARD_MAX 4
