# Merge Script

# 1
# Set bash script to exit immediately if any commands fail.
set -e

# 2
# Setup some constants for use later on.
FRAMEWORK_NAME="GetSocialCapture"
TARGET_DIR="${PROJECT_DIR}/../bin"

rm -rf "${TARGET_DIR}"
mkdir "${TARGET_DIR}"

# 3
# Build the framework for device and for simulator (using all needed architectures).

echo "${BUILD_DIR}"

xcodebuild \
-scheme "${FRAMEWORK_NAME}" \
-configuration Release \
-arch arm64 -arch armv7 \
only_active_arch=no \
defines_module=yes \
-sdk "iphoneos" \
BITCODE_GENERATION_MODE=bitcode \
STRIP_INSTALLED_PRODUCT=YES \
STRIP_STYLE=all \
BUILD_DIR=${BUILD_DIR} \
build

xcodebuild \
-scheme "${FRAMEWORK_NAME}" \
-configuration Release \
-arch x86_64 -arch i386 \
only_active_arch=no \
defines_module=yes \
-sdk "iphonesimulator" \
BITCODE_GENERATION_MODE=bitcode \
STRIP_INSTALLED_PRODUCT=YES \
STRIP_STYLE=all \
BUILD_DIR=${BUILD_DIR} \
build

# 4
# Remove .framework file if exists in products folder from previous run.
if [ -d "${TARGET_DIR}/${FRAMEWORK_NAME}.framework" ]; then
rm -rf "${TARGET_DIR}/${FRAMEWORK_NAME}.framework"
fi

# 5
# Copy the device version of framework to products folder .
echo "cp -R ${BUILD_DIR}/Release-iphoneos/${FRAMEWORK_NAME}.framework ${TARGET_DIR}/${FRAMEWORK_NAME}.framework"

cp -R "${BUILD_DIR}/Release-iphoneos/${FRAMEWORK_NAME}.framework" "${TARGET_DIR}/${FRAMEWORK_NAME}.framework"

echo "Copy framework step finished."

# 6
# Replace the framework executable within the framework with
# a new version created by merging the device and simulator
# frameworks' executables with lipo.
lipo -create -output "${TARGET_DIR}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "${BUILD_DIR}/Release-iphoneos/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "${BUILD_DIR}/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

echo "Lipo step finished."

# 7
# Copy the Swift module mappings for the simulator into the
# framework.  The device mappings already exist from step 5.
cp -R "${BUILD_DIR}/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/module.modulemap" "${TARGET_DIR}/${FRAMEWORK_NAME}.framework/Modules/"

echo "Copy module mapping finished."

echo "Universal framework generated, output ${TARGET_DIR}/${FRAMEWORK_NAME}.framework"
