
.PHONEY: run update clean

clean:
	rm -rf public
	rm -rf resources

update:
	hugo mod get -u

run:
	hugo server -D

public resources:
	hugo --minify

lint:
	# brew install markdownlint-cli
	markdownlint content/*** --fix
