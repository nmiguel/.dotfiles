local vars = require("config.vars")

local UTILITIES = {
    -- "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP=Hyprland",
    -- "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP",
    -- "nm-applet --indicator",
    -- "mako",
    -- "ags",
    -- "blueman-applet",
    -- "hyprsunset",
    -- "walker --gapplication-service",
    "thunar --daemon",
    -- "elephant",
    -- "openrgb -p Default",
    -- "fcitx5",
}

local MAIN_APPS = {
    {cmd = vars.terminal, opts = { workspace = "1", monitor = vars.monitor1 }},
    {cmd = vars.browser,  opts = { workspace = "2", monitor = vars.monitor2 }},
}

local ROUTED_APPS = {
    {
        name    = "startup-steam",
        match   = { class = "^(steam)$" },
        workspace = "5",
        monitor = vars.monitor1,
        command = "setpriv --ambient-caps -all steam",
    },
    {
        name    = "startup-youtube-music",
        match   = { class = "^(youtube-music)$" },
        workspace = "3",
        monitor = vars.monitor2,
        command = "pear-desktop",
    },
    {
        name    = "startup-whatsapp",
        match   = { title = "^(WhatsApp)$" },
        workspace = "3",
        monitor = vars.monitor2,
        command = "chromium --app=https://web.whatsapp.com",
    },
    {
        name    = "startup-claude",
        match   = { initial_title = "^(claude.ai_/)$" },
        workspace = "6",
        monitor = vars.monitor2,
        command = "chromium --app=https://claude.ai",
    },
}

-- ─── logic ───────────────────────────────────────────────────────────────────

local RULE_TIMEOUT = 30000

local function launch_routed(app)
    local rule = hl.window_rule({
        name      = app.name,
        match     = app.match,
        workspace = app.workspace .. " silent",
        monitor   = app.monitor,
    })
    hl.exec_cmd(app.command)
    hl.timer(function()
        rule:set_enabled(false)
    end, { timeout = RULE_TIMEOUT, type = "oneshot" })
end

-- ─── startup ─────────────────────────────────────────────────────────────────

hl.on("hyprland.start", function()
    for _, cmd in ipairs(UTILITIES) do
        hl.exec_cmd(cmd)
    end


    for _, app in ipairs(MAIN_APPS) do
        hl.exec_cmd(app.cmd, app.opts)
    end
    for _, app in ipairs(ROUTED_APPS) do
        launch_routed(app)
    end
end)
