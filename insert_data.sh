#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE teams, games RESTART IDENTITY")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then 
  # get team_id from winner
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

  # if not found
  if [[ -z $TEAM_ID ]]
  then 
    # insert winner name
    INSERT_WINNER_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    if [[ $INSERT_WINNER_NAME_RESULT == "INSERT 0 1" ]]
    then 
      echo Inserted into names, $WINNER
    fi

    # get new team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  fi

  # get team_id from opponent
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  # if not found
  if [[ -z $TEAM_ID ]]
  then
    # insert opponent name
    INSERT_OPPONENT_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if [[ $INSERT_OPPONENT_NAME_RESULT == "INSERT 0 1" ]]
    then 
     echo Inserted into names, $OPPONENT
    fi

    # get new team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # insert game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then echo Inserted into games, $WINNER_ID $OPPONENT_ID
    fi
  fi
done