# Identity, Normative Sorting, and the Persistence of Organizational Responses to Social Norms

Replication code for the agent-based simulations in Richard Wang, "Identity, Normative Sorting, and the Persistence of Organizational Responses to Social Norms" (submitted to the *Journal of Economic Behavior & Organization*, special issue "The Sociality Paradigm of Economics").

The code is written in Stata. It generates all simulated data from scratch, so the repository contains no input data.

## How to run

1. Install Stata (the author used Stata 19.5).
2. Run the master file from this folder (running it from inside `1. Dofiles`, e.g. by double-clicking it, also works):

   ```stata
   cd "path/to/Decoupling-and-ASA"
   do "1. Dofiles/0. Master.do"
   ```

The master file creates `2. Data` (simulated datasets) and `3. Output` (figures as `.svg`). It installs three user-written packages from SSC if they are missing: `grstyle`, `palettes` and `colrspace`. They are used only for graph styling.

**Run time.** The main runs simulate 1,000 firms per environment over 21 periods, so a full run can take several hours. For a quick test, set `glo pop_firm = 100` in the master file.

**Randomness.** Each simulation file sets `set seed 123`, so results are reproducible run to run.

## Files and figures

| File | What it does | Paper |
|---|---|---|
| `0. Master.do` | Sets paths and parameters; runs everything below | |
| `P1.do` | Baseline model: scenarios (ii) and (iii) | Section 3, Appendix A.1 |
| `P1x.do` | Baseline model: scenario (i), where rank-and-file employees face half the normative pressure | Section 3, Appendix A.1 |
| `P1 analysis.do` | Policy–practice gap and firm performance | Figures 2aii, 2bii, 2aiii, 2biii |
| `P1x analysis.do` | Policy–practice gap and firm performance | Figures 2ai, 2bi |
| `P2.do` | Normative sorting under weak pressure (μ = 1.2), then norm erosion after period 10 | Sections 4–5, Appendices A.2–A.3 |
| `P3.do` | Same as `P2.do` under strong pressure (μ = 2) | Sections 4–5, Appendices A.2–A.3 |
| `P2 analysis.do` | Gap and performance at t = 10; performance at t = 20 | Figures 4ai, 4aii, 4aiii |
| `P3 analysis.do` | Gap and performance at t = 10; performance at t = 20 | Figures 4bi, 4bii, 4biii |

Each analysis file also writes extra panels to `3. Output/Supplementary`: the policy–practice gap at t = 20, and mean pro-normative beliefs at t = 10 and t = 20.

**Reading the figures.**
- In Figure 2, firm performance is shown relative to firms whose rank-and-file identify fully with the organization (β₂ = 1).
- In Figure 4, firm performance and pro-normative beliefs are shown relative to firms with β₂ = 0.

## Parameters

| Global | Value | Meaning |
|---|---|---|
| `pop_firm` | 1,000 | Firms per environment |
| `pop_ind` | 100 | Individuals per firm |
| `TMT_pop` | 20 | Corporate leaders per firm (the other 80 are rank-and-file) |
| `levels` | 0, 0.1, …, 1 | Rank-and-file organizational identification β₂ |
| `phi_1`–`phi_4` | 0.1, 0.5, 1, 2 | Degrees of freedom ν of the chi-squared distribution of pro-normative beliefs φ |
| `denom` | 5 | Constant in preferred conformity exp(φ)/(denom + exp(φ)) |
| `halftime`, `maxtime` | 10, 20 | Norm erodes after period 10; simulation ends at period 20 |
