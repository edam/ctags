#!/bin/bash
FROM=v6.0.0

pr_title()
{
	local N=$1
	curl https://github.com/universal-ctags/ctags/pull/"$N" | grep '^  <title>' | \
		sed -e 's!^[[:space:]]*<title>\(.\+Pull Request #[0-9]*\).*</title>$!* \1!' | \
		sed -e "s/&#39;/'/g" -e 's/&amp;/\&/g' -e 's/&quot;/"/g' -e 's/&gt;/>/g' -e 's/&lt;/</g'
}

issue_title()
{
	local N=$1
	curl https://github.com/universal-ctags/ctags/issues/"$N" | grep '^  <title>' | \
		sed -e 's!^[[:space:]]*<title>\(.\+Issue #[0-9]*\).*</title>$!* \1!' | \
		sed -e "s/&#39;/'/g" -e 's/&amp;/\&/g' -e 's/&quot;/"/g' -e 's/&gt;/>/g' -e 's/&lt;/</g'
}

usage()
{
	printf "	%s help|--help|-h\n" "$0"
	printf "	%s pr [#]\n" "$0"
	printf "	%s issue [#]\n" "$0"
	printf "	%s man\n" "$0"		
}

if [[ $# == 0 ]]; then
	usage 1>&2
	exit 1
fi

case $1 in
	(help|--help|-h)
		usage 1>&2
		exit 0
		;;
	(pr)
		shift
		if [[ $1 =~ [0-9]+ ]]; then
			pr_title "$1"
			exit 0
		else
			git log --oneline ${FROM}.. \
				| grep '[0-9a-f]\+ Merge pull request #[0-9]\+.*' \
				| sed -ne 's/.*#\([0-9]\+\) from.*/\1/p' | while read N; do
				pr_title "$N"
			done
			exit 0
		fi
		;;
	(issue)
		shift
		if [[ $1 =~ [0-9]+ ]]; then
			issue_title "$1"
			exit 0
		else
			git log ${FROM}.. \
				| grep 'Close #' \
				| sed -ne 's/[[:space:]]Close #\([0-9]\+\).*/\1/p' | while read N; do
				issue_title $N
			done
		fi
		;;
	(man)
		git diff ${FROM}... man/*.in
		;;
esac
