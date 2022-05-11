#!/bin/bash
# This Script acts as the Entrypoint for the Docker Image, providing the needed
# Functionality for the GitHub Actions - JAKR: Just Another Keyword Releaser - 
# to work as expected, by creating a Release based on a Git Commit Message Keyword
# Notes:
# - Env Vars like GITHUB_* are in the GitHub Actions Working Environment

# ERREXIT - Exit at first Script Error
set -e

# Git Message containing the keyword
KEYWORD='RELEASE-'
RELEASER='JARK'

# Functions definition
function log_message {
    # This Function act as logger for better finding of messages in the output
    # IMPUT as String Message (i.e. log_message "this message")
    MESSAGE=${1}
    NUM_OF_CHARS=$(echo ${MESSAGE} | wc -c)
    NUM_OF_CHARS=$((${NUM_OF_CHARS} + 3))
    LINE_OF_CHARS=$(printf %${NUM_OF_CHARS}s | tr " " '#')
    echo ${LINE_OF_CHARS}
    echo "# ${MESSAGE} #"
    echo ${LINE_OF_CHARS}

}


function get_event_path {
    # This Function will define the Event to process
    # by Checking if running on a GitHub Actions, otherwise use Sample Event
    if [ "${GITHUB_EVENT_PATH}" ]; then
        EVENT_PATH=$GITHUB_EVENT_PATH

    elif [ -f ./sample_push_event.json ]; then
        EVENT_PATH='./sample_push_event.json'
        LOCAL_TEST='true'

    else

        log_message "JSON Event, Not Found."
        exit 1
    fi

    log_message "Processing EVENT_PATH: ${EVENT_PATH}"
}


function get_environment {
    # This Function will display:
    # - Environment Variables
    # - JSON Event
    log_message "Logging Environment"
    env
    jq . < $EVENT_PATH
}


function set_github_release {
    # This Function will check the exact supported KEYWORD to process the GitHub Release
    # based on the branch name and current date for version
    COMMIT_MSG=$(jq '.commits[].message' < ${EVENT_PATH} | grep 'RELEASE-' | head -1 )
    log_message ${COMMIT_MSG}

    TRUE=$(echo ${COMMIT_MSG} | grep -w "${KEYWORD}")
    log_message ${TRUE}
    if [ "${TRUE}" ]; then
        if [ "${LOCAL_TEST}" ]; then
            log_message "[TESTING] - KEYWORD:${KEYWORD} - was found, no GitHub Release created."
            exit 0

        else
            # Get Branch and Version
            # NOTE: git global setting needed to run in GitHub Workflow Environment
            git config --global --add safe.directory /github/workspace
            MASTER=$(git rev-parse --abbrev-ref HEAD)
            RELEASE_VERSION=$(echo ${COMMIT_MSG} | awk -F 'RELEASE-' '{print $NF}' | awk -F ' ' '{print $1}')
            DATE=$(date +%F.%s)

            # Set DATA Body for GitHub Release API            
            BODY='{"tag_name":"'"v${RELEASE_VERSION}"'","target_commitish":"'"${MASTER}"'","name":"'"v${RELEASE_VERSION}"'","body":"'"${DATE}"'","draft":false,"prerelease":false}'

            log_message "POST data for GitHub Release API"
            echo ${BODY}

            # GitHub Release API
            curl -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${API_TOKEN}" https://api.github.com/repos/${GITHUB_REPOSITORY}/releases -d ${BODY} || exit 1
            exit 0
        fi

    else
        # exit gracefully
        log_message "KEYWORD: ${KEYWORD} - Not Found, Nothing to process."
        exit 0

    fi

}

# Run
log_message "GitHub Keyboard Releaser:${RELEASER} Starting Execution"
get_event_path
get_environment
set_github_release
