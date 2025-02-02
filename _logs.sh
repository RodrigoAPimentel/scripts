START_PROCESS=$(date)

# Reset
Color_Off='\033[0m'       # Text Reset
# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White
# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White
# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White
# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

_log__step () {
    DD=$(date +"%H:%M:%S")
    printf "\n${BBlue}##### [$DD] $1 ${Color_Off}\n"
    sleep 1
}

_log__section () {
    printf "${BCyan}\n*****************************************************\n"
    printf "*************** ${UCyan}$1${Color_Off}\n"
    printf "${BCyan}*****************************************************${Color_Off}\n"
}

_log__script_start () {
    printf "${BCyan}###############################################################\n"
    printf "###############################################################\n"
    printf ">> $1\n"
    printf "###############################################################\n"
    printf "###############################################################${Color_Off}\n"
}

_log__script_finish () {
    printf "${BCyan}###############################################################\n"
    printf "###############################################################\n"
    printf ">> $1\n"
    printf "###############################################################\n"
    printf "###############################################################${Color_Off}\n"
}

_log__cat_file () {
    printf "${Purple}================================= [$1] ================================="
    printf "\n$2"
    printf "\n======================================================================================= [$3]${Color_Off}\n"
}

_log__step_result () {
    printf "$1\n"
}

_log__step_result_success () {
    printf "${BGreen}$1${Color_Off}\n"
}

_log__step_result_failed () {
    printf "${BRed}$1${Color_Off}\n"
}

_log__step_result_suggestion () {
    printf "${BYellow}$1${Color_Off}\n"
}

_log__finish_information () {
    # # Print the start and end time of the process
    # printf "\n\n${BCyan}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
    # printf "@@ Start of the process: $START_PROCESS\n"
    # printf "@@ End of process: $(date)\n"

    # # Calculate the time spent
    # END_PROCESS=$(date)
    # START_SECONDS=$(date -d "$START_PROCESS" +%s)
    # END_SECONDS=$(date -d "$END_PROCESS" +%s)
    # TIME_SPENT=$((END_SECONDS - START_SECONDS))

    # printf "@@ Time spent: %02d:%02d:%02d\n" $((TIME_SPENT/3600)) $((TIME_SPENT%3600/60)) $((TIME_SPENT%60))
    # printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${Color_Off}"

    





    # Registrar o início do processo (timestamp)
    START_PROCESS=$(date +%s)

    # Simulação do processo (exemplo)
    sleep 5  # Simula o tempo de execução do processo

    # Registrar o término do processo (timestamp)
    END_PROCESS=$(date +%s)

    # Exibir início e fim do processo em formato legível
    printf "\n\n${BCyan}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
    printf "@@ Start of the process: %s\n" "$(date -d @$START_PROCESS)"
    printf "@@ End of the process: %s\n" "$(date -d @$END_PROCESS)"

    # Calcular o tempo gasto
    TIME_SPENT=$((END_PROCESS - START_PROCESS))

    # Formatar o tempo gasto (HH:MM:SS)
    HOURS=$((TIME_SPENT / 3600))
    MINUTES=$(( (TIME_SPENT % 3600) / 60 ))
    SECONDS=$((TIME_SPENT % 60))

    printf "@@ Time spent: %02


}