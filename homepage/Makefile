
all: fetch

build/bootstrap.zip:
	mkdir build
	curl -Ls https://github.com/twbs/bootstrap/releases/download/v4.3.1/bootstrap-4.3.1-dist.zip -o build/bootstrap.zip

themes/eclipse-iot-packages/static/jquery.min.js:
	curl -Ls https://code.jquery.com/jquery-3.4.1.min.js -o "$@"

themes/eclipse-iot-packages/static/popper.min.js:
	curl -Ls https://unpkg.com/popper.js@1.15.0/dist/umd/popper.min.js -o "$@"

fetch: build/bootstrap.zip themes/eclipse-iot-packages/static/jquery.min.js themes/eclipse-iot-packages/static/popper.min.js
	rm -Rf themes/eclipse-iot-packages/static/bootstrap
	mkdir -p themes/eclipse-iot-packages/static/bootstrap
	cd themes/eclipse-iot-packages/static/bootstrap && unzip -qq -j  ../../../../build/bootstrap.zip

clean:
	-rm themes/eclipse-iot-packages/static/jquery.min.js
	-rm themes/eclipse-iot-packages/static/popper.min.js
	-rm -Rf build

.PHONY: all fetch clean
