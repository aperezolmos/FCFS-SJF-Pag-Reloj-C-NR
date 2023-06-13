#!/bin/bash

###########################
#        VARIABLES        #
###########################
# Cada vez que se dice que una variable es utilizada en X función, quiere decir que se utiliza por primera vez en esa función.
# Luego puede utilizarse en más partes del programa.

	alg="fcfs"

	# Colores
	declare -r _sel='\e[46m'		# Fondo cyan para la selección de opciones. BORRAR O MODIFICAR
	declare -r CAB='\e[48;5;213m' 	# Color cabecera inicio MODIFICAR

	declare -r _r='\033[0m' 	# Reset
	declare -r _b='\033[1m' 	# Bold
	declare -r _i='\033[3m' 	# Italic
	declare -r _u='\033[4m' 	# Underline
	declare -r _s='\033[9m' 	# Strikeout
	declare -r _black='\033[30m'
	declare -r _white='\033[97m'
	declare -r _red='\033[31m'
	declare -r _green='\033[32m'
	declare -r _brown='\033[33m'
	declare -r _blue='\033[34m'
	declare -r _purple='\033[35m'
	declare -r _cyan='\033[36m'
	declare -r _gray='\033[37m'

	# Globales (utilizadas en todo el programa)
	p=0;					# Son los procesos.
	tamMem=0;				# Tamaño de la memoria total.
	marcosMem=0;			# Número de marcos que caben en la memoria
	tamPag=0;				# Tamaño de las páginas.
	ord=0;					# Procesos ordenados según orden de llegada.
	nProc=0; 				# Número total de procesos.

	# Globales auxiliares
	counter=0;				# Utilizado en varias funciones como contador para bucles, etc.
	letra="a";				# Utilizado en varias funciones que piden que se escriba s o n.

	# menuInicio
	menuOpcion=0;			# Utilizada en la función menuInicio, para elegir el algoritmo, la ayuda o salir del programa.

	# asignaColores
	color=0;				# Utilizada para inicializar el vector de colores.

	# seleccionInforme
	informe="./datosScript/Informes/informeBN.txt";					# Nombre del fichero donde se guardará el informe en BLANCO y NEGRO.
	informeColor="./datosScript/Informes/informeCOLOR.txt";			# Nombre del fichero donde se guardará el informe A COLOR.

	#entradaFichero
	ficheroIn=0; 						# Indica el nombre del fichero de entrada.
	posic=0; 							#
	fila=0;								#
	maxFilas=0;							#

	#seleccionFCFS
	segEsperaEventos=0					# Segundos de espera entre cada evento mostrado por pantalla.
	opcionEjec=0						# Modo de ejecución del algoritmo (por eventos, automático, etc).

	#FCFS
	primerproceso=0;					#Proceso que llega primero
	tSistema=0;							##Tiempo actual del sistema
	fef=0;								#Utilizado Bucles
	nProcEnMemoria=0;
	seAcaba=0;
	laMedia=0;

	#vectores
	esperaconllegada=();				#Tiempo de espera de cada proceso incluyendo el tiempo de llegada
	esperaSinLlegada=();				#Tiempo de espera de cada proceso sin incluir el tiempo de llegada
	enMemoria=();						#Vale "fuera" si el proceso no está en memoria, "dentro" si el proceso está en memoria y "salido" si acabó

	colorines=();						#Utilizado en varias funciones para colorear los procesos

	tLlegada=();						#Vector que recoge los tiempos de llegada
	tEjec=();							#Vector que recoge los tiempos de ejecución
	tamProceso=();						#Vector que recoge los tamaños mínimos estructurales
	nMarcos=(); 						#Vector que recoge la cantidad de marcos de cada proceso
	ordenados=();						# Guarda el número de los procesos en orden de llegada.
	npagprocesos=();					#Vector que recoge el número de páginas por proceso
	maxPags=();							#Vector que recoge el número máximo de páginas de los procesos
	declare -A direcciones				#Vector que recoge las direcciones de página de cada proceso
	declare -A paginas					#Vector que recoge las páginas de cada proceso

	#nru
	declare -A paginasUso
	declare -A paginasAux
	declare -A paginasCola
	declare -A paginasHistorial
	declare -A contador
	paginasCambiadas=();
	marcosCambiados=();
	npagaejecutar=();
	npagejecutadas=();
	contadorPag=();
	contadorPagGlob=();
	cola=();

	max=0;
	i=0;
	fichSelect=0;	

	pEjecutados=()       #Alamcena los procesos ejectuados a lo largo del tiempo.
	nCambiosContexto=0;
	tCambiosContexto=()            #Tiempos en los que se producen los cambios de contexto.
	tCambiosContexto[0]=0

	primerproceso=0;			#Proceso que llega primero
	ejecutandoAntiguo=0;

	#declaraciones de nru
	pagina=0;
	ii=0;
	xx=0;
	yy=0;
	zz=0;
	v=0;
	o=0;
	contadorMax=0;
	posicionContadorMax=0;

	# calcularEspacios
	procesosMemoria=()		# Array que contiene los procesos que están actualmente asignados en memoria.
	tamEspacioGrande=0		# Tamaño del espacio vacío más grande en memoria.
	espaciosMemoria=()		# Array que contiene la cantidad de espacios vacíos consecutivos en memoria.

	# Algoritmo Reloj
	declare -A procesoTiempoMarcoPagina			# Valores de los marcos de memoria.
	declare -A procesoTiempoMarcoPuntero		# Orden del puntero.
	declare -A procesoTiempoMarcoBitsReloj		# Valores de bits de reloj.

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
	printf "\t$_green%s$_r%s\n"			"[1]" " -> Ejecutar el algoritmo"
	printf "\t$_green%s$_r%s\n"			"[2]" " -> Visualizar la ayuda"
	printf "\t$_green%s$_r%s\n\n"		"[3]" " -> Salir"
	read -p " Seleccione la opción: " menuOpcion
	
	until [[ $menuOpcion =~ ^[1-3]$ ]]; do
		printf "\n$_red$_b%s$_r%s"	" Valor incorrecto." " Escriba '1', '2', o '3': "
		read menuOpcion
	done

	case $menuOpcion in
		1) # Muestra la opción 1 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_green%s$_r%s\n"			"[2]" " -> Visualizar la ayuda"
			printf "\t$_green%s$_r%s\n\n"		"[3]" " -> Salir"
			sleep 0.3
			;;
		2) # Muestra la opción 2 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?"
			printf "\t$_green%s$_r%s\n"			"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> Visualizar la ayuda"
			printf "\t$_green%s$_r%s\n\n"		"[3]" " -> Salir"
			sleep 0.3
			;;
		3) # Muestra la opción 3 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?"
			printf "\t$_green%s$_r%s\n"			"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_green%s$_r%s\n"			"[2]" " -> Visualizar la ayuda"
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
			seleccionEntrada
			FCFS
			final
			;;
		2)	# Muestra la ayuda.
			clear
			cat ./datosScript/Ayuda/ayuda.txt
			echo ""
			read -p " Pulse INTRO para continuar ↲"
			clear
			menuInicio
			;;
		*)	# Sale del programa.
			sleep 0.3
			clear
			cabeceraFinal
			;;
	esac
}

###################################################################################################################################

# PENDIENTE DE HACER -> menú para ver si el usuario quiere FCFS o SJF
#function seleccionAlgoritmo(){
	#texto
#}

###################################################################################################################################

# Muestra al usuario qué nombres se le darán por defecto a los informes, permitiendo cambiarlos si así se deseara.
function seleccionInforme(){

	clear
	cabecera
	printf "\n%s" 						" Los nombres por defecto de los informes son: informeBN.txt, informeCOLOR.txt"
	printf "\n%s\n" 					" ¿Desea cambiarlos? (s/n)"
	read cambiarInformes
	
	until [[ $cambiarInformes =~ ^[nNsS]$ ]]; do
		printf "\n$_red$_b%s$_r%s"	" Entrada no válida." " Escriba 's' (SI) o 'n' (NO): "
		read cambiarInformes
	done

	if [[ $cambiarInformes =~ ^[sS]$ ]]; then
		
		clear
		cabecera
		printf "\n%s" 					" Los nombres por defecto de los informes son: informeBN.txt, informeCOLOR.txt"
		printf "\n%s\n" 				" ¿Desea cambiarlos? (s/n)"
		printf "\n%s" 					" Introduzca el nombre del informe en BLANCO y NEGRO (sin incluir .txt): "
		read informe
		informe="./datosScript/Informes/${informe}.txt"
		sleep 0.2
		clear
		cabecera
		printf "\n%s" 					" Los nombres por defecto de los informes son: informeBN.txt, informeCOLOR.txt"
		printf "\n%s\n" 				" ¿Desea cambiarlos? (s/n)"
		printf "\n%s" 					" Introduzca el nombre del informe A COLOR (sin incluir .txt): "
		read informeColor
		informeColor="./datosScript/Informes/${informeColor}.txt"
		sleep 0.2
		clear
	else
		printf "\n%s\n" " Se utilizarán los nombres por defecto."
		sleep 1
		clear
	fi
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
	printf "\t$_green%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
	printf "\t$_green%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
	printf "\t$_green%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
	printf "\t$_green%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
	printf "\t$_green%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
	printf "\t$_green%s$_r%s\n"			"[6]" " -> Otro fichero de rangos"
	printf "\t$_green%s$_r%s\n\n"		"[7]" " -> Aleatorio total (DatosRangosAleatorioTotal.txt)"
	read -p " Seleccione una opción: " opcionIn

	until [[ $opcionIn =~ ^[1-6]$ ]]; do
		printf "\n$_red$_b%s$_r%s"	" Valor incorrecto." " Escriba un número del 1 al 6: "
		read opcionIn
	done
	# Se muestra la opción elegida en el propio informe.
	echo "  Seleccione una opción:  " >> $informe
	echo -e "\e[1;38;5;81m  Seleccione una opción: : \e[0m" >> $informeColor
	
	# Muestra resaltada la opción seleccionada para que sea más visual.
	case $opcionIn in
		1)
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_green%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_green%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_green%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_green%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_green%s$_r%s\n\n"		"[6]" " -> Otro fichero de rangos"

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
			printf "\t$_green%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_green%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_green%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_green%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_green%s$_r%s\n\n"		"[6]" " -> Otro fichero de rangos"	
		
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
			printf "\t$_green%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_green%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_sel%s%s$_r\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_green%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_green%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_green%s$_r%s\n\n"		"[6]" " -> Otro fichero de rangos"
		
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
			printf "\t$_green%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_green%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_green%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_sel%s%s$_r\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_green%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_green%s$_r%s\n\n"		"[6]" " -> Otro fichero de rangos"
		
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
			printf "\t$_green%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_green%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_green%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_green%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_sel%s%s$_r\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
			printf "\t$_green%s$_r%s\n\n"		"[6]" " -> Otro fichero de rangos"
		
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
			printf "\t$_green%s$_r%s\n"			"[1]" " -> Introducción manual de datos"
			printf "\t$_green%s$_r%s\n"			"[2]" " -> Fichero de datos de última ejecución (DatosLast.txt)"
			printf "\t$_green%s$_r%s\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_green%s$_r%s\n"			"[4]" " -> Introducción manual de rangos (aleatorio)"
			printf "\t$_green%s$_r%s\n"			"[5]" " -> Fichero de rangos de última ejecución (DatosRangosLast.txt)"
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
	esac
	
	calcularEspacios

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
	clear
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
    	
		printf "\n$_red$_b%s$_r%s"	" ERROR." " El archivo $ficheroIn no existe. "
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
	
	minRangoMemoria=0
	maxRangoMemoria=0
	minRangoTamPagina=0
	maxrangotampagina=0
	minRangoNumProcesos=0
	maxRangoNumProcesos=0
	numeroprocesos=0
	minRangoTLlegada=0
	maxRangoTLlegada=0
	minRangoNumMarcos=0
	maxRangoNumMarcos=0
	minRangoNumDirecciones=0
	maxRangoNumDirecciones=0
	numerodedirecciones=()
	minRangoValorDireccion=0
	maxRangoValorDireccion=0
	contadordirecciones=0
	valordirecciones=0
	
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
	read maxrangotampagina
	echo -n " Introduzca el máximo del rango del número de direcciones por marco de página (nº de direcciones): " >> $informe
	echo -n -e " Introduzca el máximo del rango del número de direcciones por marco de \e[1;33mpágina (nº de direcciones)\e[0m: " >> $informeColor
	until [[ $maxrangotampagina =~ [0-9] && $maxrangotampagina -ge $minRangoTamPagina ]]; do
		echo ""
		echo -e "\e[1;31m El máximo del rango del número de direcciones por marco de página (nº de direcciones) debe ser mayor o igual que $minRangoTamPagina\e[0m"
		echo -n -e " Introduzca el máximo del rango del número de direcciones por marco de \e[1;33mpágina (nº de direcciones)\e[0m: "
		read maxrangotampagina
	done
	
	aleatorioEntre tamPag $minRangoTamPagina $maxrangotampagina
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
	
	aleatorioEntre numeroprocesos $minRangoNumProcesos $maxRangoNumProcesos

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
	
	for (( p=1; p<=$numeroprocesos; p++ )); do
		maxPags[$p]=0;
		aleatorioEntre tLlegada[$p] $minRangoTLlegada $maxRangoTLlegada
		pag=${tEjec[$p]};
		aleatorioEntre nMarcos[$p] $minRangoNumMarcos $maxRangoNumMarcos
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
		
		aleatorioEntre numerodedirecciones[$p] $minRangoNumDirecciones $maxRangoNumDirecciones
		
		for (( pag=0; pag<=${numerodedirecciones[$p]}; pag++ )); do
			aleatorioEntre valordirecciones $minRangoValorDireccion $maxRangoValorDireccion
			direcciones[$p,$pag]=$valordirecciones
			tEjec[$p]=$(($pag+1))
			maxPags[$p]=${tEjec[$p]}
			paginas[$p,$pag]=$((${direcciones[$p,$pag]}/$tamPag))
			clearImprime
		done
		
		clearImprime
	done
	
	p=$(($p - 1))
	nProc=$p

	printf "\n%s\n" " Pulse INTRO para continuar ↲"
	read

	clear
	guardaDatos
	guardaRangos
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores contenido en el fichero de última ejecución (DatosRangosLast.txt).
# 	Relativa a la opción 5: 'Fichero de rangos de última ejecución (DatosRangosLast.txt)' en el menú de selección de entrada de datos.
#	Si se pasa como parámetro 'op6menu' significa que está siendo llamada desde 'entradaFicheroRangos', por lo que leerá los datos del fichero seleccionado.
function entradaUltimaEjecRangos(){
	
	minRangoMemoria=0
	maxRangoMemoria=0
	minRangoTamPagina=0
	maxrangotampagina=0
	minRangoNumProcesos=0
	maxRangoNumProcesos=0
	numeroprocesos=0
	minRangoTLlegada=0
	maxRangoTLlegada=0
	minRangoNumMarcos=0
	maxRangoNumMarcos=0
	minRangoNumDirecciones=0
	maxRangoNumDirecciones=0
	numerodedirecciones=()
	minRangoValorDireccion=0
	maxRangoValorDireccion=0
	contadordirecciones=0
	valordirecciones=0
	
	if [[ $1 == "op6menu" ]]; then
		leeRangosFichero
	else
		leeRangosFichero "ultimaEjecucion"
	fi

	aleatorioEntre marcosMem $minRangoMemoria $maxRangoMemoria
	
	echo "$tamMem" >> $informe
	echo -e "\e[1;32m$tamMem\e[0m" >> $informeColor
	
	aleatorioEntre tamPag $minRangoTamPagina $maxrangotampagina
	
	echo "$tamPag" >> $informe
	echo -e "\e[1;32m$tamPag\e[0m" >> $informeColor
	
	tamMem=$(($marcosMem*$tamPag))
	
	p=1
	aleatorioEntre numeroprocesos $minRangoNumProcesos $maxRangoNumProcesos
	
	for (( p=1; p<=$numeroprocesos; p++ )); do
		maxPags[$p]=0;
		
		aleatorioEntre tLlegada[$p] $minRangoTLlegada $maxRangoTLlegada
		pag=${tEjec[$p]};
		aleatorioEntre nMarcos[$p] $minRangoNumMarcos $maxRangoNumMarcos
		
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
		aleatorioEntre numerodedirecciones[$p] $minRangoNumDirecciones $maxRangoNumDirecciones
		
		for (( pag=0; pag<=${numerodedirecciones[$p]}; pag++ )); do
			
			aleatorioEntre valordirecciones $minRangoValorDireccion $maxRangoValorDireccion
			direcciones[$p,$pag]=$valordirecciones
			tEjec[$p]=$(($pag+1))
			maxPags[$p]=${tEjec[$p]}
			paginas[$p,$pag]=$((${direcciones[$p,$pag]}/$tamPag))
			clearImprime
		done
		clearImprime
	done
	
	p=$(($p - 1))
	nProc=$p
	clear
	guardaDatos
	if [[ $1 == "op6menu" ]]; then
		printf "\n%s\n" " >> Has introducido los datos por fichero." >> $informe
		printf "\n%s\n" " >> Has introducido los datos por fichero." | tee -a $informeColor
	fi
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores contenido en un fichero de rangos.
# 	Relativa a la opción 6: 'Otro fichero de rangos' en el menú de selección de entrada de datos.
function entradaFicheroRangos(){

	clear
	cabecera
	echo "" | tee -a $informeColor

	muestraArchivosRangos
	echo "" >> $informe
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
	ficheroIn=`find datosScript/FRangos -maxdepth 1 -type f -iname "*.txt" | sort | cut -f3 -d"/" | cut -f$fichSelect -d$'\n'` # Guarda el nombre del fichero escogido.
	echo "$ficheroIn" >> $informe
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	
	entradaUltimaEjecRangos "op6menu"
	local rutaDestino="./datosScript/FRangos/$ficheroIn"
	cp "${rutaDestino}" "./datosScript/FLast/DatosRangosLast.txt"
}

###################################################################################################################################

# Función auxiliar. Lee un fichero de rangos y asigna a las variables los valores mínimos y máximos contenidos en él.
# 	Si se pasa como parámetro "ultimaEjecucion", el fichero a leer será 'datosrangos.txt'.
# 	Si no hay parámetros, el fichero a leer será el que haya especificado anteriormente el usuario, almacenado en la variable 'ficheroIn'.
function leeRangosFichero(){
	
	if [[ $1 == "ultimaEjecucion" ]]; then
		
		nombreFicheroRangos="DatosRangosLast"	
		if [ ! -f "./datosScript/FLast/$nombreFicheroRangos" ]; then		# Si el archivo NO existe, se informa del error.
    	
			printf "\n$_red$_b%s$_r%s"	" ERROR." " El archivo $nombreFicheroRangos.txt no existe. "
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
	maxrangotampagina=`head -n 2 $ficheroRangos | tail -n 1 | cut -d "-" -f 2`
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
	clearImprime
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
	
	printf " Número de marcos de página en la memoria:  | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m | Resultado: \e[1;33m%4u\e[0m | \n"   "${minRangoMemoria}" "${maxRangoMemoria}" "${marcosMem}"
	printf " Número de direcciones por marco de página: | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m | Resultado: \e[1;33m%4u\e[0m | \n"   "${minRangoTamPagina}" "${maxrangotampagina}" "${tamPag}"
	printf " Memoria del Sistema:                       |              |              | Resultado: \e[1;33m%4u\e[0m | \n"   "${tamMem}"
	printf " Número de  procesos:                       | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m | Resultado: \e[1;33m%4u\e[0m | \n"   "${minRangoNumProcesos}" "${maxRangoNumProcesos}" "${numeroprocesos}"
	printf " Tiempo de llegada:                         | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m |\n"   "${minRangoTLlegada}" "${maxRangoTLlegada}"
	printf " Número de marcos asociados a cada proceso: | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m |\n"   "${minRangoNumMarcos}" "${maxRangoNumMarcos}"
	printf " Número de direcciones a ejecutar:          | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m |\n"   "${minRangoValorDireccion}" "${maxRangoValorDireccion}"
	printf " Tamaño del proceso (direcciones):          | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m |\n"   "${minRangoNumDirecciones}" "${maxRangoNumDirecciones}"
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
	for (( counter = 1; counter <= $p; counter++ )); do
		color=$(($counter%6))
		color=$(($color+1))
		colorines[$counter]=$color
	done
}

###################################################################################################################################

# Borra la pantalla y llama a la función 'imprimeProcesos'.
function clearImprime(){
	clear
	imprimeProcesos
}

###################################################################################################################################

# Ordena los procesos según su tiempo de llegada.
function ordenacion(){
	local count=1 			# Índice del proceso en el vector 'ordenados'.
	local acabado=0   		# Indica cuándo se ha acabado de ordenar los procesos.
	local numProceso=0		# Número del proceso que está siendo evaluado.
	t=0						# Instante de tiempo.
	while [[ $acabado -eq 0 ]]; do
		for (( numProceso=1; numProceso<=$p; numProceso++ )); do
			if [[ ${tLlegada[$numProceso]} -eq $t ]]; then		# Si el tiempo de llegada del proceso es igual al instante de tiempo evaluado...
				ordenados[$count]=$numProceso					# El número del proceso se mete al vector 'ordenados' en la posición correspondiente.
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

###################################################################################################################################

# Calcula el tamaño del espacio vacío más grande en memoria ('tamEspacioGrande') y guarda la cantidad de espacios vacíos consecutivos en memoria ('espaciosMemoria').
function calcularEspacios(){
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
	#echo "${procesosMemoria[*]}/${espaciosMemoria[*]}"
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

# Imprime por pantalla el algoritmo utilizado, el instante de tiempo actual y las variables globales.
function imprimeTiempo(){
	printf "%s\n" " FCFS/SJF - PAGINACIÓN - RELOJ - MEMORIA CONTINUA - NO REUBICABLE" | tee -a $informeColor
	printf "%s\n" " FCFS/SJF - PAGINACIÓN - RELOJ - MEMORIA CONTINUA - NO REUBICABLE" >> $informe
	printf "%s\t%s\n\n" " T=$tSistema" "Memoria del sistema = $tamMem   Tamaño de página = $tamPag   Número de marcos:  $marcosMem" | tee -a $informeColor
	printf "%s\t%s\n\n" " T=$tSistema" "Memoria del sistema = $tamMem   Tamaño de página = $tamPag   Número de marcos:  $marcosMem" >> $informe
}

###################################################################################################################################

# Pide el tipo de ejecución al usuario.
function seleccionFCFS(){
	clear
	cabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" Seleccione el tipo de ejecución:"
	printf "\t$_green%s$_r%s\n"		"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)"
	printf "\t$_green%s$_r%s\n"		"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)"
	printf "\t$_green%s$_r%s\n"		"[3]" " -> Completa (sin esperas)"
	printf "\t$_green%s$_r%s\n\n"		"[4]" " -> Completa solo resumen"
	read -p " Seleccione la opción: " opcionEjec
	until [[ $opcionEjec =~ ^[1-4]$ ]]; do
		printf "\n$_red$_b%s$_r%s"	" Valor incorrecto." " Escriba '1', '2', '3' o '4: "
		read opcionEjec
	done

	case $opcionEjec in
		1) # Muestra la opción 1 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n"		"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n"		"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n\n"		"[4]" " -> Completa solo resumen" | tee -a $informeColor

			printf "\n$_b%s\n\n"				" ¿Qué opción desea realizar?" >> $informe
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
			printf "\t$_green%s$_r%s\n"		"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n"		"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n\n"		"[4]" " -> Completa solo resumen" | tee -a $informeColor

			printf "\n$_b%s\n\n"				" ¿Qué opción desea realizar?" >> $informe
			printf "\t%s%s\n"					"[1]" " Por eventos (pulsando INTRO en cada cambio de estado)" >> $informe
			printf "\t%s%s\n"					" -> [2]" " Automática (introduciendo cada cuántos segundos cambia de estado) <-" >> $informe
			printf "\t%s%s\n"					"[3]" " Completa (sin esperas)" >> $informe
			printf "\t%s%s\n\n"					"[4]" " Completa solo resumen" >> $informe
			sleep 0.3

			read -p "Introduzca el número de segundos entre cada evento: " segEsperaEventos
			until [[ $segEsperaEventos =~ [0-9] && $segEsperaEventos -gt 0 ]]; do
				printf "\n$_red$_b%s$_r%s"	" Valor incorrecto." " Introduzca un número mayor que 0: "
				read segEsperaEventos
			done
			;;
		3) # Muestra la opción 3 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n"		"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n"		"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n\n"		"[4]" " -> Completa solo resumen" | tee -a $informeColor

			printf "\n$_b%s\n\n"				" ¿Qué opción desea realizar?" >> $informe
			printf "\t%s%s\n"					"[1]" " Por eventos (pulsando INTRO en cada cambio de estado)" >> $informe
			printf "\t%s%s\n"					"[2]" " Automática (introduciendo cada cuántos segundos cambia de estado)" >> $informe
			printf "\t%s%s\n"					" -> [3]" " Completa (sin esperas) <-" >> $informe
			printf "\t%s%s\n\n"					"[4]" " Completa solo resumen" >> $informe
			# Es igual que la opción 2 solo que los segundos de espera entre eventos son 0.
			segEsperaEventos=0
			opcionEjec=2
			sleep 0.3
			;;
		4) # Muestra la opción 4 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n"		"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n"		"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_green%s$_r%s\n"		"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_sel%s%s$_r\n"			"[4]" " -> Completa solo resumen" | tee -a $informeColor

			printf "\n$_b%s\n\n"				" ¿Qué opción desea realizar?" >> $informe
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

# Muestra el principio y final de la línea de tiempo, en el instante T=0.
# 	Si se pasa como parámetro un '1', entonces es porque hay un proceso que llega en ese instante y se ha comenzado a escribir.
# 	Si se pasa cualquier otro parámetro, aún no ha llegado ningún proceso por lo que se muestra vacía.
function lineaDeTiempoCero(){

	if [[ $1 -eq 1 ]]; then
		if [[ $ejecutando -lt 10 ]]; then
  			echo -e "        \e[1;3${colorines[$ejecutando]}mP0$ejecutando\e[0m" | tee -a $informeColor
  			echo "        P0$ejecutando" >> $informe
		else
  			echo -e "        \e[1;3${colorines[$ejecutando]}mP$ejecutando\e[0m" | tee -a $informeColor
  			echo "        P$ejecutando" >> $informe
		fi
		echo -e "    |   |" | tee -a $informeColor
  		echo -e " BT |\e[1;37m0 \e[0m  | T=0" | tee -a $informeColor
  		echo -e "    |  0|" | tee -a $informeColor

		echo "    |   |" >> $informe  
  		echo " BT |   | T=0" >> $informe
  		echo "    |  0|" >> $informe
	else
  		echo "    |   |" | tee -a $informeColor
  		echo -e " BT |   | T=0" | tee -a $informeColor
  		echo "    |  0|" | tee -a $informeColor
  
  		echo "    |   |" >> $informe
  		echo " BT |   | T=0" >> $informe
  		echo "    |  0|" >> $informe
  	fi
}

############

# Imprime la línea de tiempo.
lineaDeTiempo(){

	espacio=0
	i=0
	j=0
	k=0
	mod=0
	espacios=()
	previoCambio=0;
	color_bg=0;
	tiempoCambio=()
	espaciosTotales=()
	espaciosMenos=()
	
	filaTiemProc=""
	filaTiemPag=""
	filaTiemTiem=""
	
	colorProcDiagTiem=();
	colorDiagTiem=();
	n=0;
	
	colsTerminal=`tput cols`
	longImprimeTiem=0;
	veces=0;
	imprimeAhora=0;
	
	for (( n=1; n<=$nProc; n++ )); do
		contadorPag[$n]=0
	done
		
	#Imprime los procesos
	filaTiemProc="    |"
	m=6
	#	colorProcDiagTiem[$m]
	for (( i=0; i<$nCambiosContexto; i++ )); do
			
		let j=i+1
		
		let tiempoCambio[j]=(tCambiosContexto[j]-tCambiosContexto[i])
		let espaciosTotales[j]=tiempoCambio[j]*3
		let espaciosMenos[j]=espaciosTotales[j]-3
	
		if [[ ${pEjecutados[$j]} -eq -1 ]]  #Si vale -1 no se imprime nada.
			then
				for ((n=0; n<${espaciosTotales[$j]}; n++)); do
					filaTiemProc="${filaTiemProc} "
					((m++))
				done
		else
					if [[ ${pEjecutados[$j]} -lt 10 ]]
						then
							filaTiemProc="${filaTiemProc}P0${pEjecutados[$j]}"
							proc=${pEjecutados[$j]}
							colorProcDiagTiem[$m]="\e[1;3${colorines[$proc]}m"
							((m++))
							colorProcDiagTiem[$m]="\e[1;3${colorines[$proc]}m"
                                                        ((m++))
							colorProcDiagTiem[$m]="\e[1;3${colorines[$proc]}m"
                                                        ((m++))
							colorProcDiagTiem[$m]="\e[0m"
						else
							filaTiemProc="${filaTiemProc}P${pEjecutados[$j]}"
							proc=${pEjecutados[$j]}
                                                        colorProcDiagTiem[$m]="\e[1;3${colorines[$proc]}m"
							((m++))
                                                        colorProcDiagTiem[$m]="\e[1;3${colorines[$proc]}m"
                                                        ((m++))
                                                        colorProcDiagTiem[$m]="\e[0m"
					fi
					for ((n=0; n<${espaciosMenos[$j]}; n++))
						do
							filaTiemProc="${filaTiemProc} "
							((m++))
						done
		fi
	done

	if [[ $finalizados -ne $nProc ]]
		then
			if [[ $ejecutando -lt 10 ]]
				then
					filaTiemProc="${filaTiemProc}P0$ejecutando"
				#	proc=${pEjecutados[$j]}
                                        colorProcDiagTiem[$m]="\e[1;3${colorines[$ejecutando]}m"
					((m++))
                                        colorProcDiagTiem[$m]="\e[1;3${colorines[$ejecutando]}m"
                                        ((m++))
					colorProcDiagTiem[$m]="\e[1;3${colorines[$ejecutando]}m"
                                        ((m++))
                                        colorProcDiagTiem[$m]="\e[0m"

				else
					filaTiemProc="${filaTiemProc}P$ejecutando"
				#	 proc=${pEjecutados[$j]}
                                                       # colorProcDiagTiem[$m]="\e[1;3${colorines[$ejecutando]}m"
                                        colorProcDiagTiem[$m]="\e[1;3${colorines[$ejecutando]}m"
                                        ((m++))
                                        colorProcDiagTiem[$m]="\e[1;3${colorines[$ejecutando]}m"
                                        ((m++))

                                                        colorProcDiagTiem[$m]="\e[0m"

			fi
		else
			filaTiemProc="${filaTiemProc}   "
	fi
	filaTiemProc="${filaTiemProc}|"
	
	
	#imprime la fila de las páginas

	filaTiemPag=" BT |"
	
	for (( i=0; i<$nCambiosContexto; i++ ))
		do
			let j=i+1
			if [[ ${pEjecutados[$j]} -eq -1 ]]  #Si vale -1 no se imprime nada.
				then
					for ((n=0; n<${espaciosTotales[$j]}; n++))
						do
							filaTiemPag="${filaTiemPag}-"
						done
				else
					for ((n=0; n<${tiempoCambio[$j]}; n++))
						do
							filaTiemPag="${filaTiemPag}$(printf '%3u' "${paginasHistorial[${pEjecutados[$j]},${contadorPag[${pEjecutados[$j]}]}]}")"
							let contadorPag[${pEjecutados[$j]}]=contadorPag[${pEjecutados[$j]}]+1
						done
			fi
	#			filaTiemPag="${filaTiemPag}"
		done
		if [[ $ejecutando == "vacio" ]] || [[ $finalizados -eq $nProc ]]
		then
			filaTiemPag="${filaTiemPag}  -"
		else
			pag=${paginas[$ejecutando,0]}
			printf -v paginillas "%3d" "$pag"
			filaTiemPag="$filaTiemPag$paginillas"
		fi
		filaTiemPag="$filaTiemPag| T=$tSistema"
  
  
  #imprime la fila de tiempos
  filaTiemTiem="    |"
	#  echo "${tCambiosContexto[*]}"
  forma=$((${#tCambiosContexto[*]}-1))

  for (( n = 0; n <= ${tCambiosContexto[$forma]}; n++ ))
	do
		if [[ " ${tCambiosContexto[@]} " =~ " $n " ]]
			then
				printf -v tiempoOrdenado "%3d" "$n"
			else
				printf -v tiempoOrdenado "%3s" ""
		fi
		filaTiemTiem="$filaTiemTiem$tiempoOrdenado"
	done
	filaTiemTiem="${filaTiemTiem}|"


	
		
	
	#guarda los colores de páginas
	
	for (( n=1; n<=7; n++ ))
		do
			colorDiagTiem[$n]="\e[0m"
		done
	n=6
	for (( i=0; i<$nCambiosContexto; i++ ))
		do
			let j=i+1
	#			color_bg="\e[1;4${colorines[${pEjecutados[$j]}]}m" 
			if [[ ${pEjecutados[$j]} -eq -1 ]]  #Si vale -1 no se imprime nada.
				then
					for ((m=0; m<${espaciosTotales[$j]}; m++))
						do
							colorDiagTiem[$n]="\e[7m"
							((n++))
						done
				else
					for ((m=0; m<${tiempoCambio[$j]}; m++))
						do
							for (( o=1; o<=3; o++ ))
								do
									colorDiagTiem[$n]="\e[1;4${colorines[${pEjecutados[$j]}]}m"
									((n++))
								done
							let contadorPag[${pEjecutados[$j]}]=contadorPag[${pEjecutados[$j]}]+1
						done
			fi
		done
  

		
	longImprimeTiem=`expr length "$filaTiemPag"`
	veces=0;
	imprimeAhora=0;
	
	until [[ $longImprimeTiem -le 0 ]]
		do
			if [[ $longImprimeTiem -le $colsTerminal ]]
				then
					imprimeAhora=$longImprimeTiem
				else
					imprimeAhora=$colsTerminal
			fi
			
			if [[ $veces -ne 0 ]]
				then
					echo ""  | tee -a $informeColor
					echo "" >> $informe
			fi
			for ((n=1; n<= $imprimeAhora; n++))
				do
					let m=n+colsTerminal*veces
					echo -n -e "${colorProcDiagTiem[$m]}" | tee -a $informeColor
					printf '%c' "$filaTiemProc"  | tee -a $informeColor
					printf '%c' "$filaTiemProc" >> $informe
					filaTiemProc=${filaTiemProc#?}
					echo -n -e "\e[0m" | tee -a $informeColor
				done
			echo ""  | tee -a $informeColor
			echo "" >> $informe
			for ((n=1; n<= $imprimeAhora; n++)) 
				do
					let m=n+colsTerminal*veces
					echo -n -e "${colorDiagTiem[$m]}"  | tee -a $informeColor
					printf '%c' "$filaTiemPag"  | tee -a $informeColor
					printf '%c' "$filaTiemPag" >> $informe
					filaTiemPag=${filaTiemPag#?}
					echo -n -e "\e[0m"  | tee -a $informeColor
				done
			echo ""  | tee -a $informeColor
			echo "" >> $informe		
			for ((n=1; n<= $imprimeAhora; n++))
				do
					let m=n+colsTerminal*veces
					echo -n -e "${colorProcDiagTiem[$m]}" | tee -a $informeColor
					printf '%c' "$filaTiemTiem" | tee -a $informeColor
					printf '%c' "$filaTiemTiem" >> $informe
					filaTiemTiem=${filaTiemTiem#?}
					echo -n -e "\e[0m" | tee -a $informeColor
				done
			echo "" | tee -a $informeColor
			echo "" >> $informe
			((veces++))
			let longImprimeTiem=longImprimeTiem-colsTerminal
		done

}



############


diagramaMemoria(){

	#          |P01            P04                           |
	#Memoria:  |--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.|
	#          |0              5                    12       |14


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
      # for palabra in ${!procesosMemoria[*]}; do
              # echo "$palabra < ${procesosMemoria[$palabra]}"
      # done

	filaMemProc="    |"
	#	for (( counter = 1; counter <= $nProc ; counter++ ))
	#		do
	#			ord=${ordenados[$counter]}                      ################################
	#			if [[ ${enMemoria[$ord]} == "dentro" ]]
	#				then
	#					if [[ $ord -lt 10 ]]
	#						then
	#							filaMemProc="${filaMemProc}P0$ord"
	#						else
	#							filaMemProc="${filaMemProc}P$ord"
	#					fi
	#					((marcosPintados++))
	#					for (( m = 2; m <= ${nMarcos[$ord]} ; m++ ))
	#						do
	#							filaMemProc="${filaMemProc}   "
	#							((marcosPintados++))
	#						done
	#					
	#					filaMemProc="${filaMemProc}"
	#			fi
	#		done
	#
	for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ ))
		do
			if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]
				then
					ord=${procesosMemoria[$marcoNuevo]}
					if [[ $ord -lt 10 ]]
                                               then
                                                       filaMemProc="${filaMemProc}P0$ord"
                                               else
                                                       filaMemProc="${filaMemProc}P$ord"
                                        fi
					for (( i = 1; i < ${nMarcos[$ord]}; i++))
					do
						filaMemProc="${filaMemProc}   "
					done
						marcoNuevo=$(($marcoNuevo+${nMarcos[$ord]}-1))
				else
					filaMemProc="${filaMemProc}   "


			fi
		done
	#	if [[ $marcosPintados -lt $marcosMem ]]
	#		then
	#			filaMemProc="${filaMemProc}   "
	#			((marcosPintados++))
	#			until [[ $marcosPintados -eq $marcosMem ]]
	#				do
	#					filaMemProc="${filaMemProc}   "
	#					((marcosPintados++))
	#				done
	#	fi
	filaMemProc="${filaMemProc}|"

	
	
	#Imprime fila de memoria
	marcosPintados=0
	filaMemMem=" BM |"
	#	for (( counter = 1; counter <= $nProc ; counter++ ))
	#		do
	#			ord=${ordenados[$counter]}
	#			if [[ ${enMemoria[$ord]} == "dentro" ]]
	#				then
	#					filaMemMem="${filaMemMem}"
	#					for (( m = 1; m <= ${nMarcos[$ord]} ; m++ ))
	#						do
	#							filaMemMem="${filaMemMem}  -"
	#							((marcosPintados++))
	#						done
	#					
	#					filaMemMem="${filaMemMem}"
	#			fi
	#		done

	for (( m = 0; m < $marcosMem; m++ ))
	do
	if [[ " ${!procesosMemoria[*]} " =~ " $m " ]]
	then
		proc=${procesosMemoria[$m]}
		tiem=$((${tRetorno[$proc]}-${esperaSinLlegada[$proc]}))
		for (( i = 0; i < ${nMarcos[$proc]}; i++ ))
		do
			pag=${procesoTiempoMarcoPagina[$proc,$tiem,$i]}
			if [[ $pag -eq -1 ]] || [[ $proc -ne $ejecutando ]]
			then
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

	#	if [[ $marcosPintados -lt $marcosMem ]]
	#		then
	#			filaMemMem="${filaMemMem}  -"
	#			((marcosPintados++))
	#			until [[ $marcosPintados -eq $marcosMem ]]
	#				do
	#					filaMemMem="${filaMemMem}  -"
	#					((marcosPintados++))
	#				done
	#			filaMemMem="${filaMemMem}"
	#	fi
	filaMemMem="${filaMemMem}|"
	
	
	#Imprime fila de direcciones
	marcosPintados=0
	memPintada=0
	filaMemMarc="    |"
	#	for (( counter = 1; counter <= $nProc ; counter++ ))
	#		do
	#		ord=${ordenados[$counter]}
	#			if [[ ${enMemoria[$ord]} == "dentro" ]]
	#				then
	#					filaMemMarc="${filaMemMarc}$(printf "%3u" "$marcosPintados")"
	#					let marcosPintados=marcosPintados+nMarcos[$ord]
	#					
	#					let espaciosPintar=(nMarcos[$ord]*3)-3
	#					
	#					for (( m = 1; m <= $espaciosPintar ; m++ ))
	#						do
	#							filaMemMarc="${filaMemMarc} "
	#						done
	#					filaMemMarc="${filaMemMarc}"
	#			fi
	#		done
	#
	#	if [[ $marcosPintados -lt $marcosMem ]]
	#		then
	#			filaMemMarc="${filaMemMarc}$(printf "%3u" "$marcosPintados")" 
	#			let faltaPintar=(marcosMem-marcosPintados)*3
	#			let faltaPintar=(faltaPintar)-3
	#			for (( m = 1; m <= $faltaPintar ; m++ ))
	#				do
	#					filaMemMarc="${filaMemMarc} "
	#				done
	#	fi
        for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ ))
                do
                        if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]
                                then   
                                        ord=${procesosMemoria[$marcoNuevo]}
					filaMemMarc="${filaMemMarc}$(printf "%3u" "$marcoNuevo")"
                                        for (( i = 1; i < ${nMarcos[$ord]}; i++))
                                        do
                                                filaMemMarc="${filaMemMarc}   "
                                        done
                                    #            marcoNuevo=$(($marcoNuevo+${nMarcos[$ord]}-1))
			 	 elif [[ -n "${espaciosMemoria[$marcoNuevo]}" ]]
				 then
				        filaMemMarc="${filaMemMarc}$(printf "%3u" "$marcoNuevo")"
                                        for (( i = 1; i < ${espaciosMemoria[$marcoNuevo]}; i++))
                                        do
                                                filaMemMarc="${filaMemMarc}   "
                                        done
				#		[[ ${espaciosMemoria[$marcoNuevo]} -gt 1 ]] \
                                #                && marcoNuevo=$(($marcoNuevo+${espaciosMemoria[$marcoNuevo]}-1))\
				#		|| marcoNuevo=$(($marcoNuevo+${espaciosMemoria[$marcoNuevo]}-2))

			#	 else
                         #               filaMemMarc="${filaMemMarc}   "


                        fi
                done


	filaMemMarc="${filaMemMarc}|"	
	
	#guarda colores procesos
	n=6
	for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ ))
                do
                        if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]
                                then
                                        ord=${procesosMemoria[$marcoNuevo]}
                                        for (( i = 0; i < ${nMarcos[$ord]}; i++))
                                        do
						for (( o=1; o<=3; o++ ))
                                               	do
                                                       colorProcDiagMem[$n]="\e[1;3${colorines[$ord]}m"
                                                       ((n++))
                                               	done

                                        done
                                                marcoNuevo=$(($marcoNuevo+${nMarcos[$ord]}-1))
                     
			else
			n=$((n+3))
		fi
                done
	#	for procesoColores in  ${!procesosMemoria[*]};do
	#		do
	#			ord=${ordenados[$counter]}
	#			if [[ ${enMemoria[$ord]} == "dentro" ]]
	#				then
	#					for (( o=1; o<=3; o++ ))
	#						do
	#							colorProcDiagMem[$n]="\e[1;3${colorines[$ord]}m"
	#							((n++))
	#						done
	#
	#					for (( m = 2; m <= ${nMarcos[$ord]} ; m++ ))
	#						do
	#							let n=n+3
	#						done
	#			fi
	#		done
	

	#guarda colores diagrama
	marcosPintados=0
	n=0
	for (( n=1; n<=8; n++ ))
		do
			colorDiagMem[$n]="\e[0m"
		done
	n=6
        for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ ))
                do
                        if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]
                                then
                                        ord=${procesosMemoria[$marcoNuevo]}
                                        for (( i = 0; i < ${nMarcos[$ord]}; i++))
                                        do
                                                for (( o=1; o<=3; o++ ))
                                                do
                                                       colorDiagMem[$n]="\e[1;4${colorines[$ord]}m"
                                                       ((n++))
                                                done

                                        done
                                                marcoNuevo=$(($marcoNuevo+${nMarcos[$ord]}-1))

			else
                        for (( o=1; o<=3; o++ ))
                                                do
                                                       colorDiagMem[$n]="\e[7m"
                                                       ((n++))
                                                done

			fi
                done
		colorDiagMem[$n]="\e[0m"

	#	for (( counter = 1; counter <= $nProc ; counter++ ))
	#		do
	#			ord=${ordenados[$counter]}
	#			if [[ ${enMemoria[$ord]} == "dentro" ]]
	#				then
	#					for (( o=1; o<=3; o++ ))
	#						do
	#							colorDiagMem[$n]="\e[1;4${colorines[$ord]}m"
	#							((n++))
	#						done
	#					((marcosPintados++))
	#					for (( m = 2; m <= ${nMarcos[$ord]} ; m++ ))
	#						do
	#							for (( o=1; o<=3; o++ ))
	#								do
	#									colorDiagMem[$n]="\e[1;4${colorines[$ord]}m"
	#									((n++))
	#								done
	#							((marcosPintados++))
	#
	#						done
	#			fi
	#		done
	
	#	if [[ $marcosPintados -lt $marcosMem ]]
	#		then
	#			for (( o=1; o<=3; o++ ))
	#				do
	#					colorDiagMem[$n]="\e[107m"
	#					((n++))
	#				done
	#			((marcosPintados++))
	#			until [[ $marcosPintados -eq $marcosMem ]]
	#				do
	#					for (( o=1; o<=3; o++ ))
	#						do
	#							colorDiagMem[$n]="\e[107m"
	#							((n++))
	#						done
	#					((marcosPintados++))
	#				done
	#	fi
	
	#	echo "$filaMemProc" >> $informe
	#	echo "$filaMemMem" >> $informe
	#	echo "$filaMemMarc" >> $informe
	
	longImprimeMem=`expr length "$filaMemMem"`
	veces=0;
	imprimeAhora=0;
	
	until [[ $longImprimeMem -le 0 ]]
		do
			if [[ $longImprimeMem -le $colsTerminal ]]
				then
					imprimeAhora=$longImprimeMem
				else
					imprimeAhora=$colsTerminal
			fi
			
			if [[ $veces -ne 0 ]]
				then
					echo "" | tee -a $informeColor
					printf "\n" >> $informe
			fi
			for ((n=1; n<= $imprimeAhora; n++))
				do
					let m=n+colsTerminal*veces
					echo -n -e "${colorProcDiagMem[$m]}" | tee -a $informeColor
				#	echo -n -e "${colorProcDiagMem[$m]}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >> $informe
					printf '%c' "$filaMemProc" | tee -a $informeColor
					printf '%c' "$filaMemProc" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >> $informe
					filaMemProc=${filaMemProc#?}
					echo -n -e "\e[0m" | tee -a $informeColor
			#		echo -n -e "\e[0m" >> $informe
				done
			echo "" | tee -a $informeColor
			printf "\n" >> $informe

			for ((n=1; n <= $imprimeAhora; n++))
				do
					let m=n+colsTerminal*veces
					echo -n -e "${colorDiagMem[$m]}" | tee -a $informeColor
			#		echo -n -e "${colorDiagMem[$m]}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >> $informe
					printf '%c' "$filaMemMem"  | tee -a $informeColor
					printf '%c' "$filaMemMem" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >> $informe
					filaMemMem=${filaMemMem#?}
					echo -n -e "\e[0m"  | tee -a $informeColor
			#		echo -n -e "\e[0m"  >> $informe
				done
			echo " M=$marcosMem"  | tee -a $informeColor
			printf " M=$marcosMem\n" >> $informe
					
			for ((n=1; n<= $imprimeAhora; n++))
				do
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


###################################################################################################################################

# Muestra la tabla de procesos con sus respectivos parámetros (tiempos de llegada, ejecución, páginas, etc).
function diagramaResumen(){

	#echo -e " \e[1;30;41mResumen:\e[0m\e[30;46mT.lleg|T.ejec|T.Rest|T.Retor\e[0m\e[47m  \e[0m\e[30;44mT.Espera\e[0m\e[47m      \e[0m\e[30;47mEstado\e[0m\e[47m      \e[0m\e[30;41mDirecc-Páginas\e[0m" | tee -a $informeColor
	echo -e " Ref Tll Tej nMar Tesp Tret Trej Mini Mfin Estado           Dirección-Página" | tee -a $informeColor
	
	#	Pro|TLl|TEj|nMar|TEsp|TRet|TRes
	#	...|...|...|....|....|....|....|
	
	for (( counter = 1; counter <= $nProc; counter++ )); do
		
		let ord=${ordenados[$counter]}
			
		if [[ $ord -lt 10 ]]; then
			printf " \e[1;3${colorines[$ord]}mP0$ord %3u %3u %4u" "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
			echo -n " P0$ord	T.lleg: ${tLlegada[$ord]}	T.Ejec: ${tEjec[$ord]}	Marcos: ${nMarcos[$ord]}	T.Espera: ${esperaconllegada[$ord]}  " >> $informe
		else
			printf " \e[1;3${colorines[$ord]}mP$ord %3u %3u %4u" "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
			echo -n " P$ord	T.lleg: ${tLlegada[$ord]}	T.Ejec: ${tEjec[$ord]}	Marcos: ${nMarcos[$ord]}	T.Espera: ${esperaconllegada[$ord]}  " >> $informe
		fi

		#Imprime el tiempo de espera
		if [[ ${tLlegada[$ord]} -gt $tSistema ]]; then		# Si el tiempo de llegada del proceso es mayor que el del sistema es porque aún no ha entrado.
			echo -n -e "    -   " | tee -a $informeColor
		else
			esperaSinLlegada[$ord]=$((${esperaconllegada[$ord]}-${tLlegada[$ord]}))
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
				echo -n -e " \e[1;3${colorines[$ord]}mFinalizado\e[0m       " | tee -a $informeColor
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
			         #         echo -n "|${npagejecutadas[$ord]}|"
			for (( v = 1; v <  ${npagejecutadas[$ord]} ; v++ )); do
					
				echo -ne "\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m" | tee -a $informeColor
				echo -n " " | tee -a $informeColor
				echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
				echo -n " " >> $informe
				((xx++))
			done
		if [[ ord -eq $ejecutando && ${tLlegada[$ord]} -le $tSistema && $finalizados -ne $nProc ]]; then

		    for (( v = 0; v <=  ${npagaejecutar[$ord]} ; v++ )); do
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
 			for (( v = 0; v <  ${npagaejecutar[$ord]} ; v++ )); do
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
	imprimeCola
}

############



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
					printf " \e[1;3${colorines[$counter]}mP0$counter\e[0m \e[1;3${colorines[$counter]}m%12u\e[0m \e[1;3${colorines[$counter]}m%10u/%-10u\e[0m \e[1;3${colorines[$counter]}m%2u\e[0m \e[1;3${colorines[$counter]}m%13u \e[0m\n" "${esperaSinLlegada[$counter]}" "${tLlegada[$counter]}" "${salida[$counter]}" "${duracion[$counter]}" "${cuentafallos[$counter]}"  | tee -a $informeColor
					echo "|  Proceso: P0$counter	T.Espera: ${esperaSinLlegada[$counter]}	Inicio/fin: ${tLlegada[$counter]}/${salida[$counter]}	T.Retorno: ${duracion[$counter]}	Fallos Pág.: ${cuentafallos[$counter]}" >> $informe
				else
					                                        printf " \e[1;3${colorines[$counter]}mP0$counter\e[0m \e[1;3${colorines[$counter]}m%12u\e[0m \e[1;3${colorines[$counter]}m%10u/%-10u\e[0m \e[1;3${colorines[$counter]}m%2u\e[0m \e[1;3${colorines[$counter]}m%13u \e[0m\n" "${esperaSinLlegada[$counter]}" "${tLlegada[$counter]}" "${salida[$counter]}" "${duracion[$counter]}" "${cuentafallos[$counter]}"  | tee -a $informeColor

					echo  "|  Proceso: P$counter	T.Espera: ${esperaSinLlegada[$counter]}	Inicio/fin: ${tLlegada[$counter]}/${salida[$counter]}	T.Retorno: ${duracion[$counter]}	Fallos Pág.: ${cuentafallos[$counter]}" >> $informe
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


############


# Suma a los procesos que no están ejecutándose (y no han terminado) el tiempo de espera.
sumaTiempoEspera(){
	for (( counter=1; counter <= $nProc; counter++ )); do
		
		if [[ $counter -ne $ejecutando || $1 -eq 1 ]] && [[ ${tiempoRestante[$counter]} -ne 0 ]]; then
			let esperaconllegada[$counter]=esperaconllegada[$counter]+aumento
		fi
	done
}


############


nru(){

	pagina=0;
	ii=0;
	xx=0;
	yy=0;
	zz=0;
	v=0;
	o=0;
	contadorMax=0;
	posicionContadorMax=0;
	
	#((tachado[$ejecutandoAntiguo]++))
	yy=$(($zz+${npagejecutadas[$ejecutandoAntiguo]}))
	pagina=${paginasCola[$ejecutandoAntiguo,$yy]}

	while [[ $zz -lt ${npagaejecutar[$ejecutandoAntiguo]} && $pagina != "s" ]]
		do
			#((tachado[$ejecutando]++))

			while [[ $ii -lt ${nMarcos[$ejecutandoAntiguo]} && $zz -lt ${npagaejecutar[$ejecutandoAntiguo]} && $pagina != "s" ]]

				do
				#	((tachado[$ejecutando]++))
					if [[ ${paginasUso[$ejecutandoAntiguo,$ii]} = $pagina ]]
						then
							paginasUso[$ejecutandoAntiguo,$ii]=$pagina
							paginasCambiadas[$zz]=$pagina
							paginasHistorial[$ejecutandoAntiguo,${contadorPagGlob[$ejecutandoAntiguo]}]=$pagina
							let contadorPagGlob[$ejecutandoAntiguo]=contadorPagGlob[$ejecutandoAntiguo]+1
							marcosCambiados[$zz]=$ii
							sumacontadores $ii
							((zz++))
						#	((tachado[$ejecutandoAntiguo]++))
							yy=$(($zz+${npagejecutadas[$ejecutandoAntiguo]}))
							pagina=${paginasCola[$ejecutandoAntiguo,$yy]}
							ii=0
						else
							if [[ ${paginasUso[$ejecutandoAntiguo,$ii]} == "vacio" ]]
								then
									paginasUso[$ejecutandoAntiguo,$ii]=$pagina
									paginasCambiadas[$zz]=$pagina
									paginasHistorial[$ejecutandoAntiguo,${contadorPagGlob[$ejecutandoAntiguo]}]=$pagina
									let contadorPagGlob[$ejecutandoAntiguo]=contadorPagGlob[$ejecutandoAntiguo]+1
									marcosCambiados[$zz]=$ii
									sumacontadores $ii
									fallos[$ejecutandoAntiguo]=$((${fallos[$ejecutandoAntiguo]}+1))
									((zz++))
									yy=$(($zz+${npagejecutadas[$ejecutandoAntiguo]}))
									pagina=${paginasCola[$ejecutandoAntiguo,$yy]}
									ii=0
								else
									((ii++))
							fi
					fi
				done
			ii=0

			if [[ $zz -lt ${npagaejecutar[$ejecutandoAntiguo]} && $pagina != "s" ]]
				then
					calculaNRU $ejecutandoAntiguo
					paginasUso[$ejecutandoAntiguo,$posicionContadorMax]=$pagina
					paginasCambiadas[$zz]=$pagina
					paginasHistorial[$ejecutandoAntiguo,${contadorPagGlob[$ejecutandoAntiguo]}]=$pagina
					let contadorPagGlob[$ejecutandoAntiguo]=contadorPagGlob[$ejecutandoAntiguo]+1
					marcosCambiados[$zz]=$posicionContadorMax
					sumacontadores $posicionContadorMax
					fallos[$ejecutandoAntiguo]=$((${fallos[$ejecutandoAntiguo]}+1))
			fi		

			((zz++))			
			yy=$(($zz+${npagejecutadas[$ejecutandoAntiguo]}))
			pagina=${paginasCola[$ejecutandoAntiguo,$yy]}
		done



	if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
		then
			filasPaginas=$(
			echo -n -e "    "
			for (( p = 0; p < ${tEjec[$ejecutandoAntiguo]}; p++ ))
			do
				printf " %9s" "${paginas[$ejecutandoAntiguo,$p]}"
			done
			)
			#echo
			filasMarcos=()
			for (( m = 0; m < ${nMarcos[$ejecutandoAntiguo]}; m++ ))
			do
				filasMarcos[$m]=$(
				r=-1
		        	if [[ -z ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} ]] || [[ ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} -eq -1 ]]
                                        then
                                                printf " "
                                                if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]
                                		        then
                                               		printf "%4s" "sM$m"
                                        else
                                                printf "%3s" "M$m"

                                       		 fi
						
						
                                        else
                                                 printf " "
                                                 if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]
                                        		then
                                                	echo -n -e "s"
                                        	 fi
                                                 printf "M%-2sf-%3d-%d" "$m" "${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]}" "${procesoTiempoMarcoBitsReloj[$ejecutandoAntiguo,$r,$m]}"
                                 fi
                                 echo -n -e "f"


				for (( r = 0; r < ${tEjec[$ejecutandoAntiguo]}; r++ ))
				do
				#	if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]
				#	then
				#		echo -n -e "s"
				#	fi
					# Si el marco está vacio
					if [[ -z ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} ]] || [[ ${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]} -eq -1 ]]
					then
						printf " %6s"
						                                        if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]
                                        then
                                                printf "%4s" "sM$m"
					else
						printf "%3s" "M$m"
                                        fi

					else
						printf " "
						                                        if [[ ${procesoTiempoMarcoPuntero[$ejecutandoAntiguo,$r]} -eq $m ]]
                                        then
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
			for (( i = 0; i < ${nMarcos[$ejecutandoAntiguo]}; i++ ))
			do
				caracterInicialMarcos[$i]=0
			done
			informeResumen=$(
			echo -e -n "\e[1;3${colorines[$ejecutandoAntiguo]}m"
			colsTerminal=`tput cols`
			while [[ $caracterInicialPaginas -lt ${#filasPaginas} ]]
			do
				caracterDos=0
				for (( caracter = $caracterInicialPaginas; caracterDos < $colsTerminal; caracter++ ))
				do
					echo -n "${filasPaginas:$caracter:1}"
					((caracterInicialPaginas++))
					((caracterDos++))
				done
				echo

				for (( mar = 0; mar < ${nMarcos[$ejecutandoAntiguo]}; mar++ ))
				do
					caracterDos=0
                                	for (( caracter = ${caracterInicialMarcos[$mar]}; caracterDos < $colsTerminal; caracter++ ))
                                		do
							cadena=${filasMarcos[$mar]}
                                        		letra="${cadena:$caracter:1}"
							if [[ "$letra" == "s" ]]
							then
								echo -e -n "\e[4m"
							elif [[ "$letra" == "f" ]]
							then
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
	echo -n "$informeResumen" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >> $informe	
	fi
		
		
		

		#	echo "" | tee -a $informeColor
	#		echo "" >> $informe
			
			
		#	for (( o = 0; o < ${npagaejecutar[$ejecutandoAntiguo]}; o++ ))
		#		do	
		#			echo -e " Se ha introducido la página ${paginasCambiadas[$o]} en el marco ${marcosCambiados[$o]}" | tee -a $informeColor
		#			echo " Se ha introducido la página ${paginasCambiadas[$o]} en el marco ${marcosCambiados[$o]}" >> $informe
		#			
		#		done
				
		#	if [[ $ejecutando -lt 10 ]]
		#		then
					#echo "" | tee -a $informeColor
					#echo "" >> $informe
		#			echo -e " Se han producido ${fallos[$ejecutandoAntiguo]} fallos de pagina en el proceso P0$ejecutandoAntiguo" | tee -a $informeColor
					#echo "" | tee -a $informeColor
					#echo "" >> $informe
		#			echo "  Se han producido $fallos[$ejecutandoAntiguo] fallos de pagina en el proceso P0$ejecutandoAntiguo" >> $informe
					#echo -e " \e[1;32mEstado del proceso\e[0m \e[4${colorines[$ejecutandoAntiguo]}m\e[1;37mP0$ejecutando :\e[0m"
					#echo "" >> $informe
					#echo " Estado del proceso P0$ejecutandoAntiguo :" >> $informe
		#		else
					#echo "" | tee -a $informeColor
					#echo "" >> $informe
		#			echo -e " Se han producido ${fallos[$ejecutandoAntiguo]} fallos de pagina en el proceso P$ejecutandoAntiguo" | tee -a $informeColor
					#echo "" | tee -a $informeColor
					#echo "" >> $informe
		#			echo " Se han producido $fallos[$ejecutandoAntiguo] fallos de pagina en el proceso P$ejecutandoAntiguo" >> $informe
					#echo -e " \e[1;32mEstado del proceso\e[0m \e[4${colorines[$ejecutando]}m\e[1;37mP$ejecutando : \e[0m"
					#echo "" >> $informe
					#echo " Estado del proceso P$ejecutando : " >> $informe
		#	fi
			


	#}
		#	resumenTMedios
			imprimeNRU
			
			#echo " " | tee -a $informeColor
			#echo " " >> $informe
	#fi

	if [[ tiempoRestante[$ejecutandoAntiguo] -eq 0 ]]
		then
			let cuentafallos[$ejecutandoAntiguo]=${fallos[$ejecutandoAntiguo]}
	fi
	#nru
}

############


sumacontadores(){
	for (( o = 0; o < ${nMarcos[$ejecutandoAntiguo]}; o++  ))
		do
			if [[ $o -ne $1 ]]
				then
					contador[$ejecutandoAntiguo,$o]=$((${contador[$ejecutandoAntiguo,$o]}+1))
				else
					contador[$ejecutandoAntiguo,$o]=0
			fi
		done
}


###################################################################################################################################

# Calcula la posición del marco de memoria del proceso '$1' que tiene el contador más alto. -> BORRAR??? no es mi algoritmo
function calculaNRU(){
	contadorMax=0
	posicionContadorMax=0
	for (( o = 0; o < ${nMarcos[$1]}; o++  )); do
		
		if [[ $contadorMax -lt ${contador[$1,$o]} ]]; then
			contadorMax=${contador[$1,$o]}
			posicionContadorMax=$o
		fi
	done
}


###################################################################################################################################

# No modificada mucho pero el function es para buscarla mas facil.
function imprimeNRU(){

	m=0;
	marcosPintados=0;
	memPintada=0;

	coloresNRU=();
	coloresNRUMarc=();

	filaProc=""
	filaProcInf=""
	filaMarc=""
	filaMarcInf=""
	filaPag=""
	filaPagInf=""
	filaDir=""
	filaDirInf=""
	filaCont=""
	filaContInf=""

	colsTerminal=`tput cols`
	longImprimeNRU=0
	
	# Imprime la fila de procesos.
	
	marcosPintados=0

    for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ )); do
                        
		if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]; then			# Si el marco de memoria actual no está vacío...
                                        
			ord=${procesosMemoria[$marcoNuevo]}						# Se guarda el número del marco en la variable 'ord'.
            if [[ $ord -lt 10 ]]; then
                filaProc="${filaProc} P0$ord-"						# Se añade al string 'filaProc' el número del proceso.
            else
                filaProc="${filaProc} P$ord-"
            fi
			# Sea agregan guiones adicionales dependiendo del número de marcos que ocupa el proceso ('nMarcos[$ord]').
            for (( i = 1; i < ${nMarcos[$ord]}; i++)); do
                filaProc="${filaProc}-----"
            done
			# Se actualiza 'marcoNuevo' para saltar los marcos que ya están ocupados por el proceso actual.
            marcoNuevo=$(($marcoNuevo+${nMarcos[$ord]}-1))			
        else							
            filaProc="${filaProc} ----"		# Si el marco de memoria actual está vacío, se agregan guiones indicando los espacios en blanco.
        fi
    done

	# ANTERIOR?? -> borrar si eso.
		#	for (( counter = 1; counter <= $nProc ; counter++ ))
		#		do
		#			ord=${ordenados[$counter]}
		#			if [[ ${enMemoria[$ord]} == "dentro" ]]
		#				then
		#					if [[ $ord -lt 10 ]]
		#						then
		#							filaProc="${filaProc} P0$ord"
		#						else
		#							filaProc="${filaProc} P$ord"
		#					fi
		#					((marcosPintados++))
		#					for (( m = 2; m <= ${nMarcos[$ord]} ; m++ ))
		#						do
		#							filaProc="${filaProc}-----"
		#							((marcosPintados++))
		#						done
		#					
		#					filaProc="${filaProc}-"
		#			fi
		#		done
		#	if [[ $marcosPintados -lt $marcosMem ]]
		#		then
		#			filaProc="${filaProc} NADA"
		#			((marcosPintados++))
		#			until [[ $marcosPintados -eq $marcosMem ]]
		#				do
		#					filaProc="${filaProc}-----"
		#					((marcosPintados++))
		#				done
		#	fi
		#	filaProc="${filaProc}  "
	#
	
	# Imprime la fila de marcos.
	
	marcosPintados=0

	for (( counter = 1; counter <= $nProc ; counter++ )); do
			
		ord=${ordenados[$counter]}
			
		if [[ ${enMemoria[$ord]} == "dentro" ]]; then
					
			calculaNRU $ord		# BORRAR?? NO ES MI ALGORITMO.
			filaMarc="${filaMarc}  M0  "
			((marcosPintados++))
			for (( m = 1; m < 20 ; m++ )); do
				if [[ $m -lt 10 ]]; then
					filaMarc="${filaMarc} M$m  "
				else
					filaMarc="${filaMarc} M$m "
				fi
				((marcosPintados++))
			done
		fi
	done

	if [[ $marcosPintados -lt $marcosMem ]]; then
			
		until [[ $marcosPintados -eq $marcosMem ]]; do	
			filaMarc="  M0   M1   M2   M3   M4   M5   M6   M7   M8   M9   M10  M11  M12  M13  M14  M15  M16  M17  M18  M19"
			((marcosPintados++))		
		done
	fi
	filaMarc="${filaMarc} "
	
	#Imprime la fila de páginas. -> SOLO IMPRIME LA PRIMERA PÁGINA EL RESTO NADA???????????
	
	marcosPintados=0
	
	for (( counter = 1; counter <= $nProc; counter++ )); do
			
		ord=${ordenados[$counter]}
		if [[ $ord -eq $ejecutando ]]; then

			if [[ ${enMemoria[$ord]} == "dentro" ]]; then
				
				if [[ ${paginasUso[$ord,0]} == "vacio" ]]; then
					filaPag="${filaPag}$(printf "%5u" "${paginas[$ord,0]}")"
				else
					filaPag="${filaPag}$(printf "%5u" "${paginasUso[$ord,0]}")"
				fi
				((marcosPintados++))
				for (( m = 1; m < ${nMarcos[$ord]} ; m++ )); do
					
					if [[ ${paginasUso[$ord,$m]} == "vacio" ]]; then
						filaPag="${filaPag}$(printf -- "-----")"
					else
						filaPag="${filaPag}$(printf "%5u" "$paginasUso[$ord,$m]}")"		
					fi
					((marcosPintados++))
				done
			fi
		fi
	done
	
	if [[ $marcosPintados -lt $marcosMem ]]; then
		until [[ $marcosPintados -eq $marcosMem ]]; do
			filaPag="${filaPag}-----"   
			((marcosPintados++))
		done
	fi
	filaPag="${filaPag}|"
		
	# Imprime la fila de las direcciones de memoria.
	
	marcosPintados=0
	memPintada=0

	for (( counter = 1; counter <= $nProc ; counter++ ))
		do
			ord=${ordenados[$counter]}
			if [[ ${enMemoria[$ord]} == "dentro" ]]
				then
					if [[ $memPintada -ge 1000 ]]
						then
						filaDir="${filaDir}$(printf "%3u " "$memPintada")"
						else
						filaDir="${filaDir}$(printf " %3u " "$memPintada")"
					fi
					memPintada=$(($memPintada+${tamProceso[$ord]}))
					((marcosPintados++))
					for (( m = 1; m < ${nMarcos[$ord]} ; m++ ))
						do
							filaDir="${filaDir}     "
							((marcosPintados++))
						done
			fi
		done
		
	if [[ $marcosPintados -lt $marcosMem ]]
		then
			filaDir="${filaDir}$(printf " %3u" "$memPintada")"
			((marcosPintados++))
			until [[ $marcosPintados -eq $marcosMem ]]
				do
					filaDir="${filaDir}     "
					((marcosPintados++))
				done
	fi
	filaDir="${filaDir}|"
	
	
	#Imprime la fila de contadores
	
	marcosPintados=0

	for (( counter = 1; counter <= $nProc ; counter++ ))
		do
			ord=${ordenados[$counter]}
			if [[ ${enMemoria[$ord]} == "dentro" ]]
				then
					if [[ ${paginasUso[$ord,0]} == "vacio" ]]
						then
							filaCont="${filaCont} [--]"
						else
							filaCont="${filaCont}$(printf " [%2u]" "${contador[$ord,0]}")"
					fi
					((marcosPintados++))
					for (( m = 1; m < ${nMarcos[$ord]} ; m++ ))
						do
							if [[ ${paginasUso[$ord,$m]} == "vacio" ]]
								then
									filaCont="${filaCont} [--]"
								else
									filaCont="${filaCont}$(printf " [%2u]" "${contador[$ord,$m]}")"
							fi
							((marcosPintados++))
						done
					
					#filaCont="${filaCont}"
			fi
		done
	if [[ $marcosPintados -lt $marcosMem ]]
		then
			until [[ $marcosPintados -eq $marcosMem ]]
				do
					filaCont="${filaCont} [--]"
					((marcosPintados++))
				done
	fi
	filaCont="${filaCont}  "
	
	n=2
    for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ ))
                do
                        if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]
                                then
                                        ord=${procesosMemoria[$marcoNuevo]}
                                        for (( i = 0; i < ${nMarcos[$ord]}; i++))
                                        do
                                                for (( o=1; o<=5; o++ ))
                                                do
                                                       coloresNRU[$n]="\e[1;3${colorines[$ord]}m"
                                                       ((n++))
                                                done

                                        done
                                                marcoNuevo=$(($marcoNuevo+${nMarcos[$ord]}-1))

                        else
                        n=$((n+5))
                fi
    done

	# ANTIGUO???
		#	for (( counter = 1; counter <= $nProc ; counter++ ))
		#		do
		#			ord=${ordenados[$counter]}
		#			if [[ ${enMemoria[$ord]} == "dentro" ]]
		#				then
		#					for (( o=1; o<=4; o++ ))
		#						do
		#							coloresNRU[$n]="\e[1;3${colorines[$ord]}m"
		#							((n++))
		#						done
		#					for (( m = 2; m <= ${nMarcos[$ord]} ; m++ ))
		#						do
		#							coloresNRU[$n]="\e[1;3${colorines[$ord]}m"
		#							((n++))
		#							for (( o=1; o<=4; o++ ))
		#								do
		#									coloresNRU[$n]="\e[1;3${colorines[$ord]}m"
		#									((n++))
		#								done
		#						done
		#					
		#					coloresNRU[$n]="\e[0m"
		#					((n++))
		#			fi
		#		done
		
		#AÑADIR LO DE COLORES DE MARCOS Y ESO
	
		#	marcosPintados=0
		#	n=2
		#	for (( counter = 1; counter <= $nProc ; counter++ ))
		#		do
		#			ord=${ordenados[$counter]}
		#			if [[ ${enMemoria[$ord]} == "dentro" ]]
		#				then
		#					calculaNRU $ord
		#					if [[ ${paginasUso[$ord,0]} == "vacio" ]]
		#						then
		#							for (( o=1; o<=4; o++ ))
		#								do
		#									coloresNRUMarc[$n]="\e[1;3${colorines[$ord]}m"
		#									((n++))
		#								done
		#						else
		#							if [[ $posicionContadorMax -eq 0 ]]
		#								then
		#									for (( o=1; o<=4; o++ ))
		#										do
		#											coloresNRUMarc[$n]="\e[0;7;4${colorines[$ord]}m"
		#											((n++))
		#										done
		#								else
		#									for (( o=1; o<=4; o++ ))
		#										do
		#											coloresNRUMarc[$n]="\e[1;3${colorines[$ord]}m"
		#											((n++))	
		#										done
		#							fi
		#					fi
		#					for (( m = 1; m < ${nMarcos[$ord]} ; m++ ))
		#						do
		#							coloresNRUMarc[$n]="\e[1;3${colorines[$ord]}m"
		#							((n++))
		#							if [[ ${paginasUso[$ord,0]} == "vacio" ]]
		#								then
		#									for (( o=1; o<=4; o++ ))
		#										do
		#											coloresNRUMarc[$n]="\e[1;3${colorines[$ord]}m"
		#											((n++))
		#										done
		#								else
		#									if [[ $posicionContadorMax -eq $m ]]
		#										then
		#											for (( o=1; o<=4; o++ ))
		#												do
		#													coloresNRUMarc[$n]="\e[1;7;3${colorines[$ord]}m"
		#													((n++))
		#												done
		#										else
		#											for (( o=1; o<=4; o++ ))
		#												do
		#													coloresNRUMarc[$n]="\e[1;3${colorines[$ord]}m"
		#													((n++))
		#												done
		#									fi
		#							fi	
		#						done
		#					
		#					coloresNRUMarc[$n]="\e[0m"
		#					((n++))
		#			fi
		#		done
		#	resumenTMedios
	#
	#	Proceso:     P01------ P03-------------------------- P14------ NADA----- +
	#	Nº Marco:    M0   M1   M0   M1   M2   M3   M4   M70  M0   M1   --   --   +
	#	Página:     |63  |34  |568 |57  |77  |32  |4   |5   |8888|764 |----|----|+
	#	Dir. Mem.:  |0        |200                          |7200     |7400     |+
	#	Contador:    [ 1] [ 0] [ 1] [ 3] [ 6] [ 0] [ 5] [49] [12] [ 0] [--] [--] +

	longImprimeNRU=`expr length "$filaProc"` #FILA PROC O FILA PAG????
	let longImprimeNRU=longImprimeNRU+12
	veces=0;
	imprimeAhora=0;
	
	echo " Proceso:     $filaProc" >> $informe
	echo " Nº Marco:    $filaMarc" >> $informe
	echo " Página:     $filaPag" >> $informe
	echo " Dir. Mem.:   $filaDir" >> $informe
	echo " Contador:    $filaCont" >> $informe
	
	until [[ $longImprimeNRU -le 0 ]]; do

		if [[ $longImprimeNRU -le $colsTerminal ]]; then
			imprimeAhora=$(($longImprimeNRU-2))
		else
			imprimeAhora=$(($colsTerminal-2))
		fi
			
		if [[ $veces -eq 0 ]]; then
					
			let imprimeAhora=imprimeAhora-0
					
			echo -n -e " Proceso  :   " | tee -a $informeColor
			for ((n=1; n<= $imprimeAhora; n++))
						do
							let m=n+colsTerminal*veces
							echo -n -e "${coloresNRU[$m]}" | tee -a $informeColor
							printf '%c' "$filaProc" | tee -a $informeColor
							filaProc=${filaProc#?}
							echo -n -e "\e[0m" | tee -a $informeColor
			done
			echo "" | tee -a $informeColor
					
			echo -n -e " Nº Marco :   " | tee -a $informeColor
			for ((n=1; n<= $imprimeAhora; n++))
						do
							let m=n+colsTerminal*veces
							echo -n -e "${coloresNRU[$m]}" | tee -a $informeColor
							printf '%c' "$filaMarc" | tee -a $informeColor
							filaMarc=${filaMarc#?}
							echo -n -e "\e[0m" | tee -a $informeColor
			done
			echo "" | tee -a $informeColor
					
			echo -n -e " Página   :  " | tee -a $informeColor
			for ((n=1; n<= $imprimeAhora; n++))
						do
							let m=n+colsTerminal*veces
							echo -n -e "${coloresNRU[$m]}" | tee -a $informeColor
							printf '%c' "$filaPag"  | tee -a $informeColor
							filaPag=${filaPag#?}
							echo -n -e "\e[0m" | tee -a $informeColor
			done
			echo ""  | tee -a $informeColor
					
			echo -n -e " Dir. Mem.:   " | tee -a $informeColor
			for ((n=1; n<= $imprimeAhora; n++))
						do
							let m=n+colsTerminal*veces
							echo -n -e "${coloresNRU[$m]}" | tee -a $informeColor
							printf '%c' "$filaDir" | tee -a $informeColor
							filaDir=${filaDir#?}
							echo -n -e "\e[0m" | tee -a $informeColor
			done
			echo ""  | tee -a $informeColor
					
			echo -n -e " Contador :   "  | tee -a $informeColor
			for ((n=1; n<= $imprimeAhora; n++))
						do
							let m=n+colsTerminal*veces
							echo -n -e "${coloresNRU[$m]}"  | tee -a $informeColor
							printf '%c' "$filaCont" | tee -a $informeColor
							filaCont=${filaCont#?}
							echo -n -e "\e[0m"  | tee -a $informeColor
			done
			echo "" | tee -a $informeColor

		else
			echo "" | tee -a $informeColor
			for ((n=1; n<= $imprimeAhora; n++))
						do
							let m=(colsTerminal*veces)+n-12
							echo -n -e "${coloresNRU[$m]}" | tee -a $informeColor
							printf '%c' "$filaProc" | tee -a $informeColor
							filaProc=${filaProc#?}
							echo -n -e "\e[0m"  | tee -a $informeColor
			done
			echo "" | tee -a $informeColor
					
			for ((n=1; n<= $imprimeAhora; n++))
						do
							let m=(colsTerminal*veces)+n-12
							echo -n -e "${coloresNRUMarc[$m]}" | tee -a $informeColor
							printf '%c' "$filaMarc" | tee -a $informeColor
							filaMarc=${filaMarc#?}
							echo -n -e "\e[0m" | tee -a $informeColor
			done
			echo "" | tee -a $informeColor
					
			for ((n=1; n<= $imprimeAhora; n++))
						do
							let m=(colsTerminal*veces)+n-12
							echo -n -e "${coloresNRU[$m]}" | tee -a $informeColor
							printf '%c' "$filaPag" | tee -a $informeColor
							filaPag=${filaPag#?}
							echo -n -e "\e[0m" | tee -a $informeColor
			done
			echo "" | tee -a $informeColor
					
			for ((n=1; n<= $imprimeAhora; n++))
						do
							let m=(colsTerminal*veces)+n-12
							echo -n -e "${coloresNRU[$m]}"  | tee -a $informeColor
							printf '%c' "$filaDir" | tee -a $informeColor
							filaDir=${filaDir#?}
							echo -n -e "\e[0m" | tee -a $informeColor
			done
			echo "" | tee -a $informeColor
					
			for ((n=1; n<= $imprimeAhora; n++))
						do
							let m=(colsTerminal*veces)+n-12
							echo -n -e "${coloresNRU[$m]}" | tee -a $informeColor
							printf '%c' "$filaCont" | tee -a $informeColor
							filaCont=${filaCont#?}
							echo -n -e "\e[0m"  | tee -a $informeColor
			done
			echo "" | tee -a $informeColor
		fi
		((veces++))
		let longImprimeNRU=longImprimeNRU-colsTerminal
	done
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

############


meteEnMemoria(){

	nProcMeter=0;
	paraMeter=();
	n=0;
	prim=0;
	
	fef=0
	while [ $fef -eq 0 ]
		do
			#if [ $position -gt $nProc ]
				#then #Si hemos llegado al final del vector lista
					#position=1
					#ejecutando=${ordenados[$position]}
			#fi
			if [ $exe -eq 0 ]
				then
					let tSistema=tSistema+1 #Si no ha habido ninguna ejecución en la lista anterior ir al siguiente turno
					tiemproceso=1
					aumento=1
					sumaTiempoEspera 1
			fi
			exe=0
			nProcMeter=0
			dejaentraramemoria=1
			for ((posic = 1; posic <= $nProc; posic++ ))
				do
					counter=${ordenados[$posic]}
					if [[ ${tiempoRestante[$counter]} -ne 0 ]] && [[ $tSistema -ge ${tLlegada[$counter]} ]]
						then
							if [[ ${enMemoria[$counter]} == "fuera" ]] && [[ $tSistema -ge ${tLlegada[$counter]} ]] 
							
							#&& [[ $dejaentraramemoria -eq $posic ]]
							
							
								then
									let memUtiliz=memUtiliz+${tamProceso[$counter]}
								#	echo "Aqui ${nMarcos[$counter]} $tamEspacioGrande"
								#	for palabra in ${!procesosMemoria[*]}; do
								#		echo "$palabra < ${procesosMemoria[$palabra]}"
								#	done
								#	if [[ $memUtiliz -gt $tamMem ]]
								#		then
								#			let memUtiliz=memUtiliz-${tamProceso[$counter]}

										if [[ ${nMarcos[$counter]} -le $tamEspacioGrande ]] 
										then

											#ejecutando=$counter;
											((nProcMeter++))
											paraMeter[$nProcMeter]=$counter
											#anadeCola $counter
											enMemoria[$counter]="dentro"
											for marcoNuevo in ${!espaciosMemoria[*]}; do
												if [[ ${espaciosMemoria[$marcoNuevo]} -ge ${nMarcos[$counter]} ]]
												then
													procesosMemoria[$marcoNuevo]=$counter
													marcoIntroducido=$marcoNuevo

												fi
											done
											calcularEspacios
											fef=1
											if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
												then
													if [[ $prim -eq 0 ]]
														then
															prim=1
															#echo "" | tee -a $informeColor
															#echo "" >> $informe
													fi
													if [[ $counter -lt 10 ]]
														then
															echo -e " Entra el proceso \e[1;3${colorines[$counter]}mP0$counter\e[0m a memoria a partir del marco $marcoIntroducido" | tee -a $informeColor
															echo "Entra el proceso P0$counter a memoria a partir del marco $marcoIntroducido" >> $informe
														else
															echo -e " Entra el proceso \e[1;3${colorines[$counter]}mP$counter\e[0m a memoria a partir del marco  $marcoIntroducido" | tee -a $informeColor
															echo " Entra el proceso P$counter a memoria a partir del marco $marcoIntroducido" >> $informe
													fi
											fi
											#dejaentraramemoria=$(($posic+1))
											
										else
												
												break	
										
										
										fi
										
							
										
							#else 
							
								#dejaentraramemoria=$posic
							fi
					fi
				done
			if [[ $fef -eq 0 ]]
				then
					#ejecutando=${ordenados[$position]}
					fef=1
			fi
		done
		
		#if [[ $opcionEjec = 1 ]]
			#then
				#echo "" | tee -a $informeColor
				#echo "" >> $informe
		#fi
}

############


actualizaCola(){
		
	for (( n=1; n<=$nProcMeter; n++ ))
		do
			if [[ ${tLlegada[${paraMeter[$n]}]} -ne $tSistema ]] && [ "${paraMeter[$n]}" != "v" ]
				then
					anadeCola ${paraMeter[$n]}
					paraMeter[$n]="v"
			fi
		done
	
	if [[ ${tiempoRestante[$ejecutando]} -ne 0 ]] && [[ $1 -ne 1 ]]
		then
			anadeCola $ejecutando
	fi
	
	for (( n=1; n<=$nProcMeter; n++ ))
		do
			if [[ ${tLlegada[${paraMeter[$n]}]} -eq $tSistema ]] && [ "${paraMeter[$n]}" != "v" ]
				then
					anadeCola ${paraMeter[$n]}
					paraMeter[$n]="v"
			fi
		done
}

############


mueveCola(){

	u=0
	until [[ ${cola[$u]} == "vacio" ]]; do
		((u++))
	done
	((u--))
	
	for (( n=0; n<$u; n++ )); do
			
		m=$((n+1))
		let cola[$n]=cola[$m]
	done
		
	cola[$n]="vacio"

}

############


anadeCola(){
	u=0;

	u=0
	until [[ ${cola[$u]} == "vacio" ]]
		do
			((u++))
		done
	cola[$u]=$1
	((u++))
	cola[$u]="vacio"
}

###################################################################################################################################

# PROPÓSITO?? -> es llamada en diagramaResumen() pero todo su contenido está comentado y parece no hacer nada útil.
function imprimeCola(){
	u=0
	until [[ ${cola[$u]} == "vacio" ]]; do
		((u++))
	done
	
	# TODO ESTO COMENTADO ANTERIORMENTE


	echo "" | tee -a $informeColor
	echo -n "A continuación:  " >> $informe
	
	if [[ $ejecutando -lt 10 ]]
	then
		echo -n -e "\e[1;3${colorines[$ejecutando]}mP0$ejecutando\e[0m " | tee -a $informeColor
		echo -n "P0$ejecutando " >> $informe
	else
		echo -n -e "\e[1;3${colorines[$ejecutando]}mP$ejecutando\e[0m " | tee -a $informeColor
		echo -n "P$ejecutando " >> $informe
	fi
					
	for ((n=0; n<$u; n++ ))
		do
			if [[ ${cola[$n]} -lt 10 ]]
			then
				echo -n -e " \e[1;3${colorines[${cola[$n]}]}mP0${cola[$n]}\e[0m " | tee -a $informeColor
				echo -n " P0${cola[$n]} " >> $informe
			else
				echo -n -e " \e[1;3${colorines[${cola[$n]}]}mP${cola[$n]}\e[0m " | tee -a $informeColor
				echo -n " P${cola[$n]} " >> $informe
			fi
	done
	echo "" | tee -a $informeColor
	echo "" >> $informe
}

###################################################################################################################################

#No modificada mucho pero el function es para buscarla mas facil.
function FCFS(){
	clear
	printf "\n\n\n" >> $informe
	printf "\n\n\n" >> $informeColor
	
	# Se inicializan por defecto las variables.
	enMemoria=();														# Ver si los procesos están en memoria.
	for (( counter = 1; counter <= $nProc; counter++ )); do
		enMemoria[$counter]="fuera"										# "fuera" si no está, "dentro" si está, "salido" si ha terminado.
	done

	tiempoInicio=();
	for (( counter = 1; counter <= $nProc; counter++ )); do
		let tiempoInicio[$counter]=${tEjec[$counter]}
	done
		
    tachado=();
    for (( counter = 1; counter <= $nProc; counter++ )); do
        let tachado[$counter]=0
    done

	tiempoRestante=();
	for (( counter = 1; counter <= $nProc; counter++ ));do
		let tiempoRestante[$counter]=${tEjec[$counter]}
	done
		
	tEjecutando=();														# Cuenta el tiempo ejecutando de cada proceso.
	for (( i = 1; i <= $nProc; i++ )); do
		let tEjecutando[$i]=0
	done
	
	npagejecutadas=();
	for (( i = 1; i <= $nProc; i++ )); do
		let npagejecutadas[$i]=0
	done
		
	npagaejecutar=();
	for (( i = 1; i <= $nProc; i++ )); do
		let npagaejecutar[$i]=0
	done
			
	i=0; #??
	
	for (( i = 1; i <= $nProc; i++ )); do
		let contadorPagGlob[$i]=0
	done
			
	i=0; #??
	
	cola[0]="vacio"
		
	for (( i = 1; i<= $nProc; i++ )); do
		for (( o = 0; o < ${maxPags[$i]}; o++ )); do
			let paginasCola[$i,$o]=${paginas[$i,$o]}
		done
		o=0
		#paginasCola[$i,$o]="s"
		#let npagejecutadas[$i]=0
	
		for (( ii = 0; ii < ${nMarcos[$i]}; ii++  )); do  		# <= O < NO LO SE
			paginasUso[$i,$ii]="vacio"
			paginasAux[$i,$ii]="vacio"
		done
		ii=0

		fallos[$i]=0
	done
	i=0
	
	esperaconllegada=(); 					#Tiempo de espera acumulado
	esperaSinLlegada=();					#Tiempo de espera real
	primerproceso=${ordenados[1]}			#El proceso que menos tiempo tarda en llegar
	tSistema=0;								#El tiempo que tarda el primer proceso en llegar
	salida=();								#Tiempo de retorno
	duracion=();							#Tiempo que ha estado el proceso desde entró hasta que terminó
	finalizados=0 							#Procesos terminados
	seAcaba=0 								#0 = aun no ha terminado, 1 = ya se terminó
	ejecutando=0;							#El proceso a ejecutar en cada ronda
	cuentafallos=();						#Cuenta los fallos de cada proceso
	aejecutar=();
	impordenado=();
	
	for (( counter = 1; counter <= $nProc; counter++ )); do
		let aejecutar[$counter]=0
		let impordenado[$counter]=0
	done
		
	counter=0;								#Inicializamos contador a cero
	exe=1;									#Ejecuciones que ha habido en una vuelta de lista
	position=0;								#Posición del porceso que se debe ejecutar ahora
	fin=0;
	indicador=0;
	i=0;
	memUtiliz=0;							#memoria utilizada
	opcionEjec=0;

	seleccionFCFS		# El usuario elige el modo en que se ejecutará el algorimo (por eventos, automático, etc).
	clear
	sleep 1
	printf "\n\n" >> $informe
	printf "\n\n" >> $informeColor

	for (( i = 0; i < numprocesos; i++ )); do
		let tejecutando[$i]=0
	done
	i=0;

	#Se acumula en su esperaconllegada el tiempo de llegada del primer proceso en llegar
	for (( fef=1; fef<= $nProc; fef++ )); do
		esperaconllegada[$fef]=$tSistema
	done

	##### Esto ya es el algoritmo #####

	ordenacion

	if [[ ${tLlegada[${ordenados[1]}]} -gt 0 ]]; then			# Si el tiempo de llegada del proceso con menor tiempo de llegada es mayor que 0...

		ejecutando=${ordenados[1]}								# El proceso que se va a ejecutar será el que tenga menor tiempo de llegada.
		aumento=${tLlegada[$primerproceso]}						# 'aumento' toma el valor del tiempo de llegada del primer proceso (?).
		sumaTiempoEspera 1										# Se suma el tiempo de espera a los demás procesos.
		if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]; then
			clear
			imprimeTiempo
			diagramaResumen
			imprimeNRU
			diagramaMemoria
			lineaDeTiempoCero 0

			if [[ $opcionEjec = 2 ]]; then
				sleep $segEsperaEventos
			else
				read -p " Pulse INTRO para continuar"
			fi
		fi
		tSistema=${tLlegada[$ejecutando]}						# El instante de tiempo mostrado por pantalla será el tLlegada del proceso ejecutándose.
		clear
			
		if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]; then 
			imprimeTiempo
		fi
			
		meteEnMemoria
		actualizaCola 1
		ejecutando=${cola[0]}
		#mueveCola

		((nCambiosContexto++))
		tCambiosContexto[$nCambiosContexto]=$tSistema
		pEjecutados[$nCambiosContexto]=-1
			
		if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]; then 

			if [[ ${tiempoRestante[$ejecutando]} -ne 0 ]]; then
					if [[ $ejecutando -lt 10 ]]; then
						echo -e " Entra el proceso \e[1;3${colorines[$ejecutando]}mP0$ejecutando\e[0m al procesador" | tee -a $informeColor
						echo " Entra el proceso P0$ejecutando al procesador" >> $informe
					else
						cho -e " Entra el proceso \e[1;3${colorines[$ejecutando]}mP$ejecutando\e[0m al procesador" | tee -a $informeColor
						echo " Entra el proceso P$ejecutando al procesador" >> $informe
					fi
			fi
			diagramaResumen
			imprimeNRU
			diagramaMemoria
				#diagramaTiempo
			lineaDeTiempo
			if [[ $opcionEjec = 2 ]]; then
				sleep $segEsperaEventos
			else
				read -p " Pulse INTRO para continuar"
			fi 
		fi
	else
			if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]; then 
				imprimeTiempo
			fi
			
			meteEnMemoria
			actualizaCola 1
					
			ejecutando=${cola[0]}
			#mueveCola
			
			if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]; then 
				if [[ ${tiempoRestante[$ejecutando]} -ne 0 ]]; then
					if [[ $ejecutando -lt 10 ]]; then
						echo -e " Entra el proceso \e[1;3${colorines[$ejecutando]}mP0$ejecutando\e[0m al procesador" | tee -a $informeColor
						echo " Entra el proceso P0$ejecutando al procesador" >> $informe
					else
						echo -e " Entra el proceso \e[1;3${colorines[$ejecutando]}mP$ejecutando\e[0m al procesador" | tee -a $informeColor
						echo " Entra el proceso P$ejecutando al procesador" >> $informe
					fi
				fi
				diagramaResumen
				imprimeNRU
				diagramaMemoria
				#diagramaTiempo
				lineaDeTiempoCero 1
				if [[ $opcionEjec = 2 ]]; then
					sleep $segEsperaEventos
				else
					read -p " Pulse INTRO para continuar"
		
				fi 
			fi
	fi
	
	ejecutando=${cola[0]}
	mueveCola
	
	while [ $seAcaba -eq 0 ]; do
		
		if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]; then
			clear
		fi
			#ejecutando=${ordenados[$position]}
			
		if [ $finalizados -ne $nProc ]; then 	# Cambio de contexto.
			tiemproceso=$tSistema
		fi
 			
			let tSistema=tSistema+tiempoRestante[$ejecutando]
			let salida[$ejecutando]=$tSistema	#El momento de retorno será igual al momento de salida en el reloj
			let duracion[$ejecutando]=salida[$ejecutando]-tLlegada[$ejecutando]
			fin=1
			indicador=1
			aumento=${tiempoRestante[$ejecutando]}
			npagaejecutar[$ejecutando]=${tiempoRestante[$ejecutando]}
			let tEjecutando[$ejecutando]=tEjecutando[$ejecutando]+${tiempoRestante[$ejecutando]}
			tiempoRestante[$ejecutando]=0
			exe=1
			let finalizados=$finalizados+1
			let memUtiliz=memUtiliz-${tamProceso[$ejecutando]}
			enMemoria[$ejecutando]="salido"			#El valor "salido" quiere decir que el proceso ha estado en memoria y ha acabado, por lo que se ha sacado de allí
			for marcoNuevo in ${!procesosMemoria[*]}; do
				if [[ ${procesosMemoria[$marcoNuevo]} -eq $ejecutando ]]; then
					unset procesosMemoria[$marcoNuevo]
				fi
			done
					calcularEspacios
					if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
						then
							imprimeTiempo
							#echo ""
							if [[ $ejecutando -lt 10 ]]
								then
									echo -e " El proceso \e[1;3${colorines[$ejecutando]}mP0$ejecutando\e[0m ha finalizado y ha transcurrido este tiempo: $aumento" | tee -a $informeColor
									echo " El proceso P0$ejecutando ha finalizado y ha transcurrido este tiempo: $aumento" >> $informe
								else
									echo -e " El proceso \e[1;3${colorines[$ejecutando]}mP$ejecutando\e[0m ha finalizado y ha transcurrido este tiempo: $aumento" | tee -a $informeColor
									echo " El proceso P$ejecutando ha finalizado y ha transcurrido este tiempo: $aumento" >> $informe
							fi
					fi
			
			
			((nCambiosContexto++))
			tCambiosContexto[$nCambiosContexto]=$tSistema
			pEjecutados[$nCambiosContexto]=$ejecutando

			#Util para saber en cada pasada cuantos procesos hay en memoria
			nProcEnMemoria=0;
			for (( counter = 1; counter <= $nProc; counter++ ))
				do
					if [[ ${enMemoria[$counter]} == "dentro" ]]
						then
							let nProcEnMemoria=nProcEnMemoria+1
					fi
				done


					if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
						then
							#echo "" | tee -a $informeColor
							#echo "" >> $informe
							if [[ $ejecutando -lt 10 ]]
								then
									echo -e " \e[1;3${colorines[$ejecutando]}mP0$ejecutando\e[0m    Tiempo de entrada: $tiemproceso Tiempo Salida: $tSistema Tiempo Restante: ${tiempoRestante[$ejecutando]}" | tee -a $informeColor
									echo " P0$ejecutando    Tiempo de entrada: $tiemproceso Tiempo Salida: $tSistema Tiempo Restante: ${tiempoRestante[$ejecutando]}" >> $informe
								else
									echo -e " \e[1;3${colorines[$ejecutando]}mP$ejecutando\e[0m    Tiempo de entrada: $tiemproceso Tiempo Salida: $tSistema Tiempo Restante: ${tiempoRestante[$ejecutando]}" | tee -a $informeColor
									echo " P$ejecutando    Tiempo de entrada: $tiemproceso Tiempo Salida: $tSistema Tiempo Restante: ${tiempoRestante[$ejecutando]}" >> $informe
							fi
					fi
			

			sumaTiempoEspera 0 #Función sumaTiempoEspera; aumenta el tiempo de espera acumulado de cada proceso

			ejecutandoAntiguo=$ejecutando

			#let position=position+1
			
			if [ $finalizados -ne $nProc ]
				then
					meteEnMemoria
					actualizaCola 2
				#	echo "$ejecutando"
					ejecutando=${cola[0]}
				#	echo "$ejecutando"
				#	read akjsdashdkadhf
					mueveCola
			fi

			if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
				then
					if [[ ${tiempoRestante[$ejecutando]} -ne 0 ]]
						then
							if [[ $ejecutando -lt 10 ]]
								then
									echo -e " Entra el proceso \e[1;3${colorines[$ejecutando]}mP0$ejecutando\e[0m al procesador" | tee -a $informeColor
									echo " Entra el proceso P0$ejecutando al procesador" >> $informe
								else
									echo -e " Entra el proceso \e[1;3${colorines[$ejecutando]}mP$ejecutando\e[0m al procesador" | tee -a $informeColor
									echo " Entra el proceso P$ejecutando al procesador" >> $informe
							fi
					fi
					diagramaResumen
			fi
			
			
			nru                ############################################################################## I # M # P # O # R # T # A # N # T # E ##############################################################################
			sumaNPaginas

			if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
				then
					diagramaMemoria
					#diagramaTiempo
					lineaDeTiempo
			fi

			
			if [ $finalizados -ne $nProc ]
				then
					if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
						then
							if [[ $opcionEjec = 2 ]]
							then
								sleep $segEsperaEventos
							else
								read -p " Pulse INTRO para continuar"
		
							fi 
					fi
			fi
			if [ $finalizados -eq $nProc ]
				then #Si todos los procesos terminados son igual a los procesos introducidos
					seAcaba=1
			fi
	done

	# Se da valor a esperaSinLlegada.
	for (( counter=0; counter < $nProc; counter++ )); do
		let esperaSinLlegada[$counter]=esperaconllegada[$counter]-tLlegada[$counter]
	done
		
	if [[ $opcionEjec = 1 ]]; then
		read -p " Pulse INTRO para continuar ↲ "
	elif [[ $opcionEjec = 2 ]]; then
		sleep $segEsperaEventos	
	fi 
	resumenFinal
}

############


sumaNPaginas(){
	let npagejecutadas[$ejecutando]=npagejecutadas[$ejecutando]+npagaejecutar[$ejecutando]
	npagaejecutar[$ejecutando]=0
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
	printf "\n$_cyan$_b%s\n\n$_r"		" Por último, ¿desea abrir el informe? (s/n)"
	read abrirInforme
	
	until [[ $abrirInforme =~ ^[nNsS]$ ]]; do
		printf "\n$_red$_b%s$_r%s"	" Entrada no válida." " Escriba 's' (SI) o 'n' (NO): "
		read abrirInforme
	done

	if [[ $abrirInforme =~ ^[sS]$ ]]; then
		clear
		printf "\n\n%s\n" "  ¿Con qué editor desea abrir el informe?"
		echo -e "  \e[1;32mnano\e[0m, \e[1;33mvi\e[0m, \e[1;34m[vim]\e[0m, \e[1;35mgvim\e[0m, \e[1;32mgedit\e[0m, \e[1;33matom\e[0m, \e[1;34mcat (a color)\e[0m, \e[1;31motro\e[0m"
		echo "  Después de visualizarlo vuelva a esta ventana y terminará el algoritmo"
		read -p "  Seleccione: " editor
		until [[ $editor = "nano" ||  $editor = "vi" ||  $editor = "vim" ||  $editor = "gvim" ||  $editor = "gedit" ||  $editor = "atom" || $editor = "cat" || $editor = "otro" || $editor = "" ]]
			do
				echo -e "  \e[1;31mPor favor escoja uno de la lista\e[0m"
				echo " ¿Con qué editor desea abrir el informe?"
				echo "  \e[1;32mnano\e[0m, \e[1;33mvi\e[0m, \e[1;34m[vim]\e[0m, \e[1;35mgvim\e[0m, \e[1;32mgedit\e[0m, \e[1;33matom\e[0m, \e[1;34mcat (a color)\e[0m, \e[1;31motro\e[0m"
				read -p "  Seleccione: " editor
		done
				
		case $editor in
			"nano")
				nano $informe
				echo ""
				echo " Presione cualquier tecla para continuar"
				read -n 1;;
			"vi")
				vi $informe
				echo ""
				echo " Presione cualquier tecla para continuar"
				read -n 1;;
			"vim")
				vim $informe
				echo ""
				echo " Presione cualquier tecla para continuar"
				read -n 1;;
			"gvim")
				gvim $informe
				echo ""
				echo " Presione cualquier tecla para continuar"
				read -n 1;;
			"gedit")
				gedit $informe
				echo ""
				echo " Presione cualquier tecla para continuar"
				read -n 1;;
			"atom")
				atom $informe
				echo ""
				echo " Presione cualquier tecla para continuar"
				read -n 1;;
			"cat")
				clear
				cat $informeColor
				echo ""
				echo " Presione cualquier tecla para continuar"
				read -n 1;;
			"otro")
				echo 
				echo -e "  \e[1;31mAl escoger otro editor tenga en cuenta que debe tenerlo instalado, si no dará error\e[0m"
				read -p "  Introduzca: " editor
				echo
				$editor $nombre".txt"
				echo ""
				echo " Presione cualquier tecla para continuar"
				read -n 1;;
			*)	# Opción por defecto.
				vim $informe
				echo ""
				echo " Presione cualquier tecla para continuar"
				read -n 1;;
		esac
	else
		echo
		echo -e "  \e[1;31mNo se abrirá el informe\e[0m"
		sleep 1
	fi
	clear
	cabeceraFinal
}

###################################################################################################################################

# Guarda los datos que se han introducido en el fichero que el usuario desee.
function guardaDatos(){
	
	clear
	cabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los DATOS?"
	printf "\t$_green%s$_r%s\n"			"[1]" " -> En el fichero de datos por defecto (DatosDefault.txt)"
	printf "\t$_green%s$_r%s\n\n"		"[2]" " -> En otro fichero de datos"
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
			printf "\t$_green%s$_r%s\n\n"		"[2]" " -> En otro fichero de datos"
			sleep 0.3
			;;
		2)	# Muestra la opción 2 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los DATOS?"
			printf "\t$_green%s$_r%s\n"			"[1]" " -> En el fichero de datos por defecto (DatosDefault.txt)"
			printf "\t$_sel%s%s$_r\n\n"			"[2]" " -> En otro fichero de datos"
			sleep 0.3
			printf "Introduzca el nombre del fichero donde se guardarán los datos de la práctica (sin incluir '.txt'): "
			read nombreOtroFichero
			clear
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
	sleep 1
	clear
}

###################################################################################################################################

# Guarda los rangos que se han introducido en el fichero que el usuario desee.
function guardaRangos(){
	
	local nombreFicheroRangos="DatosRangosDefault"
	clear
	cabecera
	printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los RANGOS?"
	printf "\t$_green%s$_r%s\n"			"[1]" " -> En el fichero de rangos por defecto (DatosRangosDefault.txt)"
	printf "\t$_green%s$_r%s\n\n"		"[2]" " -> En otro fichero de rangos"
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
			printf "\t$_green%s$_r%s\n\n"		"[2]" " -> En otro fichero de rangos"
			sleep 0.3
			;;
		2)	# Muestra la opción 2 seleccionada.
			clear
			cabecera
			printf "\n$_cyan$_b%s\n\n$_r"		" ¿Dónde quiere guardar los RANGOS?"
			printf "\t$_green%s$_r%s\n"		"[1]" " -> En el fichero de rangos por defecto (DatosRangosDefault.txt)"
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
	echo "$maxrangotampagina" >> $ficheroRangos
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
	printf " $CAB%s$_r%s$CAB%s$_r\n"        "  " "                       Tutor: Jose Manuel Saiz Diez                       " "  "
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

	echo ""
	echo -e " \e[1;48;5;159m                                                      \e[0m"
	echo -e " \e[1;48;5;159m  \e[0m\e[107m                                                  \e[0m\e[1;48;5;159m  \e[0m"
	echo -e " \e[1;48;5;159m  \e[0m\e[1;34;107m                     ALGORITMO                    \e[0m\e[1;48;5;159m  \e[0m"
	echo -e " \e[1;48;5;159m  \e[0m\e[34;107m            GESTIÓN DE MEMORIA VIRTUAL            \e[0m\e[1;48;5;159m  \e[0m"
	echo -e " \e[1;48;5;159m  \e[0m\e[1;94;107m       -----------------------------------        \e[0m\e[1;48;5;159m  \e[0m"
	echo -e " \e[1;48;5;159m  \e[0m\e[1;94;107m       -----------------------------------        \e[0m\e[1;48;5;159m  \e[0m"
	echo -e " \e[1;48;5;159m  \e[0m\e[107m                                                  \e[0m\e[1;48;5;159m  \e[0m"
	echo -e " \e[1;48;5;159m                                                      \e[0m"
	echo ""
}

###################################################################################################################################

# Cabecera del principio del informe.
function cabeceraInforme(){

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
	printf " %s%s%s\n"        	"#" "                       Tutor: Jose Manuel Saiz Diez                       " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s%s%s\n"        	"#" "                                                                          " "#" >> $informe
	printf " %s\n"              "############################################################################" >> $informe
	echo >> $informe

	printf "\n\n" >> $informe
    printf " %s\n"   			"############################################################################" >> $informe
    printf " %s\n"   			"# INFORME DE LA PRÁCTICA                               $(date '+%d/%b/%Y - %H:%M') #" >> $informe
    printf " %s\n\n"   			"############################################################################" >> $informe
	
	# Informe a COLOR
	echo -e "\e[1;48;5;85m                                                     \e[0m" > $informeColor
	echo -e "\e[1;48;5;85m  \e[0m                                                  \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m              PRÁCTICA DE CONTROL 		  \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m         GRADO EN INGENIERÍA INFORMÁTICA          \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m       FCFS/SJF - PAGINACIÓN - S.OPORTUNIDAD      \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m          MEMORIA CONTINUA - NO REUBICABLE        \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m                                                  \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m         Autores: César Rodríguez Villagrá        \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m                  Hugo de la Cámara Saiz          \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m                  Rodrigo Pérez Ubierna           \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m                                                  \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m         Sistemas Operativos 2º Semestre          \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m   Grado en ingeniería informática (2021-2022)    \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m                                                  \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m         \e[33mTutor: Jose Manuel Saiz Diez\e[0m             \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m  \e[0m                                                  \e[1;48;5;85m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;85m                                                      \e[0m" >> $informeColor
	echo ""  >> $informeColor
	echo ""  >> $informeColor
	echo -e "\e[1;48;5;159m                                                      \e[0m" >> $informeColor
	echo -e "\e[1;48;5;159m  \e[0m\e[107m                                                  \e[0m\e[1;48;5;159m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;159m  \e[0m\e[1;34;107m               INFORME DE PRÁCTICA                \e[0m\e[1;48;5;159m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;159m  \e[0m\e[34;107m           GESTIÓN DE MEMORIA VIRTUAL             \e[0m\e[1;48;5;159m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;159m  \e[0m\e[1;94;107m       -----------------------------------        \e[0m\e[1;48;5;159m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;159m  \e[0m\e[1;94;107m       -----------------------------------        \e[0m\e[1;48;5;159m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;159m  \e[0m\e[107m                                                  \e[0m\e[1;48;5;159m  \e[0m" >> $informeColor
	echo -e "\e[1;48;5;159m                                                      \e[0m" >> $informeColor
	echo "" >> $informeColor
}

###################################################################################################################################

# Cabecera que se muestra al finalizar la ejecución del script.
function cabeceraFinal(){
	echo "" | tee -a $informeColor
	echo -e " \e[1;48;5;159m                                                              \e[0m" | tee -a $informeColor
	echo -e " \e[1;48;5;159m  \e[0m\e[107m                                                          \e[0m\e[1;48;5;159m  \e[0m" | tee -a $informeColor
	echo -e " \e[1;48;5;159m  \e[0m\e[1;34;107m                        ALGORITMO                         \e[0m\e[1;48;5;159m  \e[0m" | tee -a $informeColor
	echo -e " \e[1;48;5;159m  \e[0m\e[107m               \e[0m\e[34;107mGESTIÓN DE MEMORIA VIRTUAL\e[0m\e[107m                 \e[0m\e[1;48;5;159m  \e[0m" | tee -a $informeColor
	echo -e " \e[1;48;5;159m  \e[0m\e[107m       \e[0m\e[1;94;107m-------------------------------------------\e[0m\e[107m        \e[0m\e[1;48;5;159m  \e[0m" | tee -a $informeColor
	echo -e " \e[1;48;5;159m  \e[0m\e[107m       \e[0m\e[1;94;107m--------------\e[0m\e[107m      \e[0m\e[1;32;107mFIN\e[0m\e[107m      \e[0m\e[1;94;107m-------------\e[0m\e[107m         \e[0m\e[1;48;5;159m  \e[0m" | tee -a $informeColor
	echo -e " \e[1;48;5;159m  \e[0m\e[107m       \e[0m\e[1;94;107m-------------------------------------------\e[0m\e[107m        \e[0m\e[1;48;5;159m  \e[0m" | tee -a $informeColor
	echo -e " \e[1;48;5;159m  \e[0m\e[107m       \e[0m\e[1;94;107m-------------------------------------------\e[0m\e[107m        \e[0m\e[1;48;5;159m  \e[0m" | tee -a $informeColor
	echo -e " \e[1;48;5;159m  \e[0m\e[107m                                                          \e[0m\e[1;48;5;159m  \e[0m" | tee -a $informeColor
	echo -e " \e[1;48;5;159m                                                              \e[0m" | tee -a $informeColor
	echo "" | tee -a $informeColor

	echo "" >> $informe
	echo " ############################################################" >> $informe
	echo " #                                                          #" >> $informe
	echo " #                   INFORME DE PRÁCTICA                    #" >> $informe
	echo " #               GESTIÓN DE MEMORIA VIRTUAL                 #" >> $informe
	echo " #       -------------------------------------------        #" >> $informe
	echo " #       --------------       FIN      -------------        #" >> $informe
	echo " #       -------------------------------------------        #" >> $informe
	echo " #       -------------------------------------------        #" >> $informe
	echo " #                                                          #" >> $informe
	echo " ############################################################" >> $informe
	echo "" >> $informe
	
}

###################################################################################################################################

# Indica al usuario que el tamaño recomendado para la visualización del programa es la pantalla completa.
function imprimeTamanyoRecomendado(){
	
	printf "\n%s\n"		" Para una correcta visualización del programa se recomienda poner el terminal en pantalla completa."
	read -p " Pulse INTRO cuando haya ajustado el tamaño."
	clear
	cabecera
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
	cabecera
	#imprimeTamanyoRecomendado
	menuInicio
	sed -i 's/\x0//g' ${informe}			# Limpia los caracteres NULL que se han impreso en el informe.
	sed -i 's/\x0//g' ${informeColor}		# Limpia los caracteres NULL que se han impreso en el informeColor.
}

### Ejecución programa ###
main