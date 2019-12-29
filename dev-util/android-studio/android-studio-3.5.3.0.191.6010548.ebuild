# Copyright (c) 2019 Sándor Balázs
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils

RESTRICT="strip"
QA_PREBUILT="
	opt/${PN}/bin/fsnotifier*
	opt/${PN}/bin/libdbm64.so
	opt/${PN}/bin/lldb/*
	opt/${PN}/jre/*
	opt/${PN}/lib/pty4j-native/linux/*/libpty.so
	opt/${PN}/plugins/android/lib/libwebp_jni*.so
	opt/${PN}/plugins/android/resources/installer/*
	opt/${PN}/plugins/android/resources/perfetto/*
	opt/${PN}/plugins/android/resources/simpleperf/*
	opt/${PN}/plugins/android/resources/transport/*
"

VERSION_NUMBER=$(ver_cut 1-4)
BUILD_NUMBER=$(ver_cut 5-6)

DESCRIPTION="Official IDE for Android app development based on IntelliJ IDEA"
HOMEPAGE="http://developer.android.com/sdk/installing/studio.html"
SRC_URI="https://dl.google.com/dl/android/studio/ide-zips/${VERSION_NUMBER}/${PN}-ide-${BUILD_NUMBER}-linux.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"

IUSE=""

BDEPEND="dev-util/patchelf"

S=${WORKDIR}/${PN}

src_prepare() {
	eapply_user
}

src_compile() {
	patchelf --set-rpath '$ORIGIN' bin/lldb/lib/readline.so || die "Failed to fix insecure RPATH"
}

src_install() {
	local destination="/opt/${PN}"

	insinto "${destination}"
	doins -r *

	fperms 755 "${destination}"/bin/{format.sh,fsnotifier{,64},inspect.sh,printenv.py,restart.py,studio.sh}
	fperms -R 755 "${destination}"/bin/lldb/{android,bin}

	fperms 755 "${destination}"/jre/jre/lib/jexec
	fperms -R 755 "${destination}"/jre/{bin,jre/bin}

	newicon "bin/studio.png" "${PN}.png"
	make_wrapper ${PN} "${destination}/bin/studio.sh"
	make_desktop_entry ${PN} "Android Studio" ${PN} "Development;IDE"
}
