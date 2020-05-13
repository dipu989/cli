GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
BINARY_NAME=civo
BINARY_MAC=$(BINARY_NAME)_mac
BINARY_LINUX=$(BINARY_NAME)_linux
BINARY_WINDOWS=$(BINARY_NAME)_windows

all: build
test:
	$(GOTEST) -v ./...
clean:
	$(GOCLEAN)
	rm -f dest/
	git fetch --tags
build:
	mkdir -p dest
	$(eval VERSION_CLI=$(shell git tag | tail -1 | cut -d "v" -f 2))
	$(eval COMMIT_CLI=$(shell git log --format="%H" -n 1))
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -o dest/$(BINARY_LINUX) -ldflags "-s -X github.com/civo/cli/cmd.VersionCli=$(VERSION_CLI) -X github.com/civo/cli/cmd.CommitCli=$(COMMIT_CLI) -X github.com/civo/cli/cmd.DateCli=$(shell date +%FT%T%Z)" -v
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 $(GOBUILD) -o dest/$(BINARY_MAC) -ldflags "-s -X github.com/civo/cli/cmd.VersionCli=$(VERSION_CLI) -X github.com/civo/cli/cmd.CommitCli=$(COMMIT_CLI) -X github.com/civo/cli/cmd.DateCli=$(shell date +%FT%T%Z)" -v
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 $(GOBUILD) -o dest/$(BINARY_WINDOWS) -ldflags "-s -X github.com/civo/cli/cmd.VersionCli=$(VERSION_CLI) -X github.com/civo/cli/cmd.CommitCli=$(COMMIT_CLI) -X github.com/civo/cli/cmd.DateCli=$(shell date +%FT%T%Z)" -v
	rm -f civo
	ln -s dest/$(BINARY_MAC) civo
release: build
	# extract version from app
	VERSION=`dest/civo_mac version -q`
	# Set a github token with git config --global github.token "....."
	# $ ghr \
  #   -t TOKEN \        # Set Github API Token
  #   -u USERNAME \     # Set Github username
  #   -r REPO \         # Set repository name
  #   -c COMMIT \       # Set target commitish, branch or commit SHA
  #   -n TITLE \        # Set release title
  #   -b BODY \         # Set text describing the contents of the release
  #   -p NUM \          # Set amount of parallelism (Default is number of CPU)
  #   -delete \         # Delete release and its git tag in advance if it exists (same as -recreate)
  #   -replace          # Replace artifacts if it is already uploaded
  #   -draft \          # Release as draft (Unpublish)
  #   -soft \           # Stop uploading if the same tag already exists
  #   -prerelease \     # Create prerelease
  #   TAG PATH
	# ghr $VERSION pkg/
	# https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap