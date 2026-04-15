# Dashboard Assets

This directory is mounted **read-only** into the Grafana container at:

```
/usr/share/grafana/public/img/albertsons/
```

Any file placed here is served by Grafana at `/public/img/albertsons/<filename>`
and can be referenced from any dashboard HTML / text panel as:

```html
<img src="public/img/albertsons/logo.svg" width="82" height="82" alt="Albertsons">
```

## Expected files

| File | Used by | Notes |
|------|---------|-------|
| `logo.svg` | Albertsons Home dashboard (`/d/albertsons-home`) | Preferred — scales cleanly at any size |
| `logo.png` | Albertsons Home dashboard (fallback) | Used only if `logo.svg` is not present |

## How to add or update the logo

1. Obtain the official brand asset from your own internal source
   (brand portal, design system, marketing team, etc.)
2. Save it to this directory as `logo.svg` (preferred) or `logo.png`
3. Refresh the Albertsons home dashboard — no container restart needed

## Note

The repository ships with no logo file on purpose. Brand assets are not
checked into git; they live here so each environment can bring its own
approved file. If the file is missing, the dashboard falls back to a
text placeholder so the layout still renders correctly.
