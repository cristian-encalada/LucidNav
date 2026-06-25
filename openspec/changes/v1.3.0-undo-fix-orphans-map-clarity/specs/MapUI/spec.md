# Spec: MapUI — v1.3.0

## ADDED

### Checkpoint toolbar controls
- **"Save"** button — calls `Checkpoints.Save()` (prompts for / defaults a name).
- **"Restore"** button — opens a small list/dropdown of saved checkpoints
  (name + timestamp from `Checkpoints.List()`); selecting one calls
  `Checkpoints.Restore(name)`.

### Disconnected-room rendering
- On the **main canvas**, a room cell with zero neighbors (other than the current
  room) is drawn with a red border via the RoomEngine `recolorRoom` change, so
  orphans are obvious. (Mirroring this into the 8×8 Grid Map cell is deferred —
  the canvas indicator is sufficient for spotting orphans before deletion.)

## CHANGED

### Overlap-resistant interaction (Item 4 Phase 1)
- The selected room and current room are raised in frame level so that when cells
  abut or partially overlap, the relevant room stays clickable (addresses
  "failed to click overlapping button").
- Connector lines drawn by the engine for non-physically-adjacent links are
  parented to the canvas/scroll container and pan with it.
