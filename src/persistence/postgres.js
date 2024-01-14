const waitPort = require('wait-port');
const fs = require('fs');
const { Client } = require('pg');

const {
    POSTGRES_HOST: HOST,
    POSTGRES_HOST_FILE: HOST_FILE,
    POSTGRES_USER: USER,
    POSTGRES_USER_FILE: USER_FILE,
    POSTGRES_PASSWORD: PASSWORD,
    POSTGRES_PASSWORD_FILE: PASSWORD_FILE,
    POSTGRES_DB: DB,
    POSTGRES_DB_FILE: DB_FILE,
} = process.env;

let client;

async function init() {
    const host = HOST_FILE ? fs.readFileSync(HOST_FILE) : HOST;
    const user = USER_FILE ? fs.readFileSync(USER_FILE) : USER;
    const password = PASSWORD_FILE ? fs.readFileSync(PASSWORD_FILE, 'utf8') : PASSWORD;
    const database = DB_FILE ? fs.readFileSync(DB_FILE) : DB;

    await waitPort({ 
        host, 
        port: 5432,
        timeout: 10000,
        waitForDns: true,
    });

    client = new Client({
        host,
        user,
        password,
        database
    });

    return client.connect().then(async () => {
        console.log(`Connected to postgres db at host ${HOST}`);
        // Run the SQL instruction to create the table if it does not exist
        await client.query('CREATE TABLE IF NOT EXISTS todo_items (id varchar(36), name varchar(255), completed boolean)');
        console.log('Connected to db and created table todo_items if it did not exist');
    }).catch(err => {
        console.error('Unable to connect to the database:', err);
    });
}

// Get all items from the table
async function getItems() {
  return client.query('SELECT * FROM todo_items').then(res => {
    return res.rows.map(row => ({
      id: row.id,
      name: row.name,
      completed: row.completed
    }));
  }).catch(err => {
    console.error('Unable to get items:', err);
  });
}


// End the connection
async function teardown() {
  return client.end().then(() => {
    console.log('Client ended');
  }).catch(err => {
    console.error('Unable to end client:', err);
  });
}
  
// Get one item by id from the table
async function getItem(id) {
    return client.query('SELECT * FROM todo_items WHERE id = $1', [id]).then(res => {
      return res.rows.length > 0 ? res.rows[0] : null;
    }).catch(err => {
      console.error('Unable to get item:', err);
    });
}
  
// Store one item in the table
async function storeItem(item) {
    return client.query('INSERT INTO todo_items(id, name, completed) VALUES($1, $2, $3)', [item.id, item.name, item.completed]).then(() => {
      console.log('Stored item:', item);
    }).catch(err => {
      console.error('Unable to store item:', err);
    });
}
  
// Update one item by id in the table
async function updateItem(id, item) {
    return client.query('UPDATE todo_items SET name = $1, completed = $2 WHERE id = $3', [item.name, item.completed, id]).then(() => {
      console.log('Updated item:', item);
    }).catch(err => {
      console.error('Unable to update item:', err);
    });
}
  
// Remove one item by id from the table
async function removeItem(id) {
    return client.query('DELETE FROM todo_items WHERE id = $1', [id]).then(() => {
      console.log('Removed item:', id);
    }).catch(err => {
      console.error('Unable to remove item:', err);
    });
}
  
module.exports = {
  init,
  teardown,
  getItems,
  getItem,
  storeItem,
  updateItem,
  removeItem,
};
