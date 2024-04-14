#!/bin/bash
# Set the GitHub Personal Access Token from the secret
TOKEN="nil"

# Set your GitHub username and repository name
USERNAME="Victoria-OA"
REPO="--Capstone--"

# Get the workflow ID
WORKFLOW_ID=$(curl -s -X GET \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $TOKEN" \
  https://api.github.com/repos/$USERNAME/$REPO/actions/workflows | jq -r '.workflows[0].id')

# Trigger the workflow run using cURL
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $TOKEN" \
  https://api.github.com/repos/$USERNAME/$REPO/actions/workflows/$WORKFLOW_ID/dispatches \
  -d '{"ref":"main"}'
