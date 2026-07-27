#!/bin/bash
#
# Script  unificado que sirve para gestionar compositores de ventanas en XFCE
#
# ver. 20260307
#
# jEsuSdA 8)
#
# Compositories soportados:  picom, compton, fastcompmgr y xfwm4
#
# Uso: compositor.sh <xfwm4|picom|compton|fc|fastcompmgr|--help>


# ============================================================================
# CONFIGURACIÓN
# ============================================================================
# Si usas un archivo de configuración específico, defínelo aquí.
# Si lo dejas vacío, el compositor usará su configuración por defecto.
CONFIG_FILE=""

# ============================================================================
# FUNCIONES DE UTILIDAD COMPARTIDAS
# ============================================================================

# Mata los compositores externos (picom, compton, fastcompmgr)
kill_compositors() {
    if pgrep -x "picom" >/dev/null || pgrep -x "compton" >/dev/null || pgrep -x "fastcompmgr" >/dev/null; then
        echo "Deteniendo compositores externos..."
        pkill -x picom 2>/dev/null
        pkill -x compton 2>/dev/null
        pkill -x fastcompmgr 2>/dev/null
    fi
}

# Espera a que los compositores externos terminen realmente
wait_for_death() {
    while pgrep -x "picom" >/dev/null || pgrep -x "compton" >/dev/null || pgrep -x "fastcompmgr" >/dev/null; do
        sleep 0.1
    done
}

# Desactiva el compositor nativo de XFWM4
disable_xfwm4() {
    if command -v xfconf-query >/dev/null; then
        xfconf-query -c xfwm4 -p /general/use_compositing -s false
        echo "Compositor de XFWM4 desactivado correctamente."
    else
        echo "Error: No se encontró xfconf-query. Asegúrate de estar en XFCE."
    fi
}

# Envía notificaciones al escritorio
# Parámetros: $1=mensaje éxito, $2=nombre_del_proceso_a_verificar, $3=urgencia (normal/critical)
notify() {
    if ! command -v notify-send >/dev/null; then
        return
    fi
    
    local mensaje="$1"
    local proceso="$2"
    local urgencia="${3:-normal}"
    
    if [[ -n "$proceso" ]]; then
        if pgrep -x "$proceso" >/dev/null; then
            notify-send "Gestor de Composición" "$mensaje" -i video-display
        else
            notify-send "Error" "$mensaje no pudo iniciarse." -i dialog-warning -u critical
        fi
    else
        if [[ "$urgencia" == "critical" ]]; then
            notify-send "Error" "$mensaje" -i dialog-warning -u critical
        else
            notify-send "Gestor de Composición" "$mensaje" -i video-display
        fi
    fi
}

# Muestra mensaje de ayuda
show_help() {
    echo "Uso: $0 <compositor>"
    echo ""
    echo "Compositores disponibles:"
    echo "  xfwm4        - Activa el compositor nativo de XFWM4 (XFCE)"
    echo "  picom        - Lanza Picom compositor"
    echo "  compton      - Lanza Compton compositor"
    echo "  fc           - Lanza FastCompmgr (alias corto)"
    echo "  fastcompmgr  - Lanza FastCompmgr (nombre completo)"
    echo "  --help, -h   - Muestra este mensaje de ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 xfwm4     # Activa compositor nativo XFCE"
    echo "  $0 picom     # Lanza picom compositor"
    echo "  $0 fc        # Lanza fastcompmgr compositor"
}

# ============================================================================
# FUNCIONES ESPECÍFICAS POR COMPOSITOR
# ============================================================================

# Lanza Picom compositor
launch_picom() {
    if ! command -v picom >/dev/null; then
        notify "Error: picom no está instalado" "" "critical"
        exit 1
    fi
    
    if [[ -n "$CONFIG_FILE" ]]; then
        picom --config "$CONFIG_FILE" -b
    else
        picom -b
    fi
    
    notify "Compositor PICOM activado." "picom"
}

# Lanza Compton compositor
launch_compton() {
    if ! command -v compton >/dev/null; then
        notify "Error: compton no está instalado" "" "critical"
        exit 1
    fi
    
    if [[ -n "$CONFIG_FILE" ]]; then
        compton --config "$CONFIG_FILE" &
    else
        compton &
    fi
    
    notify "Compositor COMPTON activado." "compton"
}

# Lanza FastCompmgr compositor
launch_fastcompmgr() {
    if ! command -v fastcompmgr >/dev/null; then
        notify "Error: fastcompmgr no está instalado" "" "critical"
        exit 1
    fi
    
    # Flags fijos: -o opacidad, -r radio de sombra, -l desplazamiento sombra izquierda
    # -t desplazamiento sombra superior, -c habilita sombras
    fastcompmgr -o 0.6 -r 20 -l -30 -t -25 -c &
    
    notify "Compositor FastComPMGR ACTIVADO" "fastcompmgr"
}

# Activa el compositor nativo de XFWM4
enable_xfwm4() {
    if ! command -v xfconf-query >/dev/null; then
        echo "Error: No se encontró xfconf-query. ¿Estás en una sesión XFCE?"
        exit 1
    fi
    
    xfconf-query -c xfwm4 -p /general/use_compositing -s true
    echo "Compositor nativo XFWM4 reactivado."
    
    # Verificamos si la propiedad realmente cambió a true
    local estado
    estado=$(xfconf-query -c xfwm4 -p /general/use_compositing)
    
    if [[ "$estado" == "true" ]]; then
        notify "Compositor XFWM4 ACTIVADO" ""
    else
        notify "No se pudo reactivar el compositor de XFWM4." "" "critical"
    fi
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main() {
    # Verificar que se proporcionó un argumento
    if [[ $# -eq 0 ]]; then
        show_help
        exit 1
    fi
    
    local compositor="$1"
    
    case "$compositor" in
        xfwm4)
            # --- Paso 1: Matar compositores externos ---
            kill_compositors
            wait_for_death
            
            # --- Paso 2: Activar compositor nativo XFWM4 ---
            enable_xfwm4
            ;;
            
        picom)
            # --- Paso 1: Desactivar compositor nativo ---
            disable_xfwm4
            
            # --- Paso 2: Limpiar procesos anteriores ---
            kill_compositors
            wait_for_death
            
            # --- Paso 3: Lanzar Picom ---
            launch_picom
            ;;
            
        compton)
            # --- Paso 1: Desactivar compositor nativo ---
            disable_xfwm4
            
            # --- Paso 2: Limpiar procesos anteriores ---
            kill_compositors
            wait_for_death
            
            # --- Paso 3: Lanzar Compton ---
            launch_compton
            ;;
            
        fc|fastcompmgr)
            # --- Paso 1: Desactivar compositor nativo ---
            # FIX: Los scripts originales no desactivaban XFWM4 para fastcompmgr
            disable_xfwm4
            
            # --- Paso 2: Limpiar procesos anteriores ---
            kill_compositors
            wait_for_death
            
            # --- Paso 3: Lanzar FastCompmgr ---
            launch_fastcompmgr
            ;;
            
        --help|-h)
            show_help
            exit 0
            ;;
            
        *)
            echo "Error: Compositor '$compositor' no reconocido."
            echo ""
            show_help
            exit 1
            ;;
    esac
    
    exit 0
}

# Ejecutar main con todos los argumentos
main "$@"
