# UPM 3º Semestre - Ciências da Computação - Organização de Computadores
# Miguel Piñeiro Coratolo Simões - RA 10427085
# Bruno Germanetti Ramalho - RA 10426491

.data 
	msg_vetor: .asciiz "Insira o tamanho do vetor que deseja ordenar: "
	msg_nums: .asciiz "Insira seus números: "
	msg_contador: .asciiz "Total de trocas: "
	msg_output: .asciiz "Vetor Ordenado: "
	inicio_vetor: .space 50
	virgula: .asciiz ", "
	colchetes_abre: .asciiz "[ " 
	colchetes_fecha: .asciiz " ]\n"
.text	
.globl main
main:
	#Solicitar tamanho da lista para o usuário
	li $v0,4
	la $a0, msg_vetor
	syscall

	#Recebe resposta do usuário em $v0
	li $v0,5
	syscall

	# Salva resposta do usuário em $t4 (Será utilizada para as iterações no loop de criação do vetor)
	# Salva resposta também em e $s2, será utilizado no Bubble Sort
	move $t4, $v0
	sub $s2, $v0, 1 # Subtrai 1 aqui pois o loop interno do Bubble Sort realiza n - 1 iteraçõe
	move $t6, $v0 # Salvei também em $t6 para utilizar no print final, porém reconheco que nesse ponto talvez fosse interessante rever o fluxo do programa
	
	# Inicio do vetor em que aplicaremos os valores passados pelo usuário
	la $t1, inicio_vetor
	
	# Funções de criação do vetor e ordenação
	jal cria_vetor
	jal bubble_sort
	
	# Imprime os resultados do programa
	jal resultados
	
	
	# Encerrar o programa
    	li $v0, 10
    	syscall

# Função para criação do vetor	
cria_vetor:
	#Verifica se chegamos ao final do loop
	beqz $t4, fim_loop_vetor
	
	#Solicitar próximo número
	li $v0,4
	la $a0, msg_nums
	syscall

	#Recebe número
	li $v0,5
	syscall
	
	#Salva o número
	sw $v0,($t1)
	
	# Atualiza próximo endereço de memória e contador do loop
	add $t1, $t1, 4
	sub $t4, $t4, 1
	
	j cria_vetor
	
	fim_loop_vetor:
		jr $ra


# Função do Bubble Sort
bubble_sort:
	# Inicializando $t5 para realizar comparações com $t4 para parar o algoritmo quando não houver trocas dentro de 1 iteração
	# Optei por essa forma pois achei que se não esperarmos o loop_externo terminar, ganharemos tempo em alguns cenários
	# Usarei nessa função $t4 como contador de trocas
	li $t5, -1 
	loop_externo:
		beq $t5, $t4, fim_bubble_sort
		move $t5, $t4 # Copia $t4 em $t5 pois se estiverem iguais na próxima iteração, terminamos a ordenação
		la $t1, inicio_vetor # Reset do endereço do inicio do vetor após cada iteração interna
		
		move $s1, $s2 # Copia o tamanho do vetor para o iterador interno
		sub $s2, $s2, 1 # Reduz o tamanho calculado do vetor pois a cada iteração garantimos que mais um item esteja corretamente posicionado no final do vetor
		bltz $s2, fim_bubble_sort
		loop_interno:
			#$t2 e t3 serão utilizados para as comparações
			
			# Obtem ambos valores arr[j] e arr[j+1]
			lw $t2, ($t1)
			add $t1, $t1, 4
			lw $t3, ($t1)
			
			# Caso o segundo seja maior, troca
			bgt $t2, $t3, troca
			
			# Caso contrário, anda 
			anda:
				sub $s1, $s1, 1
				beqz $s1, loop_externo	
				j loop_interno
			
			troca: 
				# Realiza a troca 
				sw $t2, ($t1)
				sub $t1, $t1, 4
				sw $t3, ($t1)
				add $t1, $t1, 4
				
				add $t4, $t4, 1 # Contador de trocas 
				j anda

	fim_bubble_sort:
		jr $ra

resultados: 
	# Resetar $t1 para apontar para o começo do vetor
	la $t1, inicio_vetor # Reset do endereço do inicio do vetor após cada iteração interna
	
	# Imprime frase de resultado
	li $v0, 4
	la $a0, msg_output
	syscall
	
	# Abre colchetes
	la $a0, colchetes_abre
	syscall
	
	# Precisei usar esses registradores para realizar meu jump pois o retorno para meu main está armazenado em $ra
	la $t8, print_loop
	jalr $t7, $t8
			
	# Fecha colchetes
	la $a0, colchetes_fecha
	li $v0, 4
	syscall
	
	# Imprime mensagem de resultado do contador
	li $v0, 4
	la $a0, msg_contador
	syscall
	
	# Imprime contagem de trocas
	li $v0, 1
	move $a0, $t4
	syscall
	
	jr $ra
	
	
	
			
# Print vetor
print_loop:
	# Print o número
	li $v0, 1
	lw $a0, ($t1)
	syscall
		
	# Verifica se já printamos todos os números, coloquei nesssa posição para não imprimir a virgula errado, mesmo ficando mais desorganizado
	sub $t6, $t6, 1
	beqz $t6, print_loop_fim
		
	# Print a virgula
	li $v0, 4
	la $a0, virgula
	syscall
		
	add $t1, $t1, 4
		
	j print_loop
			
	print_loop_fim:
		jr $t7

# Usos dos registradores T:
# $t1: Utilizado ao longo do programa para referenciar o inicio do vetor, e cada passo dentro dele
# $t2: Utilizado no Bubble Sort como arr[j]
# $t3: Utilizado no Bubble Sort como arr[j+1]
# $t4: Foi meu coringa, utilizei como contador de diferentes formas ao longo do programa
# $t5: Utilizado para registrar o último valor de $t4 no Bubble Sort, para verificar se alguma iteração não realizou trocas
# $t6: Utilizado como contador para print de resultados
# $t7: Utilizado como Return Jump para não bagunçar o Jump para a main
# $t8: Utilizado para trazer o endereço da label print_loop para a instrução jalr
# Uso dos registradores S:
# $s1: Utilizado como referência no loop interno do Bubble Sort
# $s2: Utilizado como referência no loop externo do Bubble Sort