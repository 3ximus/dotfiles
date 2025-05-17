document.addEventListener("DOMContentLoaded", function () {
  let s = document.createElement("style");
  s.innerHTML = `
    body {
      font-family: "Terminess Nerd Font Mono", Slack-Lato,Slack-Fractions,appleLogo,sans-serif !important;
    }
    .c-texty_input_unstyled {
      font-family: "Terminess Nerd Font Mono", Slack-Lato,Slack-Fractions,appleLogo,sans-serif !important;
    }
  `;
  document.head.appendChild(s);
}); // XXX EXIMUS PATCH -- DONT CHANGE THIS COMMENT, its used to remove this style when reapplying the patch
