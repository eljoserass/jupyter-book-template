---
numbering:
  title: false
---
# DynSim Smoke Test

If plugin registration and JS injection are both working, this page renders an interactive simulator.

```{dynsim}
:params: [{"id":"tau","label":"Tau","min":0.1,"max":5,"step":0.1,"value":1}]
:plotType: timeseries
:plotConfig: {"title":"Leaky Integrator","xaxis":{"title":"Time"},"yaxis":{"title":"v"}}
:initialState: {"v":0}
:initialX: 1.0
:height: 360
:dt: 0.02

import numpy as np

def step(x, state, p):
    dv = (-state['v'] + x) / p['tau']
    v_new = state['v'] + p['dt'] * dv
    return (v_new, {'v': v_new})
```
