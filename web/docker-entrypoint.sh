#!/bin/sh
set -eu

template_dir="/opt/cobalt-template"
target_dir="/usr/share/nginx/html"

: "${WEB_DEFAULT_API:=https://api.cobalt.tools/}"
: "${WEB_HOST:=}"
: "${WEB_PLAUSIBLE_HOST:=}"
: "${ENABLE_DEPRECATED_YOUTUBE_HLS:=false}"

escape_sed_replacement() {
    printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'
}

copy_template() {
    rm -rf "$target_dir"
    mkdir -p "$target_dir"
    cp -a "$template_dir"/. "$target_dir"/
}

replace_runtime_config() {
    escaped_api="$(escape_sed_replacement "$WEB_DEFAULT_API")"
    escaped_host="$(escape_sed_replacement "$WEB_HOST")"
    escaped_plausible="$(escape_sed_replacement "$WEB_PLAUSIBLE_HOST")"
    escaped_youtube_hls="$(escape_sed_replacement "$ENABLE_DEPRECATED_YOUTUBE_HLS")"

    find "$target_dir" -type f \
        \( -name '*.html' -o -name '*.js' -o -name '*.json' -o -name '*.map' -o -name '*.txt' -o -name '*.webmanifest' -o -name '*.xml' \) \
        -exec sed -i \
            -e "s|__COBALT_WEB_DEFAULT_API__|$escaped_api|g" \
            -e "s|__COBALT_WEB_HOST__|$escaped_host|g" \
            -e "s|__COBALT_WEB_PLAUSIBLE_HOST__|$escaped_plausible|g" \
            -e "s|__COBALT_ENABLE_DEPRECATED_YOUTUBE_HLS__|$escaped_youtube_hls|g" \
            {} +
}

copy_template
replace_runtime_config
