#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --tuples-only --no-align -c"

# Genera un número aleatorio entre 1 y 1000
RANDOM_NUMBER=$((1 + RANDOM % 1000))
ATTEMPTS=1

echo -e "Enter your username:\n"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# if user doesn't exist
if [[ -z $USER_ID ]]
then
  # get new customer name
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  USER_DATA=$($PSQL "SELECT username, games_played, best_game FROM users WHERE user_id = $USER_ID")
  # SeparO los campos usando awk
  username=$(echo "$USER_DATA" | awk -F"|" '{print $1}')
  games_played=$(echo "$USER_DATA" | awk -F"|" '{print $2}')
  best_game=$(echo "$USER_DATA" | awk -F"|" '{print $3}')

  echo -e "\nWelcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

echo -e "Guess the secret number between 1 and 1000:\n"


  while true; do
    read NUMBER_USER
    if [[ $NUMBER_USER =~ ^[0-9]+$ ]]
    then
      if [ $NUMBER_USER -eq $RANDOM_NUMBER ]
      then
        echo "You guessed it in $ATTEMPTS tries. The secret number was $RANDOM_NUMBER. Nice job!"
        if [[ $ATTEMPTS -lt $best_game || $best_game -eq 0 ]]
        then
          UPDATE_ATTEMPTS=$($PSQL "UPDATE users SET best_game = $ATTEMPTS WHERE username = '$USERNAME';")
        fi
        UPDATE_INFO=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME';")
        break
      elif [ $NUMBER_USER -lt $RANDOM_NUMBER ]; then
        ((ATTEMPTS += 1))
        echo -e "It's higher than that, guess again:\n"
      else
        ((ATTEMPTS+= 1))
        echo -e "It's lower than that, guess again:\n"
      fi
    else
      ((ATTEMPTS+= 1))
      echo -e "That is not an integer, guess again:\n"
    fi
  done
  