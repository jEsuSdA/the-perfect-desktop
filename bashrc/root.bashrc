# ~/.bashrc: ejecutado por bash(1) para shells no-login.


# .bashrc personalizado de jEsuSdA 8)
#
# Ver. 20260129 · versión mejorada
# Ver. 20200101 · primera versión
# 





# 1. SALIDA TEMPRANA
# Si no se ejecuta interactivamente, no hacer nada.
[ -z "$PS1" ] && return

# 2. OPCIONES DEL SHELL (SHOPT)
# Comprobar tamaño de ventana tras cada comando
shopt -s checkwinsize

# No poner líneas duplicadas en el historial (opcional)
# export HISTCONTROL=ignoredups

# 3. VARIABLES DE ENTORNO Y EXPORTS

# 3.1. Configuración de Audio y Juegos
export ALSA_OUTPUT_PORTS="128:0"
export SCUMMVM_PORT=128:0

# 3.2. Configuración Java
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dsun.java2d.xrender=true -Dawt.useSystemAAFontSettings=gasp -Dswing.crossplatformlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

# 3.3. Correcciones visuales GTK/QT
export GTK_OVERLAY_SCROLLING=0
export GTK_CSD=0
# export QT_STYLE=GTK+
# export QT_QPA_PLATFORMTHEME=qt5ct
# Solo cargamos la librería si existe para evitar errores en logs
if [ -f "/usr/lib/libgtk3-nocsd.so.0" ]; then
    export LD_PRELOAD=/usr/lib/libgtk3-nocsd.so.0
fi


# 3.4. Colores para páginas MAN (less)
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# 4. ALIAS
# Habilitar soporte de colores para ls
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
fi

# 5. IDENTIFICACIÓN CHROOT
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# 6. CONFIGURACIÓN DE COLORES (Solarized y fallbacks)

# Detectar y configurar terminal de 256 colores
if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
    TERM=gnome-256color
fi

if tput setaf 1 &> /dev/null; then
    tput sgr0
    if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
        # Valores para terminal de 256 colores
        BASE03=$(tput setaf 234); BASE02=$(tput setaf 235); BASE01=$(tput setaf 240); BASE00=$(tput setaf 241)
        BASE0=$(tput setaf 244);   BASE1=$(tput setaf 245);   BASE2=$(tput setaf 254);   BASE3=$(tput setaf 230)
        YELLOW=$(tput setaf 136);  ORANGE=$(tput setaf 166);  RED=$(tput setaf 160);    MAGENTA=$(tput setaf 125)
        VIOLET=$(tput setaf 61);   BLUE=$(tput setaf 33);     CYAN=$(tput setaf 37);     GREEN=$(tput setaf 64)
    else
        # Fallback para 8 colores
        BASE03=$(tput setaf 8);    BASE02=$(tput setaf 0);    BASE01=$(tput setaf 10);   BASE00=$(tput setaf 11)
        BASE0=$(tput setaf 12);    BASE1=$(tput setaf 14);    BASE2=$(tput setaf 7);     BASE3=$(tput setaf 15)
        YELLOW=$(tput setaf 3);    ORANGE=$(tput setaf 9);    RED=$(tput setaf 1);       MAGENTA=$(tput setaf 5)
        VIOLET=$(tput setaf 13);   BLUE=$(tput setaf 4);      CYAN=$(tput setaf 6);      GREEN=$(tput setaf 2)
    fi
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    # Fallback para consola Linux sin tput
    MAGENTA="\033[1;31m"; ORANGE="\033[1;33m"; GREEN="\033[1;32m"
    PURPLE="\033[1;35m";  WHITE="\033[1;37m";  BOLD=""; RESET="\033[m"
    # Inicializar variables vacías para evitar errores
    BASE0=""; BASE00=""; BLUE=""; CYAN=""; RED=""; YELLOW="";
fi

# 7. FUNCIONES GIT
parse_git_dirty () {
  # Nota: Esto depende del idioma del sistema.
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
}
parse_git_branch () {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/*\(.*\)/\1$(parse_git_dirty)/"
}

# 8. PROMPT (Personalizado para Root)
# El prompt de root es rojo/naranja para diferenciarlo claramente.
PS1='${debian_chroot:+($debian_chroot)}'
PS1+='\[${BOLD}${RED}\]\u\[${BASE0}\]@\[${RED}\]\h \[${BASE0}\]in \[${ORANGE}\]\w'
PS1+='$([[ -n $(git branch 2> /dev/null) ]] && echo " on ")'
PS1+='\[${YELLOW}\]$(parse_git_branch)\[${BASE0}\]'
PS1+='\n\[${RED}\]# →\[${BASE0}\] \[${RESET}\]'

# 9. TÍTULO DE VENTANA (para xterm/rxvt)
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    ;;
*)
    ;;
esac

# 10. COMPLETADO PROGRAMABLE
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
