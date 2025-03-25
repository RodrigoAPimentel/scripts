# LOADING LOG FUNCTIONS FILE
. ./_logs.sh




# VERIFICA SE A SENHA DO SUDO FOI INFORMADA
_verify_root_pass() {
    _step '[--] AACheck if the sudo password was entered'
    if [ -z "${1}" ]; then
        _step_result_failed "sudo password not entered!!"
        _step_result_suggestion "Sample: script.sh <sudo pass>"
        exit 1
    else
        _step_result_success "✅ sudo password entered."
    fi
}