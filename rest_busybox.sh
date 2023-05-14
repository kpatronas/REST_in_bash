rm -f /tmp/http_response 2>/dev/null
mkfifo /tmp/http_response

function GET_handler()
{
  # Here write your code for GET request
  MATCH_PATH_REGEX="/example/.*"
  if [[ $(expr match "$HTTP_PATH" $MATCH_PATH_REGEX) != 0 ]]
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
  if [[ $(expr match "$HTTP_PATH" $MATCH_PATH_REGEX) != 0 ]]
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
  if [[ $(expr match "$HTTP_PATH" $MATCH_PATH_REGEX) != 0 ]]
  then
    HTTP_RESPONSE="HTTP/1.1 200 OK\n\n "
  else
    _HTTP_RESPONSE="HTTP/1.1 404 Not Found\n\n "
  fi
}

function UPDATE_handler()
{
  # Here write your code for UPDATE request
  MATCH_PATH_REGEX="/example/.*"
  if [[ $(expr match "$HTTP_PATH" $MATCH_PATH_REGEX) != 0 ]]
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
  if [[ $(expr match "$HTTP_PATH" $MATCH_PATH_REGEX) != 0 ]]
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
  HTTP_METHOD_PATH_REGEX='\(.*\)\ \(.*\)\ HTTP.*'
  if expr "$transformed_line" : "$HTTP_METHOD_PATH_REGEX" > /dev/null;
  then
    HTTP_METHOD="${transformed_line%% *}"
    HTTP_PATH_VER="${transformed_line#* }"
    HTTP_PATH="${HTTP_PATH_VER%% HTTP*}"
  fi

  # Extract Content-Length

  HTTP_CONTENT_LENGTH_REGEX='Content-Length:[[:space:]]\{1,\}\([0-9]*\)'
  if expr "$transformed_line" : ".*$HTTP_CONTENT_LENGTH_REGEX.*" >/dev/null;
  then
    HTTP_CONTENT_LENGTH=`echo $transformed_line | cut -d " " -f2`
  fi
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
 echo "$(date) - $HTTP_RESPONSE - $HTTP_PATH - $HTTP_BODY" | sed 's/\\n\\n//g'
 echo -e "$HTTP_RESPONSE" > /tmp/http_response
}

# Main Loop
while true;
do
  cat /tmp/http_response | nc -l -p 3000 | http_request
done
