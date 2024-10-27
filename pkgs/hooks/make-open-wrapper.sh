openWrapper() { openWrapperShell "$@"; }
openWrapperShell() {
    if [ ! -e "$prefix/Applications" -o -L "$prefix/Applications" ]; then return; fi
    # local appBin="$(find $prefix/Applications/ -maxdepth 4 -iwholename "*/Contents/MacOS/*")"
    local appBin="$(find $prefix/Applications/* -maxdepth 0)"

    local wrapper="$1"
    if [ -z "$wrapper" ]; then
        wrapper=$(basename ${appBin,,})
        wrapper=${wrapper%".app"}
    fi

    mkdir -p "$prefix/bin"
    {
        echo "#! @shell@ -e"
        echo "open -a "$appBin" --args" '"$@"'
    } > "$prefix/bin/$wrapper"
    chmod +x "$prefix/bin/$wrapper"
}
