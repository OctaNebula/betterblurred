#!/usr/bin/env bash

message() { printf "%s\n" "$*" >&2; }

download_tb() {

    message "[>>] Installing theme from local repository..."

    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    message "[>>] Copying from local repo at: ${SCRIPT_DIR}"

    # Copy all files except the install script itself
    cp "${SCRIPT_DIR}"/*.css "${CHROME_DIRECTORY}/" 2>/dev/null || true
    cp -r "${SCRIPT_DIR}"/addons "${CHROME_DIRECTORY}/" 2>/dev/null || true
    cp -r "${SCRIPT_DIR}"/assets "${CHROME_DIRECTORY}/" 2>/dev/null || true

        cat > "${CHROME_DIRECTORY}/../user.js" <<'EOL'
        user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); 
        user_pref("layers.acceleration.force-enabled", true);
        user_pref("gfx.webrender.all", true);
        user_pref("gfx.webrender.enabled", true);
        user_pref("svg.context-properties.content.enabled", true);
EOL
        if [[ $? -eq 0 ]];
        then
            message "[>>] Local installation completed successfully!"
        else
            message " [!!] There was a problem while copying the files. Terminating..."
            return 1
        fi
    cat <<-'EOF'
━┏┛┃ ┃┃ ┃┏━ ┏━ ┏━┛┏━┃
 ┃ ┏━┃┃ ┃┃ ┃┃ ┃┏━┛┏┏┛
 ┛ ┛ ┛━━┛┛ ┛━━ ━━┛┛ ┛
░█▀▄░█░░░█░█░█▀▄░█▀▄░█▀▀░█▀▄
░█▀▄░█░░░█░█░█▀▄░█▀▄░█▀▀░█░█
░▀▀░░▀▀▀░▀▀▀░▀░▀░▀░▀░▀▀▀░▀▀░
EOF
    message "Thunderblurred successfully installed! To enable the transparency change the theme to Dark in preferences! Enjoy!"
}


TB_USER_DIRECTORY="$(find "${HOME}/.thunderbird" -maxdepth 1 -type d -regextype egrep -regex '.*[a-zA-Z0-9]+.default-default')"

if [[ -n $TB_USER_DIRECTORY ]];
then
    message "[>>] Thunderbird user profile directory located..."

    CHROME_DIRECTORY="$(find "$TB_USER_DIRECTORY" -maxdepth 1 -type d -name 'chrome')"

    if [[ -n $CHROME_DIRECTORY ]];
    then

        # Check if the chrome folder contains files
        shopt -s nullglob dotglob 
        content=("${CHROME_DIRECTORY}"/*)

        # If there's a current theme, make a backup then wipe the folder
        if [ ${#content[@]} -gt 0 ];
        then
            message "[>>] Current chrome folder is not empty. Creating a backup and wiping folder for clean install..."
            mv "${CHROME_DIRECTORY}" "${CHROME_DIRECTORY}.backup.$(date +%Y%m%d-%H%M%S)"
            mkdir "${CHROME_DIRECTORY}"
        else
            message "[>>] Chrome folder exists but is empty. Proceeding with installation..."
        fi

        
        download_tb
    else
        
        message "[>>] Chrome directory does not exist! Creating one..."
        mkdir "${TB_USER_DIRECTORY}/chrome"

        if [[ $? -eq 0 ]];
        then
            CHROME_DIRECTORY="${TB_USER_DIRECTORY}/chrome"
            
            download_tb
        else
            message "[!!] There was a problem creating the directory. Terminating..."
            exit 1;
        fi
    fi

else
    message "[!!] No thunderbird user profile directory found. Make sure to run Thunderbird atleast once! Terminating..."
    exit 1;
fi
