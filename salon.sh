#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

HOME_MENU() {
  echo -e "\n$1"
  # get available service
  # SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # display available service
  # echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE
  # do
  #   echo "$(echo $SERVICE_ID | sed -r 's/^ *| *$//g')) $SERVICE"
  # done

  echo -e "\n1) cut\n2) manicure\n3) pedicure"
  
  #ask for service to book
  read SERVICE_ID_SELECTED
     #go to service menu
  case $SERVICE_ID_SELECTED in
    1) SERVICE_MENU "$SERVICE_ID_SELECTED" ;;
    2) SERVICE_MENU "$SERVICE_ID_SELECTED" ;;
    3) SERVICE_MENU "$SERVICE_ID_SELECTED" ;;
    *) HOME_MENU "Please enter a valid option." ;;
  esac

  # if not a number
  # if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  # then
  #   # return to home with message
  #   HOME_MENU "Please input a number"
  # else
  
# fi
}

SERVICE_MENU() {

  SERVICE_ID_SELECTED=$1
  # check service in database
  SERVICE_NAME_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME_RESULT ]]
  then 
    #send to HOME_MENU
    HOME_MENU "I could not find that service. What would you like today?"
  else

  #get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?" 
    read CUSTOMER_NAME

    #insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # get time appoinment
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME_RESULT, $CUSTOMER_NAME? | sed -r 's/^ *| *$//g')"
  read SERVICE_TIME

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # insert appointment detail
  INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_SERVICE_RESULT != "INSERT 0 1" ]]
  then
    # return to home with message
    HOME_MENU "Could not schedule appointment, please schedule another service or try again later."
  else 

  # print success message 
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME_RESULT at $SERVICE_TIME, $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
fi
}

HOME_MENU "Welcome to My Salon, how can I help you?"
