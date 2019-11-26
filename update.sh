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
		version_family="v${version}"
		exts=(tar.gz)
		downloads_url="https://github.com/JuliaLang/julia/releases/download"
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
		  #/v1.3.0-rc5/julia-1.3.0-rc5.tar.gz
			archive="julia-${version}.${ext}"
			url="$downloads_url/$version_family/$archive"
		  #/v1.3.0-rc5/julia-1.3.0-rc5-full.tar.gz
			archive_full="julia-${version}-full.${ext}"
			url_full="$downloads_url/$version_family/$archive_full"
			;;
		*)
			echo 'Unknown Julia.'
			exit 1
			;;
	esac

	if [ -f "$archive" ]; then
		echo "Already downloaded $archive"
	else
		wget -O "$archive" "$url"
	fi

	for algorithm in gpg; do
		echo "1  $archive" >> "../$julia/signatures.$algorithm"
		echo "1  $archive_full" >> "../$julia/signatures.$algorithm"
	done
done

echo "$version" >> "../$julia/versions.txt"

if [[ $(wc -l < "../$julia/stable.txt") == "1" ]]; then
	echo "$version" > "../$julia/stable.txt"
fi

popd >/dev/null
