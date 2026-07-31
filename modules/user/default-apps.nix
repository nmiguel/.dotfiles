# Default desktop applications.
{
  config,
  lib,
  ...
}:
let
  cfg = config.userSettings.defaultApps;

  archiveManager = "org.gnome.FileRoller.desktop";
  browser = "firefox.desktop";
  calendar = "org.gnome.Calendar.desktop";
  fileManager = "thunar.desktop";
  imageViewer = "imv.desktop";
  mediaPlayer = "mpv.desktop";
  pdfViewer = "org.gnome.Evince.desktop";
  textEditor = "org.xfce.mousepad.desktop";
in
{
  options.userSettings.defaultApps.enable = lib.mkEnableOption "declarative default desktop applications";

  config = lib.mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        # Web
        "text/html" = browser;
        "application/xhtml+xml" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;

        # Images
        "image/avif" = imageViewer;
        "image/bmp" = imageViewer;
        "image/gif" = imageViewer;
        "image/heic" = imageViewer;
        "image/heif" = imageViewer;
        "image/jpeg" = imageViewer;
        "image/png" = imageViewer;
        "image/svg+xml" = imageViewer;
        "image/tiff" = imageViewer;
        "image/webp" = imageViewer;

        # Documents
        "application/pdf" = pdfViewer;

        # Video
        "video/mp4" = mediaPlayer;
        "video/mpeg" = mediaPlayer;
        "video/quicktime" = mediaPlayer;
        "video/webm" = mediaPlayer;
        "video/x-matroska" = mediaPlayer;
        "video/x-msvideo" = mediaPlayer;

        # Audio
        "audio/flac" = mediaPlayer;
        "audio/mpeg" = mediaPlayer;
        "audio/ogg" = mediaPlayer;
        "audio/wav" = mediaPlayer;
        "audio/x-m4a" = mediaPlayer;

        # Text and code
        "application/json" = textEditor;
        "application/x-yaml" = textEditor;
        "application/xml" = textEditor;
        "text/plain" = textEditor;
        "text/x-c++src" = textEditor;
        "text/x-csrc" = textEditor;
        "text/x-python" = textEditor;
        "text/x-shellscript" = textEditor;

        # Files and archives
        "inode/directory" = fileManager;
        "application/gzip" = archiveManager;
        "application/vnd.rar" = archiveManager;
        "application/x-7z-compressed" = archiveManager;
        "application/x-bzip2" = archiveManager;
        "application/x-compressed-tar" = archiveManager;
        "application/x-rar" = archiveManager;
        "application/x-tar" = archiveManager;
        "application/x-xz" = archiveManager;
        "application/zip" = archiveManager;

        # Calendar
        "text/calendar" = calendar;
      };
    };

    # Replace the legacy files now that Home Manager owns MIME defaults.
    xdg.configFile."mimeapps.list".force = true;
    xdg.dataFile."applications/mimeapps.list".force = true;
  };
}
