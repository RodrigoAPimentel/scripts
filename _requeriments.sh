# LOADING LOG FUNCTIONS FILE
. ./_logs.sh

# VERIFICA SE A SENHA DO SUDO FOI INFORMADA
__verify_root_pass() {
    _step '🔍 Check if the sudo password was entered ...'
    if [ -z "${1}" ]; then
        _step_result_failed "❌ sudo password not entered!!"
        _step_result_suggestion "Sample: script.sh <sudo pass>"
        exit 1
    else
        _step_result_success "✅ sudo password entered."
    fi
}

# Verifica se o script está sendo executado como root
__verify_root() {
    _step '🔍 Checking if the script is being run as root ...'
    if [[ $EUID -ne 0 ]]; then
        _step_result_failed "❌ This script must be run as root."
        exit 1
    fi
    _step_result_success "✅ Script running as root."
}