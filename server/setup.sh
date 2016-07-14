#/bin/bash!

curl https://www.npmjs.org/install.sh | sh
npm install npm -g
npm install --silent -g parse-server
echo "parse-server --appId ZoalMIIVftZEKQoUcIWFkQqJWDsn2zYF8jJZiBlz --masterKey 5NZ0hrLBeCxB4EHMvmz8bxiD7r1BXGRvEqTmvkAS --databaseURI mongodb://john:fourzero40@ds011024.mlab.com:11024/valley-quest" > run.sh
chmod +x run.sh