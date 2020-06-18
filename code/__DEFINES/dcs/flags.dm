/// Return this from `/datum/component/Initialize` or `datum/component/OnTransfer` to have the component be deleted if it's applied to an incorrect type.
/// `parent` must not be modified if this is to be returned.\
/// This will be noted in the runtime logs
#define COMPONENT_INCOMPATIBLE 1
/// Return this from `/datum/component/Initialize` or `datum/component/OnTransfer` to have the component be deleted if it for any reason can not be applied.
/// This will not be noted in the runtime logs.
#define COMPONENT_NOT_ATTACHED 2

// How multiple components of the exact same type are handled in the same datum

/// old component is deleted (default)
#define COMPONENT_DUPE_HIGHLANDER      0
/// duplicates allowed
#define COMPONENT_DUPE_ALLOWED         1
/// new component is deleted
#define COMPONENT_DUPE_UNIQUE          2
/// old component is given the initialization args of the new
#define COMPONENT_DUPE_UNIQUE_PASSARGS 4
