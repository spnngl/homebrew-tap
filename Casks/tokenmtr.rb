# frozen_string_literal: true

cask "tokenmtr" do
  # Renovate bumps both lines from the spnngl/tokenmtr release and its SHA256SUMS (renovate.json5).
  version "0.4.0"
  sha256 "40a1d8e0d9d524439663d844520c0e70765a4c815f6e1c3f2998fbfae4d77c91"

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

  # The app's onboarding installs the daemon: Homebrew sandboxes install steps (no launchd, a
  # throwaway HOME), so the cask cannot. `uninstall` also runs on `brew upgrade`, which then reopens
  # the app it quit; the app reinstalls a missing daemon at launch once onboarding is done.
  uninstall launchctl: "dev.tokenmtr.daemon",
            quit:      "dev.tokenmtr.app"

  zap trash: [
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
    `brew upgrade` removes the daemon and the app reinstalls it at launch.
    `brew uninstall --zap tokenmtr` also deletes the config, the usage store
    and its backups.
  EOS
end
