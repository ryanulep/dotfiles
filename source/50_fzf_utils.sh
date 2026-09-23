function oa() {
	app=$(fd "\.app$" /Applications --max-depth=5 | rg -v "Contents" | fzf) && open -a "$app" "$@"
}

function jobsf() {
	if [[ $(jobs | wc -l | xargs) -ne 0 ]]; then
		job="$(jobs | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')" && echo '' && fg %$job
	fi
}

function b() {
	local bookmarks_path="${CHROME_BOOKMARKS_FILE:-$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks}"
	local jq_script='def ancestors: while(. | length >= 2; del(.[-1,-2])); . as $in | paths(.url?) as $key | $in | getpath($key) | {name,url, path: [$key[0:-2] | ancestors as $a | $in | getpath($a) | .name?] | reverse | join("/") } | [(.path + "/" + .name | gsub("[\\t\\n]"; " ")), .url] | join("\t")'
	local choice
	# A tab is a real field delimiter; `cut -d '  '` fails on macOS. Keep URLs
	# quoted rather than handing spaces, percent signs, or '&' through xargs.
	choice=$(jq -r "$jq_script" <"$bookmarks_path" | fzf --delimiter=$'\t' --with-nth=1) || return
	[[ -n "$choice" ]] && open "${choice##*$'\t'}"
}

function emoj() {
	emoji-fzf preview | fzf --preview 'emoji-fzf get --name {1}' | cut -d " " -f 1 | emoji-fzf get | dotfiles-copy
}

function ghstars() {
	gh api --paginate users/ryanulep/starred | jq -rc '.[].full_name' | fzf
}
