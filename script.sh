#!/bin/bash

###########################
#        VARIABLES        #
###########################
# Cada vez que se dice que una variable es utilizada en X función, quiere decir que se utiliza por primera vez/principalmente
# en esa función. Luego puede utilizarse en más partes del programa.

	# Colores
		# Funcionamiento:
    		# \e[ o \033[ es la secuencia de escape
    		# Para indicar que lo que se quiere cambiar es el COLOR DEL TEXTO, después del escape se pone ' 38; '
    		# Para indicar que lo que se quiere cambiar es el COLOR DEL FONDO, después del escape se pone ' 48; '
    		# Después de decir si era el color del texto o fondo, para indicar que se va a usar la paleta de 256 colores se pone ' 5; '
    		# Finalmente, se escribe el color deseado de esa paleta seguido por m (p.e: '140m ')
		#
		declare -r _sel='\e[48;5;111m'		# Fondo cyan para la selección de opciones.
		declare -r _rojo='\e[38;5;160m'
		declare -r _nrja='\e[38;5;208m'
		declare -r _amll='\e[38;5;220m'
		declare -r _verd='\e[38;5;112m'
		declare -r _cyan='\e[38;5;117m'
		declare -r _azul='\e[38;5;38m'
		declare -r _mora='\e[38;5;133m'
		declare -r _rosa='\e[38;5;211m'
		declare -r _r='\033[0m' 			# Reset
		declare -r _b='\033[1m' 			# Bold
		declare -r _i='\033[3m' 			# Italic
		declare -r _u='\033[4m' 			# Underline
		declare -r _s='\033[9m' 			# Strikeout
	#

	# Globales (utilizadas en todo el programa)
	tamMem=0;				# Tamaño de la memoria total.
	marcosMem=0;			# Número de marcos que caben en la memoria
	tamPag=0;				# Tamaño de las páginas.
	nProc=0; 				# Número total de procesos.
	alg="FCFS"				# Algoritmo de planificación de procesos (puede ser "FCFS" o "SJF").
	algReemplazo="RELOJ"	# Algoritmo de reemplazo de páginas (puede ser "RELOJ" o "SEGOP").
	anchoUnidadBarras=3		# Nº de caracteres que ocupan los procesos/marcos/páginas por defecto.
    logEventos=""			# Almacena los eventos que han ido ocurriendo en un determinado instante para volcarlos al final.
	logEventosBN=""			# Lo mismo pero sin secuencias de escape para mandar al informe en blanco y negro.
	tSistema=0;				# Tiempo actual del sistema.
	seAcaba=0;				# Para saber si la ejecución ha acabado (solo se usa en la opción 4, que muestra solo el resumen final).

	anchura=`tput cols`;	# Anchura actual del terminal en caracteres (columnas). 
	((anchura--))			# Para que no se pinten cosas en la última columna.
	trap 'anchura=`tput cols`; ((anchura--))' WINCH 	# Cada vez que se reajusta el ancho del terminal se actualiza la variable.
	
	# menuInicio
	menuOpcion=0;			# Utilizada en la función menuInicio, para elegir el algoritmo, la ayuda o salir del programa.

	# seleccionInforme
	informe="./datosScript/Informes/informeBN.txt";					# Nombre del fichero donde se guardará el informe en BLANCO y NEGRO.
	informeColor="./datosScript/Informes/informeCOLOR.txt";			# Nombre del fichero donde se guardará el informe A COLOR.

	# Leer ficheros
	ficheroIn=0; 			# Nombre del fichero de entrada (con extensión .txt). Puede ser de datos o de rangos dependiendo de la opción elegida.
	fichSelect=0;			# Número del fichero seleccionado en el menú.

	# seleccionTipoEjecucion
	segEsperaEventos=0		# Segundos de espera entre cada evento mostrado por pantalla.
	opcionEjec=0			# Modo de ejecución del algoritmo (por eventos=1, automático=2, etc).

	# Vectores
	Ref=()						# Almacena las referencias a los procesos (por ejemplo, Ref[1]=P01, Ref[20]=P20).
	colorines=()				# Contiene el último dígito del color asignado a cada proceso. Utilizado en varias funciones para colorear los procesos.
	ordenados=()				# Guarda el número de los procesos en orden de llegada.
	esperaConLlegada=()			# Tiempo de espera de cada proceso incluyendo el tiempo de llegada.
	esperaSinLlegada=()			# Tiempo de espera (real) de cada proceso sin incluir el tiempo de llegada.
	tRetorno=()					# Tiempo que ha estado el proceso desde entró hasta que terminó.
	tLlegada=();				# Recoge los tiempos de llegada.
	tEjec=();					# Recoge los tiempos de ejecución.
	tamProceso=();				# Recoge los tamaños de los procesos. En mi algoritmo no se usa pero puede ser útil para otros.
	nMarcos=(); 				# Recoge la cantidad de marcos de cada proceso.
	maxPags=();					# Recoge el número máximo de páginas de los procesos.
	declare -A direcciones		# Recoge las direcciones de página de cada proceso.
	declare -A paginas			# Recoge las páginas de cada proceso.
	enMemoria=();				# Vale "fuera" si el proceso no está en memoria, "dentro" si el proceso está en memoria y "salido" si acabó.
	ejecutandoAntiguo=0;		# Proceso que se estaba ejecutando antes. Se usa para mostrar la tabla de fallos de página de un proceso que acaba de finalizar.
	cola=();					# Cola de ejecución (orden en el que se ejecutarán los procesos que están en memoria).
	colaMemoria=()				# Cola de memoria. Los procesos que llegan al sistema se almacenan en esta cola.
	mediaEspera=0				# Tiempo medio de espera de los procesos.
	mediaDurac=0				# Tiempo medio de retorno/duración de los procesos.

	# diagramaResumen
	nPagAEjecutar=();			# Se usa para ver cuántas páginas hay que subrayar porque se han ejecutado.

	# Barra memoria
	marcoInicial=()				# Primer marco que ocupa un proceso.
	marcoFinal=()				# Último marco que ocupa un proceso.
	memoriaProceso=()         	# Proceso que hay en cada marco. Si no hay ningún proceso el índice está vacío.
    memoriaPagina=()          	# Página que hay en cada marco. Si no hay ninguna página el índice está vacío.
	
    # Línea temporal
    tiempoProceso=()          	# Proceso que está en ejecución en cada instante de tiempo.
    tiempoPagina=()           	# Página que se ha ejecutado en cada instante de tiempo.
    procesotInicio=()          	# Tiempo de inicio de cada proceso.
    procesotFin=()             	# Tiempo de finalización de cada proceso.

	# calculaEspaciosMemoria
	procesosMemoria=()			# Array que contiene los procesos que están actualmente asignados en memoria.
	tamEspacioGrande=0			# Tamaño del espacio vacío más grande en memoria.
	espaciosMemoria=()			# Array que contiene la cantidad de espacios vacíos consecutivos en memoria.

	# Algoritmo Reloj/SegOp
	declare -A procesoTiempoMarcoPagina			# Valores de los marcos de memoria.
	declare -A procesoTiempoMarcoPuntero		# Orden del puntero.
	declare -A procesoTiempoMarcoBits			# Valores de bits de reloj/segunda oportunidad
	declare -A procesoTiempoMarcoFallo			# Fallos de página en el proceso a lo largo del tiempo.

	# Globales auxiliares (utilizadas en varias funciones como contador para bucles, índices, valores máximos, etc.)
	p=0;					# Son los procesos.
	ord=0;					# Se suele utilizar para identificar un proceso de una forma más cómoda.
	counter=0;
	max=0;
	i=0;
	
###################################################################################################################################


###################################################################################
######                           #################                           ######
########                           #############                           ########
##   #########################################################################   ##
##     #####                           #####                           #####     ##
##       #####                           #                           #####       ##
##        ############################### ###############################        ##
##         ##########  ########---------------------########  ##########         ##
##         ########      ######--ENTRADA-DE-DATOS---######      ########         ##
##         ##########  ########---------------------########  ##########         ##
##        ############################### ###############################        ##
##       #####                           #                           #####       ##
##     #####                           #####                           #####     ##
##   #########################################################################   ##
########                           #############                           ########
######                           #################                           ######
###################################################################################


# Menú inicial. Permite al usuario elegir entre ejecutar el algoritmo, visualizar la ayuda o salir del programa.
#	- En caso de introducir una opción no válida, se notifica al usuario y se vuelve a preguntar hasta que la introduzca correctamente.
function menuInicio(){

	clearYCabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?"
	printf "\t$_verd%s$_r%s\n"			"[1]" " -> Ejecutar el algoritmo"
	printf "\t$_verd%s$_r%s\n"			"[2]" " -> Visualizar la ayuda"
	printf "\t$_verd%s$_r%s\n\n"		"[3]" " -> Salir"
	read -p " Seleccione la opción: " menuOpcion
	
	until [[ $menuOpcion =~ ^[1-3]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Valor incorrecto." " Escriba '1', '2', o '3': "
		read menuOpcion
	done

	case $menuOpcion in
		1) # Muestra la opción 1 seleccionada.
			clearYCabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Visualizar la ayuda"
			printf "\t$_verd%s$_r%s\n\n"		"[3]" " -> Salir"
			sleep 0.3
			;;
		2) # Muestra la opción 2 seleccionada.
			clearYCabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> Visualizar la ayuda"
			printf "\t$_verd%s$_r%s\n\n"		"[3]" " -> Salir"
			sleep 0.3
			;;
		3) # Muestra la opción 3 seleccionada.
			clearYCabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Visualizar la ayuda"
			printf "\t$_sel%s%s$_r\n\n"			"[3]" " -> Salir"
			sleep 0.3
			;;
	esac

	seleccionMenuInicio
}

###################################################################################################################################

# Función auxiliar para el menú inicial. Opera en base a la opción seleccionada en el menú de inicio.
function seleccionMenuInicio(){

	case $menuOpcion in
		1)	# Pasa a la ejecución del algoritmo.
			seleccionInforme
			seleccionAlgoritmo
			seleccionEntrada
			ejecucion
			final
			;;
		2)	# Muestra la ayuda.
			clear
			cat ./datosScript/Ayuda/ayuda.txt
			echo ""
			read -p " Pulse INTRO para continuar ↲ "
			clear
			menuInicio
			;;
		*)	# Sale del programa.
			sleep 0.3
			cabeceraFinal
			;;
	esac
}

###################################################################################################################################

# Muestra al usuario qué nombres se le darán por defecto a los informes, permitiendo cambiarlos si así se deseara.
function seleccionInforme(){

	clearYCabecera
	printf "\n%s$_verd$_b%s\n$_r"	" Los nombres por defecto de los informes son: " "informeBN.txt, informeCOLOR.txt"
	printf "\n%s$_r" 				" ¿Desea cambiarlos? (s/n): "
	read cambiarInformes
	
	until [[ $cambiarInformes =~ ^[nNsS]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Entrada no válida." " Escriba 's' (SI) o 'n' (NO): "
		read cambiarInformes
	done

	if [[ $cambiarInformes =~ ^[sS]$ ]]; then
		
		clearYCabecera
		printf "\n%s$_verd$_b%s\n$_r"	" Los nombres por defecto de los informes son: " "informeBN.txt, informeCOLOR.txt"
		printf "\n%s$_r" 				" ¿Desea cambiarlos? (s/n): "
		printf 							"\n\n >> Introduzca el nombre del informe en ${_verd}${_b}BLANCO y NEGRO${_r} (sin incluir .txt): "
		read informe
		informe="./datosScript/Informes/${informe}.txt"
		sleep 0.3
		clearYCabecera
		printf "\n%s$_verd$_b%s\n$_r"	" Los nombres por defecto de los informes son: " "informeBN.txt, informeCOLOR.txt"
		printf "\n%s$_r" 				" ¿Desea cambiarlos? (s/n): "
		printf 									"\n\n >> Introduzca el nombre del informe ${_verd}${_b}A COLOR${_r} (sin incluir .txt): "
		read informeColor
		informeColor="./datosScript/Informes/${informeColor}.txt"
		sleep 0.3
	else
		printf "\n\n >> Se utilizarán los nombres por defecto."
		sleep 1
	fi

	touch $informe			# Crea el archivo en BLANCO y NEGRO con el nombre que tiene la variable 'informe'.
	touch $informeColor		# Crea el archivo A COLOR con el nombre que tiene la variable 'informeColor'.
	cabeceraInforme
}

###################################################################################################################################

# Permite al usuario elegir el algoritmo de planificación de procesos (FCFS o SJF) y de reemplazo de páginas (Reloj o Segunda Oportunidad).
function seleccionAlgoritmo(){
	
	clearYCabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" Escoja un algoritmo de planificación de procesos:"
	printf "\t$_verd%s$_r%s\n"			"[1]" " -> FCFS"
	printf "\t$_verd%s$_r%s\n\n"		"[2]" " -> SJF"
	read -p " Seleccione la opción: " algSeleccionado
	
	until [[ $algSeleccionado =~ ^[1-2]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Valor incorrecto." " Escriba '1' o '2': "
		read algSeleccionado
	done

	clearYCabecera
	case $algSeleccionado in
		1) # Muestra la opción 1 seleccionada.
			printf "\n$_cyan$_b%s\n\n$_r"		" Escoja un algoritmo de planificación de procesos:"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> FCFS"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> SJF"
			alg="FCFS"
			sleep 0.3
			;;
		2) # Muestra la opción 2 seleccionada.
			printf "\n$_cyan$_b%s\n\n$_r"		" Escoja un algoritmo de planificación de procesos:"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> FCFS"
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> SJF"
			alg="SJF"
			sleep 0.3
			;;
	esac

	clearYCabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" Escoja un algoritmo de reemplazo de páginas:"
	printf "\t$_verd%s$_r%s\n"			"[1]" " -> Reloj"
	printf "\t$_verd%s$_r%s\n\n"		"[2]" " -> Segunda Oportunidad"
	read -p " Seleccione la opción: " algReemSeleccionado
	
	until [[ $algReemSeleccionado =~ ^[1-2]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Valor incorrecto." " Escriba '1' o '2': "
		read algReemSeleccionado
	done

	clearYCabecera
	case $algReemSeleccionado in
		1) # Muestra la opción 1 seleccionada.
			printf "\n$_cyan$_b%s\n\n$_r"		" Escoja un algoritmo de reemplazo de páginas:"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> Reloj"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Segunda Oportunidad"
			algReemplazo="RELOJ"
			sleep 0.3
			;;
		2) # Muestra la opción 2 seleccionada.
			printf "\n$_cyan$_b%s\n\n$_r"		" Escoja un algoritmo de reemplazo de páginas:"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Reloj"
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> Segunda Oportunidad"
			algReemplazo="SEGOP"
			sleep 0.3
			;;
	esac
}

###################################################################################################################################

# Permite al usuario seleccionar de qué manera van a ser introducidos los datos.
function seleccionEntrada(){

	clearYCabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
	printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
	printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
	printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
	printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
	printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
	printf "\t$_verd%s$_r%s\n"			"[6]" " -> Otro fichero de rangos"
	printf "\t$_verd%s$_r%s\n\n"		"[7]" " -> Aleatorio total (DatosRangosAleatorioTotal.txt)"
	read -p " Seleccione una opción: " opcionIn

	until [[ $opcionIn =~ ^[1-7]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Valor incorrecto." " Escriba un número del 1 al 7: "
		read opcionIn
	done
	# Se muestra la opción elegida en el propio informe.
	echo " Seleccione una opción:  " >> $informe
	echo " Seleccione una opción:  " >> $informeColor
	
	clearYCabecera
	imprimeHuecosInformes 1 0
	# Muestra resaltada la opción seleccionada para que sea más visual.
	case $opcionIn in
		1)
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[6]" " -> Otro fichero de rangos"
			printf "\t$_verd%s$_r%s\n\n"		"[7]" " -> Aleatorio total (DatosRangosAleatorioTotal.txt)"

			printf "\t$_sel%s%s$_r\n\n"			"[1]" " -> Introducción manual de datos" >> $informeColor
			printf "\t%s\n\n" 					"-> Introducción manual de datos <-" >> $informe
			sleep 0.3
			entradaManual
			;;
		2)
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[6]" " -> Otro fichero de rangos"
			printf "\t$_verd%s$_r%s\n\n"		"[7]" " -> Aleatorio total (DatosRangosAleatorioTotal.txt)"	
		
			printf "\t$_sel%s%s$_r\n\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)" >> $informeColor
			printf "\t%s\n\n" 					"-> Fichero de datos de última ejecución (DatosLast.txt) <-" >> $informe
			sleep 0.3
			entradaUltimaEjec
			;;
		3)
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_sel%s%s$_r\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[6]" " -> Otro fichero de rangos"
			printf "\t$_verd%s$_r%s\n\n"		"[7]" " -> Aleatorio total (DatosRangosAleatorioTotal.txt)"
		
			printf "\t$_sel%s%s$_r\n\n"			"[3]" " -> Otro fichero de datos" >> $informeColor
			printf "\t%s\n\n" 					"-> Otro fichero de datos <-" >> $informe
			sleep 0.3
			entradaFichero
			;;
		4)
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_sel%s%s$_r\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[6]" " -> Otro fichero de rangos"
			printf "\t$_verd%s$_r%s\n\n"		"[7]" " -> Aleatorio total (DatosRangosAleatorioTotal.txt)"
		
			printf "\t$_sel%s%s$_r\n\n"			"[4]" " -> Introducción manual de rangos (aleatorio)" >> $informeColor
			printf "\t%s\n\n" 					"-> Introducción manual de rangos (aleatorio) <-" >> $informe
			sleep 0.3
			entradaManualRangos
			;;
		5)
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_sel%s%s$_r\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[6]" " -> Otro fichero de rangos"
			printf "\t$_verd%s$_r%s\n\n"		"[7]" " -> Aleatorio total (DatosRangosAleatorioTotal.txt)"
		
			printf "\t$_sel%s%s$_r\n\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)" >> $informeColor
			printf "\t%s\n\n" 					"-> Fichero de rangos de última ejecución (DatosRangosLast.txt) <-" >> $informe
			sleep 0.3
			entradaUltimaEjecRangos
			;;
		6)
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_sel%s%s$_r\n"			"[6]" " -> Otro fichero de rangos"
			printf "\t$_verd%s$_r%s\n\n"		"[7]" " -> Aleatorio total (DatosRangosAleatorioTotal.txt)"
		
			printf "\t$_sel%s%s$_r\n\n"			"[6]" " -> Otro fichero de rangos" >> $informeColor
			printf "\t%s\n\n" 					"-> Otro fichero de rangos <-" >> $informe
			sleep 0.3
			entradaFicheroRangos
		;;
		7)
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[6]" " -> Otro fichero de rangos"
			printf "\t$_sel%s%s$_r\n\n"			"[7]" " -> Aleatorio total (DatosRangosAleatorioTotal.txt)"

			printf "\t$_sel%s%s$_r\n\n"			"[7]" " -> Aleatorio total (DatosRangosAleatorioTotal.txt)" >> $informeColor
			printf "\t%s\n\n" 					"-> Aleatorio total (DatosRangosAleatorioTotal.txt) <-" >> $informe
			sleep 0.3
			entradaAleatorioTotal
		;;
	esac
	
	calculaEspaciosMemoria

	for (( proc=1; proc<=$nProc; proc++ )); do
		if [ "$algReemplazo" = "SEGOP" ]; then
			segundaOportunidad $proc
		else
			reloj $proc
		fi
	done
}

###################################################################################################################################

# Pide el tipo de ejecución al usuario.
function seleccionTipoEjecucion(){
	
	clearYCabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" Seleccione el tipo de ejecución:"
	printf "\t$_verd%s$_r%s\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)"
	printf "\t$_verd%s$_r%s\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)"
	printf "\t$_verd%s$_r%s\n"			"[3]" " -> Automática sin esperas"
	printf "\t$_verd%s$_r%s\n\n"		"[4]" " -> Completa (solo resumen)"
	read -p " Seleccione la opción: " opcionEjec
	until [[ $opcionEjec =~ ^[1-4]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Valor incorrecto." " Escriba '1', '2', '3' o '4': "
		read opcionEjec
	done

	clearYCabecera
	case $opcionEjec in
		1) # Muestra la opción 1 seleccionada.
			printf "\n$_cyan$_b%s\n\n$_r"		" Seleccione el tipo de ejecución:" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Automática sin esperas" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n\n"		"[4]" " -> Completa (solo resumen)" | tee -a $informeColor

			printf "\n%s\n\n"					" Seleccione el tipo de ejecución:" >> $informe
			printf "\t%s%s\n"					" -> [1]" " Por eventos (pulsando INTRO en cada cambio de estado) <-" >> $informe
			printf "\t%s%s\n"					"[2]" " Automática (introduciendo cada cuántos segundos cambia de estado)" >> $informe
			printf "\t%s%s\n"					"[3]" " Automática sin esperas" >> $informe
			printf "\t%s%s\n\n"					"[4]" " Completa (solo resumen)" >> $informe
			sleep 0.3
			;;
		2) # Muestra la opción 2 seleccionada.
			printf "\n$_cyan$_b%s\n\n$_r"		" Seleccione el tipo de ejecución:" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Automática sin esperas" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n\n"		"[4]" " -> Completa (solo resumen)" | tee -a $informeColor

			printf "\n%s\n\n"					" Seleccione el tipo de ejecución:" >> $informe
			printf "\t%s%s\n"					"[1]" " Por eventos (pulsando INTRO en cada cambio de estado)" >> $informe
			printf "\t%s%s\n"					" -> [2]" " Automática (introduciendo cada cuántos segundos cambia de estado) <-" >> $informe
			printf "\t%s%s\n"					"[3]" " Automática sin esperas" >> $informe
			printf "\t%s%s\n\n"					"[4]" " Completa (solo resumen)" >> $informe
			sleep 0.3

			read -p " Introduzca el número de segundos entre cada evento: " segEsperaEventos
			until [[ $segEsperaEventos =~ [0-9] && $segEsperaEventos -gt 0 ]]; do
				printf "\n$_rojo$_b%s$_r%s"	" Valor incorrecto." " Introduzca un número mayor que 0: "
				read segEsperaEventos
			done
			;;
		3) # Muestra la opción 3 seleccionada.
			printf "\n$_cyan$_b%s\n\n$_r"		" Seleccione el tipo de ejecución:" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[3]" " -> Automática sin esperas" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n\n"		"[4]" " -> Completa (solo resumen)" | tee -a $informeColor

			printf "\n%s\n\n"					" Seleccione el tipo de ejecución:" >> $informe
			printf "\t%s%s\n"					"[1]" " Por eventos (pulsando INTRO en cada cambio de estado)" >> $informe
			printf "\t%s%s\n"					"[2]" " Automática (introduciendo cada cuántos segundos cambia de estado)" >> $informe
			printf "\t%s%s\n"					" -> [3]" " Automática sin esperas <-" >> $informe
			printf "\t%s%s\n\n"					"[4]" " Completa (solo resumen)" >> $informe
			# Es igual que la opción 2 solo que los segundos de espera entre eventos son 0.
			segEsperaEventos=0
			opcionEjec=2
			sleep 0.3
			;;
		4) # Muestra la opción 4 seleccionada.
			printf "\n$_cyan$_b%s\n\n$_r"		" Seleccione el tipo de ejecución:" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Automática sin esperas" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[4]" " -> Completa (solo resumen)" | tee -a $informeColor

			printf "\n%s\n\n"					" Seleccione el tipo de ejecución:" >> $informe
			printf "\t%s%s\n"					"[1]" " Por eventos (pulsando INTRO en cada cambio de estado)" >> $informe
			printf "\t%s%s\n"					"[2]" " Automática (introduciendo cada cuántos segundos cambia de estado)" >> $informe
			printf "\t%s%s\n"					"[3]" " Automática sin esperas" >> $informe
			printf "\t%s%s\n\n"					" -> [4]" " Completa (solo resumen) <-" >> $informe
			sleep 0.3
			;;
	esac
	clear
}

###################################################################################################################################

# Las variables globales serán introducidas una a una por teclado.
#	Relativa a la opción 1: 'Introducción manual de datos' en el menú de selección de entrada de datos.
function entradaManual(){
	
	guardaDatos 0
	local otroProc="s";		# Para comprobar si se quiere introducir o no un nuevo proceso.
	
	# Número de marcos en memoria.
	imprimeVarGlob
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el número de marcos de pagina en la \e[1;33mmemoria\e[0m: "
	read marcosMem
	echo -n " Introduzca el número de marcos de pagina en la memoria: " >> $informe
	echo -n -e " Introduzca el número de marcos de pagina en la \e[1;33mmemoria\e[0m: " >> $informeColor
	
	until [[ $marcosMem =~ [0-9] && $marcosMem -gt 0 ]]; do
		echo ""
		echo -e "\e[1;31m El número de marcos de pagina en la memoria debe ser mayor que \e[0m\e[1;33m0\e[0m"
		echo -n -e " Introduzca el número de marcos de pagina en la \e[1;33mmemoria\e[0m: "
		read marcosMem
	done
	echo "$marcosMem" >> $informe
	echo -e "\e[1;32m$marcosMem\e[0m" >> $informeColor
	
	# Tamaño de página.
	clear
	imprimeVarGlob
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el tamaño de \e[1;33mpágina\e[0m: "
	read tamPag
	echo -n " Introduzca el tamaño de página: " >> $informe
	echo -n -e " Introduzca el tamaño de \e[1;33mpágina\e[0m: " >> $informeColor
	
	until [[ $tamPag =~ [0-9] && $tamPag -gt 0 ]]; do
		echo ""
		echo -e "\e[1;31m El tamaño de página debe ser mayor que 0\e[0m"
		echo -n -e " Introduzca el tamaño de \e[1;33mpágina\e[0m: "
		read tamPag
	done
	echo "$tamPag" >> $informe
	echo -e "\e[1;32m$tamPag\e[0m" >> $informeColor
	
	tamMem=$(($marcosMem*$tamPag))

	p=1
	clearImprime
	
	# Pide los datos de cada proceso hasta que no se quieran más procesos.
	while [[ $otroProc == "s" ]]; do

		maxPags[$p]=0;

		# Tiempo de llegada.	
		imprimeHuecosInformes 1 0
		echo -n -e " Introduzca el \e[1;33mtiempo de llegada\e[0m del proceso $p: "
		read tLlegada[$p]
		echo -n " Introduzca el tiempo de llegada del proceso $p: " >> $informe
		echo -n -e " Introduzca el \e[1;33mtiempo de llegada\e[0m del proceso $p: " >> $informeColor
		
		until [[ ${tLlegada[$p]} =~ [0-9] && ${tLlegada[$p]} -ge 0 ]]; do
			echo -e " \e[1;31mEl tiempo de llegada debe ser un número positivo\e[0m"
			echo -n -e " Introduzca el \e[1;33mtiempo de llegada\e[0m del proceso $p: "
			read tLlegada[$p]
		done
		echo "${tLlegada[$p]}" >> $informe
		echo -e "\e[1;32m${tLlegada[$p]}\e[0m" >> $informeColor
		clearImprime
		
		# Número de marcos del proceso.
		imprimeHuecosInformes 1 0
		echo -n -e " Introduzca el \e[1;33mnúmero de marcos\e[0m del proceso $p: "
		read nMarcos[$p]
		until [[ ${nMarcos[$p]} =~ [0-9] && ${nMarcos[$p]} -gt 0 && ${nMarcos[$p]} -le $marcosMem ]]; do
			echo -e " \e[1;31mEl número de marcos de un proceso es como mínimo 1 y no debe superar el número de marcos totales de la memoria\e[0m"
			echo -n -e " Introduzca el \e[1;33mnúmero de marcos\e[0m del proceso $p: "
			read nMarcos[$p]
		done
		echo -n " Introduzca el número de marcos del proceso $p: " >> $informe
		echo -n -e " Introduzca el \e[1;33mnúmero de marcos\e[0m del proceso $p: " >> $informeColor
			
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))	# El tamaño total del proceso será su número de marcos multiplicado por el tamaño de las páginas.

		echo "${nMarcos[$p]}" >> $informe
		echo "" >> $informe
		echo -e "\e[1;32m${nMarcos[$p]}\e[0m" >> $informeColor
		echo "" >> $informeColor
		clearImprime

		for (( pag=0; ; pag++ )); do
			
			imprimeHuecosInformes 1 0
			echo -n -e " Introduzca la \e[1;33mdirección de página\e[0m $(($pag+1)) o 'n' si no quiere más: "
			read  distinta
			if [[ $distinta =~ ^[nN]$ ]]; then
				if [ "$pag" == "0" ]; then
					echo " Debe introducir al menos una página"
					until [[ $distinta =~ [0-9] ]]; do
						echo ""
						echo -e -n " \e[1;31mValor incorrecto, introduce un número \e[0m"
						read distinta
					done
				else
					break
                fi
			fi
			direcciones[$p,$pag]=$distinta

			echo -n " Introduzca la dirección de página $(($pag+1)) o una n si no quiere más: " >> $informe
			echo -n -e " Introduzca la \e[1;33mdirección de página\e[0m $(($pag+1)) o una n si no quiere más: " >> $informeColor
			until [[ ${direcciones[$p,$pag]} =~ [0-9] && ${direcciones[$p,$pag]} -ge 0 ]]; do			
				echo -e " \e[1;31mLa dirección debe ser un número positivo\e[0m"
				echo -n -e " Introduzca la \e[1;33mdirección de página\e[0m $(($pag+1)) o una n si no quiere más: "
				read  direcciones[$p,$pag]
			done
			tEjec[$p]=$(($pag+1))
			maxPags[$p]=${tEjec[$p]}
			echo "${direcciones[$p,$pag]}" >> $informe
			echo -e "\e[1;32m${direcciones[$p,$pag]}\e[0m" >> $informeColor
			paginas[$p,$pag]=$((${direcciones[$p,$pag]}/$tamPag))
			clearImprime
		done
		
		clearImprime
		imprimeHuecosInformes 1 0
		echo -n -e " ¿Desea introducir \e[1;33motro\e[0m proceso? (s = sí, n = no): "
		read otroProc
		echo -n " ¿Desea introducir otro proceso? (s = sí, n = no): " >> $informe
		echo -n " ¿Desea introducir \e[1;33motro\e[0m proceso? (s = sí, n = no): " >> $informeColor
		until [[ $otroProc == "s" || $otroProc == "n" ]]; do	
			echo -e "\e[1;31mPor favor, escriba \"s\" o \"n\" \e[0m"
			read -p " ¿Desea introducir otro proceso? (s = sí, n = no): " otroProc
		done
				
		echo "$otroProc" >> $informe
		echo -e "\e[1;32m$otroProc\e[0m" >> $informeColor
		p=$(($p + 1))

		if [[ "$otroProc" != "n" ]]; then
			clearImprime
		fi
	done
	p=$(($p - 1))
	nProc=$p
	guardaDatos 1
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se inicializan con los datos contenidos en el fichero de última ejecución (DatosLast.txt).
# 	Relativa a la opción 2: 'Fichero de datos de última ejecución (DatosLast.txt)' en el menú de selección de entrada de datos.
function entradaUltimaEjec(){
	
	imprimeHuecosInformes 1 0
	leeDatosFichero "ultimaEjecucion"	
	printf "%s\n" " >> Ha introducido los datos por el fichero de la última ejecución." | tee -a $informeColor
	printf "%s\n" " >> Ha introducido los datos por el fichero de la última ejecución." >> $informe
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se inicializan con los datos contenidos en un fichero de datos.
# 	Relativa a la opción 3: 'Otro fichero de datos' en el menú de selección de entrada de datos.
function entradaFichero(){

	clearYCabecera
	muestraArchivosDatos
	echo -e " Elija un \e[1;32mfichero de datos\e[0m: " | tee -a $informeColor
	echo -n " Elija un fichero de datos: " >> $informe
	read fichSelect
	until [[ $tamMem =~ [0-9] && $fichSelect -gt 0 && $fichSelect -le $max ]]; do
		echo ""
		echo -e "\e[1;31m El valor introducido no es correcto. Debe estar entre\e[0m \e[1;33m1\e[0m \e[1;31my\e[0m \e[1;33m$max\e[0m"
		echo -n " Elija un fichero: "
		read fichSelect
	done

	clearYCabecera
	muestraArchivosDatos 1
	sleep 0.3

	# Guarda el nombre del fichero escogido.
	ficheroIn=`find datosScript/FDatos -maxdepth 1 -type f -iname "*.txt" | sort | cut -f3 -d"/" | cut -f$fichSelect -d$'\n'`
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	echo "$ficheroIn" >> $informe
	
	leeDatosFichero
	local rutaDestino="./datosScript/FDatos/$ficheroIn"
	cp "${rutaDestino}" "./datosScript/FLast/DatosLast.txt"
	printf "%s\n" " >> Ha introducido los datos por fichero." >> $informe
	printf "%s\n" " >> Ha introducido los datos por fichero." | tee -a $informeColor
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores introducido por teclado para cada una.
# 	Relativa a la opción 4: 'Introducción manual de rangos (aleatorio)' en el menú de selección de entrada de datos.
function entradaManualRangos(){
	
	guardaRangos 0
	guardaDatos 0
	inicializaVariablesRangos
	
	# Mínimo número de marcos en memoria.
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el mínimo del rango del número de marcos de pagina en la \e[1;33mmemoria\e[0m: "
	read minRangoMemoria
	echo -n " Introduzca el mínimo número del rango de marcos de pagina en la memoria: " >> $informe
	echo -n -e " Introduzca el mínimo número del rango de marcos de pagina en la \e[1;33mmemoria\e[0m: " >> $informeColor
	until [[ $minRangoMemoria =~ [0-9] && $minRangoMemoria -gt 0 ]]; do
		echo ""
		echo -e "\e[1;31m El mínimo número del rango  de marcos de pagina en la memoria: debe ser mayor que \e[0m\e[1;33m0\e[0m"
		echo -n -e " Introduzca el mínimo número del rango de marcos de pagina en la \e[1;33mmemoria\e[0m: "
		read minRangoMemoria
	done

	# Máximo número de marcos en memoria.
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el máximo del rango del número de marcos de pagina en la \e[1;33mmemoria\e[0m: "
	read maxRangoMemoria
	echo -n " Introduzca el máximo del rango del número de marcos de pagina en la memoria: " >> $informe
	echo -n -e " Introduzca el máximo del rango del número de marcos de pagina en la \e[1;33mmemoria\e[0m: " >> $informeColor
	until [[ $maxRangoMemoria =~ [0-9] && $maxRangoMemoria -ge $minRangoMemoria ]]; do
		echo ""
		echo -e "\e[1;31m El máximo del rango del número de marcos de pagina en la memoria debe ser mayor que \e[0m\e[1;33m$minRangoMemoria\e[0m"
		echo -n -e " Introduzca el máximo del rango del número de marcos de pagina en la \e[1;33mmemoria\e[0m: "
		read maxRangoMemoria
	done
	aleatorioEntre marcosMem $minRangoMemoria $maxRangoMemoria
	echo "$tamMem" >> $informe
	echo -e "\e[1;32m$tamMem\e[0m" >> $informeColor
	
	# Mínimo número de direcciones por marco (nº de direcciones).
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el mínimo del rango del número de direcciones por marco de \e[1;33mpágina (nº de direcciones)\e[0m: "
	read minRangoTamPagina
	echo -n " Introduzca el mínimo del rango del número de direcciones por marco de  página (nº de direcciones): " >> $informe
	echo -n -e " Introduzca el mínimo del rango del número de direcciones por marco de  \e[1;33mpágina (nº de direcciones)\e[0m: " >> $informeColor
	until [[ $minRangoTamPagina =~ [0-9] && $minRangoTamPagina -gt 0 ]]; do
		echo ""
		echo -e "\e[1;31m del rango del número de direcciones por marco de página debe ser mayor que 0\e[0m"
		echo -n -e " Introduzca el mínimo tamaño del marco de \e[1;33mpágina (nº de direcciones)\e[0m: "
		read minRangoTamPagina
	done

	# Máximo número de direcciones por marco (nº de direcciones).	
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el máximo del rango del número de direcciones por marco de \e[1;33mpágina (nº de direcciones)\e[0m: "
	read maxRangoTamPagina
	echo -n " Introduzca el máximo del rango del número de direcciones por marco de página (nº de direcciones): " >> $informe
	echo -n -e " Introduzca el máximo del rango del número de direcciones por marco de \e[1;33mpágina (nº de direcciones)\e[0m: " >> $informeColor
	until [[ $maxRangoTamPagina =~ [0-9] && $maxRangoTamPagina -ge $minRangoTamPagina ]]; do
		echo ""
		echo -e "\e[1;31m El máximo del rango del número de direcciones por marco de página (nº de direcciones) debe ser mayor o igual que $minRangoTamPagina\e[0m"
		echo -n -e " Introduzca el máximo del rango del número de direcciones por marco de \e[1;33mpágina (nº de direcciones)\e[0m: "
		read maxRangoTamPagina
	done
	
	aleatorioEntre tamPag $minRangoTamPagina $maxRangoTamPagina
	echo "$tamPag" >> $informe
	echo -e "\e[1;32m$tamPag\e[0m" >> $informeColor
	tamMem=$(($marcosMem*$tamPag))

	p=1

	# Mínimo número de procesos.	
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el mínimo del rango del número de \e[1;33mprocesos\e[0m: "
	read minRangoNumProcesos
	echo -n " Introduzca el mínimo del rango del número de procesos: " >> $informe
	echo -n -e " Introduzca el mínimo del rango del número de \e[1;33mprocesos\e[0m: " >> $informeColor
	until [[ $minRangoNumProcesos =~ [0-9] && $minRangoNumProcesos -gt 0 ]]; do
		echo ""
		echo -e "\e[1;31m El mímimo del rango del número de procesos debe ser mayor que 0\e[0m"
		echo -n -e " Introduzca el mínimo del rango del número de procesos \e[1;33mprocesos\e[0m: "
		read minRangoNumProcesos
	done

	# Máximo número de procesos.	
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el máximo del rango del número de \e[1;33mprocesos\e[0m: "
	read maxRangoNumProcesos
	echo -n " Introduzca el máximo del rango del número de procesos " >> $informe
	echo -n -e " Introduzca el máximo del rango del número de \e[1;33mprocesos\e[0m: " >> $informeColor
	until [[ $maxRangoNumProcesos =~ [0-9] && $maxRangoNumProcesos -ge $minRangoNumProcesos ]]; do
		echo ""
		echo -e "\e[1;31m El máximo del rango del número de procesos debe ser mayor o igual que $minRangoNumProcesos\e[0m"
		echo -n -e " Introduzca el máximo del rango del número de \e[1;33mprocesos\e[0m: "
		read maxRangoNumProcesos
	done
	
	aleatorioEntre numeroProcesos $minRangoNumProcesos $maxRangoNumProcesos

	# Tiempo de llegada mínimo de los procesos.
	clearYCabecera
	imprimeVarGlobRangos
	maxPags[$p]=0;
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el mínimo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: "
	read minRangoTLlegada
	echo -n " Introduzca el mínimo del rango del tiempo de llegada de los procesos: " >> $informe
	echo -n -e " Introduzca el mínimo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: " >> $informeColor
	until [[ $minRangoTLlegada =~ [0-9] && $minRangoTLlegada -ge 0 ]]; do
		echo -e " \e[1;31mEl mínimo del rango del tiempo de llegada debe ser un número positivo\e[0m"
		echo -n -e " Introduzca el mínimo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: "
		read minRangoTLlegada
	done

	# Tiempo de llegada máximo de los procesos.
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el máximo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: "
	read maxRangoTLlegada
	echo -n " Introduzca el máximo del rango del tiempo de llegada de los procesos: " >> $informe
	echo -n -e " Introduzca el máximo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: " >> $informeColor
	until [[ $maxRangoTLlegada =~ [0-9] && $maxRangoTLlegada -ge $minRangoTLlegada ]]; do
		echo -e " \e[1;31mEl máximo del rango del tiempo de llegada debe ser un número mayor o igual que $minRangoTLlegada\e[0m"
		echo -n -e " Introduzca el máximo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: "
		read maxRangoTLlegada
	done

	# Mínimo número de marcos asociados a cada proceso.	
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el mínimo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
	read minRangoNumMarcos
	echo -n " Introduzca el mínimo del número de marcos asociados a cada proceso: " >> $informe
	echo -n -e " Introduzca el mínimo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: " >> $informeColor
	until [[ $minRangoNumMarcos =~ [0-9] && $minRangoNumMarcos -ge 0 && $minRangoNumMarcos -le $marcosMem ]]; do
		echo ""
		echo -e "\e[1;31m El mínimo del número de marcos asociados a cada proceso debe ser un número positivo menor que el nº marcos totales\e[0m"
		echo -n -e " Introduzca el mínimo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
		read minRangoNumMarcos
	done

	# Máximo número de marcos asociados a cada proceso.	
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el máximo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
	read maxRangoNumMarcos
	echo -n " Introduzca el máximo del número de marcos asociados a cada proceso: " >> $informe
	echo -n -e " Introduzca el máximo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: " >> $informeColor
	until [[ $maxRangoNumMarcos =~ [0-9] && $maxRangoNumMarcos -ge $minRangoNumMarcos && $maxRangoNumMarcos -le $marcosMem ]]; do
		echo ""
		echo -e "\e[1;31m El máximo número del rango de marcos asociados a cada procesos debe ser un número positivo mayor o igual que $minRangoNumMarcos y menor que el nº de marcos totales \e[0m"
		echo -n -e " Introduzca el máximo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
		read maxRangoNumMarcos
	done		

	# Mínimo valor para una dirección de página.	
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el \e[1;33mmínimo del rango del número de direcciones a ejecutar\e[0m: "
	read  minRangoValorDireccion
	until [[ $minRangoValorDireccion =~ [0-9] && $minRangoValorDireccion -ge 0 ]]; do
		echo ""
		echo -e "\e[1;31m El mínimo del rango del número de direcciones a ejecutar debe ser mayor o igual que \e[0m\e[1;33m0 \e[0m"
		echo -n -e " Introduzca el \e[1;33mmínimo del rango del número de direcciones a ejecutar\e[0m: "
		read minRangoValorDireccion
	done

	# Máximo valor para una dirección de página.		
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca la máxima\e[1;33m dirección de página\e[0m : "
	read  maxRangoValorDireccion
	until [[ $maxRangoValorDireccion =~ [0-9] && $maxRangoValorDireccion -ge $minRangoValorDireccion ]]; do
		echo ""
		echo -e "\e[1;31m La máxima dirección de página debe ser mayor que \e[0m\e[1;33m$minRangoValorDireccion\e[0m"
		echo -n -e " Introduzca la \e[1;33mmáxima dirección de página\e[0m: "
		read maxRangoValorDireccion
	done
	
	# Tamaño mínimo del proceso.			
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el mínimo del rango del \e[1;33mtamaño del proceso (direcciones) \e[0m: "
	read  minRangoNumDirecciones	
	until [[ $minRangoNumDirecciones =~ [0-9] && $minRangoNumDirecciones -ge 1 ]]; do
		echo ""
		echo -e "\e[1;31m El mínimo del rango del tamaño del proceso (direcciones) debe ser mayor que \e[0m\e[1;33m0 \e[0m"
		echo -n -e " Introduzca el mínimo del rango del \e[1;33mtamaño del proceso (direcciones) \e[0m: "
		read minRangoNumDirecciones
	done
	
	# Tamaño máximo del proceso.	
	clearYCabecera
	imprimeVarGlobRangos
	imprimeHuecosInformes 1 1
	echo -n -e " Introduzca el máximo del rango del \e[1;33mtamaño del proceso (direcciones) \e[0m: "
	read  maxRangoNumDirecciones
	until [[ $maxRangoNumDirecciones =~ [0-9] && $maxRangoNumDirecciones -ge $minRangoNumDirecciones ]]; do
		echo ""
		echo -e "\e[1;31m El máximo del rango del tamaño del proceso (direcciones) debe ser mayor que \e[0m\e[1;33m$minRangoNumDirecciones\e[0m"
		echo -n -e " Introduzca el máximo del rango del \e[1;33mtamaño del proceso (direcciones) \e[0m: "
		read maxRangoNumDirecciones
	done
	
	for (( p=1; p<=$numeroProcesos; p++ )); do
		maxPags[$p]=0;
		aleatorioEntre tLlegada[$p] $minRangoTLlegada $maxRangoTLlegada
		pag=${tEjec[$p]};
		aleatorioEntre nMarcos[$p] $minRangoNumMarcos $maxRangoNumMarcos
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
		
		aleatorioEntre numeroDirecciones[$p] $minRangoNumDirecciones $maxRangoNumDirecciones
		
		for (( pag=0; pag<=${numeroDirecciones[$p]}; pag++ )); do
			aleatorioEntre valorDirecciones $minRangoValorDireccion $maxRangoValorDireccion
			direcciones[$p,$pag]=$valorDirecciones
			tEjec[$p]=$(($pag+1))
			maxPags[$p]=${tEjec[$p]}
			paginas[$p,$pag]=$((${direcciones[$p,$pag]}/$tamPag))
		done
	done
	
	p=$(($p - 1))
	nProc=$p
	imprimeVarGlobRangos
	printf "\n%s\n" " Pulse INTRO para continuar ↲"
	read

	guardaRangos 1
	guardaDatos 1
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores contenido en el fichero de última ejecución (DatosRangosLast.txt).
# 	Relativa a la opción 5: 'Fichero de rangos de última ejecución (DatosRangosLast.txt)' en el menú de selección de entrada de datos.
function entradaUltimaEjecRangos(){
	
	inicializaVariablesRangos
	leeRangosFichero "ultimaEjecucion"
	guardaDatos 0
	generaDatosAleatorios
	printf "%s\n" " >> Los datos se han generado por el fichero de rangos de última ejecución." | tee -a $informeColor
	printf "%s\n" " >> Los datos se han generado por el fichero de rangos de última ejecución." >> $informe
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores contenido en un fichero de rangos.
# 	Relativa a la opción 6: 'Otro fichero de rangos' en el menú de selección de entrada de datos.
function entradaFicheroRangos(){

	clearYCabecera
	imprimeHuecosInformes 1 1
	muestraArchivosRangos
	echo -e " Elija un \e[1;32mfichero de rangos\e[0m: " | tee -a $informeColor
	echo -n " Elija un fichero de rangos: " >> $informe
	read fichSelect
	until [[ $tamMem =~ [0-9] && $fichSelect -gt 0 && $fichSelect -le $max ]]; do
		echo ""
		echo -e "\e[1;31m El valor introducido no es correcto. Debe estar entre\e[0m \e[1;33m1\e[0m \e[1;31my\e[0m \e[1;33m$max\e[0m"
		echo -n " Elija un fichero de rangos: "
		read fichSelect
	done

	clearYCabecera
	muestraArchivosRangos 1
	sleep 0.3

	# Guarda el nombre del fichero escogido.
	ficheroIn=`find datosScript/FRangos -maxdepth 1 -type f -iname "*.txt" | sort | cut -f3 -d"/" | cut -f$fichSelect -d$'\n'`
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	echo "$ficheroIn" >> $informe

	guardaDatos 0
	inicializaVariablesRangos
	leeRangosFichero
	generaDatosAleatorios
	local rutaDestino="./datosScript/FRangos/$ficheroIn"
	cp "${rutaDestino}" "./datosScript/FLast/DatosRangosLast.txt"
	printf "%s\n" " >> Los datos se han generado por un fichero de rangos." | tee -a $informeColor
	printf "%s\n" " >> Los datos se han generado por un fichero de rangos." >> $informe
	imprimeProcesosFinal
}

###################################################################################################################################

# A partir de un fichero de rangos totales (más grandes que los normales), se genera un fichero de rangos, del que luego se generan los datos a ejecutar.
#	Relativa a la opción 7: 'Aleatorio total (DatosRangosAleatorioTotal.txt)' en el menú de selección de entrada de datos.
function entradaAleatorioTotal(){
	
	guardaRangos 0
	guardaDatos 0
	leeRangosAleatorioTotal
	imprimeVarAleatorioTotal
	compruebaRangosAleatorioTotal
	echo " Pulse INTRO para continuar ↲ "
	read
	clear
	imprimeVarAleatorioTotal
	echo " Pulse INTRO para continuar ↲ "
	read
	guardaRangos 1
	generaDatosAleatorios "aleatorioTotal"
	imprimeProcesosFinal
}



###########################
#        AUXILIARES       #
###########################

# Muestra los archivos que hay en el directorio './datosScript/FDatos'.
# 	Si se han pasado argumentos, muestra todos los archivos y resalta el elegido. Si no, imprime todos los archivos.
function muestraArchivosDatos(){
	
	max=`find datosScript/FDatos -maxdepth 1 -type f | cut -f3 -d"/" | wc -l`				# Número de archivos en el directorio.
	printf "\n$_cyan$_b%s\n\n$_r"		" Archivos en el directorio './datosScript/FDatos': "
	
	if [[ $# -gt 0 ]]; then		# Si el número de argumentos pasados ($#) es mayor que 0...
		for (( i=1; i<=$max; i++ )); do
			file=`find datosScript/FDatos -maxdepth 1 -type f | cut -f3 -d"/" | sort | cut -f$i -d$'\n'` # Mostrar sólo los nombres de ficheros (no directorios).
			if [ $i -eq $fichSelect ]; then
				printf '    \e[1;38;5;64;48;5;7m	[%2u]\e[90m %-20s\e[0m\n' "$i" "$file" 		# Resaltar opción escogida.
			else
				printf '    \e[1;32m	[%2u]\e[0m %-20s\e[0m\n' "$i" "$file"
			fi
		done
	else
		for (( i=1; i<=$max; i++ )); do
			file=`find datosScript/FDatos -maxdepth 1 -type f | cut -f3 -d"/" | sort | cut -f$i -d$'\n'` # Mostrar sólo los nombres de ficheros (no directorios).
			printf '    \e[1;32m	[%2u]\e[0m %-20s\e[0m\n' "$i" "$file"
		done
	fi
	printf "\n"
}

###################################################################################################################################

# Muestra los archivos que hay en el directorio './datosScript/FRangos'.
# 	Si se han pasado argumentos, muestra todos los archivos y resalta el elegido. Si no, imprime todos los archivos.
function muestraArchivosRangos(){

	max=`find datosScript/FRangos -maxdepth 1 -type f | cut -f3 -d"/" | wc -l`		# Número de archivos en el directorio.
	printf "\n$_cyan$_b%s\n\n$_r"		" Archivos en el directorio './datosScript/FRangos': "
	
	if [[ $# -gt 0 ]]; then		# Si el número de argumentos pasados ($#) es mayor que 0...
		for (( i=1; i<=$max; i++ )); do
			file=`find datosScript/FRangos -maxdepth 1 -type f | cut -f3 -d"/" | sort | cut -f$i -d$'\n'` 	# Mostrar sólo los nombres de ficheros (no directorios).
			if [ $i -eq $fichSelect ]; then
				printf '    \e[1;38;5;64;48;5;7m	[%2u]\e[90m %-20s\e[0m\n' "$i" "$file" 					# Resaltar opción escogida.
			else
				printf '    \e[1;32m	[%2u]\e[0m %-20s\e[0m\n' "$i" "$file"
			fi
		done
	else
		for (( i=1; i<=$max; i++ )); do
			file=`find datosScript/FRangos -maxdepth 1 -type f | cut -f3 -d"/" | sort | cut -f$i -d$'\n'` #Mostrar solo los nombres de ficheros (no directorios).
			printf '    \e[1;32m	[%2u]\e[0m %-20s\e[0m\n' "$i" "$file"
		done
	fi
	printf "\n"
}

###################################################################################################################################

# Inicializa por defecto las variables relativas a la generación aleatoria de datos por medio de rangos.
function inicializaVariablesRangos(){

	minRangoMemoria=0
	maxRangoMemoria=0
	minRangoTamPagina=0
	maxRangoTamPagina=0
	minRangoNumProcesos=0
	maxRangoNumProcesos=0
	numeroProcesos=0
	minRangoTLlegada=0
	maxRangoTLlegada=0
	minRangoNumMarcos=0
	maxRangoNumMarcos=0
	minRangoNumDirecciones=0
	maxRangoNumDirecciones=0
	numeroDirecciones=()
	minRangoValorDireccion=0
	maxRangoValorDireccion=0
	valorDirecciones=0
}

###################################################################################################################################

# Genera datos aleatorios a partir de un fichero de rangos.
#	- Si se pasa como parámetro 'aleatorioTotal', se excluye de calcular los parámetros de la memoria principal y nº procesos puesto que ya se han calculado.
function generaDatosAleatorios(){
	
	if [[ $1 != "aleatorioTotal" ]]; then
		
		aleatorioEntre marcosMem $minRangoMemoria $maxRangoMemoria
		aleatorioEntre tamPag $minRangoTamPagina $maxRangoTamPagina
		tamMem=$(($marcosMem*$tamPag))
		aleatorioEntre numeroProcesos $minRangoNumProcesos $maxRangoNumProcesos
	fi

	p=1
	for (( p=1; p<=$numeroProcesos; p++ )); do
		maxPags[$p]=0;
		
		aleatorioEntre tLlegada[$p] $minRangoTLlegada $maxRangoTLlegada
		pag=${tEjec[$p]};
		aleatorioEntre nMarcos[$p] $minRangoNumMarcos $maxRangoNumMarcos
		
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
		aleatorioEntre numeroDirecciones[$p] $minRangoNumDirecciones $maxRangoNumDirecciones
		
		for (( pag=0; pag<=${numeroDirecciones[$p]}; pag++ )); do
			
			aleatorioEntre valorDirecciones $minRangoValorDireccion $maxRangoValorDireccion
			direcciones[$p,$pag]=$valorDirecciones
			tEjec[$p]=$(($pag+1))
			maxPags[$p]=${tEjec[$p]}
			paginas[$p,$pag]=$((${direcciones[$p,$pag]}/$tamPag))
		done
	done
	
	p=$(($p - 1))
	nProc=$p
	guardaDatos 1
}

###################################################################################################################################

# Lee un fichero de DATOS y asigna a las variables los valores contenidos en él.
# 	- Si se pasa como parámetro "ultimaEjecucion", el fichero a leer será 'DatosLast.txt'.
# 	- Si no hay parámetros, el fichero a leer será el que haya especificado anteriormente el usuario, almacenado en la variable 'ficheroIn'.
function leeDatosFichero(){

	if [[ $1 == "ultimaEjecucion" ]]; then
		
		nombreFicheroDatos="DatosLast"	
		if [ ! -f "./datosScript/FLast/${nombreFicheroDatos}.txt" ]; then		# Si el archivo NO existe, se informa del error.
    	
			printf "\n$_rojo$_b%s$_r%s"	" ERROR." " El archivo $nombreFicheroDatos.txt no existe. "
			printf "\n%s" " >> Nota: El archivo de datos de última ejecución se creará automáticamente cuando se ejecute algún algoritmo."
			printf "\n\n%s\n" " Pulse INTRO para salir del programa ↲"
			printf "\n\n%s\n" " Pulse INTRO para salir del programa ↲"
			read
			exit 1
		else
			ficheroDatosIn="./datosScript/FLast/${nombreFicheroDatos}.txt"
		fi	
	else
		ficheroDatosIn="./datosScript/FDatos/$ficheroIn"
	fi

	tamMem=$(awk 'NR==1' "$ficheroDatosIn")
	tamPag=$(awk 'NR==2' "$ficheroDatosIn")
	marcosMem=$(($tamMem/$tamPag))
	# Habrá tantos procesos como líneas tenga el fichero (ignorando las 2 líneas del principio, que son el tamaño de la memoria y sus páginas).
	nProc=$(($(wc -l < "$ficheroDatosIn")-2))		
	p=1;
	local maxFilas=$(($nProc+2))
	for (( fila = 3; fila <= $maxFilas; fila++ )); do

		linea=$(awk "NR==$fila" "$ficheroDatosIn")
		IFS=";" read -r -a parte <<< "$linea"

		tLlegada[$p]=${parte[0]}
		nMarcos[$p]=${parte[1]}
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
		tEjec[$p]=$((${#parte[*]}-3))
		maxPags[$p]=${tEjec[$p]}
		
		for (( n = 0; n < ${maxPags[$p]}; n++ )); do
			m=$(($n+3))
			direcciones[$p,$n]=${parte[$m]}
			paginas[$p,$n]=$(( ${direcciones[$p,$n]}/$tamPag ))
		done
		p=$(($p+1))
	done

	p=$(($p-1))
	clear
}

###################################################################################################################################

# Lee un fichero de RANGOS y asigna a las variables los valores mínimos y máximos contenidos en él.
# 	- Si se pasa como parámetro "ultimaEjecucion", el fichero a leer será 'DatosRangosLast.txt' (del directorio FLast).
# 	- Si no hay parámetros, el fichero a leer será el que haya especificado anteriormente el usuario, almacenado en la variable 'ficheroIn'.
function leeRangosFichero(){
	
	if [[ $1 == "ultimaEjecucion" ]]; then
		
		nombreFicheroRangos="DatosRangosLast"	
		if [ ! -f "./datosScript/FLast/${nombreFicheroRangos}.txt" ]; then		# Si el archivo NO existe, se informa del error.
    	
			printf "\n$_rojo$_b%s$_r%s"	" ERROR." " El archivo $nombreFicheroRangos.txt no existe. "
			printf "\n%s" " >> Nota: El archivo de rangos de última ejecución se creará automáticamente cuando se ejecute algún algoritmo"
			printf "\n%s" "          donde se hayan utilizado rangos para la introducción de datos."
			printf "\n\n%s\n" " Pulse INTRO para salir del programa ↲"
			read
			exit 1
		else
			ficheroRangosIn="./datosScript/FLast/${nombreFicheroRangos}.txt"
		fi	
	else
		ficheroRangosIn="./datosScript/FRangos/$ficheroIn"
	fi

	minRangoMemoria=`head -n 1 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 1`
	maxRangoMemoria=`head -n 1 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 2`
	minRangoTamPagina=`head -n 2 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 1`
	maxRangoTamPagina=`head -n 2 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 2`
	minRangoNumProcesos=`head -n 3 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 1`
	maxRangoNumProcesos=`head -n 3 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 2`
	minRangoTLlegada=`head -n 4 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 1`
	maxRangoTLlegada=`head -n 4 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 2`
	minRangoNumMarcos=`head -n 5 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 1`
	maxRangoNumMarcos=`head -n 5 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 2`
	minRangoNumDirecciones=`head -n 6 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 1`
	maxRangoNumDirecciones=`head -n 6 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 2`
	minRangoValorDireccion=`head -n 7 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 1`
	maxRangoValorDireccion=`head -n 7 $ficheroRangosIn | tail -n 1 | cut -d "-" -f 2`
}

###################################################################################################################################

# Lee los RANGOS del fichero 'DatosRangosAleatorioTotal.txt' (del directorio FRangosAleTotal).
function leeRangosAleatorioTotal(){

	nombreFicheroAleTotal="DatosRangosAleatorioTotal"	
	if [ ! -f "./datosScript/FRangosAleTotal/${nombreFicheroAleTotal}.txt" ]; then		# Si el archivo NO existe, se informa del error.
    	
		printf "\n$_rojo$_b%s$_r%s"	" ERROR." " El archivo $nombreFicheroAleTotal.txt no existe. "
		printf "\n\n%s\n" " Pulse INTRO para salir del programa ↲"
		read
		exit 1
	else
		ficheroRangosIn="./datosScript/FRangosAleTotal/${nombreFicheroAleTotal}.txt"
	fi

	for (( fila=1; fila<=7; fila++ )); do

		linea=$(sed -n "${fila}p" "$ficheroRangosIn")				# Leer la línea correspondiente en el archivo.
		lineaSinParentesis=$(echo "$linea" | sed 's/[()]//g')		# Eliminar paréntesis y obtener los valores.
		
		case "${fila}" in
			1)
				IFS=',' read -r minRangoMemoriaAleTotal maxRangoMemoriaAleTotal <<< "$lineaSinParentesis"
				aleatorioEntreConNegativos minRangoMemoria $minRangoMemoriaAleTotal $maxRangoMemoriaAleTotal;;
			2)
				IFS=',' read -r minRangoTamPaginaAleTotal maxRangoTamPaginaAleTotal <<< "$lineaSinParentesis"
				aleatorioEntreConNegativos minRangoTamPagina $minRangoTamPaginaAleTotal $maxRangoTamPaginaAleTotal;;
			3)
				IFS=',' read -r minRangoNumProcesosAleTotal maxRangoNumProcesosAleTotal <<< "$lineaSinParentesis"
				aleatorioEntreConNegativos minRangoNumProcesos $minRangoNumProcesosAleTotal $maxRangoNumProcesosAleTotal;;
			4)
				IFS=',' read -r minRangoTLlegadaAleTotal maxRangoTLlegadaAleTotal <<< "$lineaSinParentesis"
				aleatorioEntreConNegativos minRangoTLlegada $minRangoTLlegadaAleTotal $maxRangoTLlegadaAleTotal;;
			5)
				IFS=',' read -r minRangoNumMarcosAleTotal maxRangoNumMarcosAleTotal <<< "$lineaSinParentesis"
				aleatorioEntreConNegativos minRangoNumMarcos $minRangoNumMarcosAleTotal $maxRangoNumMarcosAleTotal;;
			6)
				IFS=',' read -r minRangoNumDireccionesAleTotal maxRangoNumDireccionesAleTotal <<< "$lineaSinParentesis"
				aleatorioEntreConNegativos minRangoNumDirecciones $minRangoNumDireccionesAleTotal $maxRangoNumDireccionesAleTotal;;
			7)
				IFS=',' read -r minRangoValorDireccionAleTotal maxRangoValorDireccionAleTotal <<< "$lineaSinParentesis"
				aleatorioEntreConNegativos minRangoValorDireccion $minRangoValorDireccionAleTotal $maxRangoValorDireccionAleTotal;;
		esac
	done
}

###################################################################################################################################

# Comprueba los mínimos generados en el primer instante de la opción 'Aleatorio Total'. Si hay error, se notifica (añade al log)
# y se recalcula el mínimo. Después se calcula el máximo a partir del mínimo (que ha sido recalculado o no).
function compruebaRangosAleatorioTotal(){

	local numFallosAleTotal=0
	local logErroresAleTotal="\n"

	# El número de marcos de la memoria tiene que ser como mínimo 1.
	if [ "$minRangoMemoria" -lt 1 ]; then
    	aleatorioEntreConNegativos minRangoMemoria 1 $maxRangoMemoriaAleTotal
		logErroresAleTotal+=" - Tiene que haber como mínimo 1 marco en la memoria total.\n"
		logErroresAleTotal+="     >> Se va a recalcular el valor mínimo de marcos de memoria entre 1 y ${maxRangoMemoriaAleTotal}.\n"
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoMemoria $minRangoMemoria $maxRangoMemoriaAleTotal


	# El tamaño de página tiene que ser como mínimo 1.
	if [ "$minRangoTamPagina" -lt 1 ]; then
    	aleatorioEntreConNegativos minRangoTamPagina 1 $maxRangoTamPaginaAleTotal
		logErroresAleTotal+=" - El tamaño de página tiene que ser como mínimo 1.\n"
		logErroresAleTotal+="     >> Se va a recalcular el valor mínimo de tamaño de página entre 1 y ${maxRangoTamPaginaAleTotal}.\n"
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoTamPagina $minRangoTamPagina $maxRangoTamPaginaAleTotal


	# Calculamos los parámetros de la memoria porque algunos parámetros posteriores (nº marcos por proceso) dependen de ellos.
	aleatorioEntreConNegativos marcosMem $minRangoMemoria $maxRangoMemoria
	aleatorioEntreConNegativos tamPag $minRangoTamPagina $maxRangoTamPagina
	tamMem=$(($marcosMem*$tamPag))


	# Tiene que haber como mínimo 1 proceso.
	if [ "$minRangoNumProcesos" -lt 1 ]; then
    	aleatorioEntreConNegativos minRangoNumProcesos 1 $maxRangoNumProcesosAleTotal
		logErroresAleTotal+=" - Tiene que haber como mínimo 1 proceso.\n"
		logErroresAleTotal+="     >> Se va a recalcular el valor mínimo de nº procesos entre 1 y ${maxRangoNumProcesosAleTotal}.\n"
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoNumProcesos $minRangoNumProcesos $maxRangoNumProcesosAleTotal
	# Calculamos el número de procesos total.
	aleatorioEntre numeroProcesos $minRangoNumProcesos $maxRangoNumProcesos


	# El tiempo de llegada de un proceso puede ser a partir de 0.
	if [ "$minRangoTLlegada" -lt 0 ]; then
    	aleatorioEntreConNegativos minRangoTLlegada 0 $maxRangoTLlegadaAleTotal
		logErroresAleTotal+=" - Los tiempos de llegada deben ser a partir del instante T=0.\n"
		logErroresAleTotal+="     >> Se va a recalcular el valor mínimo de tiempo de llegada entre 0 y ${maxRangoTLlegadaAleTotal}.\n"
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoTLlegada $minRangoTLlegada $maxRangoTLlegadaAleTotal


	# El número de marcos asociados a un proceso tiene que ser como mínimo 1. También tiene que ser menor que el número de marcos de la memoria.
	if [ "$minRangoNumMarcos" -lt 1 ]; then
    	# Si el número de marcos de la memoria es menor que el máximo del rango aleatorio total del fichero, entonces el límite máximo
		# pasa a ser el número de marcos de la memoria. Si no, el límite seguirá siendo el indicado en el fichero.
		if [ "$marcosMem" -lt "$maxRangoNumMarcosAleTotal"  ]; then
			aleatorioEntreConNegativos minRangoNumMarcos 1 $marcosMem
			logErroresAleTotal+=" - El número de marcos asociados a un proceso tiene que ser como mínimo 1.\n"
			logErroresAleTotal+="     >> Se va a recalcular el valor mínimo de marcos de procesos entre 1 y ${marcosMem} (nº marcos memoria).\n"
		else
			aleatorioEntreConNegativos minRangoNumMarcos 1 $maxRangoNumMarcosAleTotal
			logErroresAleTotal+=" - El número de marcos asociados a un proceso tiene que ser como mínimo 1.\n"
			logErroresAleTotal+="     >> Se va a recalcular el valor mínimo de marcos de procesos entre 1 y ${maxRangoNumMarcosAleTotal}.\n"
		fi
		((numFallosAleTotal++))

	elif [ "$minRangoNumMarcos" -gt "$marcosMem" ]; then		# Cabe la posibilidad de que el mínimo generado supere el número de marcos de la memoria.
		aleatorioEntreConNegativos minRangoNumMarcos 1 $marcosMem
		logErroresAleTotal+=" - El número de marcos asociados a un proceso no puede exceder el número de marcos de la memoria.\n"
		logErroresAleTotal+="     >> Se va a recalcular el valor mínimo de marcos de procesos entre 1 y ${$marcosMem} (nº marcos memoria).\n"
		((numFallosAleTotal++))
	fi

	if [ "$marcosMem" -lt "$maxRangoNumMarcosAleTotal"  ]; then
		aleatorioEntreConNegativos maxRangoNumMarcos $minRangoNumMarcos $marcosMem
	else
		aleatorioEntreConNegativos maxRangoNumMarcos $minRangoNumMarcos $maxRangoNumMarcosAleTotal
	fi


	# Cada proceso debe tener como mínimo 1 dirección de página.
	if [ "$minRangoNumDirecciones" -lt 1 ]; then
    	aleatorioEntreConNegativos minRangoNumDirecciones 1 $maxRangoNumDireccionesAleTotal
		logErroresAleTotal+=" - Cada proceso debe tener como mínimo 1 dirección de página.\n"
		logErroresAleTotal+="     >> Se va a recalcular el valor mínimo de nº direcciones entre 1 y ${maxRangoNumDireccionesAleTotal}.\n"
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoNumDirecciones $minRangoNumDirecciones $maxRangoNumDireccionesAleTotal


	# El valor de las direcciones de página de un proceso puede ser a partir de 0.
	if [ "$minRangoValorDireccion" -lt 0 ]; then
    	aleatorioEntreConNegativos minRangoValorDireccion 0 $maxRangoValorDireccionAleTotal
		logErroresAleTotal+=" - Los valores de las direcciones de página de los procesos van de 0 en adelante.\n"
		logErroresAleTotal+="     >> Se va a recalcular el valor mínimo de valor de dirección entre 0 y ${maxRangoValorDireccionAleTotal}.\n"
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoValorDireccion $minRangoValorDireccion $maxRangoValorDireccionAleTotal

	printf "\n\n$_rojo$_b%s$_r" " ERRORES" | tee -a $informeColor
	printf "\n\n%s" " ERRORES" >> $informe
	if [ "$numFallosAleTotal" -ne 0 ]; then
		echo -ne "$logErroresAleTotal" | tee -a $informeColor
		echo -ne "$logErroresAleTotal" >> $informe
	else
		printf "\n\n%s" " >> No se han producido fallos al generar los rangos mínimos aleatoriamente." | tee -a $informeColor
		printf "\n\n%s" " >> No se han producido fallos al generar los rangos mínimos aleatoriamente." >> $informe
	fi
	imprimeHuecosInformes 2 1
}



###################################################################################
##                                                                               ##
##                                                                               ##
###################################################################################
####     #####     ####                                     ####     #####     ####
#########     #########  #################################  #########     #########
#########     #########  ##                             ##  #########     #########
####     #####     ####  ##                             ##  ####     #####     ####
####     #####     ####  ##   #######################   ##  ####     #####     ####
#########     #########  ##   ##-------------------##   ##  #########     #########
#########     #########  ##   ##--TABLAS-DE-DATOS--##   ##  #########     #########
####     #####     ####  ##   ##-------------------##   ##  ####     #####     ####
####     #####     ####  ##   #######################   ##  ####     #####     ####
#########     #########  ##                             ##  #########     #########
#########     #########  ##                             ##  #########     #########
####     #####     ####  #################################  ####     #####     ####
#######################                                     #######################


# Muestra por pantalla las variables globales.
function imprimeVarGlob(){
	
	echo -e " Memoria del Sistema:  \e[1;33m$tamMem\e[0m"
	echo -e "    Tamaño de página:  \e[1;33m$tamPag\e[0m"
	echo -e "    Número de marcos:  \e[1;33m$marcosMem\e[0m"
}

###################################################################################################################################

# Muestra por pantalla los parámetros y variables globales que se han obtenido aleatoriamente en las opciones de rangos.
function imprimeVarGlobRangos(){
	
	printf " Número de marcos de página en la memoria:  | Mínimo: \e[1;33m%4d\e[0m | Máximo: \e[1;33m%4d\e[0m | Resultado: \e[1;33m%4d\e[0m | \n"   "${minRangoMemoria}" "${maxRangoMemoria}" "${marcosMem}"
	printf " Número de direcciones por marco de página: | Mínimo: \e[1;33m%4d\e[0m | Máximo: \e[1;33m%4d\e[0m | Resultado: \e[1;33m%4d\e[0m | \n"   "${minRangoTamPagina}" "${maxRangoTamPagina}" "${tamPag}"
	printf " Memoria del sistema:                       |              |              | Resultado: \e[1;33m%4d\e[0m | \n"   "${tamMem}"
	printf " Número de procesos:                        | Mínimo: \e[1;33m%4d\e[0m | Máximo: \e[1;33m%4d\e[0m | Resultado: \e[1;33m%4d\e[0m | \n"   "${minRangoNumProcesos}" "${maxRangoNumProcesos}" "${numeroProcesos}"
	printf " Tiempo de llegada:                         | Mínimo: \e[1;33m%4d\e[0m | Máximo: \e[1;33m%4d\e[0m |\n"   "${minRangoTLlegada}" "${maxRangoTLlegada}"
	printf " Número de marcos asociados a cada proceso: | Mínimo: \e[1;33m%4d\e[0m | Máximo: \e[1;33m%4d\e[0m |\n"   "${minRangoNumMarcos}" "${maxRangoNumMarcos}"
	printf " Tamaño del proceso (direcciones):          | Mínimo: \e[1;33m%4d\e[0m | Máximo: \e[1;33m%4d\e[0m |\n"   "${minRangoNumDirecciones}" "${maxRangoNumDirecciones}"
	printf " Valor de direcciones a ejecutar:           | Mínimo: \e[1;33m%4d\e[0m | Máximo: \e[1;33m%4d\e[0m |\n"   "${minRangoValorDireccion}" "${maxRangoValorDireccion}"
}

###################################################################################################################################

# Muestra por pantalla una tabla con los rangos extraídos del fichero 'DatosRangosAleatorioTotal.txt' junto a los parámetros generados.
function imprimeVarAleatorioTotal(){
	
	local _c1="${_verd}${_b}"	# Color 1 para los rangos que salen del fichero.
	local _c2="${_azul}${_b}"	# Color 2 para los rangos generados aleatoriamente.

	{
	printf "\n\n$_c1%s$_c2%s$_r" "                                                  RANGOS FICHERO" "    RANGOS CALCULADOS"
	printf "\n%s"				" ┌────────────────────────────────────────────╥─────────┬─────────╥─────────┬─────────╥─────────┐"
	printf "\n%s"				" │                                            ║   Min   │   Max   ║   Min   │   Max   ║  TOTAL  │"
	printf "\n%s"				" ├────────────────────────────────────────────╫─────────┼─────────╫─────────┼─────────╫─────────┤"
	printf "\n │ Número de marcos de página en la memoria   ║ $_c1%7d$_r │ $_c1%7d$_r ║ $_c2%7d$_r │ $_c2%7d$_r ║ %7d │"   "${minRangoMemoriaAleTotal}" 	"${maxRangoMemoriaAleTotal}" 	"${minRangoMemoria}"	"${maxRangoMemoria}"	"${marcosMem}"
	printf "\n │ Número de direcciones por marco de página  ║ $_c1%7d$_r │ $_c1%7d$_r ║ $_c2%7d$_r │ $_c2%7d$_r ║ %7d │"   "${minRangoTamPaginaAleTotal}" 	"${maxRangoTamPaginaAleTotal}" 	"${minRangoTamPagina}"	"${maxRangoTamPagina}"	"${tamPag}"
	printf "\n │ Memoria del sistema                        ║         │         ║         │         ║ %7d │"	"${tamMem}"
	printf "\n │ Número de procesos                         ║ $_c1%7d$_r │ $_c1%7d$_r ║ $_c2%7d$_r │ $_c2%7d$_r ║ %7d │"   		"${minRangoNumProcesosAleTotal}" "${maxRangoNumProcesosAleTotal}" "${minRangoNumProcesos}"	"${maxRangoNumProcesos}" "${numeroProcesos}"
	printf "\n │ Tiempo de llegada                          ║ $_c1%7d$_r │ $_c1%7d$_r ║ $_c2%7d$_r │ $_c2%7d$_r ╟─────────┘"   	"${minRangoTLlegadaAleTotal}" 	"${maxRangoTLlegadaAleTotal}" 	"${minRangoTLlegada}"		"${maxRangoTLlegada}"
	printf "\n │ Número de marcos asociados a cada proceso  ║ $_c1%7d$_r │ $_c1%7d$_r ║ $_c2%7d$_r │ $_c2%7d$_r ║"	"${minRangoNumMarcosAleTotal}"	"${maxRangoNumMarcosAleTotal}"	"${minRangoNumMarcos}"	"${maxRangoNumMarcos}"
	printf "\n │ Tamaño del proceso (nº direcciones)        ║ $_c1%7d$_r │ $_c1%7d$_r ║ $_c2%7d$_r │ $_c2%7d$_r ║"	"${minRangoNumDireccionesAleTotal}"	"${maxRangoNumDireccionesAleTotal}" "${minRangoNumDirecciones}"	"${maxRangoNumDirecciones}"	
	printf "\n │ Valor de direcciones a ejecutar            ║ $_c1%7d$_r │ $_c1%7d$_r ║ $_c2%7d$_r │ $_c2%7d$_r ║"	"${minRangoValorDireccionAleTotal}" "${maxRangoValorDireccionAleTotal}" "${minRangoValorDireccion}"	"${maxRangoValorDireccion}"
	printf "\n%s\n"				" └────────────────────────────────────────────╨─────────┴─────────╨─────────┴─────────╜"
	} | tee -a $informeColor

	{
	printf "\n\n%s%s" "                                                  RANGOS FICHERO" "    RANGOS CALCULADOS"
	printf "\n%s"				" ┌────────────────────────────────────────────╥─────────┬─────────╥─────────┬─────────╥─────────┐"
	printf "\n%s"				" │                                            ║   Min   │   Max   ║   Min   │   Max   ║  TOTAL  │"
	printf "\n%s"				" ├────────────────────────────────────────────╫─────────┼─────────╫─────────┼─────────╫─────────┤"
	printf "\n │ Número de marcos de página en la memoria   ║ %7d │ %7d ║ %7d │ %7d ║ %7d │"   "${minRangoMemoriaAleTotal}" 	"${maxRangoMemoriaAleTotal}" 	"${minRangoMemoria}"	"${maxRangoMemoria}"	"${marcosMem}"
	printf "\n │ Número de direcciones por marco de página  ║ %7d │ %7d ║ %7d │ %7d ║ %7d │"   "${minRangoTamPaginaAleTotal}" 	"${maxRangoTamPaginaAleTotal}" 	"${minRangoTamPagina}"	"${maxRangoTamPagina}"	"${tamPag}"
	printf "\n │ Memoria del sistema                        ║         │         ║         │         ║ %7d │"	"${tamMem}"
	printf "\n │ Número de procesos                         ║ %7d │ %7d ║ %7d │ %7d ║ %7d │"   		"${minRangoNumProcesosAleTotal}" "${maxRangoNumProcesosAleTotal}" "${minRangoNumProcesos}"	"${maxRangoNumProcesos}" "${numeroProcesos}"
	printf "\n │ Tiempo de llegada                          ║ %7d │ %7d ║ %7d │ %7d ╟─────────┘"   	"${minRangoTLlegadaAleTotal}" 	"${maxRangoTLlegadaAleTotal}" 	"${minRangoTLlegada}"		"${maxRangoTLlegada}"
	printf "\n │ Número de marcos asociados a cada proceso  ║ %7d │ %7d ║ %7d │ %7d ║"	"${minRangoNumMarcosAleTotal}"	"${maxRangoNumMarcosAleTotal}"	"${minRangoNumMarcos}"	"${maxRangoNumMarcos}"
	printf "\n │ Tamaño del proceso (nº direcciones)        ║ %7d │ %7d ║ %7d │ %7d ║"	"${minRangoNumDireccionesAleTotal}"	"${maxRangoNumDireccionesAleTotal}" "${minRangoNumDirecciones}"	"${maxRangoNumDirecciones}"	
	printf "\n │ Valor de direcciones a ejecutar            ║ %7d │ %7d ║ %7d │ %7d ║"	"${minRangoValorDireccionAleTotal}" "${maxRangoValorDireccionAleTotal}" "${minRangoValorDireccion}"	"${maxRangoValorDireccion}"
	printf "\n%s\n"				" └────────────────────────────────────────────╨─────────┴─────────╨─────────┴─────────╜"
	} >> $informe
}

###################################################################################################################################

# Imprime por pantalla un resumen de los procesos y sus parámetros A MEDIDA QUE SON INTRODUCIDOS manualmente por el usuario.
function imprimeProcesos(){
	
	local maxpaginas=0
	ordenacion
	asignaColores
	imprimeHuecosInformes 1 0
	echo -e " Memoria del Sistema:  \e[1;33m$tamMem\e[0m" | tee -a $informeColor
	echo -e " Tamaño  de   página:  \e[1;33m$tamPag\e[0m" | tee -a $informeColor
	echo -e " Número  de   marcos:  \e[1;33m$marcosMem\e[0m" | tee -a $informeColor
	echo " Memoria del Sistema:  $tamMem" >> $informe
	echo " Tamaño   de  página:  $tamPag" >> $informe
	echo " Número   de  marcos:  $marcosMem" >> $informe
	echo -e " Ref Tll Tej nMar Dirección-Página" | tee -a $informeColor
	echo -e " Ref Tll Tej nMar Dirección-Página" >> $informe
	
	#|Pro|TLl|TEj|nMar|T.M.E|Dir.-Pag.
	# ... ... ... .... ..... ............................
	#  3   3   3    4    5
	for (( improcesos = 1; improcesos <= $p; improcesos++ )); do
		ord=${ordenados[$improcesos]}
		if [[ ord -lt 10 ]]; then
			printf "\e[1;32m\e[0m \e[1;3${colorines[$ord]}mP0$ord %3u %3u %4u \e[0m"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
			printf " P0$ord|%3u|%3u|%4u|"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" >> $informe
		else
			printf "\e[1;32m\e[0m \e[1;3${colorines[$ord]}mP$ord %3u %3u %4u \e[0m"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}"| tee -a $informeColor
			printf " P$ord|%3u|%3u|%4u|"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}"  >> $informe
		fi
		counter=0;
		maxpaginas=${maxPags[$ord]} 

		for (( impaginillas = 0; impaginillas <  maxpaginas ; impaginillas++ )); do
			echo -n -e "\e[3${colorines[$ord]}m${direcciones[$ord,$impaginillas]}-\e[1m${paginas[$ord,$impaginillas]}\e[0m " | tee -a $informeColor
			echo -n "${direcciones[$ord,$impaginillas]}-${paginas[$ord,$impaginillas]} " >> $informe
		done
		echo ""	 | tee -a $informeColor
		echo "" >> $informe
		maxpaginas=0;
	done
	imprimeHuecosInformes 1 1
}

###################################################################################################################################

# Imprime por pantalla un resumen de TODOS los procesos y sus parámetros. Se debe mostrar antes de la ejecución del algoritmo.
#	TO DO -> fusionar con la de arriba si son iguales, si no nada.
function imprimeProcesosFinal(){

	local maxpaginas=0
	ordenacion
	asignaColores
	printf "\n$_mora%s$_r"							" ╔══════════════════════════════════╗" | tee -a $informeColor
	printf "\n$_mora%s$_r$_b%s$_r$_mora%s$_r"		" ║       "       "TABLA FINAL DE DATOS" "       ║" | tee -a $informeColor
	printf "\n$_mora%s$_r\n"							" ╚══════════════════════════════════╝" | tee -a $informeColor
	echo -e " Algoritmo planificación: $alg" | tee -a $informeColor
	echo -e " Algoritmo reemplazo: $algReemplazo" | tee -a $informeColor
	echo -e " Memoria del Sistema: $tamMem" | tee -a $informeColor
	echo -e " Tamaño  de   página: $tamPag" | tee -a $informeColor
	echo -e " Número  de   marcos: $marcosMem" | tee -a $informeColor
	printf "\n%s"		" ╔══════════════════════════════════╗" >> $informe
	printf "\n%s"		" ║       TABLA FINAL DE DATOS       ║" >> $informe
	printf "\n%s\n"		" ╚══════════════════════════════════╝" >> $informe
	echo -e " Algoritmo planificación: $alg" >> $informe
	echo -e " Algoritmo reemplazo: $algReemplazo" >> $informe
	echo " Memoria del Sistema:  $tamMem" >> $informe
	echo " Tamaño  de   página:  $tamPag" >> $informe
	echo " Número  de   marcos:  $marcosMem" >> $informe
	printf "\n Ref Tll Tej nMar Dirección-Página\n" | tee -a $informeColor
	printf "\n Ref Tll Tej nMar Dirección-Página\n" >> $informe
	
	for (( improcesos = 1; improcesos <= $nProc; improcesos++ )); do
		ord=${ordenados[$improcesos]}
		if [[ ord -lt 10 ]]; then
			printf " \e[1;3${colorines[$ord]}mP0$ord %3u %3u %4u \e[0m"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
			printf " P0$ord|%3u|%3u|%4u|"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" >> $informe
		else
			printf " \e[1;3${colorines[$ord]}mP$ord %3u %3u %4u \e[0m"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
			printf " P$ord|%3u|%3u|%4u|"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" >> $informe
		fi
		counter=0;
		maxpaginas=${maxPags[$ord]}

		for (( impaginillas = 0; impaginillas <  maxpaginas ; impaginillas++ )); do
			echo -n -e "\e[3${colorines[$ord]}m${direcciones[$ord,$impaginillas]}-\e[1m${paginas[$ord,$impaginillas]}\e[0m " | tee -a $informeColor
			echo -n "${direcciones[$ord,$impaginillas]}-${paginas[$ord,$impaginillas]} " >> $informe
		done
		echo "" | tee -a $informeColor
		echo "" >> $informe
		maxpaginas=0;
	done
	
	printf "\n\n Pulse INTRO para continuar ↲ "
	read
	imprimeHuecosInformes 2 0
}



###########################
#        AUXILIARES       #
###########################

# Establece el orden de colores para los procesos.
function asignaColores(){
	
	local color=0;
	for (( counter = 1; counter <= $p; counter++ )); do
		color=$(($counter%6))
		color=$(($color+1))
		colorines[$counter]=$color
	done
}

###################################################################################################################################

# Borra la pantalla y llama a la función 'imprimeProcesos'.
function clearImprime() {
	clear
	imprimeProcesos
}

###################################################################################################################################

# Borra la pantalla e imprime la cabecera principal.
function clearYCabecera() {
	clear
	cabecera
}

###################################################################################################################################

# Ordena los procesos según su tiempo de llegada.
function ordenacion() {
	local count=1 			# Índice del proceso en el vector 'ordenados'.
	local acabado=0   		# Indica cuándo se ha acabado de ordenar los procesos.
	local numProceso=0		# Número del proceso que está siendo evaluado.
	t=0						# Instante de tiempo.
	while [[ $acabado -eq 0 ]]; do
		for (( numProceso=1; numProceso<=$p; numProceso++ )); do
			if [[ ${tLlegada[$numProceso]} -eq $t ]]; then		# Si el tiempo de llegada del proceso es igual al instante de tiempo evaluado...
				ordenados[$count]=$numProceso					# El número del proceso se mete al vector 'ordenados' en la posición correspondiente.
				# Se crean las referencias para los procesos.
				if [[ $numProceso -gt 9 ]];then 
					Ref[$numProceso]="P$numProceso"					
					else
					Ref[$numProceso]="P0$numProceso"
				fi
				((count++))										# Se incrementa el índice para que el próximo proceso esté en la posición siguiente.
			fi  
		done
		# Si el número de elementos en el vector 'ordenados' coincide con el número de procesos, se ha terminado de ordenar.
    	if [[ $count -gt $p ]]; then
        	acabado=1
    	else
        	((t++))			# Si no, se incrementa el instante de tiempo para ver si hay otro proceso cuyo tiempo de llegada coincida con él.
    	fi
	done
}

###################################################################################################################################

# Asigna al primer parámetro de la entrada un valor aleatorio entre el rango definido por el segundo y tercer parámetro de entrada, ambos incluidos.
function aleatorioEntre() {
    eval "${1}=$( shuf -i ${2}-${3} -n 1 )"
}

# Genera un valor aleatorio y los números pueden ser o no negativos (el anterior solo es para positivos).
#	TO DO-> fusionar con la de arriba si eso.
function aleatorioEntreConNegativos() {
    
	# eval "${1}=$((RANDOM % ($3 - $2 + 1) + $2))"

	if [[ $3 -lt $2 ]]; then	# Para el caso en el que ambos rangos (de aleatorio total) son negativos.
        eval "${1}=$2"			# Se habrá corregido el valor mínimo por lo que se pone este valor directamente.
    else
        eval "${1}=$((RANDOM % ($3 - $2 + 1) + $2))"
    fi
}

###################################################################################################################################

# Calcula el tamaño del espacio vacío más grande en memoria ('tamEspacioGrande') y guarda la cantidad de espacios vacíos consecutivos en memoria ('espaciosMemoria').
function calculaEspaciosMemoria() {
	tamEspacioGrande=0			# Tamaño del espacio vacío más grande en memoria.
	espaciosMemoria=()			# Array que contiene la cantidad de espacios vacíos consecutivos en memoria.
	local posicionInicial=0		# Indica el índice del primer marco vacío en memoria.
	
	for (( i=0; i < $marcosMem; i++)); do
		if [[ " ${!procesosMemoria[*]} " =~ " $i " ]]; then		# El marco '$i' está asignado a un proceso.
			if [[ ${espaciosMemoria[$posicionInicial]} -gt $tamEspacioGrande ]]; then
				tamEspacioGrande=${espaciosMemoria[$posicionInicial]}
			fi
			procesoActual=${procesosMemoria[$i]}
			i=$(($i+${nMarcos[$procesoActual]}-1))
			posicionInicial=$i+1
		else													# El marco '$i' está vacío.
			if [[ -z "${espaciosMemoria[$i]}" ]] && [[ $posicionInicial -eq $i ]]; then
				#posicionInicial=$i
				espaciosMemoria[$posicionInicial]=0 
			fi
			((espaciosMemoria[$posicionInicial]++))
		fi
	done

    if [[ ${espaciosMemoria[$posicionInicial]} -gt $tamEspacioGrande ]]; then
        tamEspacioGrande=${espaciosMemoria[$posicionInicial]}
    fi
}

###################################################################################################################################

# Calcula los anchos necesarios para diferentes volcados a pantalla (p.e si las páginas tienen más de un dígito, para que no se desordene todo).
function calculaAnchos(){

	((num= marcosMem-1 ))
	((anchoMarcosMax=${#num}+1))

	anchoUnidadBarras=3
	[[ $anchoMarcosMax -gt $anchoUnidadBarras ]] && anchoUnidadBarras=$anchoMarcosMax

	for pagina in "${paginas[@]}"; do
	[[ ${#pagina} -ge $anchoUnidadBarras ]] && anchoUnidadBarras=$((${#pagina}+1))
	done

	[[ ${#tSistema} -ge $anchoUnidadBarras ]] && anchoUnidadBarras=$((${#tSistema}+1))

	# diagramaMarcos
	for ((m=0;m<marcosMem;m++));do
		anchoResumenMarco[$m]=2
		# Si la referencia al marco (M--) ocupa más de 3 unidades, aumenta su valor.
		[[ $((${#m}+1)) -ge "3" ]] && anchoResumenMarco[$m]=$((${#m}+1))
		[[ ${#memoriaPagina[$m]} -gt ${anchoResumenMarco[$m]} ]] && anchoResumenMarco[$m]=${#memoriaPagina[$m]}
	done
}



###################################################################################
###########################                             ###########################
##################          ###        #####        ###          ##################
############       #############        ###        #############       ############
########      ###################        #        ###################      ########
#####     #####################                     #####################     #####
###     #######################  #################  #######################     ###
##    #########################  ##-------------##  #########################    ##
##    #########################  ##--ALGORITMO--##  #########################    ##
##    #########################  ##-------------##  #########################    ##
###     #######################  #################  #######################     ###
#####     #####################                     #####################     #####
########      ###################        #        ###################      ########
############       #############        ###        #############       ############
##################          ###        #####        ###          ##################
###########################                             ###########################
###################################################################################


#####################################
#        EJECUCIÓN PRINCIPAL        #
#####################################

# Función general que engloba la ejecución completa del algoritmo.
function ejecucion(){
	
	inicializaVariablesEjecucion
	seleccionTipoEjecucion		# El usuario elige el modo en que se ejecutará el algorimo (por eventos, automático o completo).

	##### Esto ya es el algoritmo #####
	ordenacion
	ejecutando="vacio"

	if [[ ${tLlegada[${ordenados[1]}]} -ne 0 ]]; then		# Si no va a llegar ningún proceso en el primer instante, se imprime vacío.
		mostrarPantalla=1
		volcadoAPantalla
	fi

	for (( tSistema=0; ; tSistema++ )); do

		mostrarPantalla=0
			 		
        if [ $ejecutando != "vacio" ]; then
			
			if [ ${tiempoRestante[$ejecutando]} -eq 0 ]; then
				mostrarPantalla=1
				gestionFinalizacionProceso
		    	ejecutandoAntiguo=$ejecutando
				ejecutando="vacio"
			else
				((tiempoRestante[$ejecutando]--))
			fi
        fi
		sumaTiempoEspera

		if [ $finalizados -ne $nProc ]; then

			meteEnMemoria
			actualizaCola
			if [ $ejecutando == "vacio" ]; then		# Si no hay un proceso ejecutándose, puede o no meterse otro proceso.
				if [ ${#cola[@]} -gt 0 ]; then
                
					ejecutando=${cola[0]}
                	tiempoProceso[$tSistema]=$ejecutando
					colocarTiemposPaginas
                	procesotInicio[$ejecutando]=$tSistema
                	mueveCola
					mostrarPantalla=1
					((tiempoRestante[$ejecutando]--))

					logEventos+=" Entra el proceso \e[1;3${colorines[$ejecutando]}m${Ref[$ejecutando]}\e[0m al procesador\n"
					logEventosBN+=" Entra el proceso ${Ref[$ejecutando]} al procesador\n"
            	fi
			else	# Se notifica qué proceso sigue ejecutándose (solo cuando se trata de un evento importante) -> si no, se imprimiría demasiadas veces.
				if [[ $mostrarPantalla -eq 1 ]]; then
					logEventos+=" Sigue ejecutándose el proceso \e[1;3${colorines[$ejecutando]}m${Ref[$ejecutando]}\e[0m\n"
					logEventosBN+=" Sigue ejecutándose el proceso ${Ref[$ejecutando]}\n"
				fi
			fi
            
		fi

		if [ $ejecutando != "vacio" ]; then
			((nPagAEjecutar[$ejecutando]++))

			# Se asignan las páginas que están en cada marco del proceso en ese instante.
			# El procesotiempomarco... es relativo. es decir, t=0 será el primer instante de ejec del proceso, no necesariamente
			# del algoritmo. al igual que m=0 será el primer marco del proceso (que puede ser M0, m1,m2...).
			tiem=$(( ${nPagAEjecutar[$ejecutando]} - 1 ))
			for (( i = 0; i < ${nMarcos[$ejecutando]}; i++ )); do
				index=$(( marcoInicial[$ejecutando] + i ))
				memoriaPagina[$index]=${procesoTiempoMarcoPagina[$ejecutando,$tiem,$i]}
				if [[ ${memoriaPagina[$index]} == -1 ]]; then	# Si es -1 significa que está vacío.
    				unset memoriaPagina[$index]
				fi
			done
		fi

        volcadoAPantalla

		if [ $finalizados -eq $nProc ]; then	# Si todos los procesos terminados son igual a los procesos introducidos.
			seAcaba=1
			break
        fi
	done

	# Se da valor a esperaSinLlegada.
	for (( counter=0; counter < $nProc; counter++ )); do
		let esperaSinLlegada[$counter]=esperaConLlegada[$counter]-tLlegada[$counter]
	done
	resumenFinal
}

###################################################################################################################################

# Inicializa por defecto las variables que se usarán a lo largo de la ejecución.
function inicializaVariablesEjecucion(){

	tSistema=0;						# Tiempo del sistema.
	ejecutando="vacio";				# El proceso a ejecutar en cada ronda.
	finalizados=0 					# Número de procesos que han terminado.
	seAcaba=0 						# Para finalizar la ejecución (0 = aún no ha terminado, 1 = ya se terminó).
    esperaConLlegada=(); 			# Tiempo de espera acumulado.
	esperaSinLlegada=();			# Tiempo de espera real.
	duracion=();					# Tiempo que ha estado el proceso desde entró hasta que terminó.
	enMemoria=();					# Ver si los procesos están en memoria.
	tiempoRestante=();				# Tiempo que le queda al proceso para terminar su ejecución.
	nPagAEjecutar=();				# Páginas que se han ejecutado de un proceso (se utiliza para subrayarlas en el resumen).

	for (( counter = 1; counter <= $nProc; counter++ )); do
		enMemoria[$counter]="fuera"								# "fuera" si no está, "dentro" si está, "salido" si ha terminado.
		let tiempoRestante[$counter]=${tEjec[$counter]}
		let nPagAEjecutar[$counter]=0
		marcoInicial[$counter]=0
		marcoFinal[$counter]=0
		esperaConLlegada[$counter]=$tSistema
	done

	counter=0;						# Inicializamos contador a cero.
	i=0;
	opcionEjec=0;
	mostrarPantalla=1				# El primer instante (T=0) se mostrará siempre.
}

###################################################################################################################################

# Acciones que se llevan a cabo cuando un proceso finaliza su ejecución.
function gestionFinalizacionProceso(){

	haFinalizadoProceso=1
    procesotFin[$ejecutando]=$tSistema
    let duracion[$ejecutando]=procesotFin[$ejecutando]-tLlegada[$ejecutando]
    nPagAEjecutar[$ejecutando]=${tEjec[$ejecutando]}	# ya debería ser el tiempo de ejecución cuando llegue aquí. borrar si eso
    tiempoRestante[$ejecutando]=0						# ya debería ser 0 cuando llega aquí así que borrar si eso
	((finalizados++))	
	# El valor "salido" quiere decir que el proceso ha estado en memoria y ha acabado, por lo que se ha sacado de allí.
    enMemoria[$ejecutando]="salido"			
    for marcoNuevo in ${!procesosMemoria[*]}; do
        if [[ ${procesosMemoria[$marcoNuevo]} -eq $ejecutando ]]; then
            unset procesosMemoria[$marcoNuevo]
        fi
    done
    
	for (( mar="${marcoInicial[$ejecutando]}"; mar<=${marcoFinal[$ejecutando]}; mar++ ));do
        unset "memoriaProceso[$mar]"
        unset "memoriaPagina[$mar]"
    done
	# unset "marcoInicial[$ejecutando]" # se puede hacer así para que en el resumen aparezca -
	# unset "marcoFinal[$ejecutando]"

    calculaEspaciosMemoria
	logEventos+=" El proceso \e[1;3${colorines[$ejecutando]}m${Ref[$ejecutando]}\e[0m ha finalizado y ha transcurrido este tiempo: ${tEjec[$ejecutando]}\n"
	logEventosBN+=" El proceso ${Ref[$ejecutando]} ha finalizado y ha transcurrido este tiempo: ${tEjec[$ejecutando]}\n"

	logEventos+=" \e[1;3${colorines[$ejecutando]}m${Ref[$ejecutando]}\e[0m ->   Tiempo Entrada: ${procesotInicio[$ejecutando]}   Tiempo Salida: $tSistema   Tiempo Restante: ${tiempoRestante[$ejecutando]}\n"
	logEventosBN+=" ${Ref[$ejecutando]} ->   Tiempo Entrada: ${procesotInicio[$ejecutando]}  Tiempo Salida: $tSistema   Tiempo Restante: ${tiempoRestante[$ejecutando]}\n"
}

###################################################################################################################################

# Muestra cada instante en el que ocurre un evento importante por pantalla y depende del tipo de ejecución (por eventos, automática, etc.).
function volcadoAPantalla(){

    if [[ $mostrarPantalla -eq 1 ]];then
		
		calculaAnchos

		case "${opcionEjec}" in
		1)	# Por eventos -> pulsando INTRO para el siguiente evento.
			clear
            imprimeCabeceraAlgoritmo
			imprimeLogEventos
            diagramaResumen
			if [[ $haFinalizadoProceso -eq 1 ]]; then
				muestraTablaFallosPag
			fi
			haFinalizadoProceso=0
			diagramaMarcos
			diagramaMemoria
            diagramaTiempo
			printf "\n"
			read -p " Pulse INTRO para continuar ↲ "
			echo
		;;
		2)	# Automática -> espera un determinado numero de segundos entre cada evento.
			clear
            imprimeCabeceraAlgoritmo
			imprimeLogEventos
            diagramaResumen
            if [[ $haFinalizadoProceso -eq 1 ]]; then
            	muestraTablaFallosPag
			fi
			haFinalizadoProceso=0
			diagramaMarcos
			diagramaMemoria
			diagramaTiempo
			sleep $segEsperaEventos	
		;;
		4) # Completa (solo resumen) -> se ejecuta sin mostrar por pantalla y solo imprime el resumen final.

			touch recipiente		# Crea un archivo 'recipiente' donde se redirigirá el output para que no se muestre por pantalla.
			{
    			imprimeCabeceraAlgoritmo
    			imprimeLogEventos
    			diagramaResumen
    			if [[ $haFinalizadoProceso -eq 1 ]]; then
        			muestraTablaFallosPag
    			fi
    			haFinalizadoProceso=0
				diagramaMarcos
				diagramaMemoria
    			diagramaTiempo
			} >> recipiente

			rm recipiente			# Se desecha el archivo 'recipiente'.
			local progreso
		 	((progreso=100*finalizados/nProc))
		 	printf " Ejecutando...(%d%%)\n" "$progreso"

			if [ $seAcaba -eq 1 ]; then
				resumenFinal
			fi
		;;
		esac
	fi

}



#####################################
#        VOLCADOS A PANTALLA        #
#####################################

# Imprime por pantalla el algoritmo utilizado, el instante de tiempo actual y las variables globales.
function imprimeCabeceraAlgoritmo(){
	
	imprimeHuecosInformes 2 0
	printf "%s\n" " FCFS/SJF - PAGINACIÓN - RELOJ - MEMORIA CONTINUA - NO REUBICABLE" | tee -a $informeColor
	printf "%s\n" " FCFS/SJF - PAGINACIÓN - RELOJ - MEMORIA CONTINUA - NO REUBICABLE" >> $informe
	printf "%s\t%s\n" " T=$tSistema" "Algoritmo utilizado = $alg    Memoria del sistema = $tamMem    Tamaño de página = $tamPag    Número de marcos = $marcosMem" | tee -a $informeColor
	printf "%s\t%s\n" " T=$tSistema" "Algoritmo utilizado = $alg    Memoria del sistema = $tamMem    Tamaño de página = $tamPag    Número de marcos = $marcosMem" >> $informe
}

###################################################################################################################################

# Muestra la tabla de procesos con sus respectivos parámetros (tiempos de llegada, ejecución, páginas, etc).
function diagramaResumen(){

	local _c
	printf " Ref Tll Tej nMar Tesp Tret Trej Mini Mfin Estado           Dirección-Página" | tee -a $informeColor
	printf " Ref Tll Tej nMar Tesp Tret Trej Mini Mfin Estado           Dirección-Página" >> $informe
	
	#	Pro|TLl|TEj|nMar|TEsp|TRet|TRes|Mini|Mfin|
	#	..3|..3|..3|...4|...4|...4|...4|...4|...4|
	
	for (( counter = 1; counter <= $nProc; counter++ )); do
		
		ord=${ordenados[$counter]}			# Guardamos el proceso en una variable por comodidad.
		_c="\e[1;3${colorines[$ord]}m"		# Color del proceso a imprimir.
		
		printf "\n$_c%s %3d %3d %4d" 	" ${Ref[$ord]}" "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
		printf "\n%s %3d %3d %4d" 		" ${Ref[$ord]}" "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" >> $informe

		# Tiempo de espera
		if [[ ${tLlegada[$ord]} -gt $tSistema ]]; then		# Si el tiempo de llegada del proceso es mayor que el del sistema es porque aún no ha entrado.
			printf "    -" | tee -a $informeColor
			printf "    -" >> $informe
		else
			esperaSinLlegada[$ord]=$((${esperaConLlegada[$ord]}-${tLlegada[$ord]}))
			printf " %4d" "${esperaSinLlegada[$ord]}" | tee -a $informeColor
			printf " %4d" "${esperaSinLlegada[$ord]}" >> $informe
		fi
			
		# Tiempo de retorno
		if [[ $tSistema -ge ${tLlegada[$ord]} ]]; then
			if [[ ${tiempoRestante[$ord]} -eq 0 ]] && [[ ${enMemoria[$ord]} == "salido" ]]; then
				retorn=${duracion[$ord]}
			else
				retorn=`expr $tSistema - ${tLlegada[$ord]}`
			fi
			tRetorno[$ord]=$retorn
			printf " %4d" "$retorn" | tee -a $informeColor
			printf " %4d" "$retorn" >> $informe
		else
			printf "    -" | tee -a $informeColor
			printf "    -" >> $informe
		fi
			
		# Tiempo restante de ejecución
		if [[ ${tLlegada[$ord]} -le $tSistema ]]; then

			if [[ $ord -eq $ejecutando ]]; then
				printf " %4d" "$((tiempoRestante[$ord] + 1))" | tee -a "$informeColor"
				printf " %4d" "$((tiempoRestante[$ord] + 1))" >> "$informe"
			else
				printf " %4d" "${tiempoRestante[$ord]}" | tee -a $informeColor
				printf " %4d" "${tiempoRestante[$ord]}" >> $informe
			fi
		else
			printf "    -" "${tiempoRestante[$ord]}" | tee -a $informeColor
			printf "    -" "${tiempoRestante[$ord]}" >> $informe
		fi

		# Marcos de memoria inicial y final
		if [[ " ${procesosMemoria[*]} " =~ " $ord " ]]; then
			# Se podría cambiar por las variables marcoInicial y marcoFinal. Pendiente de hacer.
			for marcoNuevo in ${!procesosMemoria[*]}; do
				if [[ ${procesosMemoria[$marcoNuevo]} -eq $ord ]]; then
					printf "\e[1;3${colorines[$ord]}m%5u" "$marcoNuevo" | tee -a $informeColor
					printf "%5u" "$(($marcoNuevo+${nMarcos[$ord]}-1))" | tee -a $informeColor
					printf "%5u" "$marcoNuevo" >> $informe
					printf "%5u" "$(($marcoNuevo+${nMarcos[$ord]}-1))" >> $informe
					break
				fi
			done
		else
			printf "%5s" "-" | tee -a $informeColor
            printf "%5s" "-" | tee -a $informeColor
			printf "%5s" "-" >> $informe
            printf "%5s" "-" >> $informe
		fi
		
		# Estado del proceso
		if [[ ${tLlegada[$ord]} -le $tSistema ]]; then
			if [[ ${tiempoRestante[$ord]} -eq 0 ]] && [[ ${enMemoria[$ord]} == "salido" ]]; then
				printf "%s"		" Finalizado      " | tee -a $informeColor
				printf "%s"		" Finalizado      " >> $informe
			else		
				if [[ ord -eq $ejecutando ]]; then			
					printf "%s"		" En ejecución    " | tee -a $informeColor
					printf "%s"		" En ejecución    " >> $informe
				else
					if [[ ${enMemoria[$ord]} != "dentro" ]]; then
						printf "%s"		" En espera       " | tee -a $informeColor
						printf "%s"		" En espera       " >> $informe
					else
						printf "%s"		" En memoria      " | tee -a $informeColor
						printf "%s"		" En memoria      " >> $informe
					fi
				fi
			fi
		else
			printf "%s"		" Fuera de sist.  " | tee -a $informeColor
			printf "%s"		" Fuera de sist.  " >> $informe
		fi

		# Estado----------10
		# Finalizado------6
		# En ejecución----4
		# En espera-------7
		# En memoria------6
		# Fuera de sist.--2
										
		# Direcciones y páginas del proceso
		local xx=0		# El número de dirección/página que toca imprimir.

		# Proceso que se está ejecutando en este instante.
		#	- Se subrayan las páginas que ya se hayan ejecutado (1er bucle for) y el resto se quedan igual (2ndo bucle for).
		if [[ ord -eq $ejecutando && ${tLlegada[$ord]} -le $tSistema && $finalizados -ne $nProc ]]; then

			for (( i = 0; i < ${nPagAEjecutar[$ord]} ; i++ )); do        
				printf " $_u$_c%s$_r" 	"${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" | tee -a $informeColor
                printf 					" ${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
                ((xx++))
            done
			for (( i = ${nPagAEjecutar[$ord]}; i < ${tEjec[$ord]} ; i++ )); do	
                printf " $_c%s$_r" 	"${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" | tee -a $informeColor
                printf 				" ${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
                ((xx++))
            done
		# Resto de procesos.
		#	- Los procesos que ya se hayan ejecutado tendrán todas las páginas subrayadas (entran solo en el 1er bucle for).
		#	- Los procesos que aún no se hayan ejecutado, se mostrarán de forma normal (entran solo en el 2ndo bucle for).
		else	
 			for (( i = 0; i <  ${nPagAEjecutar[$ord]} ; i++ )); do
				printf " $_u$_c%s$_r" 	"${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" | tee -a $informeColor
				printf 					" ${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
				((xx++))
			done
			for (( i = 0; i <  ${tiempoRestante[$ord]} ; i++ )); do
                printf " $_c%s$_r" 	"${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" | tee -a $informeColor
                printf 				" ${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
                ((xx++))
            done
		fi
	done
	imprimeHuecosInformes 1 1
	resumenTMedios
}

###################################################################################################################################

# Calcula y muestra por pantalla el tiempo medio de espera y el tiempo medio de retorno.
function resumenTMedios(){
    
	local tMedioEsp
    local tMedioRet
    local total=0
    local contador=0

    for tiem in ${esperaSinLlegada[*]}; do
        total=$(( total + $tiem ))
        (( contador++ ))
    done
    [ $contador -ne 0 ] \
        && tMedioEsp="$(bc -l <<<"scale=2;$total / $contador")"
    total=0
    contador=0

    for tiem in ${tRetorno[*]}; do
        total=$(( total + $tiem ))
        (( contador++ ))
    done
    [ $contador -ne 0 ] \
        && tMedioRet="$(bc -l <<<"scale=2;$total / $contador")"

    # Impresión por pantalla.
    if [[ -n "${tMedioEsp}" && "$tMedioEsp" != "0" ]]; then
		printf " %s: %-9s" "Tiempo Medio de Espera" "${tMedioEsp}" | tee -a $informeColor
		printf " %s: %-9s" "Tiempo Medio de Espera" "${tMedioEsp}" >> $informe
		mediaEspera="${tMedioEsp}"
    else
        printf " %s: %-9s" "Tiempo Medio de Espera" "0.0" | tee -a $informeColor
		printf " %s: %-9s" "Tiempo Medio de Espera" "0.0" >> $informe
		mediaEspera="0.0"
    fi

    if [[ -n "${tMedioRet}" && "$tMedioRet" != "0" ]]; then
        printf " %s: %s\n" "Tiempo Medio de Retorno" "${tMedioRet}" | tee -a $informeColor
		printf " %s: %s\n" "Tiempo Medio de Retorno" "${tMedioRet}" >> $informe
		mediaDurac="${tMedioRet}"
    else
        printf " %s: %s\n" "Tiempo Medio de Retorno" "0.0" | tee -a $informeColor
		printf " %s: %s\n" "Tiempo Medio de Retorno" "0.0" >> $informe
		mediaDurac="0.0"
    fi
}

###################################################################################################################################

# Muestra la tabla de fallos de paginación del proceso que acaba de terminar de ejecutarse.
function muestraTablaFallosPag(){

	local _f="\e[1;3${colorines[$ejecutandoAntiguo]}m"					# Color del proceso que se acaba de terminar de ejecutar.
	local _res="\e[4${colorines[$ejecutandoAntiguo]}m\e[38;5;255m"		# Para resaltar el marco que causó el fallo de página en cada instante.
	printf "\n Se han producido $_f$_b%d$_r fallos de página en la ejecución de $_f$_b%s$_r" "${fallos[$ejecutandoAntiguo]}" "${Ref[$ejecutandoAntiguo]}" | tee -a $informeColor
	printf "\n Se han producido %d fallos de página en la ejecución de %s" "${fallos[$ejecutandoAntiguo]}" "${Ref[$ejecutandoAntiguo]}" >> $informe
	
	filaPaginas=()
	filaFallos=()
	declare -A filaMarcos
	declare -A filaMarcos_BN
	local mayorMar=$((${#marcoFinal[$ejecutandoAntiguo]}+1))		# Valor mayor de los marcos de memoria.
	local mayorPag=0										# Valor mayor de las páginas del proceso.
	for (( i = 0; i < ${tEjec[$ejecutandoAntiguo]}; i++ )); do
		[ ${#paginas[$ejecutandoAntiguo,$i]} -gt $mayorPag ] && mayorPag=${#paginas[$ejecutandoAntiguo,$i]}
	done
	ind=0				# Número de línea en la que se escribe el marco (si no caben en la pantalla hay saltos de línea).
	columnas=0			# Ancho en caracteres de las columnas que se han ido mostrando en la pantalla.
	local anchuraCol=$(( mayorPag + 2 ))		# página+'-'+bit
	local anchuraReal=$(( anchuraCol + 4 ))		# Las columnas en realidad son '_|_<col>' + la del final tampoco se pinta
	local contenido

	# Primer instante, marcos vacíos. La manecilla apunta al primer marco.
	filaPaginas[$ind]="${filaPaginas[$ind]}$( printf "%s%-*s" " " "$mayorMar" )"
	filaFallos[$ind]="${filaFallos[$ind]}$( printf "%s%-*s" " " "$mayorMar" )"
	for ((m = 0; m < ${nMarcos[$ejecutandoAntiguo]}; m++)); do
       	
		let mar=m+marcoInicial[$ejecutandoAntiguo]
		if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,-1]} -eq $m ]]; then
			filaMarcos[$ind,$m]="$( printf "$_u%-*s$_r" "$mayorMar" "M$mar" )"
        else
            filaMarcos[$ind,$m]="$( printf "%-*s" "$mayorMar" "M$mar" )"
        fi

		filaMarcos_BN[$ind,$m]="$( printf "%-*s" "$mayorMar" "M$mar" )"
	done

	# Resto de instantes, se muestran los números de página y valores de bits de reloj.
	for ((r = 0; r < ${tEjec[$ejecutandoAntiguo]}; r++)); do				# Tiempo.
		
		if [[ $columnas -gt $(($anchura-$anchuraReal)) ]]; then		# Si no cabe, incrementar la línea.
	 	 	((ind++))
			columnas=0
			filaPaginas[$ind]="${filaPaginas[$ind]}$( printf "%s%-*s" " " "$mayorMar" )"
			filaFallos[$ind]="${filaFallos[$ind]}$( printf "%s%-*s" " " "$mayorMar" )"
			for ((m = 0; m < ${nMarcos[$ejecutandoAntiguo]}; m++)); do
				let mar=m+marcoInicial[$ejecutandoAntiguo]
				filaMarcos[$ind,$m]="$( printf "%-*s" "$mayorMar" "M$mar" )"

				filaMarcos_BN[$ind,$m]="$( printf "%-*s" "$mayorMar" "M$mar" )"
			done
		fi
		filaPaginas[$ind]="${filaPaginas[$ind]}$( printf "%s%*s%s" "  " "$anchuraCol" "${paginas[$ejecutandoAntiguo,$r]}" " " )"
		filaFallos[$ind]="${filaFallos[$ind]}$( printf "%s%*s%s" "  " "$anchuraCol" "${procesoTiempoMarcoFallo[$ejecutandoAntiguo,$r]}" " " )"

		for ((m = 0; m < ${nMarcos[$ejecutandoAntiguo]}; m++)); do			# Marcos.	

			filaMarcos[$ind,$m]="${filaMarcos[$ind,$m]}$( printf " │ " )"
			filaMarcos_BN[$ind,$m]="${filaMarcos_BN[$ind,$m]}$( printf " │ " )"
		  	# Si el marco está vacio
          	if [[ ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} -eq -1 ]] || [[ -z ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} ]] ; then
								
            	if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]; then		# Si le apunta la manecilla se subraya.
					filaMarcos[$ind,$m]="${filaMarcos[$ind,$m]}$( printf "$_u%*s$_r" "$anchuraCol" )"
            	else
					filaMarcos[$ind,$m]="${filaMarcos[$ind,$m]}$( printf "%*s" "$anchuraCol")"
            	fi

				filaMarcos_BN[$ind,$m]="${filaMarcos_BN[$ind,$m]}$( printf "%*s" "$anchuraCol")"
          	
			
			else
				contenido=$( printf "%s-%s" "${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]}" "${procesoTiempoMarcoBits[$ejecutandoAntiguo,$r,$m]}" )
				
				# (!!!) Hay tantos if por cambios de última hora. En realidad se podrá poner mucho más resumido.

				# Si es el marco que ocasionó un fallo de página se resalta.
				if [[ ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} -eq ${paginas[$ejecutandoAntiguo,$r]} ]] && [[ ${procesoTiempoMarcoFallo[$ejecutandoAntiguo,$r]} == "F" ]]; then
					
					# Caso MUY particular en que solo hay 1 marco para el proceso, entonces siempre le apunta la manecilla y es el único que provoca los fallos.
					# Es decir, el bit de reloj tiene que ser 1, tiene que resaltarse y subrayarse.
					if [[ "$algReemplazo" = "RELOJ" ]] && [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]] ; then

						contenido=$( printf "%s-1" "${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]}" )
						filaMarcos[$ind,$m]="${filaMarcos[$ind,$m]}$( printf "$_u$_res%*s$_r" "$anchuraCol" "$contenido" )"

					elif [ "$algReemplazo" = "RELOJ" ]; then		# Acordé con el profesor que si no le apuntaba la manecilla, su bit fuera 0.
						
						contenido=$( printf "%s-0" "${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]}" )
						filaMarcos[$ind,$m]="${filaMarcos[$ind,$m]}$( printf "$_res%*s$_r" "$anchuraCol" "$contenido" )"

					else
						filaMarcos[$ind,$m]="${filaMarcos[$ind,$m]}$( printf "$_res%*s$_r" "$anchuraCol" "$contenido" )"
					fi

				# Si estamos en segunda oportunidad y se acaba de actualizar su bit a 1, también se resalta.
				elif [[ "$algReemplazo" = "SEGOP" ]] && [[ ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} -eq ${paginas[$ejecutandoAntiguo,$r]} ]] && [[ ${procesoTiempoMarcoBits[$ejecutandoAntiguo,$r,$m]} -eq 1 ]]; then	

					if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]; then
						filaMarcos[$ind,$m]="${filaMarcos[$ind,$m]}$( printf "$_u$_res%*s$_r" "$anchuraCol" "$contenido" )"
					else
						filaMarcos[$ind,$m]="${filaMarcos[$ind,$m]}$( printf "$_res%*s$_r" "$anchuraCol" "$contenido" )"
					fi

				# Si le apunta la manecilla se subraya.
            	elif [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]; then		

					if [ "$algReemplazo" = "RELOJ" ]; then		# Acordé con el profesor que si le apuntaba la manecilla, su bit fuera 1.
						contenido=$( printf "%s-1" "${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]}" )
					fi

					filaMarcos[$ind,$m]="${filaMarcos[$ind,$m]}$( printf "$_u%*s$_r" "$anchuraCol" "$contenido" )"
				else

					if [ "$algReemplazo" = "RELOJ" ]; then
						contenido=$( printf "%s-0" "${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]}" )
					fi

					filaMarcos[$ind,$m]="${filaMarcos[$ind,$m]}$( printf "%*s" "$anchuraCol" "$contenido" )"

				fi
				filaMarcos_BN[$ind,$m]="${filaMarcos_BN[$ind,$m]}$( printf "%*s" "$anchuraCol" "$contenido" )"
          	fi
		done
		columnas=$((columnas + anchuraCol + 4))
    done
	
	for ((i = 0; i <= $ind; i++)); do
	 	printf "\n $_f$_b%s$_r" "${filaPaginas[$i]}" | tee -a $informeColor
		printf "\n %s" "${filaPaginas[$i]}" >> $informe

		for ((m = 0; m < ${nMarcos[$ejecutandoAntiguo]}; m++)); do
			printf "\n %s" "${filaMarcos[$i,$m]}" | tee -a $informeColor
			printf "\n %s" "${filaMarcos_BN[$i,$m]}" >> $informe
	 	done

		printf "\n $_f$_b%s$_r" "${filaFallos[$i]}" | tee -a $informeColor
		printf "\n %s" "${filaFallos[$i]}" >> $informe
		printf "\n"
	done
}

###################################################################################################################################

# Muestra un diagrama de los marcos de la memoria principal, qué procesos los ocupan, qué páginas se han ejecutado y sus contadores.
function diagramaMarcos(){
	
	declare -A marcosPag		# Tabla de marcos A COLOR de página de la memoria principal.
	declare -A marcosPag_BN		# Tabla de marcos en BLANCO y NEGRO de página de la memoria principal.
	local espacios=0			# Espacios que dejar antes de una página.
	local formato
	local aux=0
	local l=0
	local columnas=1
	marcosPag[$aux,0]=""	# Referencias a procesos.
	marcosPag[$aux,1]=""	# Referencias a marcos de la memoria.
	marcosPag[$aux,2]=""	# Páginas situadas en cada marco de memoria.
	marcosPag[$aux,3]=""	# Bits de reloj o segunda oportunidad.

	for (( marco=0 ; marco<marcosMem; marco++ )); do
		# Si hay un proceso 
		if [[ -n ${memoriaProceso[$marco]} ]] ;then
			p=${memoriaProceso[$marco]}		# Se mete el proceso en una variable.
		fi

		#Incrementar el contador en el numero de caracteres que ocupe lo que hay que escribir.
		((columnas=columnas+${anchoResumenMarco[$marco]}+1))

		if [[ $columnas -gt $anchura ]]; then	# Si no cabe lo que se quiere escribir, se incrementa la linea.
			((aux++))
			# Inicializar la nueva línea 
			columnas=1
			marcosPag[$aux,0]=""
			marcosPag[$aux,1]=""
			marcosPag[$aux,2]=""
			marcosPag[$aux,3]=""

			marcosPag_BN[$aux,0]=""
			marcosPag_BN[$aux,1]=""
			marcosPag_BN[$aux,2]=""
			marcosPag_BN[$aux,3]=""
		fi


		# Procesos
		l=0
		formato="\e[1;3${colorines[$p]}m"
		# Si el marco está ocupado y es el primer marco del proceso que lo ocupa
		if [[ -n ${memoriaProceso[$marco]} ]] && [[ $marco -eq "${marcoInicial[$p]}" ]]; then
			espacios=1
			[[ ${anchoResumenMarco[$marco]} -lt "3" ]] && espacios=0
			marcosPag[$aux,$l]="${marcosPag[$aux,$l]}$( printf "%b%-*s\e[0m%*s" "$formato" "${anchoResumenMarco[$marco]}" "${Ref[$p]}" "$espacios" "" )"

			marcosPag_BN[$aux,$l]="${marcosPag_BN[$aux,$l]}$( printf "%-*s%*s" "${anchoResumenMarco[$marco]}" "${Ref[$p]}" "$espacios" "" )"
		else
			marcosPag[$aux,$l]="${marcosPag[$aux,$l]}$( printf "%*s " "${anchoResumenMarco[$marco]}" "" )"

			marcosPag_BN[$aux,$l]="${marcosPag_BN[$aux,$l]}$( printf "%*s " "${anchoResumenMarco[$marco]}" "" )"
		fi


		if [[ $ejecutando != "vacio" ]]; then
			tiem=$(( ${nPagAEjecutar[$ejecutando]} - 1 ))
			#siguienteMarco=${procesoTiempoMarcoPuntero[$ejecutando,$tiem]}
			siguienteMarco=$(( ${marcoInicial[$ejecutando]} + ${procesoTiempoMarcoPuntero[$ejecutando,$tiem]} ))
		fi
		

	 	# Marcos
		l=1
		#imprimimos el nombre del marco en el color del proceso que lo ocupa.
		if [[ -z ${memoriaProceso[$marco]} ]]; then
			# Sin color, en negrita
			marcosPag[$aux,$l]=${marcosPag[$aux,$l]}"$( printf "\e[1m%-*s\e[0m " "${anchoResumenMarco[$marco]}" "M$marco" )"
			#si el marco es el marcosiguiente donde se van a meter páginas 
		elif [[ $marco = "$siguienteMarco" ]]; then	
			#color y subrayar
			marcosPag[$aux,$l]=${marcosPag[$aux,$l]}"$( printf "%b%-*s\e[0m " "\e[4m\e[1;3${colorines[$p]}m" "${anchoResumenMarco[$marco]}" "M$marco" )"
		else
			#color
			marcosPag[$aux,$l]=${marcosPag[$aux,$l]}"$( printf "%b%-*s\e[0m " "\e[1;3${colorines[$p]}m" "${anchoResumenMarco[$marco]}" "M$marco" )"
		fi
		marcosPag_BN[$aux,$l]=${marcosPag_BN[$aux,$l]}"$( printf "%-*s " "${anchoResumenMarco[$marco]}" "M$marco" )"

	 	# Páginas
		l=2
		espacios=0
		# Si la pagina ocupa menos que el marco, calcular cuántos espacios (lo que ocupa el Mmarco - lo que ocupa la página)
		[[ ${#memoriaPagina[$marco]} -lt ${anchoResumenMarco[$marco]} ]] && espacios=$(( ${anchoResumenMarco[$marco]}-${#memoriaPagina[$marco]} ))
		
		#imprimimos la página en el color del proceso que ocupa el marco.
		#si el marco es el marcosiguiente donde se van a meter páginas 

		if [[ $marco = "$siguienteMarco" ]];then
			#añadir subrayado al formato.
			formato="\e[4m\e[1;3${colorines[$p]}m"
		elif [[ -n ${memoriaProceso[$marco]} ]];then
			#formato normal(color del proceso) en negrita
			formato="\e[1;3${colorines[$p]}m"
		else
			formato="\e[0m"
		fi
		# Si no hay proceso
		if [[ -z ${memoriaProceso[$marco]} ]]; then
			marcosPag[$aux,$l]=${marcosPag[$aux,$l]}"$( printf "%*s%b%s\e[0m " "$espacios" "" "$formato" "" )"

			marcosPag_BN[$aux,$l]=${marcosPag_BN[$aux,$l]}"$( printf "%*s%s " "$espacios" "" "" )"
		# Si no hay página
		elif [[ -z ${memoriaPagina[$marco]} ]]; then
			espacios=$(( ${#marco} ))
			marcosPag[$aux,$l]=${marcosPag[$aux,$l]}"$( printf "%*s%b%s\e[0m " "$espacios" "" "$formato" "-" )"

			marcosPag_BN[$aux,$l]=${marcosPag_BN[$aux,$l]}"$( printf "%*s%s " "$espacios" "" "-" )"
		else
			marcosPag[$aux,$l]=${marcosPag[$aux,$l]}"$( printf "%*s%b%s\e[0m " "$espacios" "" "$formato" "${memoriaPagina[$marco]}" )"

			marcosPag_BN[$aux,$l]=${marcosPag_BN[$aux,$l]}"$( printf "%*s%s " "$espacios" "" "${memoriaPagina[$marco]}" )"
		fi


	 	# Coeficientes -> pendiente
		l=3
		# if [[ -n ${memoriaBitR[$marco]} ]]; then #procesotiempo...bits
		# 	marcosPag[$aux,$l]="${marcosPag[$aux,$l]}$( printf "%b%*s \e[0m" "\e[1;3${colorines[$p]}m" "${anchoResumenMarco[$marco]}" "${memoriaBitR[$marco]}" )"
		# 	elif [[ ${memoriaProceso[$marco]} -eq $enEjecucion ]] && [[ -n ${memoriaProceso[$marco]} ]];then
		# 	marcosPag[$aux,$l]="${marcosPag[$aux,$l]}$( printf "%*s " "${anchoResumenMarco[$marco]}" "-")"
		# 	else
		# 	marcosPag[$aux,$l]="${marcosPag[$aux,$l]}$( printf "%*s " "${anchoResumenMarco[$marco]}" "")"
		# fi


		# Si el marco es el último
		if [[ $marco = $((marcosMem-1)) ]];then
			# Se cuenta lo que va a ocupar M=...
			((columnas=columnas+4+${#marco}))

			if [[ $columnas -gt $anchura ]]; then	# Si no cabe lo que se quiere escribir, se incrementa la linea.
				((aux++))
				# Inicializar la nueva linea con 1 espacio para que guarde el margen
				columnas=1
				barraM[$aux,1]=" "
			fi
			marcosPag[$aux,1]=${marcosPag[$aux,1]}"$( printf "| M=%s" "$marcosMem" )"
			marcosPag_BN[$aux,1]=${marcosPag_BN[$aux,1]}"$( printf "| M=%s" "$marcosMem" )"
		fi
	
	done

	for (( i=0;i<=aux;i++ )); do
		for ((j=0 ; j<=l ; j++)); do
			printf "\n %s" "${marcosPag[$i,$j]}" | tee -a $informeColor
			printf "\n %s" "${marcosPag_BN[$i,$j]}" >> $informe
		done
	done
	echo ""
}

###################################################################################################################################

# Muestra el estado de la memoria en cada instante.
function diagramaMemoria(){ 
	
	local -A barraM			# Barra de memoria A COLOR.
	local -A barraM_BN		# Barra de memoria en BLANCO y NEGRO.
	local formato
	local anchoprebarra=3
	local anchopostbarra=$((5+${#marcosMem}))
	local p=0
	local aux=0
	local l=0
	local columnas=0
	
	for (( marco = 0; marco < marcosMem; marco++ ))
	do	
		#si hay un proceso 
		if [[ -n ${memoriaProceso[$marco]} ]] ;then
			#meter el proceso en una variable (por comodidad)
			p=${memoriaProceso[$marco]}
		fi

		#si es el primer marco
		if [[ $marco = 0 ]];then
			#Inicializar barras
			barraM[$aux,0]="$( printf "%*s|" "$anchoprebarra" " " )"
			barraM[$aux,1]="$( printf "%-*s|" "$anchoprebarra" "BM " )"
			barraM[$aux,2]="$( printf "%*s|" "$anchoprebarra" " " )"

			barraM_BN[$aux,0]="$( printf "%*s|" "$anchoprebarra" " " )"
			barraM_BN[$aux,1]="$( printf "%-*s|" "$anchoprebarra" "BM " )"
			barraM_BN[$aux,2]="$( printf "%*s|" "$anchoprebarra" " " )"
			((columnas=$anchoprebarra+2))
		fi

		#comprobar si va a caber algo más
		if [[ $columnas -gt $(($anchura-$anchoUnidadBarras)) ]]
		then	#si no cabe, incrementar la linea.
			((aux++))
			#inicializar la nueva linea con 5 espacios para que guarde el margen
			columnas=$((anchoprebarra+1))
			barraM[$aux,0]="    "
			barraM[$aux,1]="    "
			barraM[$aux,2]="    "

			barraM_BN[$aux,0]="    "
			barraM_BN[$aux,1]="    "
			barraM_BN[$aux,2]="    "
			flag=0
		fi

	 #Procesos
		l=0
		formato="\e[1;3${colorines[$p]}m"
		#si el marco está ocupado y es el primer marco del proceso que lo ocupa
		if [[ -n ${memoriaProceso[$marco]} ]] && [[ $marco -eq "${marcoInicial[$p]}" ]]; then
			barraM[$aux,$l]="${barraM[$aux,$l]}$( printf "%b%-*s\e[0m" "$formato" "$anchoUnidadBarras" "${Ref[$p]}" )"
			
			barraM_BN[$aux,$l]="${barraM_BN[$aux,$l]}$( printf "%-*s" "$anchoUnidadBarras" "${Ref[$p]}" )"

			else
			barraM[$aux,$l]="${barraM[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" " " )"

			barraM_BN[$aux,$l]="${barraM_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" " " )"
		fi

	 #Barra del medio
	 	l=1
		#si el marco esta vacío
		if [[ -z ${memoriaProceso[$marco]} ]] ;then
			formato="\e[47m\e[30m"
			else
			formato="\e[4${colorines[$p]}m\e[30m"
		fi
		#si la pagina está vacía
		if [[ -z ${memoriaPagina[$marco]} ]] ;then
			#poner el color de fondo y escribir un -
			barraM[$aux,$l]="${barraM[$aux,$l]}$( printf "%b%*s\e[0m" "$formato" "$anchoUnidadBarras" "-" )"

			barraM_BN[$aux,$l]="${barraM_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "-" )"
		else

			#poner el color y escribir la página que ocupa ese marco
			barraM[$aux,$l]="${barraM[$aux,$l]}$( printf "%b%*s\e[0m" "$formato" "$anchoUnidadBarras" "${memoriaPagina[$marco]}" )"

			barraM_BN[$aux,$l]="${barraM_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "${memoriaPagina[$marco]}" )"
		fi

	 #Barra de marcos
	 	l=2;
		#si el marco es el primer marco del proceso que lo ocupa o es el primero vacío despues de un proceso
		if [[ $marco -eq "${marcoInicial[$p]}" ]] || [[ $marco = 0 ]] || { [[ $flag = 0 ]] && [[ -z ${memoriaProceso[$marco]} ]] ;}; then
			barraM[$aux,$l]="${barraM[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "$marco" )"

			barraM_BN[$aux,$l]="${barraM_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "$marco" )"
			else 
			barraM[$aux,$l]="${barraM[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" " " )"

			barraM_BN[$aux,$l]="${barraM_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" " " )"
		fi
		flag=1
		[[ -n ${memoriaProceso[$marco]} ]] && [[ $marco -eq "${marcoFinal[$p]}" ]] && flag=0

	#Incrementar el contador en el número de caracteres que ocupe lo que se haya escrito.
		((columnas=$columnas+$anchoUnidadBarras))

		#si el marco es el último
		if [[ $marco = $((marcosMem-1)) ]];then

			#comprobar si cabe lo que quiero escribir
			if [[ $columnas -gt $(($anchura-$anchopostbarra)) ]]
			then	#si no cabe, incrementar la linea.
				((aux++))
				#inicializar la nueva linea con 5 espacios para que guarde el margen
				columnas=$((anchoprebarra+1))
				barraM[$aux,0]="    "
				barraM[$aux,1]="    "
				barraM[$aux,2]="    "

				barraM_BN[$aux,0]="    "
				barraM_BN[$aux,1]="    "
				barraM_BN[$aux,2]="    "
			fi
		
			barraM[$aux,0]="${barraM[$aux,0]}$( printf "|" )"
			barraM[$aux,1]="${barraM[$aux,1]}$( printf "|%s" " M=$marcosMem" )"
			barraM[$aux,2]="${barraM[$aux,2]}$( printf "|" )"

			barraM_BN[$aux,0]="${barraM_BN[$aux,0]}$( printf "|" )"
			barraM_BN[$aux,1]="${barraM_BN[$aux,1]}$( printf "|%s" " M=$marcosMem" )"
			barraM_BN[$aux,2]="${barraM_BN[$aux,2]}$( printf "|" )"
			((columnas=$columnas+$anchopostbarra))
			break
		fi
	done

	for (( i=0;i<=aux;i++ )); do	
		for ((j=0 ; j<=l ; j++)); do
			printf "\n %s" "${barraM[$i,$j]}" | tee -a $informeColor

			printf "\n %s" "${barraM_BN[$i,$j]}" >> $informe
		done
	done
	imprimeHuecosInformes 1 1
}

###################################################################################################################################

# Muestra una representación de los procesos que se han ido ejecutando a lo largo del tiempo y sus páginas.
function diagramaTiempo(){
	
	local -A barraT			# Línea de tiempo A COLOR.
	local -A barraT_BN		# Línea de tiempo en BLANCO y NEGRO.
	local formato
	local anchoprebarra=3
	local anchopostbarra=$((5+${#marcosMem}))
	local p=0				# Proceso en el marco actual.
	local aux=0				# Para saber cuántas veces se hace salto de línea si la barra no cabe en la pantalla.
	local l=0				# Línea/fila en la que estamos. Hay 3 -> procesos, páginas y tiempos.
	local columnas=0		# Contador de las columnas (caracteres en el terminal) que se han ocupado.

	for (( tiempo = 0; tiempo <=$tSistema; tiempo++ ))
	do
		# Si hay un proceso.
		if [[ -n ${tiempoProceso[$tiempo]} ]] ;then
			p=${tiempoProceso[$tiempo]}		# Se mete el proceso en una variable.
		fi

		# Si es el primer instante T=0.
		if [[ $tiempo = 0 ]];then
			#Inicializar barras
			barraT[$aux,0]="$( printf "%*s|" "$anchoprebarra" " " )"
			barraT[$aux,1]="$( printf "%-*s|" "$anchoprebarra" "BT " )"
			barraT[$aux,2]="$( printf "%*s|" "$anchoprebarra" " " )"
			
			barraT_BN[$aux,0]="$( printf "%*s|" "$anchoprebarra" " " )"
			barraT_BN[$aux,1]="$( printf "%-*s|" "$anchoprebarra" "BT " )"
			barraT_BN[$aux,2]="$( printf "%*s|" "$anchoprebarra" " " )"
			
			((columnas=$anchoprebarra+2))
		fi

		# Comprobar si cabe otra unidad.
		if [[ $columnas -gt $(($anchura-$anchoUnidadBarras)) ]]; then	# Si no cabe, incrementar la línea.
			((aux++))
			# Inicializar la nueva línea con 5 espacios para que guarde el margen.
			columnas=$((anchoprebarra+2+$anchoUnidadBarras))
			barraT[$aux,0]="    "
			barraT[$aux,1]="    "
			barraT[$aux,2]="    "
		
			barraT_BN[$aux,0]="    "
			barraT_BN[$aux,1]="    "
			barraT_BN[$aux,2]="    "
		fi


	 	# REFERENCIAS PROCESOS
		l=0
		formato="\e[1;3${colorines[$p]}m"
		#si el en ese tiempo hay un proceso en ejecución y es el tiempo en el que ha iniciado la ejecución el proceso
		if [[ -n ${tiempoProceso[$tiempo]} ]] && [[ $tiempo -eq "${procesotInicio[$p]}" ]]; then
			barraT[$aux,$l]="${barraT[$aux,$l]}$( printf "%b%-*s\e[0m" "$formato" "$anchoUnidadBarras" "${Ref[$p]}" )"

			barraT_BN[$aux,$l]="${barraT_BN[$aux,$l]}$( printf "%-*s" "$anchoUnidadBarras" "${Ref[$p]}" )"

		else
			barraT[$aux,$l]="${barraT[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" " " )"

			barraT_BN[$aux,$l]="${barraT_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" " " )"
		fi

		# BARRA DEL MEDIO
	 	l=1
		# Si hay proceso y no es el tiempo actual.
		if [[ -n ${tiempoProceso[$tiempo]} ]] && [[ $tiempo -ne $tSistema ]];then
			#barra del color del proceso y letras neutras
			formato="\e[4${colorines[$p]}m\e[30m"
		elif [[ -n ${tiempoPagina[$tiempo]} ]] && [[ $tiempo -eq $tSistema ]];then
			#solo letras del color del proceso
			formato="\e[3${colorines[$p]}m"
		else
			#barra blanca
			formato="\e[47m\e[30m"
		fi

		# Si la pagina está vacía
		if [[ -z ${tiempoPagina[$tiempo]} ]] ;then

			if [[ $tSistema -eq 0 ]];then
				formato="\e[0m"		# Que en el primer instante t=0, si no hay proceso sea transparente.
			else
				formato="\e[47m\e[30m"
			fi

			barraT[$aux,$l]="${barraT[$aux,$l]}$( printf "%b%*s\e[0m" "$formato" "$anchoUnidadBarras" " " )"

			barraT_BN[$aux,$l]="${barraT_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "-" )"
		else
			# Escribir la página que ocupa ese marco.
			if [[ $tiempo -eq $tSistema ]];then
				formato="\e[3${colorines[$p]}m"
			else
				formato="\e[4${colorines[$p]}m\e[30m"		# Que en el primer instante de ejecución del proceso sea transparente.
			fi
			
			barraT[$aux,$l]="${barraT[$aux,$l]}$( printf "%b%*s\e[0m" "$formato" "$anchoUnidadBarras" "${tiempoPagina[$tiempo]}" )"

			barraT_BN[$aux,$l]="${barraT_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "${tiempoPagina[$tiempo]}" )"
		fi
	 
	 
	 	# TIEMPOS
	 	l=2
		# Si el tiempo es el de entrada del proceso o es el primero vacío despues de un proceso.
		if [[ $tiempo -eq "${procesotInicio[$p]}" ]] || [[ $tiempo = 0 ]] || [[ $tiempo -eq ${procesotFin[$p]} ]]; then
			barraT[$aux,$l]="${barraT[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "$tiempo" )"

			barraT_BN[$aux,$l]="${barraT_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "$tiempo" )"
		else 
			barraT[$aux,$l]="${barraT[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" " " )"

			barraT_BN[$aux,$l]="${barraT_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" " " )"
		fi
		

	 	# Incrementar el contador en el número de caracteres que ocupe lo que hay que escribir.
		((columnas=$columnas+$anchoUnidadBarras))

		# Si el marco es el último.
		if [[ $tiempo -eq $tSistema ]];then
		
			if [[ $columnas -gt $(($anchura-$anchopostbarra)) ]]; then	# Si no cabe, incrementar la línea.
				((aux++))
				# Inicializar la nueva línea con espacios para que guarde el margen.
				columnas=$((anchoprebarra+1))
				barraT[$aux,0]="    "
				barraT[$aux,1]="    "
				barraT[$aux,2]="    "

				barraT_BN[$aux,0]="    "
				barraT_BN[$aux,1]="    "
				barraT_BN[$aux,2]="    "
			fi

			barraT[$aux,0]="${barraT[$aux,0]}$( printf "|" )"
			barraT[$aux,1]="${barraT[$aux,1]}$( printf "|%s" " T=$tSistema" )"
			barraT[$aux,2]="${barraT[$aux,2]}$( printf "|" )"

			barraT_BN[$aux,0]="${barraT_BN[$aux,0]}$( printf "|" )"
			barraT_BN[$aux,1]="${barraT_BN[$aux,1]}$( printf "|%s" " T=$tSistema" )"
			barraT_BN[$aux,2]="${barraT_BN[$aux,2]}$( printf "|" )"

			# Contar tambien lo que va a ocupar M=...
			((columnas=$columnas+$anchopostbarra))
			break
		fi
	done

	for (( i=0;i<=$aux;i++ ));do	
		for ((j=0 ; j<=l ; j++)); do
			printf "\n %s" "${barraT[$i,$j]}" | tee -a $informeColor
			printf "\n %s" "${barraT_BN[$i,$j]}" >> $informe
		done
	done
	imprimeHuecosInformes 1 1
}

###################################################################################################################################

# Muestra un resumen de los tiempos de ejecución y fallos de página de cada proceso al finalizar el algoritmo.
function resumenFinal(){

	clear
	imprimeHuecosInformes 3 0
	local _c="\e[1;3${colorines[$counter]}m"	# Color del proceso a imprimir.

	printf "\n$_cyan%s$_r"							" ╔═══════════════════════════╗" | tee -a $informeColor
	printf "\n$_cyan%s$_r$_b%s$_r$_cyan%s$_r"		" ║       "       "RESUMEN FINAL" "       ║" | tee -a $informeColor
	printf "\n$_cyan%s$_r"							" ╚═══════════════════════════╝" | tee -a $informeColor
	printf "\n%s"		" ╔═══════════════════════════╗" >> $informe
	printf "\n%s"		" ║       RESUMEN FINAL       ║" >> $informe
	printf "\n%s"		" ╚═══════════════════════════╝" >> $informe
	imprimeHuecosInformes 1 1

	printf "\n T.Espera    -> Tiempo que el proceso no ha estado ejecutándose en la CPU desde que entra en memoria hasta que sale" | tee -a $informeColor
	printf "\n Inicio/Fin  -> Tiempo de llegada al gestor de memoria del proceso y tiempo de salida del proceso" | tee -a $informeColor
	printf "\n T.Retorno   -> Tiempo total de ejecución del proceso, incluyendo tiempos de espera, desde la señal de entrada hasta la salida" | tee -a $informeColor
	printf "\n Fallos Pág. -> Número de fallos de página que han ocurrido en la ejecución de cada proceso" | tee -a $informeColor
	
	printf "\n T.Espera      -> Tiempo que el proceso no ha estado ejecutándose en la CPU desde que entra en memoria hasta que sale" >> $informe
	printf "\n Inicio/Fin    -> Tiempo de llegada al gestor de memoria del proceso y tiempo de salida del proceso" >> $informe
	printf "\n T.Retorno     -> Tiempo total de ejecución del proceso, incluyendo tiempos de espera, desde la señal de entrada hasta la salida" >> $informe
	printf "\n Fallos Pág.   -> Número de fallos de página que han ocurrido en la ejecución de cada proceso" >> $informe
	imprimeHuecosInformes 3 1
	
	#		  Proc.   T.Espera   Inicio/Fin   T.Retorno   Fallos Pág.
	#		  ----5----------11------8/------7--------9------------14

	printf " Proc.   T.Espera   Inicio/Fin   T.Retorno   Fallos Pág." | tee -a $informeColor
	printf " Proc.   T.Espera   Inicio/Fin   T.Retorno   Fallos Pág." >> $informe
	for (( counter=1; counter <= $nProc; counter++ )); do
		_c="\e[1;3${colorines[$counter]}m"
		printf "\n $_c$_b%-5s%11d%8d/%-7d%9d%14d$_r" 	"${Ref[$counter]}" "${esperaSinLlegada[$counter]}" "${tLlegada[$counter]}" "${procesotFin[$counter]}" "${duracion[$counter]}" "${fallos[$counter]}"  | tee -a $informeColor
		printf "\n %-5s%11d%8d/%-7d%9d%14d" 			"${Ref[$counter]}" "${esperaSinLlegada[$counter]}" "${tLlegada[$counter]}" "${procesotFin[$counter]}" "${duracion[$counter]}" "${fallos[$counter]}"  >> $informe
	done

	imprimeHuecosInformes 2 1
	printf "\n %s" "Tiempo total transcurrido en ejecutar todos los procesos: $tSistema" | tee -a $informeColor
	printf "\n %s" "Media tiempo espera de todos los procesos:  $mediaEspera" | tee -a $informeColor
	printf "\n %s" "Media tiempo retorno de todos los procesos: $mediaDurac" | tee -a $informeColor
	printf "\n %s" "Tiempo total transcurrido en ejecutar todos los procesos: $tSistema" >> $informe
	printf "\n %s" "Media tiempo espera de todos los procesos: $mediaEspera" >> $informe
	printf "\n %s" "Media tiempo retorno de todos los procesos: $mediaDurac" >> $informe

	printf "\n\n"
	read -p " Fin del algoritmo. Pulse INTRO para continuar ↲ "
}



####################################
#        GESTIÓN DE LA COLA        #
####################################

# Se encarga de meter a memoria los procesos que han llegado al sistema y caben en la memoria.
function meteEnMemoria() {

    colaMemoria=()		# Cola de entrada en memoria. Procesos que han llegado al sistema y se quiere ver si caben en memoria principal.

    for ((posic = 1; posic <= $nProc; posic++)); do
        
		counter=${ordenados[$posic]}
        if [[ ${tiempoRestante[$counter]} -ne 0 ]] && [[ $tSistema -ge ${tLlegada[$counter]} ]] && [[ ${enMemoria[$counter]} == "fuera" ]]; then

			#aquí se puede añadir al log el 'llega el proceso...'. luego si entra en memoria ya se notificará. si no, se queda en espera.

            if [[ ${nMarcos[$counter]} -le $tamEspacioGrande ]]; then
                        
				enMemoria[$counter]="dentro"
                colaMemoria+=("$counter")
                        
                for marcoNuevo in ${!espaciosMemoria[*]}; do
                    if [[ ${espaciosMemoria[$marcoNuevo]} -ge ${nMarcos[$counter]} ]]; then
                        procesosMemoria[$marcoNuevo]=$counter
                        marcoIntroducido=$marcoNuevo

						# Si no lo ponía con comillas daba errores.
						marcoInicial["$counter"]=$marcoIntroducido
    					marcoFinal["$counter"]=$((marcoIntroducido + ${nMarcos[$counter]} - 1))
                    fi
                done
                calculaEspaciosMemoria		# Cada vez que se meta un proceso a memoria, recalculamos sus espacios para ver si caben más.
                
				# Añadir proceso a la memoria, desde el marco inicial al marco final, incluido este último.
				for ((marc=${marcoInicial[$counter]} ; marc<=${marcoFinal[$counter]};marc++)); do
					memoriaProceso[$marc]="$counter"
				done

				logEventos+=" Entra el proceso \e[1;3${colorines[$counter]}m${Ref[$counter]}\e[0m a memoria a partir del marco $marcoIntroducido\n"
				logEventosBN+=" Entra el proceso ${Ref[$counter]} a memoria a partir del marco $marcoIntroducido\n"

				mostrarPantalla=1
            else
                break	# Si no cabe el primer proceso no se evalúa el resto (cola FIFO de entrada a memoria).
            fi
        fi
    done
}

###################################################################################################################################

# Mete los procesos que estaban en memoria en la cola de ejecución y la reordena si fuese necesario (si el algoritmo es SJF).
function actualizaCola(){

	for ((n=0; n<${#colaMemoria[@]}; n++)); do
		if [ "${colaMemoria[$n]}" != "v" ]; then
            cola+=("${colaMemoria[n]}")
			colaMemoria[$n]="v"				# Lo marca como 'vacío', también se podría eliminar si eso.
		fi
	done

	# Si el algoritmo es SJF, es necesario reordenar la cola por tiempos de ejecución.
	if [ "$alg" = "SJF" ] && [ ${#cola[@]} -gt 0 ]; then
		reordenaColaSJF
	fi
}

###################################################################################################################################

# Mueve todos los elementos de la cola de ejecución un lugar a la izquierda. Se llama después de haber puesto un nuevo proceso
# a ejecutar, puesto que se quiere eliminar éste de la cola.
function mueveCola(){

	for ((i=0; i<${#cola[@]}-1; i++)); do
        j=$((i+1))
        cola[$i]=${cola[$j]}
    done
    unset 'cola[${#cola[@]}-1]'
}

###################################################################################################################################

# Reordena la cola de ejecución en función de los tiempos de ejecución de los procesos que se encuentran en ella.
#	- La cola se reordena de menor a mayor tiempo de ejecución. Así, el siguiente proceso a ejecutar será el primero de la cola.
function reordenaColaSJF(){
	
	local colaAux=()
  	local maxTEjec=$(encontrarMax "${tEjec[@]}")  # Encuentra el máximo de los tiempos de ejecución.

  	for ((tiem = 0; tiem <= maxTEjec; tiem++)); do
    	for proceso in "${cola[@]}"; do
      		if ((tEjec[$proceso] == tiem)); then
        		colaAux+=($proceso)  # Añade elemento al vector auxiliar.
      		fi
    	done
  	done
  	cola=("${colaAux[@]}")  		# Copia el contenido de 'colaAux' en 'cola'.
}

###################################################################################################################################

# Función auxiliar para imprimir la cola de procesos. No se utiliza en la ejecución (de momento), pero es útil para depurar.
function imprimeCola(){
	
	printf "\n\n\t%s" "COLA MEMORIA:  "
	for elemento in "${colaMemoria[@]}"; do
        printf "P%s - " "$elemento"
    done
	printf "\n\n"

	printf "\nt%s" "COLA EJECUCION:  "
	for elemento in "${cola[@]}"; do
        printf "P%s - " "$elemento"
    done
	printf "\n\n"
}



#################################
#        ALGORITMO RELOJ        #
#################################

# Función principal del algoritmo de Reloj. Calcula las páginas del proceso, establece las variables necesarias e itera sobre cada
# página para ejecutar el algoritmo.
function reloj(){

	# Calcular páginas del proceso
	paginasProceso=()
	for (( i = 0; i < ${tEjec[$1]}; i++ )); do
		paginasProceso[$i]=${paginas[$1,$i]}
	done

	numeroMarcos=${nMarcos[$1]}
	tiempoEjecucion=${#paginasProceso[*]}
	puntero=0
	numeroFallos=0
	bitReloj=()
	memoriaMarcos=()

	for ((i = 0; i < $numeroMarcos; i++))
	do
	 	memoriaMarcos[$i]=-1
	 	bitReloj[$i]=0
	done
	procesoTiempoMarcoPuntero[$1,-1]=$puntero

	for ((i = 0; i < $tiempoEjecucion; i++))
	do
	 	paginaActual=${paginasProceso[$i]}
	 	encontrarYactualizarReloj
	 	if [[ $? -eq 1 ]]
	 	then
	 		reemplazarYactualizarReloj
			procesoTiempoMarcoFallo[$1,$i]="F"
	 		((numeroFallos++))
	 	else
			procesoTiempoMarcoFallo[$1,$i]=" "
		fi
	 	# Guardar el orden de memoria
	 	procesoTiempoMarcoPuntero[$1,$i]=$puntero

	 	for (( j = 0; j < ${numeroMarcos}; j++ )); do
	 		procesoTiempoMarcoPagina[$1,$i,$j]=${memoriaMarcos[$j]}
	 	done

	 	for (( j = 0; j < ${numeroMarcos}; j++ )); do
            procesoTiempoMarcoBits[$1,$i,$j]=${bitReloj[$j]}
       done
	done
	# Se guardan los fallos de paginación del proceso.
	fallos[$1]=$numeroFallos		
}

###################################################################################################################################

# Función auxiliar. Devuelve '0' si la página buscada se encuentra en memoria y '1' si no está en memoria.
function encontrarYactualizarReloj(){

	for ((j = 0; j < $numeroMarcos; j++)); do
		if [[ ${memoriaMarcos[$j]} -eq $paginaActual ]]
		then
			return 0
		fi
	done
	return 1
}

###################################################################################################################################

# Función auxiliar. Lleva a cabo el proceso de reemplazo de una página si fuera necesario.
#	- Si el bit de la página apuntada por el puntero es 1, se cambia a 0 y se avanza el puntero al siguiente marco.
#	- Si el bit es 0, se actualiza esa página con la nueva página '$paginaActual', se establece el bit a 1 y se avanza el puntero.
function reemplazarYactualizarReloj(){

	while :; do
		if [[ ${bitReloj[$puntero]} -eq 0 ]]; then
	 		memoriaMarcos[$puntero]=$paginaActual
	 		bitReloj[$puntero]=1
	 		puntero=$((($puntero+1)%$numeroMarcos))
	 		return 1
	 	fi
	 	bitReloj[$puntero]=0
	 	puntero=$((($puntero+1)%$numeroMarcos))
	done
}



###############################################
#        ALGORITMO SEGUNDA OPORTUNIDAD        #
###############################################

# Función principal del algoritmo de Segunda Oportunidad. Calcula las páginas del proceso, establece las variables necesarias e itera
# sobre cada página para ejecutar el algoritmo.
function segundaOportunidad(){

	# Calcular paginas del proceso
	pagsegop=()
	for (( i = 0; i < ${tEjec[$1]}; i++ )); do
		pagsegop[$i]=${paginas[$1,$i]}
	done

	numeroMarcos=${nMarcos[$1]}
	tiempoEjecucion=${#pagsegop[*]}
	puntero=0
	numeroFallos=0
	bitSegOp=()
	memoriaMarcos=()

	for ((i = 0; i < $numeroMarcos; i++)); do
		memoriaMarcos[$i]=-1
		bitSegOp[$i]=0
	done
	procesoTiempoMarcoPuntero[$1,-1]=$puntero

	for ((i = 0; i < $tiempoEjecucion; i++)); do
		#procesoTiempoMarcoPuntero[$1,$i]=$puntero
		paginaActual=${pagsegop[$i]}
		encontrarYactualizarSegOp 
		if [[ $? -eq 1 ]]; then
			reemplazarYactualizarSegOp
			procesoTiempoMarcoFallo[$1,$i]="F"
	 		((numeroFallos++))
	 	else
			procesoTiempoMarcoFallo[$1,$i]=" "
		fi

		# Guardar el orden de memoria
		procesoTiempoMarcoPuntero[$1,$i]=$puntero
		for (( j = 0; j < ${numeroMarcos}; j++ )); do
			procesoTiempoMarcoPagina[$1,$i,$j]=${memoriaMarcos[$j]}
		done

	    for (( j = 0; j < ${numeroMarcos}; j++ )); do
            procesoTiempoMarcoBits[$1,$i,$j]=${bitSegOp[$j]}
        done
	done
	fallos[$1]=$numeroFallos
}

###################################################################################################################################

# Función auxiliar. Devuelve '0' si la página buscada se encuentra en memoria (y actualiza el bit de segOp) y '1' si no está en memoria.
function encontrarYactualizarSegOp(){
	for ((j = 0; j < $numeroMarcos; j++)); do
		if [[ ${memoriaMarcos[$j]} -eq $paginaActual ]]; then
			bitSegOp[$j]=1
			return 0
		fi
	done
	return 1
}

###################################################################################################################################

# Función auxiliar. Lleva a cabo el proceso de reemplazo de una página si fuera necesario.
function reemplazarYactualizarSegOp(){
	while :; do
		if [[ ${bitSegOp[$puntero]} -eq 0 ]]; then
			memoriaMarcos[$puntero]=$paginaActual
			puntero=$((($puntero+1)%$numeroMarcos))
			return 1
		fi
		bitSegOp[$puntero]=0
		puntero=$((($puntero+1)%$numeroMarcos))
	done
}



###########################
#        AUXILIARES       #
###########################

# Los eventos son almacenados en una variable y se concatenan a medida que suceden más eventos. Finalmente se muestran por pantalla
# y se vacía la variable para recoger los eventos de otro instante.
function imprimeLogEventos(){
	echo -ne "$logEventos" | tee -a $informeColor
	echo -ne "$logEventosBN" >> $informe
	# Se borran para rellenarlos en el siguiente instante.
	logEventos=""
	logEventosBN=""
}

###################################################################################################################################

# Imprime huecos en blanco en los informes que actúan como separador. El número de huecos depende del valor pasado como primer parámetro.
#	- Si el segundo parámetro es 0, solo se envían a los informes, si no, se visualizan por pantalla.
function imprimeHuecosInformes(){
	
	local huecos=""
	if [[ $1 =~ ^[0-9]+$ ]]; then
    	for ((i=0; i<$1; i++)); do
    		huecos+="\n"
    	done
  	else
    	huecos="\n"
  	fi
	if [[ $2 -eq 0 ]]; then
		printf "$huecos" >> $informe
		printf "$huecos" >> $informeColor
	else
		printf "$huecos" >> $informe
		printf "$huecos" | tee -a $informeColor
	fi
}

###################################################################################################################################

# Auxiliar para la linea de tiempo. Saber qué página se ejecuta en cada instante.
function colocarTiemposPaginas(){

	local tiemp=$tSistema

	for (( i = 0; i < ${tEjec[$ejecutando]}; i++ )); do
		tiempoPagina[$tiemp]=${paginas[$ejecutando,$i]}
		((tiemp++))
	done
}

###################################################################################################################################

# Encuentra el valor máximo de un vector (númerico, de momento) que se le pase como parámetro.
function encontrarMax() {
  	
	local vector=("$@")  			# Se recibe el vector como parámetro.
  	local maximo=0
  	
  	for num in "${vector[@]}"; do	# Itera sobre el vector para encontrar el máximo.
    	if ((num > maximo)); then
      		maximo=$num
    	fi
  	done
	echo $maximo
}

###################################################################################################################################

# Suma a los procesos que no están ejecutándose (y no han terminado) el tiempo de espera.
function sumaTiempoEspera(){
	for (( counter=1; counter <= $nProc; counter++ )); do	
		if [[ $counter -ne $ejecutando && $tSistema -ne 0 ]] && [[ ${tiempoRestante[$counter]} -ne 0 ]]; then
			let esperaConLlegada[$counter]=esperaConLlegada[$counter]+1
		fi
	done
}



###################################################################################
##         ###########                                       ###########         ##
##  #####   #########   #####    ##  #########  ##    #####   #########   #####  ##
##   #####             #####     ##  ##     ##  ##     #####             #####   ##
##    #####################   #  ##  #########  ##  #   #####################    ##
##     ###################   ##                     ##   ###################     ##
##  #   #####       #####   ###########################   #####       #####   #  ##
######   #####     #####   ###-----------------------###   #####     #####   ######
#######   #############   ####--FUNCIONES-DEL-FINAL--####   #############   #######
######   #####     #####   ###-----------------------###   #####     #####   ######
##  #   #####       #####   ###########################   #####       #####   #  ##
##     ###################   ##                     ##   ###################     ##
##    #####################   #  ####  #####  ####  #   #####################    ##
##   #####             #####     ####  ## ##  ####     #####             #####   ##
##  #####   #########   #####    ####  #####  ####    #####   #########   #####  ##
##         ###########                                       ###########         ##
###################################################################################


# Fin del programa. Pregunta al usuario si quiere abrir el informe. En caso afirmativo, pregunta con qué editor.
function final(){

	clearYCabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" Por último, ¿desea abrir el informe? (s/n)"
	read abrirInforme
	
	until [[ $abrirInforme =~ ^[nNsS]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Entrada no válida." " Escriba 's' (SI) o 'n' (NO): "
		read abrirInforme
	done

	if [[ $abrirInforme =~ ^[sS]$ ]]; then
		clearYCabecera
		printf "\n\n%s\n" " ¿Con qué editor desea abrir el informe?"
		echo -e "  \e[1;32mnano\e[0m, \e[1;33mvi\e[0m, \e[1;34m[vim]\e[0m, \e[1;35mgvim\e[0m, \e[1;32mgedit\e[0m, \e[1;33matom\e[0m, \e[1;34mcat (a color)\e[0m, \e[1;31motro\e[0m"
		echo " Después de visualizarlo vuelva a esta ventana y terminará el algoritmo"
		read -p " Seleccione: " editor
		until [[ $editor = "nano" ||  $editor = "vi" ||  $editor = "vim" ||  $editor = "gvim" ||  $editor = "gedit" ||  $editor = "atom" || $editor = "cat" || $editor = "otro" || $editor = "" ]]
			do
				echo -e " \e[1;31mPor favor escoja uno de la lista\e[0m"
				echo " ¿Con qué editor desea abrir el informe?"
				echo "  \e[1;32mnano\e[0m, \e[1;33mvi\e[0m, \e[1;34m[vim]\e[0m, \e[1;35mgvim\e[0m, \e[1;32mgedit\e[0m, \e[1;33matom\e[0m, \e[1;34mcat (a color)\e[0m, \e[1;31motro\e[0m"
				read -p " Seleccione: " editor
		done
				
		case $editor in
			"nano")
				nano $informe;;
			"vi")
				vi $informe;;
			"vim")
				vim $informe;;
			"gvim")
				gvim $informe;;
			"gedit")
				gedit $informe;;
			"atom")
				atom $informe;;
			"cat")
				clear
				cat $informeColor;;
			"otro")
				echo 
				echo -e " \e[1;31mAl escoger otro editor tenga en cuenta que debe tenerlo instalado, si no dará error\e[0m"
				read -p " Introduzca: " editor
				echo
				$editor $nombre".txt";;
			*)	# Opción por defecto.
				vim $informe;;
		esac

		printf "\n\n Presione cualquier tecla para continuar"
		read -n 1
	else
		printf "\n >> No se abrirá el informe."
		sleep 1
	fi
	cabeceraFinal
}

###################################################################################################################################

# Guarda los datos que se han introducido en el fichero que el usuario desee.
#	- Si se pasa un '0' como parámetro, hace la pregunta de dónde se quieren guardar los datos y almacena el nombre de ese fichero.
#	- Si se pasa cualquier otro parámetro, guarda los datos en el fichero que se haya indicado anteriormente.
function guardaDatos(){
	
	if [ $1 -eq 0 ]; then
		clearYCabecera
		printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los DATOS?"
		printf "\t$_verd%s$_r%s\n"			"[1]" " -> En el fichero de datos por defecto (DatosDefault.txt)"
		printf "\t$_verd%s$_r%s\n\n"		"[2]" " -> En otro fichero de datos"
		read -p " Seleccione opción: " elegirGuardarDatos
    	until [[ $elegirGuardarDatos =~ ^[1-2]$ ]]; do
        	echo ""
        	echo -e -n "\e[1;31mValor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
        	read elegirGuardarDatos
    	done

		clearYCabecera
		case $elegirGuardarDatos in
			1)	# Muestra la opción 1 seleccionada.
				printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los DATOS?"
				printf "\t$_sel%s%s$_r\n"			"[1]" " -> En el fichero de datos por defecto (DatosDefault.txt)"
				printf "\t$_verd%s$_r%s\n\n"		"[2]" " -> En otro fichero de datos"
				ficheroDatosOut="./datosScript/FDatos/DatosDefault.txt"
				sleep 0.3
				;;
			2)	# Muestra la opción 2 seleccionada.
				printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los DATOS?"
				printf "\t$_verd%s$_r%s\n"			"[1]" " -> En el fichero de datos por defecto (DatosDefault.txt)"
				printf "\t$_sel%s%s$_r\n\n"			"[2]" " -> En otro fichero de datos"
				sleep 0.3
				printf " >> Introduzca el nombre del fichero donde se guardarán los datos de la práctica (sin incluir '.txt'): "
				read nombreOtroFichero
				ficheroDatosOut="./datosScript/FDatos/${nombreOtroFichero}.txt"
				;;
		esac

	else
		echo "$tamMem" > $ficheroDatosOut
    	echo "$tamPag" >> $ficheroDatosOut

    	for (( i = 1; i <= $nProc; i++ )); do
        	echo -n "${tLlegada[$i]};" >> $ficheroDatosOut
        	echo -n "${nMarcos[$i]};;" >> $ficheroDatosOut
        	for (( n = 0; n < ${maxPags[$i]}; n++ )); do
            	echo -n "${direcciones[$i,$n]};" >> $ficheroDatosOut
        	done
        	echo "" >> $ficheroDatosOut
    	done

		cp "${ficheroDatosOut}" "./datosScript/FLast/DatosLast.txt"
        
		nombreFichElegido=$(basename -a "$ficheroDatosOut")
		printf "\n Elija un \e[1;32mfichero\e[0m: \e[1;32m%s\e[0m" "$nombreFichElegido" >> $informeColor
		printf "\n Elija un fichero: %s" "$nombreFichElegido" >> $informe	
	fi
	clear
}

###################################################################################################################################

# Guarda los rangos que se han introducido en el fichero que el usuario desee.
#	- Si se pasa un '0' como parámetro, hace la pregunta de dónde se quieren guardar los rangos y almacena el nombre de ese fichero.
#	- Si se pasa cualquier otro parámetro, guarda los rangos en el fichero que se haya indicado anteriormente.
function guardaRangos(){
	
	local nombreFicheroRangos="DatosRangosDefault"

	if [ $1 -eq 0 ]; then
		clearYCabecera
		printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los RANGOS?"
		printf "\t$_verd%s$_r%s\n"			"[1]" " -> En el fichero de rangos por defecto (DatosRangosDefault.txt)"
		printf "\t$_verd%s$_r%s\n\n"		"[2]" " -> En otro fichero de rangos"
		read -p " Seleccione opción: " elegirGuardarRangos
    	until [[ $elegirGuardarRangos =~ ^[1-2]$ ]]; do
        	echo ""
        	echo -e -n "\e[1;31mValor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
        	read elegirGuardarRangos
   		done

		clearYCabecera
		case $elegirGuardarRangos in
			1)	# Muestra la opción 1 seleccionada.
				printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los RANGOS?"
				printf "\t$_sel%s%s$_r\n"			"[1]" " -> En el fichero de rangos por defecto (DatosRangosDefault.txt)"
				printf "\t$_verd%s$_r%s\n\n"		"[2]" " -> En otro fichero de rangos"
				sleep 0.3
				ficheroRangosOut="./datosScript/FRangos/${nombreFicheroRangos}.txt"
				clear
				;;
			2)	# Muestra la opción 2 seleccionada.
				printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los RANGOS?"
				printf "\t$_verd%s$_r%s\n"		"[1]" " -> En el fichero de rangos por defecto (DatosRangosDefault.txt)"
				printf "\t$_sel%s%s$_r\n\n"		"[2]" " -> En otro fichero de rangos"
				sleep 0.3
				printf " >> Introduzca el nombre del fichero donde se guardarán los rangos de la práctica (sin incluir '.txt'): "
				read nombreOtroFicheroRangos
				ficheroRangosOut="./datosScript/FRangos/${nombreOtroFicheroRangos}.txt"
				clear
				;;
		esac

	else
		echo -n "$minRangoMemoria" > $ficheroRangosOut
		echo -n "-" >> $ficheroRangosOut
		echo "$maxRangoMemoria" >> $ficheroRangosOut
		echo -n "$minRangoTamPagina" >> $ficheroRangosOut
		echo -n "-" >> $ficheroRangosOut
		echo "$maxRangoTamPagina" >> $ficheroRangosOut
		echo -n "$minRangoNumProcesos" >> $ficheroRangosOut
		echo -n "-" >> $ficheroRangosOut
		echo "$maxRangoNumProcesos" >> $ficheroRangosOut
		echo -n "$minRangoTLlegada" >> $ficheroRangosOut
		echo -n "-" >> $ficheroRangosOut
		echo "$maxRangoTLlegada" >> $ficheroRangosOut
		echo -n "$minRangoNumMarcos" >> $ficheroRangosOut
		echo -n "-" >> $ficheroRangosOut
		echo "$maxRangoNumMarcos" >> $ficheroRangosOut
		echo -n "$minRangoNumDirecciones" >> $ficheroRangosOut
		echo -n "-" >> $ficheroRangosOut
		echo "$maxRangoNumDirecciones" >> $ficheroRangosOut
		echo -n "$minRangoValorDireccion" >> $ficheroRangosOut
		echo -n "-" >> $ficheroRangosOut
		echo "$maxRangoValorDireccion" >> $ficheroRangosOut

		cp "${ficheroRangosOut}" "./datosScript/FLast/DatosRangosLast.txt"
	fi
}



###################################################################################
######       ##########       ##########       ##########       ##########       ##
###       ##########       ##########       ##########       ##########       #####
##     ##########       ##########       ##########       ##########       ########
##  ##########       ##########       ##########       ##########       ###########
###########       ##########       ##########       ##########       ##########  ##
########       ##########      ############################       ##########     ##
#####       ##########       ####-----------------######       ##########       ###
##       ##########       #######--LAS-CABECERAS--###       ##########       ######
#####       ##########       ####-----------------######       ##########       ###
########       ##########      ############################       ##########     ##
###########       ##########       ##########       ##########       ##########  ##
##  ##########       ##########       ##########       ##########       ###########
##     ##########       ##########       ##########       ##########       ########
###       ##########       ##########       ##########       ##########       #####
######       ##########       ##########       ##########       ##########       ##
###################################################################################

# Imprime la cabecera que se muestra al ejecutar el script.
function cabeceraInicio(){
	
	local CAB='\e[48;5;192m'	# Color utilizado.

	clear
	echo
	printf " $CAB%s$_r\n"                   "                                                                              "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                           PRÁCTICA DE CONTROL                            " "  "
	printf " $CAB%s$_r$_b%s$CAB%s$_r\n"     "  " "     FCFS/SJF - Paginación - Reloj - Memoria Continua - No Reubicable     " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  "
	printf " $CAB%s$_r$_i%s$CAB%s$_r\n"     "  " "                        Autora:  Amanda Pérez Olmos                       " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "        Anteriores: César Rodríguez Villagrá, Rodrigo Pérez Ubierna       " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                      Sistemas Operativos 2º Semestre                     " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                Grado en Ingeniería Informática (2022-2023)               " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                       Tutor: Jose Manuel Sáiz Diez                       " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  "
	printf " $CAB%s$_r\n"                   "                                                                              "
	echo
	read -p " Pulse INTRO para continuar ↲ "
	clear
}

###################################################################################################################################

# Muestra la cabecera principal del programa, indicando que es un algoritmo de gestión de memoria virtual.
function cabecera(){

	local CAB='\e[48;5;219m'				# Color de los bordes.
	local TEXT='\e[38;5;53m\e[48;5;225m'	# Color del interior (texto+fondo).

	echo
	printf " $CAB%s$_r\n"                   		"                                                             "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                                                         " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                                                         " "  "
	printf " $CAB%s$_r$TEXT$_b%s$CAB%s$_r\n"     	"  " "                        ALGORITMO                        " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                GESTIÓN DE MEMORIA VIRTUAL               " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                                                         " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"     		"  " "              FCFS/SJF - Paginación - Reloj              " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                                                         " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                                                         " "  "
	printf " $CAB%s$_r\n"                   		"                                                             "
	echo
}

###################################################################################################################################

# Cabecera del principio del informe.
function cabeceraInforme(){

	# Informe a COLOR
	local CAB='\e[48;5;192m'	# Color utilizado.

	echo > $informeColor
	printf " $CAB%s$_r\n"                   "                                                                              " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                           PRÁCTICA DE CONTROL                            " "  " >> $informeColor
	printf " $CAB%s$_r$_b%s$CAB%s$_r\n"     "  " "     FCFS/SJF - Paginación - Reloj - Memoria Continua - No Reubicable     " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r$_i%s$CAB%s$_r\n"     "  " "                        Autora:  Amanda Pérez Olmos                       " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "        Anteriores: César Rodríguez Villagrá, Rodrigo Pérez Ubierna       " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                      Sistemas Operativos 2º Semestre                     " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                Grado en Ingeniería Informática (2022-2023)               " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                       Tutor: Jose Manuel Saiz Diez                       " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r\n"                   "                                                                              " >> $informeColor
	echo >> $informeColor

	printf "\n\n" >> $informeColor 
    printf " %s\n"   			"╔════════════════════════════════════════════════════════════════════════════╗" >> $informeColor
    printf " %s\n"   			"║ INFORME DE LA PRÁCTICA                                 $(date '+%d/%b/%Y - %H:%M') ║" >> $informeColor  
    printf " %s\n\n"   			"╚════════════════════════════════════════════════════════════════════════════╝" >> $informeColor 

	# Informe en BLANCO y NEGRO
	echo > $informe
	printf " %s\n"            	"############################################################################" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                           PRÁCTICA DE CONTROL                            " "#" >> $informe
	printf " %s%s%s\n"     		"#" "     FCFS/SJF - Paginación - Reloj - Memoria Continua - No Reubicable     " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s%s%s\n"     		"#" "                        Autora:  Amanda Pérez Olmos                       " "#" >> $informe
	printf " %s%s%s\n"        	"#" "        Anteriores: César Rodríguez Villagrá, Rodrigo Pérez Ubierna       " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                      Sistemas Operativos 2º Semestre                     " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                Grado en Ingeniería Informática (2022-2023)               " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                       Tutor: Jose Manuel Saiz Diez                       " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s\n"              "############################################################################" >> $informe
	echo >> $informe

	printf "\n\n" >> $informe
    printf " %s\n"   			"############################################################################" >> $informe
    printf " %s\n"   			"# INFORME DE LA PRÁCTICA                               $(date '+%d/%b/%Y - %H:%M') #" >> $informe
    printf " %s\n\n"   			"############################################################################" >> $informe
}

###################################################################################################################################

# Cabecera que se muestra al finalizar la ejecución del script.
function cabeceraFinal(){
	
	clear
	local CAB='\e[48;5;219m'
	local TEXT='\e[38;5;53m\e[48;5;225m'
	# Por pantalla.
	echo
	printf " $CAB%s$_r\n"                   		"                                                             "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                                                         " "  "
	printf " $CAB%s$_r$TEXT$_b%s$CAB%s$_r\n"     	"  " "                        ALGORITMO                        " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                GESTIÓN DE MEMORIA VIRTUAL               " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                                                         " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"     		"  " "              FCFS/SJF - Paginación - Reloj              " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                                                         " "  "
	printf " $CAB%s$_r$TEXT$_b%s$CAB%s$_r\n"     	"  " "                      ---  FIN  ---                      " "  "
	printf " $CAB%s$_r$TEXT%s$CAB%s$_r\n"        	"  " "                                                         " "  "
	printf " $CAB%s$_r\n"                   		"                                                             "
	echo
	# Informe a color.
	printf "\n\n" >> $informeColor  
    printf " %s\n"   				"╔════════════════════════════════════════════════════════════════════════════╗" >> $informeColor  
    printf " %s\n"   				"║ INFORME DE LA PRÁCTICA                                                 FIN ║" >> $informeColor  
    printf " %s\n\n\n\n"   			"╚════════════════════════════════════════════════════════════════════════════╝" >> $informeColor 
	# Informe en blanco y negro.
	printf "\n\n" >> $informe  
    printf " %s\n"   				"############################################################################" >> $informe  
    printf " %s\n"   				"# INFORME DE LA PRÁCTICA                                               FIN #" >> $informe  
    printf " %s\n\n\n\n"   			"############################################################################" >> $informe	
}

###################################################################################################################################

# Indica al usuario que el tamaño recomendado para la visualización del programa es la pantalla completa.
function imprimeTamanyoRecomendado(){
	
	if [ $anchura -lt 79 ]; then
    	cabecera
		printf "\n%s"			" Para una correcta visualización del programa, se recomienda poner"
		printf "\n%s\n\n"		" el terminal en pantalla completa."
		printf 					" Pulse INTRO cuando haya ajustado el tamaño."
	else
		printf "\n\n\n%-s\n" 	"  ╔═════════════════════════════════════════════════════════════════════════╗"
		printf "%-s\n"			"  ║                                                                         ║"
		printf "%-s\n"  		"  ║    Para una correcta visualización del programa, se recomienda poner    ║"
		printf "%-s\n"  		"  ║    el terminal en pantalla completa.                                    ║"
		printf "%-s\n"  		"  ║                                                                         ║"
		printf "%-s\n"  		"  ║               Pulse INTRO cuando haya ajustado el tamaño.               ║"
		printf "%-s\n"  		"  ║                                                                         ║"
		printf "%-s\n"  		"  ╚═════════════════════════════════════════════════════════════════════════╝"
		printf "%-s\n"  		"                                   \ (•◡ •) /"
		printf "%-s\n"  		"                                    \      /" 
	fi
	read
}



###################################################################################
###################################             ###################################
##############################      ####   ####      ##############################
#########################      #########   #########      #########################
####################      ##############   ##############      ####################
###############      ###################   ###################      ###############
##########      ######################       ######################      ##########
#####      #########################           #########################      #####
#                                      #MAIN                                      #
#####      #########################           #########################      #####
##########      ######################       ######################      ##########
###############      ###################   ###################      ###############
####################      ##############   ##############      ####################
#########################      #########   #########      #########################
##############################      ####   ####      ##############################
###################################             ###################################
###################################################################################

function main(){
	cabeceraInicio
	imprimeTamanyoRecomendado
	menuInicio
	sed -i 's/\x0//g' ${informe}			# Limpia los caracteres NULL que se han impreso en el informe (ya no se imprimen pero por si acaso).
	sed -i 's/\x0//g' ${informeColor}		# Limpia los caracteres NULL que se han impreso en el informeColor.
}

### Ejecución programa ###
main