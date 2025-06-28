#include <stdio.h>
#include <string.h>

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │ D E F I N I T I O N S                                                                                                                      │
// └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

// ┌───────────────────────────────────────────────────────────┐
// │ l a y o u t  a n d  k e y m a p                           │
// └───────────────────────────────────────────────────────────┘

#include "layout_saegewerk.cfg"
#include "keymap_saegewerk.h"
#define LAYOUT LAYOUT_saegewerk

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │ M A C R O S                                                                                                                                │
// └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

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

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │ E N C O D E R                                                                                                                              │
// └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

#ifdef ENCODER_ENABLE

bool encoder_update_user(uint8_t index, bool clockwise) {
  if (index == 0) {
    if (clockwise) tap_code(KC_VOLD);
    else tap_code(KC_VOLU);
  } else if (index == 1) {
    if (clockwise) tap_code(KC_PGDN);
    else tap_code(KC_PGUP);
  }
  return false;
}

#endif // ENCODER_ENABLE


// ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │ O L E D                                                                                                                                    │
// └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

#ifdef OLED_ENABLE


// ┌───────────────────────────────────────────────────────────┐
// │ d y n a m i c   m a c r o                                 │
// └───────────────────────────────────────────────────────────┘

char layer_state_str[24];
char o_text[24] = "";
int dmacro_num = 0;

#ifdef DYNAMIC_MACRO_ENABLE
char dmacro_text[4][24] = { "", "RECORDING", "STOP RECORDING",  "PLAY RECORDING"};
static uint16_t dmacro_timer;
const char PROGMEM rec_ico[] = {0xD1, 0xE1, 0};
const char PROGMEM stop_ico[] = {0xD3, 0xE1, 0};
const char PROGMEM play_ico[] = {0xD2, 0xE1, 0};


    // DYNMACRO RECORD ├─────────────────────────────────────────────────────────────┐
void dynamic_macro_record_start_user(void) {
  dmacro_num = 1;
  return;
}

    // DYNMACRO STOP RECORDING ├─────────────────────────────────────────────────────┐
void dynamic_macro_record_end_user(int8_t direction) {
  dmacro_num = 2;
  dmacro_timer = timer_read();
  return;
}

    // DYNMACRO PLAY RECORDING ├─────────────────────────────────────────────────────┐
void dynamic_macro_play_user(int8_t direction) {
  dmacro_num = 3;
  dmacro_timer = timer_read();
  return;
}
#endif //DYNAMIC_MACRO_ENABLE


void matrix_scan_user(void) {
#ifdef DYNAMIC_MACRO_ENABLE
  // DynMacroTimer
  if(dmacro_num > 0){
    if (timer_elapsed(dmacro_timer) < 3000) {
      strcpy ( o_text, dmacro_text[dmacro_num] );
    }
    else {
      if (dmacro_num == 1) {
        strcpy ( o_text, dmacro_text[1] );
      }
      else {
        strcpy ( o_text, layer_state_str );
        dmacro_num = 0;
      }
    }
  }
#endif //DYNAMIC_MACRO_ENABLE
}


// ┌───────────────────────────────────────────────────────────┐
// │ o l e d   g r a p h i c s                                 │
// └───────────────────────────────────────────────────────────┘

void render_os_lock_status(void) {
  static const char PROGMEM sep_v[] = {0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0};
  static const char PROGMEM sep_h1[] = {0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0};
  static const char PROGMEM sep_h2[] = {0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0};
  static const char PROGMEM face_1[] = {0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xE1, 0};
  static const char PROGMEM face_2[] = {0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xE1, 0};
  static const char PROGMEM os_m_1[] = {0x95, 0x96, 0};
  static const char PROGMEM os_m_2[] = {0xB5, 0xB6, 0};
  static const char PROGMEM os_w_1[] = {0x97, 0x98, 0};
  static const char PROGMEM os_w_2[] = {0xB7, 0xB8, 0};
  static const char PROGMEM s_lock[] = {0x8F, 0x90, 0};
  static const char PROGMEM n_lock[] = {0x91, 0x92, 0};
  static const char PROGMEM c_lock[] = {0x93, 0x94, 0};
  static const char PROGMEM b_lock[] = {0xE1, 0xE1, 0};
#ifdef AUDIO_ENABLE
  static const char PROGMEM aud_en[] = {0xAF, 0xB0, 0};
  static const char PROGMEM aud_di[] = {0xCF, 0xD0, 0};
#endif
#ifdef HAPTIC_ENABLE
  static const char PROGMEM hap_en[] = {0xB1, 0xB2, 0};
#endif

  // os mode status ────────────────────────────────────────┐

  oled_write_ln_P(sep_v, false);

  if (keymap_config.swap_lctl_lgui) {
    oled_write_P(os_m_1, false); // ──── MAC
  } else {
    oled_write_P(os_w_1, false); // ──── WIN
  }

  oled_write_P(sep_h1, false);
  oled_write_P(face_1, false);

  if (keymap_config.swap_lctl_lgui) {
    oled_write_P(os_m_2, false); // ──── MAC
  } else {
    oled_write_P(os_w_2, false); // ──── WIN
  }

  oled_write_P(sep_h1, false);
  oled_write_P(face_2, false);
  oled_write_ln_P(sep_v, false);


  // lock key layer status ─────────────────────────────────┐

  led_t led_usb_state = host_keyboard_led_state();

  if (led_usb_state.num_lock) {
    oled_write_P(n_lock, false); // ──── NUMLOCK
  } else {
    oled_write_P(b_lock, false);
  }
  if (led_usb_state.caps_lock) {
    oled_write_P(c_lock, false); // ─── CAPSLOCK
  } else {
    oled_write_P(b_lock, false);
  }
  if (led_usb_state.scroll_lock) { // ─ SCROLLLOCK
    oled_write_P(s_lock, false);
  } else {
    oled_write_P(b_lock, false);
  }

  // hardware feature status ──────────────────────────────┐

  oled_write_P(sep_h2, false);

#ifndef AUDIO_ENABLE
  oled_write_P(b_lock, false);
#endif
#ifndef HAPTIC_ENABLE
  oled_write_P(b_lock, false);
#endif

#ifdef AUDIO_ENABLE // ────────────────── AUDIO
  if (is_audio_on()) {
    oled_write_P(aud_en, false);
  } else {
    oled_write_P(aud_di, false);
  }
#endif // AUDIO ENABLE

#ifdef HAPTIC_ENABLE // ─────────────── HAPTIC
  oled_write_P(hap_en, false);
#endif // HAPTIC ENABLE
}


// layer status ──────────────────────────────────────────┐

layer_state_t layer_state_set_kb(layer_state_t state) {
  // state is the bitmask of the active layer
  sprintf(layer_state_str, "> %d | %d <", dmacro_num, state);
  strcpy ( o_text, layer_state_str);
  return state;
}


// ┌───────────────────────────────────────────────────────────┐
// │ w r i t e   t o   o l e d                                 │
// └───────────────────────────────────────────────────────────┘

bool oled_task_kb(void) {
  if (!oled_task_user()) {
    return false;
  }
  if (is_keyboard_master()) {  // ────────────────────────── PRIMARY SIDE

/*     // layer status ──────────────────────────────────────────────────┐ */
/* #ifdef DYNAMIC_MACRO_ENABLE */
/*     if(dmacro_num == 1){ oled_write_P(rec_ico, false); } */
/*     if(dmacro_num == 2){ oled_write_P(stop_ico, false); } */
/*     if(dmacro_num == 3){ oled_write_P(play_ico, false); } */
/* #endif //DYNAMIC_MACRO_ENABLE */
/*  */
/*     oled_write_ln(o_text, false); */
/*     render_os_lock_status(); */
    static const char PROGMEM gengar[] = {
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x80,0,0,0,0,0x80,0x40,0x80,0,0,0,0,0,0,0x80,0,0x80,0x40,0xa0,0x50,0x20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x4,0xa,0x34,0xc8,0x4,0x18,0x28,0x30,0x50,0xa0,0x48,0xb4,0x58,0xb0,0x2c,0xa,0x5,0x1a,0x5,0xa,0x6,0x1,0x2,0x15,0xa,0x5,0x2c,0x1a,0x4,0xa,0x5,0x2,0x1,0,0x55,0x2a,0x55,0xa0,0x50,0xa8,0x10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x40,0xa0,0x20,0x10,0x20,0x20,0x20,0x41,0x46,0x98,0x60,0,0,0,0x80,0,0x1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x80,0,0,0,0,0,0,0,0,0,0x2,0x1,0xa,0x1d,0x6,0xc,0xa,0x4,0x2,0xc,0x8,0x28,0xb0,0x40,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x1,0x2,0x6,0x8,0x8,0x10,0x20,0x40,0x40,0x80,0,0,0,0x20,0xc7,0xf,0x98,0x94,0x18,0x10,0,0,0,0,0,0x10,0x38,0x34,0xb8,0xbe,0x1f,0x8f,0xc0,0,0x70,0,0,0,0,0,0,0,0,0,0,0x80,0x60,0x10,0x8,0x4,0x2,0x2,0x1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0xab,0x54,0x80,0,0,0,0,0x7,0xf,0,0xf,0x1f,0x1f,0,0x1f,0x1f,0x1f,0,0xf,0xf,0xf,0,0x7,0x1,0,0,0,0,0,0,0,0,0,0x14,0x2a,0x95,0x48,0x10,0x28,0x10,0x20,0x10,0xd0,0x20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x14,0x2a,0xc1,0x80,0x1,0,0,0,0,0,0x10,0xd0,0x20,0x20,0x20,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x20,0x20,0x20,0x40,0x80,0,0,0,0,0,0,0,0x80,0x80,0x41,0x6a,0x94,0x4,0x2,0x1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x1,0x2,0x2,0x4,0x4,0x4,0x2,0x2,0x1,0x1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x1,0x1,0x2,0x2,0x4,0x18,0x20,0x10,0x10,0x10,0xc,0x5,0x2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
    };
    oled_write_raw_P(gengar, sizeof(gengar));

  } else {  // ─────────────────────────────────────────── SECONDARY SIDE
    static const char PROGMEM mew[] = {
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x80,0x80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x80,0x80,0,0,0,0,0,0,0,0,0,0,0,0,0,0x80,0xe0,0xf8,0x7c,0x3e,0x9f,0x4f,0x27,0x11,0xf,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0xe0,0xe0,0xe0,0xc0,0xe0,0xf0,0xf0,0xf8,0xf8,0xfc,0x7c,0xfd,0xfb,0xff,0xfe,0xf8,0x50,0x20,0,0,0,0,0,0,0,0x3e,0x7f,0xc7,0x83,0x80,0x81,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x1,0xd,0x33,0x4f,0x9f,0x3f,0x63,0x65,0xc1,0xdd,0x7a,0xb7,0x7f,0x3f,0x5f,0x3f,0x1f,0xe,0,0,0,0,0x80,0x80,0,0,0,0,0,0x81,0xc1,0xe1,0xc2,0x2,0x2,0x2,0x4,0x4,0x8,0x10,0x20,0x40,0x80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x80,0xc0,0x60,0xf1,0x79,0x3c,0x3e,0x5f,0xff,0xff,0xff,0xfe,0xfd,0xfb,0x7b,0x76,0x26,0xc0,0xf8,0x3f,0x9f,0x7f,0x6,0,0xc0,0xf8,0x3e,0x8f,0x7f,0xf,0x1,0,0,0,0,0,0,0,0,0,0x81,0xfe,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x1,0,0,0,0,0,0,0xa,0x11,0x2b,0x47,0x7,0x8c,0x17,0x8f,0x9a,0x1f,0x9c,0xce,0xe1,0x9c,0x87,0x3,0xf,0xe,0x6,0x1,0,0,0,0,0,0x80,0x80,0x40,0x60,0x30,0x18,0xe,0x3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x1,0x1,0x3,0x2,0x6,0x6,0x6,0x6,0x2,0x3,0x1,0x1,0x1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,
    };
    oled_write_raw_P(mew, sizeof(mew));
  }
  return false;
}
#endif // OLED_ENABLE

