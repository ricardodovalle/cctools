build_cloog() {
    PKG=cloog
    PKG_VERSION=$cloog_version
    PKG_DESC="Chunky Loop Generator."
    O_FILE=$SRC_PREFIX/$PKG/$PKG-$PKG_VERSION.tar.gz
    S_DIR=$src_dir/${PKG}-${PKG_VERSION}
    B_DIR=$build_dir/$PKG

    c_tag $PKG && return

    banner "Build $PKG"

    pushd .

#    tar zxf $O_FILE -C $src_dir || error "tar zxf $O_FILE"

#    cd $S_DIR
#    patch -p1 < $patch_dir/${PKG}-${PKG_VERSION}.patch

    mkdir -p $B_DIR
    cd $B_DIR

    $S_DIR/configure \
	--target=$TARGET_ARCH \
	--host=$TARGET_ARCH \
	--prefix=$TMPINST_DIR \
	--with-gmp=system \
	--with-gmp-prefix=$TMPINST_DIR \
	--with-isl=system \
	--with-isl-prefix=$TMPINST_DIR \
	--disable-werror \
	--disable-static \
	--enable-shared || error "configure"

    $MAKE $MAKEARGS || error "make $MAKEARGS"

    $MAKE install || error "make install"

    $MAKE install prefix=${TMPINST_DIR}/${PKG}/cctools || error "package install"

    rm -rf ${TMPINST_DIR}/${PKG}/cctools/share
    rm -rf ${TMPINST_DIR}/${PKG}/cctools/bin
    rm -f ${TMPINST_DIR}/${PKG}/cctools/lib/*.py
    rm -rf ${TMPINST_DIR}/${PKG}/cctools/lib/pkgconfig
    rm -f ${TMPINST_DIR}/${PKG}/cctools/lib/*.*a

    ${TARGET_ARCH}-strip ${TMPINST_DIR}/${PKG}/cctools/lib/*.so*

    rm -rf   ${TMPINST_DIR}/${PKG}-dev/cctools/${TARGET_ARCH}
    mkdir -p ${TMPINST_DIR}/${PKG}-dev/cctools/${TARGET_ARCH}
    mv ${TMPINST_DIR}/${PKG}/cctools/include ${TMPINST_DIR}/${PKG}-dev/cctools/${TARGET_ARCH}/

    local filename="lib${PKG}_${PKG_VERSION}_${PKG_ARCH}.zip"
    build_package_desc ${TMPINST_DIR}/${PKG} $filename lib${PKG} $PKG_VERSION $PKG_ARCH "$PKG_DESC"
    cd ${TMPINST_DIR}/${PKG}
    remove_rpath cctools
    rm -f ${REPO_DIR}/$filename; zip -r9y ${REPO_DIR}/$filename cctools pkgdesc

    PKG_DESC="Chunky Loop Generator (development files)."
    local filename="lib${PKG}-dev_${PKG_VERSION}_${PKG_ARCH}.zip"
    build_package_desc ${TMPINST_DIR}/${PKG}-dev $filename lib${PKG}-dev $PKG_VERSION $PKG_ARCH "$PKG_DESC" "lib${PKG}"
    cd ${TMPINST_DIR}/${PKG}-dev
    remove_rpath cctools
    rm -f ${REPO_DIR}/$filename; zip -r9y ${REPO_DIR}/$filename cctools pkgdesc

    popd
    s_tag $PKG
}
