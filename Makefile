# Bootstrap and apply the Nix + Home Manager setup; install.sh drives these on a new machine.

.PHONY: prepare install-deps apply apps test-vm

prepare:
	curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes

install-deps:
	nix-channel --add https://nixos.org/channels/nixos-25.11 nixpkgs
	nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
	nix-channel --update

# home.nix installs home-manager itself, so the first run borrows it from the channel
# instead of putting a second copy in the nix-env profile, which would conflict.
apply:
	rm -f ~/.zshrc.zwc
	if command -v home-manager >/dev/null 2>&1; then \
		home-manager switch -b backup --file $(CURDIR)/home.nix; \
	else \
		nix-shell -E 'with import <nixpkgs> {}; mkShell { packages = [ (import <home-manager> {}).home-manager ]; }' \
			--run "home-manager switch -b backup --file $(CURDIR)/home.nix"; \
	fi

# Install the apps in apps.txt (home.nix provides the install-apps command).
apps:
	install-apps

# Boot a throwaway macOS VM, run install.sh in it and check the result (see test-vm.sh).
test-vm:
	./test-vm.sh
