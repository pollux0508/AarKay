TOOL_NAME = AarKayRunner 
INSTALL_NAME = aarkay
SHORT_NAME = rk

PREFIX = /usr/local
PROD_INSTALL_PATH = $(PREFIX)/bin/$(SHORT_NAME)
DEV_INSTALL_PATH = $(PREFIX)/bin/$(SHORT_NAME)d
BUILD_PATH = .build/release/$(TOOL_NAME)

.PHONY: build clean dev install release test uninstall

install: test build
	mkdir -p $(PREFIX)/bin
	cp -f $(BUILD_PATH) $(PROD_INSTALL_PATH)

dev: test build
	mkdir -p $(PREFIX)/bin
	rm -f $(DEV_INSTALL_PATH)
	cp -f $(BUILD_PATH) $(DEV_INSTALL_PATH)

version-bump:
	set -e
	sh ./scripts/version-bump ${version}

release: test version-bump build
	set -e
	mkdir -p bin
	cp -f -f $(BUILD_PATH) bin/$(INSTALL_NAME)
	zip -r AarKay-v${version}.zip bin/$(INSTALL_NAME)
	rm -rf bin 
	sh ./scripts/brew-publish ${version}
	git push origin develop && git push origin --tags

clean:
	set -e
	swift package clean

build:
	swift build --disable-sandbox -Xswiftc "-suppress-warnings" -c release

test: clean
	swift test -Xswiftc "-suppress-warnings"

uninstall:
	set -e
	rm -f $(PROD_INSTALL_PATH)
