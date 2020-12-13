# Trabalho elaborado por Lucas Alves Rossi Figueira, para a disciplina de Arquitetura de Computadores
# PUC Minas - Bacharelado em Engenharia de Software
# 13/12/2020

			.data		# início da área de dados

taxaAprendizado: 	.float 0.03 # label para valor da taxa de aprendizado
w0: 				.float 0.0 # label para peso1 inicial
w1: 				.float 0.8 # label para o peso2 inicial

arrayNumeros:
					.space 40   # reserva de espaço para 10 inteiros no vetor (10 * 4 bytes)
				

# mensagens que serão exibidas para indicar o inicio do treinamento e teste do neurônio
mensagemTreinamento:	.asciiz "Inicio do treinamento...\n"
mensagemTeste:			.asciiz "\nTreinamento finalizado.\n\nInicio do teste...\n\nSaidas obtidas:\n"
mensagemFim:			.asciiz "\nFim do teste.\nFim do programa."
quebraLinha:			.asciiz "\n"
		
			.text		# início do código

main:
			# carrega floats nos registradores específicos
			lwc1 $f0, taxaAprendizado
			lwc1 $f1, w0
			lwc1 $f2, w1
			
			
			add $t0, $zero, $zero   # carrega contador (i=0)
			add $t1, $zero, $zero   # registrador $t1 armazenará o valor esperado de cada iteração
			
			# imprime mensagem de início do treinamento
			addi $v0, $zero, 4 
			la $a0, mensagemTreinamento
			syscall

			add $t2, $zero, $zero 	# o registrador $t2 será utlizado para percorrer o vetor. Inicialização em 0.
			
FOR_TREINAMENTO:

			slti    $t3, $t0, 10      	# definindo que o treinamento do neurônio será feito com os 10 dados do arrayNumeros, que será preenhido neste mesmo loop
			beq $t3, $zero, PREPARA_TESTE	# quando $t3 não for menor que 5, haverá o salto para o PREPARA_TESTE
			
			#percorrendo o vetor
			lw $t4, arrayNumeros($t2)
			addi $t2, $t2, 4

			#preenhchendo o vetor com inteiros de 1 a 10
			addi $t5, $t0, 1 			#o registrador $t5 amarzena i+1 (pois i começa em 0)
			sw $t5, arrayNumeros($t2) 	# arrayNumeros[i] = i+1
			
			#conversão para float
			mtc1 $t4, $f7 
			cvt.s.w $f7, $f7

			add $t1, $t4, $t4	 	# o registrador $t1 armazena o valor esperado, ou seja, o valor da iteração atual * 2
			
			#conversão do valor esperado para float, para pordemos calcular o erro
			mtc1 $t1, $f8	
			cvt.s.w $f8, $f8

			mul.s $f5, $f7, $f1		# o registrador $f5 armazena o valor da entrada1 * w0 (peso0)
			mul.s $f6, $f7, $f2 	# o registrador $f6 armazena o valor da entrada2 * w1 (peso1)
			add.s $f4, $f5, $f6 	# o registrador $f4 armazena o valor da saída do neurônio nesta iteração, somando os valores temporários de $f5 e $f6

			sub.s $f3, $f8, $f4		# obtendo o valor do erro desta iteração

			# definindo os novos pesos
			# peso w0
			mul.s $f5, $f0, $f7 	# taxaAprendizado*entrada1
			mul.s $f6, $f3, $f5 	# erro * (taxaAprendizado*entrada1)
			add.s $f1, $f1, $f6 	# redefinindo, finalmente, o peso w0

			# peso w1
			mul.s $f5, $f0, $f7 	# taxaAprendizado*entrada2
			mul.s $f6, $f3, $f5 	# erro * (taxaAprendizado*entrada2)
			add.s $f2, $f2, $f6 	# redefinindo, finalmente, o peso w1

			addi $t0, $t0, 1 # incrementa +1 no contador
			j FOR_TREINAMENTO # volta para o início do FOR_TREINAMENTO

PREPARA_TESTE:	

			# zerando o contador e o registador responsavel por caminhar pelo arrayNumeros
			add $t2, $zero, $zero
			add $t0, $zero, $zero
			
			# imprime mensagem do fim do treinamento e início do teste
			addi $v0, $zero, 4 
			la $a0, mensagemTeste
			syscall
			j FOR_TESTE ## pula para o loop em que será feito o teste com o neurônio
			
FOR_TESTE:	

			slti    $t3, $t0, 10      	# definindo que o teste do neurônio será feito com todos os 10 valores do arrayNumeros
			beq $t3, $zero, FIM			# quando $t3 não for menor que 10, haverá o salto para o FOR_TESTE

			#percorrendo o vetor
			lw $t4, arrayNumeros($t2)
			addi $t2, $t2, 4

			#conversão para float
			mtc1 $t4, $f7
			cvt.s.w $f7, $f7

			mul.s $f5, $f7, $f1		# o registrador $f5 armazena o valor da entrada1 * w0 (peso0)
			mul.s $f6, $f7, $f2 	# o registrador $f6 armazena o valor da entrada2 * w1 (peso1)
			add.s $f4, $f5, $f6 	# o registrador $f4 armazena o valor da saída do neurônio nesta iteração, somando os valores temporários

			#exibição dos valores
			li $v0, 2
			mov.s $f12, $f4
			syscall

			# imprime quebra de linha
			addi $v0, $zero, 4 
			la $a0, quebraLinha
			syscall

			addi $t0, $t0, 1 # incrementa +1 no contador
			j FOR_TESTE # volta para o início do FOR_TESTE

FIM:                        
			# imprime mensagem do fim do teste
			addi $v0, $zero, 4 
			la $a0, mensagemFim
			syscall
            jr $ra


# Antes de construir o neurônio em MIPS, implementei o neurônio em Java para visualizar mais facilmente

# 	public static void main(String[] args) {
		
# 	float taxaAprendizado = 0.03f;
# 	int entrada1[] = new int[10];//= {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
# 	int entrada2[] = new int[10];// = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
# 	float saidaNeuronio;
# 	int valorEsperado;
# 	float erro;
# 	int i;
	
# 	//Pesos inicializados com valores aleatórios
# 	float w0 = 0.0f; //peso 1
# 	float w1 =  0.8f; //peso 2
	
	
# 	// Treinamento
# 	System.out.println("-------------INÍCIO DO TREINAMENTO-------------\n");
# 	for (i=0; i<10; i++) {
		
# 		entrada1[i] = i+1;
# 		entrada2[i] = i+1;
		
# 		valorEsperado = entrada1[i] + entrada2[i];
		
# 		saidaNeuronio = entrada1[i]*w0 + entrada2[i]*w1;
		
# 		erro = valorEsperado - saidaNeuronio;
		
# 		w0 += erro*taxaAprendizado*entrada1[i]; 
# 		w1 += erro*taxaAprendizado*entrada2[i]; 

# 		System.out.println("\n--- DADOS DA ITERAÇÃO " + i + " ---\n");
# 		System.out.println("Entrada 1: " + entrada1[i]);
# 		System.out.println("Entrada 2: " + entrada2[i]);
# 		System.out.println("\nSaída esperada: " + valorEsperado);
# 		System.out.println("Saída obtida: " + saidaNeuronio);
# 		System.out.println("\nErro: " + erro);
# 		System.out.println("\n Novos pesos: \n- w0: " + w0 + "\n- w1: " + w1);
# 		System.out.println("\n\n");
# 	}
# 	System.out.println("\n-------------FIM DO TREINAMENTO-------------\n\n");
	
# 	// Teste
# 		System.out.println("--------------INÍCIO DO TESTE-------------\n");
# 		System.out.println("PESOS FINAIS OBTIDOS DO TREINAMENTO:\n- w0: " + w0 + "\n- w1: " + w1 + "\n\n");
# 		for(i=0; i<10; i++) {
# 			saidaNeuronio = entrada1[i]*w0 + entrada2[i]*w1;
			
# 			System.out.println("\n--- DADOS DA ITERAÇÃO " + i + " ---\n");
# 			System.out.println(entrada1[i] + " + " + entrada2[i] + " = " + saidaNeuronio);
			
# 		}
# 		System.out.println("\n-------------FIM DO TESTE-------------");

# 	}