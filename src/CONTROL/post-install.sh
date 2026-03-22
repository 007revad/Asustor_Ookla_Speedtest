#!/bin/sh

PKG_NAME="Asustorspeedtest"
PKG_ROOT="/usr/local/AppCentral/${PKG_NAME}"
BIN_DIR="${PKG_ROOT}/bin"
VAR_DIR="${PKG_ROOT}/var"
WWW_DIR="/usr/local/www/${PKG_NAME}"
RESULT_DIR="${WWW_DIR}/result"
LOG_FILE="${VAR_DIR}/install.log"

log_message() {
    mkdir -p "${VAR_DIR}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_FILE}" 2>/dev/null || echo "$1"
}

install_or_upgrade() {
    log_message "Post-installation starting for package: ${PKG_NAME}"

    # Create runtime var directory
    if mkdir -p "${VAR_DIR}"; then
        log_message "Created var directory: ${VAR_DIR}"
        chmod 755 "${VAR_DIR}"
    else
        log_message "Error: Failed to create var directory: ${VAR_DIR}"
        exit 1
    fi

    # Create result directory under ADM's www tree (used by api.cgi for static file serving)
    if mkdir -p "${RESULT_DIR}"; then
        log_message "Created result directory: ${RESULT_DIR}"
        chmod 755 "${RESULT_DIR}"
    else
        log_message "Warning: Failed to create result directory: ${RESULT_DIR}"
        ERRORS=1
    fi

    # Create aarch64 symlink for any uname -m variant that reports differently
    # (ADM on AS5304T/AS5404T reports x86_64; aarch64 covers ARM models like AS-T10)
    # Uncomment and add entries below if you add ARM binaries to bin/
    # ln -sf aarch64 "${BIN_DIR}/armv8"  2>/dev/null

    # Create cgi-bin symlink for Python HTTP server CGI support
    mkdir -p "${PKG_ROOT}/webman/cgi-bin"
    ln -sf ../api.cgi "${PKG_ROOT}/webman/cgi-bin/api.cgi"
    log_message "Created cgi-bin/api.cgi symlink"

    # Set execute permissions for speedtest binaries
    chmod +x "${BIN_DIR}/x86_64/speedtest"  2>/dev/null && \
        log_message "Set +x on bin/x86_64/speedtest" || \
        log_message "Warning: bin/x86_64/speedtest not found"
    chmod +x "${BIN_DIR}/aarch64/speedtest" 2>/dev/null && \
        log_message "Set +x on bin/aarch64/speedtest" || \
        log_message "Warning: bin/aarch64/speedtest not found"

    # Set execute permissions for wrapper script
    chmod +x "${BIN_DIR}/speedtest.sh" 2>/dev/null && \
        log_message "Set +x on bin/speedtest.sh" || \
        log_message "Warning: bin/speedtest.sh not found"

    # Set execute permissions for CGI
    chmod +x "${PKG_ROOT}/webman/api.cgi" 2>/dev/null && \
        log_message "Set +x on webman/api.cgi" || \
        log_message "Warning: webman/api.cgi not found"

    # Setup logrotate
    if cp "${PKG_ROOT}/webman/logrotate" /etc/logrotate.d/asustorspeedtest 2>/dev/null; then
        chmod 644 /etc/logrotate.d/asustorspeedtest
        log_message "Installed logrotate config"
    else
        log_message "Note: No logrotate config found, skipping"
    fi

    # Create BusyBox httpd config to enable CGI execution
    cat > "${PKG_ROOT}/var/httpd.conf" << 'EOF'
*.cgi:application/x-httpd-cgi
EOF
    chmod 644 "${PKG_ROOT}/var/httpd.conf"
    log_message "Created httpd.conf"

    if [ -z "${ERRORS}" ]; then
        log_message "Post-installation completed successfully"
    else
        log_message "Post-installation completed with warnings"
    fi
    echo >> "${LOG_FILE}"
}

case "$1" in
    install|upgrade)
        install_or_upgrade
        ;;
    *)
        ;;
esac

exit 0
