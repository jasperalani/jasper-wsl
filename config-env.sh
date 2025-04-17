#!/usr/bin/env bash

# ===============================================
# config-env.sh
#
# This script configures environment variables for your development setup.
#
# What this script does:
# 1. Checks that jwsl.env exists in the same directory as this script.
# 2. Optionally configures the Hugo project path by prompting for the location of hugo.toml.
#    - Validates the file and extracts the directory as HUGO_PROJECT_CONFIG_PATH.
#    - Appends the variable to jwsl.env (with user confirmation before replacing any existing value).
# 3. Optionally configures your Git user information by prompting for email and username.
#    - Appends GIT_USER_EMAIL and GIT_USER_NAME to jwsl.env (with user confirmation before replacing any existing value).
# ===============================================

ENV_FILE="$(dirname "$0")/jwsl.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE does not exist. Please follow README.md Installation, Step 2 to create it."
    exit 1
fi

# Helper function to update or append a variable in the env file, with confirmation if it exists
update_env_var() {
    local var_name="$1"
    local var_value="$2"
    if grep -q "^${var_name}=" "$ENV_FILE"; then
        current_var=$(grep "^${var_name}=" "$ENV_FILE")
        current_val="${current_var#*=}"
        echo "$var_name already exists: $current_val"
        read -rp "Do you want to replace it? (y/N): " replace
        if [[ ! "$replace" =~ ^[Yy]$ ]]; then
            echo "Skipped updating $var_name."
            return
        fi
        # Remove the existing variable
        sed -i "/^${var_name}=.*/d" "$ENV_FILE"
    fi
    echo "${var_name}=\"${var_value}\"" >> "$ENV_FILE"
    echo "Set $var_name."
}

# Ask user if they want to configure Hugo project
read -rp "Do you want to configure the Hugo project path? (y/N): " config_hugo
if [[ "$config_hugo" =~ ^[Yy]$ ]]; then
    read -rp "Enter the full path to your hugo.toml: " HUGO_TOML_PATH
    if [ ! -f "$HUGO_TOML_PATH" ]; then
        echo "File not found: $HUGO_TOML_PATH"
        exit 1
    fi
    if [[ "$(basename "$HUGO_TOML_PATH")" != "hugo.toml" ]]; then
        echo "Error: The file must be named 'hugo.toml'."
        exit 1
    fi
    if [[ "${HUGO_TOML_PATH##*.}" != "toml" ]]; then
        echo "Error: The file must have a .toml extension."
        exit 1
    fi
    HUGO_PROJECT_CONFIG_PATH=$(dirname "$HUGO_TOML_PATH")
    update_env_var "HUGO_PROJECT_CONFIG_PATH" "$HUGO_PROJECT_CONFIG_PATH"
fi

# Ask user if they want to configure Git user
read -rp "Do you want to configure Git user info? (y/N): " config_git
if [[ "$config_git" =~ ^[Yy]$ ]]; then
    read -rp "Enter your Git user email: " GIT_USER_EMAIL
    update_env_var "GIT_USER_EMAIL" "$GIT_USER_EMAIL"
    read -rp "Enter your Git user name: " GIT_USER_NAME
    update_env_var "GIT_USER_NAME" "$GIT_USER_NAME"
fi