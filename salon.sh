#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Function to display services
display_services() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo -e "~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"
  echo "$SERVICES" | while IFS="|" read -r SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Initial display of services
display_services

# Prompt for service ID until a valid one is entered
while true; do
  echo -e "\nPlease enter the service ID:"
  read SERVICE_ID_SELECTED

  # Validate the input
  VALID_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $VALID_SERVICE_ID ]]
  then
    echo -e "\nInvalid service ID. Please try again."
    display_services
  else
    break
  fi
done

# Prompt for customer phone number
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# Check if the customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  # Customer does not exist, prompt for name
  echo -e "\nIt looks like you are a new customer. Please enter your name:"
  read CUSTOMER_NAME

  # Insert new customer into the database
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

# Prompt for service time
echo -e "\nPlease enter your preferred service time (e.g., '2024-07-18 14:00'):"
read SERVICE_TIME

# Get customer ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Insert appointment into the database
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirmation message
echo -e "\nI have put you down for a $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") at $SERVICE_TIME, $CUSTOMER_NAME."
