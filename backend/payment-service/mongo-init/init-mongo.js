db.createUser({
  user: process.env.MONGO_ROOT_USERNAME,
  pwd: process.env.MONGO_ROOT_PASSWORD,
  roles: [
    { role: "readWrite", db: process.env.MONGO_INITDB_DATABASE },
    { role: "dbAdmin", db: process.env.MONGO_INITDB_DATABASE }
  ]
});

db.createCollection("payments");
db.createCollection("users");
db.createCollection("transactions"); 