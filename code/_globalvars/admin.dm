// Stores a list of ckeys exempted from a stickyban (workaround for a bug)
var/global/list/stickyban_admin_exemptions = list()
// Stores the entire stickyban list temporarily
var/global/list/stickyban_admin_texts = list()
// Stores the timerid of the callback that restores all stickybans after an admin joins
// Run /proc/restore_stickybans
var/global/stickyban_admin_exemption_timer_id