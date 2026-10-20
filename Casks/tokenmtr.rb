cask "tokenmtr" do
  # Renovate bumps both lines from the spnngl/tokenmtr release and its SHA256SUMS (renovate.json5).
  version "0.2.0"
  sha256 "a2da8e3df40d6a2d4718f132463774ff6e1a66141dadf00d087e93630eb6998b"

  url "https://github.com/spnngl/tokenmtr/releases/download/v#{version}/TokenMtr_#{version}_universal.dmg"
  name "TokenMtr"
  desc "Token usage and cost meter for AI coding agents"
  homepage "https://github.com/spnngl/tokenmtr"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "TokenMtr.app"
  binary "#{appdir}/TokenMtr.app/Contents/MacOS/tokenmtr"

  postflight_steps do
    # Self-signed and not notarised: Gatekeeper would block the first launch.
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/TokenMtr.app"]
  end

  uninstall quit: "dev.tokenmtr.app"

  # The app's onboarding installs the daemon: Homebrew sandboxes install steps (no launchd, a
  # throwaway HOME), so the cask cannot. `uninstall` also runs on `brew upgrade`, so removing the
  # daemon there would stop it on every update; the app restarts an outdated daemon at launch.
  zap launchctl: "dev.tokenmtr.daemon",
      trash:     [
        "~/.config/tokenmtr",
        "~/Library/Application Support/dev.tokenmtr.app",
        "~/Library/Caches/dev.tokenmtr.app",
        "~/Library/HTTPStorages/dev.tokenmtr.app",
        # The app's "Launch at login" item (tauri-plugin-autostart), not the daemon.
        "~/Library/LaunchAgents/TokenMtr.plist",
        "~/Library/Logs/tokenmtr",
        "~/Library/Preferences/dev.tokenmtr.app.plist",
        "~/Library/Saved Application State/dev.tokenmtr.app.savedState",
        "~/Library/WebKit/dev.tokenmtr.app",
      ]

  caveats <<~EOS
    Open TokenMtr once: its onboarding installs the background daemon
    (LaunchAgent dev.tokenmtr.daemon), or run `tokenmtr service install`.
    `brew uninstall` keeps the daemon: run `tokenmtr service uninstall` first,
    or use `brew uninstall --zap tokenmtr`, which also deletes the config,
    the usage store and its backups.
  EOS
end
