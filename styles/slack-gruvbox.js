document.addEventListener('DOMContentLoaded', function() {
  let s = document.createElement('style');
    s.type = 'text/css';
    s.innerHTML = `
    body {
      font-family: "TerminessTTF Nerd Font Mono", Slack-Lato,Slack-Fractions,appleLogo,sans-serif !important;
    }
    .c-texty_input_unstyled {
      font-family: "TerminessTTF Nerd Font Mono", Slack-Lato,Slack-Fractions,appleLogo,sans-serif !important;
    }
    .sk-client-theme--dark {
      --sk_primary_background: 40,40,40;
      --sk_foreground_min_solid: 29,32,33;
      --sk_primary_foreground: 235,219,178;
      --sk_foreground_max: 235,219,178;
      --sk_foreground_max_solid: 189,174,147;
      --sk_highlight: 142,192,124;
      --sk_highlight_hover: 250,189,47;
    }`;
    document.head.appendChild(s);
})
