#!/bin/sh

export INPUT_CHANGELOG_FILE=CHANGELOG.md
export INPUT_TICKET_URL_PREFIX=http://test.test/test/
export INPUT_VERSION=
export INPUT_BRANCH_NAME=TIX-1234/Added/my_cool_feature

../entrypoint.sh
