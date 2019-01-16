TOOL_NAME = AarKayRunner 
INSTALL_NAME = aarkay
SHORT_NAME = rk
version = "v0.3.1"

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(INSTALL_NAME)
PROD_INSTALL_PATH = $(PREFIX)/bin/$(SHORT_NAME)
DEV_INSTALL_PATH = $(PREFIX)/bin/$(SHORT_NAME)d
BUILD_PATH = .build/release/$(TOOL_NAME)

.PHONY: build clean dev install release test uninstall

install: test
	set -e
	mkdir -p $(PREFIX)/bin
	cp -f $(BUILD_PATH) $(PROD_INSTALL_PATH)

dev: test
	set -e
	mkdir -p $(PREFIX)/bin
	rm -f $(DEV_INSTALL_PATH)
	cp -f $(BUILD_PATH) $(DEV_INSTALL_PATH)

release: test
	set -e
	rm -f AarKay-${version}.zip
	rm -rf bin && mkdir -p bin
	cp -f -f $(BUILD_PATH) bin/$(INSTALL_NAME)
	zip -r AarKay-${version}.zip bin/$(INSTALL_NAME)
	shasum -a 256 -b AarKay-${version}.zip | awk '{print $$1}'
	rm -rf bin 

clean:
	set -e
	swift package clean

build: clean
	set -e
	swift build --disable-sandbox -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12" -Xswiftc -static-stdlib -c release

test: build
	set -e
	swift test -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"

uninstall:
	set -e
	rm -f $(PROD_INSTALL_PATH)
