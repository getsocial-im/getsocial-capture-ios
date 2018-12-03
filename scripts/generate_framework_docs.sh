#!/bin/sh

#  generate_docs.sh
#  GetSocialSDK
#
#  Created by Demian Denker on 08/08/14.
#  Copyright (c) 2014 GetSocial. All rights reserved.

APPLEDOC_PATH=`which appledoc`
if [ $APPLEDOC_PATH ]; then
$APPLEDOC_PATH \
--output "${PROJECT_DIR}/../docs/" \
"${PROJECT_DIR}/../../scripts/GetSocialCaptureDocs.plist" \
"${PROJECT_DIR}/GetSocialCapture/GetSocialCapture.h" \
"${PROJECT_DIR}/GetSocialCapture/GetSocialCaptureSession.h" \
"${PROJECT_DIR}/GetSocialCapture/GetSocialCaptureSessionConfiguration.h" \
"${PROJECT_DIR}/GetSocialCapture/GetSocialCaptureResult.h" \
"${PROJECT_DIR}/GetSocialCapture/GetSocialCaptureConfiguration.h" \
"${PROJECT_DIR}/GetSocialCapture/GetSocialCapturePreview.h" \

echo "Docs available: ${PROJECT_DIR}/../docs/"

else
echo "error: Missing appledoc"
exit 1
fi;
