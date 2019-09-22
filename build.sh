
make 2>&1 | grep -E --line-buffered --color=never 'error:|.vala:.*warning:' | grep -E --line-buffered --color=always "error:|$"
