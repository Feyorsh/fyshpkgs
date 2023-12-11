self: super: {
  gdb = super.gdb.overrideAttrs (prev: {
    # I haven't the foggiest idea why this is necessary.
    configurePlatforms = [];

    configureFlags = with prev.lib; [
      # no prefix, it's always just "gdb"
      "--program-prefix="

      "--disable-werror"
      #"--target=i386-linux"
      "--enable-targets=[i386-linux, x86_64-linux, aarch64-linux]"
      "--enable-64-bit-bfd"
      "--disable-install-libbfd"
      "--disable-shared" "--enable-static"
      "--with-system-zlib"
      "--with-system-readline"

      "--with-system-gdbinit=/etc/gdb/gdbinit"
      "--with-system-gdbinit-dir=/etc/gdb/gdbinit.d"

      # allow loading of .gdbinit anywhere
      "--with-auto-load-safe-path=/"
    ];
    iggy = prev.writeText "ignore-errors.py" ''
      class IgnoreErrorsCommand (gdb.Command):
          """Execute a single command, ignoring all errors.
      Only one-line commands are supported.
      This is primarily useful in scripts."""
  
          def __init__ (self):
              super (IgnoreErrorsCommand, self).__init__ ("ignore-errors",
                                                          gdb.COMMAND_OBSCURE,
                                                          # FIXME...
                                                          gdb.COMPLETE_COMMAND)
  
          def invoke (self, arg, from_tty):
              try:
                  gdb.execute (arg, from_tty)
              except:
                  pass
  
      IgnoreErrorsCommand ()
    '';
    postInstall = prev.postInstall + ''
      cp $iggy $out/share/gdb/python/ignore-errors.py
    '';
    meta.platforms = prev.meta.platforms ++ [ "aarch64-darwin" ];
  });
}
