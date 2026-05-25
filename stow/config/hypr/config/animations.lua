-- ─── Curves ───────────────────────────────────────────────────────────────────

-- window-open: ease-out-expo ≈ cubic-bezier(0.16, 1, 0.3, 1)
hl.curve("easeOutExpo", { type = "bezier", points = { {0.16, 1.0}, {0.3, 1.0} } })

-- screenshot-ui-open: ease-out-quad ≈ cubic-bezier(0.25, 0.46, 0.45, 0.94)
hl.curve("easeOutQuad", { type = "bezier", points = { {0.25, 0.46}, {0.45, 0.94} } })

-- window-movement / horizontal-view-movement: damping-ratio=1.0, stiffness=800
-- dampening = 2 × √(1 × 800) ≈ 57
hl.curve("springMove", { type = "spring", mass = 1, stiffness = 800, dampening = 57 })

-- workspace-switch: damping-ratio=2.0, stiffness=2000
-- dampening = 2 × 2.0 × √2000 ≈ 179
hl.curve("springWorkspace", { type = "spring", mass = 1, stiffness = 2000, dampening = 179 })

-- window-resize: damping-ratio=1.0, stiffness=2000
-- dampening = 2 × √2000 ≈ 89
hl.curve("springResize", { type = "spring", mass = 1, stiffness = 2000, dampening = 89 })


-- ─── Animations ───────────────────────────────────────────────────────────────

-- window-open → windowsIn: 150ms = 1.5 ds
hl.animation({ leaf = "windowsIn",  enabled = true,  speed = 1.5, bezier = "easeOutExpo", style = "popin 80%" })

-- window-close → off
hl.animation({ leaf = "windowsOut", enabled = false })

-- window-movement → windowsMove (also covers resize in Hyprland, no separate leaf)
-- Using springMove (stiffness=800); swap to springResize if you prefer snappier resizes
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1, spring = "springMove" })

-- workspace-switch → workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, spring = "springWorkspace" })

-- screenshot-ui-open → layersIn: 100ms = 1.0 ds
-- config-notification / exit-confirmation are also layers — disable per-surface
-- with layerrule = noanim in your main config instead, as the animation tree
-- has no per-namespace toggle
hl.animation({ leaf = "layersIn",  enabled = true, speed = 1.0, bezier = "easeOutQuad" })
hl.animation({ leaf = "layersOut", enabled = false })

-- disable fade globally (niri has none by default)
hl.animation({ leaf = "fade", enabled = false })
