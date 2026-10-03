# Timeline example

A reference for what the `## Timeline` section of a daily note should look like.
The day below is made up — a day spent on one thesis-experiment project.

**Copy these six things, not the surface look.**

1. **The source is the trace headers.** Never from memory. Times and numbers exactly as written in the trace
2. Split into chunks where **the phase changed**, not by the clock. A day with two chunks gets two
3. **One event per line.** No narration
4. Bold **only the results that changed the direction of the day.** If everything is bold, nothing is
5. **Keep dead ends and misdiagnoses.** Remove them and the day looks smooth, and later you lose why you went that way
6. **A summary table at the top, chunk details below.** One row per chunk, numbered to match the detail titles.
   See the day at a glance, then read down only the chunks you need

On days that touched several projects, interleave by time, and **put the project name on the chunk title where the project changes**
(`③ 14:00–16:30 · [Survey-Paper] Rewrote the table`). If the day was one project, write it once at the top.

---

All [[Thesis-Experiment]].

| # | Time | Project | One line |
|---|---|---|---|
| ① | 09:40–11:50 | Thesis-Experiment | Reproducing the baseline |
| ② | 13:10–15:30 | Thesis-Experiment | Narrowing the conditions |
| ③ | 16:00–18:20 | Thesis-Experiment | First main run |

**① 09:40–11:50 · Reproducing the baseline**
- Started reproducing the baseline with the authors' code
- Accuracy 71.2 — 2.8 below the paper's 74.0
- Suspected random seed; repeated with 5 seeds → spread 0.3, not the seed
- Found the preprocessing image size differs from the paper
- **Matched the size → 73.8, fixed as the baseline**

**② 13:10–15:30 · Narrowing the conditions**
- Listed 6 candidate conditions
- Decided to cut to three before the advisor meeting (time budget)
- Learning-rate sweep, 3 points → largest value diverged
- **Blamed the model for divergence, but the cause was missing warmup** → converged after adding warmup

**③ 16:00–18:20 · First main run**
- Started condition A; restarted once due to a wrong checkpoint path
- Condition A 74.9, +1.1 over baseline
- Condition B ran out of memory → retrying with half batch, result tomorrow
- **First task tomorrow: check condition B** ← where to pick up
