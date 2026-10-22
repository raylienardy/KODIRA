#!/bin/bash
set -e
cd "$(dirname "$0")/.."
cd app
flutter build apk --release --split-per-abi \
  --dart-define-from-file=.env "$@"
echo "APK outputs:"
ls -lh build/app/outputs/flutter-apk/*.apk
