function oa() {
	app=$(fd "\.app$" /Applications --max-depth=5 | rg -v "Contents" | fzf) && open -a "$app" "$@"
}

function jobsf() {
	if [[ $(jobs | wc -l | xargs) -ne 0 ]]; then
		job="$(jobs | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')" && echo '' && fg %$job
	fi
}

function b() {
	local bookmarks_path=~/Library/Application\ Support/Google/Chrome/Default/Bookmarks
	local jq_script='def ancestors: while(. | length >= 2; del(.[-1,-2])); . as $in | paths(.url?) as $key | $in | getpath($key) | {name,url, path: [$key[0:-2] | ancestors as $a | $in | getpath($a) | .name?] | reverse | join("/") } | .path + "/" + .name + "  " + .url'
	jq -r $jq_script <"$bookmarks_path" |
		sed -E $'s/(.*)  (.*)/\\1  \x1b[36m\\2\x1b[m/g' |
		fzf --ansi |
		cut -d$'  ' -f2 |
		xargs open
}

function emoj() {
	emoji-fzf preview | fzf --preview 'emoji-fzf get --name {1}' | cut -d " " -f 1 | emoji-fzf get | pbcopy
}

function ghstars() {
	gh api --paginate users/ryanulep/starred | jq -rc '.[].full_name' | fzf
}