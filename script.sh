#!/bin/bash


#Variables
#Cada vez que se dice que una variable ha sido utilizada en X funcion,
#quiere decir que se utiliza por primera vez en esa funcion,
#luego puede utilizarse en más partes del programa

#Globales
p=0;								#Utilizada en todo el programa, son los Procesos
tamMem=0;							#Utilizada en todo el programa, es el tamaño de la memoria total
marcosMem=0;						#Utilizada en todo el programa, es el número de marcos que caben en la memoria
tamPag=0;							#Utilizada en todo el programa, es el tamaño de las páginas
ord=0;								#Utilizada en todo el programa, son los procesos ordenados según orden de llegada
nProc=0; 							#Utilizada en todo el programa, es el número total de procesos

#Globales generales
bool=0;								#Utilizado en varias funciones como booleano auxiliar
counter=0;							#Utilizado en varias funciones como contador para bucles etc
letra="a";							#Utilizado en varias funciones que piden que se escriba s o n
#variable del main
#ficheroant="`grep -lior 'fichero: ' ./datosScript/informes | cut -d "/" -f4 | cut -d "." -f1`.txt"		#busca el anterior informe generado

#imprimeprocesos
improcesos=0;						#Utilizada en las funciones imprimeProcesos, para imprimir las lineas de procesos
impaginillas=0;						#Utilizada en las funciones imprimeProcesos, para imprimir las páginas de cada proceso
maxpaginas=0;

#asignaColores
color=0;							#Utilizada para inicializar el vector de colores

#ordenacion
pep=0;								#Utilizado en la funcion ordenacion, para inicializar el vector ordenados con los datos correspondientes
kek=0;								#Utilizado en la funcion ordenacion, para recorrer todos los procesos y asignar el nro de procesos al vector ordenados
jej=0;								#Utilizado en la funcion ordenacion, para recorrer todos los procesos y comprar sus tiempos de llegada
lel=0;								#Utilizado en la funcion ordenacion, para recorrer los procesos ya ordenados y comparar si el actual proceso ha sido ordenado ya
aux=0;								#Utilizado en la funcion ordenacion, para recoger el dato del proceso que se va a introducir en el vector ordenados
max=0;								#Utilizado en la funcion ordenacion, para guardar el dato actual del Maximo tiempo de llegada
one=0;								#Utilizado en la funcion ordenacion, como booleano para comprobar si el actual proceso ha sido ordenado ya

#menuInicio
menu=0;								#Utilizada en la funcion menuInicio, para elegir el algoritmo o la ayuda

#seleccionInforme
informe="./datosScript/informes/informeBN.txt";							#el nombre del fichero donde se guardará el informe
informeColor="./datosScript/informes/informeCOLOR.txt";						#el nombre del fichero donde se guardará el informe a color

#seleccionEntrada
opcionIn=0; 						#selecciona si introducir los datos por fichero o por teclado

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

#entradaTeclado
otroProc='s';						#Utilizada en la funcion datosteclado, para comprobar si se quiere introducir o no un nuevo proceso

#diagramaMemoria
xex=0;								#Utilizada en la funcion diagramaMemoria, para recorrer nro de hashtag a imprimir
yey=0;								#Utilizada en la funcion diagramaMemoria, para imprimir la barra de debajo
tamHashtag=0;						#Utilizada en la funcion diagramaMemoria, para tener el valor numérico exacto de cada unidad de memoria
hashtagPorProceso=();				#Utilizada en la funcion diagramaMemoria, el número entero truncado de lo que ocupa cada proceso

#FCFS
primerproceso=0;					#Proceso que llega primero
tSistema=0;							##Tiempo actual del sistema
fef=0;								#Utilizado Bucles
nProcEnMemoria=0;
seAcaba=0;
laMedia=0;

#vectores
esperaconllegada=();				#Tiempo de espera de cada proceso incluyendo el tiempo de llegada
esperasinllegada=();				#Tiempo de espera de cada proceso sin incluir el tiempo de llegada
enMemoria=();						#Vale "fuera" si el proceso no está en memoria, "dentro" si el proceso está en memoria y "salido" si acabó

colorines=();						#Utilizado en varias funciones para colorear los procesos

tLlegada=();						#Vector que recoge los tiempos de llegada
tEjec=();							#Vector que recoge los tiempos de ejecución
tamProceso=();						#Vector que recoge los tamaños mínimos estructurales
nMarcos=(); 						#Vector que recoge la cantidad de marcos de cada proceso
ordenados=();						#Vector que recoge los procesos en ordenacion
npagprocesos=();					#Vector que recoge el número de páginas por proceso
maxpags=();							#Vector que recoge el número máximo de páginas de los procesos
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
#npagprocesos[$ejecutando]=maxpags[$ejecutando]

max=0;
i=0;
fichSelect=0;

	ordenados=() #Guarda el nº de los procesos en orden de llegada.
	count=0; #Para movernos por el vector ordenados.
	acabado=0;   #Indica cuando se ha acabado de ordenar los procesos.
	nproceso=0;


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

espaciosMemoria=()
procesosMemoria=()
tamEspacioGrande=0

declare -A procesoTiempoMarcoPagina 	# procesoTiempoMarcoPagina[$p,$t,$m]=pagina
declare -A procesoTiempoMarcoPuntero
declare -A procesoTiempoMarcoSegunda


############


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


############


calcularEspacios(){
	tamEspacioGrande=0
	posicionInicial=0
	espaciosMemoria=()
	for (( i=0; i < $marcosMem; i++))
		do
			if [[ " ${!procesosMemoria[*]} " =~ " $i " ]]
				then
					if [[ ${espaciosMemoria[$posicionInicial]} -gt $tamEspacioGrande ]]
						then
							tamEspacioGrande=${espaciosMemoria[$posicionInicial]}
					fi
					procesoActual=${procesosMemoria[$i]}
					i=$(($i+${nMarcos[$procesoActual]}-1))
					posicionInicial=$i+1
				else
					if [[ -z "${espaciosMemoria[$i]}" ]] && [[ $posicionInicial -eq $i ]]
						then
					#		posicionInicial=$i
							espaciosMemoria[$posicionInicial]=0 
					fi
					((espaciosMemoria[$posicionInicial]++))
			fi

		done
#			echo "${procesosMemoria[*]}/${espaciosMemoria[*]}"
                        if [[ ${espaciosMemoria[$posicionInicial]} -gt $tamEspacioGrande ]]
	                        then
        	                        tamEspacioGrande=${espaciosMemoria[$posicionInicial]}
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

cabecera(){
#Muestra la cabecera de la script
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


imprimeTamano(){
#Indica al usuario que ajuste el tamaño deseado de la ventana para mostrar los datos correctamente, recomendadndo ponerlo en pantalla completa
	echo ""
	echo -e " Para una correcta visualización del programa se"
	echo -e " recomienda poner el terminal en pantalla completa."
	echo ""
	read -p " Pulse INTRO cuando haya ajustado el tamaño."
	clear
	cabeceraInicio
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


menuInicio(){
#Muestra el primer menú en el que permite elegir entre la ayuda y ejecutar el algoritmo, en caso de meter una opción incorrecta te lo indica y vuelve a preguntar	
	clear
	cabeceraInicio
	echo ""
	echo -e "\e[1;38;5;81m ¿Desea leer el fichero de ayuda o ejecutar el algoritmo?\e[0m"
	echo ""
	echo -e "    \e[1;32m   [1]\e[0m -> Ejecutar el algoritmo	"
	echo -e "    \e[1;32m   [2]\e[0m -> Visualizar la ayuda	"
	echo ""
	read -p " Seleccione la opción: " menu
	until [[ "$menu" = "1" || "$menu" = "2" ]]
		do
			echo ""
			echo -e -n "\e[1;31m Valor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
			read menu
		done
		echo
	if [ "$menu" = 2 ]
		then
			clear
			cabeceraInicio
			echo ""
			echo -e "\e[1;38;5;81m ¿Desea leer el fichero de ayuda o ejecutar el algoritmo?\e[0m"
			echo ""
			echo -e "    \e[1;32m   [1]\e[0m -> Ejecutar el algoritmo   "
			echo -e "    \e[1;38;5;64;48;5;7m   [2]\e[90m -> Visualizar la ayuda	\e[0m"
			echo ""
			sleep 0.5

		else
			clear
			cabeceraInicio
			echo ""
			echo -e "\e[1;38;5;81m ¿Desea leer el fichero de ayuda o ejecutar el algoritmo?\e[0m"
			echo ""
			echo -e "    \e[1;38;5;64;48;5;7m   [1]\e[90m -> Ejecutar el algoritmo   \e[0m"
			echo -e "    \e[1;32m   [2]\e[0m -> Visualizar la ayuda	"
			echo ""
			sleep 0.5
	fi
}


############


seleccionInforme(){
#Muestra al usuario el nombre por defecto de los informes que se generan al ejecutar el script, dando la opotunidad al usuario de cambiarlos
	clear
	cabeceraInicio
	echo ""
	echo -e "\e[1;38;5;81m Los nombres por defecto de los informes son:\e[0m \e[1;32minformeBN.txt\e[0m \e[1;38;5;81me\e[0m \e[1;33minformeCOLOR.txt\e[0m"
	echo -e "\e[1;38;5;81m ¿Desea cambiarlos?\e[0m"
	echo ""
	echo -e "    \e[1;32m   [1]\e[0m -> Sí	"
	echo -e "    \e[1;32m   [2]\e[0m -> No	"
	echo ""
	read -p " Seleccione la opción: " cambiarInformes
	until [[ "$cambiarInformes" == "1" || "$cambiarInformes" == "2" ]]
		do
			echo ""
			echo -e -n "\e[1;31mValor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
			read cambiarInformes
		done
	if [[ "$cambiarInformes" == "1" ]]
		then
			clear
			cabeceraInicio
			echo ""
			echo -e "\e[1;38;5;81m Los nombres por defecto de los informes son:\e[0m \e[1;32minformeBN.txt\e[0m \e[1;38;5;81me\e[0m \e[1;33minformeCOLOR.txt\e[0m"
			echo -e "\e[1;38;5;81m ¿Desea cambiarlos?\e[0m"
			echo ""
			echo -e "    \e[1;38;5;64;48;5;7m   [1]\e[90m -> Sí   \e[0m"
			echo -e "    \e[1;32m   [2]\e[0m -> No	"
			echo ""
			sleep 0.5
			clear
			cabeceraInicio
			echo ""
			echo -n -e "\e[1m Por favor introduzca el nombre del informe de texto plano \e[31m(sin incluir \".txt\")\e[0m: " 
			read informe
			informe="./datosScript/informes/${informe}.txt"
			sleep 0.2
			clear
			cabeceraInicio
			echo ""
			echo -n -e "\e[1m Por favor introduzca el nombre del informe a color \e[31m(sin incluir \".txt\")\e[0m: " 
			read informeColor
			informeColor="./datosScript/informes/${informeColor}.txt"
			sleep 0.2
			clear
		else
			clear
			cabeceraInicio
			echo ""
			echo -e "\e[1;38;5;81m Los nombres por defecto de los informes son:\e[0m \e[1;32minformeBN.txt\e[0m \e[1;38;5;81me\e[0m \e[1;33minformeCOLOR.txt\e[0m"
			echo -e "\e[1;38;5;81m ¿Desea cambiarlos?\e[0m"
			echo ""
			echo -e "    \e[1;32m   [1]\e[0m -> Sí	"
			echo -e "    \e[1;38;5;64;48;5;7m   [2]\e[90m -> No   \e[0m"
			echo ""
			sleep 0.5
			clear
	fi
#	echo "$informeColor  $informe"
#	sleep 2
	touch $informe				#crea el archivo en blanco con el nombre que tiene la variable informe
	touch $informeColor				#crea el archivo en blanco con el nombre que tiene la variable informeColor
	cabeceraInforme
	
}


############


seleccionEntrada(){
#permite al usuario introducir datos por teclado, datos de la última ejecucion o por fichero, llevando los datos a los ficheros de informe
	clear
	cabeceraInicio
	echo ""
	echo -e "\e[1;38;5;81m Introduzca una opción valida: \e[0m"
	echo ""
	echo -e "    \e[1;32m	[1]\e[0m -> Por teclado	"
	echo -e "    \e[1;32m	[2]\e[0m -> Fichero de datos de la última ejecución (datos.txt)"
	echo -e "    \e[1;32m	[3]\e[0m -> Otro fichero de datos	"
	echo -e "    \e[1;32m	[4]\e[0m -> Aleatorio manual	"
	echo -e "    \e[1;32m	[5]\e[0m -> Fichero de rangos de última  ejecución (datosrangos.txt)	"
	echo -e "    \e[1;32m	[6]\e[0m -> Otro fichero de rangos	"
	
		
	echo ""
	read -p " Seleccione una opción: " opcionIn
	until [[ "$opcionIn" == "1" || "$opcionIn" == "2" || "$opcionIn" == "3" || "$opcionIn" == "4" || "$opcionIn" == "5" || "$opcionIn" == "6" ]]
		do
			echo ""
			echo -e -n "\e[1;31m Valor incorrecto, escriba uno valido: \e[0m"
			read opcionIn
		done
		
	echo "  Seleccione una opción:  " >> $informe
	echo -e "\e[1;38;5;81m  Seleccione una opción: : \e[0m" >> $informeColor
	case $opcionIn in			#empieza un case (como un switch case) de la opcion introducida
	
		#caso 1
		"1")
		clear
		cabeceraInicio
		echo ""
		echo -e "\e[1;38;5;81m Seleccione una opción: : "
		echo ""
		echo -e "    \e[1;38;5;64;48;5;7m	[1]\e[90m -> Por teclado	\e[0m"
		echo -e "    \e[1;32m	[2]\e[0m -> Fichero de datos de la última ejecución (datos.txt)	"
		echo -e "    \e[1;32m	[3]\e[0m -> Otro fichero de datos	"
		echo -e "    \e[1;32m	[4]\e[0m -> Aleatorio manual	"
		echo -e "    \e[1;32m	[5]\e[0m -> Fichero de rangos de última  ejecución (datosrangos.txt)	"
		echo -e "    \e[1;32m	[6]\e[0m -> Otro fichero de rangos	"
			
		echo ""
		
		echo "" >> $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	[1]\e[90m -> Por teclado	\e[0m" >> $informeColor
		echo "" >> $informeColor
		echo "" >> $informe
		echo -e "	  -> Por teclado <-	" >> $informe
		echo "" >> $informe
		sleep 0.5
		entradaTeclado
		;;
		
		#caso 3
		"3")
		clear
		cabeceraInicio
		echo  ""
		echo -e "\e[1;38;5;81m Seleccione una opción: : "
		echo ""
		echo -e "    \e[1;32m	[1]\e[0m -> Por teclado	"
		echo -e "    \e[1;32m	[2]\e[0m -> Fichero de datos de la última ejecución (datos.txt)	"
		echo -e "    \e[1;38;5;64;48;5;7m	[3]\e[90m -> Otro fichero de datos	\e[0m"
		echo -e "    \e[1;32m	[4]\e[0m -> Aleatorio manual	" 
		echo -e "    \e[1;32m	[5]\e[0m -> Fichero de rangos de última  ejecución (datosrangos.txt)	"	
		echo -e "    \e[1;32m	[6]\e[0m -> Otro fichero de rangos	"
		echo ""
		
		echo "" >> $informeColor
		
		echo -e "    \e[1;32m	[1]\e[0m -> Por teclado	" >> $informeColor
		echo -e "    \e[1;32m	[2]\e[0m -> Fichero de datos de la última ejecución (datos.txt)	" >> $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	[3]\e[90m -> Otro fichero de datos	\e[0m" >> $informeColor
		echo -e "    \e[1;32m	[4]\e[0m -> Aleatorio manual	" >> $informeColor
		echo -e "    \e[1;32m	[5]\e[0m -> Fichero de rangos de última  ejecución (datosrangos.txt)	">> $informeColor
		echo -e "    \e[1;32m	[6]\e[0m -> Otro fichero de rangos	" >> $informeColor
		
		echo "" >> $informeColor
		echo "" >> $informe
		echo -e "    -> Otro fichero de datos" >> $informe
		
		
		echo "" >> $informe
		sleep 0.5
		entradaFichero
		;;
		#caso 2
		"2")
		clear
		cabeceraInicio
		echo  ""
		echo -e "\e[1;38;5;81m Seleccione una opción: : "
		echo ""
		echo -e "    \e[1;32m	[1]\e[0m -> Por teclado	"
		echo -e "    \e[1;38;5;64;48;5;7m	[2]\e[90m -> Fichero de datos de la última ejecución (datos.txt)	\e[0m"
		echo -e "    \e[1;32m	[3]\e[0m -> Otro fichero de datos	\e[0m"
		echo -e "    \e[1;32m	[4]\e[0m -> Aleatorio manual	"
		echo -e "    \e[1;32m	[5]\e[0m -> Fichero de rangos de última  ejecución (datosrangos.txt)	" 
		echo -e "    \e[1;32m	[6]\e[0m -> Otro fichero de rangos	"	
		
		echo ""
	
		echo "" >> $informeColor
		echo -e "    \e[1;32m	[1]\e[0m -> Por teclado	" >> $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m [2]\e[90m -> Fichero de datos de la última ejecución (datos.txt)	\e[0m" >> $informeColor
		echo -e "    \e[1;32m	[3]\e[0m -> Otro fichero de datos	" >> $informeColor
		
		echo "" >> $informeColor
		echo "" >> $informe
		echo -e "	     Por teclado 	" >> $informe
		echo -e "	  -> Fichero de datos de la última ejecución (datos.txt) <-" >> $informe
		echo -e "	     Otro fichero de datos 	" >> $informe
		echo "" >> $informe
		sleep 0.5
		clear
		entradaUltimo
		;;
		"4")
		clear
		cabeceraInicio
		echo ""
		echo -e "\e[1;38;5;81m Seleccione una opción: :: "
		echo ""
		echo -e "    \e[1;38;5;64;48;5;7m	[4]\e[90m ->  Aleatorio manual	\e[0m"
		echo ""
		
		echo "" >> $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Aleatorio manual	\e[0m" >> $informeColor
		echo "" >> $informeColor
		echo "" >> $informe
		echo -e "	  -> Aleatorio manual <-	" >> $informe
		echo "" >> $informe
		sleep 0.5
		entradaAleatorio
		;;
		
		
		
		
		
		
		
		
		
		"6")
		clear
		cabeceraInicio
		echo ""
		echo -e "\e[1;38;5;81m Seleccione una opción: :: "
		echo ""
		echo -e "    \e[1;38;5;64;48;5;7m	[6]\e[90m ->  Otro fichero de rangos	\e[0m"
		echo ""
		
		echo "" >> $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Otro fichero de rangos	\e[0m" >> $informeColor
		echo "" >> $informeColor
		echo "" >> $informe
		echo -e "	  -> Otro fichero de rangos <-	" >> $informe
		echo "" >> $informe
		sleep 0.5
		#entradaFicheroAleatorio
		entradaFicherorangos
		;;
		"5")
		clear
		cabeceraInicio
		echo ""
		echo -e "\e[1;38;5;81m Seleccione una opción: :: "
		echo ""
		echo -e "    \e[1;38;5;64;48;5;7m	[5]\e[90m ->  Fichero de rangos de última ejecucuion (datosrangos.txt)	\e[0m"
		echo ""
		
		echo "" >> $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Fichero de rangos de última ejecucuion (datosrangos.txt)	\e[0m" >> $informeColor
		echo "" >> $informeColor
		echo "" >> $informe
		echo -e "	  -> Fichero de rangos de última ejecucuion (datosrangos.txt) <-	" >> $informe
		echo "" >> $informe
		sleep 0.5
		entradarangoAleatorio
		;;
		
		
	esac				#cierre del case
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
#	read jehnafd

}


############






eligeTeclado(){
	local tecorand=0
	clear
	cabeceraInicio
	echo ""
	echo -e "\e[1;38;5;81m ¿Desea introducir los datos por teclado o aleatoriamente?: \e[0m"
	echo ""
	echo -e "    \e[1;32m	[1]\e[0m -> Por teclado	"
	echo -e "    \e[1;32m	[4]\e[0m -> Aleatoriamente manual	"
	echo ""
	read -p " Seleccione la opción: " tecorand
	until [[ "$tecorand" == "t" || "$tecorand" == "a" ]]
		do
			echo ""
			echo -e -n "\e[1;31m Valor incorrecto, escriba \e[1;33mt\e[0m \e[1;31mo\e[0m \e[1;33ma : \e[0m"
			read tecorand
		done
		
	echo " ¿Desea  introducir los datos por teclado o aleatoriamente? ( t / a): " >> $informe
	echo -e "\e[1;38;5;81m ¿Desea  introducir los datos por teclado o aleatoriamente? ( t / a): \e[0m" >> $informeColor
	
	case $tecorand in			#empieza un case (como un switch case) de la opcion introducida
	
		#caso t
		"t")
		clear
		cabeceraInicio
		echo ""
		echo -e "\e[1;38;5;81m ¿Desea  introducir los datos por teclado o aleatoriamente?: "
		echo ""
		echo -e "    \e[1;38;5;64;48;5;7m	[1]\e[90m -> Por teclado	\e[0m"
		echo -e "    \e[1;32m	[4]\e[0m -> Aleatoriamente manual	"
		echo ""
		
		echo "" >> $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	[1]\e[90m -> Por teclado	\e[0m" >> $informeColor
		echo -e "    \e[1;32m	[4]\e[0m -> Aleatoriamente manual	" >> $informeColor
		echo "" >> $informeColor
		echo "" >> $informe
		echo -e "	  -> Por teclado <-	" >> $informe
		echo -e "	     Aleatoriamente manual	" >> $informe
		echo "" >> $informe
		sleep 0.5
		entradaTeclado
		;;
		
		#caso a
		"a")
		clear
		cabeceraInicio
		echo ""
		echo -e "\e[1;38;5;81m ¿Desea  introducir los datos por teclado o aleatoriamente?: "
		echo ""
		echo -e "    \e[1;32m	[1]\e[0m -> Por teclado"
		echo -e "    \e[1;38;5;64;48;5;7m	[4]\e[90m ->  Aleatoriamente manual	\e[0m"
		echo ""
		
		echo "" >> $informeColor
		echo -e "    \e[1;32m	[1]\e[0m -> Por teclado	" >> $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	\e[90m -> Aleatoriamente manual	\e[0m" >> $informeColor
		echo "" >> $informeColor
		echo "" >> $informe
		echo -e "	     Por teclado 		" >> $informe
		echo -e "	  -> Aleatoriamente manual <-	" >> $informe
		echo "" >> $informe
		sleep 0.5
		entradaAleatorio
		;;
		
	esac				#cierre del case

}




############


entradaUltimo(){
	
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
#	nProc=`awk NR==4 ./datosScript/"$ficheroIn"`
	nProc=`wc -l < ./datosScript/"$ficheroIn"`
	let nProc=$nProc-2
	p=1;
	maxFilas=$(($nProc+2))
	for (( fila = 3; fila <= $maxFilas; fila++ )) 
		do
		        linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
                        IFS=";" read -r -a parte <<< "$linea"

		#	lectura1=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 1 -d ";"`
			tLlegada[$p]=${parte[0]}
		#	lectura2=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 2 -d ";"`
		#	tEjec[$p]=$lectura2
		#	maxpags[$p]=${tEjec[$p]}
		#	lectura3=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 3 -d ";"`
			nMarcos[$p]=${parte[1]}
			tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
			
			linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
			IFS=";" read -r -a parte <<< "$linea"
			tEjec[$p]=$((${#parte[*]}-3))
			maxpags[$p]=${tEjec[$p]}
			

			for (( n = 0; n < ${maxpags[$p]}; n++ ))
				do
					m=$(($n+3))
	#				posic=$(($n+5))
	#				lectura4=`awk NR==$fila ./datosScript/"$ficheroIn"  | cut -f $posic -d ";"`
					direcciones[$p,$n]=${parte[$m]}
					paginas[$p,$n]=$(( ${direcciones[$p,$n]}/$tamPag ))
				done
			p=$(($p+1))

		done
	
	p=$(($p-1))
	
	clear
	
	imprimeProcesosUltimoFichero
}


############


aleatorio_entre() {
    eval "${1}=$( shuf -i ${2}-${3} -n 1 )"
}



############



entradaTeclado(){
	
	#pide que las variables globales sean introducido por teclado, guiandote paso a paso y mostrando en todo momento los valores de Memoria del sistema y el Tamaño de Página 
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
	until [[ $marcosMem =~ [0-9] && $marcosMem -gt 0 ]]			#entrada robusta hasta que $tammem sea un valor mayor que 0 y que sea un número
		do
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
	
	
	#pide los datos de cada proceso hasta que se diga que no se quieren más
	
	otroProc="s";
	while [[ $otroProc == "s" ]]
		do
			
			maxpags[$p]=0;
			
			echo "" >> $informe
			echo "" >> $informeColor
			echo -n -e " Introduzca el \e[1;33mtiempo de llegada\e[0m del proceso $p: "
			read tLlegada[$p]
			echo -n " Introduzca el tiempo de llegada del proceso $p: " >> $informe
			echo -n -e " Introduzca el \e[1;33mtiempo de llegada\e[0m del proceso $p: " >> $informeColor
			until [[ ${tLlegada[$p]} =~ [0-9] && ${tLlegada[$p]} -ge 0 ]]
				do
					echo -e " \e[1;31mEl tiempo de llegada debe ser un número positivo\e[0m"
					echo -n -e " Introduzca el \e[1;33mtiempo de llegada\e[0m del proceso $p: "
					read tLlegada[$p]
				done
			echo "${tLlegada[$p]}" >> $informe
			echo -e "\e[1;32m${tLlegada[$p]}\e[0m" >> $informeColor
			clearImprime
	
	

			echo "${tEjec[$p]}" >> $informe
			echo -e "\e[1;32m${tEjec[$p]}\e[0m" >> $informeColor
			pag=${tEjec[$p]};
			clearImprime
			
			echo "" >>$informe
			echo "" >> $informeColor
			echo -n -e " Introduzca el \e[1;33mnúmero de marcos\e[0m del proceso $p: "
			read nMarcos[$p]
			echo -n " Introduzca el número de marcos del proceso $p: " >> $informe
			echo -n -e " Introduzca el \e[1;33mnúmero de marcos\e[0m del proceso $p: " >> $informeColor
			
			tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))

			echo "${nMarcos[$p]}" >> $informe
			echo "" >> $informe
			echo " Tamaño mínimo estructural del proceso $p: ${tamProceso[$p]}" >> $informe
			echo -e "\e[1;32m${nMarcos[$p]}\e[0m" >> $informeColor
			echo "" >> $informeColor
			echo -e " \e[1;33Tamaño mínimo estructural\e[0m del proceso $p: \e[1;32m${tamProceso[$p]}\e[0m" >> $informeColor
			clearImprime

			for (( pag=0; ; pag++ ))
				do
			
					echo "" >> $informe
					echo "" >> $informeColor
					echo -n -e " Introduzca la \e[1;33mdirección de página\e[0m $(($pag+1)) o una n si no quiere más: "
					read  distinta
					if [ "$distinta" == "n" ]
						then
							if [ "$pag" == "0" ]
								then
									echo " Debe introducir al menos una página"
									until [[ $distinta =~ [0-9] ]]
									do
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
					until [[ ${direcciones[$p,$pag]} =~ [0-9] && ${direcciones[$p,$pag]} -ge 0 ]];
						do
							
							echo -e " \e[1;31mLa dirección debe ser un número positivo\e[0m"
							echo -n -e " Introduzca la \e[1;33mdirección de página\e[0m $(($pag+1)) o una n si no quiere más: "
							read  direcciones[$p,$pag]
						done
					tEjec[$p]=$(($pag+1))
					maxpags[$p]=${tEjec[$p]}
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
			until [[ $otroProc == "s" || $otroProc == "n" ]]
				do
					
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


#############


entradaAleatorio(){
	minrangomemoria=0
	maxrangomemoria=0
	minrangotampagina=0
	maxrangotampagina=0
	minrangonumeroprocesos=0
	maxrangonumeroprocesos=0
	numeroprocesos=0
	minrangotiempollegada=0
	maxrangotiempollegada=0
	minrangonumerodemarcos=0
	maxrangonumerodemarcos=0
	minrangonumerodedirecciones=0
	maxrangonumerodedirecciones=0
	numerodedirecciones=()
	minrangovalordirecciones=0
	maxrangovalordirecciones=0
	contadordirecciones=0
	valordirecciones=0
	
	#hace que las variables globales sean aleatorias,pidiendote un rango de números para que eñ número aleatorio esté en el , guiandote paso a paso y mostrando en todo momento los valores de Memoria del sistema y el Tamaño de Página 
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el mínimo del rango del número de marcos de pagina en la \e[1;33mmemoria\e[0m: "
	read minrangomemoria
	echo -n " Introduzca el mínimo número del rango de marcos de pagina en la memoria: " >> $informe
	echo -n -e " Introduzca el mínimo número del rango de marcos de pagina en la \e[1;33mmemoria\e[0m: " >> $informeColor
	until [[ $minrangomemoria =~ [0-9] && $minrangomemoria -gt 0 ]]			#entrada robusta hasta que $minrangomemoria sea un valor mayor que 0 y que sea un número
		do
			echo ""
			echo -e "\e[1;31m El mínimo número del rango  de marcos de pagina en la memoria: debe ser mayor que \e[0m\e[1;33m0\e[0m"
			echo -n -e " Introduzca el mínimo número del rango de marcos de pagina en la \e[1;33mmemoria\e[0m: "
			read minrangomemoria
		done
	
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el máximo del rango del número de marcos de pagina en la \e[1;33mmemoria\e[0m: "
	read maxrangomemoria
	echo -n " Introduzca el máximo del rango del número de marcos de pagina en la memoria: " >> $informe
	echo -n -e " Introduzca el máximo del rango del número de marcos de pagina en la \e[1;33mmemoria\e[0m: " >> $informeColor
	until [[ $maxrangomemoria =~ [0-9] && $maxrangomemoria -ge $minrangomemoria ]]			#entrada robusta hasta que $minrangomemoria sea un valor mayor que 0 y que sea un número
		do
			echo ""
			echo -e "\e[1;31m El máximo del rango del número de marcos de pagina en la memoria debe ser mayor que \e[0m\e[1;33m$minrangomemoria\e[0m"
			echo -n -e " Introduzca el máximo del rango del número de marcos de pagina en la \e[1;33mmemoria\e[0m: "
			read maxrangomemoria
		done
	
	aleatorio_entre marcosMem $minrangomemoria $maxrangomemoria
	
	
	
	echo "$tamMem" >> $informe
	echo -e "\e[1;32m$tamMem\e[0m" >> $informeColor
	sleep 0.2
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el mínimo del rango del número de direcciones por marco de \e[1;33mpágina (nº de direcciones)\e[0m: "
	read minrangotampagina
	echo -n " Introduzca el mínimo del rango del número de direcciones por marco de  página (nº de direcciones): " >> $informe
	echo -n -e " Introduzca el mínimo del rango del número de direcciones por marco de  \e[1;33mpágina (nº de direcciones)\e[0m: " >> $informeColor
	until [[ $minrangotampagina =~ [0-9] && $minrangotampagina -gt 0 ]]
		do
			echo ""
			echo -e "\e[1;31m del rango del número de direcciones por marco de página debe ser mayor que 0\e[0m"
			echo -n -e " Introduzca el mínimo tamaño del marco de \e[1;33mpágina (nº de direcciones)\e[0m: "
			read minrangotampagina
		done
	
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
	until [[ $maxrangotampagina =~ [0-9] && $maxrangotampagina -ge $minrangotampagina ]]
		do
			echo ""
			echo -e "\e[1;31m El máximo del rango del número de direcciones por marco de página (nº de direcciones) debe ser mayor o igual que $minrangotampagina\e[0m"
			echo -n -e " Introduzca el máximo del rango del número de direcciones por marco de \e[1;33mpágina (nº de direcciones)\e[0m: "
			read maxrangotampagina
		done
	
	
	aleatorio_entre tamPag $minrangotampagina $maxrangotampagina
	
	
	
		
	
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
	
	

	
	
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el mínimo del rango del número de \e[1;33mprocesos\e[0m: "
	read minrangonumeroprocesos
	echo -n " Introduzca el mínimo del rango del número de procesos: " >> $informe
	echo -n -e " Introduzca el mínimo del rango del número de \e[1;33mprocesos\e[0m: " >> $informeColor
	until [[ $minrangonumeroprocesos =~ [0-9] && $minrangonumeroprocesos -gt 0 ]]
		do
			echo ""
			echo -e "\e[1;31m El mímimo del rango del número de procesos debe ser mayor que 0\e[0m"
			echo -n -e " Introduzca el mínimo del rango del número de procesos \e[1;33mprocesos\e[0m: "
			read minrangonumeroprocesos
		done
	
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el máximo del rango del número de \e[1;33mprocesos\e[0m: "
	read maxrangonumeroprocesos
	echo -n " Introduzca el máximo del rango del número de procesos " >> $informe
	echo -n -e " Introduzca el máximo del rango del número de \e[1;33mprocesos\e[0m: " >> $informeColor
	until [[ $maxrangonumeroprocesos =~ [0-9] && $maxrangonumeroprocesos -ge $minrangonumeroprocesos ]]
		do
			echo ""
			echo -e "\e[1;31m El máximo del rango del número de procesos debe ser mayor o igual que $minrangonumeroprocesos\e[0m"
			echo -n -e " Introduzca el máximo del rango del número de \e[1;33mprocesos\e[0m: "
			read maxrangonumeroprocesos
		done
	
	
	aleatorio_entre numeroprocesos $minrangonumeroprocesos $maxrangonumeroprocesos
	
	
	
	
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	maxpags[$p]=0;
	
	
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el mínimo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: "
	read minrangotiempollegada
	echo -n " Introduzca el mínimo del rango del tiempo de llegada de los procesos: " >> $informe
	echo -n -e " Introduzca el mínimo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: " >> $informeColor
	until [[ $minrangotiempollegada =~ [0-9] && $minrangotiempollegada -ge 0 ]]
		do
			echo -e " \e[1;31mEl mínimo del rango del tiempo de llegada debe ser un número positivo\e[0m"
			echo -n -e " Introduzca el mínimo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: "
			read minrangotiempollegada
		done
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el máximo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: "
	read maxrangotiempollegada
	echo -n " Introduzca el máximo del rango del tiempo de llegada de los procesos: " >> $informe
	echo -n -e " Introduzca el máximo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: " >> $informeColor
	until [[ $maxrangotiempollegada =~ [0-9] && $maxrangotiempollegada -ge $minrangotiempollegada ]]
		do
			echo -e " \e[1;31mEl máximo del rango del tiempo de llegada debe ser un número mayor o igual que $minrangotiempollegada\e[0m"
			echo -n -e " Introduzca el máximo del rango del \e[1;33mtiempo de llegada\e[0m de los procesos: "
			read maxrangotiempollegada
		done
	
	
	
	
	
	
	
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el mínimo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
	read minrangonumerodemarcos
	echo -n " Introduzca el mínimo del número de marcos asociados a cada proceso: " >> $informe
	echo -n -e " Introduzca el mínimo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: " >> $informeColor
	until [[ $minrangonumerodemarcos =~ [0-9] && $minrangonumerodemarcos -ge 0 ]]
	do
		echo ""
		echo -e "\e[1;31m El mínimo del número de marcos asociados a cada proceso debe ser un número positivo\e[0m"
		echo -n -e " Introduzca el mínimo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
		read minrangonumerodemarcos
	done
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el máximo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
	read maxrangonumerodemarcos
	echo -n " Introduzca el máximo del número de marcos asociados a cada proceso: " >> $informe
	echo -n -e " Introduzca el máximo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: " >> $informeColor
	until [[ $maxrangonumerodemarcos =~ [0-9] && $maxrangonumerodemarcos -ge $minrangonumerodemarcos ]]
	do
		echo ""
		echo -e "\e[1;31m El máximo número del rango de marcos asociados a cada procesos debe ser un número positivo mayor o igual que $minrangonumerodemarcos \e[0m"
		echo -n -e " Introduzca el máximo del \e[1;33mnúmero de marcos asociados\e[0m a cada proceso: "
		read maxrangonumerodemarcos
	done	
		
	
	clear
	cabeceraInicio
	imprimeVarGlobRangos

	
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el \e[1;33mmínimo del rango del número de direcciones a ejecutar\e[0m: "
	read  minrangovalordirecciones
		
	until [[ $minrangovalordirecciones =~ [0-9] && $minrangovalordirecciones -ge 0 ]]			
	do
		echo ""
		echo -e "\e[1;31m El mínimo del rango del número de direcciones a ejecutar debe ser mayor o igual que \e[0m\e[1;33m0 \e[0m"
		echo -n -e " Introduzca el \e[1;33mmínimo del rango del número de direcciones a ejecutar\e[0m: "
		read minrangovalordirecciones
	done
	
	clear
	cabeceraInicio
	imprimeVarGlobRangos
		
		
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca la máxima\e[1;33m dirección de página\e[0m : "
	read  maxrangovalordirecciones
	
	until [[ $maxrangovalordirecciones =~ [0-9] && $maxrangovalordirecciones -ge $minrangovalordirecciones ]]			
	do
		echo ""
		echo -e "\e[1;31m La máxima dirección de página debe ser mayor que \e[0m\e[1;33m$minrangovalordirecciones\e[0m"
		echo -n -e " Introduzca la \e[1;33mmáxima dirección de página\e[0m: "
		read maxrangovalordirecciones
	done
	
		
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el mínimo del rango del \e[1;33mtamaño del proceso (direcciones) \e[0m: "
	read  minrangonumerodedirecciones	
	until [[ $minrangonumerodedirecciones =~ [0-9] && $minrangonumerodedirecciones -ge 1 ]]			
	do
		echo ""
		echo -e "\e[1;31m El mínimo del rango del tamaño del proceso (direcciones) debe ser mayor que \e[0m\e[1;33m0 \e[0m"
		echo -n -e " Introduzca el mínimo del rango del \e[1;33mtamaño del proceso (direcciones) \e[0m: "
		read minrangonumerodedirecciones
	done
	clear
	cabeceraInicio
	imprimeVarGlobRangos
	echo ""
	echo "" >> $informe
	echo "" >> $informeColor
	echo -n -e " Introduzca el máximo del rango del \e[1;33mtamaño del proceso (direcciones) \e[0m: "
	read  maxrangonumerodedirecciones
	until [[ $maxrangonumerodedirecciones =~ [0-9] && $maxrangonumerodedirecciones -ge $minrangonumerodedirecciones ]]			
	do
		echo ""
		echo -e "\e[1;31m El máximo del rango del tamaño del proceso (direcciones) debe ser mayor que \e[0m\e[1;33m$minrangonumerodedirecciones\e[0m"
		echo -n -e " Introduzca el máximo del rango del \e[1;33mtamaño del proceso (direcciones) \e[0m: "
		read maxrangonumerodedirecciones
	done
	
	echo ""
	echo " Pulse INTRO para continuar."
	read
		
	
	

	
	for (( p=1; p<=$numeroprocesos; p++ ))
	do
		maxpags[$p]=0;
		aleatorio_entre tLlegada[$p] $minrangotiempollegada $maxrangotiempollegada
		pag=${tEjec[$p]};
		aleatorio_entre nMarcos[$p] $minrangonumerodemarcos $maxrangonumerodemarcos
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
		
		
		aleatorio_entre numerodedirecciones[$p] $minrangonumerodedirecciones $maxrangonumerodedirecciones
		
		for (( pag=0; pag<=${numerodedirecciones[$p]}; pag++ ))
		do
			aleatorio_entre valordirecciones $minrangovalordirecciones $maxrangovalordirecciones
			direcciones[$p,$pag]=$valordirecciones
			tEjec[$p]=$(($pag+1))
			maxpags[$p]=${tEjec[$p]}
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
	guardarangos
	imprimeProcesosFinal
	
}



############


guardarangos(){
	ficheroestandarrangos="datosrangos"
	clear
	cabeceraInicio
	echo -n -e "\e[1;38;5;81m ¿Dónde quiere guardar los rangos?\n"
	echo -e "    \e[1;32m   [1]\e[0m -> En la salida estándar (datosrangos.txt)	"
	echo -e "    \e[1;32m   [2]\e[0m -> En otro fichero	"
	read -p " Seleccione opción: " elegirguardarrangos
        until [[ "$elegirguardarrangos" == "1" || "$elegirguardarrangos" == "2" ]]
                do
                        echo ""
                        echo -e -n "\e[1;31mValor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
                        read elegirguardarrangos
                done


	case $elegirguardarrangos in			#empieza un case (como un switch case) de la opcion introducida
		#caso 1
		"1")
		clear
		cabeceraInicio
		echo ""
		echo -e "\e[1;38;5;81m ¿Dónde quiere guardar los rangos? "
		echo ""
		echo -e "    \e[1;38;5;64;48;5;7m	[1]\e[90m -> En la salida estándar (datosrangos.txt)	\e[0m"
		echo -e "    \e[1;32m	[2]\e[0m -> En otro fichero	"			
		echo ""
		sleep 0.5
		;;
		
		#caso 2
		"2")
		clear
		cabeceraInicio
		echo  ""
		echo -e "\e[1;38;5;81m ¿Dónde quiere guardar los rangos? "
		echo ""
		echo -e "    \e[1;32m	[1]\e[0m -> En la salida estándar (datosrangos.txt)	"
		echo -e "   \e[1;38;5;64;48;5;7m	[2]\e[90m -> En otro fichero	\e[0m"
		sleep 0.5
		echo ""
              	echo -n -e " Introduzca el nombre del fichero donde se guardarán los rangos de la práctica (sin incluir \".txt\"): "
		read ficheroestandarrangosotro
		clear
		;;
	esac
				
	ficherorangos="./datosScript/rangos/${ficheroestandarrangos}.txt"
	
	echo -n "$minrangomemoria" > $ficherorangos
	echo -n "-" >> $ficherorangos
	echo "$maxrangomemoria" >> $ficherorangos
	echo -n "$minrangotampagina" >> $ficherorangos
	echo -n "-" >> $ficherorangos
	echo "$maxrangotampagina" >> $ficherorangos
	echo -n "$minrangonumeroprocesos" >> $ficherorangos
	echo -n "-" >> $ficherorangos
	echo "$maxrangonumeroprocesos" >> $ficherorangos
	echo -n "$minrangotiempollegada" >> $ficherorangos
	echo -n "-" >> $ficherorangos
	echo "$maxrangotiempollegada" >> $ficherorangos
	echo -n "$minrangonumerodemarcos" >> $ficherorangos
	echo -n "-" >> $ficherorangos
	echo "$maxrangonumerodemarcos" >> $ficherorangos
	echo -n "$minrangonumerodedirecciones" >> $ficherorangos
	echo -n "-" >> $ficherorangos
	echo "$maxrangonumerodedirecciones" >> $ficherorangos
	echo -n "$minrangovalordirecciones" >> $ficherorangos
	echo -n "-" >> $ficherorangos
	echo "$maxrangovalordirecciones" >> $ficherorangos
	
	 if [[ "$elegirguardarrangos" == "2" ]]
                then
                       cp "${ficherorangos}" "./datosScript/rangos/${ficheroestandarrangosotro}.txt"
	fi
	
	
	
	
}



leerrangosultimaejecucion(){
	
	ficheroestandarrangos="datosrangos"	
	ficherorangos="./datosScript/rangos/${ficheroestandarrangos}.txt"
	
	minrangomemoria=`head -n 1 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangomemoria=`head -n 1 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangotampagina=`head -n 2 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangotampagina=`head -n 2 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangonumeroprocesos=`head -n 3 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangonumeroprocesos=`head -n 3 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangotiempollegada=`head -n 4 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangotiempollegada=`head -n 4 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangonumerodemarcos=`head -n 5 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangonumerodemarcos=`head -n 5 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangonumerodedirecciones=`head -n 6 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangonumerodedirecciones=`head -n 6 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangovalordirecciones=`head -n 7 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangovalordirecciones=`head -n 7 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	
	clearImprime

}





leerrangosarchivo(){
	
		
	ficherorangos="./datosScript/rangos/${ficheroIn}.txt"
	
	minrangomemoria=`head -n 1 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangomemoria=`head -n 1 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangotampagina=`head -n 2 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangotampagina=`head -n 2 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangonumeroprocesos=`head -n 3 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangonumeroprocesos=`head -n 3 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangotiempollegada=`head -n 4 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangotiempollegada=`head -n 4 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangonumerodemarcos=`head -n 5 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangonumerodemarcos=`head -n 5 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangonumerodedirecciones=`head -n 6 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangonumerodedirecciones=`head -n 6 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	minrangovalordirecciones=`head -n 7 $ficherorangos | tail -n 1 | cut -d "-" -f 1`
	maxrangovalordirecciones=`head -n 7 $ficherorangos | tail -n 1 | cut -d "-" -f 2`
	
	clearImprime

}




entradarangoAleatorio(){
	minrangomemoria=0
	maxrangomemoria=0
	minrangotampagina=0
	maxrangotampagina=0
	minrangonumeroprocesos=0
	maxrangonumeroprocesos=0
	numeroprocesos=0
	minrangotiempollegada=0
	maxrangotiempollegada=0
	minrangonumerodemarcos=0
	maxrangonumerodemarcos=0
	minrangonumerodedirecciones=0
	maxrangonumerodedirecciones=0
	numerodedirecciones=()
	minrangovalordirecciones=0
	maxrangovalordirecciones=0
	contadordirecciones=0
	valordirecciones=0
	
	
	leerrangosultimaejecucion
	
	#hace que las variables globales sean aleatorias,leyendo los rangos
	
	
	aleatorio_entre marcosMem $minrangomemoria $maxrangomemoria
	
	echo "$tamMem" >> $informe
	echo -e "\e[1;32m$tamMem\e[0m" >> $informeColor
	
	
	
	aleatorio_entre tamPag $minrangotampagina $maxrangotampagina
	
	echo "$tamPag" >> $informe
	echo -e "\e[1;32m$tamPag\e[0m" >> $informeColor
	
	tamMem=$(($marcosMem*$tamPag))
	
	
	p=1
	
	aleatorio_entre numeroprocesos $minrangonumeroprocesos $maxrangonumeroprocesos
	
	
	maxpags[$p]=0;
	
	
	for (( p=1; p<=$numeroprocesos; p++ ))
	do
		maxpags[$p]=0;
		aleatorio_entre tLlegada[$p] $minrangotiempollegada $maxrangotiempollegada
		pag=${tEjec[$p]};
		aleatorio_entre nMarcos[$p] $minrangonumerodemarcos $maxrangonumerodemarcos
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
		
		
		aleatorio_entre numerodedirecciones[$p] $minrangonumerodedirecciones $maxrangonumerodedirecciones
		
		for (( pag=0; pag<=${numerodedirecciones[$p]}; pag++ ))
		do
			aleatorio_entre valordirecciones $minrangovalordirecciones $maxrangovalordirecciones
			direcciones[$p,$pag]=$valordirecciones
			tEjec[$p]=$(($pag+1))
			maxpags[$p]=${tEjec[$p]}
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



#########





entradarangoarchivo(){
	minrangomemoria=0
	maxrangomemoria=0
	minrangotampagina=0
	maxrangotampagina=0
	minrangonumeroprocesos=0
	maxrangonumeroprocesos=0
	numeroprocesos=0
	minrangotiempollegada=0
	maxrangotiempollegada=0
	minrangonumerodemarcos=0
	maxrangonumerodemarcos=0
	minrangonumerodedirecciones=0
	maxrangonumerodedirecciones=0
	numerodedirecciones=()
	minrangovalordirecciones=0
	maxrangovalordirecciones=0
	contadordirecciones=0
	valordirecciones=0
	
	
	leerrangosarchivo
	
	#hace que las variables globales sean aleatorias,leyendo los rangos
	
	
	aleatorio_entre marcosMem $minrangomemoria $maxrangomemoria
	
	echo "$tamMem" >> $informe
	echo -e "\e[1;32m$tamMem\e[0m" >> $informeColor
	
	
	
	aleatorio_entre tamPag $minrangotampagina $maxrangotampagina
	
	echo "$tamPag" >> $informe
	echo -e "\e[1;32m$tamPag\e[0m" >> $informeColor
	
	tamMem=$(($marcosMem*$tamPag))
	
	
	p=1
	
	aleatorio_entre numeroprocesos $minrangonumeroprocesos $maxrangonumeroprocesos
	
	
	maxpags[$p]=0;
	
	
	for (( p=1; p<=$numeroprocesos; p++ ))
	do
		maxpags[$p]=0;
		aleatorio_entre tLlegada[$p] $minrangotiempollegada $maxrangotiempollegada
		pag=${tEjec[$p]};
		aleatorio_entre nMarcos[$p] $minrangonumerodemarcos $maxrangonumerodemarcos
		tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
		
		
		aleatorio_entre numerodedirecciones[$p] $minrangonumerodedirecciones $maxrangonumerodedirecciones
		
		for (( pag=0; pag<=${numerodedirecciones[$p]}; pag++ ))
		do
			aleatorio_entre valordirecciones $minrangovalordirecciones $maxrangovalordirecciones
			direcciones[$p,$pag]=$valordirecciones
			tEjec[$p]=$(($pag+1))
			maxpags[$p]=${tEjec[$p]}
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
	guardarangos
	imprimeProcesosFinal
	
}









imprimefiles(){
#Imprime los archivos que hay en el directorio datosScript, si el parametro pasado es mayor que 0 nos muestra todos los archivos y nos resalta el elegido, si no imprime todos los archivos
	max=`find datosScript -maxdepth 1 -type f | cut -f2 -d"/" | wc -l`
	echo -e "\e[1;38;5;81m ARCHIVOS EN EL DIRECTORIO \"datosScript\" : \e[0m"
	echo ""
	if [[ $# -gt 0 ]] #Si se han pasado argumentos. $#corresponde al nº de argumentos pasados
		then
			for (( i=1; i<=$max; i++ ))
				do
					file=`find datosScript -maxdepth 1 -type f | cut -f2 -d"/" | sort | cut -f$i -d$'\n'` #Mostrar solo los nombres de ficheros (no directorios).
					if [ $i -eq $fichSelect ]
						then
							printf '    \e[1;38;5;64;48;5;7m	[%2u.]\e[90m %-20s\e[0m\n' "$i" "$file" #Resaltar opción escogida.
						else
							printf '    \e[1;32m	[%2u.]\e[0m %-20s\e[0m\n' "$i" "$file"
					fi
				done
		else
			for (( i=1; i<=$max; i++ ))
				do
					file=`find datosScript -maxdepth 1 -type f | cut -f2 -d"/" | sort | cut -f$i -d$'\n'` #Mostrar solo los nombres de ficheros (no directorios).
				printf '    \e[1;32m	[%2u.]\e[0m %-20s\e[0m\n' "$i" "$file"
			done
	fi
	echo ""
}


############



imprimefilesrangos(){
#Imprime los archivos que hay en el directorio datosScript, si el parametro pasado es mayor que 0 nos muestra todos los archivos y nos resalta el elegido, si no imprime todos los archivos
	max=`find datosScript/rangos -maxdepth 1 -type f | cut -f3 -d"/" | wc -l`
	echo -e "\e[1;38;5;81m ARCHIVOS EN EL DIRECTORIO \"datosScript/rangos\" : \e[0m"
	echo ""
	if [[ $# -gt 0 ]] #Si se han pasado argumentos. $#corresponde al nº de argumentos pasados
		then
			for (( i=1; i<=$max; i++ ))
				do
					file=`find datosScript/rangos -maxdepth 1 -type f | cut -f3 -d"/" | sort | cut -f$i -d$'\n'` #Mostrar solo los nombres de ficheros (no directorios).
					if [ $i -eq $fichSelect ]
						then
							printf '    \e[1;38;5;64;48;5;7m	[%2u.]\e[90m %-20s\e[0m\n' "$i" "$file" #Resaltar opción escogida.
						else
							printf '    \e[1;32m	[%2u.]\e[0m %-20s\e[0m\n' "$i" "$file"
					fi
				done
		else
			for (( i=1; i<=$max; i++ ))
				do
					file=`find datosScript/rangos -maxdepth 1 -type f | cut -f3 -d"/" | sort | cut -f$i -d$'\n'` #Mostrar solo los nombres de ficheros (no directorios).
				printf '    \e[1;32m	[%2u.]\e[0m %-20s\e[0m\n' "$i" "$file"
			done
	fi
	echo ""
}


############


entradaFichero(){

	clear
	cabeceraInicio
	echo "" | tee -a $informeColor

	imprimefiles
	echo "" >> $informe
	echo -e " Elija un \e[1;32mfichero\e[0m: " | tee -a $informeColor
	echo -n " Elija un fichero: " >> $informe
	read fichSelect
	until [[ $tamMem =~ [0-9] && $fichSelect -gt 0 && $fichSelect -le $max ]]
		do
			echo ""
			echo -e "\e[1;31m El valor introducido no es correcto. Debe estar entre\e[0m \e[1;33m1\e[0m \e[1;31my\e[0m \e[1;33m$max\e[0m"
			echo -n " Elija un fichero: "
			read fichSelect
		done
	clear
	cabeceraInicio
	echo ""
	imprimefiles 1
	sleep 0.5
	ficheroIn=`find datosScript -maxdepth 1 -type f -iname "*.txt" | sort | cut -f2 -d"/" | cut -f$fichSelect -d$'\n'` #Guardar el nombre del fichero escogido.
	
	echo "$ficheroIn" >> $informe
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	
	tamMem=`awk NR==1 ./datosScript/"$ficheroIn"`
	tamPag=`awk NR==2 ./datosScript/"$ficheroIn"`
	marcosMem=$(($tamMem/$tamPag))
#	nProc=`awk NR==4 ./datosScript/"$ficheroIn"`
	nProc=`wc -l < ./datosScript/"$ficheroIn"`
	let nProc=$nProc-2
	p=1;
	maxFilas=$(($nProc+2))
	for (( fila = 3; fila <= $maxFilas; fila++ )) 
		do
		        linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
                        IFS=";" read -r -a parte <<< "$linea"

		#	lectura1=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 1 -d ";"`
			tLlegada[$p]=${parte[0]}
		#	lectura2=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 2 -d ";"`
		#	tEjec[$p]=$lectura2
		#	maxpags[$p]=${tEjec[$p]}
		#	lectura3=`awk NR==$fila ./datosScript/"$ficheroIn" | cut -f 3 -d ";"`
			nMarcos[$p]=${parte[1]}
			tamProceso[$p]=$((${nMarcos[$p]}*$tamPag))
			
			linea=`awk NR==$fila ./datosScript/"$ficheroIn"`
			IFS=";" read -r -a parte <<< "$linea"
			tEjec[$p]=$((${#parte[*]}-3))
			maxpags[$p]=${tEjec[$p]}
			

			for (( n = 0; n < ${maxpags[$p]}; n++ ))
				do
					m=$(($n+3))
	#				posic=$(($n+5))
	#				lectura4=`awk NR==$fila ./datosScript/"$ficheroIn"  | cut -f $posic -d ";"`
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

        for(( i = 1; i <= $nProc; i++ ))
                do
                        echo -n "${tLlegada[$i]};" >> $ficheroOut
                        #echo -n "${tEjec[$i]};" >> $ficheroOut
                        echo -n "${nMarcos[$i]};;" >> $ficheroOut
                        for (( n = 0; n < ${maxpags[$i]}; n++ ))
                                do
                                        echo -n "${direcciones[$i,$n]};" >> $ficheroOut
                                done
                        echo "" >> $ficheroOut
                done
        clear
	imprimeProcesosFichero
	
}




entradaFicherorangos(){

	clear
	cabeceraInicio
	echo "" | tee -a $informeColor

	imprimefilesrangos
	echo "" >> $informe
	echo -e " Elija un \e[1;32mfichero de rangos\e[0m: " | tee -a $informeColor
	echo -n " Elija un fichero de rangos: " >> $informe
	read fichSelect
	until [[ $tamMem =~ [0-9] && $fichSelect -gt 0 && $fichSelect -le $max ]]
		do
			echo ""
			echo -e "\e[1;31m El valor introducido no es correcto. Debe estar entre\e[0m \e[1;33m1\e[0m \e[1;31my\e[0m \e[1;33m$max\e[0m"
			echo -n " Elija un fichero: "
			read fichSelect
		done
	clear
	cabeceraInicio
	echo ""
	imprimefilesrangos 1
	sleep 0.5
	ficheroIn=`find datosScript/rangos -maxdepth 1 -type f -iname "*.txt" | sort | cut -f3 -d"/" | cut -f$fichSelect -d$'\n'` #Guardar el nombre del fichero escogido.
	
	echo "$ficheroIn" >> $informe
	echo -e "\e[1;32m$ficheroIn\e[0m" >> $informeColor
	
	entradarangoAleatorio
	
	clear
	imprimeProcesosFichero
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
	
imprimeVarGlob(){
	
	echo -e " Memoria del Sistema:  \e[1;33m$tamMem\e[0m"
	echo -e " Tamaño  de   Página:  \e[1;33m$tamPag\e[0m"
	echo -e " Número  de   marcos:  \e[1;33m$marcosMem\e[0m"
	
}


############


imprimeVarGlobRangos(){
	
	printf " Número de marcos de página en la memoria:  | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m | Resultado: \e[1;33m%4u\e[0m | \n"   "${minrangomemoria}" "${maxrangomemoria}" "${marcosMem}"
	printf " Número de direcciones por marco de página: | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m | Resultado: \e[1;33m%4u\e[0m | \n"   "${minrangotampagina}" "${maxrangotampagina}" "${tamPag}"
	printf " Memoria del Sistema:                       |              |              | Resultado: \e[1;33m%4u\e[0m | \n"   "${tamMem}"
	printf " Número de  procesos:                       | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m | Resultado: \e[1;33m%4u\e[0m | \n"   "${minrangonumeroprocesos}" "${maxrangonumeroprocesos}" "${numeroprocesos}"
	printf " Tiempo de llegada:                         | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m |\n"   "${minrangotiempollegada}" "${maxrangotiempollegada}"
	printf " Número de marcos asociados a cada proceso: | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m |\n"   "${minrangonumerodemarcos}" "${maxrangonumerodemarcos}"
	printf " Número de direcciones a ejecutar:          | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m |\n"   "${minrangovalordirecciones}" "${maxrangovalordirecciones}"
	printf " Tamaño del proceso (direcciones):          | Mínimo: \e[1;33m%4u\e[0m | Máximo: \e[1;33m%4u\e[0m |\n"   "${minrangonumerodedirecciones}" "${maxrangonumerodedirecciones}"
	
	
	
	

	
}


############


imprimeProcesos(){
	ordenacion
	asignaColores

	echo "" >> $informe
	echo "" >> $informeColor
	echo "   TABLA FINAL DE DATOS:"
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
	for (( improcesos = 1; improcesos <= $p; improcesos++ ))
		do
			ord=${ordenados[$improcesos]}
			if [[ ord -lt 10 ]]
			then
				printf "\e[1;32m\e[0m \e[1;3${colorines[$ord]}mP0$ord %3u %3u %4u \e[0m"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
				printf " P0$ord|%3u|%3u|%4u|"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" >> $informe
			else
				printf "\e[1;32m\e[0m \e[1;3${colorines[$ord]}mP$ord %3u %3u %4u \e[0m"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}"| tee -a $informeColor
				printf " P$ord|%3u|%3u|%4u|"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}"  >> $informe
			fi
			counter=0;
			maxpaginas=${maxpags[$ord]} 
			for (( impaginillas = 0; impaginillas <  maxpaginas ; impaginillas++ ))
				do
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


############


imprimeProcesosFichero(){

	echo "" >> $informe
	echo "" >> $informe
	echo "" >> $informeColor
	echo "" >> $informeColor
	echo -e " Has introducido los datos por fichero "| tee -a $informeColor
	echo " Has introducido los datos por fichero " >> $informe
#	echo ""
	
	imprimeProcesosFinal

}


############

imprimeProcesosUltimoFichero(){

	echo "" >> $informe
	echo "" >> $informe
	echo "" >> $informeColor
	echo "" >> $informeColor
	echo -e " Has introducido los datos por el fichero de la última ejecución "| tee -a $informeColor
	echo " Has introducido los datos por el fichero de la última ejecución " >> $informe
#	echo ""
	
	imprimeProcesosFinal

}


############


imprimeProcesosFinal(){
	#guardaDatos
	ordenacion
	asignaColores
	echo "" >> $informe
	echo "" >> $informeColor
	
	echo -e "   TABLA FINAL DE DATOS:\e[0m"
	echo -e " Memoria del Sistema: $tamMem" | tee -a $informeColor
	echo -e " Tamaño  de   Página: $tamPag" | tee -a $informeColor
	echo -e " Número  de   marcos: $marcosMem" | tee -a $informeColor
	echo "   TABLA FINAL DE DATOS:" >> $informe
	echo " Memoria del Sistema:  $tamMem" >> $informe
	echo " Tamaño  de   Página:  $tamPag" >> $informe
	echo " Número  de   marcos:  $marcosMem" >> $informe

	echo -e "\e[0m Ref Tll Tej nMar Dirección-Página" | tee -a $informeColor
	echo -e " Ref Tll Tej nMar Dirección-Página" >> $informe
	
	for (( improcesos = 1; improcesos <= $nProc; improcesos++ ))
		do
			ord=${ordenados[$improcesos]}
			if [[ ord -lt 10 ]]
			then
				printf " \e[1;3${colorines[$ord]}mP0$ord %3u %3u %4u \e[0m"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
				printf " P0$ord|%3u|%3u|%4u|"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" >> $informe
			else
				printf " \e[1;3${colorines[$ord]}mP$ord %3u %3u %4u \e[0m"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" | tee -a $informeColor
				printf " P$ord|%3u|%3u|%4u|"   "${tLlegada[$ord]}" "${tEjec[$ord]}" "${nMarcos[$ord]}" >> $informe
			fi
			counter=0;
			maxpaginas=${maxpags[$ord]} 
			for (( impaginillas = 0; impaginillas <  maxpaginas ; impaginillas++ ))
				do
							echo -n -e "\e[3${colorines[$ord]}m${direcciones[$ord,$impaginillas]}-\e[1m${paginas[$ord,$impaginillas]}\e[0m " | tee -a $informeColor
							echo -n "${direcciones[$ord,$impaginillas]}-${paginas[$ord,$impaginillas]} " >> $informe
				done
				echo "" | tee -a $informeColor
				echo "" >> $informe
			maxpaginas=0;
		done
	
	echo "" >> $informe
	echo "" >> $informe
	echo "" >> $informe
	echo "" >> $informeColor
	echo "" >> $informeColor
	echo "" >> $informeColor
	
	echo " Pulse INTRO para continuar."
	read

}


############


asignaColores(){
	for (( counter = 1; counter <= $p; counter++ ))
		do
			color=$(($counter%6))
			color=$(($color+1))
			colorines[$counter]=$color
		done
}
	

############


clearImprime(){
	clear
	imprimeProcesos
}


############


ordenacionViejo(){
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


############


ordenacion(){
	count=1 #Para movernos por el vector ordenados.
	acabado=0   #Indica cuando se ha acabado de ordenar los procesos.
	nproceso=0
  t=0
  while [[ $acabado -eq 0 ]]
    do
			for (( nproceso=1; nproceso<=$p; nproceso++ ))
				do
					if [[ ${tLlegada[$nproceso]} -eq $t ]]
						then
							ordenados[$count]=$nproceso
							((count++))
					fi  
			done
      if [[ $count -gt $p ]]
        then
          acabado=1
        else
          ((t++))
      fi
	done
	#Procesos ordenados en pordenados.
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


imprimeTiempo(){
#	echo "" | tee -a $informeColor
	echo -e " FCFS/SJF - PAGINACIÓN - S.OPORTUNIDAD - MEMORIA CONTINUA - NO REUBICABLE" | tee -a $informeColor
	echo -e " FCFS/SJF - PAGINACIÓN - S.OPORTUNIDAD - MEMORIA CONTINUA - NO REUBICABLE" >> $informe
	echo -e " T=\e[1;32m$tSistema\e[0m \tMemoria del sistema = $tamMem  Tamaño de página = $tamPag  Número de marcos:  $marcosMem" | tee -a $informeColor
	echo -e " T=$tSistema \tMemoria del sistema = $tamMem  Tamaño de página = $tamPag  Número de marcos:  $marcosMem" >> $informe
 
	
}


############


seleccionFCFS(){
#Pide el tipo de ejecución al usuario
	clear
	cabeceraInicio
	echo ""
	echo -e "\e[1;38;5;81m Seleccione el tipo de ejecución: \e[0m"
	echo ""
	echo -e "    \e[1;32m	[1]\e[0m -> Por eventos (Pulsando \e[1m\"INTRO\"\e[0m en cada cambio de estado)	"
	
	echo -e "    \e[1;32m	[2]\e[0m -> Introduciendo cada cuantos segundos nos muestra un \e[1mcambio de estado\e[0m  	"
	echo -e "    \e[1;32m	[3]\e[0m -> Completa (sin esperas)"
	echo -e "    \e[1;32m	[4]\e[0m -> Completa solo resumen"
	echo ""
	read -p " Seleccione la opción: " opcionEjec
	until [[ "$opcionEjec" == "1" || "$opcionEjec" == "2" || "$opcionEjec" == "3" || "$opcionEjec" == "4" ]]
		do
			echo ""
			echo -e -n "\e[1;31m Valor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m \e[1;31mo\e[0m \e[1;33m3 \e[1;31mo\e[0m \e[1;33m4\e[0m\e[1;31m: \e[0m"
			read opcionEjec
		done
	case $opcionEjec in
		"1")				#caso opcionEjec == 1
		clear
		cabeceraInicio
		echo "" | tee -a $informeColor
		echo -e "\e[1;38;5;81mSeleccione el tipo de ejecución: \e[0m" | tee -a $informeColor
		echo "" | tee -a $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	[1]\e[90m -> Por eventos (Pulsando \e[1m\"INTRO\"\e[21m en cada cambio de estado)	\e[0m" | tee -a $informeColor
		echo -e "    \e[1;32m	[2]\e[0m -> Introduciendo cada cuantos segundos nos muestra un \e[1mcambio de estado\e[0m 				" | tee -a $informeColor
		echo -e "    \e[1;32m	[4]\e[0m -> Completa solo resumen				" | tee -a $informeColor
		echo "" | tee -a $informeColor
		
		echo "" >> $informe
		echo "Seleccione el tipo de ejecución: " >> $informe
		echo "	  -> Por eventos (Pulsando INTRO en cada cambio de estado) <-	" >> $informe
		echo "	     Introduciendo cada cuantos segundos nos muestra un cambio de estado				" >> $informe
		echo "	     Completa solo resumen				" >> $informe
		echo "" >> $informe
		sleep 0.5
		;;
		"3")				#caso opcionEjec == 3
		clear
		cabeceraInicio
		echo "" | tee -a $informeColor
		echo -e "\e[1;38;5;81mSeleccione el tipo de ejecución: \e[0m" | tee -a $informeColor
		echo "" | tee -a $informeColor

		echo -e "    \e[1;32m	[1]\e[0m  Por eventos (Pulsando \e[1m\"INTRO\"\e[0m en cada cambio de estado)	" | tee -a $informeColor
		echo -e "    \e[1;32m	[2]\e[0m   Introduciendo cada cuantos segundos nos muestra un cambio de estado  \e[0m" | tee -a $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	[3]\e[90m  -> Completa (sin esperas) <- \e[0m" | tee -a $informeColor
		
		echo "" | tee -a $informeColor
		
		echo "" >> $informe
		echo "Seleccione el tipo de ejecución: " >> $informe
		echo "	     Por eventos (Pulsando \e[1m\"INTRO\"\e[0m en cada cambio de estado) 	" >> $informe
		echo "	     Introduciendo cada cuantos segundos nos muestra un cambio de estado 				" >> $informe
		echo "	  -> Completa (sin esperas) <-" >> $informe
		echo "" >> $informe
		sleep 0.5
		segundosesperaeventos=0
		opcionEjec=2
#		echo -n -e " Introduzca el número de segundos entre cada \e[1;33mevento\e[0m: "
#		read segundosesperaeventos
#		until [[ $segundosesperaeventos =~ [0-9] && $segundosesperaeventos -gt 0 ]]
#		do
#			echo ""
#			echo -e -n " \e[1;31mValor incorrecto, introduce un número mayor que 0 \e[0m"
#			read segundosesperaeventos
#		done
		
		
		;;
		"4")				#caso opcionEjec == 4
		clear
		cabeceraInicio
		echo  "" | tee -a $informeColor
		echo -e "\e[1;38;5;81mSeleccione el tipo de ejecución: \e[0m" | tee -a $informeColor
		echo "" | tee -a $informeColor
		echo -e "    \e[1;32m	[1]\e[0m -> Por eventos (Pulsando \e[1m\"INTRO\"\e[0m en cada cambio de estado)	" | tee -a $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	[4]\e[90m -> Completa solo resumen	\e[0m" | tee -a $informeColor
		echo "" | tee -a $informeColor
		
		echo "" >> $informe
		echo "Seleccione el tipo de ejecución: " >> $informe
		echo -e "	     Por eventos (Pulsando \"INTRO\" en cada cambio de estado) 	" >> $informe
		echo -e "	     Introduciendo cada cuantos segundos nos muestra un cambio de estado				" >> $informe
		echo -e "	  -> Completa solo resumen <-	" >> $informe
		echo "" >> $informe
		sleep 0.5
		;;
		"2")				#caso opcionEjec == 2
		clear
		cabeceraInicio
		echo "" | tee -a $informeColor
		echo -e "\e[1;38;5;81mSeleccione el tipo de ejecución: \e[0m" | tee -a $informeColor
		echo "" | tee -a $informeColor

		echo -e "    \e[1;32m	[1]\e[0m -> Por eventos (Pulsando \e[1m\"INTRO\"\e[0m en cada cambio de estado)	" | tee -a $informeColor
		echo -e "    \e[1;38;5;64;48;5;7m	[2]\e[90m  -> Introduciendo cada cuantos segundos nos muestra un cambio de estado <- \e[0m" | tee -a $informeColor
		echo -e "    \e[1;32m	[4]\e[0m -> Completa solo resumen				" | tee -a $informeColor
		echo "" | tee -a $informeColor
		
		echo "" >> $informe
		echo "Seleccione el tipo de ejecución: " >> $informe
		echo "	     Por eventos (Pulsando \e[1m\"INTRO\"\e[0m en cada cambio de estado) 	" >> $informe
		echo "	  -> Introduciendo cada cuantos segundos nos muestra un cambio de estado <-				" >> $informe
		echo "	     Completa solo resumen				" >> $informe
		echo "" >> $informe
		sleep 0.5
		echo -n -e " Introduzca el número de segundos entre cada \e[1;33mevento\e[0m: "
		read segundosesperaeventos
		until [[ $segundosesperaeventos =~ [0-9] && $segundosesperaeventos -gt 0 ]]
		do
			echo ""
			echo -e -n " \e[1;31mValor incorrecto, introduce un número mayor que 0 \e[0m"
			read segundosesperaeventos
		done
		;;
	esac
	clear
}


############


lineadetiempoCero(){

	if [[ $1 -eq 1 ]]
		then
			if [[ $ejecutando -lt 10 ]]
				then
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
		tiem=$((${tRetorno[$proc]}-${esperasinllegada[$proc]}))
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
					esperasinllegada[$ord]=$((${esperaconllegada[$ord]}-${tLlegada[$ord]}))
					printf " %4d" "${esperasinllegada[$ord]}" | tee -a $informeColor
					#echo -n -e "	${esperasinllegada[$ord]}" | tee -a $informeColor
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
		resumenMedios
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

	media 'esperasinllegada[@]'
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
					printf " \e[1;3${colorines[$counter]}mP0$counter\e[0m \e[1;3${colorines[$counter]}m%12u\e[0m \e[1;3${colorines[$counter]}m%10u/%-10u\e[0m \e[1;3${colorines[$counter]}m%2u\e[0m \e[1;3${colorines[$counter]}m%13u \e[0m\n" "${esperasinllegada[$counter]}" "${tLlegada[$counter]}" "${salida[$counter]}" "${duracion[$counter]}" "${cuentafallos[$counter]}"  | tee -a $informeColor
					echo "|  Proceso: P0$counter	T.Espera: ${esperasinllegada[$counter]}	Inicio/fin: ${tLlegada[$counter]}/${salida[$counter]}	T.Retorno: ${duracion[$counter]}	Fallos Pág.: ${cuentafallos[$counter]}" >> $informe
				else
					                                        printf " \e[1;3${colorines[$counter]}mP0$counter\e[0m \e[1;3${colorines[$counter]}m%12u\e[0m \e[1;3${colorines[$counter]}m%10u/%-10u\e[0m \e[1;3${colorines[$counter]}m%2u\e[0m \e[1;3${colorines[$counter]}m%13u \e[0m\n" "${esperasinllegada[$counter]}" "${tLlegada[$counter]}" "${salida[$counter]}" "${duracion[$counter]}" "${cuentafallos[$counter]}"  | tee -a $informeColor

					echo  "|  Proceso: P$counter	T.Espera: ${esperasinllegada[$counter]}	Inicio/fin: ${tLlegada[$counter]}/${salida[$counter]}	T.Retorno: ${duracion[$counter]}	Fallos Pág.: ${cuentafallos[$counter]}" >> $informe
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
	
#	((tachado[$ejecutandoAntiguo]++))
	yy=$(($zz+${npagejecutadas[$ejecutandoAntiguo]}))
	pagina=${paginasCola[$ejecutandoAntiguo,$yy]}

	while [[ $zz -lt ${npagaejecutar[$ejecutandoAntiguo]} && $pagina != "s" ]]
		do
#			((tachado[$ejecutando]++))

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
#					echo -e " \e[1;32mEstado del proceso\e[0m \e[4${colorines[$ejecutandoAntiguo]}m\e[1;37mP0$ejecutando :\e[0m"
					#echo "" >> $informe
#					echo " Estado del proceso P0$ejecutandoAntiguo :" >> $informe
		#		else
					#echo "" | tee -a $informeColor
					#echo "" >> $informe
		#			echo -e " Se han producido ${fallos[$ejecutandoAntiguo]} fallos de pagina en el proceso P$ejecutandoAntiguo" | tee -a $informeColor
					#echo "" | tee -a $informeColor
					#echo "" >> $informe
		#			echo " Se han producido $fallos[$ejecutandoAntiguo] fallos de pagina en el proceso P$ejecutandoAntiguo" >> $informe
#					echo -e " \e[1;32mEstado del proceso\e[0m \e[4${colorines[$ejecutando]}m\e[1;37mP$ejecutando : \e[0m"
					#echo "" >> $informe
#					echo " Estado del proceso P$ejecutando : " >> $informe
		#	fi
			


#	}
		#	resumenMedios
			imprimeNRU
			
			#echo " " | tee -a $informeColor
			#echo " " >> $informe
#	fi

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
#	filaProc=" Proceso:    "
#	filaProcInf="Proceso:    "
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
#	filaMarc="Nº Marco:   "
#	filaMarcInf="Nº Marco:   "
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
					
#					filaMarc="${filaMarc}"
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
#	filaPag="Página:     "
#	filaPagInf="Página:     "
	
#	vectorNuevo=("${procesosMemoria[*]}")
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
#						filaPag="${filaPag}"
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
#	filaDir="Dir. Mem.:  "
#	filaDirInf="Dir. Mem.:  "
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
					
#					filaDir="${filaDir}"
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
#	filaCont="Contador:   "
#	filaContInf="Contador:   "
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
					
#					filaCont="${filaCont}"
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
	
#	for ((n=1; n<=13; n++ ))
#		do
#			coloresNRU[$n]="\e[1;4;32m"
#		done
#	n=14
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
	#	resumenMedios
	
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
		

		
#					echo -e "$filaProc"
#					echo -e "$filaMarc"
#					echo -e "$filaPag"
#					echo -e "$filaDir"
#					echo -e "$filaCont"

	#FALTA AÑADIR LA PARTE DE INFORME Y INFORMECOLOR
}



############



resumenMedios(){
    local tMedioEsp
    local tMedioRet
    local total=0
    local contador=0

    
    for tiem in ${esperasinllegada[*]};do
        total=$(( total + $tiem ))
        (( contador++ ))
    done
    [ $contador -ne 0 ] \
        && tMedioEsp="$(bc -l <<<"scale=2;$total / $contador")"
    total=0
    contador=0

    for tiem in ${tRetorno[*]};do
        total=$(( total + $tiem ))
        (( contador++ ))
    done
    [ $contador -ne 0 ] \
        && tMedioRet="$(bc -l <<<"scale=2;$total / $contador")"

    # IMPRESIÓN
    if [ -n "${tMedioEsp}" ];then
        printf " %s: %-9s" "Tiempo Medio de Espera" "${tMedioEsp}"
    else
        printf " %s: %-9s" "Tiempo Medio de Espera" "0.0"
    fi

    if [ -n "${tMedioRet}" ];then
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
#			if [ $position -gt $nProc ]
#				then #Si hemos llegado al final del vector lista
#					position=1
#					ejecutando=${ordenados[$position]}
#			fi
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

#											ejecutando=$counter;
											((nProcMeter++))
											paraMeter[$nProcMeter]=$counter
#											anadeCola $counter
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
#					ejecutando=${ordenados[$position]}
					fef=1
			fi
		done
		
#		if [[ $opcionEjec = 1 ]]
#			then
#				echo "" | tee -a $informeColor
#				echo "" >> $informe
#		fi
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
	echo "" >> $informe
	echo "" >> $informe
	echo "" >> $informe
	echo "" >> $informeColor
	echo "" >> $informeColor
	echo "" >> $informeColor
	


	#Declaro variables
	enMemoria=();																							#Inicializamos el vector enMemoria, para ver si los procesos están en memoria
	for (( counter = 1; counter <= $nProc; counter++ ))
		do
			enMemoria[$counter]="fuera"														#"fuera" si no está, "dentro" si está, "salido" si ha terminado
		done

	tiempoInicio=();
	for (( counter = 1; counter <= $nProc; counter++ ))
		do
			let tiempoInicio[$counter]=${tEjec[$counter]}
		done
		
        tachado=();
        for (( counter = 1; counter <= $nProc; counter++ ))
                do
                        let tachado[$counter]=0
                done

	tiempoRestante=();
	for (( counter = 1; counter <= $nProc; counter++ ))
		do
			let tiempoRestante[$counter]=${tEjec[$counter]}
		done
		
	tEjecutando=();																						#Cuenta el tiempo ejecutando de cada proceso
	for (( i = 1; i <= $nProc; i++ ))
		do
			let tEjecutando[$i]=0
		done
	
		
	npagejecutadas=();
	for (( i = 1; i <= $nProc; i++ ))
		do
			let npagejecutadas[$i]=0
		done
		
	npagaejecutar=();
	for (( i = 1; i <= $nProc; i++ ))
		do
			let npagaejecutar[$i]=0
		done
			
	i=0;
	
	
	for (( i = 1; i <= $nProc; i++ ))
		do
			let contadorPagGlob[$i]=0
		done
			
	i=0;
	
	cola[0]="vacio"
	
	
		
	for (( i = 1; i<= $nProc; i++ ))
	do
		for (( o = 0; o < ${maxpags[$i]}; o++ ))
		do
			let paginasCola[$i,$o]=${paginas[$i,$o]}
		done
		o=0
		#paginasCola[$i,$o]="s"
	
		#let npagejecutadas[$i]=0
	
		for (( ii = 0; ii < ${nMarcos[$i]}; ii++  ))   		# <= O < NO LO SE
			do
				paginasUso[$i,$ii]="vacio"
				paginasAux[$i,$ii]="vacio"
			done
		ii=0
	
		fallos[$i]=0
	done
		i=0
		

	esperaconllegada=(); 																			#Tiempo de espera acumulado
	esperasinllegada=();																			#Tiempo de espera real
	primerproceso=${ordenados[1]}															#El proceso que menos tiempo tarda en llegar
	tSistema=0;											#El tiempo que tarda el primer proceso en llegar
	salida=();																								#Tiempo de retorno
	duracion=();																							#Tiempo que ha estado el proceso desde entró hasta que terminó
	finalizados=0 																						#Procesos terminados
	seAcaba=0 																										#0 = aun no ha terminado, 1 = ya se terminó
	ejecutando=0;																							#El proceso a ejecutar en cada ronda
	cuentafallos=();																					#Cuenta los fallos de cada proceso
	aejecutar=();
	impordenado=();
	
	for (( counter = 1; counter <= $nProc; counter++ ))
		do
			let aejecutar[$counter]=0
			let impordenado[$counter]=0
		done
		
	counter=0;																								#Inicializamos contador a cero
	exe=1;																											#Ejecuciones que ha habido en una vuelta de lista
	position=0;																								#Posición del porceso que se debe ejecutar ahora
	fin=0;																											#
	indicador=0;																								#
	i=0;
	memUtiliz=0;																								#memoria utilizada
	opcionEjec=0;

	
	
	seleccionFCFS ############

	clear
	sleep 1
	echo "" >> $informe
	echo "" >> $informe
	echo "" >> $informeColor
	echo "" >> $informeColor


	for (( i = 0; i < numprocesos; i++ ))
		do
			let tejecutando[$i]=0
		done
	i=0;

	#Se acumula en su esperaconllegada el tiempo de llegada del primer proceso en llegar
	for (( fef=1; fef<= $nProc; fef++ ))
		do
			esperaconllegada[$fef]=$tSistema
		done




	#Esto ya es el algoritmo

	ordenacion

	if [[ ${tLlegada[${ordenados[1]}]} -gt 0 ]]
		then
			ejecutando=${ordenados[1]}
			aumento=${tLlegada[$primerproceso]}
			sumaTiempoEspera 1
			if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
				then
					clear
					imprimeTiempo
				#	echo " " | tee -a $informeColor
				#	echo " " >> $informe
				#	echo -e " Aún no ha llegado ningún proceso." | tee -a $informeColor
				#	echo " Aún no ha llegado ningún proceso." >> $informe

				#	if [[ ${ordenados[1]} -lt 10 ]]
				#		then
				#			echo -e " El primer proceso en llegar será P0${ordenados[1]} y lo hará en t=${tLlegada[$ejecutando]}\e[0m." | tee -a $informeColor
				#			echo " El primer proceso en llegar será P0${ordenados[1]} y lo hará en t=${tLlegada[$ejecutando]}." >> $informe
				#		else
				#			echo -e " El primer proceso en llegar será P${ordenados[1]} y lo hará en t=${tLlegada[$ejecutando]}\e[0m." | tee -a $informeColor
				#			echo " El primer proceso en llegar será P${ordenados[1]} y lo hará en t=${tLlegada[$ejecutando]}." >> $informe
				#	fi
					#echo " " | tee -a $informeColor
					#echo " " >> $informe
					diagramaresumen
					#echo " " | tee -a $informeColor
					#echo " " >> $informe
					imprimeNRU
					#echo " " | tee -a $informeColor
					#echo " " >> $informe
					diagramaMemoria
					#echo " " | tee -a $informeColor
					#echo " " >> $informe
					#diagramaTiempo
					lineadetiempoCero 0
					#echo ""
					if [[ $opcionEjec = 2 ]]
					then
						sleep $segundosesperaeventos
					else
						read -p " Pulse INTRO para continuar"
					fi
			fi
			tSistema=${tLlegada[$ejecutando]}
#			time_primero=${tLlegada[$ejecutando]}      ???????????????????????????????????????????

			clear
			
			if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
				then 
					imprimeTiempo
			fi
			
			meteEnMemoria
			actualizaCola 1
			
			ejecutando=${cola[0]}
#			mueveCola

			((nCambiosContexto++))
			tCambiosContexto[$nCambiosContexto]=$tSistema
			pEjecutados[$nCambiosContexto]=-1
			
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
		         #		echo " " | tee -a $informeColor
			#		echo " " >> $informe
					imprimeNRU
					#echo " " | tee -a $informeColor
					#echo " " >> $informe
					diagramaMemoria
					#echo " " | tee -a $informeColor
					#echo " " >> $informe
					#diagramaTiempo
					lineadetiempo
					#echo ""
					if [[ $opcionEjec = 2 ]]
					then
						sleep $segundosesperaeventos
					else
						read -p " Pulse INTRO para continuar"
		
					fi 
					
			fi
		else
			if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
				then 
					imprimeTiempo
			fi
			
			meteEnMemoria
			actualizaCola 1
					
			ejecutando=${cola[0]}
#			mueveCola
			
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
					#echo " " | tee -a $informeColor
					#echo " " >> $informe
					imprimeNRU
					#echo " " | tee -a $informeColor
					#echo " " >> $informe
					diagramaMemoria
					#echo " " | tee -a $informeColor
					#echo " " >> $informe
					#diagramaTiempo
					lineadetiempoCero 1
					#echo ""
					if [[ $opcionEjec = 2 ]]
					then
						sleep $segundosesperaeventos
					else
						read -p " Pulse INTRO para continuar"
		
					fi 
			fi
	fi
	
	
	ejecutando=${cola[0]}
	mueveCola
	
	while [ $seAcaba -eq 0 ]
		do
		
			if [[ $opcionEjec = 1 || $opcionEjec = 2 ]]
				then
					clear
					#echo "" >> $informe
					#echo "" >> $informe
					
					#echo "" >> $informeColor
					#echo "" >> $informeColor
					

			fi
#			ejecutando=${ordenados[$position]}
			

			if [ $finalizados -ne $nProc ]
				then #Cambio de contexto
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
						if [[ ${procesosMemoria[$marcoNuevo]} -eq $ejecutando ]]
						then
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

#			let position=position+1
			
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
								sleep $segundosesperaeventos
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



	#Damos valor a esperasinllegada
	for (( counter=1; counter <= $nProc; counter++ ))
		do
			let esperasinllegada[$counter]=esperaconllegada[$counter]-tLlegada[$counter]
		done
		
		if [[ $opcionEjec = 1 ]]
			then
				read -p " Pulse INTRO para continuar"
		fi
		if [[ $opcionEjec = 2 ]]
		then
			sleep $segundosesperaeventos
			
		fi 
#	resumenfinal
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

final(){
	openInforme=0;
	editor=0;
	echo " Presione INTRO para continuar"
	read
	clear
	echo -e " Fin del algoritmo" | tee -a $informeColor
	#echo
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
	
	
	echo ""
	echo -e " \e[1;38;5;81mPor último, ¿desea abrir el informe? \e[0m"
	echo ""
	echo -e "    \e[1;32m	[1]\e[0m -> Sí	"
	echo -e "    \e[1;32m	[2]\e[0m -> No	"
	echo ""
	read -p " Seleccione la opción: " openInforme
	until [[ "$openInforme" == "1" || "$openInforme" == "2" ]]
		do
			echo ""
			echo -e -n " \e[1;31mValor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
			read openInforme
		done
		
	

	if [[ $openInforme = "1" ]]
		then
			clear
			echo ""
			echo -e " \e[1;38;5;81mPor último, ¿desea abrir el informe? \e[0m"
			echo ""
			echo -e "    \e[1;38;5;64;48;5;7m   [1]\e[90m -> Sí   \e[0m"
			echo -e "    \e[1;32m   [2]\e[0m -> No	"
			echo ""
			sleep 0.5
			clear
			
			echo ""
			echo ""
#			echo "  ¿Con qué editor desea abrir el informe? (nano, vi, [vim], gvim, gedit, atom, cat (a color), otro)"
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
				
# ¿Con qué editor desea abrir el informe?"
#
#  \e[1;32mnano\e[0m, \e[1;33mvi\e[0m, \e[1;34m[vim]\e[0m, \e[1;35mgvim\e[0m, \e[1;32mgedit\e[0m, \e[1;33matom\e[0m, \e[1;34mcat (a color)\e[0m, \e[1;31motro\e[0m






			
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
					"")
						vim $informe
						echo ""
						echo " Presione cualquier tecla para continuar"
						read -n 1;;
			esac
			
		else
			clear
			echo ""
			echo -e "\e[1;38;5;81mPor último, ¿desea abrir el informe? \e[0m"
			echo ""
			echo -e "    \e[1;32m   [1]\e[0m -> Sí	"
			echo -e "    \e[1;38;5;64;48;5;7m   [2]\e[90m -> No   \e[0m"
			echo ""
			sleep 0.5
			clear
			
			echo
			echo -e "  \e[1;31mNo se abrirá el informe\e[0m"
			echo
	fi
#	sleep 2
	clear
	cabeceraFinal
	sleep 1
}


############



finalAlternativo(){
#después de haber visualizado la ayuda, finalAlternativo muestra la cabecera final y acaba la ejecución
	sleep 1
	clear
	cabeceraFinal
	sleep 1
}


############



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
			for (( n = 0; n < ${maxpags[$i]}; n++ ))
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
                        for (( n = 0; n < ${maxpags[$i]}; n++ ))
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



entradaFicheroAleatorio(){
	#toma un archivo aleatorio de los disponibles
	clear
	cabeceraInicio
	echo "" | tee -a $informeColor

	imprimefiles
	echo "" >> $informe
	echo -e " Ficheros \e[1;32mdisponibles\e[0m: " | tee -a $informeColor
	echo -n " Ficheros disponibles: " >> $informe
	aleatorio_entre fichSelect 1 $max
	minrango=0
	maxrango=0
	until [[ $tamMem =~ [0-9] && $fichSelect -gt 0 && $fichSelect -le $max ]]
		do
			echo ""
			echo -e "\e[1;31m El valor introducido no es correcto. Debe estar entre\e[0m \e[1;33m1\e[0m \e[1;31my\e[0m \e[1;33m$max\e[0m"
			echo -n " Ficheros disponibles: "
			aleatorio_entre fichSelect 1 $max
			minrango=0
			maxrango=0
		done
	clear
	cabeceraInicio
	echo ""
	imprimefiles 1
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
			maxpags[$p]=${tEjec[$p]}
			

			for (( n = 0; n < ${maxpags[$p]}; n++ ))
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
			maxpags[$p]=${tEjec[$p]}
			

			for (( n = 0; n < ${maxpags[$p]}; n++ ))
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

guardaDatosAleatorios(){
#guarda los datos que se han introducido en el fichero estandar 
	clear
	cabeceraInicio
	
#	echo -n -e " El nombre del fichero donde se guardarán los datos es datos.txt.\n"
#	sleep 1
        clear
        
        clear
	cabeceraInicio
	echo -n -e "\e[1;38;5;81m ¿Dónde quiere guardar los datos?\n"
	echo -e "    \e[1;32m   [1]\e[0m -> En la salida estándar (datos.txt)	"
	echo -e "    \e[1;32m   [2]\e[0m -> En otro fichero	"
	read -p " Seleccione opción: " elegirguardardatos
        until [[ "$elegirguardardatos" == "1" || "$elegirguardardatos" == "2" ]]
                do
                        echo ""
                        echo -e -n "\e[1;31mValor incorrecto, escriba \e[1;33m1\e[0m \e[1;31mo\e[0m \e[1;33m2\e[0m\e[1;31m: \e[0m"
                        read elegirguardardatos
                done
	case $elegirguardardatos in			#empieza un case (como un switch case) de la opcion introducida
		#caso 1
		"1")
		clear
		cabeceraInicio
		echo ""
		echo -e "\e[1;38;5;81m ¿Dónde quiere guardar los datos? "
		echo ""
		echo -e "    \e[1;38;5;64;48;5;7m	[1]\e[90m -> En la salida estándar (datos.txt)	\e[0m"
		echo -e "    \e[1;32m	[2]\e[0m -> En otro fichero	"			
		echo ""
		sleep 0.5
		;;
		
		#caso 2
		"2")
		clear
		cabeceraInicio
		echo  ""
		echo -e "\e[1;38;5;81m ¿Dónde quiere guardar los datos? "
		echo ""
		echo -e "    \e[1;32m	[1]\e[0m -> En la salida estándar (datos.txt)	"
		echo -e "   \e[1;38;5;64;48;5;7m	[2]\e[90m -> En otro fichero	\e[0m"
		sleep 0.5
		echo ""
              	echo -n -e " Introduzca el nombre del fichero donde se guardarán los datos de la práctica (sin incluir \".txt\"): "
		read ficheroestandarotro
		clear
		;;
	esac
                        
        ficheroOut="./datosScript/datos.txt"
        touch $ficheroOut
        echo "$tamMem" > $ficheroOut
        echo "$tamPag" >> $ficheroOut

        for(( i = 1; i <= $nProc; i++ ))
                do
                        echo -n "${tLlegada[$i]};" >> $ficheroOut
                        #echo -n "${tEjec[$i]};" >> $ficheroOut
                        echo -n "${nMarcos[$i]};;" >> $ficheroOut
                        for (( n = 0; n < ${maxpags[$i]}; n++ ))
                                do
                                        echo -n "${direcciones[$i,$n]};" >> $ficheroOut
                                done
                        echo "" >> $ficheroOut
                done
        #echo ""
        echo -e " Se han guardado los datos en el fichero de salida"
        
         if [[ "$elegirguardardatos" == "2" ]]
                then
                       cp "${ficheroOut}" "./datosScript/${ficheroestandarotro}.txt"
	fi

ultimoficheroman=`echo ${ficheroOut} | cut -d "/" -f3`
	echo "" | tee -a $informeColor

	echo "" >> $informe		
	echo -e " Elija un \e[1;32mfichero\e[0m: " >> $informeColor
	echo -n " Elija un fichero: " >> $informe	
	echo "$ultimoficheroman" >> $informe
	echo -e "\e[1;32m$ultimoficheroman\e[0m" >> $informeColor
}	





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
		
		entradarangoAleatorio

	fi
	clear
	cabeceraInicio
	imprimeVarGlob
	sleep 0.5
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
	
	#### Ejecución del programa ####
	
	####ALGORITMO#####
	cabecera
	cabeceraInicio
	imprimeTamano
	menuInicio
	
	if [[ menu -eq 1 ]]
		then
			
#			ficheroIn=`grep '.txt$' ./datosScript/informes/$ficheroant | cut -d " " -f5` 				#Guardar el nombre del fichero de la anterior ejecución.
			seleccionInforme
			seleccionEntrada
			FCFS
			final
		else
			clear
			cat ./datosScript/ayuda/ayuda.txt
			echo ""
			read -p " Presione INTRO para continuar"
			clear
			finalAlternativo
	fi
	

	sed -i 's/\x0//g' ${informe}			#limpia los caracteres NULL que se han impreso en el informe
	sed -i 's/\x0//g' ${informeColor}		#limpia los caracteres NULL que se han impreso en el informeColor
	
	
	###FIN###