# Review Rubric

## Verdicts

- **Pass**: the intended picture, geometry, repaint behavior, lifecycle, and explanation meet the lesson's acceptance criteria.
- **Revise**: the approach is sound, but one or more concrete criteria need another attempt.
- **Blocked**: the file cannot run or the current structure prevents meaningful progress. The review identifies the smallest unblocker.

Visual similarity alone is not enough for a pass.

## Review categories

Each review evaluates:

| Category | The reviewer checks |
|---|---|
| Picture | Required shapes, colors, overlap, and clipping are present |
| Draw order | Commands are intentionally ordered back-to-front |
| Coordinates | Points are derived from `Size` and remain understandable |
| Geometry | Formulas express the intended relationships and edge cases |
| Paint objects | Fill/stroke/style are explicit; avoid needless per-frame allocation |
| State | Immutable, interactive, and animated values have clear owners |
| Repaint | Only meaningful changes repaint; animation does not require `setState` per frame |
| Lifecycle | Tickers/listeners are started, stopped, and disposed safely |
| Input | Hit testing uses the same geometric truth as drawing |
| Accessibility | Interactive custom painting has labels, actions, and keyboard/focus behavior |
| Verification | Format, analysis, runtime behavior, and relevant tests succeed |
| Explanation | The student can describe why the picture is built this way |

## Hint-first protocol

For a problem, the reviewer gives help in this order:

1. Observation: what the canvas or lifecycle currently does.
2. Question: which assumption or formula should be reconsidered.
3. Direction: name the Flutter API or mathematical relationship to use.
4. Pseudocode: outline the correction without supplying the final Dart.
5. Patch: only after the student explicitly asks for one.

The review may stop at the first level that gives enough information for another attempt.

## Submission template

Send:

```text
Review lesson XX
File: lib/custom_painter_lessons/lesson_XX_name.dart
What I intended to draw:
What I found difficult:
Why my draw order is correct:
What triggers and stops repainting:
Checks I ran:
```

## Performance rules used throughout

- Keep `paint()` free of widget-tree mutation.
- Prefer the `repaint` argument for frame-by-frame canvas changes.
- Cache the painter when its identity need not change.
- Move invariant calculations or objects out of hot paths when measurement shows value or intent is clearer.
- Pair every `canvas.save()` with `canvas.restore()`.
- Use `saveLayer` only when its compositing behavior is truly required.
- Treat `shouldRepaint` as a comparison of painter delegate configuration, not as a place to advance animation.
