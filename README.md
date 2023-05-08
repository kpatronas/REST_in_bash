# REST_in_bash
A simple REST server in Bash

Why on earth someone might need a REST server written in bash? maybe very small embedded systems that happen to have the nc command? (the TCP listener) and you want to do whatever you might think!

To setup this script you need to do two things
```
chmod +x ./rest.sh
```
Write some code for each Method Handler
Example:
```
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
```
You might also want to change the listening port from 3000 to something else
```
cat /tmp/http_response | nc -lN 3000 | http_request
```
