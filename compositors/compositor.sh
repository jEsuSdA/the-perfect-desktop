#!/bin/bash
#
# Script unificado que sirve para gestionar compositores de ventanas en XFCE
#
# ver. 20260823 · parámetro -watchdog: relanzar automáticamente compositor si falla en ejecución.
# ver. 20260307 · versión inicial
#
# jEsuSdA 8)
#
# Compositories soportados:  picom, compton, fastcompmgr y xfwm4
#
# Uso: compositor.sh [--watchdog|-w] <xfwm4|picom|compton|fc|fastcompmgr|--help>
#
# --watchdog, -w   Activa el mecanismo de auto‑relaunch del compositor
#                  (se relanza si se cae inesperadamente, con límite de reintentos)
#

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
    echo "Uso: $0 [--watchdog|-w] <compositor>"
    echo ""
    echo "Compositores disponibles:"
    echo "  xfwm4        - Activa el compositor nativo de XFWM4 (XFCE)"
    echo "  picom        - Lanza Picom compositor"
    echo "  compton      - Lanza Compton compositor"
    echo "  fc           - Lanza FastCompmgr (alias corto)"
    echo "  fastcompmgr  - Lanza FastCompmgr (nombre completo)"
    echo "  --help, -h   - Muestra este mensaje de ayuda"
    echo ""
    echo "Opciones:"
    echo "  --watchdog, -w   Activa el mecanismo de auto‑relaunch del compositor"
    echo ""
    echo "Ejemplos:"
    echo "  $0 xfwm4                     # Activa compositor nativo XFCE"
    echo "  $0 --watchdog picom         # Lanza picom con watchdog"
    echo "  $0 -w fc                    # Lanza fastcompmgr con watchdog"
}

# Elimina el marcador de watchdog para un compositor dado
clear_watchmark() {
    rm -f "/tmp/compositor_$1.run"
}

# ============================================================================
# FUNCIONES DE INICIO DE COMPOSITORES (síncronas, sin &)
# ============================================================================

# Inicia Picom (espera a que termine)
start_picom() {
    if ! command -v picom >/dev/null; then
        notify "Error: picom no está instalado" "" "critical"
        exit 1
    fi

    if [[ -n "$CONFIG_FILE" ]]; then
        picom --config "$CONFIG_FILE"
    else
        picom
    fi
}

# Inicia Compton (espera a que termine)
start_compton() {
    if ! command -v compton >/dev/null; then
        notify "Error: compton no está instalado" "" "critical"
        exit 1
    fi

    if [[ -n "$CONFIG_FILE" ]]; then
        compton --config "$CONFIG_FILE"
    else
        compton
    fi
}

# Inicia FastCompmgr (espera a que termine)
start_fastcompmgr() {
    if ! command -v fastcompmgr >/dev/null; then
        notify "Error: fastcompmgr no está instalado" "" "critical"
        exit 1
    fi

    # Flags fijos: -o opacidad, -r radio de sombra, -l desplazamiento sombra izquierda
    # -t desplazamiento sombra superior, -c habilita sombras
    fastcompmgr -o 0.6 -r 20 -l -30 -t -25 -c
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
# WATCHDOG: lanza un componente con reintentos limitados
# ============================================================================
# Se activa únicamente si la variable USE_WATCHDOG está a 1.
# Crea un marcador temporal /tmp/compositor_<nombre>.run.
# Mientras el marcador exista:
#   - ejecuta el compositor de forma síncrona
#   - si termina con código != 0 y el marcador sigue ahí, cuenta un fallo
#   - tras MAX_RETRIES fallos notifica crítico y elimina el marcador
#   - si termina con código 0 (salida normal) elimina el marcador y sale
#   - si el marcador se elimina externamente (cambio de compositor) sale sin reintentar
launch_with_watchdog() {
    local name="$1"
    shift
    local start_fn="$1"
    local max_retries=3
    local attempt=0

    touch "/tmp/compositor_${name}.run"

    while [[ -f "/tmp/compositor_${name}.run" ]]; do
        # Ejecutamos la función de inicio (síncrona)
        "$start_fn"
        local status=$?

        if [[ -f "/tmp/compositor_${name}.run" ]]; then
            # El marcador sigue presente → el lanzamiento fue intencional
            if (( status != 0 )); then
                ((attempt++))
                if (( attempt >= max_retries )); then
                    notify "Error: $name falló tras $max_retries intentos" "" "critical"
                    rm -f "/tmp/compositor_${name}.run"
                    break
                else
                    notify "Advertencia: $name se detuvo inesperadamente, reintentando..." "" "normal"
                    sleep 1
                fi
            else
                # Salida normal
                rm -f "/tmp/compositor_${name}.run"
                break
            fi
        else
            # Marcador eliminado por cambio de compositor o salida del script
            break
        fi
    done
}

# Wrapper que decide si usar watchdog o no
run_compositor() {
    local name="$1"
    shift
    local start_fn="$1"

    if (( USE_WATCHDOG )); then
        launch_with_watchdog "$name" "$start_fn"
    else
        # Modo clásico: lanzar en background y notificar inmediatamente
        "$start_fn" &
        local pid=$!
        wait $pid
        local status=$?
        if (( status == 0 )); then
            notify "Compositor $name activado." "$name"
        else
            notify "Error: $name falló al iniciar." "" "critical"
        fi
    fi
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main() {
    # Procesar opción de watchdog
    USE_WATCHDOG=0
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --watchdog|-w)
                USE_WATCHDOG=1
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done

    # Verificar que se proporcionó un argumento (el compositor)
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

            # --- Paso 2: Limpiar procesos anteriores y marcadores ---
            kill_compositors
            wait_for_death
            clear_watchmark picom   # eliminar marcador previo por si queda

            # --- Paso 3: Lanzar Picom ---
            run_compositor picom start_picom
            ;;

        compton)
            # --- Paso 1: Desactivar compositor nativo ---
            disable_xfwm4

            # --- Paso 2: Limpiar procesos anteriores y marcadores ---
            kill_compositors
            wait_for_death
            clear_watchmark compton

            # --- Paso 3: Lanzar Compton ---
            run_compositor compton start_compton
            ;;

        fc|fastcompmgr)
            # --- Paso 1: Desactivar compositor nativo ---
            disable_xfwm4

            # --- Paso 2: Limpiar procesos anteriores y marcadores ---
            kill_compositors
            wait_for_death
            clear_watchmark fastcompmgr

            # --- Paso 3: Lanzar FastCompmgr ---
            run_compositor fastcompmgr start_fastcompmgr
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