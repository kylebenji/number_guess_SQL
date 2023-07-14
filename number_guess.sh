#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~ Random Number Guesser ~~~~\n"

RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ));

echo -e "Enter your username:"
read USERNAME

#check for username
USER_INFO=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
if [[ -z $USER_INFO ]]
then
  #if no user data in database
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  ADD_USER='y'
else
  #if username exists, print message
  ADD_USER='n'
  echo "$USER_INFO" | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

#variables
FOUND='f'
NUMBER_OF_GUESSES=0

#get guess
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

#guess number loop
while [[ $FOUND = 'f' ]]
do
  #increment numGuesses
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))

  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
  done
  
  #check for match and print response
  if [[ $GUESS = $RANDOM_NUMBER ]]
  then
    FOUND='t'
    echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  else
    if [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
    elif [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      read GUESS
    fi
  fi
done

#add new info to sql database
if [[ $ADD_USER = 'y' ]]
then
  ADD_USER_RESULT=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',1,$NUMBER_OF_GUESSES)")
else
  echo "$USER_INFO" | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    LOWEST_SCORE=$(( NUMBER_OF_GUESSES > BEST_GAME ? BEST_GAME : NUMBER_OF_GUESSES ))
    ADD_USER_RESULT=$($PSQL "UPDATE users SET games_played=games_played+1, best_game=$LOWEST_SCORE WHERE username='$USERNAME'")
  done
fi