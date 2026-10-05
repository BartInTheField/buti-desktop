#!/usr/bin/env bash
# CalVer tags in the same shape as BartInTheField/buti: YYYY.MM.DD.N
# N counts the releases of that UTC day.
set -euo pipefail

# next_calver <YYYY.MM.DD> <existing tags, one per line>
next_calver() {
	local today="$1"
	local tags="${2-}"
	local escaped last
	escaped=$(printf '%s' "$today" | sed 's/\./\\./g')
	last=$(printf '%s\n' "$tags" | sed -n "s/^${escaped}\\.//p" | sort -n | tail -1)
	echo "${today}.$(( ${last:-0} + 1 ))"
}

# Tauri's updater compares semver, which rejects a fourth numeric component.
# YYYY.MM.DD.N becomes YYYY.MMDD.N (month * 100 + day). Order matches the tag.
calver_to_semver() {
	local tag="$1"
	local year month day n
	IFS=. read -r year month day n <<< "$tag"
	if [ -z "${year:-}" ] || [ -z "${month:-}" ] || [ -z "${day:-}" ] || [ -z "${n:-}" ]; then
		echo "calver tag must be YYYY.MM.DD.N, got: $tag" >&2
		return 1
	fi
	printf '%d.%d.%d\n' "$((10#$year))" "$((10#$month * 100 + 10#$day))" "$((10#$n))"
}

if [ "${1-}" = "--test" ]; then
	got=$(next_calver "2026.10.05" "")
	[ "$got" = "2026.10.05.1" ] || { echo "empty tags: $got"; exit 1; }

	got=$(next_calver "2026.10.05" $'2026.10.05.1\n2026.10.05.2\n2026.10.04.9')
	[ "$got" = "2026.10.05.3" ] || { echo "increment: $got"; exit 1; }

	got=$(next_calver "2026.10.05" $'2026.10.05.9\n2026.10.05.10')
	[ "$got" = "2026.10.05.11" ] || { echo "numeric sort: $got"; exit 1; }

	got=$(calver_to_semver "2026.10.05.1")
	[ "$got" = "2026.1005.1" ] || { echo "oct semver: $got"; exit 1; }

	got=$(calver_to_semver "2026.01.09.2")
	[ "$got" = "2026.109.2" ] || { echo "jan semver: $got"; exit 1; }

	got=$(calver_to_semver "2026.12.31.4")
	[ "$got" = "2026.1231.4" ] || { echo "dec semver: $got"; exit 1; }

	echo "calver ok"
	exit 0
fi

if [ "${1-}" = "--semver" ]; then
	calver_to_semver "${2:?tag}"
	exit 0
fi

if [ -n "$(git tag --points-at HEAD)" ]; then
	echo "Nothing merged since $(git tag --points-at HEAD | head -1); skipping." >&2
	exit 0
fi

today=$(date -u +%Y.%m.%d)
tags=$(git tag --list "${today}.*")
next_calver "$today" "$tags"
