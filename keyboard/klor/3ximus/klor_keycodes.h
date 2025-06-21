#ifndef KLOR_KEYCODE_H
#define KLOR_KEYCODE_H

#include QMK_KEYBOARD_H

// ┌───────────────────────────────────────────────────────────┐
// │ d e f i n e   k e y c o d e s                             │
// └───────────────────────────────────────────────────────────┘

typedef enum {
  QWERTY = SAFE_RANGE,
  COLEMAK,
  LOWER,
  RAISE,
  ADJUST,
  OS_SWAP,
  MAKE_H,
  CTL_EXLM,
} custom_keycodes;

#endif
