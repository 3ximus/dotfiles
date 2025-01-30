/*
 * My custom corne keymap for 36 key layout
 */

#include "quantum_keycodes.h"
#include QMK_KEYBOARD_H

enum custom_keycodes {
  CTL_EXLM = SAFE_RANGE,
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [0] = LAYOUT_split_3x5_3(KC_Q, KC_W, KC_E, KC_R, KC_T, KC_Y, KC_U, KC_I, KC_O, KC_P, LCTL_T(KC_A), LSFT_T(KC_S), KC_D, KC_F, KC_G, KC_H, KC_J, KC_K, RSFT_T(KC_L), RCTL_T(KC_QUOT), KC_Z, KC_X, KC_C, KC_V, KC_B, KC_N, KC_M, KC_COMM, KC_DOT, KC_SLSH, KC_LGUI, MO(2), KC_SPC, RSFT_T(KC_ENT), LT(1, KC_ESC), KC_LALT),
  [1] = LAYOUT_split_3x5_3(KC_F1, KC_F2, KC_F3, KC_F4, KC_F5, KC_F6, KC_F7, KC_F8, KC_F9, KC_BSPC, LCTL_T(KC_1), KC_2, KC_3, KC_4, KC_5, KC_6, KC_7, KC_8, KC_9, RCTL_T(KC_0), KC_LSFT, KC_TRNS, KC_TRNS, KC_TRNS, KC_F10, KC_F11, KC_F12, KC_TRNS, KC_TRNS, KC_RSFT, KC_LGUI, MO(3), KC_TAB, KC_ENT, KC_TRNS, KC_LALT),
  [2] = LAYOUT_split_3x5_3(KC_NO, KC_LT, KC_GRV, KC_GT, KC_QUES, KC_PPLS, KC_LCBR, KC_TILD, KC_RCBR, KC_BSPC, CTL_EXLM, KC_CIRC, KC_EQL, KC_DLR, KC_HASH, KC_ASTR, KC_LPRN, KC_PMNS, KC_RPRN, KC_PIPE, KC_LSFT, KC_AMPR, KC_AT, KC_PERC, KC_COMM, KC_SCLN, KC_LBRC, KC_UNDS, KC_RBRC, KC_BSLS, KC_LGUI, KC_TRNS, KC_SPC, KC_COLN, MO(3), KC_LALT),
  [3] = LAYOUT_split_3x5_3(KC_PAUS, KC_MPRV, KC_MPLY, KC_MNXT, KC_NO, KC_NO, KC_PGUP, RCS(KC_TAB), LCTL(KC_TAB), KC_DEL, KC_LCTL, LSFT_T(KC_HOME), KC_PGDN, KC_END, KC_CAPS, KC_LEFT, KC_DOWN, KC_UP, KC_RGHT, KC_RCTL, KC_NO, RCS(KC_X), RCS(KC_C), RCS(KC_V), LALT(KC_LEFT), LALT(KC_RGHT), KC_VOLD, KC_VOLU, KC_MUTE, KC_NO, KC_LGUI, KC_TRNS, KC_SPC, KC_ENT, KC_TRNS, KC_LALT)};

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  static uint16_t ctl_exlm_timer;
  switch (keycode) {
    case CTL_EXLM:
      if (record->event.pressed) {
        ctl_exlm_timer = timer_read();
        register_code(KC_LCTL);
      } else {
        unregister_code(KC_LCTL);
        if (timer_elapsed(ctl_exlm_timer) < TAPPING_TERM) {
          SEND_STRING("!");
        }
      }
      return false;
  }
  return true;
}

#ifdef ENCODER_MAP_ENABLE
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
    [0] =
        {
            ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
            ENCODER_CCW_CW(KC_MPRV, KC_MNXT),
            ENCODER_CCW_CW(RM_VALD, RM_VALU),
            ENCODER_CCW_CW(KC_RGHT, KC_LEFT),
        },
    [1] =
        {
            ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
            ENCODER_CCW_CW(KC_MPRV, KC_MNXT),
            ENCODER_CCW_CW(RM_VALD, RM_VALU),
            ENCODER_CCW_CW(KC_RGHT, KC_LEFT),
        },
    [2] =
        {
            ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
            ENCODER_CCW_CW(KC_MPRV, KC_MNXT),
            ENCODER_CCW_CW(RM_VALD, RM_VALU),
            ENCODER_CCW_CW(KC_RGHT, KC_LEFT),
        },
    [3] =
        {
            ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
            ENCODER_CCW_CW(KC_MPRV, KC_MNXT),
            ENCODER_CCW_CW(RM_VALD, RM_VALU),
            ENCODER_CCW_CW(KC_RGHT, KC_LEFT),
        },
};
#endif
