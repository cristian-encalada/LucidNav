# Spec: Constants — v1.4.0

## ADDED

New fields on `ns.C`:

- `cellStep` — canvas spacing between cell origins (≈ `buttonW + 1`). Replaces the
  hard-coded `buttonW + 6` used in `getMapXY` / `centerCam` so adjacent open rooms
  read as connected.
- `wallColor` — RGBA for solid/dashed wall lines (light, to read on the dark
  cells).
- `wallThickness` — line thickness in px for wall edges.
- `dashSegments` — number of short bars used to draw a dashed edge.
- `dashGap` — gap (px) between dash segments.

## NOTES
- `blockW` / `blockH` / `wallInset` (used by the old X-icon walls) become unused
  for wall rendering; retained only if still referenced elsewhere, otherwise may
  be removed.
