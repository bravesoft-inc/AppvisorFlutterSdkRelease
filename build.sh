#!/bin/bash

set -e

# Define a function to print messages in yellow
print_step() {
  echo -e "\033[33m$1\033[0m"
}

# Define a function to print messages in green
print_success() {
  echo -e "\033[32m$1\033[0m"
}

# Default value for the fetch flag
fetch_flag=true

# Parse command-line arguments
while getopts ":f:" opt; do
  case ${opt} in
    f)
      fetch_flag=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." 1>&2
      exit 1
      ;;
  esac
done

if [ "$fetch_flag" = true ]; then
  print_step "Fetching the latest changes"
  git fetch
fi

print_step "Getting the version from pubspec.yaml"
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | tr -d '\r')

if [ -z "$VERSION" ]; then
  echo "Version not found in pubspec.yaml"
  exit 1
fi

print_step "Copying necessary libraries from the dependencies repository"
mkdir -p dist
cp assets/libs/av-android-stg-*.zip dist/
cp assets/libs/av-android-prod-*.zip dist/
cp assets/libs/av-ios-stg-*.zip dist/
cp assets/libs/av-ios-prod-*.zip dist/

mkdir -p dist/temp_libs

print_step "Unzipping staging libraries"
unzip -o dist/av-android-stg-*.zip -d dist/temp_libs/staging
unzip -o dist/av-ios-stg-*.zip -d dist/temp_libs/staging

print_step "Unzipping production libraries"
unzip -o dist/av-android-prod-*.zip -d dist/temp_libs/production
unzip -o dist/av-ios-prod-*.zip -d dist/temp_libs/production

print_step "Deleting the zip files after unzipping"
rm dist/av-android-stg-*.zip dist/av-android-prod-*.zip dist/av-ios-stg-*.zip dist/av-ios-prod-*.zip

# Function to package the Flutter plugin
package_plugin() {
  local build_type=$1
  local temp_dir="dist/temp_libs/$build_type"
  local package_dir="dist/package_temp_$build_type"

  print_step "Packaging the Flutter plugin for $build_type"

  # Create a temporary directory for the package
  mkdir -p $package_dir

  # Use rsync to copy files, excluding unwanted directories and files
  rsync -av --progress . $package_dir --exclude temp_libs --exclude '*.zip' --exclude example --exclude assets --exclude test --exclude 'package_temp_*' --exclude .git --exclude .github --exclude dist

  # Replace Android AAR
  cp $temp_dir/lib/appvisor-release.aar $package_dir/android/androidSdk/avp.aar

  # Replace iOS XCFramework
  rm -rf $package_dir/ios/AppVisorSDK.xcframework
  mv $temp_dir/AppVisorSDK.xcframework $package_dir/ios/AppVisorSDK.xcframework

  # Create the zip file from the package directory
  cd $package_dir
  zip -r ../../dist/avp-flutter-sdk-${build_type}-${VERSION}.zip .
  cd ../..

  # Clean up the temporary directory
  rm -rf $package_dir
}

print_step "Packaging the staging version"
package_plugin "staging"

print_step "Moving the staging zip file out of the dist directory temporarily"
mv dist/avp-flutter-sdk-staging-${VERSION}.zip .

print_step "Packaging the production version"
package_plugin "production"

print_step "Moving the staging zip file back into the dist directory"
mv avp-flutter-sdk-staging-${VERSION}.zip dist/

print_step "Cleaning up the dist directory, leaving only the zip files"
find dist -mindepth 1 -not -name 'avp-flutter-sdk-*.zip' -delete

print_success "Packaging complete. The output files are in the dist directory:"
print_success "$(ls dist/avp-flutter-sdk-*.zip)"