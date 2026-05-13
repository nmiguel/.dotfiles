-- Toolkit Backend Variables
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")
-- env = GTK_IM_MODULE,fcitx
-- env = QT_IM_MODULE,fcitx
-- env = XMODIFIERS,@im=fcitx

-- Run SDL2 applications on Wayland.
-- Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("GSK_RENDERER", "ngl")

-- xdg Specifications
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- QT Variables
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- hyprland-qt-support
hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")

-- xwayland apps scale fix (useful if you are use monitor scaling).
-- Set same value if you use scaling in Monitors.conf
-- 1 is 100% 1.5 is 150%
-- see https://wiki.hyprland.org/Configuring/XWayland/
hl.env("GDK_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")

hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- firefox
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- electron >28 apps (may help) -- #
-- https://www.electronjs.org/docs/latest/api/environment-variables
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- NVIDIA
-- This is from Hyprland Wiki. Below will be activated nvidia gpu detected
-- See hyprland wiki https://wiki.hyprland.org/Nvidia/-- environment-variables

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

-- additional ENV's for nvidia. Caution, activate with care
-- env = GBM_BACKEND,nvidia-drm

-- env = __GL_GSYNC_ALLOWED,1 -- adaptive Vsync
-- env = __NV_PRIME_RENDER_OFFLOAD,1
-- env = __VK_LAYER_NV_optimus,NVIDIA_only
-- env = WLR_DRM_NO_ATOMIC,1

-- FOR VM and POSSIBLY NVIDIA
-- LIBGL_ALWAYS_SOFTWARE software mesa rendering
-- env = LIBGL_ALWAYS_SOFTWARE,1 --  Warning. May cause hyprland to crash
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")

-- nvidia firefox (for hardware acceleration on FF)?
-- check this post https://github.com/elFarto/nvidia-vaapi-driver-- configuration
hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
hl.env("EGL_PLATFORM", "wayland")

hl.env("DMS_DISABLE_MATUGEN", "1")
hl.env("QT_MEDIA_BACKEND", "ffmpeg")

hl.env("PATH", "$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.config/bin:$HOME/go/bin:/usr/local/bin:/usr/bin:/bin")
