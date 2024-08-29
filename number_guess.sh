#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo -n "Enter your username: "
read USERNAME

USER_RESULT=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
if [[ $USER_RESULT ]]
then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  GAMES_PLAYED=0
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES ('$USERNAME', $GAMES_PLAYED)")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo -n "Guess the secret number between 1 and 1000: "
read NUMBER

NUMBER_OF_GUESS=1
while [[ $NUMBER -ne $SECRET_NUMBER ]]
do
  if [[ $NUMBER =~ ^[0-9]+$ ]]
  then
    if [[ $NUMBER -lt $SECRET_NUMBER ]]
    then
      echo -n "It's higher than that, guess again: "
    elif [[ $NUMBER -gt $SECRET_NUMBER ]]
    then
      echo -n "It's lower than that, guess again: "
    fi
  else
    echo -n "That is not an integer, guess again: "
  fi
  (( NUMBER_OF_GUESS++ ))
  read NUMBER
done

(( GAMES_PLAYED++ ))
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
if [[ $BEST_GAME ]]
then
  if [[ $NUMBER_OF_GUESS -lt $BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESS WHERE username = '$USERNAME'")
  fi
else
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESS WHERE username = '$USERNAME'")
fi
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")

echo "You guessed it in $NUMBER_OF_GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"