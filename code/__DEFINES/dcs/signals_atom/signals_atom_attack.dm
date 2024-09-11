/// from /atom/proc/atom_break: (damage_flag)
#define COMSIG_ATOM_BREAK "atom_break"
/// from base of [/atom/proc/atom_fix]: ()
#define COMSIG_ATOM_FIX "atom_fix"
/// from base of [/atom/proc/atom_destruction]: (damage_flag)
#define COMSIG_ATOM_DESTRUCTION "atom_destruction"
///from base of [/atom/proc/update_integrity]: (old_value, new_value)
#define COMSIG_ATOM_INTEGRITY_CHANGED "atom_integrity_changed"
///from base of [/atom/proc/take_damage]: (damage_amount, damage_type, damage_flag, sound_effect, attack_dir, aurmor_penetration)
#define COMSIG_ATOM_TAKE_DAMAGE "atom_take_damage"
	/// Return bitflags for the above signal which prevents the atom taking any damage.
	#define COMPONENT_NO_TAKE_DAMAGE (1<<0)
