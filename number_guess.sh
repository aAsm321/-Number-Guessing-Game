#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
if [[ -z $USER_ID ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  x=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

COUNT=0
SECRET_NUMBER=$(( $RANDOM % 1001 ))
echo "Guess the secret number between 1 and 1000:"
read INPUT
while true
do
  COUNT=$((COUNT+1))
  if [[ ! $INPUT =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif (( INPUT < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( INPUT > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  elif (( INPUT == SECRET_NUMBER )); then
    x=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $COUNT);")
    echo "You guessed it in $COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    exit 0;
  fi
  read INPUT
done