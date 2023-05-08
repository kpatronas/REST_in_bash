#!/bin/bash

# Create a fifo that will hold the http response for every http request
rm -f /tmp/http_response 2>/dev/null
mkfifo /tmp/http_response

function GET_handler()
{
  # Here write your code for GET request
  MATCH_PATH_REGEX="/example/.*"
  if [[ "$HTTP_PATH" =~ $MATCH_PATH_REGEX ]]
  then
    HTTP_RESPONSE="HTTP/1.1 200 OK\n\n "
  else
    HTTP_RESPONSE="HTTP/1.1 404 Not Found\n\n "
  fi
}

function POST_handler()
{
  # Here write your code for POST request
  MATCH_PATH_REGEX="/example/.*"
  if [[ "$HTTP_PATH" =~ $MATCH_PATH_REGEX ]]
  then
    HTTP_RESPONSE="HTTP/1.1 201 OK\n\n "
  else
    HTTP_RESPONSE="HTTP/1.1 404 Not Found\n\n "
  fi
}

function DELETE_handler()
{
  # Here write your code for DELETE request
  MATCH_PATH_REGEX="/example/.*"
  if [[ "$HTTP_PATH" =~ $MATCH_PATH_REGEX ]]
  then
    HTTP_RESPONSE="HTTP/1.1 200 OK\n\n "
  else
    HTTP_RESPONSE="HTTP/1.1 404 Not Found\n\n "
  fi
}

function UPDATE_handler()
{
  # Here write your code for UPDATE request
  MATCH_PATH_REGEX="/example/.*"
  if [[ "$HTTP_PATH" =~ $MATCH_PATH_REGEX ]]
  then
    HTTP_RESPONSE="HTTP/1.1 200 OK\n\n "
  else
    HTTP_RESPONSE="HTTP/1.1 404 Not Found\n\n "
  fi
}

function PUT_handler()
{
  # Here write your code for PUT request
  MATCH_PATH_REGEX="/example/.*"
  if [[ "$HTTP_PATH" =~ $MATCH_PATH_REGEX ]]
  then
    HTTP_RESPONSE="HTTP/1.1 200 OK\n\n "
  else
    HTTP_RESPONSE="HTTP/1.1 404 Not Found\n\n "
  fi
}

function INVALID_handler()
{
  # Here write your code for an INVALID HTTP Method
  HTTP_RESPONSE="HTTP/1.1 405 Invalid Method\n\n "
}

# Process HTTP Request
function http_request()
{

 # Parse HTTP Request Parts
 while read line;
 do

  # Remove \r\n
  transformed_line=$(echo $line | tr -d '[\r\n]')

  # Exit loop if var empty
  [ -z "$transformed_line" ] && break

  # Extract HTTP Method and Path
  HTTP_METHOD_PATH_REGEX='(.*?)\s(.*?)\sHTTP.*?'
  [[ "$transformed_line" =~ $HTTP_METHOD_PATH_REGEX ]] && HTTP_METHOD=$(echo $transformed_line | sed -E "s/$HTTP_METHOD_PATH_REGEX/\1/")
  [[ "$transformed_line" =~ $HTTP_METHOD_PATH_REGEX ]] && HTTP_PATH=$(echo $transformed_line | sed -E "s/$HTTP_METHOD_PATH_REGEX/\2/")

  # Extract Content-Length
  HTTP_CONTENT_LENGTH_REGEX='Content-Length:\s(.*?)'
  [[ "$transformed_line" =~ $HTTP_CONTENT_LENGTH_REGEX ]] && HTTP_CONTENT_LENGTH=$(echo $transformed_line | sed -E "s/$HTTP_CONTENT_LENGTH_REGEX/\1/")

 done

 # IF HTTP CONTENT LENGTH
 if [ ! -z "$HTTP_CONTENT_LENGTH" ];
 then
  while read -n$HTTP_CONTENT_LENGTH -t1 line;
  do
   [ -z "$line" ] && break
   HTTP_BODY="$HTTP_BODY "$line
  done
 fi

 # HTTP Method Selector
 case "$HTTP_METHOD" in
  "GET")    GET_handler;;
  "POST")   POST_handler;;
  "DELETE") DELETE_handler;;
  "UPDATE") UPDATE_handler;;
  "PUT")    PUT_handler;;
  *)        INVALID_handler;;
 esac
 echo "$(date) - $HTTP_RESPONSE - $HTTP_PATH - $HTTP_BODY"
 echo -e "$HTTP_RESPONSE" > /tmp/http_response
}

# Main Loop
while true;
do
  cat /tmp/http_response | nc -lN 3000 | http_request
done
