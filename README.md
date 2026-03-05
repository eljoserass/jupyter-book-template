
# Jupyter Book DynSim Template

This is a barebones Jupyter Book project that demonstrates the `dynsim` directive with the same plugin/runtime wiring used in `snn-book`.

## Where `dynsim` is wired

- Directive registration: `_plugins/dynamical-systems.mjs`
- Runtime logic: `_static/js/dynamical_systems.js`
- Head/script injection for PyScript + static assets: `_static/js/server.js`


## Run yourself

```bash
uv sync

source .venv/bin/activate

jupter book start

```
