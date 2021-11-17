//env qmk compile #
/* Copyright 2020 ZSA Technology Labs, Inc <@zsa>
 * Copyright 2020 Jack Humbert <jack.humb@gmail.com>
 * Copyright 2020 Christopher Courtney, aka Drashna Jael're  (@drashna) <drashna@live.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// // // // // // // // //  THIS IS OF BETA-QUALITY // // // // // // // // //

/*
 * I have not ran this particular build on my moonlander (yet)
 * This was merely an attempt to transition the generated version from Oryx to
 * pure QMK. I want to reduce my reliance on that tool, cool though it may be.
 * There's also a slow feature roll-out, and Oryx's closed-source... :eek:
 * I want some home-row mods!!!!!
 *
 * Therefore, if you royally F something up,
 * I take absolutely NO responsibility.
 */


/**/
#include QMK_KEYBOARD_H
#include "version.h"
#include "keymap_us_international.h"

//#include "keymap_contributions.h"

#include "keymap_german.h"
//#include "keymap_nordic.h"
#include "keymap_french.h"
#include "keymap_spanish.h"
#include "keymap_hungarian.h"
#include "keymap_swedish.h"
#include "keymap_br_abnt2.h"
#include "keymap_canadian_multilingual.h"
#include "keymap_german_ch.h"
#include "keymap_jp.h"
#include "keymap_korean.h"
#include "keymap_bepo.h"
#include "keymap_italian.h"
#include "keymap_slovenian.h"
#include "keymap_lithuanian_azerty.h"
#include "keymap_danish.h"
//#include "keymap_norwegian.h"
#include "keymap_portuguese.h"
#include "keymap_czech.h"
#include "keymap_romanian.h"
#include "keymap_russian.h"
#include "keymap_uk.h"
#include "keymap_estonian.h"
#include "keymap_belgian.h"
/**/

#define moon_led_level LED_LEVEL



enum custom_keycodes
	{ VRSN = ML_SAFE_RANGE
	, rgb_sld = ML_SAFE_RANGE
	, hsv_105_255_255
	, hsv_249_228_255
	, hsv_35_255_255
	, hsv_14_255_255
	};


enum layers
	{ DEF  // normal usage
	, US1  // QWERTY
	, VIM  // vim keys and symbols
	, NUM  // numpad
	, US2  // QWERTY gaming
	//COL  // colors, mapped atop numpad and numrow
	, DBL  // dual   gaming
	, MUS  // music mode
	, LAYERS  // cheap LEN
	};

enum
	{ SINGLE_TAP = 1
	, SINGLE_HOLD
	, DOUBLE_TAP
	, DOUBLE_HOLD
	, DOUBLE_SINGLE_TAP
	, MORE_TAP
	};

enum tap_dance_codes
	{ LOCK
	, LVOL
	, ESCT
	, RVOL
	, PLAY
	//METAN
	//DANCE_911
	, DANCES  // cheap LEN
	};

#define OS(mod) OSM(MOD_##mod)
#define MM(mod,key) MT(MOD_##mod, key)
#define LS LSFT
#define MOD_LS KC_LSFT
#define L LAYOUT_moonlander


#define HYTAB MM(HYPR, KC_TAB)


//const uint16_t PROGMEM
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
	[DEF] = L(
	/*
		_______,  _______,  _______,  _______,  _______,  _______,  _______,          _______,  _______,  _______,  _______,  _______,  _______,  _______,
		_______,  _______,  _______,  _______,  _______,  _______,  _______,          _______,  _______,  _______,  _______,  _______,  _______,  _______,
		_______,  _______,  _______,  _______,  _______,  _______,  _______,          _______,  _______,  _______,  _______,  _______,  _______,  _______,
		_______,  _______,  _______,  _______,  _______,  _______,                              _______,  _______,  _______,  _______,  _______,  _______,
		_______,  _______,  _______,  _______,  _______,            _______,          _______,            _______,  _______,  _______,  _______,  _______,
		                                        _______,  _______,  _______,          _______,  _______,  _______
	*/
		KC_GRAVE,    KC_1,     KC_2,     KC_3,     KC_4,     KC_5, TD(LOCK),         OS(LGUI),     KC_6,     KC_7,     KC_8,     KC_9,     KC_0,   KC_DEL,
		HYTAB,       KC_Q,     KC_W,     KC_F,     KC_P,     KC_G, LS(KC_HOME),    LS(KC_END),     KC_J,     KC_L,     KC_U,     KC_Y,KC_SCOLON,KC_BSPACE,
		KC_BSPACE,LCTL_T(KC_A),LSFT_T(KC_R),LALT_T(KC_S),LGUI_T(KC_T),KC_D,KC_HOME,    KC_END,KC_H,LGUI_T(KC_N),LALT_T(KC_E),LSFT_T(KC_I),LCTL_T(KC_O), KC_QUOTE,
		KC_LCTRL,    KC_Z,    KC_X,      KC_C,     KC_V,     KC_B,                                 KC_K,     KC_M, KC_COMMA,   KC_DOT, KC_SLASH,KC_BSLASH,
		OS(LS),  KC_PGUP,  KC_PGDOWN,  KC_LALT,  KC_LGUI,                  TD(LVOL),TD(RVOL),       MO(VIM), OS(LCTL),LCTL(KC_PGUP),LCTL(KC_PGDN),TO(US1),
		                                                 KC_SPACE ,TD(ESCT),_______,_______,KC_ENTER,KC_RSHIFT
	),
	[US1] = L(
		KC_ESCAPE,  _______, _______, _______, _______, _______, KC_6,  TO(DEF),  _______, _______, _______, _______, _______, KC_DELETE,  
		KC_TAB,  KC_Q,  KC_W,  KC_E,  KC_R,  KC_T,  KC_Y,  TO(DBL),  KC_Y,  KC_U,  KC_I,  KC_O,  KC_P,  KC_BSPACE,  
		KC_LSHIFT,  KC_A,  KC_S,  KC_D,  KC_F,  KC_G,  KC_H,  TO(US2),  KC_H,  KC_J,  KC_K,  KC_L,  KC_SCOLON,  KC_RSHIFT,  
		KC_LCTRL,  KC_Z,  KC_X,  KC_C,  KC_V,  KC_B,  KC_N,  KC_M,  _______, _______, _______, KC_RCTRL,  
		OSL(VIM),  KC_LGUI,  KC_ESCAPE,  KC_ESCAPE,  KC_SPACE,  _______,  _______, KC_SPACE,  KC_RSHIFT,  KC_RCTRL,  KC_LALT,  TO(DEF),  
		KC_SPACE,  KC_SPACE,  XXXXXXX,  XXXXXXX,  KC_ENTER,  KC_SPACE
	),
	[VIM] = L(
		TO(MUS),  KC_F1,  KC_F2,  KC_F3,  KC_F4,  KC_F5,  XXXXXXX,  moon_led_level, KC_F6,  KC_F7,  KC_F8,  KC_F9,  KC_F10,  KC_F11,  
		XXXXXXX,    KC_ESC,  KC_GRAVE,  KC_MS_BTN1,  KC_MS_BTN2,  KC_MS_BTN3,  MO(NUM),  KC_MS_WH_UP,    KC_TILD,  KC_MINUS,  KC_EQUAL,  KC_BSPACE,  KC_DELETE,  KC_F12,  
		KC_LALT,  KC_LCTRL,  KC_LSHIFT,  KC_TAB,  MO(NUM),  KC_MS_WH_UP,    MO(NUM),  KC_MS_WH_DOWN,  KC_LEFT,  KC_DOWN,  KC_UP,  KC_RIGHT,  KC_COLN,  KC_RCTRL,  
		KC_LALT,  LSFT_T(KC_LBRACKET),RSFT_T(KC_RBRACKET),RALT(XXXXXXX),    KC_PSCREEN,  KC_MS_WH_DOWN,  TD(PLAY),   KC_ENTER,  _______, KC_LSPO,  KC_RSPC,  _______, 
		KC_LALT,  KC_LCTRL,  KC_LSHIFT,  KC_LALT,  KC_LGUI,  KC_BRIGHTNESS_DOWN,  KC_BRIGHTNESS_UP,_______, TO(NUM),  XXXXXXX,  XXXXXXX,  XXXXXXX,  
		_______, _______, _______,          _______, _______, RSFT_T(KC_SPACE)
	),
	[NUM] = L(
		_______, _______, _______, _______, _______, _______, XXXXXXX,  _______, _______, _______, KC_SLASH,  KC_ASTR,  KC_MINUS,  _______, 
		_______, _______, _______, RGB_SPD,  RGB_SPI,  _______, _______,  _______, _______, KC_7,  KC_8,  KC_9,  KC_MINUS,  _______, 
		_______, hsv_105_255_255,hsv_249_228_255,hsv_35_255_255, _______, hsv_14_255_255, _______,  _______, KC_0,  KC_4,  KC_5,  KC_6,  KC_PLUS,  KC_RSHIFT,  
		_______, _______, _______, _______, TOGGLE_LAYER_COLOR,RGB_MOD,  KC_ENTER,  KC_1,  KC_2,  KC_3,  KC_ENTER,  KC_RCTRL,  
		_______, _______, _______, _______, _______, KC_BRIGHTNESS_DOWN,  KC_BRIGHTNESS_UP,KC_0,  TO(DEF),  KC_DOT,  KC_EQUAL,  KC_LALT,  
		_______, _______, _______,  _______, _______, KC_RSHIFT
	),
	[US2] = L(
		TO(DEF),  KC_ESCAPE,  KC_5,  KC_1,  KC_2,  KC_3,  KC_4,  TO(DEF),  _______, _______, _______, _______, _______, KC_DELETE,  
		TO(DBL),  KC_TAB,  KC_Q,  KC_W,  KC_E,  KC_R,  KC_T,  TO(DBL),  KC_Y,  KC_U,  KC_I,  KC_O,  KC_P,  KC_BSPACE,  
		TO(US1),  KC_LSHIFT,  KC_A,  KC_S,  KC_D,  KC_F,  KC_G,  TO(US1),  KC_H,  KC_J,  KC_K,  KC_L,  KC_SCOLON,  KC_RSHIFT,  
		KC_Z,  KC_LCTRL,  KC_X,  KC_C,  KC_V,  KC_B,  KC_N,  KC_M,  KC_COMMA,  KC_DOT,  KC_SLASH,  KC_RCTRL,  
		KC_LGUI,  KC_LALT,  KC_ESCAPE,  KC_ESCAPE,  KC_SPACE,  _______,  _______, KC_SPACE,  KC_RSHIFT,  KC_RCTRL,  KC_LALT,  TO(DEF),  
		KC_SPACE,  KC_SPACE,  _______,  _______, _______, KC_SPACE
	),
	[DBL] = L(
		KC_ESCAPE,  KC_ESCAPE,  _______, _______, _______, _______, XXXXXXX,  TO(DEF),  _______, _______, _______, _______, KC_ESCAPE,  KC_ESCAPE,  
		KC_LSHIFT,  KC_LCTRL,  KC_Q,  KC_W,  KC_E,  KC_R,  XXXXXXX,  TO(US2),  KC_Y,  KC_DOT,  KC_UP,  KC_SLASH,  KC_RCTRL,  KC_LSHIFT,  
		KC_LCTRL,  KC_LSHIFT,  KC_A,  KC_S,  KC_D,  KC_G,  XXXXXXX,  TO(US1),  KC_H,  KC_LEFT,  KC_DOWN,  KC_RIGHT,  KC_RSHIFT,  KC_RCTRL,  
		KC_LSHIFT,  KC_LCTRL,  KC_DOT,  KC_UP,  KC_SLASH,  KC_SPACE,  KC_TAB,  KC_Q,  KC_W,  KC_E,  KC_RCTRL,  KC_LSHIFT,  
		KC_RCTRL,  KC_LSHIFT,  KC_LEFT,  KC_DOWN,  KC_RIGHT,  _______,  _______, KC_A,  KC_S,  KC_D,  KC_RSHIFT,  KC_LCTRL,  
		KC_SPACE,  KC_SPACE,  KC_TAB,  KC_SPACE,  KC_TAB,  KC_TAB
	),
	[MUS] = L(
		XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  
		XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  
		XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  
		XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  
		XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  XXXXXXX,  
		MU_MOD,  MU_TOG,  TO(DEF),  TO(DEF),  MU_TOG,  MU_MOD
	),
};

extern bool g_suspend_state;
extern rgb_config_t rgb_matrix_config;

void keyboard_post_init_user(void) {
	rgb_matrix_enable();
}

const uint8_t PROGMEM ledmap[][DRIVER_LED_TOTAL][3] = {
	[DEF] = { {0,0,255}, {105,255,255}, {105,255,255}, {35,255,255}, {14,255,255}, {143,50,255}, {0,0,0}, {0,0,0}, {0,0,0}, {154,255,255}, {143,50,255}, {0,0,0}, {0,0,0}, {0,0,0}, {154,255,255}, {143,50,255}, {0,0,0}, {0,0,0}, {0,0,0}, {35,255,255}, {143,50,255}, {0,0,0}, {0,0,0}, {0,0,0}, {35,255,255}, {143,50,255}, {0,0,0}, {0,0,0}, {0,0,0}, {202,255,255}, {154,255,255}, {154,255,255}, {105,255,255}, {105,255,255}, {14,255,255}, {134,255,213}, {154,255,255}, {154,255,255}, {0,0,255}, {0,0,255}, {249,228,255}, {143,50,255}, {0,0,255}, {0,0,0}, {0,0,255}, {154,255,255}, {143,50,255}, {0,0,0}, {0,0,0}, {0,0,255}, {154,255,255}, {143,50,255}, {0,0,0}, {0,0,0}, {0,0,255}, {14,255,255}, {143,50,255}, {0,0,0}, {0,0,0}, {0,0,0}, {14,255,255}, {143,50,255}, {0,0,0}, {0,0,0}, {0,0,0}, {14,255,255}, {154,255,255}, {154,255,255}, {35,255,255}, {154,255,255}, {14,255,255}, {134,255,213} },

	[US1] = { {35,255,255}, {105,255,255}, {35,255,255}, {154,255,255}, {14,255,255}, {0,0,0}, {0,0,0}, {154,255,255}, {0,0,0}, {249,228,255}, {0,0,0}, {105,255,255}, {154,255,255}, {0,0,0}, {35,255,255}, {0,0,0}, {0,0,0}, {154,255,255}, {0,0,0}, {35,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {105,255,255}, {0,0,0}, {134,255,213}, {105,255,255}, {105,255,255}, {35,255,255}, {154,255,255}, {14,255,255}, {0,0,0}, {0,0,0}, {0,0,255}, {0,0,255}, {249,228,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,255}, {154,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,255}, {35,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {0,0,0}, {249,228,255}, {35,255,255}, {105,255,255}, {105,255,255}, {154,255,255}, {0,0,0}, {134,255,213} },

	[VIM] = { {35,255,255}, {0,0,0}, {0,255,255}, {0,255,255}, {0,255,255}, {134,255,213}, {154,255,255}, {14,255,255}, {35,255,255}, {14,255,255}, {134,255,213}, {154,255,255}, {35,255,255}, {35,255,255}, {35,255,255}, {134,255,213}, {0,0,255}, {0,0,255}, {134,255,213}, {249,228,255}, {134,255,213}, {0,0,255}, {14,255,255}, {134,255,213}, {35,255,255}, {134,255,213}, {0,0,255}, {143,50,255}, {143,50,255}, {0,0,0}, {14,255,255}, {14,255,255}, {105,255,255}, {0,0,0}, {0,0,0}, {0,0,136}, {134,255,213}, {134,255,213}, {105,255,255}, {0,0,255}, {0,0,0}, {134,255,213}, {154,255,255}, {0,0,255}, {35,255,255}, {0,0,0}, {134,255,213}, {154,255,255}, {154,255,255}, {35,255,255}, {0,0,0}, {134,255,213}, {0,0,255}, {154,255,255}, {0,0,255}, {14,255,255}, {134,255,213}, {0,0,255}, {154,255,255}, {105,255,255}, {14,255,255}, {134,255,213}, {0,0,255}, {154,255,255}, {0,255,255}, {86,255,255}, {30,96,255}, {30,96,255}, {105,255,255}, {0,0,0}, {0,0,0}, {0,0,136} },

	[NUM] = { {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {249,228,255}, {0,0,0}, {0,0,0}, {0,0,0}, {35,255,255}, {35,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {154,255,255}, {14,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {14,255,255}, {154,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,136}, {0,0,0}, {0,0,0}, {35,255,255}, {35,255,255}, {35,255,255}, {0,0,255}, {0,0,255}, {0,0,255}, {105,255,255}, {0,0,255}, {0,0,255}, {154,255,255}, {154,255,255}, {154,255,255}, {0,0,255}, {0,0,255}, {154,255,255}, {154,255,255}, {154,255,255}, {14,255,255}, {0,0,0}, {154,255,255}, {154,255,255}, {154,255,255}, {154,255,255}, {0,0,0}, {0,0,0}, {154,255,255}, {105,255,255}, {86,255,255}, {0,0,0}, {0,0,0}, {105,255,255}, {0,0,0}, {0,0,0}, {0,0,136} },

	[US2] = { {249,228,255}, {35,255,255}, {105,255,255}, {154,255,255}, {14,255,255}, {35,255,255}, {105,255,255}, {0,0,0}, {154,255,255}, {249,228,255}, {0,0,0}, {0,0,0}, {154,255,255}, {0,0,0}, {35,255,255}, {0,0,0}, {105,255,255}, {154,255,255}, {0,0,0}, {35,255,255}, {0,0,0}, {0,0,0}, {154,255,255}, {0,0,0}, {105,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {105,255,255}, {0,0,0}, {0,0,0}, {105,255,255}, {105,255,255}, {35,255,255}, {154,255,255}, {14,255,255}, {0,0,0}, {0,0,0}, {0,0,255}, {0,0,255}, {249,228,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,255}, {154,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,255}, {35,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {0,0,0}, {0,0,0}, {105,255,255}, {0,0,0}, {249,228,255}, {35,255,255}, {105,255,255}, {105,255,255}, {0,0,0}, {0,0,0}, {0,0,0} },

	[DBL] = { {249,228,255}, {35,255,255}, {105,255,255}, {35,255,255}, {154,255,255}, {249,228,255}, {105,255,255}, {35,255,255}, {154,255,255}, {35,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {0,0,0}, {154,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {105,255,255}, {154,255,255}, {134,255,213}, {249,228,255}, {35,255,255}, {105,255,255}, {35,255,255}, {154,255,255}, {249,228,255}, {105,255,255}, {35,255,255}, {154,255,255}, {35,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {105,255,255}, {0,0,0}, {154,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {35,255,255}, {0,0,0}, {105,255,255}, {249,228,255}, {35,255,255}, {105,255,255}, {105,255,255}, {105,255,255}, {154,255,255}, {134,255,213} },

	[MUS] = { {154,255,255}, {0,0,0}, {0,0,0}, {154,255,255}, {0,0,0}, {154,255,255}, {0,0,0}, {0,0,0}, {154,255,255}, {154,255,255}, {0,0,0}, {154,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {154,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {154,255,255}, {154,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {35,255,255}, {154,255,255}, {14,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {249,228,255}, {249,228,255}, {249,228,255}, {249,228,255}, {249,228,255}, {249,228,255}, {0,0,0}, {0,0,0}, {249,228,255}, {249,228,255}, {249,228,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {249,228,255}, {249,228,255}, {249,228,255}, {249,228,255}, {0,0,0}, {0,0,0}, {0,0,0}, {249,228,255}, {249,228,255}, {0,0,0}, {0,0,0}, {0,0,0}, {35,255,255}, {154,255,255}, {14,255,255}, {0,0,0} },

};

void set_layer_color(int layer) {
	for (int i = 0; i < DRIVER_LED_TOTAL; i++) {
		HSV hsv = {
			.h = pgm_read_byte(&ledmap[layer][i][0]),
			.s = pgm_read_byte(&ledmap[layer][i][1]),
			.v = pgm_read_byte(&ledmap[layer][i][2]),
		};
		if (!hsv.h && !hsv.s && !hsv.v) {
			rgb_matrix_set_color( i, 0, 0, 0 );
		} else {
			RGB rgb = hsv_to_rgb( hsv );
			float f = (float)rgb_matrix_config.hsv.v / UINT8_MAX;
			rgb_matrix_set_color( i, f * rgb.r, f * rgb.g, f * rgb.b );
		}
	}
}

void rgb_matrix_indicators_user(void) {
	if (rgb_matrix_get_suspend_state() || keyboard_config.disable_layer_led) { return; }
	// used to be switch statement, no longer
	if (biton32(layer_state) < LAYERS) {
		set_layer_color(biton32(layer_state));
	} else if (rgb_matrix_get_flags() == LED_FLAG_NONE) {
		rgb_matrix_set_color_all(0, 0, 0);
	}
}

typedef struct {
	bool is_press_action;
	uint8_t step;
} tap;


static tap dance_state[DANCES];

uint8_t dance_step(qk_tap_dance_state_t *state);

uint8_t dance_step(qk_tap_dance_state_t *state) {
	if (state->count == 1) {
		if (state->interrupted || !state->pressed) return SINGLE_TAP;
		else return SINGLE_HOLD;
	} else if (state->count == 2) {
		if (state->interrupted) return DOUBLE_SINGLE_TAP;
		else if (state->pressed) return DOUBLE_HOLD;
		else return DOUBLE_TAP;
	}

	return MORE_TAP;

	// logically unneeded, but the compiler complains without it :shrug:
	return 0;

}

// lock
SAFETY(LOCK, LGUI(KC_L))
// left volume/media
SIMPLE3(LVOL, KC_AUDIO_VOL_DOWN, KC_AUDIO_MUTE, KC_MEDIA_PREV_TRACK)
// esc/tab - thumb
SIMPLE2(ESCT, KC_ESCAPE, KC_TAB)
// right volume/media
SIMPLE3(RVOL, KC_AUDIO_VOL_UP, KC_AUDIO_MUTE, KC_MEDIA_NEXT_TRACK)
// playpause -- 44
SIMPLE2_ALT(PLAY, KC_MEDIA_PLAY_PAUSE, KC_AUDIO_MUTE)
// emergency eeprom reset
//SAFETY(911, EEP_RST)
//TAP_HOLD(METAN, KC_N, KC_LGUI)

#define NO(x) NULL
#define YES(x) x
qk_tap_dance_action_t tap_dance_actions[] =
	{ AVDANCE(LOCK, NO , YES, YES)
	, AVDANCE(LVOL, YES, YES, YES)
	, AVDANCE(ESCT, YES, YES, YES)
	, AVDANCE(RVOL, YES, YES, YES)
	, AVDANCE(PLAY, YES, YES, YES)
	//AVDANCE(METAN, YES, YES, YES)
	//AVDANCE(DANCE_911, NO, YES, YES)
	};
#undef NO
#undef YES


bool process_record_user(uint16_t keycode, keyrecord_t *record) {
	switch (keycode) {
		case rgb_sld:
			if (record->event.pressed) {
				rgblight_mode(1);
			}
			return false;
		case hsv_105_255_255:
			if (record->event.pressed) {
				rgblight_mode(1);
				rgblight_sethsv(105,255,255);
			}
			return false;
		case hsv_249_228_255:
			if (record->event.pressed) {
				rgblight_mode(1);
				rgblight_sethsv(249,228,255);
			}
			return false;
		case hsv_35_255_255:
			if (record->event.pressed) {
				rgblight_mode(1);
				rgblight_sethsv(35,255,255);
			}
			return false;
		case hsv_14_255_255:
			if (record->event.pressed) {
				rgblight_mode(1);
				rgblight_sethsv(14,255,255);
			}
			return false;
	}
	return true;
}

#ifdef TAPPING_TERM_PER_KEY
uint16_t get_tapping_term(uint16_t keycode, keyrecord_t *record) {
	switch (keycode) {
		case LGUI_T(KC_T):
		case LGUI_T(KC_N):
		case LALT_T(KC_S):
		case LALT_T(KC_E):
			return TAPPING_TERM + 50;

		case LSFT_T(KC_R):
		case LSFT_T(KC_I):
			return TAPPING_TERM + 75;

		case LCTL_T(KC_A):
		case LCTL_T(KC_O):
			return TAPPING_TERM + 100;

		default: return TAPPING_TERM;
	}
}
#endif
#ifdef PERMISSIVE_HOLD_PER_KEY
bool get_permissive_hold(uint16_t keycode, keyrecord_t *record) {
	switch (keycode) {
		case(OS(LGUI)):
		case(OS(LALT)):
		case(OS(LSFT)):
		case(OS(LCTL)):
			return true;
		default: return false; // Do not select the hold action when another key is tapped.
	}
}
#endif
#ifdef TAPPING_FORCE_HOLD_PER_KEY
bool get_tapping_force_hold(uint16_t keycode, keyrecord_t *record) {
	switch (keycode) {
		case LGUI_T(KC_T):
		case LGUI_T(KC_N):
		case LALT_T(KC_S):
		case LALT_T(KC_E):

		case LSFT_T(KC_R):
		case LSFT_T(KC_I):

		case LCTL_T(KC_A):
		case LCTL_T(KC_O):
			return true;

		default: return false;
	}
}
#endif
#ifdef RETRO_TAPPING_PER_KEY
bool get_retro_tapping(uint16_t keycode, keyrecord_t *record) {
	switch (keycode) {
		case LGUI_T(KC_T):
		case LGUI_T(KC_N):
		case LALT_T(KC_S):
		case LALT_T(KC_E):

		case LSFT_T(KC_R):
		case LSFT_T(KC_I):

		case LCTL_T(KC_A):
		case LCTL_T(KC_O):
//			return true;

		default: return false;
	}
}
#endif
#ifdef IGNORE_MOD_TAP_INTERRUPT_PER_KEY
bool get_ignore_mod_tap_interrupt(uint16_t keycode, keyrecord_t *record) {
	switch (keycode) {
		case LGUI_T(KC_T):
		case LGUI_T(KC_N):
		case LALT_T(KC_S):
		case LALT_T(KC_E):

		case LSFT_T(KC_R):
		case LSFT_T(KC_I):

		case LCTL_T(KC_A):
		case LCTL_T(KC_O):
			return true;
		default: return false;
	}
}
#endif

