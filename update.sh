#!/usr/bin/env bash

set -e

if [[ ! $# -eq 2 ]]; then
	echo "usage: $0 [julia] [VERSION]"
	exit 1
fi

julia="$1"
version="$2"
dest="pkg"

case "$julia" in
	julia)
		version_family="${version:0:3}"

		exts=(tar.gz tar.bz2 tar.xz zip)
		downloads_url="https://cache.julia-lang.org/pub/julia"
		;;
	mruby)
		exts=(tar.gz zip)
		downloads_url="https://github.com/mruby/mruby/archive"
		;;
	jruby)
		exts=(tar.gz zip)
		downloads_url="https://s3.amazonaws.com/jruby.org/downloads"
		;;
	rubinius)
		exts=(tar.bz2)
		downloads_url="https://rubinius-releases-rubinius-com.s3.amazonaws.com"
		;;
	truffleruby)
		exts=(linux-amd64.tar.gz macos-amd64.tar.gz)
		downloads_url="https://github.com/oracle/truffleruby/releases/download"
		;;
	*)
		echo "$0: unknown julia: $julia" >&2
		exit 1
		;;
esac

mkdir -p "$dest"
pushd "$dest" >/dev/null

for ext in "${exts[@]}"; do
	case "$julia" in
		julia)
			archive="julia-${version}.${ext}"
			url="$downloads_url/$version_family/$archive"
			;;
		mruby)
			archive="mruby-${version}.${ext}"
			url="$downloads_url/$version/$archive"
			;;
		jruby)
			archive="jruby-bin-${version}.${ext}"
			url="$downloads_url/$version/$archive"
			;;
		rubinius)
			archive="rubinius-${version}.${ext}"
			url="$downloads_url/$archive"
			;;
		truffleruby)
			archive="truffleruby-${version}-${ext}"
			url="$downloads_url/vm-$version/$archive"
			;;
	esac

	if [ -f "$archive" ]; then
		echo "Already downloaded $archive"
	else
		wget -O "$archive" "$url"
	fi

	for algorithm in md5 sha1 sha256 sha512; do
		${algorithm}sum "$archive" >> "../$julia/checksums.$algorithm"
	done
done

echo "$version" >> "../$julia/versions.txt"

if [[ $(wc -l < "../$julia/stable.txt") == "1" ]]; then
	echo "$version" > "../$julia/stable.txt"
fi

popd >/dev/null
