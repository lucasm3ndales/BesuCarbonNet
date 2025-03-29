#!/bin/bash

echo "Verificando sessões Tmux ativas..."
echo "---------------------------------"

# Lista todas as sessões Tmux
sessions=$(tmux list-sessions 2>/dev/null)

if [ -z "$sessions" ]; then
  echo "Nenhuma sessão Tmux encontrada."
  exit 0
else
  echo "Sessões Tmux disponíveis:"
  echo "$sessions"
  echo "---------------------------------"
  
  # Pergunta ao usuário o que deseja fazer
  PS3='Selecione uma opção: '
  options=(
    "Entrar em uma sessão"
    "Criar nova sessão"
    "Sair sem fazer nada"
  )
  
  select opt in "${options[@]}"
  do
    case $opt in
      "Entrar em uma sessão")
        read -p "Digite o nome da sessão que deseja entrar: " session_name
        if tmux has-session -t "$session_name" 2>/dev/null; then
          echo "Entrando na sessão '$session_name'..."
          echo "Dica: Para sair sem encerrar a sessão, pressione Ctrl+B seguido de D"
          sleep 2
          tmux attach -t "$session_name"
        else
          echo "Sessão '$session_name' não encontrada!"
        fi
        break
        ;;
      "Criar nova sessão")
        read -p "Digite o nome para a nova sessão: " new_session
        echo "Criando nova sessão '$new_session'..."
        tmux new-session -s "$new_session"
        break
        ;;
      "Sair sem fazer nada")
        echo "Saindo..."
        break
        ;;
      *) 
        echo "Opção inválida"
        ;;
    esac
  done
fi

echo "---------------------------------"
echo "Comandos úteis do Tmux:"
echo "• Ctrl+B D - Desconectar da sessão atual (sem encerrar)"
echo "• Ctrl+B C - Criar nova janela"
echo "• Ctrl+B N - Ir para próxima janela"
echo "• Ctrl+B P - Ir para janela anterior"
echo "• Ctrl+B [0-9] - Ir para janela específica"
echo "• Ctrl+B % - Dividir painel verticalmente"
echo "• Ctrl+B \" - Dividir painel horizontalmente"