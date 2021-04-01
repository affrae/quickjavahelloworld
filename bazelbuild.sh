#! /bin/zsh

if [[ "$1" == "macos" ]] || [[ "$1" == "linux" ]]
then

  GIT_BRANCH="refs/heads/$(git branch --show-current)"
  GIT_HASH=$(git rev-parse HEAD)

  THEPATH=$PWD
  BUNDLE=$THEPATH/codeqlbinaries/$1
  THECONFIGFILE=$THEPATH/.github/codeql/codeql-config.yml

  if test -d "$BUNDLE"; then
    echo "Executing with:"
    echo "... the path to where we executed this from: $THEPATH"
    echo "... codeql cli binary: $BUNDLE/codeql"
    echo "... config file: $THECONFIGFILE"

    rm -rf $THEPATH/bazel-*

    export SEMMLE_JAVA_INTERCEPT_VERBOSITY=6
    export SEMMLE_JAVA_INTERCEPT_LOG_FILE=true
    
    codeql-runner-$1 init \
      --github-url 'https://github.com' \
      --repository 'affrae/quickhelloworld' \
      --languages 'java' \
      --codeql-path $BUNDLE/codeql \
      --config-file $THECONFIGFILE \
      --debug
    
    . $THEPATH/codeql-runner/codeql-env.sh

    echo "\$CODEQL_RUNNER = $CODEQL_RUNNER" 

    bazel shutdown 

    bazel clean --expunge

    if [[ "$1" == "macos" ]]
    then
    # Execution from macOS
      echo "\$CODEQL_RUNNER = $CODEQL_RUNNER" 
      $CODEQL_RUNNER bazel build --spawn_strategy=local --nouse_action_cache //:app
    else
      bazel build --spawn_strategy=local --nouse_action_cache //:app
    fi

    codeql-runner-$1 analyze --github-url 'https://github.com' --repository 'affrae/quickhelloworld' --commit $GIT_HASH --no-upload --ref $GIT_BRANCH

    APP=$THEPATH/bazel-bin/app

    if test -f "$APP"; then
      echo "Executing $APP"
      $THEPATH/bazel-bin/app
    else 
      echo "$APP does not exist"
      exit 3
    fi
  else 
    echo "$BUNDLE does not exist"
    exit 2
  fi
else
  echo "Usage $0 macos|linux"
  exit 1
fi