#!/bin/bash

###########################
#        VARIABLES        #
###########################
# Cada vez que se dice que una variable es utilizada en X función, quiere decir que se utiliza por primera vez en esa función.
# Luego puede utilizarse en más partes del programa.

	# PENDIENTES DE REORGANIZAR
	anchoUnidadBarras=3
	Ref=()
    logEventos=""
	logEventosBN=""
    #Globales generales
	anchura=`tput cols`;				#anchura de pantalla (columnas), 
	((anchura--))						# restamos uno para que no se pinten cosas en la última columna en las fucniones que  tienen en cuenta la anchura
	trap 'anchura=`tput cols`; ((anchura--))' WINCH 	##cada vez que reajustamos el ancho de la pantalla se ejecutan esos comandos
    # Variables para la linea temporal
    tiempoProceso=()          # Contien el proceso que está en ejecución en cada tiempo
    tiempoPagina=()           # Contiene la página que se ha ejecutado en cada tiempo
    # VARIABLES PARA LA PANTALLA DE RESUMEN
    procesotInicio=()          # Contiene el tiempo de inicio de cada proceso
    procesotFin=()             # COntiene el tiempo de fin de cada proceso

	# -------------------

	# Colores
		# Funcionamiento:
    		# \e[ o \033[ es la secuencia de escape
    		# Para indicar que lo que se quiere cambiar es el COLOR DEL TEXTO, después del escape se pone ' 38; '
    		# Para indicar que lo que se quiere cambiar es el COLOR DEL FONDO, después del escape se pone ' 48; '
    		# Después de decir si era el color del texto o fondo, para indicar que se va a usar la paleta de 256 colores se pone ' 5; '
    		# Finalmente, se escribe el color deseado de esa paleta seguido por m (p.e: '140m ')
		#
	declare -r _sel='\e[46m'		# Fondo cyan para la selección de opciones. BORRAR O MODIFICAR
	declare -r _rojo='\e[38;5;160m'
	declare -r _nrja='\e[38;5;208m'
	declare -r _amll='\e[38;5;220m'
	declare -r _verd='\e[38;5;112m'
	declare -r _cyan='\e[38;5;117m'
	declare -r _azul='\e[38;5;38m'
	declare -r _mora='\e[38;5;133m'
	declare -r _rosa='\e[38;5;211m'
	declare -r _r='\033[0m' 		# Reset
	declare -r _b='\033[1m' 		# Bold
	declare -r _i='\033[3m' 		# Italic
	declare -r _u='\033[4m' 		# Underline
	declare -r _s='\033[9m' 		# Strikeout

	# Globales (utilizadas en todo el programa)
	p=0;					# Son los procesos.
	tamMem=0;				# Tamaño de la memoria total.
	marcosMem=0;			# Número de marcos que caben en la memoria
	tamPag=0;				# Tamaño de las páginas.
	ord=0;					# Procesos ordenados según orden de llegada.
	nProc=0; 				# Número total de procesos.
	alg="FCFS"				# Algoritmo a utilizar (puede ser "FCFS" o "SJF").

	# Globales auxiliares (utilizadas en varias funciones como contador para bucles, índices, valores máximos, etc.)
	counter=0;
	letra="a";
	max=0;
	i=0;
	xx=0;
	v=0;
	o=0;
	
	# menuInicio
	menuOpcion=0;			# Utilizada en la función menuInicio, para elegir el algoritmo, la ayuda o salir del programa.

	# seleccionInforme
	informe="./datosScript/Informes/informeBN.txt";					# Nombre del fichero donde se guardará el informe en BLANCO y NEGRO.
	informeColor="./datosScript/Informes/informeCOLOR.txt";			# Nombre del fichero donde se guardará el informe A COLOR.

	# entradaFichero
	ficheroIn=0; 			# Indica el nombre del fichero de entrada (con extensión .txt).
	posic=0;
	fila=0;
	maxFilas=0;
	fichSelect=0;	

	# entradaAleatorioTotal -> constantes que establecen límites (como los rangos son muy extensos, para que no salgan cifras desorbitadas).
	declare -r MAX_PROC=99	# Número máximo de procesos.

	# seleccionTipoEjecucion
	segEsperaEventos=0		# Segundos de espera entre cada evento mostrado por pantalla.
	opcionEjec=0			# Modo de ejecución del algoritmo (por eventos=1, automático=2, etc).

	# Algoritmo ejecucion
	tSistema=0;				# Tiempo actual del sistema.
	seAcaba=0;
	laMedia=0;				# Media calculada por la función 'media()'.

	# Vectores
	colorines=()					# Contiene el último dígito del color asignado a cada proceso. Utilizado en varias funciones para colorear los procesos.
	ordenados=()					# Guarda el número de los procesos en orden de llegada.
	esperaConLlegada=()				# Tiempo de espera de cada proceso incluyendo el tiempo de llegada.
	esperaSinLlegada=()				# Tiempo de espera de cada proceso sin incluir el tiempo de llegada.
	tLlegada=();					# Recoge los tiempos de llegada.
	tEjec=();						# Recoge los tiempos de ejecución.
	tamProceso=();					# Recoge los tamaños de los procesos.
	nMarcos=(); 					# Recoge la cantidad de marcos de cada proceso.
	maxPags=();						# Recoge el número máximo de páginas de los procesos.
	declare -A direcciones			# Recoge las direcciones de página de cada proceso.
	declare -A paginas				# Recoge las páginas de cada proceso
	enMemoria=();					# Vale "fuera" si el proceso no está en memoria, "dentro" si el proceso está en memoria y "salido" si acabó.
	# LINEA TIEMPO -> BORRAR SI NO SIRVEN
	# pEjecutados=()       			# Almacena los procesos ejectuados a lo largo del tiempo.
	# tCambiosContexto=()            	# Tiempos en los que se producen los cambios de contexto.
	# tCambiosContexto[0]=0
	# nCambiosContexto=0;				# Número de cambios de contexto (índice para el vector 'tCambiosContexto').
	ejecutandoAntiguo=0;			# Proceso que se estaba ejecutando antes. Se usa para mostrar la tabla de fallos de página de un proceso que acaba de finalizar.
	cola=();						# Cola de ejecución (orden en el que se ejecutarán los procesos que están en memoria).
	colaMemoria=()					# Cola de memoria. Los procesos que llegan al sistema se almacenan en esta cola.

	# calcularEspaciosMemoria
	procesosMemoria=()			# Array que contiene los procesos que están actualmente asignados en memoria.
	tamEspacioGrande=0			# Tamaño del espacio vacío más grande en memoria.
	espaciosMemoria=()			# Array que contiene la cantidad de espacios vacíos consecutivos en memoria.

	# Algoritmo Reloj
	declare -A procesoTiempoMarcoPagina			# Valores de los marcos de memoria.
	declare -A procesoTiempoMarcoPuntero		# Orden del puntero.
	declare -A procesoTiempoMarcoBitsReloj		# Valores de bits de reloj.

	# muestraTablaPaginas
	nPagAEjecutar=();
	nPagEjecutadas=();
	contadorPag=();
	
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
#				En caso de introducir una opción no válida, se notifica al usuario y se vuelve a preguntar hasta que la introduzca correctamente.
function menuInicio(){

	clear
	cabecera
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
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Visualizar la ayuda"
			printf "\t$_verd%s$_r%s\n\n"		"[3]" " -> Salir"
			sleep 0.3
			;;
		2) # Muestra la opción 2 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> Visualizar la ayuda"
			printf "\t$_verd%s$_r%s\n\n"		"[3]" " -> Salir"
			sleep 0.3
			;;
		3) # Muestra la opción 3 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Visualizar la ayuda"
			printf "\t$_sel%s%s$_r\n"			"[3]" " -> Salir"
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

# Permite elegir al usuario si quiere ejecutar el algoritmo por FCFS o SJF.
function seleccionAlgoritmo(){
	
	clear
	cabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" Escoja un algoritmo de planificación de procesos:"
	printf "\t$_verd%s$_r%s\n"			"[1]" " -> FCFS"
	printf "\t$_verd%s$_r%s\n\n"			"[2]" " -> SJF"
	read -p " Seleccione la opción: " algSeleccionado
	
	until [[ $algSeleccionado =~ ^[1-2]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Valor incorrecto." " Escriba '1' o '2': "
		read algSeleccionado
	done

	case $algSeleccionado in
		1) # Muestra la opción 1 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" Escoja un algoritmo de planificación de procesos:"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> FCFS"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> SJF"
			alg="FCFS"
			sleep 0.3
			;;
		2) # Muestra la opción 2 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" Escoja un algoritmo de planificación de procesos:"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> FCFS"
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> SJF"
			alg="SJF"
			sleep 0.3
			;;
	esac
}

###################################################################################################################################

# Muestra al usuario qué nombres se le darán por defecto a los informes, permitiendo cambiarlos si así se deseara.
function seleccionInforme(){

	clear
	cabecera
	printf "\n%s" 						" Los nombres por defecto de los informes son: informeBN.txt, informeCOLOR.txt"
	printf "\n%s\n" 					" ¿Desea cambiarlos? (s/n)"
	read cambiarInformes
	
	until [[ $cambiarInformes =~ ^[nNsS]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Entrada no válida." " Escriba 's' (SI) o 'n' (NO): "
		read cambiarInformes
	done

	if [[ $cambiarInformes =~ ^[sS]$ ]]; then
		
		clear
		cabecera
		printf "\n%s" 					" Los nombres por defecto de los informes son: informeBN.txt, informeCOLOR.txt"
		printf "\n%s\n" 				" ¿Desea cambiarlos? (s/n)"
		printf "\n%s" 					" >> Introduzca el nombre del informe en BLANCO y NEGRO (sin incluir .txt): "
		read informe
		informe="./datosScript/Informes/${informe}.txt"
		sleep 0.2
		clear
		cabecera
		printf "\n%s" 					" Los nombres por defecto de los informes son: informeBN.txt, informeCOLOR.txt"
		printf "\n%s\n" 				" ¿Desea cambiarlos? (s/n)"
		printf "\n%s" 					" >> Introduzca el nombre del informe A COLOR (sin incluir .txt): "
		read informeColor
		informeColor="./datosScript/Informes/${informeColor}.txt"
		sleep 0.2
	else
		printf "\n%s\n" " Se utilizarán los nombres por defecto."
		sleep 1
	fi
	clear
	touch $informe			# Crea el archivo en BLANCO y NEGRO con el nombre que tiene la variable 'informe'.
	touch $informeColor		# Crea el archivo A COLOR con el nombre que tiene la variable 'informeColor'.
	cabeceraInforme
}

###################################################################################################################################

# Permite al usuario seleccionar de qué manera van a ser introducidos los datos.
function seleccionEntrada(){

	clear
	cabecera
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
	echo -e "\e[1;38;5;81m Seleccione una opción: : \e[0m" >> $informeColor
	
	# Muestra resaltada la opción seleccionada para que sea más visual.
	case $opcionIn in
		1)
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n\n"		"[6]" " -> Otro fichero de rangos"

			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Introducción manual de datos	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Introducción manual de datos <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			entradaManual
			;;
		2)
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n\n"		"[6]" " -> Otro fichero de rangos"	
		
			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Fichero de datos de última ejecución (DatosLast.txt)	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Fichero de datos de última ejecución (DatosLast.txt) <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			entradaUltimaEjec
			;;
		3)
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_sel%s%s$_r\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n\n"		"[6]" " -> Otro fichero de rangos"
		
			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Otro fichero de datos	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Otro fichero de datos <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			entradaFichero
			;;
		4)
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_sel%s%s$_r\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n\n"		"[6]" " -> Otro fichero de rangos"
		
			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Introducción manual de rangos (aleatorio)	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Introducción manual de rangos (aleatorio) <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			entradaManualRangos
			;;
		5)
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_sel%s%s$_r\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_verd%s$_r%s\n\n"		"[6]" " -> Otro fichero de rangos"
		
			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Fichero de rangos de última ejecucuion (DatosRangosLast.txt)	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Fichero de rangos de última ejecucuion (DatosRangosLast.txt) <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			entradaUltimaEjecRangos
			;;
		6)
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_verd%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_verd%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_sel%s%s$_r\n\n"			"[6]" " -> Otro fichero de rangos"
		
			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Otro fichero de rangos	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Otro fichero de rangos <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			entradaFicheroRangos
		;;
		7)
			clear
			#cabecera
			entradaAleatorioTotal

			#modif -> que se vea lo seleccionado ...
		;;
	esac
	
	calcularEspaciosMemoria

	for (( proc=1; proc<=$nProc; proc++ )); do
		reloj $proc
	done
}

###################################################################################################################################

# Las variables globales serán introducidas una a una por teclado.
#	Relativa a la opción 1: 'Introducción manual de datos' en el menú de selección de entrada de datos.
function entradaManual(){
	
	local otroProc="s";		# Para comprobar si se quiere introducir o no un nuevo proceso.
	clear
	cabecera
	imprimeVarGlob
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el número de marcos de pagina en la \e[1;33mmemoria\e[0m: "
	read marcosMem
	echo -n " Introduzca el número de marcos de pagina en la memoria: " >> $informe
	echo -n -e " Introduzca el número de marcos de pagina en la \e[1;33mmemoria\e[0m: " >> $informeColor
	
	# Comprueba que el número de marcos en memoria introducido se trata de un número y es mayor que 0.
	until [[ $marcosMem =~ [0-9] && $marcosMem -gt 0 ]]; do
		echo ""
		echo -e "\e[1;31m El número de marcos de pagina en la memoria debe ser mayor que \e[0m\e[1;33m0\e[0m"
		echo -n -e " Introduzca el número de marcos de pagina en la \e[1;33mmemoria\e[0m: "
		read marcosMem
	done
	echo "$marcosMem" >> $informe
	echo -e "\e[1;32m$marcosMem\e[0m" >> $informeColor
	sleep 0.2
	clear
	cabecera
	imprimeVarGlob
	
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el tamaño de \e[1;33mpágina\e[0m: "
	read tamPag
	echo -n " Introduzca el tamaño de página: " >> $informe
	echo -n -e " Introduzca el tamaño de \e[1;33mpágina\e[0m: " >> $informeColor
	
	until [[ $tamPag =~ [0-9] && $tamPag -gt 0 ]]
		do
			echo ""
			echo -e "\e[1;31m El tamaño de página debe ser mayor que 0\e[0m"
			echo -n -e " Introduzca el tamaño de \e[1;33mpágina\e[0m: "
			read tamPag
		done
	echo "$tamPag" >> $informe
	echo -e "\e[1;32m$tamPag\e[0m" >> $informeColor
	
	tamMem=$(($marcosMem*$tamPag))
	sleep 0.2
	clear
	cabecera
	imprimeVarGlob
	sleep 1
	p=1
	clearImprime
	
	# Pide los datos de cada proceso hasta que no se quieran más procesos.
	while [[ $otroProc == "s" ]]; do

		maxPags[$p]=0;

		# Tiempo de llegada.	
		echo "" >> $informe
		echo "" >> $informeColor
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

		# Tiempo de ejecución.
		echo "${tEjec[$p]}" >> $informe
		echo -e "\e[1;32m${tEjec[$p]}\e[0m" >> $informeColor
		pag=${tEjec[$p]};
		clearImprime
		
		# Número de marcos del proceso.
		echo "" >>$informe
		echo "" >> $informeColor
		echo -n -e " Introduzca el \e[1;33mnúmero de marcos\e[0m del proceso $p: "
		read nMarcos[$p]
		echo -n " Introduzca el número de marcos del proceso $p: " >> $informe
		echo -n -e " Introduzca el \e[1;33mnúmero de marcos\e[0m del proceso $p: " >> $informeColor
			
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))	# El tamaño total del proceso será su número de marcos multiplicado por el tamaño de las páginas.

		echo "${nMarcos[$p]}" >> $informe
		echo "" >> $informe
		echo " Tamaño mínimo estructural del proceso $p: ${tamProceso[$p]}" >> $informe
		echo -e "\e[1;32m${nMarcos[$p]}\e[0m" >> $informeColor
		echo "" >> $informeColor
		echo -e " \e[1;33Tamaño mínimo estructural\e[0m del proceso $p: \e[1;32m${tamProceso[$p]}\e[0m" >> $informeColor
		clearImprime

		for (( pag=0; ; pag++ )); do
			
			echo "" >> $informe
			echo "" >> $informeColor
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
		echo "" >> $informe
		echo "" >> $informeColor
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
		clearImprime
	done
	p=$(($p - 1))
	nProc=$p
	guardaDatos
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se inicializan con los datos contenidos en el fichero de última ejecución (DatosLast.txt).
# 	Relativa a la opción 2: 'Fichero de datos de última ejecución (DatosLast.txt)' en el menú de selección de entrada de datos.
function entradaUltimaEjec(){
	
	echo "" >> $informeColor
	echo "" >> $informe
	echo -e " Elija un \e[1;32mfichero\e[0m: " >> $informeColor
	echo -n " Elija un fichero: " >> $informe
	ficheroIn="DatosLast.txt"
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	echo "$ficheroIn" >> $informe
		
	if [ ! -f "./datosScript/FLast/$ficheroIn" ]; then		# Si el archivo NO existe, se informa del error.
    	
		printf "\n$_rojo$_b%s$_r%s"	" ERROR." " El archivo $ficheroIn no existe. "
		printf "\n%s" " >> Nota: El archivo de datos de última ejecución se creará automáticamente cuando se ejecute algún algoritmo."
		printf "\n\n%s\n" " Pulse INTRO para salir del programa ↲"
		read
		exit 1
	else

		tamMem=`awk NR==1 ./datosScript/FLast/"$ficheroIn"`
		tamPag=`awk NR==2 ./datosScript/FLast/"$ficheroIn"`
	
		echo $tamMem
		echo $tamPag
	
		marcosMem=$(($tamMem/$tamPag))
		nProc=`wc -l < ./datosScript/FLast/"$ficheroIn"`
		let nProc=$nProc-2
		p=1;
		maxFilas=$(($nProc+2))
		for (( fila = 3; fila <= $maxFilas; fila++ )); do
			linea=`awk NR==$fila ./datosScript/FLast/"$ficheroIn"`
        	IFS=";" read -r -a parte <<< "$linea"

			tLlegada[$p]=${parte[0]}
			nMarcos[$p]=${parte[1]}
			tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
			
			linea=`awk NR==$fila ./datosScript/FLast/"$ficheroIn"`
			IFS=";" read -r -a parte <<< "$linea"
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
		printf "\n%s\n" " >> Has introducido los datos por el fichero de la última ejecución." >> $informe
		printf "\n%s\n" " >> Has introducido los datos por el fichero de la última ejecución." | tee -a $informeColor
		imprimeProcesosFinal
	fi
}

###################################################################################################################################

# Las variables globales se inicializan con los datos contenidos en un fichero de datos.
# 	Relativa a la opción 3: 'Otro fichero de datos' en el menú de selección de entrada de datos.
function entradaFichero(){

	clear
	cabecera
	echo "" | tee -a $informeColor

	muestraArchivos
	echo "" >> $informe
	echo -e " Elija un \e[1;32mfichero\e[0m: " | tee -a $informeColor
	echo -n " Elija un fichero: " >> $informe
	read fichSelect
	until [[ $tamMem =~ [0-9] && $fichSelect -gt 0 && $fichSelect -le $max ]]; do
		echo ""
		echo -e "\e[1;31m El valor introducido no es correcto. Debe estar entre\e[0m \e[1;33m1\e[0m \e[1;31my\e[0m \e[1;33m$max\e[0m"
		echo -n " Elija un fichero: "
		read fichSelect
	done

	clear
	cabecera
	echo ""
	muestraArchivos 1
	sleep 0.5
	ficheroIn=`find datosScript/FDatos -maxdepth 1 -type f -iname "*.txt" | sort | cut -f3 -d"/" | cut -f$fichSelect -d$'\n'` # Guardar el nombre del fichero escogido.
	echo "$ficheroIn" >> $informe
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	
	tamMem=`awk NR==1 ./datosScript/FDatos/"$ficheroIn"`
	tamPag=`awk NR==2 ./datosScript/FDatos/"$ficheroIn"`
	marcosMem=$(($tamMem/$tamPag))
	nProc=`wc -l < ./datosScript/FDatos/"$ficheroIn"`
	let nProc=$nProc-2
	p=1;
	maxFilas=$(($nProc+2))
	for (( fila = 3; fila <= $maxFilas; fila++ )); do
		linea=`awk NR==$fila ./datosScript/FDatos/"$ficheroIn"`
        IFS=";" read -r -a parte <<< "$linea"

		tLlegada[$p]=${parte[0]}
		nMarcos[$p]=${parte[1]}
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
			
		linea=`awk NR==$fila ./datosScript/FDatos/"$ficheroIn"`
		IFS=";" read -r -a parte <<< "$linea"
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
	local rutaDestino="./datosScript/FDatos/$ficheroIn"
	cp "${rutaDestino}" "./datosScript/FLast/DatosLast.txt"
	printf "%s\n" " >> Has introducido los datos por fichero." >> $informe
	printf "%s\n" " >> Has introducido los datos por fichero." | tee -a $informeColor
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores introducido por teclado para cada una.
# 	Relativa a la opción 4: 'Introducción manual de rangos (aleatorio)' en el menú de selección de entrada de datos.
function entradaManualRangos(){
	
	inicializaVariablesRangos
	
	# Mínimo número de marcos en memoria.
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
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
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
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
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
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
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
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
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
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
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
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
	clear
	cabecera
	imprimeVarGlobRangos
	maxPags[$p]=0;
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
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
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
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
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el mínimo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
	read minRangoNumMarcos
	echo -n " Introduzca el mínimo del número de marcos asociados a cada proceso: " >> $informe
	echo -n -e " Introduzca el mínimo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: " >> $informeColor
	until [[ $minRangoNumMarcos =~ [0-9] && $minRangoNumMarcos -ge 0 ]]; do
		echo ""
		echo -e "\e[1;31m El mínimo del número de marcos asociados a cada proceso debe ser un número positivo\e[0m"
		echo -n -e " Introduzca el mínimo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
		read minRangoNumMarcos
	done

	# Máximo número de marcos asociados a cada proceso.	
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el máximo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
	read maxRangoNumMarcos
	echo -n " Introduzca el máximo del número de marcos asociados a cada proceso: " >> $informe
	echo -n -e " Introduzca el máximo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: " >> $informeColor
	until [[ $maxRangoNumMarcos =~ [0-9] && $maxRangoNumMarcos -ge $minRangoNumMarcos ]]; do
		echo ""
		echo -e "\e[1;31m El máximo número del rango de marcos asociados a cada procesos debe ser un número positivo mayor o igual que $minRangoNumMarcos \e[0m"
		echo -n -e " Introduzca el máximo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
		read maxRangoNumMarcos
	done		

	# Mínimo valor para una dirección de página.	
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el \e[1;33mmínimo del rango del número de direcciones a ejecutar\e[0m: "
	read  minRangoValorDireccion
	until [[ $minRangoValorDireccion =~ [0-9] && $minRangoValorDireccion -ge 0 ]]; do
		echo ""
		echo -e "\e[1;31m El mínimo del rango del número de direcciones a ejecutar debe ser mayor o igual que \e[0m\e[1;33m0 \e[0m"
		echo -n -e " Introduzca el \e[1;33mmínimo del rango del número de direcciones a ejecutar\e[0m: "
		read minRangoValorDireccion
	done

	# Máximo valor para una dirección de página.		
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca la máxima\e[1;33m dirección de página\e[0m : "
	read  maxRangoValorDireccion
	until [[ $maxRangoValorDireccion =~ [0-9] && $maxRangoValorDireccion -ge $minRangoValorDireccion ]]; do
		echo ""
		echo -e "\e[1;31m La máxima dirección de página debe ser mayor que \e[0m\e[1;33m$minRangoValorDireccion\e[0m"
		echo -n -e " Introduzca la \e[1;33mmáxima dirección de página\e[0m: "
		read maxRangoValorDireccion
	done
	
	# Tamaño mínimo del proceso.			
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el mínimo del rango del \e[1;33mtamaño del proceso (direcciones) \e[0m: "
	read  minRangoNumDirecciones	
	until [[ $minRangoNumDirecciones =~ [0-9] && $minRangoNumDirecciones -ge 1 ]]; do
		echo ""
		echo -e "\e[1;31m El mínimo del rango del tamaño del proceso (direcciones) debe ser mayor que \e[0m\e[1;33m0 \e[0m"
		echo -n -e " Introduzca el mínimo del rango del \e[1;33mtamaño del proceso (direcciones) \e[0m: "
		read minRangoNumDirecciones
	done
	
	# Tamaño máximo del proceso.	
	clear
	cabecera
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
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
			#clearImprime
		done
		#clearImprime
	done
	
	p=$(($p - 1))
	nProc=$p

	printf "\n%s\n" " Pulse INTRO para continuar ↲"
	read

	guardaDatos
	guardaRangos
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores contenido en el fichero de última ejecución (DatosRangosLast.txt).
# 	Relativa a la opción 5: 'Fichero de rangos de última ejecución (DatosRangosLast.txt)' en el menú de selección de entrada de datos.
function entradaUltimaEjecRangos(){
	
	inicializaVariablesRangos
	leeRangosFichero "ultimaEjecucion"
	generaDatosAleatorios
	printf "%s\n" " >> Los datos se han generado por el fichero de rangos de última ejecución." | tee -a $informeColor
	printf "%s\n" " >> Los datos se han generado por el fichero de rangos de última ejecución." >> $informe
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores contenido en un fichero de rangos.
# 	Relativa a la opción 6: 'Otro fichero de rangos' en el menú de selección de entrada de datos.
function entradaFicheroRangos(){

	clear
	cabecera
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

	clear
	cabecera
	echo ""
	muestraArchivosRangos 1
	sleep 0.5

	# Guarda el nombre del fichero escogido.
	ficheroIn=`find datosScript/FRangos -maxdepth 1 -type f -iname "*.txt" | sort | cut -f3 -d"/" | cut -f$fichSelect -d$'\n'`
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	echo "$ficheroIn" >> $informe

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
	
	leeRangosAleatorioTotal
	imprimeVarAleatorioTotal
	compruebaRangosAleatorioTotal
	echo " Pulse INTRO para continuar ↲ "
	read
	#clear		-> DESCOMENTAR una vez enseñado y que compruebe que va bien
	imprimeVarAleatorioTotal
	echo " Pulse INTRO para continuar ↲ "
	read
	guardaRangos
	generaDatosAleatorios "aleatorioTotal"
	imprimeProcesosFinal
}

###################################################################################################################################

# Pide el tipo de ejecución al usuario.
function seleccionTipoEjecucion(){
	clear
	cabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" Seleccione el tipo de ejecución:"
	printf "\t$_verd%s$_r%s\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)"
	printf "\t$_verd%s$_r%s\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)"
	printf "\t$_verd%s$_r%s\n"			"[3]" " -> Completa (sin esperas)"
	printf "\t$_verd%s$_r%s\n\n"		"[4]" " -> Completa solo resumen"
	read -p " Seleccione la opción: " opcionEjec
	until [[ $opcionEjec =~ ^[1-4]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Valor incorrecto." " Escriba '1', '2', '3' o '4': "
		read opcionEjec
	done

	case $opcionEjec in
		1) # Muestra la opción 1 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n\n"		"[4]" " -> Completa solo resumen" | tee -a $informeColor

			printf "\n%s\n\n"					" ¿Qué opción desea realizar?" >> $informe
			printf "\t%s%s\n"					" -> [1]" " Por eventos (pulsando INTRO en cada cambio de estado) <-" >> $informe
			printf "\t%s%s\n"					"[2]" " Automática (introduciendo cada cuántos segundos cambia de estado)" >> $informe
			printf "\t%s%s\n"					"[3]" " Completa (sin esperas)" >> $informe
			printf "\t%s%s\n\n"					"[4]" " Completa solo resumen" >> $informe
			sleep 0.3
			;;
		2) # Muestra la opción 2 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n\n"		"[4]" " -> Completa solo resumen" | tee -a $informeColor

			printf "\n%s\n\n"					" ¿Qué opción desea realizar?" >> $informe
			printf "\t%s%s\n"					"[1]" " Por eventos (pulsando INTRO en cada cambio de estado)" >> $informe
			printf "\t%s%s\n"					" -> [2]" " Automática (introduciendo cada cuántos segundos cambia de estado) <-" >> $informe
			printf "\t%s%s\n"					"[3]" " Completa (sin esperas)" >> $informe
			printf "\t%s%s\n\n"					"[4]" " Completa solo resumen" >> $informe
			sleep 0.3

			read -p "Introduzca el número de segundos entre cada evento: " segEsperaEventos
			until [[ $segEsperaEventos =~ [0-9] && $segEsperaEventos -gt 0 ]]; do
				printf "\n$_rojo$_b%s$_r%s"	" Valor incorrecto." " Introduzca un número mayor que 0: "
				read segEsperaEventos
			done
			;;
		3) # Muestra la opción 3 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n\n"		"[4]" " -> Completa solo resumen" | tee -a $informeColor

			printf "\n%s\n\n"					" ¿Qué opción desea realizar?" >> $informe
			printf "\t%s%s\n"					"[1]" " Por eventos (pulsando INTRO en cada cambio de estado)" >> $informe
			printf "\t%s%s\n"					"[2]" " Automática (introduciendo cada cuántos segundos cambia de estado)" >> $informe
			printf "\t%s%s\n"					" -> [3]" " Completa (sin esperas) <-" >> $informe
			printf "\t%s%s\n\n"					"[4]" " Completa solo resumen" >> $informe
			# Es igual que la opción 2 solo que los segundos de espera entre eventos son 0.
			segEsperaEventos=0
			opcionEjec=2
			sleep 0.3
			;;
		
		# DESHABILITADA DE MOMENTO
		4) # Muestra la opción 4 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_verd%s$_r%s\n"			"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[4]" " -> Completa solo resumen" | tee -a $informeColor

			printf "\n%s\n\n"					" ¿Qué opción desea realizar?" >> $informe
			printf "\t%s%s\n"					"[1]" " Por eventos (pulsando INTRO en cada cambio de estado)" >> $informe
			printf "\t%s%s\n"					"[2]" " Automática (introduciendo cada cuántos segundos cambia de estado)" >> $informe
			printf "\t%s%s\n"					"[3]" " Completa (sin esperas)" >> $informe
			printf "\t%s%s\n\n"					" -> [4]" " Completa solo resumen <-" >> $informe
			sleep 0.3
			;;
	esac
	clear
}

###################################################################################################################################


# Comprobamos los mínimos. Si hay error, se notifica (añade al log) y se recalcula el mínimo. Después se calcula el máximo a  partir
# del mínimo (que ha sido recalculado o no).
function compruebaRangosAleatorioTotal(){

	local numFallosAleTotal=0
	local logErroresAleTotal="\n"

	# El número de marcos de la memoria tiene que ser como mínimo 1.
	if [ "$minRangoMemoria" -lt 1 ]; then
    	aleatorioEntreConNegativos minRangoMemoria 1 $maxRangoMemoriaAleTotal
		logErroresAleTotal+=" - Tiene que haber como mínimo 1 marco en la memoria total.\n"
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoMemoria $minRangoMemoria $maxRangoMemoriaAleTotal


	# El tamaño de página tiene que ser como mínimo 1.
	if [ "$minRangoTamPagina" -lt 1 ]; then
    	aleatorioEntreConNegativos minRangoTamPagina 1 $maxRangoTamPaginaAleTotal
		logErroresAleTotal+=" - El tamaño de página tiene que ser como mínimo 1.\n"
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
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoNumProcesos $minRangoNumProcesos $maxRangoNumProcesosAleTotal
	# Calculamos el número de procesos total.
	aleatorioEntre numeroProcesos $minRangoNumProcesos $maxRangoNumProcesos


	# El tiempo de llegada de un proceso puede ser a partir de 0.
	if [ "$minRangoTLlegada" -lt 0 ]; then
    	aleatorioEntreConNegativos minRangoTLlegada 0 $maxRangoTLlegadaAleTotal
		logErroresAleTotal+=" - Los tiempos de llegada deben ser a partir del instante T=0.\n"
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoTLlegada $minRangoTLlegada $maxRangoTLlegadaAleTotal


	# El número de marcos asociados a un proceso tiene que ser como mínimo 1. También tiene que ser menor que el número de marcos de la memoria.
	if [ "$minRangoNumMarcos" -lt 1 ]; then
    	# Si el número de marcos de la memoria es menor que el máximo del rango aleatorio total del fichero, entonces el límite máximo
		# pasa a ser el número de marcos de la memoria. Si no, el límite seguirá siendo el indicado en el fichero.
		if [ "$marcosMem" -lt "$maxRangoNumMarcosAleTotal"  ]; then
			aleatorioEntreConNegativos minRangoNumMarcos 1 $marcosMem
		else
			aleatorioEntreConNegativos minRangoNumMarcos 1 $maxRangoNumMarcosAleTotal
		fi
		logErroresAleTotal+=" - El número de marcos asociados a un proceso tiene que ser como mínimo 1.\n"
		((numFallosAleTotal++))

	elif [ "$minRangoNumMarcos" -gt "$marcosMem" ]; then		# Cabe la posibilidad de que el mínimo generado supere el número de marcos de la memoria.
		aleatorioEntreConNegativos minRangoNumMarcos 1 $marcosMem
		logErroresAleTotal+=" - El número de marcos asociados a un proceso no puede exceder el número de marcos de la memoria.\n"
		((numFallosAleTotal++))
	fi
	#aleatorioEntreConNegativos maxRangoNumMarcos ...
	if [ "$marcosMem" -lt "$maxRangoNumMarcosAleTotal"  ]; then
		aleatorioEntreConNegativos maxRangoNumMarcos $minRangoNumMarcos $marcosMem
	else
		aleatorioEntreConNegativos maxRangoNumMarcos $minRangoNumMarcos $maxRangoNumMarcosAleTotal
	fi


	# Cada proceso debe tener como mínimo 1 dirección de página.
	if [ "$minRangoNumDirecciones" -lt 1 ]; then
    	aleatorioEntreConNegativos minRangoNumDirecciones 1 $maxRangoNumDireccionesAleTotal
		logErroresAleTotal+=" - Cada proceso debe tener como mínimo 1 dirección de página.\n"
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoNumDirecciones $minRangoNumDirecciones $maxRangoNumDireccionesAleTotal


	# El valor de las direcciones de página de un proceso puede ser a partir de 0.
	if [ "$minRangoValorDireccion" -lt 0 ]; then
    	aleatorioEntreConNegativos minRangoValorDireccion 0 $maxRangoValorDireccionAleTotal
		logErroresAleTotal+=" - Los valores de las direcciones de página de los procesos van de 0 en adelante.\n"
		((numFallosAleTotal++))
	fi
	aleatorioEntreConNegativos maxRangoValorDireccion $minRangoValorDireccion $maxRangoValorDireccionAleTotal

	printf "\n\n$_rojo$_b%s$_r" " ERRORES"
	if [ "$numFallosAleTotal" -ne 0 ]; then
		echo -ne "$logErroresAleTotal"
		# echo -ne "$logErroresAleTotal" | tee -a $informeColor
		# echo -ne "$logErroresAleTotal">> $informe
	else
		printf "\n\n%s" " >> No se han producido fallos al generar los rangos mínimos aleatoriamente."
	fi
	printf "\n\n"		#sustituir por imprimehuecos...
}


###########################
#        AUXILIARES       #
###########################

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
			#clearImprime
		done
		#clearImprime
	done
	
	p=$(($p - 1))
	nProc=$p
	guardaDatos
}

###################################################################################################################################

# Lee un fichero de DATOS y asigna a las variables los valores contenidos en él.
# 	- Si se pasa como parámetro "ultimaEjecucion", el fichero a leer será 'DatosLast.txt'.
# 	- Si no hay parámetros, el fichero a leer será el que haya especificado anteriormente el usuario, almacenado en la variable 'ficheroIn'.
function leeDatosFichero(){
	echo "modif"
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
			ficheroRangos="./datosScript/FLast/${nombreFicheroRangos}.txt"
		fi	
	else
		ficheroRangos="./datosScript/FRangos/$ficheroIn"
	fi

	minRangoMemoria=`head -n 1 $ficheroRangos | tail -n 1 | cut -d "-" -f 1`
	maxRangoMemoria=`head -n 1 $ficheroRangos | tail -n 1 | cut -d "-" -f 2`
	minRangoTamPagina=`head -n 2 $ficheroRangos | tail -n 1 | cut -d "-" -f 1`
	maxRangoTamPagina=`head -n 2 $ficheroRangos | tail -n 1 | cut -d "-" -f 2`
	minRangoNumProcesos=`head -n 3 $ficheroRangos | tail -n 1 | cut -d "-" -f 1`
	maxRangoNumProcesos=`head -n 3 $ficheroRangos | tail -n 1 | cut -d "-" -f 2`
	minRangoTLlegada=`head -n 4 $ficheroRangos | tail -n 1 | cut -d "-" -f 1`
	maxRangoTLlegada=`head -n 4 $ficheroRangos | tail -n 1 | cut -d "-" -f 2`
	minRangoNumMarcos=`head -n 5 $ficheroRangos | tail -n 1 | cut -d "-" -f 1`
	maxRangoNumMarcos=`head -n 5 $ficheroRangos | tail -n 1 | cut -d "-" -f 2`
	minRangoNumDirecciones=`head -n 6 $ficheroRangos | tail -n 1 | cut -d "-" -f 1`
	maxRangoNumDirecciones=`head -n 6 $ficheroRangos | tail -n 1 | cut -d "-" -f 2`
	minRangoValorDireccion=`head -n 7 $ficheroRangos | tail -n 1 | cut -d "-" -f 1`
	maxRangoValorDireccion=`head -n 7 $ficheroRangos | tail -n 1 | cut -d "-" -f 2`
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
		ficheroRangos="./datosScript/FRangosAleTotal/${nombreFicheroAleTotal}.txt"
	fi

	for (( fila=1; fila<=7; fila++ )); do

		linea=$(sed -n "${fila}p" "$ficheroRangos")					# Leer la línea correspondiente en el archivo.
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

# Muestra los archivos que hay en el directorio './datosScript/FDatos'.
# 	Si se han pasado argumentos, muestra todos los archivos y resalta el elegido. Si no, imprime todos los archivos.
function muestraArchivos(){
	
	max=`find datosScript/FDatos -maxdepth 1 -type f | cut -f3 -d"/" | wc -l`				# Número de archivos en el directorio.
	printf "\n$_cyan$_b%s\n\n$_r"		" ARCHIVOS EN EL DIRECTORIO './datosScript/FDatos': "
	
	if [[ $# -gt 0 ]]; then		# Si el número de argumentos pasados ($#) es mayor que 0...
		for (( i=1; i<=$max; i++ )); do
			file=`find datosScript/FDatos -maxdepth 1 -type f | cut -f3 -d"/" | sort | cut -f$i -d$'\n'`	# Mostrar sólo los nombres de ficheros (no directorios).
			if [ $i -eq $fichSelect ]; then
				printf '    \e[1;38;5;64;48;5;7m	[%2u]\e[90m %-20s\e[0m\n' "$i" "$file" 		# Resaltar opción escogida.
			else
				printf '    \e[1;32m	[%2u]\e[0m %-20s\e[0m\n' "$i" "$file"
			fi
		done
	else
		for (( i=1; i<=$max; i++ )); do
			file=`find datosScript/FDatos -maxdepth 1 -type f | cut -f3 -d"/" | sort | cut -f$i -d$'\n'` #Mostrar solo los nombres de ficheros (no directorios).
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
	printf "\n$_cyan$_b%s\n\n$_r"		" ARCHIVOS EN EL DIRECTORIO './datosScript/FRangos': "
	
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
	printf " Valor de direcciones a ejecutar:           | Mínimo: \e[1;33m%4d\e[0m | Máximo: \e[1;33m%4d\e[0m |\n"   "${minRangoValorDireccion}" "${maxRangoValorDireccion}"
	printf " Tamaño del proceso (direcciones):          | Mínimo: \e[1;33m%4d\e[0m | Máximo: \e[1;33m%4d\e[0m |\n"   "${minRangoNumDirecciones}" "${maxRangoNumDirecciones}"
}


function imprimeVarAleatorioTotal(){
	
	local _c1="${_verd}${_b}"	# Color 1 para los rangos que salen del fichero.
	local _c2="${_azul}${_b}"	# Color 2 para los rangos generados aleatoriamente.

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
}

###################################################################################################################################

# Imprime por pantalla un resumen de los procesos y sus parámetros A MEDIDA QUE SON INTRODUCIDOS manualmente por el usuario.
function imprimeProcesos(){
	
	local maxpaginas=0
	ordenacion
	asignaColores
	echo "" >> $informe
	echo "" >> $informeColor
	echo -e " TABLA FINAL DE DATOS:\e[0m" | tee -a $informeColor
	echo -e " Memoria del Sistema:  \e[1;33m$tamMem\e[0m" | tee -a $informeColor
	echo -e " Tamaño  de   Página:  \e[1;33m$tamPag\e[0m" | tee -a $informeColor
	echo -e " Número  de   marcos:  \e[1;33m$marcosMem\e[0m" | tee -a $informeColor
	echo " Memoria del Sistema:  $tamMem" >> $informe
	echo " Tamaño   de  Página:  $tamPag" >> $informe
	echo " Número   de  marcos:  $marcosMem" >> $informe
	echo -e "\e[0m Ref Tll Tej nMar Dirección-Página" | tee -a $informeColor
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

	echo "" >> $informe
	echo "" >> $informeColor
}

###################################################################################################################################

# Imprime por pantalla un resumen de TODOS los procesos y sus parámetros. Se debe mostrar antes de la ejecución del algoritmo.
function imprimeProcesosFinal(){

	local maxpaginas=0
	ordenacion
	asignaColores
	echo "" >> $informe
	echo "" >> $informeColor
	
	echo -e " TABLA FINAL DE DATOS:\e[0m" | tee -a $informeColor
	echo -e " Memoria del Sistema: $tamMem" | tee -a $informeColor
	echo -e " Tamaño  de   Página: $tamPag" | tee -a $informeColor
	echo -e " Número  de   marcos: $marcosMem" | tee -a $informeColor
	echo " TABLA FINAL DE DATOS:" >> $informe
	echo " Memoria del Sistema:  $tamMem" >> $informe
	echo " Tamaño  de   Página:  $tamPag" >> $informe
	echo " Número  de   marcos:  $marcosMem" >> $informe
	echo -e "\e[0m Ref Tll Tej nMar Dirección-Página" | tee -a $informeColor
	echo -e " Ref Tll Tej nMar Dirección-Página" >> $informe
	
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
	
	printf "\n\n" >> $informe
	printf "\n\n" | tee -a $informeColor	
	echo " Pulse INTRO para continuar ↲ "
	read
}

###################################################################################################################################

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

# Genera un valor aleatorio y los números pueden ser o no negativos (el anterior solo es para positivos) -> fusionar si eso.
function aleatorioEntreConNegativos() {
    
	eval "${1}=$((RANDOM % ($3 - $2 + 1) + $2))"

	# if [[ $3 -lt $2 ]]; then
    #     eval "${1}=$2"
    # else
    #     eval "${1}=$((RANDOM % ($3 - $2 + 1) + $2))"
    # fi
}

###################################################################################################################################

# Calcula el tamaño del espacio vacío más grande en memoria ('tamEspacioGrande') y guarda la cantidad de espacios vacíos consecutivos en memoria ('espaciosMemoria').
function calcularEspaciosMemoria() {
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
	 	encontrarYactualizar
	 	if [[ $? -eq 1 ]]
	 	then
	 		reemplazarYactualizar
	 		((numeroFallos++))
	 	fi
	 	# Guardar el orden de memoria
	 	procesoTiempoMarcoPuntero[$1,$i]=$puntero

	 	for (( j = 0; j < ${numeroMarcos}; j++ )); do
	 		procesoTiempoMarcoPagina[$1,$i,$j]=${memoriaMarcos[$j]}
	 	done

	 	for (( j = 0; j < ${numeroMarcos}; j++ )); do
            procesoTiempoMarcoBitsReloj[$1,$i,$j]=${bitReloj[$j]}
       done
	done
	# Se guardan los fallos de paginación del proceso.
	fallos[$1]=$numeroFallos		
}

###################################################################################################################################

# Función auxiliar. Devuelve '0' si la página buscada se encuentra en memoria y '1' si no está en memoria.
function encontrarYactualizar(){

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
function reemplazarYactualizar(){

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

###################################################################################################################################



#####################################
#        VOLCADOS A PANTALLA        #
#####################################

# Imprime por pantalla el algoritmo utilizado, el instante de tiempo actual y las variables globales.
function imprimeCabeceraAlgoritmo(){
	
	imprimeHuecosInformes 2 0
	printf "%s\n" " FCFS/SJF - PAGINACIÓN - RELOJ - MEMORIA CONTINUA - NO REUBICABLE" | tee -a $informeColor
	printf "%s\n" " FCFS/SJF - PAGINACIÓN - RELOJ - MEMORIA CONTINUA - NO REUBICABLE" >> $informe
	printf "%s\t%s\n\n" " T=$tSistema" "Algoritmo utilizado = $alg    Memoria del sistema = $tamMem    Tamaño de página = $tamPag    Número de marcos:  $marcosMem" | tee -a $informeColor
	printf "%s\t%s\n\n" " T=$tSistema" "Algoritmo utilizado = $alg    Memoria del sistema = $tamMem    Tamaño de página = $tamPag    Número de marcos:  $marcosMem" >> $informe
}

###################################################################################################################################

# Muestra la tabla de procesos con sus respectivos parámetros (tiempos de llegada, ejecución, páginas, etc).
function diagramaResumen(){

	imprimeHuecosInformes 1 1
	#echo -e " \e[1;30;41mResumen:\e[0m\e[30;46mT.lleg|T.ejec|T.Rest|T.Retor\e[0m\e[47m  \e[0m\e[30;44mT.Espera\e[0m\e[47m      \e[0m\e[30;47mEstado\e[0m\e[47m      \e[0m\e[30;41mDirecc-Páginas\e[0m" | tee -a $informeColor
	echo -e " Ref Tll Tej nMar Tesp Tret Trej Mini Mfin Estado           Dirección-Página" | tee -a $informeColor
	
	#	Pro|TLl|TEj|nMar|TEsp|TRet|TRes
	#	...|...|...|....|....|....|....|
	
	for (( counter = 1; counter <= $nProc; counter++ )); do
		
		let ord=${ordenados[$counter]}
			
		if [[ $ord -lt 10 ]]; then
			printf " \e[1;3${colorines[$ord]}mP0$ord %3u %3u %4u" "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
			echo -n " P0$ord	T.lleg: ${tLlegada[$ord]}	T.Ejec: ${tEjec[$ord]}	Marcos: ${nMarcos[$ord]}	T.Espera: ${esperaConLlegada[$ord]}  " >> $informe
		else
			printf " \e[1;3${colorines[$ord]}mP$ord %3u %3u %4u" "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
			echo -n " P$ord	T.lleg: ${tLlegada[$ord]}	T.Ejec: ${tEjec[$ord]}	Marcos: ${nMarcos[$ord]}	T.Espera: ${esperaConLlegada[$ord]}  " >> $informe
		fi

		#Imprime el tiempo de espera
		if [[ ${tLlegada[$ord]} -gt $tSistema ]]; then		# Si el tiempo de llegada del proceso es mayor que el del sistema es porque aún no ha entrado.
			echo -n -e "    -   " | tee -a $informeColor
		else
			esperaSinLlegada[$ord]=$((${esperaConLlegada[$ord]}-${tLlegada[$ord]}))
			printf " %4d" "${esperaSinLlegada[$ord]}" | tee -a $informeColor
		fi
			
		#Imprime el tiempo de retorno
		if [[ $tSistema -ge ${tLlegada[$ord]} ]]; then
			if [[ ${tiempoRestante[$ord]} -eq 0 ]]
				then
					retorn=${duracion[$ord]}
				else
					retorn=`expr $tSistema - ${tLlegada[$ord]}`
			fi
			tRetorno[$ord]=$retorn
			printf " %4u" "$retorn" | tee -a $informeColor
		else
			echo -n -e " -" | tee -a $informeColor
		fi
			
		#Imprime el tiempo restante
			#			temmps=0
			#			if [[ ${tiempoRestante[$ord]} -eq 0 ]]
			#				then
			#					echo -n -e "	\e[1;3${colorines[$ord]}m$temmps\e[0m"
			#				else
				#	printf " %4u\e[0m" "${tiempoRestante[$ord]}" | tee -a $informeColor
				
					#echo -n -e "	${tiempoRestante[$ord]}" | tee -a $informeColor
		echo -n "T.Restante: ${tiempoRestante[$ord]} " >> $informe
			#			fi

		if [[ ${tLlegada[$ord]} -le $tSistema ]]; then
			printf " %4u\e[0m" "${tiempoRestante[$ord]}" | tee -a $informeColor
		fi

		if [[ " ${procesosMemoria[*]} " =~ " $ord " ]]; then
			for marcoNuevo in ${!procesosMemoria[*]}; do
				if [[ ${procesosMemoria[$marcoNuevo]} -eq $ord ]]; then
					printf "\e[1;3${colorines[$ord]}m%5u" "$marcoNuevo"
					printf "%5u" "$(($marcoNuevo+${nMarcos[$ord]}-1))"
					break
				fi
			done
		else
			printf "%5s" "-"
            printf "%5s" "-"
		fi
		
		#Imprime el estado
		if [[ ${tLlegada[$ord]} -le $tSistema ]]; then
			#	printf " %4u\e[0m" "${tiempoRestante[$ord]}" | tee -a $informeColor
			if [[ ${tiempoRestante[$ord]} -eq 0 ]]; then
				echo -n -e " \e[1;3${colorines[$ord]}mFinalizado\e[0m      " | tee -a $informeColor
				echo -n "Estado: Finalizado  " >> $informe
			else		
				if [[ ord -eq $ejecutando ]]; then			
					echo -n -e " \e[1;3${colorines[$ord]}mEn ejecución\e[0m    " | tee -a $informeColor
					echo -n "Estado: En ejecución " >> $informe
				else
					if [[ ${enMemoria[$ord]} != "dentro" ]]; then
						echo -n -e " \e[1;3${colorines[$ord]}mEn espera\e[0m       " | tee -a $informeColor
						echo -n "Estado: En espera " >> $informe
					else
						echo -n -e " \e[1;3${colorines[$ord]}mEn memoria\e[0m      " | tee -a $informeColor
						echo -n "Estado: En memoria " >> $informe
					fi
				fi
			fi
		else
			printf "    -\e[0m" "${tiempoRestante[$ord]}" | tee -a $informeColor
			echo -n -e " \e[1;3${colorines[$ord]}mFuera de sist.\e[0m  " | tee -a $informeColor
			echo -n " Estado: Fuera de sist.  " >> $informe
			#					echo -n -e " \e[1;3${colorines[$ord]}mLlega en t=${tLlegada[$ord]}\e[0m	" | tee -a $informeColor
			#					echo -n " Estado: Llega en t=${tLlegada[$ord]}  " >> $informe
		fi

		# Estado----------10
		# Finalizado------6
		# En ejecución----4
		# En cola---------9 
		# En pausa--------8 
		# Fuera de sist.--2
		#
										
		#Imprime las páginas
			let ord=${ordenados[$counter]}
			echo -n " "
			
			xx=0
			         #         echo -n "|${nPagEjecutadas[$ord]}|"
			for (( v = 1; v <  ${nPagEjecutadas[$ord]} ; v++ )); do
					
				echo -ne "\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m" | tee -a $informeColor
				echo -n " " | tee -a $informeColor
				echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
				echo -n " " >> $informe
				((xx++))
			done
		if [[ ord -eq $ejecutando && ${tLlegada[$ord]} -le $tSistema && $finalizados -ne $nProc ]]; then

		    for (( v = 0; v <=  ${nPagAEjecutar[$ord]} ; v++ )); do
                echo -ne "\e[4m\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m\e[0m" | tee -a $informeColor
                echo -n " " | tee -a $informeColor
                echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
                echo -n " " >> $informe
                 ((xx++))
            done
			for (( v = 1; v <  ${tiempoRestante[$ord]} ; v++ )); do
                echo -ne "\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m" | tee -a $informeColor
                echo -n " " | tee -a $informeColor
                echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
                echo -n " " >> $informe
                ((xx++))
            done
		else
 			for (( v = 0; v <  ${nPagAEjecutar[$ord]} ; v++ )); do
				echo -ne "\e[4m\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m\e[0m" | tee -a $informeColor
				echo -n " " | tee -a $informeColor
				echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
				echo -n " " >> $informe
				((xx++))
			done
			for (( v = 0; v <  ${tiempoRestante[$ord]} ; v++ )); do
                echo -ne "\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m" | tee -a $informeColor
                echo -n " " | tee -a $informeColor
                echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
                echo -n " " >> $informe
                ((xx++))
            done
		fi
		echo "" | tee -a $informeColor
		echo "" >> $informe
	done
	resumenTMedios
}

###################################################################################################################################

# Calcula y muestra por pantalla el tiempo medio de espera y el tiempo medio de llegada.
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
    if [ -n "${tMedioEsp}" ]; then
        printf " %s: %-9s" "Tiempo Medio de Espera" "${tMedioEsp}"
    else
        printf " %s: %-9s" "Tiempo Medio de Espera" "0.0"
    fi

    if [ -n "${tMedioRet}" ]; then
        printf " %s: %s\n" "Tiempo Medio de Retorno" "${tMedioRet}"
    else
        printf " %s: %s\n" "Tiempo Medio de Retorno" "0.0"
    fi
}

###################################################################################################################################

diagramaMemoria(){
	
	#          |P01            P04                           |
	#Memoria:  |--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.|
	#          |0              5                    12       |14

	imprimeHuecosInformes 1 1
	espaciosPintar=0;
	faltaPintar=0;

	filaMemProc=""
	filaMemMem=""
	filaMemMarc=""

	colorProcDiagMem=();
	colorDiagMem=();
	n=0;

	colsTerminal=`tput cols`
	longImprimeMem=0;
	veces=0;
	imprimeAhora=0;

	#Imprime fila de procesos
	marcosPintados=0

	filaMemProc="    |"

	for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ )); do
		if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]; then
			ord=${procesosMemoria[$marcoNuevo]}
			if [[ $ord -lt 10 ]]; then
				filaMemProc="${filaMemProc}P0$ord"
			else
				filaMemProc="${filaMemProc}P$ord"
			fi
			for (( i = 1; i < ${nMarcos[$ord]}; i++ )); do
				filaMemProc="${filaMemProc}   "
			done
			marcoNuevo=$(($marcoNuevo+${nMarcos[$ord]}-1))
		else
			filaMemProc="${filaMemProc}   "
		fi
	done

	filaMemProc="${filaMemProc}|"

	#Imprime fila de memoria
	marcosPintados=0
	filaMemMem=" BM |"

	for (( m = 0; m < $marcosMem; m++ )); do
		if [[ " ${!procesosMemoria[*]} " =~ " $m " ]]; then
			proc=${procesosMemoria[$m]}
			tiem=$((${tRetorno[$proc]}-${esperaSinLlegada[$proc]}))
			for (( i = 0; i < ${nMarcos[$proc]}; i++ )); do
				pag=${procesoTiempoMarcoPagina[$proc,$tiem,$i]}
				if [[ $pag -eq -1 ]] || [[ $proc -ne $ejecutando ]]; then
					printf -v cadenita "%3s" "-"
				else
					printf -v cadenita "%3d" "$pag"
				fi
				filaMemMem="${filaMemMem}$cadenita"
			done
			m=$((${nMarcos[$proc]}+$m-1))
		else
			printf -v cadenita "%3s" "-"
			filaMemMem="${filaMemMem}$cadenita"
		fi
	done

	filaMemMem="${filaMemMem}|"

	#Imprime fila de direcciones
	marcosPintados=0
	memPintada=0
	filaMemMarc="    |"

	for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ )); do
		if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]; then
			ord=${procesosMemoria[$marcoNuevo]}
			filaMemMarc="${filaMemMarc}$(printf "%3u" "$marcoNuevo")"
			for (( i = 1; i < ${nMarcos[$ord]}; i++ )); do
				filaMemMarc="${filaMemMarc}   "
			done
		elif [[ -n "${espaciosMemoria[$marcoNuevo]}" ]]; then
			filaMemMarc="${filaMemMarc}$(printf "%3u" "$marcoNuevo")"
			for (( i = 1; i < ${espaciosMemoria[$marcoNuevo]}; i++ )); do
				filaMemMarc="${filaMemMarc}   "
			done
		fi
	done

	filaMemMarc="${filaMemMarc}|"

	#guarda colores procesos
	n=6
	for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ )); do
		if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]; then
			ord=${procesosMemoria[$marcoNuevo]}
			for (( i = 0; i < ${nMarcos[$ord]}; i++ )); do
				for (( o=1; o<=3; o++ )); do
					colorProcDiagMem[$n]="\e[1;3${colorines[$ord]}m"
					((n++))
				done
			done
			marcoNuevo=$(($marcoNuevo+${nMarcos[$ord]}-1))
		else
			n=$((n+3))
		fi
	done

	#guarda colores diagrama
	marcosPintados=0
	n=0
	for (( n=1; n<=8; n++ )); do
		colorDiagMem[$n]="\e[0m"
	done
	n=6
	for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ )); do
		if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]; then
			ord=${procesosMemoria[$marcoNuevo]}
			for (( i = 0; i < ${nMarcos[$ord]}; i++ )); do
				for (( o=1; o<=3; o++ )); do
					colorDiagMem[$n]="\e[1;4${colorines[$ord]}m"
					((n++))
				done
			done
			marcoNuevo=$(($marcoNuevo+${nMarcos[$ord]}-1))
		else
			for (( o=1; o<=3; o++ )); do
				#colorDiagMem[$n]="\e[7m"
				
				colorDiagMem[$n]="\e[47m\e[30m"
				((n++))
			done
		fi
	done
	colorDiagMem[$n]="\e[0m"

	longImprimeMem=`expr length "$filaMemMem"`
	veces=0;
	imprimeAhora=0;

	until [[ $longImprimeMem -le 0 ]]; do
		if [[ $longImprimeMem -le $colsTerminal ]]; then
			imprimeAhora=$longImprimeMem
		else
			imprimeAhora=$colsTerminal
		fi

		if [[ $veces -ne 0 ]]; then
			echo "" | tee -a $informeColor
			printf "\n" >> $informe
		fi
		for ((n=1; n<= $imprimeAhora; n++)); do
			let m=n+colsTerminal*veces
			echo -n -e "${colorProcDiagMem[$m]}" | tee -a $informeColor
			printf '%c' "$filaMemProc" | tee -a $informeColor
			printf '%c' "$filaMemProc" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >> $informe
			filaMemProc=${filaMemProc#?}
			echo -n -e "\e[0m" | tee -a $informeColor
		done
		echo "" | tee -a $informeColor
		printf "\n" >> $informe

		for ((n=1; n <= $imprimeAhora; n++)); do
			let m=n+colsTerminal*veces
			echo -n -e "${colorDiagMem[$m]}" | tee -a $informeColor
			printf '%c' "$filaMemMem"  | tee -a $informeColor
			printf '%c' "$filaMemMem" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >> $informe
			filaMemMem=${filaMemMem#?}
			echo -n -e "\e[0m"  | tee -a $informeColor
		done
		echo " M=$marcosMem"  | tee -a $informeColor
		printf " M=$marcosMem\n" >> $informe

		for ((n=1; n<= $imprimeAhora; n++)); do
			let m=n+colsTerminal*veces
			printf '%c' "$filaMemMarc" | tee -a $informeColor
			printf '%c' "$filaMemMarc" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >> $informe
			filaMemMarc=${filaMemMarc#?}
		done
		echo "" | tee -a $informeColor
		printf "\n" >> $informe

		((veces++))
		let longImprimeMem=longImprimeMem-colsTerminal
	done
}



############

muestraTablaPaginas() {

  if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]; then
    filasPaginas=$(
      echo -n -e "    "
      for ((p = 0; p < ${tEjec[$ejecutandoAntiguo]}; p++)); do
        printf " %9s" "${paginas[$ejecutandoAntiguo,$p]}"
      done
    )

    filasMarcos=()
    for ((m = 0; m < ${nMarcos[$ejecutandoAntiguo]}; m++)); do
      filasMarcos[$m]=$(
        r=-1
        if [[ -z ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} ]] || [[ ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} -eq -1 ]]; then
          printf " "
          if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]; then
            printf "%4s" "sM$m"
          else
            printf "%3s" "M$m"
          fi
        else
          printf " "
          if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]; then
            echo -n -e "s"
          fi
          printf "M%-2sf-%3d-%d" "$m" "${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]}" "${procesoTiempoMarcoBitsReloj[$ejecutandoAntiguo,$r,$m]}"
        fi
        echo -n -e "f"

        for ((r = 0; r < ${tEjec[$ejecutandoAntiguo]}; r++)); do
          # Si el marco está vacio
          if [[ -z ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} ]] || [[ ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} -eq -1 ]]; then
            printf " %6s"
            if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]; then
              printf "%4s" "sM$m"
            else
              printf "%3s" "M$m"
            fi
          else
            printf " "
            if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]; then
              echo -n -e "s"
            fi
            printf "M%-2sf-%3d-%d" "$m" "${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]}" "${procesoTiempoMarcoBitsReloj[$ejecutandoAntiguo,$r,$m]}"
          fi
          echo -n -e "f"
        done
      )
    done

    caracterInicialPaginas=0
    caracterInicialMarcos=()
    for ((i = 0; i < ${nMarcos[$ejecutandoAntiguo]}; i++)); do
      caracterInicialMarcos[$i]=0
    done

    informeResumen=$(
      echo -e -n "\e[1;3${colorines[$ejecutandoAntiguo]}m"
      colsTerminal=`tput cols`
      while [[ $caracterInicialPaginas -lt ${#filasPaginas} ]]; do
        caracterDos=0
        for ((caracter = $caracterInicialPaginas; caracterDos < $colsTerminal; caracter++)); do
          echo -n "${filasPaginas:$caracter:1}"
          ((caracterInicialPaginas++))
          ((caracterDos++))
        done
        echo

        for ((mar = 0; mar < ${nMarcos[$ejecutandoAntiguo]}; mar++)); do
          caracterDos=0
          for ((caracter = ${caracterInicialMarcos[$mar]}; caracterDos < $colsTerminal; caracter++)); do
            cadena=${filasMarcos[$mar]}
            letra="${cadena:$caracter:1}"
            if [[ "$letra" == "s" ]]; then
              echo -e -n "\e[4m"
            elif [[ "$letra" == "f" ]]; then
              echo -e -n "\e[24m"
            else
              echo -n "$letra"
              ((caracterDos++))
            fi
            ((caracterInicialMarcos[$mar]++))
          done
          echo -e "\e[24m"
        done

      done
      echo -n -e "\e[0m"
    )

    echo -n -e "$informeResumen" | tee -a $informeColor
    echo -n "$informeResumen" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >>$informe
  fi

  # imprimeNRU
}

###################################################################################################################################

# Muestra un resumen de los tiempos de ejecución y fallos de página de cada proceso al finalizar el algoritmo.
function resumenFinal(){

	clear
	media 'esperaSinLlegada[@]'
	mediaespera=$laMedia
	media 'duracion[@]'
	mediadura=$laMedia
	laMedia=0

	echo -e " T.Espera:    Tiempo que el proceso no ha estado ejecutándose en la CPU desde que entra en memoria hasta que sale" | tee -a $informeColor
	echo -e " Inicio/Fin:  Tiempo de llegada al gestor de memoria del proceso y tiempo de salida del proceso" | tee -a $informeColor
	echo -e " T.Retorno:   Tiempo total de ejecución del proceso, incluyendo tiempos de espera, desde la señal de entrada hasta la salida" | tee -a $informeColor
	echo -e " Fallos Pág.: Número de fallos de página que han ocurrido en la ejecución de cada proceso" | tee -a $informeColor
	echo "" | tee -a $informeColor
	echo "" | tee -a $informeColor
	echo -e " Resumen final con tiempos de ejecución y fallos de página de cada proceso" | tee -a $informeColor
	echo "" | tee -a $informeColor
	echo "" | tee -a $informeColor
	#echo -e "\e[1;32m|----------------------------------------------------------->\e[0m" | tee -a $informeColor
	echo -e " Proc.   T.Espera    Inicio/Fin  T.Retorno   Fallos Pág." | tee -a $informeColor
	
	#					 | Proc. | T.Espera | Inicio/Fin  | T.Retorno | Fallos Pág.
	#					 |----------------------------------------------------------->
	#					 |-------|----------|-------------|-----------|-------------->
	#					  .......|..........|.............|...........|
	#						7          10         12           11
	#                    |..###..|.########.|.#####/#####.|..#######..|.

	echo "T.Espera: Tiempo que el proceso no ha estado ejecutándose en la CPU desde que entra en memoria hasta que sale" >> $informe
	echo "Inicio/Fin:  Tiempo de llegada al gestor de memoria del proceso y tiempo de salida del proceso" >> $informe
	echo "T.Retorno:   Tiempo total de ejecución del proceso, incluyendo tiempos de espera, desde la señal de entrada hasta la salida" >> $informe
	echo "Fallos Pág.:   Número de fallos de página que han ocurrido en la ejecución de cada proceso" >> $informe
	echo "" >> $informe
	echo "" >> $informe
	echo "Resumen final con tiempos de ejecución y fallos de página de cada proceso" >> $informe
	#echo "|----------------------------------------------------------->" >> $informe
		  
	#echo "|" >> $informe
	#echo -e "\e[1;32m|-------|----------|-------------|-----------|-------------->\e[0m" | tee -a $informeColor
	for (( counter=1; counter <= $nProc; counter++ ))
		do
			echo "|" >> $informe
			if [[ $counter -lt 10 ]]
				then
					printf " \e[1;3${colorines[$counter]}mP0$counter\e[0m \e[1;3${colorines[$counter]}m%12u\e[0m \e[1;3${colorines[$counter]}m%10u/%-10u\e[0m \e[1;3${colorines[$counter]}m%2u\e[0m \e[1;3${colorines[$counter]}m%13u \e[0m\n" "${esperaSinLlegada[$counter]}" "${tLlegada[$counter]}" "${salida[$counter]}" "${duracion[$counter]}" "${fallos[$counter]}"  | tee -a $informeColor
					echo "|  Proceso: P0$counter	T.Espera: ${esperaSinLlegada[$counter]}	Inicio/fin: ${tLlegada[$counter]}/${salida[$counter]}	T.Retorno: ${duracion[$counter]}	Fallos Pág.: ${fallos[$counter]}" >> $informe
				else
					                                        printf " \e[1;3${colorines[$counter]}mP0$counter\e[0m \e[1;3${colorines[$counter]}m%12u\e[0m \e[1;3${colorines[$counter]}m%10u/%-10u\e[0m \e[1;3${colorines[$counter]}m%2u\e[0m \e[1;3${colorines[$counter]}m%13u \e[0m\n" "${esperaSinLlegada[$counter]}" "${tLlegada[$counter]}" "${salida[$counter]}" "${duracion[$counter]}" "${fallos[$counter]}"  | tee -a $informeColor

					echo  "|  Proceso: P$counter	T.Espera: ${esperaSinLlegada[$counter]}	Inicio/fin: ${tLlegada[$counter]}/${salida[$counter]}	T.Retorno: ${duracion[$counter]}	Fallos Pág.: ${fallos[$counter]}" >> $informe
			fi
		done
	#echo -e "\e[1;32m|-------|----------|-------------|-----------|--------->\e[0m" | tee -a $informeColor
	#echo "|" >> $informe
	#echo "|----------------------------------------------------------->" >> $informe
	echo -e " Tiempo total transcurrido en ejecutar todos los procesos: $tSistema" | tee -a $informeColor
	echo -e " Media tiempo espera de todos los procesos:  $mediaespera" | tee -a $informeColor
	echo -e " Media tiempo retorno de todos los procesos: $mediadura" | tee -a $informeColor
	echo "   Tiempo total transcurrido en ejecutar todos los procesos: $tSistema" >> $informe
	echo "   Media tiempo espera  de todos los procesos: $mediaespera" >> $informe
	echo "   Media tiempo retorno de todos los procesos: $mediadura" >> $informe

	printf "\n\n"
	read -p " Fin del algoritmo. Pulse INTRO para continuar ↲ "
}



#######################
#        ÚTILES       #
#######################

media(){
	local vector=("${!1}")
	laMedia=0
	local tot

	tot=0
	for (( counter=0; counter< $nProc; counter++ ))
		do
			let laMedia=laMedia+vector[$counter]
			((tot++))
		done
	laMedia=`(echo "scale=3;$laMedia/$tot" | bc -l)`
}

############

# Suma a los procesos que no están ejecutándose (y no han terminado) el tiempo de espera.
sumaTiempoEspera(){
	for (( counter=1; counter <= $nProc; counter++ )); do	
		if [[ $counter -ne $ejecutando || $1 -eq 1 ]] && [[ ${tiempoRestante[$counter]} -ne 0 ]]; then
			let esperaConLlegada[$counter]=esperaConLlegada[$counter]+aumento
		fi
	done
}

############

sumaNPaginas(){
	let nPagEjecutadas[$ejecutando]=nPagEjecutadas[$ejecutando]+nPagAEjecutar[$ejecutando]
	nPagAEjecutar[$ejecutando]=0
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

            if [[ ${nMarcos[$counter]} -le $tamEspacioGrande ]]; then
                        
				enMemoria[$counter]="dentro"
                colaMemoria+=("$counter")
                        
                for marcoNuevo in ${!espaciosMemoria[*]}; do
                    if [[ ${espaciosMemoria[$marcoNuevo]} -ge ${nMarcos[$counter]} ]]; then
                        procesosMemoria[$marcoNuevo]=$counter
                        marcoIntroducido=$marcoNuevo
                    fi
                done
                calcularEspaciosMemoria		# Cada vez que se meta un proceso a memoria, recalculamos sus espacios para ver si caben más.
                
				logEventos+=" Entra el proceso \e[1;3${colorines[$counter]}m${Ref[$counter]}\e[0m a memoria a partir del marco $marcoIntroducido\n"
				logEventosBN+=" Entra el proceso ${Ref[$counter]} a memoria a partir del marco $marcoIntroducido\n"

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
		if [[ ${tLlegada[${colaMemoria[$n]}]} -ne $tSistema ]] && [ "${colaMemoria[$n]}" != "v" ]; then
            cola+=("${colaMemoria[n]}")
			colaMemoria[$n]="v"
		fi
	done
	
	if [[ ${tiempoRestante[$ejecutando]} -ne 0 ]] && [[ $1 -ne 1 ]]; then
        cola+=("$ejecutando")
	fi
	
    for ((n=0; n<${#colaMemoria[@]}; n++)); do
		if [[ ${tLlegada[${colaMemoria[$n]}]} -eq $tSistema ]] && [ "${colaMemoria[$n]}" != "v" ]; then
            cola+=("${colaMemoria[n]}")
			colaMemoria[$n]="v"
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

# Función auxiliar para imprimir la cola de procesos.
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



########################################
#        EJECUCION DEL ALGORIMO        #
########################################


# Función general que engloba la ejecución completa del algoritmo.
function ejecucion(){
	
	
	imprimeHuecosInformes 3 0
	inicializaVariablesEjecucion
	seleccionTipoEjecucion		# El usuario elige el modo en que se ejecutará el algorimo (por eventos, automático, etc).
	imprimeHuecosInformes 2 0

	##### Esto ya es el algoritmo #####

	ordenacion
	primerInstante
	
	# Pasamos al resto de procesos.
	ejecutando=${cola[0]}
	mueveCola

	while [ $seAcaba -eq 0 ]; do
			
		if [ $finalizados -ne $nProc ]; then 	# Cambio de contexto.
			tiemproceso=$tSistema
		fi
 		
        if [ $ejecutando != "vacio" ]; then
            mostrarPantalla=1
			gestionFinalizacionProceso
		    sumaTiempoEspera 0
		    ejecutandoAntiguo=$ejecutando
        else
            mostrarPantalla=0
			((tSistema++))
            aumento=1
            sumaTiempoEspera 0
        fi

		if [ $finalizados -ne $nProc ]; then

			meteEnMemoria
			actualizaCola 2
            if [ ${#cola[@]} -gt 0 ]; then
                
				ejecutando=${cola[0]}
                tiempoProceso[$tSistema]=$ejecutando
				colocarTiemposPaginas
                procesotInicio[$ejecutando]=$tSistema
                mueveCola
				mostrarPantalla=1

                if [[ ${tiempoRestante[$ejecutando]} -ne 0 ]]; then
					logEventos+=" Entra el proceso \e[1;3${colorines[$ejecutando]}m${Ref[$ejecutando]}\e[0m al procesador\n"
					logEventosBN+=" Entra el proceso ${Ref[$ejecutando]} al procesador\n"
			    fi
            else
                ejecutando="vacio"
				if [ $ejecutandoAntiguo == "vacio" ]; then
					mostrarPantalla=0
				fi
            fi
		fi

        volcadoAPantalla

		if [ $finalizados -eq $nProc ]; then	# Si todos los procesos terminados son igual a los procesos introducidos.
			seAcaba=1
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

    esperaConLlegada=(); 			# Tiempo de espera acumulado.
	esperaSinLlegada=();			# Tiempo de espera real.
	tSistema=0;						# Tiempo del sistema.
	salida=();						# Tiempo de retorno.
	duracion=();					# Tiempo que ha estado el proceso desde entró hasta que terminó.
	finalizados=0 					# Número de procesos que han terminado.
	seAcaba=0 						# Para finalizar la ejecución (0 = aún no ha terminado, 1 = ya se terminó).
	ejecutando=0;					# El proceso a ejecutar en cada ronda
	enMemoria=();					# Ver si los procesos están en memoria.
	tiempoRestante=();
	tEjecutando=();					# Cuenta el tiempo ejecutando de cada proceso.
	nPagEjecutadas=();
	nPagAEjecutar=();

	for (( counter = 1; counter <= $nProc; counter++ )); do
		enMemoria[$counter]="fuera"								# "fuera" si no está, "dentro" si está, "salido" si ha terminado.
		let tiempoRestante[$counter]=${tEjec[$counter]}
		let tEjecutando[$counter]=0
		let nPagEjecutadas[$counter]=0
		let nPagAEjecutar[$counter]=0
		esperaConLlegada[$counter]=$tSistema					# Se acumula en su esperaConLlegada el tiempo de llegada del primer proceso en llegar.
	done

	counter=0;						# Inicializamos contador a cero.
	i=0;
	opcionEjec=0;
	mostrarPantalla=1				# El primer instante (T=0) se mostrará siempre.
}

###################################################################################################################################


function primerInstante(){
	
	if [[ ${tLlegada[${ordenados[1]}]} -gt 0 ]]; then			# Si el tiempo de llegada del proceso con menor tiempo de llegada es mayor que 0...

		ejecutando=${ordenados[1]}								# El proceso que se va a ejecutar será el que tenga menor tiempo de llegada.
		aumento=${tLlegada[$ejecutando]}						# 'aumento' toma el valor del tiempo de llegada del primer proceso.
		sumaTiempoEspera 1										# Se suma el tiempo de espera a los demás procesos.
		
		volcadoAPantalla

		tSistema=${tLlegada[$ejecutando]}						# El instante de tiempo mostrado por pantalla será el tLlegada del proceso ejecutándose.
		tiempoProceso[$tSistema]=$ejecutando
		colocarTiemposPaginas
        procesotInicio[$ejecutando]=$tSistema
					
		meteEnMemoria
		actualizaCola 1
		ejecutando=${cola[0]}

		((nCambiosContexto++))
		tCambiosContexto[$nCambiosContexto]=$tSistema
		pEjecutados[$nCambiosContexto]=-1

		if [[ ${tiempoRestante[$ejecutando]} -ne 0 ]]; then
			logEventos+=" Entra el proceso \e[1;3${colorines[$ejecutando]}m${Ref[$ejecutando]}\e[0m al procesador\n"
			logEventosBN+=" Entra el proceso ${Ref[$ejecutando]} al procesador\n"
		fi

		volcadoAPantalla	
		
	else
			
		meteEnMemoria
		actualizaCola 1
					
		ejecutando=${cola[0]}
        tiempoProceso[$tSistema]=$ejecutando
		colocarTiemposPaginas
        procesotInicio[$ejecutando]=$tSistema
		
		if [[ ${tiempoRestante[$ejecutando]} -ne 0 ]]; then
			logEventos+=" Entra el proceso \e[1;3${colorines[$ejecutando]}m${Ref[$ejecutando]}\e[0m al procesador\n"
			logEventosBN+=" Entra el proceso ${Ref[$ejecutando]} al procesador\n"
		fi

		volcadoAPantalla
	fi
	
}




function primerInstanteMAL(){
	
	if [[ ${tLlegada[${ordenados[1]}]} -gt 0 ]]; then			# Si el tiempo de llegada del proceso con menor tiempo de llegada es mayor que 0...

		ejecutando=${ordenados[1]}								# El proceso que se va a ejecutar será el que tenga menor tiempo de llegada.
		aumento=${tLlegada[$ejecutando]}						# 'aumento' toma el valor del tiempo de llegada del primer proceso.
		sumaTiempoEspera 1										# Se suma el tiempo de espera a los demás procesos.
		
		volcadoAPantalla

		# tSistema=${tLlegada[$ejecutando]}						# El instante de tiempo mostrado por pantalla será el tLlegada del proceso ejecutándose.
		# tiempoProceso[$tSistema]=$ejecutando
		# colocarTiemposPaginas
        # procesotInicio[$ejecutando]=$tSistema
		tSistema=${tLlegada[$ejecutando]}						# El instante de tiempo mostrado por pantalla será el tLlegada del proceso ejecutándose.			
		meteEnMemoria
		actualizaCola 2		# antes actualizaCola 1

		# ((nCambiosContexto++))
		# tCambiosContexto[$nCambiosContexto]=$tSistema
		# pEjecutados[$nCambiosContexto]=-1	
	else		
		meteEnMemoria
		actualizaCola 1
	fi
	
	ejecutando=${cola[0]}
    tiempoProceso[$tSistema]=$ejecutando
	colocarTiemposPaginas
    procesotInicio[$ejecutando]=$tSistema

	if [[ ${tiempoRestante[$ejecutando]} -ne 0 ]]; then
		logEventos+=" Entra el proceso \e[1;3${colorines[$ejecutando]}m${Ref[$ejecutando]}\e[0m al procesador\n"
		logEventosBN+=" Entra el proceso ${Ref[$ejecutando]} al procesador\n"
	fi

	volcadoAPantalla
}

###################################################################################################################################

# Acciones que se llevan a cabo cuando un proceso finaliza su ejecución.
function gestionFinalizacionProceso(){

	haFinalizadoProceso=1

    let tSistema=tSistema+tiempoRestante[$ejecutando]
    # El momento de retorno será igual al momento de salida en el reloj.
	let salida[$ejecutando]=$tSistema	

    procesotFin[$ejecutando]=$tSistema

    let duracion[$ejecutando]=salida[$ejecutando]-tLlegada[$ejecutando]
    aumento=${tiempoRestante[$ejecutando]}
    nPagAEjecutar[$ejecutando]=${tiempoRestante[$ejecutando]}
    let tEjecutando[$ejecutando]=tEjecutando[$ejecutando]+${tiempoRestante[$ejecutando]}
    tiempoRestante[$ejecutando]=0
    let finalizados=$finalizados+1
	# El valor "salido" quiere decir que el proceso ha estado en memoria y ha acabado, por lo que se ha sacado de allí.
    enMemoria[$ejecutando]="salido"			
    for marcoNuevo in ${!procesosMemoria[*]}; do
        if [[ ${procesosMemoria[$marcoNuevo]} -eq $ejecutando ]]; then
            unset procesosMemoria[$marcoNuevo]
        fi
    done
    
    calcularEspaciosMemoria
	logEventos+=" El proceso \e[1;3${colorines[$ejecutando]}m${Ref[$ejecutando]}\e[0m ha finalizado y ha transcurrido este tiempo: $aumento\n"
	logEventosBN+=" El proceso ${Ref[$ejecutando]} ha finalizado y ha transcurrido este tiempo: $aumento\n"

	logEventos+=" \e[1;3${colorines[$ejecutando]}m${Ref[$ejecutando]}\e[0m    Tiempo de entrada: $tiemproceso   Tiempo Salida: $tSistema   Tiempo Restante: ${tiempoRestante[$ejecutando]}\n"
	logEventosBN+=" ${Ref[$ejecutando]}    Tiempo de entrada: $tiemproceso   Tiempo Salida: $tSistema   Tiempo Restante: ${tiempoRestante[$ejecutando]}\n"
        
    # ((nCambiosContexto++))
    # tCambiosContexto[$nCambiosContexto]=$tSistema
    # pEjecutados[$nCambiosContexto]=$ejecutando
}

###################################################################################################################################

# Muestra cada instante en el que ocurre un evento importante por pantalla y depende del tipo de ejecución (por eventos, automática, etc.).
function volcadoAPantalla(){

    if [[ $mostrarPantalla -eq 1 ]];then
			
		case "${opcionEjec}" in
		1)	#Ejecución por eventos (pulsa enter para ver el siguiente evento)
			clear
            imprimeCabeceraAlgoritmo
			imprimeLogEventos
            diagramaResumen
			if [[ $haFinalizadoProceso -eq 1 ]];then
            	muestraTablaPaginas
			fi
			haFinalizadoProceso=0
		    sumaNPaginas
			diagramaMemoria
            imprime_barra_tiempo
			read -p " Pulse INTRO para continuar ↲ "
			echo
		;;
		2)	#Ejecución automática (espera un determinado numero de segundos entre cada evento)
			clear
            imprimeCabeceraAlgoritmo
			imprimeLogEventos
            diagramaResumen
            if [[ $haFinalizadoProceso -eq 1 ]];then
            	muestraTablaPaginas
			fi
			haFinalizadoProceso=0
		    sumaNPaginas
			diagramaMemoria
			imprime_barra_tiempo
			sleep $segEsperaEventos	
		;;
		# 3) #Ejecución completa (no espera nada entre pantallas)
		# 	diagramaresumen >> "./$CARPETA_INFORMES/$INFORMECOLOR_NOMBRE"
		# 	diagramaresumen >> "./$CARPETA_INFORMES/$INFORMEBN_NOMBRE"
		# 	clear
		# 	echo -n 'Ejecutando...' >&3
		# 	local cargando
		# 	((cargando=100*numProcesosFinalizados/numProcesos))
		# 	printf "(%d%%)" "$cargando" >&3
		# ;;
		4) # Completa solo resumen (PRUEBA)
			# Crear archivo 'recipiente'
			touch recipiente

			# Redirigir la salida al archivo 'recipiente'
			{
    			imprimeCabeceraAlgoritmo
    			imprimeLogEventos
    			diagramaResumen
    			if [[ $haFinalizadoProceso -eq 1 ]]; then
        		muestraTablaPaginas
    			fi
    			haFinalizadoProceso=0
    			sumaNPaginas
    			diagramaMemoria
    			imprime_barra_tiempo
			} >> recipiente

			# Eliminar el archivo 'recipiente'
			rm recipiente

			if [ $seAcaba -eq 1 ]; then
				resumenFinal
			fi
		;;
		esac
	fi

}

###################################################################################################################################

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
# Si el segundo parámetro es 0, solo se envían a los informes, si no, se visualizan por pantalla.
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

#################

# auxiliar para la linea de tiempo. saber que pagina se ejecuta en cada instante.
function colocarTiemposPaginas(){

	local tiempecillo=$tSistema

	for (( i = 0; i < ${tEjec[$ejecutando]}; i++ )); do
		tiempoPagina[$tiempecillo]=${paginas[$ejecutando,$i]}
		((tiempecillo++))
	done
}





#des: muestra de cada instante, el proceso y la página que se ejecuta
imprime_barra_tiempo(){
	
	local -A barraT
	local -A barraT_BN
	local formato="\e[1;3${colorines[${tiempoProceso[$tiempo]}]}m"
	local anchoprebarra=3
	#local anchopostbarra=$((5+${#marcosTotales}))
    #local anchopostbarra=$marcosMem
	local anchopostbarra=$((5+${#marcosMem}))
	local p=0			# Proceso en el marco actual.
	local aux=0			# Para saber cuántas veces se hace salto de línea si la barra no cabe en la pantalla.
	local l=0			# Línea/fila en la que estamos. Hay 3 -> procesos, páginas y tiempos.
	local columnas=0	# Contador de las columnas (caracteres en el terminal) que se han ocupado.

	for (( tiempo = 0; tiempo <=$tSistema; tiempo++ ))
	do
		# Si hay un proceso.
		if [[ -n ${tiempoProceso[$tiempo]} ]] ;then
			#meter el proceso en una variable (por comodidad)
			p=${tiempoProceso[$tiempo]}
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

		#comprobar si cabe otra unidad
		if [[ $columnas -gt $(($anchura-$anchoUnidadBarras)) ]] || [[ $columnas -gt "124" ]]
		then	#si no cabe, incrementar la linea.
			((aux++))
			#inicializar la nueva linea con 5 espacios para que guarde el margen
			columnas=$((anchoprebarra+2+$anchoUnidadBarras))
			barraT[$aux,0]="    "
			barraT[$aux,1]="    "
			barraT[$aux,2]="    "
		
			barraT_BN[$aux,0]="    "
			barraT_BN[$aux,1]="    "
			barraT_BN[$aux,2]="    "
		fi

	 #Procesos
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

	 #Barra del medio
	 	l=1
		#si si que hay proceso y no es el tiempo actual
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

		#si la pagina está vacía
		if [[ -z ${tiempoPagina[$tiempo]} ]] ;then
			#poner el color de fondo y escribir un -
			barraT[$aux,$l]="${barraT[$aux,$l]}$( printf "%b%*s\e[0m" "$formato" "$anchoUnidadBarras" " " )"

			barraT_BN[$aux,$l]="${barraT_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "-" )"
		else
			#poner el color y escribir la página que ocupa ese marco
			
			if [[ $tiempo -eq $tSistema ]];then
				formato="\e[3${colorines[$p]}m"
			else
				formato="\e[4${colorines[$p]}m\e[30m"		# NUEVO AÑADIDO -> COMPROBAR SI DA PROBLEMAS
			fi
			
			
			
			barraT[$aux,$l]="${barraT[$aux,$l]}$( printf "%b%*s\e[0m" "$formato" "$anchoUnidadBarras" "${tiempoPagina[$tiempo]}" )"

			barraT_BN[$aux,$l]="${barraT_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "${tiempoPagina[$tiempo]}" )"
		fi
	 #Barra de tiempos
	 	l=2;
		#si el tiempo es el de entrada del proceso o es el primero vacío despues de un proceso
		if [[ $tiempo -eq "${procesotInicio[$p]}" ]] || [[ $tiempo = 0 ]] || [[ $tiempo -eq ${procesotFin[$p]} ]]; then
			barraT[$aux,$l]="${barraT[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "$tiempo" )"

			barraT_BN[$aux,$l]="${barraT_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" "$tiempo" )"
		else 
			barraT[$aux,$l]="${barraT[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" " " )"

			barraT_BN[$aux,$l]="${barraT_BN[$aux,$l]}$( printf "%*s" "$anchoUnidadBarras" " " )"
		fi
		

	 #Incrementar el contador en el numero de caracteres que ocupe lo que hay que escribir.
		((columnas=$columnas+$anchoUnidadBarras))

		#si el marco es el último
		if [[ $tiempo -eq $tSistema ]];then
		
			#comprobar si cabe lo que quiero escribir
			if [[ $columnas -gt $(($anchura-$anchopostbarra)) ]]
			then	#si no cabe, incrementar la linea.
				((aux++))
				#inicializar la nueva linea con 5 espacios para que guarde el margen
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

			#contar tambien lo que va a ocupar M=...
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
	echo | tee -a $informeColor
	echo >> $informe		# sustituir por imprimehuecos...
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

	clear
	cabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" Por último, ¿desea abrir el informe? (s/n)"
	read abrirInforme
	
	until [[ $abrirInforme =~ ^[nNsS]$ ]]; do
		printf "\n$_rojo$_b%s$_r%s"	" Entrada no válida." " Escriba 's' (SI) o 'n' (NO): "
		read abrirInforme
	done

	if [[ $abrirInforme =~ ^[sS]$ ]]; then
		clear
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

		echo ""
		echo " Presione cualquier tecla para continuar"
		read -n 1
	else
		echo
		echo -e " \e[1;31mNo se abrirá el informe\e[0m"
		sleep 1
	fi
	cabeceraFinal
}

###################################################################################################################################

# Guarda los datos que se han introducido en el fichero que el usuario desee.
function guardaDatos(){
	
	clear
	cabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los DATOS?"
	printf "\t$_verd%s$_r%s\n"			"[1]" " -> En el fichero de datos por defecto (DatosDefault.txt)"
	printf "\t$_verd%s$_r%s\n\n"		"[2]" " -> En otro fichero de datos"
	read -p " Seleccione opción: " elegirGuardarDatos
    until [[ $elegirGuardarDatos =~ ^[1-2]$ ]]; do
        echo ""
        echo -e -n "\e[1;31mValor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
        read elegirGuardarDatos
    done

	case $elegirGuardarDatos in
		1)	# Muestra la opción 1 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los DATOS?"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> En el fichero de datos por defecto (DatosDefault.txt)"
			printf "\t$_verd%s$_r%s\n\n"		"[2]" " -> En otro fichero de datos"
			sleep 0.3
			;;
		2)	# Muestra la opción 2 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los DATOS?"
			printf "\t$_verd%s$_r%s\n"			"[1]" " -> En el fichero de datos por defecto (DatosDefault.txt)"
			printf "\t$_sel%s%s$_r\n\n"			"[2]" " -> En otro fichero de datos"
			sleep 0.3
			printf "Introduzca el nombre del fichero donde se guardarán los datos de la práctica (sin incluir '.txt'): "
			read nombreOtroFichero
			#clear
			;;
	esac
                        
    ficheroOut="./datosScript/FDatos/DatosDefault.txt"
    touch $ficheroOut
    echo "$tamMem" > $ficheroOut
    echo "$tamPag" >> $ficheroOut

    for (( i = 1; i <= $nProc; i++ )); do
        echo -n "${tLlegada[$i]};" >> $ficheroOut
        #echo -n "${tEjec[$i]};" >> $ficheroOut
        echo -n "${nMarcos[$i]};;" >> $ficheroOut
        for (( n = 0; n < ${maxPags[$i]}; n++ )); do
            echo -n "${direcciones[$i,$n]};" >> $ficheroOut
        done
        echo "" >> $ficheroOut
    done
	cp "${ficheroOut}" "./datosScript/FLast/DatosLast.txt"
    echo -e " Se han guardado los datos en el fichero de salida."
        
    if [[ "$elegirGuardarDatos" == "2" ]]; then
        cp "${ficheroOut}" "./datosScript/FDatos/${nombreOtroFichero}.txt"
	fi

	ultimoficheroman=`echo ${ficheroOut} | cut -d "/" -f4`
	echo "" | tee -a $informeColor

	echo "" >> $informe		
	echo -e " Elija un \e[1;32mfichero\e[0m: " >> $informeColor
	echo -e "\e[1;32m$ultimoficheroman\e[0m" >> $informeColor
	echo -n " Elija un fichero: " >> $informe	
	echo "$ultimoficheroman" >> $informe
	#sleep 0.5
	clear
}

###################################################################################################################################

# Guarda los rangos que se han introducido en el fichero que el usuario desee.
function guardaRangos(){
	
	local nombreFicheroRangos="DatosRangosDefault"
	clear
	cabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los RANGOS?"
	printf "\t$_verd%s$_r%s\n"			"[1]" " -> En el fichero de rangos por defecto (DatosRangosDefault.txt)"
	printf "\t$_verd%s$_r%s\n\n"		"[2]" " -> En otro fichero de rangos"
	read -p " Seleccione opción: " elegirGuardarRangos
    until [[ $elegirGuardarRangos =~ ^[1-2]$ ]]; do
        echo ""
        echo -e -n "\e[1;31mValor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
        read elegirGuardarRangos
    done

	case $elegirGuardarRangos in
		1)	# Muestra la opción 1 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los RANGOS?"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> En el fichero de rangos por defecto (DatosRangosDefault.txt)"
			printf "\t$_verd%s$_r%s\n\n"		"[2]" " -> En otro fichero de rangos"
			sleep 0.3
			;;
		2)	# Muestra la opción 2 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los RANGOS?"
			printf "\t$_verd%s$_r%s\n"		"[1]" " -> En el fichero de rangos por defecto (DatosRangosDefault.txt)"
			printf "\t$_sel%s%s$_r\n\n"		"[2]" " -> En otro fichero de rangos"
			sleep 0.3
			printf "Introduzca el nombre del fichero donde se guardarán los rangos de la práctica (sin incluir '.txt'): "
			read nombreOtroFicheroRangos
			clear
			;;
	esac
				
	ficheroRangos="./datosScript/FRangos/${nombreFicheroRangos}.txt"
	
	echo -n "$minRangoMemoria" > $ficheroRangos
	echo -n "-" >> $ficheroRangos
	echo "$maxRangoMemoria" >> $ficheroRangos
	echo -n "$minRangoTamPagina" >> $ficheroRangos
	echo -n "-" >> $ficheroRangos
	echo "$maxRangoTamPagina" >> $ficheroRangos
	echo -n "$minRangoNumProcesos" >> $ficheroRangos
	echo -n "-" >> $ficheroRangos
	echo "$maxRangoNumProcesos" >> $ficheroRangos
	echo -n "$minRangoTLlegada" >> $ficheroRangos
	echo -n "-" >> $ficheroRangos
	echo "$maxRangoTLlegada" >> $ficheroRangos
	echo -n "$minRangoNumMarcos" >> $ficheroRangos
	echo -n "-" >> $ficheroRangos
	echo "$maxRangoNumMarcos" >> $ficheroRangos
	echo -n "$minRangoNumDirecciones" >> $ficheroRangos
	echo -n "-" >> $ficheroRangos
	echo "$maxRangoNumDirecciones" >> $ficheroRangos
	echo -n "$minRangoValorDireccion" >> $ficheroRangos
	echo -n "-" >> $ficheroRangos
	echo "$maxRangoValorDireccion" >> $ficheroRangos

	cp "${ficheroRangos}" "./datosScript/FLast/DatosRangosLast.txt"

	if [[ "$elegirGuardarRangos" == "2" ]]; then
        cp "${ficheroRangos}" "./datosScript/FRangos/${nombreOtroFicheroRangos}.txt"
	fi
	#sleep 0.5
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
	
	local CAB='\e[48;5;192m'

	clear
	echo
	printf " $CAB%s$_r\n"                   "                                                                              "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                           PRÁCTICA DE CONTROL                            " "  "
	printf " $CAB%s$_r$_b%s$CAB%s$_r\n"     "  " "     FCFS/SJF - Paginación - Reloj - Memoria Continua - No Reubicable     " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  "
	printf " $CAB%s$_r$_i%s$CAB%s$_r\n"     "  " "                        Autora:  Amanda Pérez Olmos                       " "  "
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                         Anterior: César Rodríguez                        " "  "
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

	local CAB='\e[48;5;219m'
	local TEXT='\e[38;5;53m\e[48;5;225m'

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
	local CAB='\e[48;5;192m'

	echo > $informeColor
	printf " $CAB%s$_r\n"                   "                                                                              " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                           PRÁCTICA DE CONTROL                            " "  " >> $informeColor
	printf " $CAB%s$_r$_b%s$CAB%s$_r\n"     "  " "     FCFS/SJF - Paginación - Reloj - Memoria Continua - No Reubicable     " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r$_i%s$CAB%s$_r\n"     "  " "                        Autora:  Amanda Pérez Olmos                       " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                         Anterior: César Rodríguez                        " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                      Sistemas Operativos 2º Semestre                     " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                Grado en Ingeniería Informática (2022-2023)               " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                                                                          " "  " >> $informeColor
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                       Tutor: Jose Manuel Sáiz Diez                       " "  " >> $informeColor
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
	printf " %s%s%s\n"        	"#" "                         Anterior: César Rodríguez                        " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                      Sistemas Operativos 2º Semestre                     " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                Grado en Ingeniería Informática (2022-2023)               " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                       Tutor: Jose Manuel Sáiz Diez                       " "#" >> $informe
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
    printf " %s\n"   			"╔════════════════════════════════════════════════════════════════════════════╗" >> $informeColor  
    printf " %s\n"   			"║ INFORME DE LA PRÁCTICA                                                 FIN ║" >> $informeColor  
    printf " %s\n\n"   			"╚════════════════════════════════════════════════════════════════════════════╝" >> $informeColor 
	# Informe en blanco y negro.
	printf "\n\n" >> $informe  
    printf " %s\n"   			"############################################################################" >> $informe  
    printf " %s\n"   			"# INFORME DE LA PRÁCTICA                                               FIN #" >> $informe  
    printf " %s\n\n"   			"############################################################################" >> $informe	
}

###################################################################################################################################

# Indica al usuario que el tamaño recomendado para la visualización del programa es la pantalla completa.
function imprimeTamanyoRecomendado(){
	
	if [ $anchura -lt 79 ]; then
    	cabecera
		printf "\n%s\n\n"		" Para una correcta visualización del programa se recomienda poner el terminal en pantalla completa."
		printf " Pulse INTRO cuando haya ajustado el tamaño."
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
	clear
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
	#imprimeTamanyoRecomendado
	menuInicio
	sed -i 's/\x0//g' ${informe}			# Limpia los caracteres NULL que se han impreso en el informe.
	sed -i 's/\x0//g' ${informeColor}		# Limpia los caracteres NULL que se han impreso en el informeColor.
}

### Ejecución programa ###
main