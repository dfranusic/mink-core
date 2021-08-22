#!/bin/sh

# Tag revisions like this:
# $ git tag -a -m "Version 0.2" v0.2 HEAD

VF=VERSION
DEFAULT_VERSION=v1.0

LF='
'
TAG_TYPE="v*"

# First see if there is a version file (included in release tarballs),
# then try git-describe, then default.
if test -d .git -o -f .git &&
    VN=$(git describe --abbrev=4 --long --match=$TAG_TYPE HEAD 2>/dev/null) &&
    case "$VN" in
    *$LF*) (exit 1) ;;
    v[0-9]*)
        git update-index -q --refresh
        test -z "$(git diff-index --name-only HEAD --)" ||
        VN="$VN-mod" ;;
    esac
then
        continue
    #VN=$(echo "$VN" | sed -e 's/-/./g');
else
    VN="$DEFAULT_VERSION"
fi

#VN=$(expr "$VN" : v*'\(.*\)')

# Show the version to the user via stderr
echo >&2 "$VN"

# Parse the existing VERSION-FILE 
if test -r $VF
then
    VC=$(sed -e 's/^version: //' <$VF)
else
    VC=unset
fi

# If version has changed, update VERSION-FILE
test "$VN" = "$VC" || {
    echo "$VN" >$VF
    echo >&2 "($VF updated)"
}
