#!/bin/bash

###########################
#        VARIABLES        #
###########################
# Cada vez que se dice que una variable es utilizada en X función, quiere decir que se utiliza por primera vez en esa función.
# Luego puede utilizarse en más partes del programa.

	# Colores
	declare -r _sel='\e[46m'	# Fondo cyan para la selección de opciones. BORRAR O MODIFICAR

	declare -r _rst='\033[0m' 	# Reset
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
	counter=0;				# Utilizado en varias funciones como contador para bucles etc.
	letra="a";				# Utilizado en varias funciones que piden que se escriba s o n.

	# menuInicio
	menuOpcion=0;			# Utilizada en la función menuInicio, para elegir el algoritmo, la ayuda o salir del programa.

	# imprimeProcesos
	improcesos=0;			# Utilizada en las funciones imprimeProcesos, para imprimir las líneas de procesos.
	impaginillas=0;			# Utilizada en las funciones imprimeProcesos, para imprimir las páginas de cada proceso.
	maxpaginas=0;

	# asignaColores
	color=0;				#Utilizada para inicializar el vector de colores.

	# seleccionInforme
	informe="./datosScript/informes/informeBN.txt";					# Nombre del fichero donde se guardará el informe en BLANCO y NEGRO.
	informeColor="./datosScript/informes/informeCOLOR.txt";			# Nombre del fichero donde se guardará el informe A COLOR.

	#variable del main
	#ficheroant="`grep -lior 'fichero: ' ./datosScript/informes | cut -d "/" -f4 | cut -d "." -f1`.txt"		#busca el anterior informe generado

	#ordenacionViejo	BORRAR? comprobar
	pep=0;			#Utilizado en la funcion ordenacion, para inicializar el vector ordenados con los datos correspondientes
	kek=0;			#Utilizado en la funcion ordenacion, para recorrer todos los procesos y asignar el nro de procesos al vector ordenados
	jej=0;			#Utilizado en la funcion ordenacion, para recorrer todos los procesos y comprar sus tiempos de llegada
	lel=0;			#Utilizado en la funcion ordenacion, para recorrer los procesos ya ordenados y comparar si el actual proceso ha sido ordenado ya
	aux=0;			#Utilizado en la funcion ordenacion, para recoger el dato del proceso que se va a introducir en el vector ordenados
	max=0;			#Utilizado en la funcion ordenacion, para guardar el dato actual del Maximo tiempo de llegada
	one=0;			#Utilizado en la funcion ordenacion, como booleano para comprobar si el actual proceso ha sido ordenado ya

	#entradaFichero
	ficheroIn=0; 						#indica el nombre del fichero de entrada
	fichExiste=0;						#indica si el fichero introducido existe
	posic=0; 							#
	fila=0;								#
	maxFilas=0;							#
	tamArchivo=0; 						#	
	lectura1=0;
	lectura2=0;
	lectura3=0;
	lectura4=0;

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
	ordenados=();						#Vector que recoge los procesos en ordenacion
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
	#npagprocesos=();
	#npagprocesos[$ejecutando]=maxPags[$ejecutando]

	max=0;
	i=0;
	fichSelect=0;

	ordenados=()			# Guarda el número de los procesos en orden de llegada.

	pEjecutados=()       #Alamcena los procesos ejectuados a lo largo del tiempo.
	nCambiosContexto=0;
	tCambiosContexto=()            #Tiempos en los que se producen los cambios de contexto.
	tCambiosContexto[0]=0

	#linedatiempo.
	time_primero=0;              #T. de llegada del primer proceso en ejecutarse.

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

	#calcularEspacios
	procesosMemoria=()		# Array que contiene los procesos que están actualmente asignados en memoria.
	tamEspacioGrande=0		# Tamaño del espacio vacío más grande en memoria.
	espaciosMemoria=()		# Array que contiene la cantidad de espacios vacíos consecutivos en memoria.

	declare -A procesoTiempoMarcoPagina 	# procesoTiempoMarcoPagina[$p,$t,$m]=pagina
	declare -A procesoTiempoMarcoPuntero
	declare -A procesoTiempoMarcoSegunda

###################################################################################################################################

encontrarYactualizar(){
	for ((j = 0; j < $numeroMarcos; j++)); do
		if [[ ${memoriaMarcos[$j]} -eq $paginaActual ]]
		then
			segunda_Oportunidad[$j]=1
			return 0
		fi
	done
	return 1
}

############

reemplazarYactualizar(){
	while :; do
		if [[ ${segunda_Oportunidad[$puntero]} -eq 0 ]]; then
			memoriaMarcos[$puntero]=$paginaActual
			puntero=$((($puntero+1)%$numeroMarcos))
			return 1
		fi
		segunda_Oportunidad[$puntero]=0
		puntero=$((($puntero+1)%$numeroMarcos))
	done
}

############

segundaOportunidad(){

	# Calcular paginas del proceso
	pagsegop=()
	for (( i = 0; i < ${tEjec[$1]}; i++ )); do
		pagsegop[$i]=${paginas[$1,$i]}
	done

	numeroMarcos=${nMarcos[$1]}
	tiempoEjecucion=${#pagsegop[*]}
	puntero=0
	numeroFallos=0
	segunda_Oportunidad=()
	memoriaMarcos=()

	for ((i = 0; i < $numeroMarcos; i++))
	do
		memoriaMarcos[$i]=-1
		segunda_Oportunidad[$i]=0
	done
	procesoTiempoMarcoPuntero[$1,-1]=$puntero
	for ((i = 0; i < $tiempoEjecucion; i++))
	do
	#	procesoTiempoMarcoPuntero[$1,$i]=$puntero
		paginaActual=${pagsegop[$i]}
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
                procesoTiempoMarcoSegunda[$1,$i,$j]=${segunda_Oportunidad[$j]}
    	done
	done
}

###################################################################################################################################

# Asigna al primer parámetro de la entrada un valor aleatorio entre el rango definido por el segundo y tercer parámetro de entrada, ambos incluidos.
function aleatorioEntre() {
    eval "${1}=$( shuf -i ${2}-${3} -n 1 )"
}

############

calcularEspacios(){
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
	cabeceraInicio
	printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Qué opción desea realizar?"
	printf "\t$_green%s$_rst%s\n"		"[1]" " -> Ejecutar el algoritmo"
	printf "\t$_green%s$_rst%s\n"		"[2]" " -> Visualizar la ayuda"
	printf "\t$_green%s$_rst%s\n\n"		"[3]" " -> Salir"
	read -p " Seleccione la opción: " menuOpcion
	
	until [[ $menuOpcion =~ ^[1-3]$ ]]; do
		printf "\n$_red$_b%s$_rst%s"	" Valor incorrecto." " Escriba '1', '2', o '3': "
		read menuOpcion
	done

	case $menuOpcion in
		1) # Muestra la opción 1 seleccionada.
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Qué opción desea realizar?"
			printf "\t$_sel%s%s$_rst\n"			"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_green%s$_rst%s\n"		"[2]" " -> Visualizar la ayuda"
			printf "\t$_green%s$_rst%s\n\n"		"[3]" " -> Salir"
			sleep 0.3
			;;
		2) # Muestra la opción 2 seleccionada.
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Qué opción desea realizar?"
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_sel%s%s$_rst\n"			"[2]" " -> Visualizar la ayuda"
			printf "\t$_green%s$_rst%s\n\n"		"[3]" " -> Salir"
			sleep 0.3
			;;
		3) # Muestra la opción 3 seleccionada.
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Qué opción desea realizar?"
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> Ejecutar el algoritmo"
			printf "\t$_green%s$_rst%s\n"		"[2]" " -> Visualizar la ayuda"
			printf "\t$_sel%s%s$_rst\n"			"[3]" " -> Salir"
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
			#ficheroIn=`grep '.txt$' ./datosScript/informes/$ficheroant | cut -d " " -f5` 			#Guardar el nombre del fichero de la anterior ejecución.
			seleccionInforme
			seleccionEntrada
			FCFS
			final
			;;
		2)	# Muestra la ayuda.
			clear
			cat ./datosScript/ayuda/ayuda.txt
			echo ""
			read -p " Presione INTRO para continuar"
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
#function seleccionAlgortimo(){
	#texto
#}

###################################################################################################################################

# Muestra al usuario qué nombres se le darán por defecto a los informes, permitiendo cambiarlos si así se deseara.
function seleccionInforme(){

	clear
	cabeceraInicio
	printf "\n%s" 						" Los nombres por defecto de los informes son: informeBN.txt, informeCOLOR.txt"
	printf "\n%s\n" 					" ¿Desea cambiarlos? (s/n)"
	read cambiarInformes
	
	until [[ $cambiarInformes =~ ^[nNsS]$ ]]; do
		printf "\n$_red$_b%s$_rst%s"	" Entrada no válida." " Escriba 's' (SI) o 'n' (NO): "
		read cambiarInformes
	done

	if [[ $cambiarInformes =~ ^[sS]$ ]]; then
		
		clear
		cabeceraInicio
		printf "\n%s" 					" Los nombres por defecto de los informes son: informeBN.txt, informeCOLOR.txt"
		printf "\n%s\n" 				" ¿Desea cambiarlos? (s/n)"
		printf "\n%s" 					" Introduzca el nombre del informe en BLANCO y NEGRO (sin incluir .txt): "
		read informe
		informe="./datosScript/informes/${informe}.txt"
		sleep 0.2
		clear
		cabeceraInicio
		printf "\n%s" 					" Los nombres por defecto de los informes son: informeBN.txt, informeCOLOR.txt"
		printf "\n%s\n" 				" ¿Desea cambiarlos? (s/n)"
		printf "\n%s" 					" Introduzca el nombre del informe A COLOR (sin incluir .txt): "
		read informeColor
		informeColor="./datosScript/informes/${informeColor}.txt"
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
	cabeceraInicio
	printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Cómo quiere introducir los datos?"
	printf "\t$_green%s$_rst%s\n"		"[1]" " -> Por teclado"
	printf "\t$_green%s$_rst%s\n"		"[2]" " -> Fichero de datos de última ejecución (datos.txt)"
	printf "\t$_green%s$_rst%s\n"		"[3]" " -> Otro fichero de datos"
	printf "\t$_green%s$_rst%s\n"		"[4]" " -> Aleatorio manual"
	printf "\t$_green%s$_rst%s\n"		"[5]" " -> Fichero de rangos de última ejecución (datosrangos.txt)"
	printf "\t$_green%s$_rst%s\n\n"		"[6]" " -> Otro fichero de rangos"
	read -p " Seleccione la opción: " opcionIn

	until [[ $opcionIn =~ ^[1-6]$ ]]; do
		printf "\n$_red$_b%s$_rst%s"	" Valor incorrecto." " Escriba un número del 1 al 6: "
		read opcionIn
	done
	# Se muestra la opción elegida en el propio informe.
	echo "  Seleccione una opción:  " >> $informe
	echo -e "\e[1;38;5;81m  Seleccione una opción: : \e[0m" >> $informeColor
	
	# Muestra resaltada la opción seleccionada para que sea más visual.
	case $opcionIn in
		1)	# Entrada por teclado
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_sel%s%s$_rst\n"			"[1]" " -> Por teclado"
			printf "\t$_green%s$_rst%s\n"		"[2]" " -> Fichero de datos de última ejecución (datos.txt)"
			printf "\t$_green%s$_rst%s\n"		"[3]" " -> Otro fichero de datos"
			printf "\t$_green%s$_rst%s\n"		"[4]" " -> Aleatorio manual"
			printf "\t$_green%s$_rst%s\n"		"[5]" " -> Fichero de rangos de última ejecución (datosrangos.txt)"
			printf "\t$_green%s$_rst%s\n\n"		"[6]" " -> Otro fichero de rangos"

			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Por teclado	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Por teclado <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			entradaManual
			;;
		2)
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> Por teclado"
			printf "\t$_sel%s%s$_rst\n"			"[2]" " -> Fichero de datos de última ejecución (datos.txt)"
			printf "\t$_green%s$_rst%s\n"		"[3]" " -> Otro fichero de datos"
			printf "\t$_green%s$_rst%s\n"		"[4]" " -> Aleatorio manual"
			printf "\t$_green%s$_rst%s\n"		"[5]" " -> Fichero de rangos de última ejecución (datosrangos.txt)"
			printf "\t$_green%s$_rst%s\n\n"		"[6]" " -> Otro fichero de rangos"	
		
			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Fichero de datos de última ejecución (datos.txt)	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Fichero de datos de última ejecución (datos.txt) <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			entradaUltimaEjec
			;;
		3)
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> Por teclado"
			printf "\t$_green%s$_rst%s\n"		"[2]" " -> Fichero de datos de última ejecución (datos.txt)"
			printf "\t$_sel%s%s$_rst\n"			"[3]" " -> Otro fichero de datos"
			printf "\t$_green%s$_rst%s\n"		"[4]" " -> Aleatorio manual"
			printf "\t$_green%s$_rst%s\n"		"[5]" " -> Fichero de rangos de última ejecución (datosrangos.txt)"
			printf "\t$_green%s$_rst%s\n\n"		"[6]" " -> Otro fichero de rangos"
		
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
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> Por teclado"
			printf "\t$_green%s$_rst%s\n"		"[2]" " -> Fichero de datos de última ejecución (datos.txt)"
			printf "\t$_green%s$_rst%s\n"		"[3]" " -> Otro fichero de datos"
			printf "\t$_sel%s%s$_rst\n"			"[4]" " -> Aleatorio manual"
			printf "\t$_green%s$_rst%s\n"		"[5]" " -> Fichero de rangos de última ejecución (datosrangos.txt)"
			printf "\t$_green%s$_rst%s\n\n"		"[6]" " -> Otro fichero de rangos"
		
			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Aleatorio manual	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Aleatorio manual <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			entradaManualRangos
			;;
		5)
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> Por teclado"
			printf "\t$_green%s$_rst%s\n"		"[2]" " -> Fichero de datos de última ejecución (datos.txt)"
			printf "\t$_green%s$_rst%s\n"		"[3]" " -> Otro fichero de datos"
			printf "\t$_green%s$_rst%s\n"		"[4]" " -> Aleatorio manual"
			printf "\t$_sel%s%s$_rst\n"			"[5]" " -> Fichero de rangos de última ejecución (datosrangos.txt)"
			printf "\t$_green%s$_rst%s\n\n"		"[6]" " -> Otro fichero de rangos"
		
			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Fichero de rangos de última ejecucuion (datosrangos.txt)	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Fichero de rangos de última ejecucuion (datosrangos.txt) <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			entradaUltimaEjecRangos
			;;
		6)
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Cómo quiere introducir los datos?"
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> Por teclado"
			printf "\t$_green%s$_rst%s\n"		"[2]" " -> Fichero de datos de última ejecución (datos.txt)"
			printf "\t$_green%s$_rst%s\n"		"[3]" " -> Otro fichero de datos"
			printf "\t$_green%s$_rst%s\n"		"[4]" " -> Aleatorio manual"
			printf "\t$_green%s$_rst%s\n"		"[5]" " -> Fichero de rangos de última ejecución (datosrangos.txt)"
			printf "\t$_sel%s%s$_rst\n\n"		"[6]" " -> Otro fichero de rangos"
		
			echo "" >> $informeColor
			echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Otro fichero de rangos	\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo "" >> $informe
			echo -e "	  -> Otro fichero de rangos <-	" >> $informe
			echo "" >> $informe
			sleep 0.5
			#entradaFicheroAleatorio
			entradaFicheroRangos
		;;
	esac
	
	calcularEspacios

	for (( proc=1; proc<=$nProc; proc++ )); do
		segundaOportunidad $proc
	done

	#	procesito=1
	#	for (( i=0; i<${tEjec[$procesito]}; i++));do
	#		for (( j=0; j<${nMarcos[$procesito]}; j++ ));do
	#			printf "%4s" "${procesoTiempoMarcoPagina[$procesito,$i,$j]}"
	#		done
	#		echo
	#	done
}

###################################################################################################################################

# Las variables globales serán introducidas una a una por teclado.
# Relativa a la opción 1: 'Por fichero' en el menú de selección de entrada de datos.
function entradaManual(){
	
	local otroProc="s";		# Para comprobar si se quiere introducir o no un nuevo proceso.
	clear
	cabeceraInicio
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
	cabeceraInicio
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
	cabeceraInicio
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
			if [ "$distinta" == "n" ]; then
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
	#guardaDatos
	clear
	guardaDatosAleatorios
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se inicializan con los datos contenidos en el fichero de última ejecución (datos.txt).
# Relativa a la opción 2: 'Fichero de datos de última ejecución (datos.txt)' en el menú de selección de entrada de datos.
function entradaUltimaEjec(){
	
	clear
	cabeceraInicio
	echo "" | tee -a $informeColor

	echo "" >> $informe
	echo -e " Elija un \e[1;32mfichero\e[0m: " | tee -a $informeColor
	echo -n " Elija un fichero: " >> $informe
	clear
	cabeceraInicio
	echo ""
	sleep 0.5
	ficheroIn="datos.txt"
	echo "$ficheroIn" >> $informe
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	
	tamMem=`awk NR==1 ./datosScript/"$ficheroIn"`
	tamPag=`awk NR==2 ./datosScript/"$ficheroIn"`
	
	echo $tamMem
	echo $tamPag
	
	marcosMem=$(($tamMem/$tamPag))
	#nProc=`awk NR==4 ./datosScript/"$ficheroIn"`
	nProc=`wc -l < ./datosScript/"$ficheroIn"`
	let nProc=$nProc-2
	p=1;
	maxFilas=$(($nProc+2))
	for (( fila = 3; fila <= $maxFilas; fila++ )); do
		linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
        IFS=";" read -r -a parte <<< "$linea"

		#lectura1=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 1 -d ";"`
		tLlegada[$p]=${parte[0]}
		#lectura2=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 2 -d ";"`
		#tEjec[$p]=$lectura2
		#maxPags[$p]=${tEjec[$p]}
		#lectura3=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 3 -d ";"`
		nMarcos[$p]=${parte[1]}
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
			
		linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
		IFS=";" read -r -a parte <<< "$linea"
		tEjec[$p]=$((${#parte[*]}-3))
		maxPags[$p]=${tEjec[$p]}
			

		for (( n = 0; n < ${maxPags[$p]}; n++ )); do
			m=$(($n+3))
			#posic=$(($n+5))
			#lectura4=`awk NR==$fila ./datosScript/"$ficheroIn"  | cut -f $posic -d ";"`
			direcciones[$p,$n]=${parte[$m]}
			paginas[$p,$n]=$(( ${direcciones[$p,$n]}/$tamPag ))
		done
		p=$(($p+1))
	done
	
	p=$(($p-1))
	clear
	imprimeProcesosUltimoFichero
}

###################################################################################################################################

# Las variables globales se inicializan con los datos contenidos en un fichero de datos.
# Relativa a la opción 3: 'Otro fichero de datos' en el menú de selección de entrada de datos.
function entradaFichero(){

	clear
	cabeceraInicio
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
	cabeceraInicio
	echo ""
	muestraArchivos 1
	sleep 0.5
	ficheroIn=`find datosScript -maxdepth 1 -type f -iname "*.txt" | sort | cut -f2 -d"/" | cut -f$fichSelect -d$'\n'` # Guardar el nombre del fichero escogido.
	echo "$ficheroIn" >> $informe
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	
	tamMem=`awk NR==1 ./datosScript/"$ficheroIn"`
	tamPag=`awk NR==2 ./datosScript/"$ficheroIn"`
	marcosMem=$(($tamMem/$tamPag))
	#nProc=`awk NR==4 ./datosScript/"$ficheroIn"`
	nProc=`wc -l < ./datosScript/"$ficheroIn"`
	let nProc=$nProc-2
	p=1;
	maxFilas=$(($nProc+2))
	for (( fila = 3; fila <= $maxFilas; fila++ )); do
		linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
        IFS=";" read -r -a parte <<< "$linea"

		#lectura1=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 1 -d ";"`
		tLlegada[$p]=${parte[0]}
		#lectura2=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 2 -d ";"`
		#tEjec[$p]=$lectura2
		#maxPags[$p]=${tEjec[$p]}
		#lectura3=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 3 -d ";"`
		nMarcos[$p]=${parte[1]}
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
			
		linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
		IFS=";" read -r -a parte <<< "$linea"
		tEjec[$p]=$((${#parte[*]}-3))
		maxPags[$p]=${tEjec[$p]}
			
		for (( n = 0; n < ${maxPags[$p]}; n++ )); do
			m=$(($n+3))
			#posic=$(($n+5))
			#lectura4=`awk NR==$fila ./datosScript/"$ficheroIn"  | cut -f $posic -d ";"`
			direcciones[$p,$n]=${parte[$m]}
			paginas[$p,$n]=$(( ${direcciones[$p,$n]}/$tamPag ))
		done
		p=$(($p+1))
	done
	p=$(($p-1))
	clear
	ficheroOut="./datosScript/datos.txt"
    touch $ficheroOut
    echo "$tamMem" > $ficheroOut
    echo "$tamPag" >> $ficheroOut

    for(( i = 1; i <= $nProc; i++ )); do
        echo -n "${tLlegada[$i]};" >> $ficheroOut
        #echo -n "${tEjec[$i]};" >> $ficheroOut
        echo -n "${nMarcos[$i]};;" >> $ficheroOut
        for (( n = 0; n < ${maxPags[$i]}; n++ )); do
            echo -n "${direcciones[$i,$n]};" >> $ficheroOut
        done
    echo "" >> $ficheroOut
    done
    clear
	imprimeProcesosFichero
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores introducido por teclado para cada una.
# Relativa a la opción 4: 'Aleatorio manual' en el menú de selección de entrada de datos.
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
	cabeceraInicio
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
	cabeceraInicio
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
	sleep 0.2
	
	# Mínimo número de direcciones por marco (nº de direcciones).
	clear
	cabeceraInicio
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
	cabeceraInicio
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
	sleep 0.2

	clear
	cabeceraInicio
	imprimeVarGlobRangos
	sleep 1
	p=1
	clearImprime

	# Mínimo número de procesos.	
	clear
	cabeceraInicio
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
	cabeceraInicio
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
	cabeceraInicio
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
	cabeceraInicio
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
	cabeceraInicio
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
	cabeceraInicio
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
	cabeceraInicio
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
	cabeceraInicio
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
	cabeceraInicio
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
	cabeceraInicio
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
	
	printf "%s\n" " Pulse INTRO para continuar ↲"
	read
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
	#guardaDatos
	clear
	guardaDatosAleatorios
	guardaRangos
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores contenido en el fichero de última ejecución (datosrangos.txt).
# Relativa a la opción 5: 'Fichero de rangos de última ejecución (datosrangos.txt)' en el menú de selección de entrada de datos.
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
	
	#leerrangosultimaejecucion
	leeRangosFichero "ultimaEjecucion"
	
	aleatorioEntre marcosMem $minRangoMemoria $maxRangoMemoria
	
	echo "$tamMem" >> $informe
	echo -e "\e[1;32m$tamMem\e[0m" >> $informeColor
	
	aleatorioEntre tamPag $minRangoTamPagina $maxrangotampagina
	
	echo "$tamPag" >> $informe
	echo -e "\e[1;32m$tamPag\e[0m" >> $informeColor
	
	tamMem=$(($marcosMem*$tamPag))
	
	p=1
	aleatorioEntre numeroprocesos $minRangoNumProcesos $maxRangoNumProcesos
	#maxPags[$p]=0;
	
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
	#guardaDatos
	clear
	guardaDatosAleatorios
	imprimeProcesosFinal
}

###################################################################################################################################

# Las variables globales se generarán aleatoriamente ajustándose a un rango de valores contenido en un fichero de rangos.
# Relativa a la opción 6: 'Otro fichero de rangos' en el menú de selección de entrada de datos.
function entradaFicheroRangos(){

	clear
	cabeceraInicio
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
	cabeceraInicio
	echo ""
	muestraArchivosRangos 1
	sleep 0.5
	ficheroIn=`find datosScript/rangos -maxdepth 1 -type f -iname "*.txt" | sort | cut -f3 -d"/" | cut -f$fichSelect -d$'\n'` # Guarda el nombre del fichero escogido.
	echo "$ficheroIn" >> $informe
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	
	entradaUltimaEjecRangos
	clear
	imprimeProcesosFichero
}

###################################################################################################################################

# NO USADO??
entradarangoarchivo(){
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
	
	
	leeRangosFichero
	
	#hace que las variables globales sean aleatorias,leyendo los rangos
	
	
	aleatorioEntre marcosMem $minRangoMemoria $maxRangoMemoria
	
	echo "$tamMem" >> $informe
	echo -e "\e[1;32m$tamMem\e[0m" >> $informeColor
	
	
	
	aleatorioEntre tamPag $minRangoTamPagina $maxrangotampagina
	
	echo "$tamPag" >> $informe
	echo -e "\e[1;32m$tamPag\e[0m" >> $informeColor
	
	tamMem=$(($marcosMem*$tamPag))
	
	
	p=1
	
	aleatorioEntre numeroprocesos $minRangoNumProcesos $maxRangoNumProcesos
	
	
	maxPags[$p]=0;
	
	
	for (( p=1; p<=$numeroprocesos; p++ ))
	do
		maxPags[$p]=0;
		aleatorioEntre tLlegada[$p] $minRangoTLlegada $maxRangoTLlegada
		pag=${tEjec[$p]};
		aleatorioEntre nMarcos[$p] $minRangoNumMarcos $maxRangoNumMarcos
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
		
		
		aleatorioEntre numerodedirecciones[$p] $minRangoNumDirecciones $maxRangoNumDirecciones
		
		for (( pag=0; pag<=${numerodedirecciones[$p]}; pag++ ))
		do
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
	#guardaDatos
	clear
	guardaDatosAleatorios
	guardaRangos
	imprimeProcesosFinal
	
}

###################################################################################################################################

# NO USADO?? (solo comentado).
entradaFicheroAleatorio(){
#toma un archivo aleatorio de los disponibles
	clear
	cabeceraInicio
	echo "" | tee -a $informeColor

	muestraArchivos
	echo "" >> $informe
	echo -e " Ficheros \e[1;32mdisponibles\e[0m: " | tee -a $informeColor
	echo -n " Ficheros disponibles: " >> $informe
	aleatorioEntre fichSelect 1 $max
	minrango=0
	maxrango=0
	until [[ $tamMem =~ [0-9] && $fichSelect -gt 0 && $fichSelect -le $max ]]
		do
			echo ""
			echo -e "\e[1;31m El valor introducido no es correcto. Debe estar entre\e[0m \e[1;33m1\e[0m \e[1;31my\e[0m \e[1;33m$max\e[0m"
			echo -n " Ficheros disponibles: "
			aleatorioEntre fichSelect 1 $max
			minrango=0
			maxrango=0
		done
	clear
	cabeceraInicio
	echo ""
	muestraArchivos 1
	sleep 0.5
	ficheroIn=`find datosScript -maxdepth 1 -type f -iname "*.txt" | sort | cut -f2 -d"/" | cut -f$fichSelect -d$'\n'` #Guardar el nombre del fichero escogido.
	
	echo "$ficheroIn" >> $informe
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	
	tamMem=`awk NR==1 ./datosScript/"$ficheroIn"`
	tamPag=`awk NR==2 ./datosScript/"$ficheroIn"`
	marcosMem=$(($tamMem/$tamPag))

	nProc=`wc -l < ./datosScript/"$ficheroIn"`
	let nProc=$nProc-2
	p=1;
	maxFilas=$(($nProc+2))
	for (( fila = 3; fila <= $maxFilas; fila++ )) 
		do
		        linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
                        IFS=";" read -r -a parte <<< "$linea"


			tLlegada[$p]=${parte[0]}

			nMarcos[$p]=${parte[1]}
			tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
			
			linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
			IFS=";" read -r -a parte <<< "$linea"
			tEjec[$p]=$((${#parte[*]}-3))
			maxPags[$p]=${tEjec[$p]}
			

			for (( n = 0; n < ${maxPags[$p]}; n++ ))
				do
					m=$(($n+3))

					direcciones[$p,$n]=${parte[$m]}
					paginas[$p,$n]=$(( ${direcciones[$p,$n]}/$tamPag ))
				done
			p=$(($p+1))

		done
	
	p=$(($p-1))
	
	clear
	imprimeProcesosFichero
}

###################################################################################################################################

# NO USADO?? -> solo se llama en elegirentradaaleatorioarchivoorango() pero esta NO está implementada.
entradaUltimoAleatorio(){
	#es la entrada del modo del ultimo fichero aleatorio
	clear
	cabeceraInicio
	echo "" | tee -a $informeColor

	
	echo "" >> $informe
	echo -e " Elija un \e[1;32mfichero\e[0m: " | tee -a $informeColor
	echo -n " Elija un fichero: " >> $informe
	
	ficheroIn="datosAleatorios.txt"
	
	echo "$ficheroIn" >> $informe
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	
	tamMem=`awk NR==1 ./datosScript/"$ficheroIn"`
	tamPag=`awk NR==2 ./datosScript/"$ficheroIn"`
	marcosMem=$(($tamMem/$tamPag))

	nProc=`wc -l < ./datosScript/"$ficheroIn"`
	let nProc=$nProc-2
	p=1;
	maxFilas=$(($nProc+2))
	for (( fila = 3; fila <= $maxFilas; fila++ )) 
		do
		        linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
                        IFS=";" read -r -a parte <<< "$linea"


			tLlegada[$p]=${parte[0]}

			nMarcos[$p]=${parte[1]}
			tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
			
			linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
			IFS=";" read -r -a parte <<< "$linea"
			tEjec[$p]=$((${#parte[*]}-3))
			maxPags[$p]=${tEjec[$p]}
			

			for (( n = 0; n < ${maxPags[$p]}; n++ ))
				do
					m=$(($n+3))

					direcciones[$p,$n]=${parte[$m]}
					paginas[$p,$n]=$(( ${direcciones[$p,$n]}/$tamPag ))
				done
			p=$(($p+1))

		done
	
	p=$(($p-1))
	
	clear
	imprimeProcesosFichero
}

###################################################################################################################################

# NO USADO??
elegirentradaaleatorioarchivoorango(){
	
	clear
	cabeceraInicio
	imprimeVarGlob
	local entradaaleatorioarchivoorango=0
	echo ""g
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " ¿Quiere introducir los datos por \e[1;33marchivo (1)\e[0m o por \e[1;33mrango (2)\e[0m?: "
	read entradaaleatorioarchivoorango
	echo -n " ¿Quiere introducir los datos por archivo (1) o por rango (2)? " >> $informe
	echo -n -e " ¿Quiere introducir los datos por \e[1;33marchivo (1)\e[0m o por \e[1;33mrango (2)\e[0m?: " >> $informeColor
	until [[ $entradaaleatorioarchivoorango =~ [1-2] ]]			
		do
			echo ""
			echo -e "\e[1;31m El número introducido debe ser \e[0m\e[1;33m1 o 2\e[0m"
			echo -n -e " Introduzca 1 o 2 si quiere introducir los datos por \e[1;33marchivo (1)\e[0m o por \e[1;33mrango (2)\e[0m: "
			read entradaaleatorioarchivoorango
		done
	echo " $entradaaleatorioarchivoorango" >> $informe
	echo " $entradaaleatorioarchivoorango" >> $informeColor
	clear
	cabeceraInicio
	imprimeVarGlob
	if [ "$entradaaleatorioarchivoorango" == "1" ]
	then
		entradaUltimoAleatorio
	else
		
		entradaUltimaEjecRangos

	fi
	clear
	cabeceraInicio
	imprimeVarGlob
	sleep 0.5
	clear
}

###################################################################################################################################

# BORRAR -> fusionado con leeRangosFichero.
leerrangosultimaejecucion(){
	
	nombreFicheroRangos="datosrangos"	
	ficheroRangos="./datosScript/rangos/${nombreFicheroRangos}.txt"
	
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

# Función auxiliar. Lee un fichero de rangos y asigna a las variables los valores mínimos y máximos contenidos en él.
# Si se pasa como parámetro "ultimaEjecucion", el fichero a leer será 'datosrangos.txt'.
# Si no hay parámetros, el fichero a leer será el que haya especificado anteriormente el usuario, almacenado en la variable 'ficheroIn'.
leeRangosFichero(){
	
	if [[ $1 == "ultimaEjecucion" ]]; then
		nombreFicheroRangos="datosrangos"	
		ficheroRangos="./datosScript/rangos/${nombreFicheroRangos}.txt"
	else
		ficheroRangos="./datosScript/rangos/${ficheroIn}.txt"
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

# Muestra los archivos que hay en el directorio './datosScript'.
# Si se han pasado argumentos, muestra todos los archivos y resalta el elegido. Si no, imprime todos los archivos.
function muestraArchivos(){
	
	max=`find datosScript -maxdepth 1 -type f | cut -f2 -d"/" | wc -l`				# Número de archivos en el directorio.
	printf "\n$_cyan$_b%s\n\n$_rst"		" ARCHIVOS EN EL DIRECTORIO './datosScript': "
	
	if [[ $# -gt 0 ]]; then		# Si el número de argumentos pasados ($#) es mayor que 0...
		for (( i=1; i<=$max; i++ )); do
			file=`find datosScript -maxdepth 1 -type f | cut -f2 -d"/" | sort | cut -f$i -d$'\n'`	# Mostrar sólo los nombres de ficheros (no directorios).
			if [ $i -eq $fichSelect ]; then
				printf '    \e[1;38;5;64;48;5;7m	[%2u]\e[90m %-20s\e[0m\n' "$i" "$file" 		# Resaltar opción escogida.
			else
				printf '    \e[1;32m	[%2u]\e[0m %-20s\e[0m\n' "$i" "$file"
			fi
		done
	else
		for (( i=1; i<=$max; i++ )); do
			file=`find datosScript -maxdepth 1 -type f | cut -f2 -d"/" | sort | cut -f$i -d$'\n'` #Mostrar solo los nombres de ficheros (no directorios).
			printf '    \e[1;32m	[%2u]\e[0m %-20s\e[0m\n' "$i" "$file"
		done
	fi
	printf "\n"
}

###################################################################################################################################

# Muestra los archivos que hay en el directorio './datosScript/rangos'.
# Si se han pasado argumentos, muestra todos los archivos y resalta el elegido. Si no, imprime todos los archivos.
function muestraArchivosRangos(){

	max=`find datosScript/rangos -maxdepth 1 -type f | cut -f3 -d"/" | wc -l`		# Número de archivos en el directorio.
	printf "\n$_cyan$_b%s\n\n$_rst"		" ARCHIVOS EN EL DIRECTORIO './datosScript/rangos': "
	
	if [[ $# -gt 0 ]]; then		# Si el número de argumentos pasados ($#) es mayor que 0...
		for (( i=1; i<=$max; i++ )); do
			file=`find datosScript/rangos -maxdepth 1 -type f | cut -f3 -d"/" | sort | cut -f$i -d$'\n'` 	# Mostrar sólo los nombres de ficheros (no directorios).
			if [ $i -eq $fichSelect ]; then
				printf '    \e[1;38;5;64;48;5;7m	[%2u]\e[90m %-20s\e[0m\n' "$i" "$file" 					# Resaltar opción escogida.
			else
				printf '    \e[1;32m	[%2u]\e[0m %-20s\e[0m\n' "$i" "$file"
			fi
		done
	else
		for (( i=1; i<=$max; i++ )); do
			file=`find datosScript/rangos -maxdepth 1 -type f | cut -f3 -d"/" | sort | cut -f$i -d$'\n'` #Mostrar solo los nombres de ficheros (no directorios).
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
	echo -e " Tamaño  de   Página:  \e[1;33m$tamPag\e[0m"
	echo -e " Número  de   marcos:  \e[1;33m$marcosMem\e[0m"
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

# IGUAL QUE imprimeProcesosFinal() ????? -> COMPROBAR
function imprimeProcesos(){
	
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

# Informa de que se han introducido los datos por fichero. -> BORRAR??? (no sirve de mucho)
function imprimeProcesosFichero(){
	printf "\n%s\n" " >> Has introducido los datos por fichero." >> $informe
	printf "\n%s\n" " >> Has introducido los datos por fichero." | tee -a $informeColor
	imprimeProcesosFinal
}

###################################################################################################################################

# Informa de que se han introducido los datos por el fichero de última ejecución. -> BORRAR??? (no sirve de mucho)
function imprimeProcesosUltimoFichero(){
	printf "\n%s\n" " >> Has introducido los datos por el fichero de la última ejecución." >> $informe
	printf "\n%s\n" " >> Has introducido los datos por el fichero de la última ejecución." | tee -a $informeColor
	imprimeProcesosFinal
}

###################################################################################################################################

# Imprime por pantalla un resumen de los procesos y sus parámetros. Se debe mostrar antes de la ejecución del algoritmo.
function imprimeProcesosFinal(){
	#guardaDatos
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
	
	printf "\n\n\n" >> $informe
	printf "\n\n\n" >> $informeColor	
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

# NO USADO?? -> BORRAR después de comprobar.
function ordenacionViejo(){
	#Se inicializa el vector de ordenacion
	for (( pep=1; pep<=$p; pep++ ))
		do
			ordenados[$pep]=$p
		done
	for (( kek=$(expr $p-1); kek>0; kek-- ))
		do
			max=0
			for (( jej=1; jej<$p; jej++ ))
				do
					for (( lel=$kek, one=0; lel<=$(expr $p-1); lel++ ))
						do
							if [ $jej -eq "${ordenados[$lel]}" ]
								then
									one=1
							fi
						done
				if [ $one -eq 0 ]
					then
						if [[ ${tLlegada[$jej]} -ge $max ]]
							then
								aux=$jej
								max=${tLlegada[$jej]}
						fi
				fi
				done
			ordenados[$kek]=$aux
		done
	if [ $p -eq 1 ]
		then
			ordenados[1]=1
	fi
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
	cabeceraInicio
	printf "\n$_cyan$_b%s\n\n$_rst"		" Seleccione el tipo de ejecución:"
	printf "\t$_green%s$_rst%s\n"		"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)"
	printf "\t$_green%s$_rst%s\n"		"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)"
	printf "\t$_green%s$_rst%s\n"		"[3]" " -> Completa (sin esperas)"
	printf "\t$_green%s$_rst%s\n\n"		"[4]" " -> Completa solo resumen"
	read -p " Seleccione la opción: " opcionEjec
	until [[ $opcionEjec =~ ^[1-4]$ ]]; do
		printf "\n$_red$_b%s$_rst%s"	" Valor incorrecto." " Escriba '1', '2', '3' o '4: "
		read opcionEjec
	done

	case $menuOpcion in
		1) # Muestra la opción 1 seleccionada.
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_sel%s%s$_rst\n"			"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n"		"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n"		"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n\n"		"[4]" " -> Completa solo resumen" | tee -a $informeColor

			printf "\n$_b%s\n\n"				" ¿Qué opción desea realizar?" >> $informe
			printf "\t%s%s\n"					" -> [1]" " Por eventos (pulsando INTRO en cada cambio de estado) <-" >> $informe
			printf "\t%s%s\n"					"[2]" " Automática (introduciendo cada cuántos segundos cambia de estado)" >> $informe
			printf "\t%s%s\n"					"[3]" " Completa (sin esperas)" >> $informe
			printf "\t%s%s\n\n"					"[4]" " Completa solo resumen" >> $informe
			sleep 0.3
			;;
		2) # Muestra la opción 2 seleccionada.
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_sel%s%s$_rst\n"			"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n"		"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n\n"		"[4]" " -> Completa solo resumen" | tee -a $informeColor

			printf "\n$_b%s\n\n"				" ¿Qué opción desea realizar?" >> $informe
			printf "\t%s%s\n"					"[1]" " Por eventos (pulsando INTRO en cada cambio de estado)" >> $informe
			printf "\t%s%s\n"					" -> [2]" " Automática (introduciendo cada cuántos segundos cambia de estado) <-" >> $informe
			printf "\t%s%s\n"					"[3]" " Completa (sin esperas)" >> $informe
			printf "\t%s%s\n\n"					"[4]" " Completa solo resumen" >> $informe
			sleep 0.3

			read -p "Introduzca el número de segundos entre cada evento: " segEsperaEventos
			until [[ $segEsperaEventos =~ [0-9] && $segEsperaEventos -gt 0 ]]; do
				printf "\n$_red$_b%s$_rst%s"	" Valor incorrecto." " Introduzca un número mayor que 0: "
				read segEsperaEventos
			done
			;;
		3) # Muestra la opción 3 seleccionada.
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n"		"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_sel%s%s$_rst\n"			"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n\n"		"[4]" " -> Completa solo resumen" | tee -a $informeColor

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
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Qué opción desea realizar?" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> Por eventos (pulsando INTRO en cada cambio de estado)" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n"		"[2]" " -> Automática (introduciendo cada cuántos segundos cambia de estado)" | tee -a $informeColor
			printf "\t$_green%s$_rst%s\n"		"[3]" " -> Completa (sin esperas)" | tee -a $informeColor
			printf "\t$_sel%s%s$_rst\n"			"[4]" " -> Completa solo resumen" | tee -a $informeColor

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


############


lineadetiempoCero(){

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


lineadetiempo(){
	#   count=1
	#   cambiacolor=1
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
	
	
	for (( n=1; n<=$nProc; n++ ))
		do
			contadorPag[$n]=0
		done
	
	#
	#              P02         
	#Tiempo: ------3  6  8  4  ----
	#        0     2           6
	#

	#	echo "" | tee -a $informeColor
	#	echo "" >> $informe
	
	
	#Imprime los procesos
	filaTiemProc="    |"
	m=6
	#	colorProcDiagTiem[$m]
	for (( i=0; i<$nCambiosContexto; i++ ))
		do
			let j=i+1
		
			let tiempoCambio[j]=(tCambiosContexto[j]-tCambiosContexto[i])
			let espaciosTotales[j]=tiempoCambio[j]*3
			let espaciosMenos[j]=espaciosTotales[j]-3
	
			if [[ ${pEjecutados[$j]} -eq -1 ]]  #Si vale -1 no se imprime nada.
				then
					for ((n=0; n<${espaciosTotales[$j]}; n++))
						do
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
		#	filaTiemProc="${filaTiemProc}"
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


	#  if [[ $nCambiosContexto -eq 1 ]]   #Para que el cálculo solo se haga una vez.
	#    then
	#        let espacio[1]=espaciosTotales[1]-1
	#    else
	#		let previoCambio=nCambiosContexto-1
	#		if [[ ${tCambiosContexto[$previoCambio]} -lt 10 ]]
	#			then
	#				let espacio[$nCambiosContexto]=espaciosTotales[$nCambiosContexto]-1
	#			else
	#				if [[ ${tCambiosContexto[$previoCambio]} -lt 100 ]]
	#					then
	#						let espacio[$nCambiosContexto]=espaciosTotales[$nCambiosContexto]-2
	#					else
	#						let espacio[$nCambiosContexto]=espaciosTotales[$nCambiosContexto]-3
	#				fi
	#		fi
	# fi
	#  
	#  for (( i = 0; i <= $nCambiosContexto ; i++ ))
	#    do
	#	   	 filaTiemTiem="${filaTiemTiem}${tCambiosContexto[i]}"
	#		for ((n=0; n<${espacio[$i]}; n++))
	#			do
	#				filaTiemTiem="${filaTiemTiem} "
	#			done
	#				let k=i+1
	#				filaTiemTiem="${filaTiemTiem}${tCambiosContexto[i]}"
	#    done
	#	filaTiemTiem="${filaTiemTiem}"


	#guarda colores de procesos
	#	n=9

	#	for (( i=0; i<$nCambiosContexto; i++ ))
	#		do
	#			let j=i+1
	#		
	#			let tiempoCambio[j]=(tCambiosContexto[j]-tCambiosContexto[i])
	#			let espaciosTotales[j]=tiempoCambio[j]*3
	#			let espaciosMenos[j]=espaciosTotales[j]-3
	#	
	#			if [[ ${pEjecutados[$j]} -eq -1 ]]  #Si vale -1 no se imprime nada.
	#				then
	#					for ((m=0; m<${espaciosTotales[$j]}; m++))
	#						do
	#							((n++))
	#						done
	#				else
	#					for (( o=1; o<=3; o++ ))
	#						do
	#							colorProcDiagTiem[$n]="\e[1;3${colorines[${pEjecutados[$j]}]}m"
	#							((n++))
	#						done
	#					for ((m=0; m<${espaciosMenos[$j]}; m++))
	#						do
	#							((n++))
	#						done
	#			fi
	#		done
	#	for (( o=1; o<=3; o++ ))
	#		do
	#			colorProcDiagTiem[$n]="\e[1;3${colorines[$ejecutando]}m"
	#			((n++))
	#		done
		
	
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
  
	#	echo "$filaTiemProc" >> $informe
	#	echo "$filaTiemPag" >> $informe
	#	echo "$filaTiemTiem" >> $informe
		
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


############


diagramaresumen(){

	#echo -e " \e[1;30;41mResumen:\e[0m\e[30;46mT.lleg|T.ejec|T.Rest|T.Retor\e[0m\e[47m  \e[0m\e[30;44mT.Espera\e[0m\e[47m      \e[0m\e[30;47mEstado\e[0m\e[47m      \e[0m\e[30;41mDirecc-Páginas\e[0m" | tee -a $informeColor
	echo -e " Ref Tll Tej nMar Tesp Tret Trej Mini Mfin Estado           Dirección-Página" | tee -a $informeColor
	
	#	Pro|TLl|TEj|nMar|TEsp|TRet|TRes
	#	...|...|...|....|....|....|....|
	
	for (( counter = 1; counter <= $nProc; counter++ ))
		do
			let ord=${ordenados[$counter]}
			
			if [[ $ord -lt 10 ]]
				then
					printf " \e[1;3${colorines[$ord]}mP0$ord %3u %3u %4u" "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
					#echo -n -e " \e[1;3${colorines[$ord]}mP0$ord	   ${tLlegada[$ord]}	${tEjec[$ord]}	${nMarcos[$ord]}" | tee -a $informeColor
					echo -n " P0$ord	T.lleg: ${tLlegada[$ord]}	T.Ejec: ${tEjec[$ord]}	Marcos: ${nMarcos[$ord]}	T.Espera: ${esperaconllegada[$ord]}  " >> $informe
				else
					printf " \e[1;3${colorines[$ord]}mP$ord %3u %3u %4u" "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
					#echo -n -e " \e[1;3${colorines[$ord]}mP$ord	   ${llegada[$ord]}	${tEjec[$ord]}	${nMarcos[$ord]}" | tee -a $informeColor
					echo -n " P$ord	T.lleg: ${tLlegada[$ord]}	T.Ejec: ${tEjec[$ord]}	Marcos: ${nMarcos[$ord]}	T.Espera: ${esperaconllegada[$ord]}  " >> $informe
			fi

			

			
			#Imprime el tiempo de espera
			if [[ ${tLlegada[$ord]} -gt $tSistema ]]
				then
					echo -n -e "    -   " | tee -a $informeColor
				else
					esperaSinLlegada[$ord]=$((${esperaconllegada[$ord]}-${tLlegada[$ord]}))
					printf " %4d" "${esperaSinLlegada[$ord]}" | tee -a $informeColor
					#echo -n -e "	${esperaSinLlegada[$ord]}" | tee -a $informeColor
			fi
			
			#Imprime el tiempo de retorno
			if [[ $tSistema -ge ${tLlegada[$ord]} ]]
				then
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
			#printf " %-4u" "$retorn" | tee -a $informeColor
			#echo -n -e "	$retorn  " | tee -a $informeColor
			
			
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

			 if [[ ${tLlegada[$ord]} -le $tSistema ]]
                                then
					printf " %4u\e[0m" "${tiempoRestante[$ord]}" | tee -a $informeColor

		 	 fi

			 if [[ " ${procesosMemoria[*]} " =~ " $ord " ]]
			 then
				 for marcoNuevo in ${!procesosMemoria[*]};do
					 if [[ ${procesosMemoria[$marcoNuevo]} -eq $ord ]]
					 then
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
			if [[ ${tLlegada[$ord]} -le $tSistema ]]
				then
				#	printf " %4u\e[0m" "${tiempoRestante[$ord]}" | tee -a $informeColor
					if [[ ${tiempoRestante[$ord]} -eq 0 ]]
						then
							echo -n -e " \e[1;3${colorines[$ord]}mFinalizado\e[0m       " | tee -a $informeColor
							echo -n "Estado: Finalizado  " >> $informe
						else
						
							if [[ ord -eq $ejecutando ]]
								then			
									echo -n -e " \e[1;3${colorines[$ord]}mEn ejecución\e[0m    " | tee -a $informeColor
									echo -n "Estado: En ejecución " >> $informe
								else
									if [[ ${enMemoria[$ord]} != "dentro" ]]
										then
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
						

									
			#Imprime las páginas (LRU)
			let ord=${ordenados[$counter]}
			echo -n " "
			
			
			xx=0
			         #         echo -n "|${npagejecutadas[$ord]}|"
			for (( v = 1; v <  ${npagejecutadas[$ord]} ; v++ ))
				do
					
					echo -ne "\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m" | tee -a $informeColor
					echo -n " " | tee -a $informeColor
					echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
					echo -n " " >> $informe
					((xx++))
				done
	if [[ ord -eq $ejecutando && ${tLlegada[$ord]} -le $tSistema && $finalizados -ne $nProc ]]
	then
		
		                        for (( v = 0; v <=  ${npagaejecutar[$ord]} ; v++ ))
                                do
                                #       echo -n "/${tachado[$ord]}/"
                                        echo -ne "\e[4m\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m\e[0m" | tee -a $informeColor

                                        echo -n " " | tee -a $informeColor
                                        echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
                                        echo -n " " >> $informe
                                        ((xx++))
                                done
				                        for (( v = 1; v <  ${tiempoRestante[$ord]} ; v++ ))
                                do
                                                                                echo -ne "\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m" | tee -a $informeColor

                                        echo -n " " | tee -a $informeColor
                                        echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
                                        echo -n " " >> $informe
                                        ((xx++))
                                done

			

	else
		
 			for (( v = 0; v <  ${npagaejecutar[$ord]} ; v++ ))
				do
				#	echo -n "/${tachado[$ord]}/"
				        echo -ne "\e[4m\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m\e[0m" | tee -a $informeColor

					echo -n " " | tee -a $informeColor
					echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
					echo -n " " >> $informe
					((xx++))
				done
				                        for (( v = 0; v <  ${tiempoRestante[$ord]} ; v++ ))
                                do
                                                                                echo -ne "\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m" | tee -a $informeColor

                                        echo -n " " | tee -a $informeColor
                                        echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
                                        echo -n " " >> $informe
                                        ((xx++))
                                done

			fi
		
	#			for (( v = 0; v <  ${tiempoRestante[$ord]} ; v++ ))
	#				do
	#					                                        echo -ne "\e[1;3${colorines[$ord]}m${direcciones[$ord,$xx]}-\e[1;3${colorines[$ord]}m${paginas[$ord,$xx]}\e[0m" | tee -a $informeColor
	#
	#					echo -n " " | tee -a $informeColor
	#					echo -n "${direcciones[$ord,$xx]}-${paginas[$ord,$xx]}" >> $informe
	#					echo -n " " >> $informe
	#					((xx++))
	#				done
	#			
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


resumenfinal(){

	media 'esperaSinLlegada[@]'
	mediaespera=$laMedia
	media 'duracion[@]'
	mediadura=$laMedia
	laMedia=0
	#	clear
	#	echo "" >> $informe
	#	echo "" >> $informe
	#	echo "" >> $informe
	#	echo "" >> $informe
	#	echo "" >> $informe
	#	echo "" >> $informe
	#	echo "" >> $informe
	#	echo "" | tee -a $informeColor
	#	echo "" | tee -a $informeColor
	#	echo -e " T.Espera:    Tiempo que el proceso no ha estado ejecutándose en la CPU desde que entra en memoria hasta que sale" | tee -a $informeColor
	#	echo -e " Inicio/Fin:  Tiempo de llegada al gestor de memoria del proceso y tiempo de salida del proceso" | tee -a $informeColor
	#	echo -e " T.Retorno:   Tiempo total de ejecución del proceso, incluyendo tiempos de espera, desde la señal de entrada hasta la salida" | tee -a $informeColor
	#	echo -e " Fallos Pág.: Número de fallos de página que han ocurrido en la ejecución de cada proceso" | tee -a $informeColor
	#echo "" | tee -a $informeColor
	#echo "" | tee -a $informeColor
	echo -e " Resumen final con tiempos de ejecución y fallos de página de cada proceso" | tee -a $informeColor
	#echo "" | tee -a $informeColor
	#echo "" | tee -a $informeColor
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
	#echo "" >> $informe
	#echo "" >> $informe
	echo "Resumen final con tiempos de ejecución y fallos de página de cada proceso" >> $informe
	#echo "" >> $informe
	#echo "" >> $informe
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
	#echo "" | tee -a $informeColor
	#echo "" | tee -a $informeColor
	#echo "" >> $informe
	#echo "" >> $informe
}


############



sumaTiempoEspera(){
	for (( counter=1; counter <= $nProc; counter++ ))
		do
			if [[ $counter -ne $ejecutando || $1 -eq 1 ]] && [[ ${tiempoRestante[$counter]} -ne 0 ]]
				then
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
                                                 printf "M%-2sf-%3d-%d" "$m" "${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]}" "${procesoTiempoMarcoSegunda[$ejecutandoAntiguo,$r,$m]}"
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

						printf "M%-2sf-%3d-%d" "$m" "${procesoTiempoMarcoPagina[$ejecutandoAntiguo,$r,$m]}" "${procesoTiempoMarcoSegunda[$ejecutandoAntiguo,$r,$m]}"
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


############


calculaNRU(){
	contadorMax=0
	posicionContadorMax=0
	for (( o = 0; o < ${nMarcos[$1]}; o++  ))
		do
			if [[ $contadorMax -lt ${contador[$1,$o]} ]]
				then
					contadorMax=${contador[$1,$o]}
					posicionContadorMax=$o
			fi
		done


}


############


imprimeNRU(){

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
	
	#Imprime la fila de procesos
	
	marcosPintados=0
	#filaProc=" Proceso:    "
	#filaProcInf="Proceso:    "
        for (( marcoNuevo = 0; marcoNuevo < $marcosMem; marcoNuevo++ ))
                do
                        if [[ -n "${procesosMemoria[$marcoNuevo]}" ]]
                                then
                                        ord=${procesosMemoria[$marcoNuevo]}
                                        if [[ $ord -lt 10 ]]
                                               then
                                                       filaProc="${filaProc} P0$ord-"
                                               else
                                                       filaProc="${filaProc} P$ord-"
                                        fi
                                        for (( i = 1; i < ${nMarcos[$ord]}; i++))
                                        do
                                                filaProc="${filaProc}-----"
                                        done
                                                marcoNuevo=$(($marcoNuevo+${nMarcos[$ord]}-1))
					#	filaProc="${filaProc} "
                                else
                                        filaProc="${filaProc} ----"


                        fi
                done

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
	
	
	#Imprime la fila de marcos
	
	marcosPintados=0
	#filaMarc="Nº Marco:   "
	#filaMarcInf="Nº Marco:   "
	for (( counter = 1; counter <= $nProc ; counter++ ))
		do
			ord=${ordenados[$counter]}
			if [[ ${enMemoria[$ord]} == "dentro" ]]
				then
					calculaNRU $ord
					filaMarc="${filaMarc}  M0  "
					((marcosPintados++))
			for (( m = 1; m < 20 ; m++ ))
				do
				if [[ $m -lt 10 ]]
					then
					  filaMarc="${filaMarc} M$m  "
					
					else
					  filaMarc="${filaMarc} M$m "
				fi
					((marcosPintados++))
						done
					
					#filaMarc="${filaMarc}"
			fi
		done
	if [[ $marcosPintados -lt $marcosMem ]]
		then
			until [[ $marcosPintados -eq $marcosMem ]]
				do
				
			filaMarc="  M0   M1   M2   M3   M4   M5   M6   M7   M8   M9   M10  M11  M12  M13  M14  M15  M16  M17  M18  M19"
							
							((marcosPintados++))
					
					done
	fi
	filaMarc="${filaMarc} "
	
	
	#Imprime la fila de páginas
	
	marcosPintados=0
	#filaPag="Página:     "
	#filaPagInf="Página:     "
	
	#vectorNuevo=("${procesosMemoria[*]}")
	for (( counter = 1; counter <= $nProc; counter++ ))
		do
			ord=${ordenados[$counter]}
		        if [[ $ord -eq $ejecutando ]]
			then
				if [[ ${enMemoria[$ord]} == "dentro" ]]
		                then
					if [[ ${paginasUso[$ord,0]} == "vacio" ]]
						then
							filaPag="${filaPag}$(printf "%5u" "${paginas[$ord,0]}")"
						else
							filaPag="${filaPag}$(printf "%5u" "${paginasUso[$ord,0]}")"
					fi
					((marcosPintados++))
					for (( m = 1; m < ${nMarcos[$ord]} ; m++ ))
						do
							if [[ ${paginasUso[$ord,$m]} == "vacio" ]]
								then
									filaPag="${filaPag}$(printf -- "-----")"
								else
									filaPag="${filaPag}$(printf "%5u" "$paginasUso[$ord,$m]}")"		
							fi
							((marcosPintados++))
						done
						#filaPag="${filaPag}"
			fi
		fi
		done
	
	if [[ $marcosPintados -lt $marcosMem ]]
		then
			until [[ $marcosPintados -eq $marcosMem ]]
				do
					filaPag="${filaPag}-----"   
					((marcosPintados++))
				done
	fi
	filaPag="${filaPag}|"
		
	
	#imprime la fila de las direcciones de memoria
	
	marcosPintados=0
	memPintada=0
	#filaDir="Dir. Mem.:  "
	#filaDirInf="Dir. Mem.:  "
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
					
					#filaDir="${filaDir}"
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
	#filaCont="Contador:   "
	#filaContInf="Contador:   "
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
	
	
	
	#guarda los coloresNRU
	
	#for ((n=1; n<=13; n++ ))
		#do
			#coloresNRU[$n]="\e[1;4;32m"
		#done
	#n=14
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
	
	until [[ $longImprimeNRU -le 0 ]]
		do
			if [[ $longImprimeNRU -le $colsTerminal ]]
				then
					imprimeAhora=$(($longImprimeNRU-2))
				else
					imprimeAhora=$(($colsTerminal-2))
			fi
			
			if [[ $veces -eq 0 ]]
				then
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
		

		
					#echo -e "$filaProc"
					#echo -e "$filaMarc"
					#echo -e "$filaPag"
					#echo -e "$filaDir"
					#echo -e "$filaCont"

	#FALTA AÑADIR LA PARTE DE INFORME Y INFORMECOLOR
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
													marcoIntroducido=marcoNuevo

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
	u=0;

	u=0
	until [[ ${cola[$u]} == "vacio" ]]
		do
			((u++))
		done
	((u--))
	
	for (( n=0; n<$u; n++ ))
		do
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

############


imprimeCola(){
	u=0;

	u=0
	until [[ ${cola[$u]} == "vacio" ]]
		do
			((u++))
		done
		
	#echo "" | tee -a $informeColor
	echo -n "A continuación:  " >> $informe
	
	#					if [[ $ejecutando -lt 10 ]]
	#						then
	#							echo -n -e "\e[1;3${colorines[$ejecutando]}mP0$ejecutando\e[0m " | tee -a $informeColor
	#							echo -n "P0$ejecutando " >> $informe
	#						else
	#							echo -n -e "\e[1;3${colorines[$ejecutando]}mP$ejecutando\e[0m " | tee -a $informeColor
	#							echo -n "P$ejecutando " >> $informe
	#					fi
					
	#	for ((n=0; n<$u; n++ ))
	#		do
	#					if [[ ${cola[$n]} -lt 10 ]]
	#						then
	#							echo -n -e " \e[1;3${colorines[${cola[$n]}]}mP0${cola[$n]}\e[0m " | tee -a $informeColor
	#							echo -n " P0${cola[$n]} " >> $informe
	#						else
	#							echo -n -e " \e[1;3${colorines[${cola[$n]}]}mP${cola[$n]}\e[0m " | tee -a $informeColor
	#							echo -n " P${cola[$n]} " >> $informe
	#					fi
	#			fi
	#		done
		#echo "" | tee -a $informeColor
		#echo "" >> $informe
}

############


FCFS(){
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
			
	i=0;#??
	
	for (( i = 1; i <= $nProc; i++ )); do
		let contadorPagGlob[$i]=0
	done
			
	i=0;#??
	
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

	if [[ ${tLlegada[${ordenados[1]}]} -gt 0 ]]; then

		ejecutando=${ordenados[1]}
		aumento=${tLlegada[$primerproceso]}
		sumaTiempoEspera 1
		if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]; then
			clear
			imprimeTiempo
			diagramaresumen
			imprimeNRU
			diagramaMemoria
			lineadetiempoCero 0

			if [[ $opcionEjec = 2 ]]; then
				sleep $segEsperaEventos
			else
				read -p " Pulse INTRO para continuar"
			fi
		fi
		tSistema=${tLlegada[$ejecutando]}
		#time_primero=${tLlegada[$ejecutando]}      ???????????????????????????????????????????
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
			diagramaresumen
			imprimeNRU
			diagramaMemoria
				#diagramaTiempo
			lineadetiempo
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
				diagramaresumen
				imprimeNRU
				diagramaMemoria
				#diagramaTiempo
				lineadetiempoCero 1
				if [[ $opcionEjec = 2 ]]; then
					sleep $segEsperaEventos
				else
					read -p " Pulse INTRO para continuar"
		
				fi 
			fi
	fi
	
	ejecutando=${cola[0]}
	mueveCola
	
	while [ $seAcaba -eq 0 ]
		do
		
			if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]; then
				clear
				#echo "" >> $informe
				#echo "" >> $informe
				#echo "" >> $informeColor
				#echo "" >> $informeColor
			fi
			#ejecutando=${ordenados[$position]}
			
			if [ $finalizados -ne $nProc ]; then #Cambio de contexto
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
					diagramaresumen
			fi
			
			
			nru                ############################################################################## I # M # P # O # R # T # A # N # T # E ##############################################################################
			sumaNPaginas

			if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
				then
					diagramaMemoria
					#diagramaTiempo
					lineadetiempo
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
	#resumenfinal
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
	echo " Presione INTRO para continuar"
	read
	clear
	echo -e " Fin del algoritmo" | tee -a $informeColor
	echo " Presione INTRO para continuar"
	read
	clear
	#guardaDatos
	clear
	#	if [[ -f ayuda.txt ]]
	#		then
	#			rm ayuda.txt
	#	fi
	#	echo ""
	#	echo -e "\e[1;31mBorrados los ficheros temporales\e[0m"
	#	echo ""
	#	
	#	echo "" >> fichero.txt
	#	echo "Borrados los ficheros temporales" >> fichero.txt
	#	echo "" >> fichero.txt
	
	printf "\n$_cyan$_b%s\n\n$_rst"		" Por último, ¿desea abrir el informe? (s/n)"
	read abrirInforme
	
	until [[ $abrirInforme =~ ^[nNsS]$ ]]; do
		printf "\n$_red$_b%s$_rst%s"	" Entrada no válida." " Escriba 's' (SI) o 'n' (NO): "
		read abrirInforme
	done

	if [[ $abrirInforme =~ ^[sS]$ ]]; then
		clear		
		echo ""
		echo ""
		echo "  ¿Con qué editor desea abrir el informe?"
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
	sleep 1
}

###################################################################################################################################

# NO USADO?? (solo comentado) -> guardaDatosAleatorios() en su lugar.
guardaDatos(){

	#echo ""
	#echo ""
	clear
	cabeceraInicio
	echo -n -e " El nombre del fichero donde se guardarán los datos es datos.txt. Si quiere cambiar\n"
	echo -n -e " el nombre, por favor, introduzca una s (s=si) o n (n=no) si desea dejarlo de esta manera:\n"
       	read -p " Seleccione opción: " elegirInforme
        until [[ "$elegirInforme" == "s" || "$elegirInforme" == "n" ]]
                do
                        echo ""
                        echo -e -n "\e[1;31mValor incorrecto, escriba \e[1;33ms\e[0m \e[1;31mo\e[0m \e[1;33mn\e[0m\e[1;31m: \e[0m"
                        read elegirInforme
                done
        if [[ "$elegirInforme" == "s" ]]
                then
                        clear
                      	echo -n -e " Introduzca el nombre del fichero donde se guardarán los datos de la práctica (sin incluir \".txt\"): "
			read ficheroOut
			ficheroOut="./datosScript/${ficheroOut}.txt"
			touch $ficheroOut
			
			
			echo "$tamMem" > $ficheroOut
			echo "$tamPag" >> $ficheroOut
			#echo "$nProc" >> $ficheroOut
			
			
			
	
	
	
	
	
	for(( i = 1; i <= $nProc; i++ ))
		do
			echo -n "${tLlegada[$i]};" >> $ficheroOut
			#echo -n "${tEjec[$i]};" >> $ficheroOut
			echo -n "${nMarcos[$i]};;" >> $ficheroOut
			for (( n = 0; n < ${maxPags[$i]}; n++ ))
				do
					echo -n "${direcciones[$i,$n]};" >> $ficheroOut
				done
			echo "" >> $ficheroOut
		done
	#echo "
	echo -e " Se han guardado los datos en el fichero de salida: "
	#echo ""

	else
		          
                        clear
                        
                        ficheroOut="./datosScript/datos.txt"
                        touch $ficheroOut
                        echo "$tamMem" > $ficheroOut
                        echo "$tamPag" >> $ficheroOut
                        #echo "$nProc" >> $ficheroOut

        for(( i = 1; i <= $nProc; i++ ))
                do
                        echo -n "${tLlegada[$i]};" >> $ficheroOut
                        #echo -n "${tEjec[$i]};" >> $ficheroOut
                        echo -n "${nMarcos[$i]};;" >> $ficheroOut
                        for (( n = 0; n < ${maxPags[$i]}; n++ ))
                                do
                                        echo -n "${direcciones[$i,$n]};" >> $ficheroOut
                                done
                        echo "" >> $ficheroOut
                done
        #echo ""
        echo -e " Se han guardado los datos en el fichero de salida"


	fi
	ultimoficheroman=`echo ${ficheroOut} | cut -d "/" -f3`
	echo "" | tee -a $informeColor

	echo "" >> $informe		
	echo -e " Elija un \e[1;32mfichero\e[0m: " >> $informeColor
	echo -n " Elija un fichero: " >> $informe	
	echo "$ultimoficheroman" >> $informe
	echo -e "\e[1;32m$ultimoficheroman\e[0m" >> $informeColor
}	

###################################################################################################################################

# Guarda los datos que se han introducido en el fichero que el usuario desee.
function guardaDatosAleatorios(){
	clear
	cabeceraInicio
	printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Dónde quiere guardar los datos?"
	printf "\t$_green%s$_rst%s\n"		"[1]" " -> En la salida estándar (datos.txt)"
	printf "\t$_green%s$_rst%s\n\n"		"[2]" " -> En otro fichero"
	read -p " Seleccione opción: " elegirGuardarDatos
    until [[ $elegirGuardarDatos =~ ^[1-2]$ ]]; do
        echo ""
        echo -e -n "\e[1;31mValor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
        read elegirGuardarDatos
    done

	case $elegirGuardarDatos in
		1)	# Muestra la opción 1 seleccionada.
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Dónde quiere guardar los datos?"
			printf "\t$_sel%s%s$_rst\n"			"[1]" " -> En la salida estándar (datos.txt)"
			printf "\t$_green%s$_rst%s\n\n"		"[2]" " -> En otro fichero"
			sleep 0.3
			;;
		2)	# Muestra la opción 2 seleccionada.
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Dónde quiere guardar los datos?"
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> En la salida estándar (datos.txt)"
			printf "\t$_sel%s%s$_rst\n\n"		"[2]" " -> En otro fichero"
			sleep 0.3
			printf "Introduzca el nombre del fichero donde se guardarán los datos de la práctica (sin incluir '.txt'): "
			read nombreOtroFichero
			clear
			;;
	esac
                        
    ficheroOut="./datosScript/datos.txt"
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
        echo -e " Se han guardado los datos en el fichero de salida."
        
    if [[ "$elegirGuardarDatos" == "2" ]]; then
        cp "${ficheroOut}" "./datosScript/${nombreOtroFichero}.txt"
	fi

	ultimoficheroman=`echo ${ficheroOut} | cut -d "/" -f3`
	echo "" | tee -a $informeColor

	echo "" >> $informe		
	echo -e " Elija un \e[1;32mfichero\e[0m: " >> $informeColor
	echo -n " Elija un fichero: " >> $informe	
	echo "$ultimoficheroman" >> $informe
	echo -e "\e[1;32m$ultimoficheroman\e[0m" >> $informeColor
}

###################################################################################################################################

# Guarda los rangos que se han introducido en el fichero que el usuario desee.
function guardaRangos(){
	
	local nombreFicheroRangos="datosrangos"
	clear
	cabeceraInicio
	printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Dónde quiere guardar los rangos?"
	printf "\t$_green%s$_rst%s\n"		"[1]" " -> En la salida estándar (datosrangos.txt)"
	printf "\t$_green%s$_rst%s\n\n"		"[2]" " -> En otro fichero"
	read -p " Seleccione opción: " elegirGuardarRangos
    until [[ $elegirGuardarRangos =~ ^[1-2]$ ]]; do
        echo ""
        echo -e -n "\e[1;31mValor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
        read elegirGuardarRangos
    done

	case $elegirGuardarRangos in
		1)	# Muestra la opción 1 seleccionada.
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Dónde quiere guardar los rangos?"
			printf "\t$_sel%s%s$_rst\n"			"[1]" " -> En la salida estándar (datosrangos.txt)"
			printf "\t$_green%s$_rst%s\n\n"		"[2]" " -> En otro fichero"
			sleep 0.3
			;;
		2)	# Muestra la opción 2 seleccionada.
			clear
			cabeceraInicio
			printf "\n$_cyan$_b%s\n\n$_rst"		" ¿Dónde quiere guardar los rangos?"
			printf "\t$_green%s$_rst%s\n"		"[1]" " -> En la salida estándar (datosrangos.txt)"
			printf "\t$_sel%s%s$_rst\n\n"		"[2]" " -> En otro fichero"
			sleep 0.3
			printf "Introduzca el nombre del fichero donde se guardarán los rangos de la práctica (sin incluir '.txt'): "
			read nombreOtroFicheroRangos
			clear
			;;
	esac
				
	ficheroRangos="./datosScript/rangos/${nombreFicheroRangos}.txt"
	
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
	
	if [[ "$elegirGuardarRangos" == "2" ]]; then
        cp "${ficheroRangos}" "./datosScript/rangos/${nombreOtroFicheroRangos}.txt"
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
cabecera(){
	clear
	echo ""
	echo -e " \e[1;48;5;85m                                                  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m                                              \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m            PRÁCTICA DE CONTROL               \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m      GRADO EN INGENIERÍA INFORMÁTICA         \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m    FCFS/SJF - PAGINACIÓN - S.OPORTUNIDAD     \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m       MEMORIA CONTINUA - NO REUBICABLE       \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m                                              \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m     Autores: César Rodríguez Villagrá        \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m          Rodrigo Pérez Ubierna               \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m                                              \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m                                              \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m       Sistemas Operativos 2º Semestre        \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m Grado en ingeniería informática (2021-2022)  \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m                                              \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m       Tutor: Jose Manuel Saiz Diez           \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m  \e[0m                                              \e[1;48;5;85m  \e[0m"
	echo -e " \e[1;48;5;85m                                                  \e[0m"
	echo ""

	read -p " Pulse INTRO para continuar. "
	clear
}

############


cabeceraInicio(){
#Muestra la cabecera de inicio del programa indicando que es un algoritmo de gestión de memoria virtual
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

############


cabeceraInforme(){

	echo "###################################################" > $informe
	echo "#                                                 #" >> $informe
	echo "#             PRÁCTICA DE CONTROL                 #" >> $informe
	echo "#        GRADO EN INGENIERÍA INFORMÁTICA          #" >> $informe
	echo "#     FCFS/SJF - PAGINACIÓN - S. OPORTUNIDAD      #" >> $informe
	echo "#						  #" >> $informe
	echo "#        MEMORIA CONTINUA - NO REUBICABLE	  #" >> $informe
	echo "#						  #" >> $informe
	echo "#        Autores:  César Rodríguez Villagrá       #" >> $informe
	echo "#                Hugo de la Cámara Saiz           #" >> $informe
	echo "#		Rodrigo Pérez Ubierna		  #" >> $informe
	echo "#						  #" >> $informe	
	echo "#        Sistemas Operativos 2º Semestre          #" >> $informe
	echo "#   Grado en Ingeniería Informática (2021-2022)   #" >> $informe
	echo "#						  #" >> $informe
	echo "#        Tutor: Jose Manuel Saiz Diez             #" >> $informe
	echo "#                                                 #" >> $informe
	echo "###################################################" >> $informe
	echo "" >> $informe
	echo "" >> $informe
	echo "" >> $informe
	echo "####################################################" >> $informe
	echo "#                                                  #" >> $informe
	echo "#               INFORME DE PRÁCTICA                #" >> $informe
	echo "#           GESTIÓN DE MEMORIA VIRTUAL             #" >> $informe
	echo "#       -----------------------------------        #" >> $informe
	echo "#       -----------------------------------        #" >> $informe
	echo "#                                                  #" >> $informe
	echo "####################################################" >> $informe
	echo "" >> $informe
	
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

############


cabeceraFinal(){
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

############

# Indica al usuario que el tamaño recomendado para la visualización del programa es la pantalla completa.
function imprimeTamanyoRecomendado(){
	
	printf "\n%s\n"		" Para una correcta visualización del programa se recomienda poner el terminal en pantalla completa."
	read -p " Pulse INTRO cuando haya ajustado el tamaño."
	clear
	cabeceraInicio
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
	cabecera
	cabeceraInicio
	imprimeTamanyoRecomendado
	menuInicio
	sed -i 's/\x0//g' ${informe}			# Limpia los caracteres NULL que se han impreso en el informe.
	sed -i 's/\x0//g' ${informeColor}		# Limpia los caracteres NULL que se han impreso en el informeColor.
}

### Ejecución programa ###
main