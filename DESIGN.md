# SOCDaily Design Language — Mastercard-Inspired

> A warm, editorial, sophisticated design system inspired by Mastercard's
> visual identity. Cream canvases, extreme border-radius, atmospheric shadows,
> and tight typography tracking create a premium yet approachable learning
> companion.

## 1. Design Principles

1. **Warm, never sterile.** Canvas Cream (#F3F0EE) replaces white everywhere.
   Pure white is reserved for floating navigation or raised card surfaces.
2. **Extreme radius scale.** Skip 8–16 px mid-range. Use 3–6 px (tiny),
   20 px (buttons), 24 px (cards), 40 px (hero frames), 999 px (pills).
3. **Atmospheric shadows.** Shadows are large-blur, low-opacity cushions
   (48 px spread at 8 % opacity), never sharp directional edges.
4. **One type family.** Sofia Sans (open-source match for MarkForMC) unifies
   headlines, body, and labels. Weight 500 for headlines, 400 for body.
5. **Tight tracking, generous spacing.** Headlines use −2 % letter-spacing,
   eyebrows use +4 %. Section padding follows 8-based scale (48–128 px).
6. **Ink Black is the hero.** #141413 for primary CTAs and headlines. Signal
   Orange (#CF4500) only for consent/legal. Decorative orange (#F37338) for
   orbital arcs and accents.
7. **Circular > rectangular.** Icon containers are circles, not rounded rects.
   Feature cards use pill-shaped arrow buttons instead of small chevrons.
8. **Floating navigation.** Bottom nav is a white pill with 999 px radius,
   atmospheric shadow, and expanding label on the active item.

## 2. Color Palette

| Token | Light | Dark | Usage |
|---|---|---|---|
| Canvas Cream | `#F3F0EE` | `#1A1917` | Body background |
| Lifted Cream | `#FCFBFA` | `#222220` | Card surfaces, nested panels |
| Ink Black | `#141413` | `#FCFBFA` | Primary text, headings, CTAs |
| Charcoal | `#262627` | — | Secondary dark surfaces |
| Slate Gray | `#696969` | `white 60%` | Secondary text |
| Dust Taupe | `#D1CDC7` | — | Muted text, placeholders |
| Signal Orange | `#CF4500` | — | Consent/legal actions only |
| Light Signal Orange | `#F37338` | — | Decorative accents, orbitals |
| Link Blue | `#3860BE` | — | In-text links, secondary icons |
| Divider Cream | `#E8E2DA` | `white 8%` | Borders, dividers |

### Accent System

Users can pick a personal accent color. Three groups:

- **Mastercard:** Ink (default), Signal, Clay — warm editorial tones.
- **Professional:** Graphite, Azure, Violet, Crimson, Forest, Amber.
- **Friendly:** Sakura, Mint, Mocha — pastel soft variants.

Each accent has `.deep` (strong, for buttons and headings) and `.soft`
(light tint, for backgrounds and indicators).

## 3. Typography

Single font family: **Sofia Sans** (weight-variable).

| Role | Size | Weight | Tracking | Line-height |
|---|---|---|---|---|
| H1 (hero) | 64 px | 500 | −2 % | 1.0 |
| H2 (section) | 36 px | 500 | −2 % | 1.22 |
| H3 (card title) | 24 px | 500 | −2 % | 1.2 |
| Body | 16 px | 400 | 0 | 1.4 |
| Eyebrow | 12 px | 700 | +4 % | — |
| Label | 11–14 px | 500–700 | +0.2–0.56 | — |

## 4. Border Radius Scale

| Size | Usage |
|---|---|
| 3–6 px | Heatmap cells, tiny indicators |
| 20 px | Buttons, FABs, accent swatches, side rail items |
| 24 px | Cards, option tiles, explanation panels |
| 40 px | Hero frames, flashcards, dialogs, bottom sheets |
| 999 px | Navigation pill, input fields, chips, tags, snackbar |

## 5. Elevation / Shadows

| Level | Shadow | Usage |
|---|---|---|
| 0 | None | 95 % of surfaces |
| 1 (floating nav) | `rgba(0,0,0,0.04) 0 4px 24px` | Bottom nav pill |
| 2 (cards/hero) | `rgba(0,0,0,0.08) 0 24px 48px` | Hero section, flashcards |
| 3 (modals) | `rgba(0,0,0,0.25) 0 70px 110px` | Rare, for overlays |

## 6. Components

- **Buttons:** Ink pill (20 px radius, Ink Black bg, Cream text). Outlined
  pill variant for secondary actions.
- **Cards:** Lifted Cream surface, 24 px radius, Level 1 shadow. Hero
  cards use 40 px radius and Level 2 shadow.
- **Feature cards:** Row layout with circular icon container, title/subtitle,
  and circular arrow button on the right.
- **Stat cards:** Vertical layout, eyebrow label in uppercase with wide
  tracking, hero numeral, accent icon at top.
- **Flashcards:** 40 px stadium radius, 3D flip animation, eyebrow dot +
  label, atmospheric Level 2 shadow.
- **MCQ options:** 24 px radius, pill badges for choice types, radio/check
  icons with accent tint.
- **Navigation:** Floating white pill bar (999 px radius) on mobile, cream
  side rail on tablet/desktop.
- **Section eyebrows:** Small accent dot (6 px circle) + uppercase label
  with +4 % tracking.
- **Tags / chips:** Full pill (999 px), Dust Taupe or accent-tinted surface.

## 7. Motion

- Default duration: 200 ms for micro-interactions, 380 ms for flashcard flip.
- Curve: `Curves.easeOutCubic` for most transitions.
- Flashcard: 3D rotateY with perspective 0.001.
- Nav items: animated width expansion on selection.

## 8. Responsive Breakpoints

| Breakpoint | Width | Layout |
|---|---|---|
| Mobile | < 600 px | Single column, floating pill nav |
| Tablet | 600–767 px | Single column with wider padding |
| Wide | ≥ 768 px | Side rail + content area |

## 9. Legacy

The old Quicksand + PlusJakartaSans font pairing is still bundled in
`pubspec.yaml` for backwards compatibility with the PDF certificate generator.
The UI rendering exclusively uses Sofia Sans.
