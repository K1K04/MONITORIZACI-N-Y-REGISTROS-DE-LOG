# MONITORIZACION-Y-REGISTROS-DE-LOG
Grafana, Prometheus y Loki
Con Prometheus vamos a recuperar datos de parámetros como uso de memoria, CPU y tráfico de red de los nodos ubuntu dockerizados.
Con Grafana vamos a dibujar dashboards de los parámetros recogidos
Con Grafana LOKI vamos a recibir los logs de los sistemas que corran el agente de OpenTelemetry (OTELCOL) y vamos a analizarlos y generar alertas con Grafana Alerting

La idea es tener un sistema integrado de recepción de alarmas bien de parámetros de sistemas o bien de entradas en logs. 

Como ejemplo sobre el tratamiento de logs debemos generar una alerta cuando se de en el log de un sistema ubuntu dockerizado un error de autentificación SSH.
