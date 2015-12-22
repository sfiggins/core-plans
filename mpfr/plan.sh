pkg_name=mpfr
pkg_derivation=chef
pkg_version=3.1.3
pkg_maintainer="The Bldr Maintainers <bldr@chef.io>"
pkg_license=('lgpl')
pkg_source=http://www.mpfr.org/mpfr-current/${pkg_name}-${pkg_version}.tar.xz
pkg_shasum=6835a08bd992c8257641791e9a6a2b35b02336c8de26d0a8577953747e514a16
pkg_build_deps=(chef/binutils)
pkg_deps=(chef/glibc chef/gmp)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_gpg_key=3853DA6B

do_prepare() {
  find . -iname "ltmain.sh" | while read file; do
    build_line "Fixing libtool script $file"
    sed -i -e 's^eval sys_lib_.*search_path=.*^^' "$file"
  done

  # TODO: We need a more clever way to calculate/determine the path to ld-*.so
  LDFLAGS="$LDFLAGS -Wl,-rpath=${LD_RUN_PATH},--enable-new-dtags"
  LDFLAGS="$LDFLAGS -Wl,--dynamic-linker=$(pkg_path_for glibc)/lib/ld-2.22.so"
  export LDFLAGS
  build_line "Updating LDFLAGS=$LDFLAGS"
}

do_build() {
  ./configure \
    --prefix=$pkg_prefix \
    --with-gmp=$(pkg_path_for chef/gmp) \
    --enable-thread-safe
  make

  if [ -n "${DO_CHECK}" ]; then
    make check
  fi
}