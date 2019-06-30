#!/bin/sh

TAGS_RESPONSE=`curl -X GET \
    -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/justindhill/YDNYNAB/tags"`

LATEST_TAG_SHA=`echo $TAGS_RESPONSE | jq -r '.[0].commit.sha'`
if [[ "$TRAVIS_COMMIT" == "$LATEST_TAG_SHA" && "$TRAVIS_EVENT_TYPE" == "cron" ]]; then
    echo "This commit has already been built. Bailing."
    exit 0
fi

set -o pipefail && xcodebuild -workspace "YDNYNAB.xcworkspace" -scheme "YDNYNAB" -configuration "Release" -derivedDataPath "$TRAVIS_BUILD_DIR/build-out" clean build | xcpretty

if [ "$TRAVIS_EVENT_TYPE" != "cron" ]; then
    echo "Not a nightly build, skipping upload to GitHub."
    exit 0
fi

mkdir "$TRAVIS_BUILD_DIR/build-out/Package"
cd "$TRAVIS_BUILD_DIR/build-out/Build/Products/Release"

SHORT_HASH=`echo $TRAVIS_COMMIT | cut -c-6 -`
APP_ARCHIVE_NAME="YDNYNAB-$SHORT_HASH.zip"
DSYM_ARCHIVE_NAME="YDNYNAB-dSYM-$SHORT_HASH.zip"
RELEASE_NAME="nightly-travis-$TRAVIS_JOB_NUMBER"

if [[ ! -d "YDNYNAB.app" || ! -d "YDNYNAB.app.dSYM" ]]; then
  echo "App or dSYM bundle is missing"
  exit 1
fi

zip -r "$TRAVIS_BUILD_DIR/build-out/Package/$APP_ARCHIVE_NAME" "YDNYNAB.app"
zip -r "$TRAVIS_BUILD_DIR/build-out/Package/$DSYM_ARCHIVE_NAME" "YDNYNAB.app.dSYM"

cd "$TRAVIS_BUILD_DIR/build-out/Package"

RELEASE_CREATE_RESPONSE=`curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -d "{\
          \"tag_name\": \"$RELEASE_NAME\",\
          \"name\": \"$RELEASE_NAME\",\
          \"target_commitish\": \"master\",\
          \"draft\": false,\
          \"prerelease\": true\
        }" \
    "https://api.github.com/repos/justindhill/YDNYNAB/releases"`

RELEASE_ID=`echo $RELEASE_CREATE_RESPONSE | jq -r .id`

curl -X POST \
    -H "Content-Type: application/zip"\
    -H "Authorization: token $GITHUB_TOKEN"\
    --data-binary @$APP_ARCHIVE_NAME \
    "https://uploads.github.com/repos/justindhill/YDNYNAB/releases/$RELEASE_ID/assets?name=YDNYNAB.app.zip"

