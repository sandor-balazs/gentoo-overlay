# Copyright (c) 2019 Sándor Balázs
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils

VERSION_NUMBER="$(ver_cut 1-3)"
BUILD_NUMBER="$(ver_cut 4-6)"

DESCRIPTION="Professional Java IDE"
HOMEPAGE="https://www.jetbrains.com/idea"
SRC_URI="https://download.jetbrains.com/idea/ideaIC-${VERSION_NUMBER}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"

IUSE=""

S="${WORKDIR}/idea-IC-${BUILD_NUMBER}"

src_prepare() {
	eapply_user
}

src_install() {
	local destination="/opt/${PN}"

	insinto "${destination}"
	doins -r *
	fperms 755 "${destination}"/bin/{format.sh,fsnotifier{,64},idea.sh,inspect.sh,printenv.py,restart.py}
	fperms -R 755 "${destination}"/jbr/bin

	newicon "bin/idea.png" "idea.png"
	make_wrapper idea "${destination}/bin/idea.sh"
	make_desktop_entry idea "IntelliJ IDEA Community" idea "Development;IDE"

	# Increase the limit for inotify watches
	# https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	mkdir -p "${D}/etc/sysctl.d/" || die
	echo "fs.inotify.max_user_watches = 524288" > "${D}/etc/sysctl.d/30-idea-inotify-watches.conf" || die
}
