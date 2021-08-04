#!/bin/sh

set -e

tmpFilePath=changelog.tmp
changelogPath=${INPUT_CHANGELOG_FILE}
urlPrefix=${INPUT_TICKET_URL_PREFIX}
version=${INPUT_VERSION}
fullDate=$(date +"%F")
branchName=${INPUT_BRANCH_NAME}

ticketLine="- ${ticket}"

if [[ -z ${version}  ]]; then
  echo "Staging changes functionality isn't finished yet."
  exit 1
fi

echo "branchName passed in value: ${branchName}"

if [[ -z ${branchName} ]]; then
  branchName=$(git rev-parse --abbrev-ref HEAD)
fi
echo "Using branch name: ${branchName}"

ticket=$(echo ${branchName} | awk -F'/' '{print($1)}')
changeType=$(echo ${branchName} | awk -F'/' '{print($2)}')
message=$(echo ${branchName} | awk -F'/' '{print($3)}' | tr '_' ' ')

if changeType | grep -Eq '(Added|Changed|Deprecated|Removed|Fixed|Security)'; then
    echo "ChangeType: ${changeType}"
else
  echo "Invalid ChangeType: ${changeType}"
  exit 1
fi

if [[ -z ${message} ]]; then
  echo "Could not parse branchName: ${branchName}"
  exit 1
fi

if [[ -n ${urlPrefix} ]]; then
  ticketLine="- [${ticket}](${urlPrefix}${ticket})"
fi

change_md="## [${version}] - ${fullDate}
### ${changeType}
- Merged \"${message}\"
### Referenced Issues
${ticketLine}"

# Check if file exists, if not, create blank template.
if [ -e "${changelogPath}" ]; then
  echo "File exists, appending..."
else
  echo "# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## End of Changelog
" > "$changelogPath"
fi

#Read template and insert data to create temp file
while read data; do
  if [ "${data}" = "## [Unreleased]" ]; then
    echo "${data}

${change_md}
" >> ${tmpFilePath}
  else
    echo $data >> ${tmpFilePath}
  fi
done < "${changelogPath}"

# delete orig and rename temp file.
rm "${changelogPath}"
mv ${tmpFilePath} "${changelogPath}"

echo "::set-output name=change_md::${change_md}"
