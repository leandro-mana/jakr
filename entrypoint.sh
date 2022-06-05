#!/bin/bash
# This Script acts as the Entrypoint for the Docker Image, providing the needed
# functionality for the GitHub Actions - JAKR: Just Another Keyword Releaser - 
# by creating a release based on a Git head commit message keyword
# Notes:
# - Env Vars like GITHUB_* are in the GitHub Actions Working Environment
# - API_TOKEN is a repository secret that allows admin access to repository for release create
# - KEYWORD Defined in Dockerfile, value provided in Makefile, otherwise default in this script
# ERREXIT - Exit at first Script Error
set -e

# Git Message containing the keyword
KEYWORD=${KEYWORD:-RELEASE-}
RELEASER='JARK'

# Functions definition
function log_message {
    # This Function act as logger for better finding of messages in the output
    # IMPUT as String Message (i.e. log_message "this message")
    MESSAGE=${*}
    NUM_OF_CHARS=$(echo ${MESSAGE} | wc -c)
    NUM_OF_CHARS=$((${NUM_OF_CHARS} + 3))
    LINE_OF_CHARS=$(printf %${NUM_OF_CHARS}s | tr " " '#')
    echo ${LINE_OF_CHARS}
    echo "# ${MESSAGE} #"
    echo ${LINE_OF_CHARS}

}


function get_event_path {
    # This Function will define the Event to process
    # by checking if running on a GitHub Actions, otherwise use a sample event
    EVENT_PATH='./sample_push_event.json'
    if [ "${GITHUB_EVENT_PATH}" ]; then
        EVENT_PATH=$GITHUB_EVENT_PATH

    else
        LOCAL_TEST='true'
        if [ ! -f ${EVENT_PATH} ]; then
            log_message "JSON Event, Not Found."
            exit 1
        fi

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
    RELEASE_VERSION=$(jq '.head_commit.message' < ${EVENT_PATH} | grep ${KEYWORD} | tr -d '"' | awk -F ${KEYWORD} '{print $NF}' | awk -F ' ' '{print $1}')
    if [ "${RELEASE_VERSION}" ]; then
        if [ "${LOCAL_TEST}" ]; then
            log_message "[TESTING] - KEYWORD:${KEYWORD} found, no GitHub Release created."
            log_message "[TESTING] - VERSION:${RELEASE_VERSION}"
            exit 0

        else
            if [  ]
            DATE=$(date +%F.%s)
            # Set DATA Body for GitHub Release API            
            BODY='{"tag_name":"'"v${RELEASE_VERSION}"'","name":"'"v${RELEASE_VERSION}"'","body":"'"${DATE}"'","draft":false,"prerelease":false}'

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

function run {
    # This function contains the business logic and wraps the flow for the execution
    log_message "GitHub Keyboard Releaser:${RELEASER} Starting Execution"
    get_event_path
    get_environment
    set_github_release
    log_message "run finished"

}

# Execution
run
