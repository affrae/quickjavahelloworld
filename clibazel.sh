#! /bin/zsh

GIT_BRANCH="refs/heads/$(git branch --show-current)"
GIT_HASH=$(git rev-parse HEAD)

ls
# helloworld.java
# codeql-runner-macos init \
#     --github-url 'https://github.com' \
#     --repository 'affrae/quickhelloworld' \
#     --languages 'java'

# . codeql-runner/codeql-env.sh

# bazel shutdown 

# bazel clean

# Execution from macOS
# $CODEQL_RUNNER bazel build --spawn_strategy=local --nouse_action_cache //:app

# codeql-runner-macos analyze \
#     --github-url 'https://github.com' \
#     --repository 'affrae/quickhelloworld' \
#     --commit $GIT_HASH \
#     --no-upload \
#     --ref $GIT_BRANCH

codeql database create java-database --language=java --command="bazel build --spawn_strategy=local --nouse_action_cache //:app"
