#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USERNAME_RESULT=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USERNAME_RESULT ]]
then
  GAMES_PLAYED=0
  ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
else
  IFS='|' read GAMES_PLAYED BEST_GAME <<< $USERNAME_RESULT
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

RAND=$(($RANDOM%1000))

GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

while [[ ! $GUESS = $RAND ]]
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    
  else
    ((GUESS_COUNT++))
    if [[ $RAND > $GUESS ]]
    then
      echo "It's higher than that, guess again:"

    elif [[ $RAND < $GUESS ]]
    then
      echo "It's lower than that, guess again:"
    
    else
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $RAND. Nice job!"

      ((GAMES_PLAYED++))
      GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
      if [[ (-z $BEST_GAME) || ($BEST_GAME > $GUESS_COUNT) ]]
      then
        NEW_BEST=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE username='$USERNAME'")
      fi
    fi
  fi
done