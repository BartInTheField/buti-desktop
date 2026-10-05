#!/usr/bin/env bash
# Build the static Tauri updater manifest from release.sh output.
# Layout: <dist>/<macos|linux|windows>/<aarch64|x86_64>/*.{tar.gz,zip,sig}
set -euo pipefail

semver=""
tag=""
repo=""
dist=""
notes_file=""
output=""
run_test=false

while [[ $# -gt 0 ]]; do
	case "$1" in
	--semver) semver="$2"; shift 2 ;;
	--tag) tag="$2"; shift 2 ;;
	--repo) repo="$2"; shift 2 ;;
	--dist) dist="$2"; shift 2 ;;
	--notes-file) notes_file="$2"; shift 2 ;;
	--output) output="$2"; shift 2 ;;
	--test) run_test=true; shift ;;
	*) echo "unknown flag $1" >&2; exit 1 ;;
	esac
done

platform_key() {
	case "$1/$2" in
	macos/aarch64) echo "darwin-aarch64" ;;
	macos/x86_64) echo "darwin-x86_64" ;;
	linux/x86_64) echo "linux-x86_64" ;;
	linux/aarch64) echo "linux-aarch64" ;;
	windows/x86_64) echo "windows-x86_64" ;;
	*) return 1 ;;
	esac
}

# Print the updater archive in a directory, if it has a sibling .sig.
updater_archive() {
	local dir="$1"
	local archive
	shopt -s nullglob
	for archive in "$dir"/*.app.tar.gz "$dir"/*.AppImage.tar.gz "$dir"/*.msi.zip "$dir"/*.nsis.zip; do
		if [ -f "${archive}.sig" ]; then
			printf '%s\n' "$archive"
			shopt -u nullglob
			return 0
		fi
	done
	shopt -u nullglob
	return 1
}

write_manifest() {
	local notes pub_date platforms archive key signature url name
	notes=$(cat "$notes_file")
	pub_date=$(date -u +%Y-%m-%dT%H:%M:%SZ)
	platforms='{}'

	local os arch dir
	for dir in "$dist"/*/*; do
		[ -d "$dir" ] || continue
		os=$(basename "$(dirname "$dir")")
		arch=$(basename "$dir")
		key=$(platform_key "$os" "$arch") || continue
		archive=$(updater_archive "$dir") || continue
		name=$(basename "$archive")
		signature=$(sed -e 's/[[:space:]]*$//' "${archive}.sig")
		url="https://github.com/${repo}/releases/download/${tag}/${name}"
		platforms=$(jq -c \
			--arg key "$key" \
			--arg url "$url" \
			--arg signature "$signature" \
			'.[$key] = {url: $url, signature: $signature}' <<<"$platforms")
	done

	jq -n \
		--arg version "$semver" \
		--arg notes "$notes" \
		--arg pub_date "$pub_date" \
		--argjson platforms "$platforms" \
		'{version: $version, notes: $notes, pub_date: $pub_date, platforms: $platforms}' >"$output"
}

if [ "$run_test" = true ]; then
	root=$(mktemp -d)
	trap 'rm -rf "$root"' EXIT
	mkdir -p "$root/dist/linux/x86_64" "$root/dist/macos/aarch64"
	printf 'linux-bytes' >"$root/dist/linux/x86_64/buti.AppImage.tar.gz"
	printf 'linux-sig\n' >"$root/dist/linux/x86_64/buti.AppImage.tar.gz.sig"
	printf 'unsigned' >"$root/dist/macos/aarch64/buti.dmg"
	printf 'release notes\n' >"$root/notes"
	semver=2026.1005.1
	tag=2026.10.05.1
	repo=BartInTheField/buti-desktop
	dist=$root/dist
	notes_file=$root/notes
	output=$root/latest.json
	write_manifest
	jq -e '.version == "2026.1005.1"' "$output" >/dev/null
	jq -e '.platforms["linux-x86_64"].signature == "linux-sig"' "$output" >/dev/null
	jq -e '.platforms["linux-x86_64"].url == "https://github.com/BartInTheField/buti-desktop/releases/download/2026.10.05.1/buti.AppImage.tar.gz"' "$output" >/dev/null
	jq -e 'has("platforms") and (.platforms | has("darwin-aarch64") | not)' "$output" >/dev/null
	echo "latest-json ok"
	exit 0
fi

[ -n "$semver" ] && [ -n "$tag" ] && [ -n "$repo" ] && [ -n "$dist" ] && [ -n "$notes_file" ] && [ -n "$output" ] || {
	echo "usage: latest-json.sh --semver V --tag T --repo owner/name --dist DIR --notes-file FILE --output FILE" >&2
	exit 1
}

write_manifest
