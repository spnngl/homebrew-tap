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
    # `uninstall` removes the daemon, `brew upgrade` included: start it on the new binary.
    # The bundle path, not the `binary` symlink: the LaunchAgent stores the path it was started from.
    # A launchd failure leaves the app installed; `tokenmtr service install` retries.
    run "TokenMtr.app/Contents/MacOS/tokenmtr",
        args:           ["service", "install"],
        base:           :appdir,
        must_succeed:   false,
        writable_paths: ["Library/LaunchAgents", "Library/Logs/tokenmtr"],
        writable_base:  :home
  end

  uninstall launchctl: "dev.tokenmtr.daemon",
            quit:      "dev.tokenmtr.app"

  zap trash: [
    "~/.config/tokenmtr",
    "~/Library/Application Support/dev.tokenmtr.app",
    "~/Library/Caches/dev.tokenmtr.app",
    "~/Library/HTTPStorages/dev.tokenmtr.app",
    "~/Library/Logs/tokenmtr",
    "~/Library/Preferences/dev.tokenmtr.app.plist",
    "~/Library/Saved Application State/dev.tokenmtr.app.savedState",
    "~/Library/WebKit/dev.tokenmtr.app",
  ]

  caveats <<~EOS
    The background daemon (LaunchAgent dev.tokenmtr.daemon) starts at install and login.
    `brew uninstall --zap tokenmtr` also deletes the config, the usage store and its backups.
  EOS
end
