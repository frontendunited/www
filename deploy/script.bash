#!/usr/bin/env bash
set -ex

branch=$TRAVIS_BRANCH
site_dir="~/frontendunited.io"

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "=> Skipping deploy for pull request."
  exit 0
fi

if [[ "$branch" = "production" ]]; then
  root_dir="$site_dir/public"
elif [[ "$branch" = "master" ]]; then
  root_dir="$site_dir/public/staging"
else
  echo "=> Skipping deploy for $branch branch"
  exit 0
fi

mkdir -p $site_dir
openssl aes-256-cbc -K $encrypted_994a64a0c4e9_key -iv $encrypted_994a64a0c4e9_iv -in deploy/ssh_private_key.enc -out deploy/ssh_private_key -d
chmod 600 deploy/ssh_private_key
ssh-keyscan -t rsa frontendunited.io >> ~/.ssh/known_hosts
chmod 600 ~/.ssh/known_hosts
ssh -i deploy/ssh_private_key frontendunited@frontendunited.io "rm -rf $root_dir"
ssh -i deploy/ssh_private_key frontendunited@frontendunited.io "mkdir -p $root_dir"
scp -r -i deploy/ssh_private_key ./public/* frontendunited@frontendunited.io:$root_dir
find $site_dir -type f -exec chmod 644 {} \;
find $site_dir -type d -exec chmod 775 {} \;
