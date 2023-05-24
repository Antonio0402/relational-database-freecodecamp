#! /bin/bash 

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME
USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USERNAME'")
if [[ -z $USERNAME_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(user_name, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  if [[ $INSERT_USER_RESULT == "INSERT 0 1" ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USERNAME'")
  fi
else
  USERNAME_INFO=$($PSQL "SELECT user_name, games_played, best_game FROM users WHERE user_id=$USERNAME_ID")
  echo "$USERNAME_INFO" | while IFS="|" read USER_NAME GAMES_PLAYED BEST_GAME
  do
  echo "Welcome back, $(echo $USER_NAME | sed -r 's/^ *| *$//g')! You have played $(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g') games, and your best game took $(echo $BEST_GAME | sed -r 's/^ *| *$//g') guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESS=0
while true
do
  read GUESS_NUMBER
  NUMBER_OF_GUESS=$(($NUMBER_OF_GUESS + 1))
  if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
  echo "That is not an integer, guess again:"
  continue
  elif [[ $GUESS_NUMBER > $RANDOM_NUMBER ]]
  then
  echo "It's lower than that, guess again:"
  continue
  elif [[ $GUESS_NUMBER < $RANDOM_NUMBER ]]
  then
  echo "It's higher than that, guess again:"
  continue 
  elif [[ $GUESS_NUMBER == $RANDOM_NUMBER ]]
  then 
  echo "You guessed it in $NUMBER_OF_GUESS tries. The secret number was $GUESS_NUMBER. Nice job!"
  break
  fi
  break
done

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USERNAME_ID")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USERNAME_ID")
let "GAMES_PLAYED++"
if [[ $NUMBER_OF_GUESS < $BEST_GAME ]] || [[ $BEST_GAME == 0 ]]
then
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESS WHERE user_id=$USERNAME_ID")
fi
UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USERNAME_ID")

