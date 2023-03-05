#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
SERVICES_LIST=$($PSQL "SELECT * FROM services ORDER BY service_id;")
SERVICE_ID=""

echo -e "\n~~~~~ Hair Appointment Booking System ~~~~~\n"

# repeat until selected service ID valid
while [[ -z $SERVICE_ID ]]
do

  # show list of services and read input
  echo -e "Please select one of our services:"
  echo "$SERVICES_LIST" | sed 's/ |/)/'
  read SERVICE_ID_SELECTED

  # query selected service ID
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  
  # if not found, display error message
  if [[ -z $SERVICE_ID ]]
  then
    echo -e "\nNot a valid service number."
  else
    # valid service ID, query name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID';")
  fi

done

# read input for phone number
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# query customer ID using phone number
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

# if not found, add new customer
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nNo matching record found. Please enter your name:"
  read CUSTOMER_NAME
  NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  # query newly created customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
else
  # known customer, query name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")
fi

# read input for appointment time
echo -e "\nWhat time would you like to book your appointment?"
read SERVICE_TIME

# add appointment to database
NEW_APPT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

# confirmation message, remove any spaces from names
SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')
CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
