## Unpack /usr/lib/slack/resources/app.asar with `asar extract`

## Append this to `dist/preload.bundle.js`

```
setTimeout(_ => {
  const prop = document.getElementsByClassName('sk-client-theme--dark')[0];
  prop.style.setProperty('--sk_primary_background', '40,40,40');
  prop.style.setProperty('--sk_foreground_min_solid', '29,32,33');
  prop.style.setProperty('--sk_primary_foreground', '235,219,178');
  prop.style.setProperty('--sk_foreground_max', '235,219,178');
  prop.style.setProperty('--sk_foreground_max_solid', '189,174,147');
  prop.style.setProperty('--sk_highlight', '142,192,124');
  prop.style.setProperty('--sk_highlight_hover', '250,189,47');
},2000)
```

## Pack with `asar pack`
