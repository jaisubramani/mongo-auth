# mongo-auth

+ set the username/password in entrypoint.sh

+ docker build -t mongo-auth .

+ docker run -v /tmp/mongo/data/db:/data/db -p 27017:27017 -itd mongo-auth
