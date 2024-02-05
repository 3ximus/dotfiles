
document.addEventListener("DOMContentLoaded", function () {
  let s = document.createElement("style");
  s.innerHTML = `
  body {
    --bg-primary: #282828;
    --background-color-primary: #282828;
    --background-color-secondary: #282828;
    --background-color-tertiary: #282828;
    --base-color-info: #689D6A;
    --base-color-brand: #FE8019;
    --content-color-link: #8EC07C;
  }
  `;
  document.head.appendChild(s);
}); // XXX EXIMUS PATCH -- DONT CHANGE THIS COMMENT, its used to remove this style when reapplying the patch
