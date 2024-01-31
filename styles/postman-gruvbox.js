
document.addEventListener("DOMContentLoaded", function () {
  let s = document.createElement("style");
  s.innerHTML = `
  body {
    font-family: "TerminessTTF Nerd Font Mono",Inter,system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Oxygen,Ubuntu,Cantarell,Fira Sans,Droid Sans,Helvetica,Arial,sans-serif;
    --bg-primary: #282828;
    --background-color-primary: #282828;
    --background-color-secondary: #282828;
    --background-color-tertiary: #282828;
    --base-color-info: #689D6A;
  }
  `;
  document.head.appendChild(s);
}); // XXX EXIMUS PATCH -- DONT CHANGE THIS COMMENT, its used to remove this style when reapplying the patch
