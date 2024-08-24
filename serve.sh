ip=$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2 | head -n1 | xargs)

if [[ $1 == "run" ]]; then
  echo
  echo $ip | xargs -I {} echo "Serving on http://{}:1126"
  echo
  flutter run -d web-server \
    --web-port 1126 \
    --web-hostname 0.0.0.0 \
    -t lib/main.dart
  exit
fi

if [[ $1 == "build" ]]; then
  flutter build web \
    --source-maps \
    --no-web-resources-cdn \
    -t lib/main.dart

  if [[ $? != 0 ]]; then
    exit
  fi

  if [[ $2 == "serve" ]]; then
    live-server ./build/web --host=$ip --port=8080 --no-browser --verbose
  fi
  exit
fi
