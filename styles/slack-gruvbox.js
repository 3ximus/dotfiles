document.addEventListener("DOMContentLoaded", function () {
  let s = document.createElement("style");
  s.innerHTML = `
    body {
      font-family: "TerminessTTF Nerd Font Mono", Slack-Lato,Slack-Fractions,appleLogo,sans-serif !important;
    }
    .c-texty_input_unstyled {
      font-family: "TerminessTTF Nerd Font Mono", Slack-Lato,Slack-Fractions,appleLogo,sans-serif !important;
    }
    .c-search_autocomplete__suggestion_item--selected{
      background: #8ec07c !important;
      color:#282828 !important;
    }
    .c-base_list_entity--highlight-dark{
      background: #8ec07c !important;
      color:#282828 !important;
    }
    .p-message_pane__unread_banner {
      background: #8ec07c !important;
      color:#282828 !important;
    }
    .p-client_desktop--ia-top-nav .p-message_pane__unread_banner__banner:hover,
    .p-client_desktop--ia-top-nav .p-message_pane__unread_banner__close_icon:hover,
    .p-client_desktop--ia-top-nav .p-message_pane__unread_banner__msg:hover {
      background: #689d60 !important;
      color:#282828 !important;
    }
    .sk-client-theme--dark {
      --sk_primary_background: 40,40,40 !important;
      --sk_foreground_min_solid: 29,32,33 !important;
      --sk_primary_foreground: 235,219,178 !important;
      --sk_foreground_max: 235,219,178 !important;
      --sk_foreground_max_solid: 189,174,147 !important;
      --sk_highlight: 142,192,124 !important;
      --sk_highlight_hover: 250,189,47 !important;
      --sk_highlight_accent: 142,192,124 !important;
      --dt_color-content-pry: #ebdbb2 !important;
      --dt_color-content-sec: #d5c4a1 !important;
      --dt_color-content-inv-pry: #8ec07c !important;
      --dt_color-theme-content-pry: #ebdbb2 !important;
      --dt_color-theme-content-sec: #d5c4a1 !important;
      --dt_color-theme-content-inv-pry: #ebdbb2 !important;
      --dt_color-theme-surf-ter: #282828 !important;
    }
    .p-channel_sidebar__channel--selected {
      background-color: #3c3836 !important
    }
    .p-ia4_top_nav, .p-ia4_channel_list, .p-tab_rail {
      background-color: #282828 !important;
    }
    .p-theme_background {
      background: unset !important;
    }
    .p-client_workspace_wrapper {
      grid-template-columns: 0px auto !important;
    }
    .p-tab_rail {
      display: none !important;
    }
    .p-control_strip__circle_button {
      display: none !important;
    }
    .p-control_strip {
      bottom: unset !important;
      left: unset !important;
      top: 0 !important;
      right: 0 !important;
      padding: 5px 0 0 0 !important;
    }
    .p-ia__nav__user__avatar.c-avatar {
      height: 30px !important;
      width: 30px !important;
    }
    .p-ia__nav__user__avatar.c-avatar>.c-base_icon__width_only_container {
      height: 30px !important;
      width: 30px !important;
    }
    .p-ia__nav__user__avatar.c-avatar>.c-base_icon__width_only_container>.c-base_icon.c-base_icon--image {
      width: 30px !important;
    }
    .p-ia4_top_nav__right_container>.c-coachmark-anchor {
      display: none !important;
    }
    .sk-client-theme--dark .p-ia4_client .p-client_workspace__layout {
      border: none !important;
      border-radius: 0 !important;
    }
    .p-ia4_client .p-client_workspace {
      padding: 0 !important;
    }
    .p-ia4_client.p-ia4_client--with-search-in-top-nav .p-view_contents--primary {
      max-height: unset !important;
    }
    .p-ia4_client.p-ia4_client--with-search-in-top-nav .p-view_contents--sidebar {
      max-height: unset !important;
    }
  `;
  document.head.appendChild(s);
}); // XXX EXIMUS PATCH -- DONT CHANGE THIS COMMENT, its used to remove this style when reapplying the patch
