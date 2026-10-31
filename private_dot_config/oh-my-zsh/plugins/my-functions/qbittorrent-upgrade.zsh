# Refresh a local cask from Homebrew metadata, retaining URL and checksum checks.
# Only this explicitly trusted application bypasses quarantine.
function _brew_upgrade_qbittorrent() {
    emulate -L zsh
    local tap=camille/local-qbittorrent
    local token=c0re100-qbittorrent
    local metadata tap_path
    command brew list --cask "$token" >/dev/null 2>&1 || return 0
    metadata=$(mktemp) || return 1
    {
        command curl --fail --silent --show-error --location \
            https://formulae.brew.sh/api/cask/c0re100-qbittorrent.json -o "$metadata" || return $?
        tap_path="$(command brew --repository)/Library/Taps/camille/homebrew-local-qbittorrent"
        command mkdir -p "$tap_path/Casks" || return $?
        command python3 - "$metadata" "$tap_path/Casks/$token.rb" <<'PY'
import json, pathlib, re, sys
metadata = json.loads(pathlib.Path(sys.argv[1]).read_text())
version, sha, url = (metadata[k] for k in ('version', 'sha256', 'url'))
if not re.fullmatch(r'\d+(?:\.\d+)+', version):
    raise SystemExit('Unexpected qBittorrent version')
if not re.fullmatch(r'[0-9a-f]{64}', sha):
    raise SystemExit('Missing or invalid qBittorrent checksum')
expected = ('https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/'
            f'release-{version}/qBittorrent-Enhanced-Edition-release-{version}-macOS-universal.dmg')
if url != expected:
    raise SystemExit('Unexpected qBittorrent download URL; review upstream changes')
if metadata.get('disable_reason') not in (None, 'fails_gatekeeper_check'):
    raise SystemExit('qBittorrent disabled for a new reason; review before upgrading')
content = f'''cask "c0re100-qbittorrent" do
  version "{version}"
  sha256 "{sha}"
  url "{url}"
  name "qBittorrent Enhanced Edition"
  desc "Bittorrent client"
  homepage "https://github.com/c0re100/qBittorrent-Enhanced-Edition"
  depends_on macos: :ventura
  app "qBittorrent.app"
end
'''
path = pathlib.Path(sys.argv[2])
temporary = path.with_suffix('.tmp')
temporary.write_text(content)
temporary.replace(path)
PY
        (( $? == 0 )) || return 1
        # Use the qualified cask so the disabled upstream definition is never selected.
        command brew upgrade --cask "$tap/$token" || return $?
        command xattr -dr com.apple.quarantine /Applications/qBittorrent.app
    } always {
        command rm -f "$metadata"
    }
}
