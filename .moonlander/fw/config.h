/*
  Set any config.h overrides for your specific keymap here.
  See config.h options at https://docs.qmk.fm/#/config_options?id=the-configh-file
*/
#define ORYX_CONFIGURATOR
#undef DEBOUNCE
#define DEBOUNCE 5

#define ONESHOT_TAP_TOGGLE 2

#undef ONESHOT_TIMEOUT
#define ONESHOT_TIMEOUT 755

// https://docs.qmk.fm/#/tap_hold
#define TAPPING_TERM 200        // def
#define TAPPING_TERM_PER_KEY    // allow changing per key
#define PERMISSIVE_HOLD_PER_KEY // break TAPPING_TERM, when a.down b.down b.up a.down
#define IGNORE_MOD_TAP_INTERRUPT_PER_KEY
#define TAPPING_FORCE_HOLD_PER_KEY
#define RETRO_TAPPING_PER_KEY

#undef RGB_DISABLE_TIMEOUT
#define RGB_DISABLE_TIMEOUT 300000 // 5 mins

#define USB_SUSPEND_WAKEUP_DELAY 0
#define RGB_MATRIX_STARTUP_SPD 60

#ifndef AUDIO_ENABLE
#	define AUDIO_ENABLE
#endif

#define AUDIO_ENABLE_TONE_MULTIPLEXING
#define AUDIO_TONE_MULTIPLEXING_RATE_DEFAULT 10

#ifdef AUDIO_ENABLE
#	define STARTUP_SONG SONG(ALL_STAR)
#endif



#define x16(pre, keycode) pre##_code16(keycode)
// key down
#define d(keycode) x16(register, keycode)
// key up
#define u(keycode) x16(unregister, keycode)
// key tap
#define t(keycode) x16(tap, keycode)
#define xx(fn) x; x;

#define LEN(x) sizeof x / sizeof x[0]
#define CASE(x,y) case x: y; break;

#define TAP1(f) CASE(SINGLE_TAP,        f)
#define TAP2(f) CASE(DOUBLE_TAP,        f)
#define TTAP(f) CASE(DOUBLE_SINGLE_TAP, f)
// no, I am not mad at myself for this pun! *shut* *shut*
#define HOLD(f) CASE(SINGLE_HOLD,       f)
#define H1LD(f) CASE(DOUBLE_HOLD,       f)


#define DANCE_ARGS (qk_tap_dance_state_t *state, void *user_data)
// dumb/advanced dance behavior
#define DUNCE(num, enable, disable) \
	void dance_##num##_finished DANCE_ARGS;  \
	void dance_##num##_reset    DANCE_ARGS;  \
	void dance_##num##_finished DANCE_ARGS { \
		dance_state[num].step = dance_step(state); \
		switch (dance_state[num].step) { enable } \
	} \
	void dance_##num##_reset    DANCE_ARGS { \
		wait_ms(10); \
		switch (dance_state[num].step) { disable } \
		dance_state[num].step = 0; \
	}
// smart/basic dance behavior
#define DANCE(num, tap, enable, disable) \
	void on_dance_##num         DANCE_ARGS;  \
	void on_dance_##num         DANCE_ARGS { \
		if(state->count == 3) { \
			t(tap); \
			t(tap); \
			t(tap); \
		} \
		if(state->count > 3) { \
			t(tap); \
		} \
	} \
	DUNCE(num, TAP1(d(tap)) enable, TAP1(u(tap)) disable)

#define SIMPLE3(num, one, two, three) \
	DANCE(num, one, \
		HOLD(d(one)) \
		TAP2(d(two)) \
		H1LD(d(three)) \
		TTAP(t(one); d(one)) \
		, \
		HOLD(u(one)) \
		TAP2(u(two)) \
		H1LD(u(three)) \
		TTAP(u(one)) \
	)
#define SIMPLE2(num, one, two) \
DANCE(num, one, \
	HOLD(d(two)) \
	TAP2(d(one)) \
	TTAP(t(one); d(one)) \
	, \
	HOLD(u(two)) \
	TAP2(u(one)) \
	TTAP(u(one)) \
)
#define SIMPLE2_ALT(num, one, two) \
	DANCE(num, one, \
		HOLD(d(two)) \
		TAP2(d(two)) \
		H1LD(d(two)) \
		TTAP(t(one); d(one)) \
		, \
		HOLD(u(two)) \
		TAP2(u(two)) \
		H1LD(u(two)) \
		TTAP(u(one)) \
	)
#define SAFETY(num, key) \
	DUNCE(num, \
		HOLD(d(key)) \
		TAP2(d(key)) \
		, \
		HOLD(u(key)) \
		TAP2(u(key)) \
	)
#define TAP_HOLD(num, tap, hold) \
	DANCE(num, tap, \
		HOLD(d(hold)) \
		, \
		HOLD(u(hold)) \
	)


// yes, punother one
#define AVDANCE(num, on, finish, reset) \
	[num] = ACTION_TAP_DANCE_FN_ADVANCED( \
		on(on_dance_##num), \
		finish(dance_##num##_finished), \
		reset(dance_##num##_reset) \
	)

#define XX XXXXXXX
#define    XXX XX
#define    XXXX XX
#define    XXXXX XX
#define    XXXXXX XX
#define _ _______
#define   __ _
#define   ___ _
#define   ____ _
#define   _____ _
#define   ______ _


