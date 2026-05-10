#!/usr/bin/env bash
set -e

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found. Install Flutter first."
  exit 1
fi

flutter create .
flutter pub get
